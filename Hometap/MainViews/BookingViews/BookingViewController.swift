//
//  BookingViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/18/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD

class BookingViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, DatePickerDelegate, UITextViewDelegate {

    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var mainServicePrice: UILabel!
    @IBOutlet weak var aditionalServicesCV: UICollectionView!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var mainServiceView: UIView!
    
    @IBOutlet weak var additionalHeigth: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeigth: NSLayoutConstraint!
    
    private var additional_services: [AppContent.HTAditionalService] = []
    private let initialHeigth: CGFloat = 1180
    private let initialCVHeight: CGFloat = 350
    
    public var selected:[Int] = []
    private var total: Double = 0
    private var total_time: Int = 0
    
    private var new_service = Service(dict: [:])
    private var old_service: Service? = nil
    private var favoriteResult: FavoriteSearchResult? = nil
    
    private var initial_load = true
    
    public class func show(parent: UIViewController, old: Service? = nil, favorite: FavoriteSearchResult? = nil) {
        let st = UIStoryboard.init(name: "Booking", bundle: nil)
        let book = st.instantiateViewController(withIdentifier: "BookView") as! BookingViewController
        book.old_service = old
        book.favoriteResult = favorite
        parent.show(book, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateTextField.text = Date().addingTimeInterval(60*60*24).toString(format: .Custom("dd/MM/yyyy"))
        self.timeTextField.text = "07:00 AM"
        self.new_service.date = Date().addingTimeInterval(60*60*24).merge(time: Date(fromString: "07:00 AM", withFormat: .Time)!)
    }
    
    override func viewDidLayoutSubviews() {
        let screenWidth = self.aditionalServicesCV.frame.size.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/2, height: screenWidth*0.9/2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 20
        self.aditionalServicesCV.collectionViewLayout = layout
        
        self.commentsTextView.bordered(color: K.UI.select_box_color)
        self.nextB.addNormalShadow()
        self.nextB.roundCorners(radius: K.UI.round_px)
        
        self.mainServiceView.roundCorners(radius: K.UI.light_round_px)
        self.mainServiceView.addNormalShadow()
    }

    override func viewDidAppear(_ animated: Bool) {
        if !initial_load {
            return
        }
        
        initial_load = false
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        if favoriteResult != nil {
            let date = Date(fromString: favoriteResult!.date, withFormat: .Custom("dd/MM/yyyy"))
            let time = Date(fromString: favoriteResult!.time, withFormat: .Time)
            self.new_service.date = date!.merge(time: time!)
            Homie.withID(id: favoriteResult!.homieID, callback: { (homie) in
                if homie != nil {
                    if self.new_service.saveClientHomie(client: K.User.client!, homie: homie!) {
                        self.new_service.blockID = self.favoriteResult!.blockID
                    }
                }
            })
            self.dateTextField.text = favoriteResult!.date
            self.dateTextField.isEnabled = false
            self.timeTextField.text = favoriteResult!.time
            self.timeTextField.isEnabled = false
        }
        
        AppContent.loadAppContent(callback: {() in
            self.additional_services = K.Hometap.app_content?.services() ?? []
            self.aditionalServicesCV.reloadData()
            self.aditionalServicesCV.layoutIfNeeded()
            
            self.additionalHeigth.constant = self.aditionalServicesCV.contentSize.height
            self.contentViewHeigth.constant = self.initialHeigth + (self.aditionalServicesCV.contentSize.height - self.initialCVHeight)
            
            self.total = K.Hometap.app_content?.basic()?.price ?? 0
            self.mainServicePrice.text = String(format: "PRECIO: %.0f COP", self.total)
            
            self.total_time = K.Hometap.app_content?.basic()?.time ?? 0
            
            if self.old_service != nil {
                self.commentsTextView.text = self.old_service?.comments
                self.total = self.old_service?.price ?? 0
                self.total_time = self.old_service?.time ?? 0
                
                if let old_additional = self.old_service?.additionalServices() {
                    for old_service in old_additional {
                        for (index, ht_add) in self.additional_services.enumerated() {
                            if old_service.descriptionH == ht_add.name {
                                self.selected.append(index)
                            }
                        }
                    }
                    self.self.aditionalServicesCV.reloadData()
                }
            }
            
            self.updateTotal()
            
            MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func next(_ sender: Any) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        guard self.new_service.date != nil else {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showAlert(title: "¡Espera!", message: "Debes elegir una fecha para tu servicio.", closeButtonTitle: "Entendido")
            return
        }
        
        guard self.timeTextField.text != "" else {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showAlert(title: "¡Espera!", message: "Debes elegir una hora para tu servicio.", closeButtonTitle: "Entendido")
            return
        }
        
        let services = additional_services[selected].map { (ht_additional) -> AdditionalService in
            let serv = AdditionalService(dict: [:])
            serv.price = ht_additional.price
            serv.descriptionH = ht_additional.name
            serv.icon = ht_additional.icon
            return serv
        }
        if services.count > 0 {
            self.new_service.saveAdditionalServices(services: services)
        }
        
        self.new_service.price = total
        self.new_service.time = total_time
        self.new_service.comments = self.commentsTextView.text ?? "Ninguno"
        
        MBProgressHUD.hide(for: self.view, animated: true)
        
        if self.new_service.homieID != nil {
            PlacePickerViewController.showPicker(service: self.new_service, parent: self)
        } else {
            HomiePickerViewController.pickHomie(service: self.new_service, parent: self)
        }
        
    }
    
    public func updateTotal() {
        self.totalPrice.text = String(format: "%.0fCOP", self.total)
    }
    
    // TextFields
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            DatePickerViewController.pickerWith(title: "¿Para cuándo quieres tu servicio?", date: self.dateTextField.text, format: "dd/MM/YYYY", minDate: .tomorrow, delegate: self, jm_delegate: self, tag: 1, onViewController: self)
            break
        case 2:
            if (self.dateTextField.text != "") {
                DatePickerViewController.pickerWith(title: "¿A qué hora quieres que llegue?", date: self.timeTextField.text, format: K.Helper.fb_time_format, type: .time, minDate: .date(self.dateTextField.text!), delegate: self, jm_delegate: self, tag: 2 , onViewController: self)
            } else {
                self.dateTextField.becomeFirstResponder()
            }
            break
        default:
            return false
        }
        return false
    }
    
