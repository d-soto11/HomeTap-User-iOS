//
//  PlacePickerViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/21/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import DropDown
import MBProgressHUD
import GooglePlacePicker

class PlacePickerViewController: UIViewController, UITextFieldDelegate, GMSPlacePickerViewControllerDelegate {

    @IBOutlet weak var placePickerBox: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var houseB: UIButton!
    @IBOutlet weak var apartamentB: UIButton!
    @IBOutlet weak var towerText: UITextField!
    @IBOutlet weak var interiorText: UITextField!
    @IBOutlet weak var metersText: UITextField!
    @IBOutlet weak var floorsText: UITextField!
    @IBOutlet weak var roomsText: UITextField!
    @IBOutlet weak var bathroomsText: UITextField!
    @IBOutlet weak var petsLabel: UILabel!
    @IBOutlet weak var currentPlaceLabel: UILabel!
    
    @IBOutlet weak var nextB: UIButton!
    
    private var places: [Place]! = []
    private var service: Service!
    
    public var selected_index: Int = 0
    
    let dropDown = DropDown()
    
    var displaceKeyboard = false
    var originalFR: CGRect = CGRect.zero
    var keyboards_list: [UITextField] = []
    
    public class func showPicker(service: Service, parent: UIViewController) {
        let st = UIStoryboard.init(name: "Places", bundle: nil)
        let picker = st.instantiateViewController(withIdentifier: "Picker") as! PlacePickerViewController
        picker.service = service
        parent.show(picker, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = K.User.client?.places(callback: { (place, total) in
            if place != nil {
                self.places.append(place!)
                if (self.places.count == total) {
                    let new_place = Place(dict: [:])
                    new_place.name = "Nueva Dirección"
                    new_place.apartament = false
                    new_place.pets = false
                    
                    self.places.append(new_place)
                    
                    self.placePickerBox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tooglePicker)))
                    
                    self.configureDropDown()
                    self.loadPlaceData()
                }
            } else {
                let new_place = Place(dict: [:])
                new_place.name = "Nueva Dirección"
                new_place.apartament = false
                new_place.pets = false
                
                self.places.append(new_place)
                
                self.placePickerBox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tooglePicker)))
                
                self.configureDropDown()
            }
        })
        keyboards_list = [nameText, addressText, towerText, interiorText, metersText, floorsText, roomsText, bathroomsText]
        setUpSmartKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.loadPlaceData()
    }
    
    public func loadPlaceData() {
        let place = self.places[self.selected_index]
        self.nameText.text = place.name
        self.addressText.text = place.address
        self.towerText.text = place.tower
        self.interiorText.text = place.interior
        self.metersText.text = place.area != nil ? String(format: "%.0f m2", place.area!) : ""
        self.floorsText.text = place.floors != nil ? String(format: "%d", place.floors!) : ""
        self.roomsText.text = place.rooms != nil ? String(format: "%d", place.rooms!) : ""
        self.bathroomsText.text = place.bathrooms != nil ? String(format: "%d", place.bathrooms!) : ""
        
        if place.apartament! {
            UIView.animate(withDuration: 0.5, animations: {
                self.floorsText.superview?.alpha = 0
                self.towerText.superview?.alpha = 1
                self.apartamentB.setTitleColor(.white, for: .normal)
                self.apartamentB.backgroundColor = K.UI.main_color
                self.houseB.setTitleColor(K.UI.form_color, for: .normal)
                self.houseB.backgroundColor = .white
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.floorsText.superview?.alpha = 1
                self.towerText.superview?.alpha = 0
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
        self.placePickerBox.roundCorners(radius: K.UI.light_round_px)
        self.placePickerBox.bordered(color: K.UI.select_box_color)
        self.apartamentB.roundCorners(radius: K.UI.light_round_px)
        self.apartamentB.addNormalShadow()
        self.houseB.roundCorners(radius: K.UI.light_round_px)
        self.houseB.addNormalShadow()
        self.nextB.roundCorners(radius: K.UI.round_px)
        self.nextB.addNormalShadow()
        
        self.originalFR = self.view.bounds
        
    }
    
    public func configureDropDown() {
        dropDown.anchorView = self.placePickerBox
        dropDown.dismissMode = .onTap
        dropDown.direction = .bottom
        let places_names = places.map { (place) -> String in
            return place.name ?? ""
        }
        dropDown.dataSource = places_names
        dropDown.selectionAction = {(index: Int, item: String) in
            self.currentPlaceLabel.text = item
            self.selected_index = index
            self.loadPlaceData()
        }
        self.currentPlaceLabel.text = places[0].name
    }
    
    public func tooglePicker() {
        dropDown.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func selectHouse(_ sender: Any) {
        places[selected_index].apartament = false
        loadPlaceData()
    }
    
    @IBAction func selectApartament(_ sender: Any) {
        places[selected_index].apartament = true
        loadPlaceData()
    }
    
    @IBAction func tooglePets(_ sender: Any) {
        places[selected_index].pets = !places[selected_index].pets!
        loadPlaceData()
    }
    
    @IBAction func done(_ sender: Any) {
        let mb = MBProgressHUD.showAdded(to: self.view, animated: true)
        let place = self.places[self.selected_index]
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
        service.place = place
        mb.hide(animated: true)
        BookingBriefViewController.brief(service: service, parent: self)
    }
    
    // Place picker
    func pickPlace() {
        var config = GMSPlacePickerConfig(viewport: nil)
        if self.places[self.selected_index].address != nil {
            let center = CLLocationCoordinate2D(latitude: self.places[self.selected_index].lat!, longitude: self.places[self.selected_index].lng!)
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
        viewController.dismiss(animated: true, completion: {() in
            if place.formattedAddress?.lowercased().range(of:"bogot") == nil {
                self.showAlert(title: "Lo sentimos", message: "HomeTap aún no está disponible para esta ubicación, estamos trabajando fuertemente para llegar a tu zona. Sin embargo, puedes pedir servicios para Bogotá desde cualquier lugar del país.", closeButtonTitle: "Entendido")
                return
            }
            self.addressText.text = place.formattedAddress ?? "Dirección inválida."
            self.places[self.selected_index].address = place.formattedAddress
            self.places[self.selected_index].lat = place.coordinate.latitude
            self.places[self.selected_index].lng = place.coordinate.longitude
        })
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
            self.displaceKeyboard = true
            return true
        case 25:
            textField.text = String(format: "%.0f", places[selected_index].area ?? 0)
            self.displaceKeyboard = true
            return true
        case 26:
            self.displaceKeyboard = true
            return true
        case 27:
            self.displaceKeyboard = true
            return true
        case 28:
            self.displaceKeyboard = true
            return true
        default:
            return true
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 28:
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
            return ((textField.text?.characters.count) ?? 0 < 4)
        case 24:
            return ((textField.text?.characters.count) ?? 0 < 9)
        case 25:
            return ((textField.text?.characters.count) ?? 0 < 5)
        case 26:
            return ((textField.text?.characters.count) ?? 0 < 2)
        case 27:
            return ((textField.text?.characters.count) ?? 0 < 3)
        case 28:
            return ((textField.text?.characters.count) ?? 0 < 3)
        default:
            return false
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 21:
            self.places[selected_index].name = textField.text
        case 23:
            self.places[selected_index].tower = textField.text
        case 24:
            self.places[selected_index].interior = textField.text
        case 25:
            if textField.text != "", let area = Double(textField.text!) {
                self.places[selected_index].area = area
            } else {
                self.showAlert(title: "Espera", message: "El área que has ingresado no es válida", closeButtonTitle: "Ok")
                return false
            }
        case 26:
            if textField.text != "", let floors = Int(textField.text!) {
                self.places[selected_index].floors = floors
            } else {
                self.showAlert(title: "Espera", message: "El número de pisos que has ingresado no es válido", closeButtonTitle: "Ok")
                return false
            }
        case 27:
            if textField.text != "", let rooms = Int(textField.text!) {
                self.places[selected_index].rooms = rooms
            } else {
                self.showAlert(title: "Espera", message: "El número de habitaciones que has ingresado no es válido", closeButtonTitle: "Ok")
                return false
            }
        case 28:
            if textField.text != "", let baths = Int(textField.text!) {
                self.places[selected_index].bathrooms = baths
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
