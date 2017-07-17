//
//  LocationsViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/17/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class LocationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // isLastCell
        if (true) {
            let cell_m = tableView.dequeueReusableCell(withIdentifier: "addAddressCell", for: indexPath) as! HTTableViewCell
            
            cell_m.uiUpdates = {(cell) in
                (cell.viewWithTag(1) as? UIButton)?.roundCorners(radius: K.UI.light_round_px)
                (cell.viewWithTag(1) as? UIButton)?.addLightShadow()
            }
            
            return cell_m
            
        } else {
            // Deque
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // isLastCell
        return true ? 80 : 60
    }
    

}
