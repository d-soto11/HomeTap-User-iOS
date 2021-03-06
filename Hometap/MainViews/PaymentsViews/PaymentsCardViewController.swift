//
//  PaymentsCardViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/27/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import Stripe
import RestEssentials
import Firebase

class PaymentsCardViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cardBG: UIImageView!
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardBrand: UIImageView!
    @IBOutlet weak var cardExpiration: UILabel!
    @IBOutlet weak var cardCVC: UILabel!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var numberText: UITextField!
    @IBOutlet weak var expirationText: UITextField!
    @IBOutlet weak var cvcText: UITextField!
    
    @IBOutlet weak var nameEditView: UIView!
    @IBOutlet weak var numberEditView: UIView!
    @IBOutlet weak var detailsEditView: UIView!
    
    
    var stripeCard: STPCardParams = STPCardParams()
    var dateExpString = ""
    
    var loaded_card: PaymentCard?
    var selecting: Bool!
    
    public class func showCardView(parent: UIViewController, frame: CGRect, card: PaymentCard? = nil, selecting: Bool = false) -> PaymentsCardViewController {
        let st = UIStoryboard.init(name: "Payments", bundle: nil)
        let cardView = st.instantiateViewController(withIdentifier: "CardView") as! PaymentsCardViewController
        
        parent.view.insertSubview(cardView.view, aboveSubview: parent.view)
        cardView.view.frame = frame
        cardView.originalFrame = frame
        cardView.loaded_card = card
        cardView.selecting = selecting
        parent.addChildViewController(cardView)
//        cardView.parent = parent
        cardView.didMove(toParentViewController: parent)
        
        parent.view.addGestureRecognizer(UITapGestureRecognizer(target: cardView, action: #selector(clearKeyboards)))
        
        return cardView
    }
    
    func tokenizeCreditCard(callback: @escaping (PaymentCard?) -> ()) {
        
        guard self.stripeCard.name != nil else {
            callback(nil)
            return
        }
        guard self.stripeCard.number != nil else {
            callback(nil)
            return
        }
        guard self.stripeCard.cvc != nil else {
            callback(nil)
            return
        }
        guard let url = RestController.make(urlString: "https://us-central1-hometap-f173f.cloudfunctions.net") else {
            callback(nil)
            return
        }
        
        Auth.auth().currentUser?.getIDToken(completion: { (id, error) in
            if id != nil {
                var options = RestOptions()
                let authToken = String(format: "Bearer %@", id!)
                options.httpHeaders = ["Authorization": authToken]
                
                let dateString = String(format: "20%02d/%02d", self.stripeCard.expYear, self.stripeCard.expMonth)
                var brandString = "CODENSA"
                switch STPCardValidator.brand(forNumber: self.stripeCard.number!) {
                case .amex:
                    brandString = "AMEX"
                case .dinersClub:
                    brandString = "DINERS"
                case .visa:
                    brandString = "VISA"
                case .masterCard:
                    brandString = "MASTERCARD"
                default:
                    break
                }
                
                let query: JSON = ["name": self.stripeCard.name!,
                                   "number":self.stripeCard.number!,
                                   "date": dateString,
                                   "cvc": self.stripeCard.cvc!,
                                   "brand": brandString]
                
                url.post(query, at: "tokenize", options: options) { (result, httpResponse) in
                    if httpResponse?.statusCode == 200 {
                        // Payment succesfull
                        do {
                            let json = try result.value()
                            DispatchQueue.main.async {
                                self.loaded_card = PaymentCard(dict: [:])
                                self.loaded_card!.uid = json["token"].string!
                                self.loaded_card!.name = json["name"].string!
                                self.loaded_card!.brand = json["brand"].string!
                                self.loaded_card!.expiration = self.cardExpiration.text
                                self.loaded_card!.number = json["last4"].string!
                                self.loaded_card!.cvc = self.cardCVC.text
                                callback(self.loaded_card!)
                            }
                        } catch {
                            DispatchQueue.main.async {
                                callback(nil)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                           callback(nil)
                        }
                    }
                }
                
            } else {
                callback(nil)
                return
            }
        })
        
//        STPAPIClient.shared().createToken(withCard: self.stripeCard) { (token, error) in
//            guard let token = token, error == nil else {
//                callback(nil)
//                return
//            }
//            guard let stcard = token.card else {
//                callback(nil)
//                return
//            }
//            self.loaded_card = PaymentCard(dict: [:])
//            self.loaded_card!.uid = token.stripeID
//            self.loaded_card!.name = stcard.name
//            switch stcard.brand {
//            case .amex:
//                self.loaded_card!.brand = "Amex"
//            case .dinersClub:
//                self.loaded_card!.brand = "Diners Club"
//            case .discover:
//                self.loaded_card!.brand = "Discover"
//            case .JCB:
//                self.loaded_card!.brand = "JCB"
//            case .masterCard:
//                self.loaded_card!.brand = "Master Card"
//            case .visa:
//                self.loaded_card!.brand = "Visa"
//            case .unknown:
//                self.loaded_card!.brand = "Otra"
//            }
//            self.loaded_card!.expiration = self.cardExpiration.text
//            self.loaded_card!.number = stcard.last4
//            self.loaded_card!.cvc = self.cardCVC.text
//            callback(self.loaded_card!)
//        }
    }
    
    func saveDetails() -> PaymentCard? {
        self.loaded_card?.expiration = self.cardExpiration.text
        self.loaded_card?.cvc = self.cardCVC.text
        return self.loaded_card
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.keyboards = [nameText, numberText, expirationText, cvcText]
        self.setUpSmartKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let card = self.loaded_card {
            self.nameEditView.isHidden = true
            self.numberEditView.isHidden = true
            self.detailsEditView.isHidden = true
            
            self.cardNumber.text = String(format: "**** **** **** %@", card.number!)
            self.cardExpiration.text = card.expiration
            self.cardCVC.text = card.cvc
            
            switch card.brand! {
            case "AMEX":
                self.cardBrand.image = STPImageLibrary.amexCardImage()
            case "DINERS":
                self.cardBrand.image = STPImageLibrary.dinersClubCardImage()
            case "MASTERCARD":
                self.cardBrand.image = STPImageLibrary.masterCardCardImage()
            case "VISA":
                self.cardBrand.image = STPImageLibrary.visaCardImage()
            default:
                self.cardBrand.image = STPImageLibrary.unknownCardCardImage()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        cardBG.addLightShadow()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func keyboardWillDisplay(notification:NSNotification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = CGRect(x: 0.0, y: 0, width: (self.originalFrame.size.width), height: (self.originalFrame.size.height))
        })
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 21:
            self.needsDisplacement = CGFloat(0)
            return true
        case 22:
            self.needsDisplacement = CGFloat(0)
            return true
        case 23:
            self.needsDisplacement = CGFloat(1)
            return true
        case 24:
            self.needsDisplacement = CGFloat(1)
            return true
        default:
            return true
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 24:
            textField.resignFirstResponder()
            return true
        default:
            textField.resignFirstResponder()
            self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            let resultString = text.replacingCharacters(in: range, with: string)
            if text.length > resultString.characters.count {
                return true
            }
        }

        switch textField.tag {
        case 21:
            return ((textField.text?.characters.count) ?? 0 < 40)
        case 22:
            if ((textField.text?.characters.count) ?? 0 < 16) {
                if let text = textField.text as NSString? {
                    let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
                    self.cardNumber.text = txtAfterUpdate.inserting(separator: " ", every: 4)
                    stripeCard.number = txtAfterUpdate
                    let cardBrand = STPCardValidator.brand(forNumber: stripeCard.number!)
                    self.cardBrand.image = STPImageLibrary.brandImage(for: cardBrand)
                }
                return true
            } else if ((textField.text?.characters.count) ?? 0 == 16) {
                self.expirationText.becomeFirstResponder()
                return false
            }
        case 23:
            if ((textField.text?.characters.count) ?? 0 < 5) {
                if let text = textField.text as NSString? {
                    let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
                    self.cardExpiration.text = txtAfterUpdate.replacingOccurrences(of: "/", with: "").inserting(separator: "/", every: 2)
                   textField.text = self.cardExpiration.text
                }
                return false
            } else if ((textField.text?.characters.count) ?? 0 == 5) {
                self.cvcText.becomeFirstResponder()
                return true
            }
        case 24:
            if ((textField.text?.characters.count) ?? 0 < 4) {
                if let text = textField.text as NSString? {
                    let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
                    self.cardCVC.text = ""
                    for _ in txtAfterUpdate.characters {
                        self.cardCVC.text = String(format: "%@%@", self.cardCVC.text!, "*")
                    }
                    stripeCard.cvc = txtAfterUpdate
                }
                return true
            } else {
                textField.resignFirstResponder()
            }
        default:
            return false
        }
        
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 21:
            stripeCard.name = textField.text!
        case 22:
            stripeCard.number = textField.text!
        case 23:
            if textField.text?.isEmpty == false {
                let expirationDate = textField.text!.components(separatedBy: "/")
                let expMonth = UInt(Int(expirationDate[0])!)
                let expYear = UInt(Int(expirationDate[1])!)
                // Send the card info to Strip to get the token
                stripeCard.expMonth = expMonth
                stripeCard.expYear = expYear
            }
        case 24:
            stripeCard.cvc = textField.text
        default:
            return true
        }
        return true
    }
    
    
}
