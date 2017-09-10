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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // Do any additional setup after loading the view.
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                // Save user
                Client.withID(id: (K.User.logged_user()?.uid)!, callback: {(client) in
                    if client == nil {
                        // Register data and save
                    } else {
                        K.User.client = client!
                        self.reloadClientData()
                        
                        self.bookingB.addTarget(self, action: #selector(self.startBooking), for: .touchUpInside)
                        self.bookingB2.addTarget(self, action: #selector(self.startBooking), for: .touchUpInside)
                        if let token = Firebase.Messaging.messaging().fcmToken {
                            K.User.client?.saveNotificationToken(token: token)
                        }
                    }
                })
            } else {
                // No user is signed in.
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
        K.Network.startNetworkUpdates()        
    }
    
    public func startBooking() {
        BookingViewController.show(parent: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if var pending = K.User.client?.notifications() {
            for notification in pending {
                switch notification.type! {
                case 1:
                    Service.withID(id: notification.uid!, callback: { (service) in
                        if service != nil {
                            ServiceRatingViewController.rateService(service: service!, parent: K.MaterialTapBar.TapBar!, callback: {
                                pending.remove(object: notification)
                                if pending.isEmpty {
                                    K.User.client?.clearNotifications()
                                    K.MaterialTapBar.TapBar?.reloadViewController()
                                }
                            })
                        }
                    })
                default:
                    break
                }
                
            }
            K.User.client?.clearNotifications()
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
    }
    
    private func reloadClientData() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Client.withID(id: K.User.client!.uid!) { (client) in
            if client != nil {
                K.User.client = client
                if let count = K.User.client?.services_brief()?.count {
                    if count > 0 {
                        UIView.animate(withDuration: 1.0, animations: {
                            self.noBookingHint.alpha = 0
                            self.noBookingArt.alpha = 0
                            self.bookingB.alpha = 0
                            
                            self.bookingTitle.alpha = 1
                            self.bookingTable.alpha = 1
                            
                            self.bookingTable.reloadData()
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
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return K.User.client?.services_brief()?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellUI = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! HTTableViewCell
        let service = K.User.client!.services_brief()![indexPath.row]
        
        cellUI.uiUpdates = {(cell) in
            cell.viewWithTag(100)?.addNormalShadow()
            cell.viewWithTag(100)?.roundCorners(radius: K.UI.light_round_px)
            
            cell.viewWithTag(2)?.addLightShadow()
            cell.viewWithTag(2)?.roundCorners(radius: K.UI.light_round_px)
            
            (cell.viewWithTag(1) as? UIImageView)?.downloadedFrom(link: service.briefPhoto!)
            (cell.viewWithTag(1) as? UIImageView)?.circleImage()
            (cell.viewWithTag(11) as? UILabel)?.text = service.briefName!
            (cell.viewWithTag(2)?.viewWithTag(12) as? UILabel)?.text = service.date?.toString(format: .Custom("MMM")) ?? "MON"
            (cell.viewWithTag(2)?.viewWithTag(13) as? UILabel)?.text = service.date?.toString(format: .Custom("dd")) ?? "00"
            (cell.viewWithTag(2)?.viewWithTag(14) as? UILabel)?.text = service.date?.toString(format: .Time)
            
            (cell.viewWithTag(15) as? UILabel)?.text = String(format: "%.0f", service.briefRating!)
        }
        return cellUI
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go to Service
        let service = K.User.client!.services_brief()![indexPath.row]
        BookingBriefViewController.brief(service: service, parent: self)
    }
    
}
