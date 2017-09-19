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

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var nextB: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboards = [nameField, mailField, passwordField, confirmPasswordField]
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
        
        self.originalFrame = self.view.bounds
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
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            self.needsDisplacement = CGFloat(0)
            return true
        case 2:
            self.needsDisplacement = CGFloat(0)
            return true
        case 3:
            self.needsDisplacement = CGFloat(0)
            return true
        case 4:
            self.needsDisplacement = CGFloat(0)
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
