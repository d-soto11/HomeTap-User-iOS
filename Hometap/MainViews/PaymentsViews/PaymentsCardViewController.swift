//
//  PaymentsCardViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/27/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class PaymentsCardViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardBrand: UIImageView!
    @IBOutlet weak var cardExpiration: UILabel!
    @IBOutlet weak var cardCVC: UILabel!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var numberText: UITextField!
    @IBOutlet weak var expirationText: UITextField!
    @IBOutlet weak var cvcText: UITextField!
    
    var displaceKeyboard = false
    var originalFR: CGRect = CGRect.zero
    var keyboards_list: [UITextField] = []
    
    public class func showCardView(parent: UIViewController, frame: CGRect) -> PaymentsCardViewController {
        let st = UIStoryboard.init(name: "Payments", bundle: nil)
        let cardView = st.instantiateViewController(withIdentifier: "CardView") as! PaymentsCardViewController
        
        parent.view.insertSubview(cardView.view, aboveSubview: parent.view)
        cardView.view.frame = frame
        cardView.originalFR = frame
        parent.addChildViewController(cardView)
        cardView.didMove(toParentViewController: parent)
        
        return cardView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        keyboards_list = [nameText, numberText, expirationText, cvcText]
        setUpSmartKeyboard()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
//        self.originalFR = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // UI Helpers
    override func needsDisplacement() -> CGFloat {
        return self.displaceKeyboard ? CGFloat(1) : CGFloat(0)
    }
    
    override func originalFrame() -> CGRect {
        return self.originalFR
    }
    
    override func keyboards() -> [UITextField] {
        return self.keyboards_list
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 21:
            self.displaceKeyboard = false
            return true
        case 22:
            self.displaceKeyboard = false
            return true
        case 23:
            self.displaceKeyboard = true
            return true
        case 24:
            self.displaceKeyboard = true
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
        switch textField.tag {
        case 21:
            return ((textField.text?.characters.count) ?? 0 < 40)
        case 22:
            return ((textField.text?.characters.count) ?? 0 < 16)
        case 23:
            if ((textField.text?.characters.count) ?? 0 == 2) {
               textField.text = String(format: "%@/%@", textField.text!, string)
                return false
            } else {
                return ((textField.text?.characters.count) ?? 0 < 5)
            }
        case 24:
            return ((textField.text?.characters.count) ?? 0 < 4)
        default:
            return false
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 21:
            break
        case 22:
            break
        case 23:
            break
        case 24:
            break
        default:
            return true
        }
        return true
    }


}
