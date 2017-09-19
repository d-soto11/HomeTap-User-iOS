//
//  LocationsViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/17/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD

class LocationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var locationsTable: UITableView!
    public var places: [Place] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        MBProgressHUD.showAdded(to: self.locationsTable, animated: true)
        self.places = K.User.client?.places(callback: { (place, total) in
            if place != nil {
                for (i, p) in self.places.enumerated() {
                    if p.uid! == place!.uid! && i < self.places.count{
                        self.places.remove(at: i)
                    }
                }
                self.places.append(place!)
                if (self.places.count == total) {
                    self.locationsTable.reloadData()
                    MBProgressHUD.hide(for: self.locationsTable, animated: true)
                }
            } else {
                MBProgressHUD.hide(for: self.locationsTable, animated: true)
            }
        }) ?? []
        if !K.Network.network_available {
            MBProgressHUD.hide(for: self.locationsTable, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.locationsTable.reloadData()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // isLastCell
        if (indexPath.row == self.places.count) {
            let cell_m = tableView.dequeueReusableCell(withIdentifier: "addAddressCell", for: indexPath) as! HTTableViewCell
            cell_m.uiUpdates = {(cell) in
                (cell.viewWithTag(1) as? UIButton)?.roundCorners(radius: K.UI.light_round_px)
                (cell.viewWithTag(1) as? UIButton)?.clearShadows()
                (cell.viewWithTag(1) as? UIButton)?.addLightShadow()
                (cell.viewWithTag(1) as? UIButton)?.addTarget(self, action: #selector(self.newPlace), for: .touchUpInside)
            }
            
            return cell_m
        } else {
            let cell_m = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! HTTableViewCell
            let place = places[indexPath.row]

            cell_m.uiUpdates = {(cell) in
                cell.viewWithTag(2)?.roundCorners(radius: K.UI.light_round_px)
                cell.viewWithTag(2)?.addNormalShadow()
                (cell.viewWithTag(2)?.viewWithTag(10) as? UIImageView)?.image = place.apartament! ? UIImage(named: "iconApartment") : UIImage(named: "iconHouseBlack")
                (cell.viewWithTag(2)?.viewWithTag(11) as? UILabel)?.text = place.name!
            }
            return cell_m
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // isLastCell
        return indexPath.row == self.places.count ? 80 : 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == places.count {
            newPlace()
        } else {
            let place = places[indexPath.row]
            PlaceEditorViewController.showEditor(place: place, parent: self)
        }
    }
    
    @objc func newPlace() {
        let place = Place(dict: [:])
        place.apartament = false
        place.pets = false
        PlaceEditorViewController.showEditor(place: place, parent: self)
    }

}
