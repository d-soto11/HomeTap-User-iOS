//
//  RedeemViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 9/9/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class RedeemViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ticketField: UITextField!
    @IBOutlet weak var redeemB: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        self.redeemB.roundCorners(radius: K.UI.round_px)
        self.redeemB.addNormalShadow()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func redeem(_ sender: Any) {
        self.ticketField.resignFirstResponder()
        let mb = MBProgressHUD.showAdded(to: self.view, animated: true)
        mb.label.text = "Verificando cupón"
        if let coupon = self.ticketField.text, self.ticketField.text != "" {
            guard !coupon.contains(".") && !coupon.contains("#") && !coupon.contains("$") &&
            !coupon.contains("[") && !coupon.contains("]") else {
                mb.hide(animated: true)
                self.showError(err: "*No hemos encontrado registro de este código, intenta usar otro")
                return
            }
            Coupon.verify(coupon: coupon, callback: { (verified) in
                mb.hide(animated: true)
                if verified != nil {
                    if let expiration_date = verified!.expires{
                        if expiration_date >= Date() {
                            if verified!.multiple ?? false {
                                // Multiple use
                                K.User.client?.checkUsedCoupon(coupon: coupon, callback: { (used) in
                                    if used {
                                        self.showError(err: "*Ya has usado este código antes")
                                    } else {
                                        // Lo puede usar
                                        K.User.client?.credits = (K.User.client?.credits ?? 0) + (verified?.credits ?? 0)
                                        K.User.client?.save()
                                        verified!.used = true
                                        verified!.save()
                                        K.User.client?.useCoupon(coupon: coupon)
                                        let congrats = String(format: "Se han redimido %.0f COP en tu cuenta, ¡disfrútalos!", verified!.credits ?? 0)
                                        self.showAlert(title: "¡Felicitaciones!", message: congrats, closeButtonTitle: "Continuar")
                                    }
                                })
                            } else {
                                // Single use
                                if verified!.used ?? false {
                                    self.showError(err: "*Este código ya ha sido utilizado antes")
                                } else {
                                    K.User.client?.credits = (K.User.client?.credits ?? 0) + (verified?.credits ?? 0)
                                    K.User.client?.save()
                                    verified!.used = true
                                    verified!.save()
                                    K.User.client?.useCoupon(coupon: coupon)
                                    self.showAlert(title: "¡Cupón redimido!", message: "Hemos agregado los créditos a tu cuenta.", closeButtonTitle: "Genial")
                                }
                            }
                        } else {
                            self.showError(err: "*Este código ya no está disponible")
                        }
                    } else {
                        self.showError(err: "*Este código ya no está disponible")
                    }
                } else {
                    self.showError(err: "*No hemos encontrado registro de este código, intenta usar otro")
                }
            })
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showError(err: "*No hemos podido leer el código, intenta de nuevo")
        }
    }
    
    private func showError(err: String) {
        self.errorLabel.text = err
        UIView.animate(withDuration: 0.5) {
            self.errorLabel.alpha = 1
        }
    }
    
    private func hideError() {
        UIView.animate(withDuration: 0.5) {
            self.errorLabel.alpha = 0
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        hideError()
        return true
    }

}
