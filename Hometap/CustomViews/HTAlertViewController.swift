//
//  HTAlertViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 9/10/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class HTAlertViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var confirmationB: UIButton!
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var cancelHeigth: NSLayoutConstraint!
    private var titleString: String!
    private var bodyString: String!
    private var acceptTitle: String!
    private var cancelTitle: String?
    private var confirmation: (()->Void)!
    private var cancelation: (()->Void)!
    private var persistent: Bool!
    private var container: UIViewController!
    private var centerY: NSLayoutConstraint!
    
    public class func showHTAlert(title: String, body: String = "", accpetTitle: String = "Aceptar", cancelTitle: String? = nil, confirmation: @escaping ()->Void = {() in}, cancelation: @ escaping ()->Void = {() in}, parent: UIViewController, persistent: Bool = false) {
        let alert = HTAlertViewController(nibName: "HTAlertViewController", bundle: nil)
        
        let blackView = UIView()
        blackView.tag = 95
        blackView.backgroundColor = .black
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.alpha = 0
        parent.view.insertSubview(blackView, aboveSubview: parent.view)
        
        let bc1 = NSLayoutConstraint(item: blackView, attribute: .leading, relatedBy: .equal, toItem: parent.view, attribute: .leading, multiplier: 1, constant: 0)
        let bc2 = NSLayoutConstraint(item: blackView, attribute: .trailing, relatedBy: .equal, toItem: parent.view, attribute: .trailing, multiplier: 1, constant: 0)
        let bc3 = NSLayoutConstraint(item: blackView, attribute: .top, relatedBy: .equal, toItem: parent.view, attribute: .top, multiplier: 1, constant: 0)
        let bc4 = NSLayoutConstraint(item: blackView, attribute: .bottom, relatedBy: .equal, toItem: parent.view, attribute: .bottom, multiplier: 1, constant: 0)
        
        parent.view.addConstraints([bc1, bc2, bc3, bc4])
        parent.view.layoutIfNeeded()

        alert.view.alpha = 0
        alert.view.translatesAutoresizingMaskIntoConstraints = false
        parent.view.insertSubview(alert.view, aboveSubview: blackView)
        alert.view.frame = CGRect(x: 0, y: parent.view.frame.height, width: parent.view.frame.width, height: 100)
        
        let c1 = NSLayoutConstraint(item: alert.view, attribute: .width, relatedBy: .equal, toItem: blackView, attribute: .width, multiplier: 0.9, constant: 0)
        let c2 = NSLayoutConstraint(item: alert.view, attribute: .centerX, relatedBy: .equal, toItem: blackView, attribute: .centerX, multiplier: 1, constant: 0)
        alert.centerY = NSLayoutConstraint(item: alert.view, attribute: .centerY, relatedBy: .equal, toItem: blackView, attribute: .centerY, multiplier: 1, constant: 0)
        let plus = 20*(round(Double(body.characters.count / 20)))
        let c4 = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(200 + plus))
        parent.view.addConstraints([c1, c2, alert.centerY, c4])
        
        
        UIView.animate(withDuration: 0.3) {
            parent.view.layoutIfNeeded()
            alert.view.roundCorners(radius: K.UI.light_round_px)
            parent.view.viewWithTag(95)?.alpha = 0.7
            alert.view.alpha = 1
        }
        
        alert.titleString = title
        alert.bodyString = body
        alert.acceptTitle = accpetTitle
        alert.cancelTitle = cancelTitle
        alert.confirmation = confirmation
        alert.cancelation = cancelation
        alert.container = parent
        alert.persistent = persistent
        
        parent.addChildViewController(alert)
        alert.didMove(toParentViewController: parent)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.titleLabel.text = self.titleString
        self.bodyLabel.text = self.bodyString
        self.confirmationB.setTitle(self.acceptTitle, for: .normal)
        if self.cancelTitle != nil {
            self.cancelB.setTitle(self.cancelTitle, for: .normal)
            self.cancelHeigth.constant = 30
            UIView.animate(withDuration: 0.3, animations: { 
                self.cancelB.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.confirmationB.addNormalShadow()
        self.confirmationB.roundCorners(radius: K.UI.round_px)
        if self.cancelTitle != nil {
            self.cancelB.roundCorners(radius: K.UI.special_round_px)
            self.cancelB.bordered(color: K.UI.form_color)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func confirm(_ sender: Any) {
        self.confirmation()
        self.dismiss()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.cancelation()
        self.dismiss()
    }
    
    private func dismiss() {
        guard persistent == false else {
            return
        }
        self.centerY.constant = self.container.view.frame.height
        UIView.animate(withDuration: 0.3, animations: {
            self.container.view.layoutIfNeeded()
            self.container.view.viewWithTag(95)?.alpha = 0
            self.view.alpha = 0
        }) { (finished) in
            self.container.view.viewWithTag(95)?.removeFromSuperview()
            self.view.removeFromSuperview()
            self.didMove(toParentViewController: nil)
        }
    }

}
