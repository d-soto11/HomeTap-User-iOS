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

class SetUpViewController: UIViewController, ImagePickerDelegate, DatePickerDelegate {

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
        config.bottomContainerColor = K.UI.main_color
        config.mainColor = .white
        
        
        let imagePicker = ImagePickerController()
        imagePicker.configuration = config
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
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
        switch tag {
        case 4:
            self.birthField.text = string
            break
        default:
            break
        }
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
            let date_picker = DatePickerViewController.init(nibName: "DatePickerViewController", bundle: nil)
            date_picker.loadWith(label: "¿Qué día naciste?", date: self.birthField.text, format: "dd-MM-yyyy", type: UIDatePickerMode.date, minDate: .none, maxDate: .now, delegate: self, jm_delegate: self, tag: 4)
            let config = JModalConfig(transitionDirection: .bottom, animationDuration: 0.2, backgroundTransform: false, tapOverlayDismiss: true)
            presentModal(self, modalViewController: date_picker, config: config) {
            }
            return false
        case 5:
            // Gender Picker
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
