//
//  HistoryViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/17/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var noBookingHint: UILabel!
    @IBOutlet weak var bookingB: UIButton!
    
    @IBOutlet weak var historyTable: UITableView!
    
    var services: [Service] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookingB.addTarget(self, action: #selector(startBooking), for: .touchUpInside)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.bookingB.addNormalShadow()
        self.bookingB.roundCorners(radius: K.UI.round_px)
        
        self.historyTable.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.reloadClientData()
    }
    
    private func reloadClientData() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Client.withID(id: K.User.client!.uid!) { (client) in
            if client != nil {
                K.User.client = client
                self.services = K.User.client?.history_brief() ?? []
                if self.services.count > 0 {
                    UIView.animate(withDuration: 1.0, animations: {
                        self.noBookingHint.alpha = 0
                        self.bookingB.alpha = 0
                        
                        self.historyTable.reloadData()
                    })
                } else {
                    UIView.animate(withDuration: 1.0, animations: {
                        self.noBookingHint.alpha = 1
                        self.bookingB.alpha = 1
                        self.historyTable.alpha = 0
                    })
                }
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
    }
    
    public func startBooking() {
        BookingViewController.show(parent: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.services.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellUI = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HTTableViewCell
        let service = self.services[indexPath.row]
        
        cellUI.uiUpdates = {(cell) in
            cell.viewWithTag(100)?.addNormalShadow()
            cell.viewWithTag(100)?.roundCorners(radius: K.UI.light_round_px)
            
            
            (cell.viewWithTag(2) as? UIImageView)?.downloadedFrom(link: service.briefPhoto!)
            (cell.viewWithTag(2) as? UIImageView)?.circleImage()
            (cell.viewWithTag(11) as? UILabel)?.text = service.briefName!
            (cell.viewWithTag(100)?.viewWithTag(12) as? UILabel)?.text = service.date?.toString(format: .Custom("dd/MM/YYYY")) ?? "Sin fecha"
            (cell.viewWithTag(100)?.viewWithTag(13) as? UILabel)?.text = service.date?.toString(format: .Time)
            if let state = service.state {
                if state == -1 {
                    (cell.viewWithTag(100)?.viewWithTag(14) as? UILabel)?.text = "Cancelado"
                    (cell.viewWithTag(100)?.viewWithTag(14) as? UILabel)?.textColor = K.UI.alert_color

                } else if state == 1 {
                    (cell.viewWithTag(100)?.viewWithTag(14) as? UILabel)?.text = "Completado"
                    (cell.viewWithTag(100)?.viewWithTag(14) as? UILabel)?.textColor = K.UI.main_color
                }
            }
            
            (cell.viewWithTag(100)?.viewWithTag(15) as? UILabel)?.text = String(format: "%.1f", service.briefRating!)
        }
        return cellUI
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go to Service
        let service = K.User.client!.services_brief()![indexPath.row]
        BookingBriefViewController.brief(service: service, parent: self)
    }
    
    
}
