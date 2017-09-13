//
//  ProfileViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/17/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import ImagePicker
import Lightbox
import Firebase
import MBProgressHUD

class ProfileViewController: UIViewController, ImagePickerDelegate, ProfileChangeDelegate {
    
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var pictureB: UIButton!
    @IBOutlet weak var nameB: UIButton!
    @IBOutlet weak var phoneB: UIButton!
    @IBOutlet weak var mailB: UIButton!
    @IBOutlet weak var paymentB: UIButton!
    @IBOutlet weak var creditsB: UIButton!
    @IBOutlet weak var logoutB: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.pictureB.addTarget(self, action: #selector(editProfilePicture), for: .touchUpInside)
        self.nameB.addTarget(self, action: #selector(editInfo(sender:)), for: .touchUpInside)
        self.phoneB.addTarget(self, action: #selector(editInfo(sender:)), for: .touchUpInside)
        self.mailB.addTarget(self, action: #selector(editInfo(sender:)), for: .touchUpInside)
        
        if !K.Network.network_available {
            self.pictureB.isEnabled = false
            self.nameB.isEnabled = false
            self.phoneB.isEnabled = false
            self.mailB.isEnabled = false
            self.paymentB.isEnabled = false
            self.creditsB.isEnabled = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if K.User.client != nil && (self.nameB.title(for: .normal) == nil || self.nameB.title(for: .normal) == "") {
            self.pictureView.downloadedFrom(link: K.User.client!.photo!)
            self.nameB.setTitle(K.User.client!.name!, for: .normal)
            self.phoneB.setTitle(K.User.client!.phone!, for: .normal)
            self.mailB.setTitle(K.User.client!.email!, for: .normal)
        } else {
            self.showAlert(title: "Sin conexión", message: "No hemos podido cargar la información de tu perfil. Revisa tu conexión a Internet", closeButtonTitle: "Aceptar")
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        paymentB.addLightShadow()
        paymentB.roundCorners(radius: K.UI.light_round_px)
        creditsB.addLightShadow()
        creditsB.roundCorners(radius: K.UI.light_round_px)
        logoutB.addLightShadow()
        logoutB.roundCorners(radius: K.UI.light_round_px)
        pictureView.circleImage()
        
    }
    
    @IBAction func showPayments(_ sender: Any) {
        PaymentsListViewController.showList(parent: self)
    }
    @IBAction func showCredits(_ sender: Any) {
        CreditsViewController.showCredits(parent: self)
    }
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch _ as NSError {
            self.showAlert(title: "Lo sentimos", message: "No hemos podido cerrar tu sesión. Intenta de nuevo.", closeButtonTitle: "Ok")
        }
    }
    
    func editProfilePicture() {
        var config = Configuration()
        config.settingsFont = UIFont(name: "Rubik", size: 15)!
        config.noCameraFont = UIFont(name: "Rubik", size: 25)!
        config.noImagesFont = UIFont(name: "Rubik", size: 25)!
        config.numberLabelFont = UIFont(name: "Rubik", size: 18)!
        config.doneButton = UIFont(name: "Rubik", size: 25)!
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
    
    func editInfo(sender: UIButton) {
        switch sender.tag {
        case 1:
            // Name
            ProfileChangeViewController.showFieldEditor(value: K.User.client?.name ?? "", name: "Nombre", delegate: self, val: .name, tag: sender.tag)
        case 2:
            // Phone
            ProfileChangeViewController.showFieldEditor(value: K.User.client?.phone ?? "", name: "Teléfono", delegate: self, val: .phone, tag: sender.tag)
        case 3:
            // Mail
            ProfileChangeViewController.showFieldEditor(value: K.User.client?.email ?? "", name: "Correo", delegate: self, val: .email, tag: sender.tag)
        default:
            break
        }
        
    }
    
    // Profile Change delegate
    func fieldUpdated(value: String, tag: Int) {
        guard let local = Auth.auth().currentUser else {
            return
        }
        switch tag {
        case 1:
        // Name
            let req = Auth.auth().currentUser!.createProfileChangeRequest()
            
            if local.displayName != value {
                req.displayName = value
            }
            req.commitChanges(completion: nil)
            
            K.User.client?.name = value
            self.nameB.setTitle(K.User.client!.name!, for: .normal)
        case 2:
        // Phone
            K.User.client?.phone = value
            self.phoneB.setTitle(K.User.client!.phone!, for: .normal)
        case 3:
        // Mail
            K.User.client?.email = value
            self.mailB.setTitle(K.User.client!.email!, for: .normal)
        default:
            break
        }
        
        K.User.client?.save()
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
        let mb = MBProgressHUD.showAdded(to: self.view, animated: true)
        let sized_images = AssetManager.resolveAssets(imagePicker.stack.assets, size: CGSize(width: 200, height: 200))
        if sized_images.count == 1 {
            
            self.pictureView.image = sized_images[0]
            
            let profile_picture_ref = K.Database.storageRef().child("clients/\(getCurrentUserUid()!)/\(Date().toString(format: .Short) ?? "pp").jpg")
            guard let pp_data = UIImageJPEGRepresentation(self.pictureView.image!, 0.8) else {
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
                    K.User.client!.photo = photo
                    
                    mb.label.text = "Finalizando"
                    
                    K.User.client!.save()
                    
                    mb.hide(animated: true)
                    
                } else {
                    mb.hide(animated: true)
                    self.showAlert(title: "Lo sentimos", message: "Ha ocurrido un error al subir tu foto a nuestra nube. Intenta de nuevo.", closeButtonTitle: "Ok")
                    return
                }
                
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
}
