//
//  ProfileViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 7/17/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var nameB: UIButton!
    @IBOutlet weak var phoneB: UIButton!
    @IBOutlet weak var mailB: UIButton!
    @IBOutlet weak var passwordB: UIButton!
    @IBOutlet weak var paymentB: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if K.User.client != nil {
            self.pictureView.downloadedFrom(link: K.User.client!.photo!)
            self.nameB.setTitle(K.User.client!.name!, for: .normal)
            self.phoneB.setTitle(K.User.client!.phone!, for: .normal)
            self.mailB.setTitle(K.User.client!.email!, for: .normal)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        paymentB.addLightShadow()
        paymentB.roundCorners(radius: K.UI.light_round_px)
        pictureView.circleImage()
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