    // Date picker
    
    func datePickerDidSelectDate(date: Date, string: String, tag: Int) {
        switch tag {
        case 1:
            // Date
            self.dateTextField.text = string
            self.new_service.date = date
        case 2:
            // Time
            self.timeTextField.text = string
            self.new_service.date = self.new_service.date?.merge(time: date)
            print(self.new_service.date?.toString(format: .Default) ?? "NO DATE")
        default:
            return
        }
    }
    
    // TextView
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 150;
    }
    
    
    
    // Aditional Services:
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return additional_services.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellUI = collectionView.dequeueReusableCell(withReuseIdentifier: "AddServiceCell", for: indexPath) as! HTCollectionViewCell
        
        let service = additional_services[indexPath.row]
        
        cellUI.uiUpdates = {(cell) in
            cell.viewWithTag(1)?.clearShadows()
            cell.viewWithTag(1)?.addSpecialShadow(size: CGSize(width: 0.0, height: 1.0), opacitiy: 0.05)
            cell.viewWithTag(2)?.clearShadows()
            cell.viewWithTag(2)?.addSpecialShadow(size: CGSize(width: 0.0, height: 1.0), opacitiy: 0.05)
            cell.viewWithTag(1)?.roundCorners(radius: K.UI.light_round_px)
            cell.viewWithTag(2)?.roundCorners(radius: 10)
            (cell.viewWithTag(1)?.viewWithTag(11) as? UILabel)?.text = service.name!
            (cell.viewWithTag(2)?.viewWithTag(11) as? UILabel)?.text = String(format: "%.0f COP", service.price!)
            
            if (self.selected.contains(indexPath.row)) {
                cell.viewWithTag(1)?.backgroundColor = K.UI.main_color
                cell.viewWithTag(2)?.backgroundColor = K.UI.main_color
                
                (cell.viewWithTag(1)?.viewWithTag(11) as? UILabel)?.textColor = .white
                (cell.viewWithTag(2)?.viewWithTag(11) as? UILabel)?.textColor = .white
                
                (cell.viewWithTag(1)?.viewWithTag(10) as? UIImageView)?.image = UIImage(named: String(format: "%@White", service.icon!))
            } else {
                cell.viewWithTag(1)?.backgroundColor = .white
                cell.viewWithTag(2)?.backgroundColor = .white
                
                (cell.viewWithTag(1)?.viewWithTag(11) as? UILabel)?.textColor = K.UI.main_color
                (cell.viewWithTag(2)?.viewWithTag(11) as? UILabel)?.textColor = K.UI.main_color
                
                (cell.viewWithTag(1)?.viewWithTag(10) as? UIImageView)?.image = UIImage(named: String(format: "%@Green", service.icon!))
            }
        }
        cellUI.layoutIfNeeded()
        
        return cellUI
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (selected.contains(indexPath.row)) {
            selected.remove(object: indexPath.row)
            total = total - additional_services[indexPath.row].price!
            total_time = total_time - additional_services[indexPath.row].time!
        } else {
            selected.append(indexPath.row)
            total = total + additional_services[indexPath.row].price!
            total_time = total_time + additional_services[indexPath.row].time!
        }
        collectionView.reloadItems(at: [indexPath])
        self.updateTotal()
    }

}
