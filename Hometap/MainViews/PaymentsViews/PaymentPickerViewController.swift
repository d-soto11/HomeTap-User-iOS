//
//  PaymentPickerViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/27/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import DropDown
import MBProgressHUD
import Firebase
import RestEssentials

class PaymentPickerViewController: UIViewController {
    
    @IBOutlet weak var paymentPicker: UIView!
    @IBOutlet weak var currentPayment: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var payB: UIButton!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var saveB: UIButton!
    
    private var payments: [PaymentCard]! = []
    private var service: Service!
    
    public var selected_index: Int = 0
    
    let dropDown = DropDown()
    
    var loaded_card_view: PaymentsCardViewController?
    var save_payment: Bool = false
    
    public class func showPicker(service: Service, parent: UIViewController) {
        let st = UIStoryboard.init(name: "Payments", bundle: nil)
        let picker = st.instantiateViewController(withIdentifier: "Picker") as! PaymentPickerViewController
        
        picker.service = service
        parent.show(picker, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        K.User.client?.payments(callback: { (payment, total) in
            if payment != nil {
                self.payments.append(payment!)
                if (self.payments.count == total) {
                    
                    self.paymentPicker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tooglePicker)))
                    
                    self.configureDropDown()
                }
            } else {
                self.paymentPicker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tooglePicker)))
                self.configureDropDown()
            }
        })
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPaymentData()
    }
    
    override func viewDidLayoutSubviews() {
        self.payB.addNormalShadow()
        self.payB.roundCorners(radius: K.UI.round_px)
    }
    
    public func configureDropDown() {
        dropDown.anchorView = self.paymentPicker
        dropDown.dismissMode = .onTap
        dropDown.direction = .bottom
        var places_names = payments.map { (payment) -> String in
            return String(format: "%@ ***%@", payment.brand!, payment.number!)
        }
        places_names.append("Nuevo medio de pago")
        dropDown.dataSource = places_names
        dropDown.selectionAction = {(index: Int, item: String) in
            self.currentPayment.text = item
            self.selected_index = index
            self.loadPaymentData()
        }
        if !payments.isEmpty {
            let payment = payments[0]
            self.currentPayment.text = String(format: "%@ ***%@", payment.brand!, payment.number!)
            loadPaymentData()
        }
    }
    
    @objc public func tooglePicker() {
        dropDown.show()
    }
    
    public func loadPaymentData() {
        if loaded_card_view != nil {
            loaded_card_view!.willMove(toParentViewController: nil)
            loaded_card_view!.view.removeFromSuperview()
            loaded_card_view!.removeFromParentViewController()
        }
        if self.selected_index < self.payments.count {
            loaded_card_view = PaymentsCardViewController.showCardView(parent: self, frame: self.cardView.frame, card: self.payments[self.selected_index], selecting: true)
            self.saveB.alpha = 0
            self.saveLabel.alpha = 0
        } else {
            loaded_card_view = PaymentsCardViewController.showCardView(parent: self, frame: self.cardView.frame)
            self.saveB.alpha = 1
            self.saveLabel.alpha = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.service.state = nil
    }
    
    @IBAction func toogleSavingPayment(_ sender: Any) {
        save_payment = !save_payment
        if save_payment {
            self.saveLabel.text = "Si"
            self.saveLabel.textColor = K.UI.main_color
        } else {
            self.saveLabel.text = "No"
            self.saveLabel.textColor = K.UI.alert_color
        }
    }
    
    @IBAction func payBooking(_ sender: Any) {
        let mb = MBProgressHUD.showAdded(to: self.view, animated: true)
        mb.label.text = "Estableciendo conexión segura"
        
        guard let url = RestController.make(urlString: "https://us-central1-hometap-f173f.cloudfunctions.net") else {
            mb.hide(animated: true)
            self.showAlert(title: "Sin conexión", message: "No hemos podido establecer una conexión segura, por favor revisa tu conexión a internet e intenta de nuevo.", closeButtonTitle: "Ok")
            return
        }
        
        Auth.auth().currentUser?.getIDToken(completion: { (id, error) in
            DispatchQueue.main.async {
                mb.label.text = "Preparando pago"
            }
            
            if id != nil {
                var options = RestOptions()
                let authToken = String(format: "Bearer %@", id!)
                options.httpHeaders = ["Authorization": authToken]
                
                if self.selected_index < self.payments.count {
                    // Is old
                    DispatchQueue.main.async {
                        mb.label.text = "Procesando pago"
                    }
                    if let token = self.payments[self.selected_index].uid {
                        let query: JSON = ["date": Date().toString(format: .Custom("yyyy-MM-dd"))!,
                                           "ammount":self.service.price!,
                                           "token": token]
                        url.post(query, at: "pay", options: options) { (result, httpResponse) in
                            if httpResponse?.statusCode == 200 {
                                // Payment succesfull
                                DispatchQueue.main.async {
                                    mb.hide(animated: true)
                                    BookingConfirmationViewController.confirm(service: self.service, parent: self)
                                }
                            } else if httpResponse?.statusCode == 201 {
                                HTAlertViewController.showHTAlert(title: "Pago pendiente", body: "Tu entidad bancaria está procesando el pago. Por el momento hemos reservado tu servicio. Te avisaremos cuando recibamos tu pago.", accpetTitle: "Genial", confirmation: {
                                    DispatchQueue.main.async {
                                        mb.hide(animated: true)
                                        BookingConfirmationViewController.confirm(service: self.service, parent: self)
                                    }
                                }, parent: self)
                            } else {
                                DispatchQueue.main.async {
                                    mb.hide(animated: true)
                                    self.showAlert(title: "Lo sentimos", message: "No hemos podido procesar tu pago. Intenta de nuevo más tarde.", closeButtonTitle: "Ok")
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            mb.hide(animated: true)
                            self.showAlert(title: "Lo sentimos", message: "No hemos podido procesar tu pago. Intenta de nuevo más tarde.", closeButtonTitle: "Ok")
                        }
                    }
                } else {
                    // Is new
                    DispatchQueue.main.async {
                        mb.label.text = "Verificando tarjeta"
                    }
                    self.loaded_card_view?.tokenizeCreditCard(callback: { (card) in
                        guard card != nil else {
                            mb.hide(animated: true)
                            self.showAlert(title: "Lo sentimos", message: "No hemos podido verificar tu tarjeta. Verifica que los datos que ingresaste son correctos.", closeButtonTitle: "Ok")
                            return
                        }
                        if self.save_payment {
                            // Save
                            DispatchQueue.main.async {
                                mb.label.text = "Guardando información de pago"
                            }
                            K.User.client!.savePayment(payment: card!)
                            card!.save()
                            if let token = card?.uid {
                                DispatchQueue.main.async {
                                    mb.label.text = "Procesando pago"
                                }
                                let query: JSON = ["date": Date().toString(format: .Custom("yyyy-MM-dd"))!,
                                                   "ammount":self.service.price!,
                                                   "token": token]
                                url.post(query, at: "pay", options: options) { (result, httpResponse) in
                                    if httpResponse?.statusCode == 200 {
                                        // Payment succesfull
                                        DispatchQueue.main.async {
                                            mb.hide(animated: true)
                                            BookingConfirmationViewController.confirm(service: self.service, parent: self)
                                        }
                                    } else if httpResponse?.statusCode == 201 {
                                        HTAlertViewController.showHTAlert(title: "Pago pendiente", body: "Tu entidad bancaria está procesando el pago. Por el momento hemos reservado tu servicio. Te avisaremos cuando recibamos tu pago.", accpetTitle: "Genial", confirmation: {
                                            DispatchQueue.main.async {
                                                mb.hide(animated: true)
                                                BookingConfirmationViewController.confirm(service: self.service, parent: self)
                                            }
                                        }, parent: self)
                                    } else {
                                        DispatchQueue.main.async {
                                            mb.hide(animated: true)
                                            self.showAlert(title: "Lo sentimos", message: "No hemos podido procesar tu pago. Intenta de nuevo más tarde.", closeButtonTitle: "Ok")
                                        }
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    mb.hide(animated: true)
                                    self.showAlert(title: "Lo sentimos", message: "No hemos podido procesar tu pago. Intenta de nuevo más tarde.", closeButtonTitle: "Ok")
                                }
                            }
                        } else {
                            if let token = card?.uid {
                                DispatchQueue.main.async {
                                    mb.label.text = "Procesando pago"
                                }
                                let query: JSON = ["date": Date().toString(format: .Custom("yyyy-MM-dd"))!,
                                                   "ammount":self.service.price!,
                                                   "token": token]
                                url.post(query, at: "pay", options: options) { (result, httpResponse) in
                                    if httpResponse?.statusCode == 200 {
                                        // Payment succesfull
                                        DispatchQueue.main.async {
                                            mb.hide(animated: true)
                                            BookingConfirmationViewController.confirm(service: self.service, parent: self)
                                        }
                                    } else if httpResponse?.statusCode == 201 {
                                        HTAlertViewController.showHTAlert(title: "Pago pendiente", body: "Tu entidad bancaria está procesando el pago. Por el momento hemos reservado tu servicio. Te avisaremos cuando recibamos tu pago.", accpetTitle: "Genial", confirmation: {
                                            DispatchQueue.main.async {
                                                mb.hide(animated: true)
                                                BookingConfirmationViewController.confirm(service: self.service, parent: self)
                                            }
                                        }, parent: self)
                                    } else {
                                        DispatchQueue.main.async {
                                            mb.hide(animated: true)
                                            self.showAlert(title: "Lo sentimos", message: "No hemos podido procesar tu pago. Intenta de nuevo más tarde.", closeButtonTitle: "Ok")
                                        }
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    mb.hide(animated: true)
                                    self.showAlert(title: "Lo sentimos", message: "No hemos podido procesar tu pago. Intenta de nuevo más tarde.", closeButtonTitle: "Ok")
                                }
                            }
                        }
                    })
                }
            } else {
                DispatchQueue.main.async {
                    mb.hide(animated: true)
                    self.showAlert(title: "Lo sentimos", message: "No hemos podido procesar tu pago. Intenta de nuevo más tarde.", closeButtonTitle: "Ok")
                }
            }
        })
        
        
    }
    
}
