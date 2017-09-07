//
//  ProfileChangeViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 9/6/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class ProfileChangeViewController: UIViewController {
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var fieldText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
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
