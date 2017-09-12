//
//  AddPaymentViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/27/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD

class AddPaymentViewController: UIViewController {

    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var paymentCardView: UIView!
    
    var loadedCardView: PaymentsCardViewController? = nil
    
    public class func add(parent: UIViewController) {
        let st = UIStoryboard.init(name: "Payments", bundle: nil)
        let add = st.instantiateViewController(withIdentifier: "Add") as! AddPaymentViewController
        parent.show(add, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.saveB.addNormalShadow()
        self.saveB.roundCorners(radius: K.UI.round_px)
        if (loadedCardView == nil) {
            loadedCardView = PaymentsCardViewController.showCardView(parent: self, frame: self.paymentCardView.frame)
        }
    }
    

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePayment(_ sender: Any) {
        let mb = MBProgressHUD.showAdded(to: self.view, animated: true)
        mb.label.text = "Guardando medio de pago"
        loadedCardView?.tokenizeCreditCard(callback: { (card) in
            mb.hide(animated: true)
            guard card != nil else {
                self.showAlert(title: "Lo sentimos", message: "No hemos podido verificar tu tarheta. Intenta de nuevo.", closeButtonTitle: "Entendido")
                return
            }
            K.User.client!.savePayment(payment: card!)
            card!.save()
            self.back(self)
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
