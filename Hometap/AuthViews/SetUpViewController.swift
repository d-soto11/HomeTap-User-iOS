//
//  SetUpViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/22/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import ImagePicker
import Lightbox
import JModalController
import MBProgressHUD
import Firebase

class SetUpViewController: UIViewController, ImagePickerDelegate, DatePickerDelegate, OptionPickerDelegate{

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
    
    let gender_options = ["Masculino", "Femenino", "Otro"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboards_list = [nameField, mailField, phoneField, birthField, genreField]
        setUpSmartKeyboard()
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        if let client = K.User.client {
            if let url = client.photo {
                self.profileImageView.downloadedFrom(link: url)
            }
            self.nameField.text = client.name
            if let mail = client.email {
                self.mailField.text = mail
                self.mailField.isEnabled = false
            }
            self.phoneField.text = client.phone
            self.birthField.text = client.birth?.toString(format: .Short)
            self.genreField.text = gender_options[client.gender ?? 2]
        }
        
        MBProgressHUD.hide(for: self.view, animated: true)
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

    @IBAction func selectProfilePicture(_ sender: UIButton) {
        var config = Configuration()
        config.settingsFont = UIFont(name: "Rubik", size: 15)!
        config.noCameraFont = UIFont(name: "Rubik", size: 25)!
        config.noImagesFont = UIFont(name: "Rubik", size: 25)!
        config.numberLabelFont = UIFont(name: "Rubik", size: 18)!
        config.doneButton = UIFont(name: "Rubik-Medium", size: 25)!
        config.flashButton = UIFont(name: "Rubik", size: 10)!
        
        config.doneButtonTitle = "Listo"
        config.noImagesTitle = "No hemos encontrado ninguna imagen."
        config.cancelButtonTitle = "Cancelar"
        config.noCameraTitle = "No hemos podido acceder a tu cámara."
        config.settingsTitle = "Ajustes"
        config.OKButtonTitle = "Listo"
        config.requestPermissionTitle = "Necesitamos tu permiso"
        
        config.requestPermissionMessage = "Para poder cambiar tu foto de perfil necesitamos permiso para usar tu cámara o acceder a la galería de imágenes"
        
        config.recordLocation = false
        config.allowMultiplePhotoSelection = false
        
        config.mainColor = .white
        
        let imagePicker = ImagePickerController()
        imagePicker.configuration = config
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
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
        
        guard (phoneField.text?.characters.count)! == 10 else {
            MBProgressHUD.hide(for: self.view, animated: true)
            showAlert(title: "Espera!", message: "El número celular que has ingresado no es válido", closeButtonTitle: "Entendido")
            return
        }
        
        guard birthField.text != "" else {
            MBProgressHUD.hide(for: self.view, animated: true)
            showAlert(title: "Espera!", message: "Debes seleccionar tu fecha de nacimiento", closeButtonTitle: "Entendido")
            return
        }
        
        if genreField.text == "" {
            genreField.text = "Otro"
        }
        
        mb.label.text = "Guardando tu información"
        let profile_picture_ref = K.Database.storageRef().child("clients/\(getCurrentUserUid()!)/profile_picture.jpg")
        guard let pp_data = UIImageJPEGRepresentation(self.profileImageView.image!, 0.8) else {
            self.showAlert(title: "Lo sentimos", message: "Ha ocurrido un error al subir tu foto a nuestra nube. Intenta de nuevo.", closeButtonTitle: "Ok")
            return
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        mb.label.text = "Subiendo foto"
        
        let _ = profile_picture_ref.putData(pp_data, metadata: metaData) { (metadata, error) in
            guard let metadata = metadata else {
                mb.hide(animated: true)
                self.showAlert(title: "Lo sentimos", message: "Ha ocurrido un error al subir tu foto a nuestra nube. Intenta de nuevo.", closeButtonTitle: "Ok")
                return
            }
            
            let downloadURL = metadata.downloadURL()
            if let photo = downloadURL?.absoluteString {
                K.User.client = Client(dict: [:])
                K.User.client!.photo = photo
                
                mb.label.text = "Finalizando"
                
                let local = Auth.auth().currentUser!
                let req = Auth.auth().currentUser!.createProfileChangeRequest()
                if local.displayName != self.nameField.text {
                    req.displayName = self.nameField.text
                }
                req.commitChanges(completion: nil)
                
                
                K.User.client!.name = self.nameField.text
                K.User.client!.email = self.mailField.text
                K.User.client!.phone = self.phoneField.text
                K.User.client!.birth = Date(fromString: self.birthField.text!, withFormat: .Short)
                K.User.client!.joined = Date()
                K.User.client!.votes = 1
                K.User.client!.rating = 5.0
                K.User.client!.gender = self.gender_options.index(of: self.genreField.text!)
                K.User.client!.uid = local.uid
                
                K.User.client!.save()
                
                mb.hide(animated: true)
                
                K.MaterialTapBar.TapBar?.reloadViewController()
                
            } else {
                mb.hide(animated: true)
                self.showAlert(title: "Lo sentimos", message: "Ha ocurrido un error al subir tu foto a nuestra nube. Intenta de nuevo.", closeButtonTitle: "Ok")
                return
            }
            
        }
        
        K.MaterialTapBar.TapBar?.reloadViewController()
    }

    // ImagePicker Delegate
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        let lightboxImages = images.map {
            return LightboxImage(image: $0)
        }
        
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.present(lightbox, animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        let sized_images = AssetManager.resolveAssets(imagePicker.stack.assets, size: CGSize(width: 200, height: 200))
        if sized_images.count == 1 {
            self.profileImageView.image = sized_images[0]
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // DatePicker Delegate
    func datePickerDidSelectDate(date: Date, string:String, tag:Int) {
        self.birthField.text = string
    }
    
    // OptionPicker Delegate
    func optionPickerDidPickSubject(index:Int, selected:String, tag:Int) {
        self.genreField.text = selected
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
            // Date Picker
            DatePickerViewController.pickerWith(title: "¿Qué día naciste?", date: self.birthField.text,maxDate: .now, delegate: self, jm_delegate: self, onViewController: self)
            return false
        case 5:
            // Gender Picker
            if let sel = self.genreField.text {
                if let ind = gender_options.index(of: sel) {
                    OptionPicker.pickerWith(title: "Género", options: gender_options, delegate: self, onViewController: self, selected: [ind])
                } else {
                    OptionPicker.pickerWith(title: "Género", options: gender_options, delegate: self, onViewController: self)
                }
            } else {
                 OptionPicker.pickerWith(title: "Género", options: gender_options, delegate: self, onViewController: self)
            }
           
            return false
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
