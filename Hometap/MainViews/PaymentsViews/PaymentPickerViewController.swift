//
//  PaymentPickerViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/27/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import DropDown
import MBProgressHUD

class PaymentPickerViewController: UIViewController {

    @IBOutlet weak var paymentPicker: UIView!
    @IBOutlet weak var currentPayment: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var payB: UIButton!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var saveB: UIButton!
    
    private var payments: [PaymentCard]! = []
    private var service: Service!
    
    public var selected_index: Int = 0
    
    let dropDown = DropDown()
    
    var loaded_card_view: PaymentsCardViewController?
    var save_payment: Bool = false
    
    public class func showPicker(service: Service, parent: UIViewController) {
        let st = UIStoryboard.init(name: "Payments", bundle: nil)
        let picker = st.instantiateViewController(withIdentifier: "Picker") as! PaymentPickerViewController
        
        picker.service = service
        parent.show(picker, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        K.User.client?.payments(callback: { (payment, total) in
            if payment != nil {
                self.payments.append(payment!)
                if (self.payments.count == total) {
                    
                    self.paymentPicker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tooglePicker)))
                    
                    self.configureDropDown()
                }
            } else {
                self.paymentPicker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tooglePicker)))
                self.configureDropDown()
            }
        })

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        self.payB.addNormalShadow()
        self.payB.roundCorners(radius: K.UI.round_px)
    }

    public func configureDropDown() {
        dropDown.anchorView = self.paymentPicker
        dropDown.dismissMode = .onTap
        dropDown.direction = .bottom
        var places_names = payments.map { (payment) -> String in
            return String(format: "%@ ***%@", payment.brand!, payment.number!)
        }
        places_names.append("Nuevo medio de pago")
        dropDown.dataSource = places_names
        dropDown.selectionAction = {(index: Int, item: String) in
            self.currentPayment.text = item
            self.selected_index = index
            self.loadPaymentData()
        }
        if !payments.isEmpty {
            let payment = payments[0]
            self.currentPayment.text = String(format: "%@ ***%@", payment.brand!, payment.number!)
            loadPaymentData()
        }
    }
    
    public func tooglePicker() {
        dropDown.show()
    }
    
    public func loadPaymentData() {
        if loaded_card_view != nil {
            loaded_card_view!.willMove(toParentViewController: nil)
            loaded_card_view!.view.removeFromSuperview()
            loaded_card_view!.removeFromParentViewController()
        }
        if self.selected_index < self.payments.count {
            loaded_card_view = PaymentsCardViewController.showCardView(parent: self, frame: self.cardView.frame, card: self.payments[self.selected_index], selecting: true)
            self.saveB.alpha = 0
            self.saveLabel.alpha = 0
        } else {
            loaded_card_view = PaymentsCardViewController.showCardView(parent: self, frame: self.cardView.frame)
            self.saveB.alpha = 1
            self.saveLabel.alpha = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func toogleSavingPayment(_ sender: Any) {
        save_payment = !save_payment
        if save_payment {
            self.saveLabel.text = "Si"
            self.saveLabel.textColor = K.UI.main_color
        } else {
            self.saveLabel.text = "No"
            self.saveLabel.textColor = K.UI.alert_color
        }
    }
    
    @IBAction func payBooking(_ sender: Any) {
        if self.selected_index < payments.count {
            // Is old
            print("Attempt pay with \(payments[self.selected_index].number)")
        } else {
            // Is new
            loaded_card_view?.tokenizeCreditCard(callback: { (card) in
                if self.save_payment {
                    // Save
                    K.User.client!.savePayment(payment: card)
                    card.save()
                    self.back(self)
                }
                // Attempt pay
                print("Attempt pay with \(card.number)")
                self.service!.save()
                K.MaterialTapBar.TapBar?.reloadViewController()
            })
        }
    }

}
