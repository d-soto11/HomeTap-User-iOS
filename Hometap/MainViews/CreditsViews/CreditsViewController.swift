//
//  CreditsViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 9/9/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {

    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var ticketB: UIButton!
    
    public class func showCredits(parent: UIViewController) {
        let st = UIStoryboard.init(name: "Credits", bundle: nil)
        let credits = st.instantiateViewController(withIdentifier: "Credits")
        
        parent.show(credits, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let cr = K.User.client?.credits ?? 0
        self.creditsLabel.text = String(format: "%.0f COP", cr)
    }
    
    override func viewDidLayoutSubviews() {
        self.ticketB.addLightShadow()
        self.ticketB.roundCorners(radius: K.UI.light_round_px)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func redeem(_ sender: Any) {
        
    }


}
