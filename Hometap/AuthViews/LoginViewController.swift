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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        keyboars_list = [username, password]
        setUpSmartKeyboard()
        // Do any additional setup after loading the view.
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
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if (error != nil){
                self.showAlert(title: "Lo sentimos", message: String(format:"Ha ocurrido un error inesperado: %@", error!.localizedDescription), closeButtonTitle: "Ok")
            }
            else{
                self.dismiss(animated: true, completion: nil)
            }
        }
        
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
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if (error != nil){
                self.showAlert(title: "Lo sentimos", message: String(format:"Ha ocurrido un error inesperado: %@", error!.localizedDescription), closeButtonTitle: "Ok")
            }
            else{
                self.dismiss(animated: true, completion: nil)
            }
        }
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
            // Date Picker
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
