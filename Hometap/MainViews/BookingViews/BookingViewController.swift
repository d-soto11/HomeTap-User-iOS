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
    
    @IBOutlet weak var additionalHeigth: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeigth: NSLayoutConstraint!
    
    private var additional_services: [AppContent.HTAditionalService] = []
    private let initialHeigth: CGFloat = 1180
    private let initialCVHeight: CGFloat = 350
    
    public var selected:[Int] = []
    private var total: Double = 0
    private var total_time: Int = 0
    
    private var new_service = Service(dict: [:])
    
    public class func show(parent: UIViewController) {
        let st = UIStoryboard.init(name: "Main", bundle: nil)
        let book = st.instantiateViewController(withIdentifier: "BookView")
        parent.show(book, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        let screenWidth = self.aditionalServicesCV.frame.size.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth*1.3/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.aditionalServicesCV.collectionViewLayout = layout
        
        self.commentsTextView.bordered(color: K.UI.select_box_color)
        self.nextB.addNormalShadow()
        self.nextB.roundCorners(radius: K.UI.round_px)
    }

    override func viewDidAppear(_ animated: Bool) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        AppContent.loadAppContent(callback: {() in
            self.additional_services = K.Hometap.app_content?.services() ?? []
            self.aditionalServicesCV.reloadData()
            self.aditionalServicesCV.layoutIfNeeded()
            
            self.additionalHeigth.constant = self.aditionalServicesCV.contentSize.height
            self.contentViewHeigth.constant = self.initialHeigth + (self.aditionalServicesCV.contentSize.height - self.initialCVHeight)
            
            self.total = K.Hometap.app_content?.basic()?.price ?? 0
            self.mainServicePrice.text = String(format: "PRECIO: %.0f COP", self.total)
            
            self.total_time = K.Hometap.app_content?.basic()?.time ?? 0
            
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
        
        HomiePickerViewController.pickHomie(service: self.new_service, parent: self)
        
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
            cell.viewWithTag(1)?.addLightShadow()
            cell.viewWithTag(2)?.addLightShadow()
            cell.viewWithTag(1)?.roundCorners(radius: K.UI.light_round_px)
            cell.viewWithTag(2)?.roundCorners(radius: 10)
            (cell.viewWithTag(1)?.viewWithTag(11) as? UILabel)?.text = service.name!
            (cell.viewWithTag(2)?.viewWithTag(11) as? UILabel)?.text = String(format: "%.0fCOP", service.price!)
            
            if (self.selected.contains(indexPath.row)) {
                cell.viewWithTag(1)?.backgroundColor = K.UI.main_color
                cell.viewWithTag(2)?.backgroundColor = K.UI.main_color
                
                (cell.viewWithTag(1)?.viewWithTag(11) as? UILabel)?.textColor = .white
                (cell.viewWithTag(2)?.viewWithTag(11) as? UILabel)?.textColor = .white
                
                (cell.viewWithTag(1)?.viewWithTag(10) as? UIImageView)?.image = UIImage(named: String(format: "%@_white", service.icon!))
            } else {
                cell.viewWithTag(1)?.backgroundColor = .white
                cell.viewWithTag(2)?.backgroundColor = .white
                
                (cell.viewWithTag(1)?.viewWithTag(11) as? UILabel)?.textColor = K.UI.main_color
                (cell.viewWithTag(2)?.viewWithTag(11) as? UILabel)?.textColor = K.UI.main_color
                
                (cell.viewWithTag(1)?.viewWithTag(10) as? UIImageView)?.image = UIImage(named: String(format: "%@_green", service.icon!))
            }
        }
        
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
