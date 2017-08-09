//
//  LoginViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/18/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import Firebase
import MBProgressHUD

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate, UITextFieldDelegate {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signInB: UIButton!
    @IBOutlet weak var google: UIButton!
    @IBOutlet weak var fb: UIButton!
    
    var displaceKeyboard = false
    var originalFR: CGRect = CGRect.zero
    var keyboars_list: [UITextField] = []
    
    var authCallback: AuthResultCallback?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        keyboars_list = [username, password]
        setUpSmartKeyboard()
        // Do any additional setup after loading the view.
        
        authCallback = { (user, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if (error != nil){
                self.showAlert(title: "Lo sentimos", message: "Ha ocurrido un error inesperado. Intenta de nuevo.", closeButtonTitle: "Ok")
            }
            else if user != nil{
                Client.withID(id: user!.uid, callback: { (client) in
                    if client == nil {
                        K.User.client = Client(user: user!)
                        self.performSegue(withIdentifier: "Setup", sender: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            } else {
                self.showAlert(title: "Lo sentimos", message:"Ha ocurrido un error inesperado.", closeButtonTitle: "Ok")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fb.addNormalShadow()
        google.addNormalShadow()
        signInB.addNormalShadow()
        signInB.roundCorners(radius: K.UI.round_px)
        
        self.originalFR = self.view.bounds
    }
    
    @IBAction func loginWithHT(_ sender: Any) {
        let mb = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        guard username.text != "" else {
            MBProgressHUD.hide(for: self.view, animated: true)
            showAlert(title: "Espera!", message: "Debes ingresar tu usuario (correo)", closeButtonTitle: "Entendido")
            return
        }
        
        guard password.text != "" else {
            MBProgressHUD.hide(for: self.view, animated: true)
            showAlert(title: "Espera!", message: "Debes ingresar tu contraseña", closeButtonTitle: "Entendido")
            return
        }
        
        mb.label.text = "Iniciando sesión"
        
        Auth.auth().signIn(withEmail: username.text!, password: password.text!) { (user, error) in
            mb.hide(animated: true)
            if error != nil {
                self.showAlert(title: "Lo sentimos", message: "El usuario/contraseña ingresado no es correcto.", closeButtonTitle: "Entendido")
            } else if user == nil {
                self.showAlert(title: "Lo sentimos", message: "Ha ocurrido un error inesperado. Intenta iniciar sesión de nuevo.", closeButtonTitle: "Entendido")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func register(_ sender: Any) {
    }
    
    @IBAction func loginWithFB(_ sender: Any) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.sendActions(for: .touchUpInside)
    }
    
    //Handler
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showAlert(title: "Lo sentimos", message: String(format: "Ha ocurrido un error inesperado: %@", error.localizedDescription), closeButtonTitle: "Ok")
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential, completion: self.authCallback!)
        
    }
    
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    @IBAction func loginWithGoogle(_ sender: Any) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        GIDSignIn.sharedInstance().delegate = self
        let loginButton = GIDSignInButton()
        loginButton.sendActions(for: .touchUpInside)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showAlert(title: "Lo sentimos", message: String(format: "Ha ocurrido un error desconocido: %@", error.localizedDescription), closeButtonTitle: "Ok")
            return
        }
        
        let authentication = user.authentication
        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        
        Auth.auth().signIn(with: credential, completion: self.authCallback!)
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                     withError error: Error?) {
        // Perform any operations when the user disconnects from app here.
        // ...
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    // UI Helpers
    
    override func needsDisplacement() -> CGFloat {
        return self.displaceKeyboard ? CGFloat(1) : CGFloat(0)
     }
    
    override func originalFrame() -> CGRect {
        return self.originalFR
    }
    
    override func keyboards() -> [UITextField] {
        return self.keyboars_list
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
        default:
            return true
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 2:
            textField.resignFirstResponder()
            return true
        default:
            textField.resignFirstResponder()
            self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
            return true
        }
    }

}
