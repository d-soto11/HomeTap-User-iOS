//
//  ProfileChangeViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 9/6/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProfileChangeViewController: UIViewController {
    @IBOutlet weak var editTitle: UILabel!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var fieldText: UITextField!
    
    enum ProfileChangeValidator {
        case email
        case name
        case phone
        case noValidation
    }
    
    private var tag: Int!
    private var fieldName: String!
    private var delegate: ProfileChangeDelegate!
    private var fieldInitialValue: String!
    private var profileValidator: ProfileChangeValidator?
    
    public class func showFieldEditor<T: UIViewController>(value: String, name: String, delegate: T, val: ProfileChangeValidator = .noValidation, tag: Int) where T:ProfileChangeDelegate {
        let st = UIStoryboard.init(name: "Main", bundle: nil)
        let editor = st.instantiateViewController(withIdentifier: "ProfileChange") as! ProfileChangeViewController
        editor.tag = tag
        editor.fieldName = name
        editor.delegate = delegate
        editor.fieldInitialValue = value
        editor.profileValidator = val
        delegate.show(editor, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fieldLabel.text = self.fieldName
        self.fieldText.text = self.fieldInitialValue
        
        self.editTitle.text = "Cambia tu \(self.fieldName.lowercased())"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fieldText.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        self.saveB.addNormalShadow()
        self.saveB.roundCorners(radius: K.UI.round_px)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        if self.fieldText.text != self.fieldInitialValue {
            switch self.profileValidator! {
            case .noValidation:
                break
            case .name:
                guard self.fieldText.text != "" else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    showAlert(title: "Espera!", message: "Debes ingresar tu nombre", closeButtonTitle: "Entendido")
                    return
                }
                
                guard (self.fieldText.text!.characters.count) <= 50 else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    showAlert(title: "Espera!", message: "El nombre que has ingresado es muy largo.", closeButtonTitle: "Entendido")
                    return
                    
                }
            case .email:
                guard self.fieldText.text != "" && self.fieldText.text!.contains("@") && self.fieldText.text!.contains(".") && !self.fieldText.text!.contains("+") && self.fieldText.text!.characters.count <= 100 else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    showAlert(title: "Espera!", message: "Debes ingresar un correo válido", closeButtonTitle: "Entendido")
                    return
                }
            case .phone:
                guard (self.fieldText.text?.characters.count)! == 10 else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    showAlert(title: "Espera!", message: "El número celular que has ingresado no es válido", closeButtonTitle: "Entendido")
                    return
                }
            }
            self.delegate.fieldUpdated(value: self.fieldText.text!, tag: self.tag)
            self.back(self)
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.back(self)
        }
        
    }
}

public protocol ProfileChangeDelegate : NSObjectProtocol {
    
    @available(iOS 7.0, *)
    func fieldUpdated(value: String, tag: Int)
    
}
