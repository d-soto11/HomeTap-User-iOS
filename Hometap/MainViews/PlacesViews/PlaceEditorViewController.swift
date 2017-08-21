//
//  PlaceEditorViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/21/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD
import GooglePlacePicker

class PlaceEditorViewController: UIViewController, UITextFieldDelegate, GMSPlacePickerViewControllerDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var houseB: UIButton!
    @IBOutlet weak var apartamentB: UIButton!
    @IBOutlet weak var interiorText: UITextField!
    @IBOutlet weak var metersText: UITextField!
    @IBOutlet weak var floorsText: UITextField!
    @IBOutlet weak var roomsText: UITextField!
    @IBOutlet weak var bathroomsText: UITextField!
    @IBOutlet weak var petsLabel: UILabel!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var deleteB: UIButton!
    
    private var place: Place!
    
    var displaceKeyboard = false
    var originalFR: CGRect = CGRect.zero
    var keyboards_list: [UITextField] = []
    
    public class func showEditor(place: Place, parent: UIViewController) {
        let st = UIStoryboard.init(name: "Places", bundle: nil)
        let picker = st.instantiateViewController(withIdentifier: "Editor") as! PlaceEditorViewController
        picker.place = place
        parent.show(picker, sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboards_list = [nameText, addressText, interiorText, metersText, floorsText, roomsText, bathroomsText]
        setUpSmartKeyboard()
        self.deleteB.alpha = self.place.uid != nil ? 1 : 0
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.loadPlaceData()
    }
    public func loadPlaceData() {
        self.nameText.text = place.name
        self.addressText.text = place.address
        self.interiorText.text = place.interior
        self.metersText.text = place.area != nil ? String(format: "%.0f m2", place.area!) : ""
        self.floorsText.text = place.floors != nil ? String(format: "%d", place.floors!) : ""
        self.roomsText.text = place.rooms != nil ? String(format: "%d", place.rooms!) : ""
        self.bathroomsText.text = place.bathrooms != nil ? String(format: "%d", place.bathrooms!) : ""
        
        if place.apartament! {
            UIView.animate(withDuration: 0.5, animations: {
                self.floorsText.superview?.alpha = 0
                self.apartamentB.setTitleColor(.white, for: .normal)
                self.apartamentB.backgroundColor = K.UI.main_color
                self.houseB.setTitleColor(K.UI.form_color, for: .normal)
                self.houseB.backgroundColor = .white
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.floorsText.superview?.alpha = 1
                self.houseB.setTitleColor(.white, for: .normal)
                self.houseB.backgroundColor = K.UI.main_color
                self.apartamentB.setTitleColor(K.UI.form_color, for: .normal)
                self.apartamentB.backgroundColor = .white
            })
        }
        
        if place.pets! {
            UIView.animate(withDuration: 0.5, animations: {
                self.petsLabel.text = "Si"
                self.petsLabel.textColor = K.UI.main_color
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.petsLabel.text = "No"
                self.petsLabel.textColor = K.UI.alert_color
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.apartamentB.roundCorners(radius: K.UI.light_round_px)
        self.apartamentB.addNormalShadow()
        self.houseB.roundCorners(radius: K.UI.light_round_px)
        self.houseB.addNormalShadow()
        self.saveB.roundCorners(radius: K.UI.round_px)
        self.saveB.addNormalShadow()
        
        self.originalFR = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func selectHouse(_ sender: Any) {
        place.apartament = false
        loadPlaceData()
    }
    
    @IBAction func selectApartament(_ sender: Any) {
        place.apartament = true
        loadPlaceData()
    }
    
    @IBAction func tooglePets(_ sender: Any) {
        place.pets = !place.pets!
        loadPlaceData()
    }
    @IBAction func done(_ sender: Any) {
        let mb = MBProgressHUD.showAdded(to: self.view, animated: true)
        mb.label.text = "Guardando"
        guard place.name != nil else {
            mb.hide(animated: true)
            self.showAlert(title: "¡Espera!", message: "Debes darle un nombre a este lugar.", closeButtonTitle: "Ok")
            return
        }
        guard place.address != nil else {
            mb.hide(animated: true)
            self.showAlert(title: "¡Espera!", message: "Debes ingresar la dirección de este lugar", closeButtonTitle: "Ok")
            return
        }
        guard place.interior != nil else {
            mb.hide(animated: true)
            self.showAlert(title: "¡Espera!", message: "Debes ingresar el número de casa/apartamento", closeButtonTitle: "Ok")
            return
        }
        guard place.area != nil else {
            mb.hide(animated: true)
            self.showAlert(title: "¡Espera!", message: "Debes ingresar el área de este lugar", closeButtonTitle: "Ok")
            return
        }
        if !place.apartament! {
            guard place.floors != nil else {
                mb.hide(animated: true)
                self.showAlert(title: "¡Espera!", message: "Debes ingresar el número de pisos de esta casa", closeButtonTitle: "Ok")
                return
            }
        }
        guard place.rooms != nil else {
            mb.hide(animated: true)
            self.showAlert(title: "¡Espera!", message: "Debes ingresar el número de habitaciones de este lugar", closeButtonTitle: "Ok")
            return
        }
        guard place.bathrooms != nil else {
            mb.hide(animated: true)
            self.showAlert(title: "¡Espera!", message: "Debes ingresar el número de baños de este lugar", closeButtonTitle: "Ok")
            return
        }
        
        place.save()
        K.User.client?.savePlace(place: place)
        self.back(self)
    }
    
    @IBAction func deletePlace(_ sender: Any) {
        K.User.client?.removePlace(place: self.place)
        self.back(self)
    }

    // Place picker
    func pickPlace() {
        var config = GMSPlacePickerConfig(viewport: nil)
        if self.place.address != nil {
            let center = CLLocationCoordinate2D(latitude: self.place.lat!, longitude: self.place.lng!)
            let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
            let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
            let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            config = GMSPlacePickerConfig(viewport: viewport)
        }
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        self.addressText.text = place.formattedAddress
        self.place.address = place.formattedAddress
        self.place.lat = place.coordinate.latitude
        self.place.lng = place.coordinate.longitude
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
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
        case 21:
            self.displaceKeyboard = false
            return true
        case 22:
            // Address picker
            self.clearKeyboards()
            self.displaceKeyboard = false
            self.pickPlace()
            return false
        case 23:
            self.displaceKeyboard = true
            return true
        case 24:
            textField.text = String(format: "%.0f", place.area ?? 0)
            self.displaceKeyboard = true
            return true
        case 25:
            self.displaceKeyboard = true
            return true
        case 26:
            self.displaceKeyboard = true
            return true
        case 27:
            self.displaceKeyboard = true
            return true
        default:
            return true
        }
    }
    
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 27:
            textField.resignFirstResponder()
            return true
        default:
            textField.resignFirstResponder()
            self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        case 21:
            return ((textField.text?.characters.count) ?? 0 < 20)
        case 22:
            return true
        case 23:
            return ((textField.text?.characters.count) ?? 0 < 9)
        case 24:
            return ((textField.text?.characters.count) ?? 0 < 5)
        case 25:
            return ((textField.text?.characters.count) ?? 0 < 2)
        case 26:
            return ((textField.text?.characters.count) ?? 0 < 3)
        case 27:
            return ((textField.text?.characters.count) ?? 0 < 3)
        default:
            return false
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 21:
            self.place.name = textField.text
        case 23:
            self.place.interior = textField.text
        case 24:
            if textField.text != "", let area = Double(textField.text!) {
                self.place.area = area
            } else {
                self.showAlert(title: "Espera", message: "El área que has ingresado no es válida", closeButtonTitle: "Ok")
                return false
            }
        case 25:
            if textField.text != "", let floors = Int(textField.text!) {
                self.place.floors = floors
            } else {
                self.showAlert(title: "Espera", message: "El número de pisos que has ingresado no es válido", closeButtonTitle: "Ok")
                return false
            }
        case 26:
            if textField.text != "", let rooms = Int(textField.text!) {
                self.place.rooms = rooms
            } else {
                self.showAlert(title: "Espera", message: "El número de habitaciones que has ingresado no es válido", closeButtonTitle: "Ok")
                return false
            }
        case 27:
            if textField.text != "", let baths = Int(textField.text!) {
                self.place.bathrooms = baths
            } else {
                self.showAlert(title: "Espera", message: "El número de baños que has ingresado no es válido", closeButtonTitle: "Ok")
                return false
            }
        default:
            return true
        }
        
        self.loadPlaceData()
        return true
    }

}
