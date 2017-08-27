//
//  EditPaymentViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/27/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class EditPaymentViewController: UIViewController {

    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var deleteB: UIButton!
    @IBOutlet weak var cardView: UIView!
    
    var loadedCardView: PaymentsCardViewController? = nil
    public var card: PaymentCard!
    
    public class func edit(parent: UIViewController, card: PaymentCard) {
        let st = UIStoryboard.init(name: "Payments", bundle: nil)
        let edit = st.instantiateViewController(withIdentifier: "Edit") as! EditPaymentViewController
        edit.card = card
        parent.show(edit, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        self.saveB.addNormalShadow()
        self.saveB.roundCorners(radius: K.UI.round_px)
        self.deleteB.addNormalShadow()
        self.deleteB.roundCorners(radius: K.UI.round_px)
        if (loadedCardView == nil) {
            loadedCardView = PaymentsCardViewController.showCardView(parent: self, frame: self.cardView.frame, card: self.card!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePayment(_ sender: Any) {
        loadedCardView?.saveDetails()?.save()
        self.back(self)
    }
    
    @IBAction func deletePayment(_ sender: Any) {
        K.User.client?.removePayment(payment: self.card)
        self.back(self)
    }

}
