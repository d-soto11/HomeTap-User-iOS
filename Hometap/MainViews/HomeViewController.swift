//
//  HomeViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/17/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var bookingB: UIButton!
    @IBOutlet weak var noBookingArt: UIImageView!
    @IBOutlet weak var noBookingHint: UILabel!

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
        self.bookingB.addNormalShadow()
        self.bookingB.roundCorners(radius: K.UI.round_px)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
