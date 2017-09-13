//
//  HomeViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/17/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var bookingB: UIButton!
    @IBOutlet weak var bookingB2: UIButton!
    @IBOutlet weak var noBookingArt: UIImageView!
    @IBOutlet weak var noBookingHint: UILabel!
    @IBOutlet weak var bookingTitle: UILabel!
    @IBOutlet weak var bookingTable: UITableView!
    
    private var services: [Service]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // Do any additional setup after loading the view.
        self.bookingB.addTarget(self, action: #selector(self.startBooking), for: .touchUpInside)
        self.bookingB2.addTarget(self, action: #selector(self.startBooking), for: .touchUpInside)
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                // Save user
                Client.withID(id: (K.User.logged_user()?.uid)!, callback: {(client) in
                    if client == nil {
                        // Register data and save
                    } else {
                        K.User.client = client!
                        K.User.loadCachedServices()
                        self.reloadClientData()
                        K.User.checkNotifications()
                        if let token = Firebase.Messaging.messaging().fcmToken {
                            K.User.client?.saveNotificationToken(token: token)
                        }
                        if K.User.client?.blocked ?? false {
                            HTAlertViewController.showHTAlert(title: "Lo sentimos", body: "Tu cuenta ha sido bloqueada por seguridad.", accpetTitle: "Llamar a HomeTap", confirmation: {() in
                                K.Hometap.call()
                            }, parent: K.MaterialTapBar.TapBar!, persistent: true)
                        }
                    }
                })
            } else {
                // No user is signed in.
                K.MaterialTapBar.TapBar?.performSegue(withIdentifier: "Login", sender: nil)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    @IBAction func showFavorites(_ sender: Any) {
        FavoritesViewController.showFavorites(parent: self)
    }
    
    public func startBooking() {
        if K.Network.network_available {
            BookingViewController.show(parent: self)
        } else {
            self.showAlert(title: "Lo sentimos", message: "No puedes pedir servicios cuando estás en el modo sin conexión.", closeButtonTitle: "Aceptar")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.bookingB.addNormalShadow()
        self.bookingB.roundCorners(radius: K.UI.round_px)
        self.bookingTable.reloadData()
        self.bookingTable.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.reloadClientData()
        self.view.layoutIfNeeded()
    }
    
    private func reloadClientData() {
        self.services = K.User.client?.services_brief() ?? []
        if self.services.count > 0 {
            UIView.animate(withDuration: 1.0, animations: {
                self.noBookingHint.alpha = 0
                self.noBookingArt.alpha = 0
                self.bookingB.alpha = 0
                
                self.bookingTitle.alpha = 1
                self.bookingTable.alpha = 1
                
                self.bookingTable.reloadData()
                self.bookingTable.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 1.0, animations: {
                self.noBookingHint.alpha = 1
                self.noBookingArt.alpha = 1
                self.bookingB.alpha = 1
                
                self.bookingTitle.alpha = 0
                self.bookingTable.alpha = 0
            })
        }
                
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.services.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellUI = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! HTTableViewCell
        let service = self.services[indexPath.row]
        
        cellUI.uiUpdates = {(cell) in
            cell.viewWithTag(100)?.addNormalShadow()
            cell.viewWithTag(100)?.roundCorners(radius: K.UI.light_round_px)
            
            cell.viewWithTag(2)?.addLightShadow()
            cell.viewWithTag(2)?.roundCorners(radius: K.UI.light_round_px)
            
            (cell.viewWithTag(1) as? UIImageView)?.downloadedFrom(link: service.briefPhoto ?? "")
            (cell.viewWithTag(1) as? UIImageView)?.circleImage()
            (cell.viewWithTag(11) as? UILabel)?.text = service.briefName ?? "Nuevo servicio"
            (cell.viewWithTag(2)?.viewWithTag(12) as? UILabel)?.text = service.date?.toString(format: .Custom("MMM")) ?? "MON"
            (cell.viewWithTag(2)?.viewWithTag(13) as? UILabel)?.text = service.date?.toString(format: .Custom("dd")) ?? "00"
            (cell.viewWithTag(2)?.viewWithTag(14) as? UILabel)?.text = service.date?.toString(format: .Time)
            
            (cell.viewWithTag(15) as? UILabel)?.text = String(format: "%.1f", service.briefRating ?? 0)
        }
        return cellUI
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go to Service
        let service = self.services[indexPath.row]
        BookingBriefViewController.brief(service: service, parent: self)
    }
    
}
