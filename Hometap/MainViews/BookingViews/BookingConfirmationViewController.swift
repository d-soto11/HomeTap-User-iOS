//
//  BookingConfirmationViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/29/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD

class BookingConfirmationViewController: UIViewController {
    
    public class func confirm(service: Service, parent: UIViewController) {
        MBProgressHUD.showAdded(to: parent.view, animated: true)
        let st = UIStoryboard.init(name: "Booking", bundle: nil)
        let confirmation = st.instantiateViewController(withIdentifier: "Confirmation") as! BookingConfirmationViewController
        service.save()
        K.User.addCacheService(service)
        MBProgressHUD.hide(for: parent.view, animated: true)
        
        parent.view.insertSubview(confirmation.view, aboveSubview: parent.view)
        confirmation.view.frame = parent.view.frame
        confirmation.view.alpha = 0
        
        parent.addChildViewController(confirmation)
        confirmation.didMove(toParentViewController: parent)
        
        UIView.animate(withDuration: 0.5) {
            confirmation.view.alpha = 1
        }
        
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
                UIView.animate(withDuration: 0.5) {
                    confirmation.view.alpha = 0
                }
                K.MaterialTapBar.TapBar?.reloadViewController()
            }
        } else {
            Timer.scheduledTimer(timeInterval: 2.0,
                                 target: confirmation,
                                 selector: #selector(hideConfirmation),
                                 userInfo: nil,
                                 repeats: false)
        }
        
    }
    
    @objc func hideConfirmation() {
        UIView.animate(withDuration: 0.5) {
            self.view.alpha = 0
        }
        K.MaterialTapBar.TapBar?.reloadViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
