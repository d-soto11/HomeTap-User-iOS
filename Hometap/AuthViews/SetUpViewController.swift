//
//  SetUpViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/22/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class SetUpViewController: UIViewController {

    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var birthField: UITextField!
    @IBOutlet weak var genreField: UITextField!
    @IBOutlet weak var doneB: UIButton!
    
    var displaceKeyboard = false
    var originalFR: CGRect = CGRect.zero
    var keyboards_list: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboards_list = [nameField, mailField, phoneField, birthField, genreField]
        setUpSmartKeyboard()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        profileContainer.roundCorners(radius: profileContainer.bounds.size.width/2)
        doneB.addNormalShadow()
        doneB.roundCorners(radius: K.UI.round_px)
        
        self.originalFR = self.view.bounds
    }
    
    @IBAction func done(_ sender: Any) {
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
//        clearKeyboards(index: textField.tag)
        switch textField.tag {
        case 1:
            self.displaceKeyboard = false
            return true
        case 2:
            self.displaceKeyboard = true
            return true
        case 3:
            self.displaceKeyboard = true
            return true
        case 4:
            self.displaceKeyboard = true
            return true
        case 5:
            self.displaceKeyboard = true
            return true
        default:
            return true
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 5:
            textField.resignFirstResponder()
            return true
        default:
            textField.resignFirstResponder()
            self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
            return true
        }
    }
}
