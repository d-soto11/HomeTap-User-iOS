//
//  RegisterViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/22/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase
import Navajo_Swift

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
        let mb = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        guard nameField.text != "" else {
            MBProgressHUD.hide(for: self.view, animated: true)
            showAlert(title: "Espera!", message: "Debes ingresar tu nombre", closeButtonTitle: "Entendido")
            return
        }
        
        guard (nameField.text!.characters.count) <= 50 else {
            MBProgressHUD.hide(for: self.view, animated: true)
            showAlert(title: "Espera!", message: "El nombre que has ingresado es muy largo.", closeButtonTitle: "Entendido")
            return
            
        }
        
        guard mailField.text != "" && mailField.text!.contains("@") && mailField.text!.contains(".") && !mailField.text!.contains("+") && mailField.text!.characters.count <= 100 else {
            MBProgressHUD.hide(for: self.view, animated: true)
            showAlert(title: "Espera!", message: "Debes ingresar un correo válido", closeButtonTitle: "Entendido")
            return
        }
        
        guard passwordField.text != "" else {
            MBProgressHUD.hide(for: self.view, animated: true)
            showAlert(title: "Espera!", message: "Debes ingresar tu nombre", closeButtonTitle: "Entendido")
            return
        }
        
        let strength = Navajo.strength(of: passwordField.text!)
        switch strength {
        case .weak, .veryWeak:
            MBProgressHUD.hide(for: self.view, animated: true)
            showAlert(title: "Espera!", message: "La contraseña que has escogido es muy débil. Trata de usar mayúsculas y minúsulas, o signos especiales (!?#.)", closeButtonTitle: "Entendido")
            return
        default:
            break
        }
        
        guard confirmPasswordField.text == passwordField.text else {
            MBProgressHUD.hide(for: self.view, animated: true)
            showAlert(title: "Espera!", message: "Debes ingresar tu nombre", closeButtonTitle: "Entendido")
            return
        }
        
        mb.label.text = "Verificando tus datos"
        Auth.auth().createUser(withEmail: self.mailField.text!, password: self.passwordField.text!) { (user, error) in
            if error != nil {
                mb.hide(animated: true)
                self.showAlert(title: "Lo sentimos", message: "No hemos podido crear tu usuario. Es posible que ya tengas una cuenta en HomeTap, intenta iniciar sesión.", closeButtonTitle: "Entendido")
            } else {
                if user != nil {
                    mb.label.text = "Cargando información"
                    let req = user!.createProfileChangeRequest()
                    req.displayName = self.nameField.text!
                    req.commitChanges(completion: nil)
                    K.User.client = Client(user: Auth.auth().currentUser!)
                    K.User.client!.name = self.nameField.text
                    self.performSegue(withIdentifier: "Setup", sender: nil)
                    
                }
            }
            
        }
        mb.hide(animated: true)

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
