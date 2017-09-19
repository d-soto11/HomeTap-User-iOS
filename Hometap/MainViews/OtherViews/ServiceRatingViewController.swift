//
//  ServiceRatingViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 9/7/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import Cosmos
import Firebase
import MBProgressHUD

class ServiceRatingViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var starRating: CosmosView!
    @IBOutlet weak var complimentView: UIView!
    @IBOutlet weak var mainHint: UILabel!
    @IBOutlet weak var commentView: UITextView!
    @IBOutlet weak var auxSaveB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var saveHomieLabel: UILabel!
    @IBOutlet weak var saveHomieB: UIButton!
    
    @IBOutlet weak var complimentHeigth: NSLayoutConstraint!
    @IBOutlet weak var commentHeigth: NSLayoutConstraint!
    @IBOutlet weak var favoriteHeigth: NSLayoutConstraint!
    private var totalHeigth: NSLayoutConstraint!
    private var centerY: NSLayoutConstraint!
    private var container: UIViewController!
    
    private var saveFavorite: Bool = true
    private var compliments: [String:Bool] = [:]
    private var service: Service!
    private var callback: ()->Void = {() in}
    
    public class func rateService(service: Service, parent: UIViewController, callback: @escaping ()->Void) {
        let st = UIStoryboard.init(name: "Other", bundle: nil)
        let rater = st.instantiateViewController(withIdentifier: "Rate") as! ServiceRatingViewController
        
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
        
        rater.view.translatesAutoresizingMaskIntoConstraints = false
        parent.view.insertSubview(rater.view, aboveSubview: blackView)
        rater.view.frame = CGRect(x: 0, y: parent.view.frame.height, width: parent.view.frame.width, height: 120)
        
        let c1 = NSLayoutConstraint(item: rater.view, attribute: .width, relatedBy: .equal, toItem: blackView, attribute: .width, multiplier: 0.9, constant: 0)
        let c2 = NSLayoutConstraint(item: rater.view, attribute: .centerX, relatedBy: .equal, toItem: blackView, attribute: .centerX, multiplier: 1, constant: 0)
        rater.centerY = NSLayoutConstraint(item: rater.view, attribute: .centerY, relatedBy: .equal, toItem: blackView, attribute: .centerY, multiplier: 1, constant: 0)
        rater.totalHeigth = NSLayoutConstraint(item: rater.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 480)
        parent.view.addConstraints([c1, c2, rater.centerY, rater.totalHeigth])
        
        
        UIView.animate(withDuration: 0.3) {
            parent.view.layoutIfNeeded()
            rater.view.roundCorners(radius: K.UI.light_round_px)
            rater.view.alpha = 1
            parent.view.viewWithTag(95)?.alpha = 0.7
        }
        
        parent.addChildViewController(rater)
        rater.didMove(toParentViewController: parent)
        rater.container = parent
        rater.service = service
        rater.callback = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        starRating.didTouchCosmos = { rating in
            self.updateUIForRaintg(rating: rating)
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    
    override func viewDidLayoutSubviews() {
        self.saveB.addNormalShadow()
        self.saveB.roundCorners(radius: K.UI.round_px)
        self.auxSaveB.addLightShadow()
        self.auxSaveB.roundCorners(radius: K.UI.special_round_px)
        self.auxSaveB.bordered(color: K.UI.select_box_color)
        
        self.commentView.bordered(color: K.UI.select_box_color)
        self.commentView.roundCorners(radius: K.UI.light_round_px)
        
        for control in 1...4 {
            if let compliment = self.complimentView.viewWithTag(control) as? UIButton {
                compliment.roundCorners(radius: compliment.frame.height/2)
                compliment.bordered(color: K.UI.select_box_color)
                compliment.addTarget(self, action: #selector(toogleCompliment(sender:)), for: .touchUpInside)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toogleFavorite(_ sender: Any) {
        self.saveFavorite = !self.saveFavorite
        if self.saveFavorite {
            self.saveHomieLabel.text = "Si"
            self.saveHomieLabel.textColor = K.UI.main_color
        } else {
            self.saveHomieLabel.text = "No"
            self.saveHomieLabel.textColor = K.UI.alert_color
        }
    }
    
    @objc func toogleCompliment(sender: UIButton) {
        let tag = sender.tag
        if let index = self.compliments.index(forKey: "\(tag)") {
            self.compliments.remove(at: index)
            (self.complimentView.viewWithTag(tag) as? UIButton)?.setTitleColor(K.UI.form_color, for: .normal)
            (self.complimentView.viewWithTag(tag) as? UIButton)?.backgroundColor = .white
            (self.complimentView.viewWithTag(tag) as? UIButton)?.bordered(color: K.UI.select_box_color)
        } else {
            self.compliments["\(tag)"] = true
            (self.complimentView.viewWithTag(tag) as? UIButton)?.setTitleColor(.white, for: .normal)
            (self.complimentView.viewWithTag(tag) as? UIButton)?.backgroundColor = K.UI.main_color
            (self.complimentView.viewWithTag(tag) as? UIButton)?.bordered(color: .clear)
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if self.starRating.rating < 3 {
            saveAux(sender)
            K.Hometap.call()
        } else {
            saveAux(sender)
        }
    }
    
    @IBAction func saveAux(_ sender: Any) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let comment = Comment(dict: [:])
        comment.body = self.commentView.text
        comment.clientID = K.User.client?.uid
        comment.clientName = K.User.client?.name
        comment.date = Date()
        let _ = service.homie { (homie) in
            if homie != nil {
                comment.homieID = homie!.uid
                comment.homieName = homie!.name
                comment.rating = self.starRating.rating
                comment.original_dictionary["tags"] = self.compliments as AnyObject
                comment.original_dictionary["tipo"] = 0 as AnyObject
                comment.save()
                if self.saveFavorite {
                    let _ = K.User.client?.saveFavorite(favorite: homie!)
                }
                MBProgressHUD.hide(for: self.view, animated: true)
                self.centerY.constant = self.container.view.frame.height
                UIView.animate(withDuration: 0.3, animations: {
                    self.container.view.layoutIfNeeded()
                    self.container.view.viewWithTag(95)?.alpha = 0
                    self.view.alpha = 0
                }, completion: { (done) in
                    self.container.view.viewWithTag(95)?.removeFromSuperview()
                    self.view.removeFromSuperview()
                    self.callback()
                    self.didMove(toParentViewController: nil)
                })
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.showAlert(title: "Lo sentimos", message: "Ha ocurrido un error inesperado.", closeButtonTitle: "Ok")
            }
        }
        
    }
    
    // UI Helpers
    
    func updateUIForRaintg(rating: Double) {
        if rating < 3 {
            // Problems
            self.commentHeigth.constant = 100
            self.complimentHeigth.constant = 0
            self.favoriteHeigth.constant = 0
            self.totalHeigth.constant = 385
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.container.view.layoutIfNeeded()
                self.complimentView.alpha = 0
                self.auxSaveB.alpha = 1
                self.saveHomieB.alpha = 0
                self.saveHomieLabel.alpha = 0
                self.saveB.setTitle("Llamar a HomeTap", for: .normal)
                self.mainHint.text = "¿Tuviste algún problema? ¡Podemos ayudarte!"
            })
        } else if rating < 4 {
            // Normal
            self.commentHeigth.constant = 100
            self.complimentHeigth.constant = 0
            self.favoriteHeigth.constant = 0
            self.totalHeigth.constant = 385
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.container.view.layoutIfNeeded()
                self.complimentView.alpha = 0
                self.auxSaveB.alpha = 0
                self.saveHomieB.alpha = 0
                self.saveHomieLabel.alpha = 0
                self.saveB.setTitle("¡Terminar!", for: .normal)
                self.mainHint.text = "¿Quieres hacer algún comentario de tu Homie?"
            })
        } else {
            // Excelent
            self.commentHeigth.constant = 100
            self.complimentHeigth.constant = 70
            self.favoriteHeigth.constant = 25
            self.totalHeigth.constant = 480
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.container.view.layoutIfNeeded()
                self.complimentView.alpha = 1
                self.auxSaveB.alpha = 0
                self.saveHomieB.alpha = 1
                self.saveHomieLabel.alpha = 1
                self.saveB.setTitle("¡Terminar!", for: .normal)
                self.mainHint.text = "¿Quieres hacer algún comentario de tu Homie?"
            })
        }
    }
    
    @objc func hideKeyboard() {
        self.commentView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.centerY.constant = -self.view.frame.height/3
        UIView.animate(withDuration: 0.5) {
            self.container.view.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.centerY.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.container.view.layoutIfNeeded()
        }
    }
    
}
