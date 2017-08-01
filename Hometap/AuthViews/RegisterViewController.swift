//
//  RegisterViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/22/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var nextB: UIButton!
    
    var displaceKeyboard = false
    var originalFR: CGRect = CGRect.zero
    var keyboards_array: [UITextField] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboards_array = [nameField, mailField, passwordField, confirmPasswordField]
        setUpSmartKeyboard()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nextB.addNormalShadow()
        nextB.roundCorners(radius: K.UI.round_px)
        
        self.originalFR = self.view.bounds
    }
    
    @IBAction func nextStep(_ sender: Any) {
    }
    
    // UI Helpers
    
    override func needsDisplacement() -> CGFloat {
        return self.displaceKeyboard ? CGFloat(1) : CGFloat(0)
    }
    
    override func originalFrame() -> CGRect {
        return self.originalFR
    }
    
    override func keyboards() -> [UITextField] {
        return keyboards_array
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        clearKeyboards(index: textField.tag)
        switch textField.tag {
        case 1:
            self.displaceKeyboard = false
            return true
        case 2:
            self.displaceKeyboard = false
            return true
        case 3:
            self.displaceKeyboard = false
            return true
        case 4:
            self.displaceKeyboard = false
            return true
        default:
            return true
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 4:
            textField.resignFirstResponder()
            return true
        default:
            textField.resignFirstResponder()
            self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
            return true
        }
    }

}
