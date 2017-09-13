//
//  BookingBriefViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/27/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class BookingBriefViewController: UIViewController {

    @IBOutlet weak var completedView: UIView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var homiePhoto: UIImageView!
    @IBOutlet weak var homieName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var serviceImageStack: UIStackView!
    @IBOutlet weak var serviceLabelStack: UIStackView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var doneB: UIButton!
    
    @IBOutlet weak var serviceStackHeigth: NSLayoutConstraint!
    @IBOutlet weak var contentHeigth: NSLayoutConstraint!
    @IBOutlet weak var basicServiceImage: UIImageView!
    @IBOutlet weak var basicServiceLabel: UILabel!
    @IBOutlet weak var statusHeigth: NSLayoutConstraint!
    
    var service: Service!
    
    public class func brief(service: Service, parent: UIViewController) {
        let st = UIStoryboard.init(name: "Booking", bundle: nil)
        let brief = st.instantiateViewController(withIdentifier: "Brief") as! BookingBriefViewController
        brief.service = service
        parent.show(brief, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if service.uid != nil {
            Service.withID(id: service.uid!, callback: { (serv) in
                if serv != nil {
                    self.service = serv
                    self.loadServiceData()
                }
            })
        } else {
            self.loadServiceData()
        }
    }
    
    public func loadServiceData() {
        
        if (service.state == nil) {
            self.completedView.alpha = 0
            self.statusHeigth.constant = 0
            self.contentHeigth.constant = self.contentHeigth.constant - 70
        } else if (service.state == 0) {
            self.completedView.alpha = 0
            self.statusHeigth.constant = 0
            self.contentHeigth.constant = self.contentHeigth.constant - 70
        } else if service.state == -1{
            self.stateLabel.text = "Cancelado"
            self.stateLabel.textColor = K.UI.alert_color
            self.statusHeigth.constant = 70
            self.contentHeigth.constant = self.contentHeigth.constant + 70
        } else if service.state == 1 {
            self.stateLabel.text = "En progreso"
            self.stateLabel.textColor = K.UI.main_color
            self.ratingLabel.text = String(format: "%.1f", service.rating ?? 5.0)
            self.statusHeigth.constant = 70
            self.contentHeigth.constant = self.contentHeigth.constant + 70
        } else if service.state == 2 {
            self.stateLabel.text = "Completado"
            self.stateLabel.textColor = K.UI.main_color
            self.ratingLabel.text = String(format: "%.1f", service.rating ?? 5.0)
            self.statusHeigth.constant = 70
            self.contentHeigth.constant = self.contentHeigth.constant + 70
        }
        
        let _ = service.homie { (homie) in
            if homie != nil {
                self.homiePhoto.downloadedFrom(link: homie!.photo!)
                self.homieName.text = homie!.name!
            }
        }
        
        self.dateLabel.text = service.date!.toString(format: .Short)
        self.timeLabel.text = service.date!.toString(format: .Time)
        self.addressLabel.text = service.place!.address!
        
        if let additional_services = service.additionalServices() {
            for additional in additional_services {
                let image = UIImageView(image: UIImage(named: "iconServiceChecked"))
                image.contentMode = .scaleAspectFit
                self.serviceImageStack.addArrangedSubview(image)
                let img_heigth = NSLayoutConstraint(item: image, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: basicServiceImage, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
                self.serviceImageStack.addConstraint(img_heigth)
                
                let label = UILabel()
                label.text = additional.descriptionH
                label.font = UIFont(name: "Rubik-Light", size: 15)
                self.serviceLabelStack.addArrangedSubview(label)
                let lbl_heigth = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: basicServiceLabel, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
                self.serviceLabelStack.addConstraint(lbl_heigth)
                
                self.serviceStackHeigth.constant = self.serviceStackHeigth.constant + 40
                self.contentHeigth.constant = self.contentHeigth.constant + 40
            }
        }
        
        self.commentLabel.text = service.comments ?? "Ninguno."
        if self.commentLabel.text! == "" {
            self.commentLabel.text = "Ninguno."
        }
        
        if (service.state == nil) {
            // New
            self.priceLabel.text = String(format: "%.0f COP", service.price!)
            self.doneB.setTitle("Confirmar", for: .normal)
        } else if (service.state == 0) {
            self.priceLabel.text = String(format: "%.0f COP", service.price!)
            self.doneB.backgroundColor = K.UI.alert_color
            self.doneB.setTitle("Cancelar", for: .normal)
        } else {
            self.priceView.alpha = 0
            self.doneB.setTitle("Llamar a Hometap", for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.doneB.addNormalShadow()
        self.doneB.roundCorners(radius: K.UI.round_px)
        
        self.homiePhoto.addLightShadow()
        self.homiePhoto.circleImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func done(_ sender: Any) {
        if (service.state == nil) {
            self.service.state = 0
            PaymentPickerViewController.showPicker(service: service, parent: self)
        } else if service.state == 0 {
            // Cancel service
            HTAlertViewController.showHTAlert(title: "Cancelar servicio", body: "¿Estás seguro que deseas cancelar este servicio?", accpetTitle: "No", cancelTitle: "Si", confirmation: { 
                
            }, cancelation: { 
                self.service.state = -1
                self.service.save()
                let _ = self.service.homie(callback: { (h) in
                    self.service.briefName = h?.name ?? "Servicio cancelado"
                    self.service.briefPhoto = h?.photo ?? K.User.default_ph
                    K.User.client?.lastCanceledService = self.service
                })
                self.back(self)
            }, parent: self)
        } else {
            K.Hometap.call()
        }
    }
    

}
