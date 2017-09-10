//
//  HomieConfirmViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/19/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD

class HomieConfirmViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var homieProfilePicture: UIImageView!
    @IBOutlet weak var homieRating: UILabel!
    @IBOutlet weak var homieName: UILabel!
    @IBOutlet weak var homieCommentsHint: UILabel!
    @IBOutlet weak var commentsTable: UITableView!
    @IBOutlet weak var noCommentsHint: UILabel!
    @IBOutlet weak var loadCommentsB: UIButton!
    @IBOutlet weak var dismissB: UIButton!
    @IBOutlet weak var bookB: UIButton!
    
    @IBOutlet weak var contentViewHeigth: NSLayoutConstraint!
    @IBOutlet weak var commentsHeigth: NSLayoutConstraint!
    
    private var service: Service!
    private var homie: Homie!
    private var comments: [Comment] = []
    private var showComments = false
    
    private let initialHeigth: CGFloat = 830
    private let initalCommentsHeigth: CGFloat = 150
    
    public class func confirmHomie(service: Service, homie: Homie, parent: UIViewController) {
        let st = UIStoryboard.init(name: "Booking", bundle: nil)
        let confirm = st.instantiateViewController(withIdentifier: "ConfirmHomieView") as! HomieConfirmViewController
        confirm.service = service
        confirm.homie = homie
        parent.show(confirm, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        self.loadCommentsB.roundCorners(radius: K.UI.light_round_px)
        self.homieProfilePicture.addNormalShadow()
        self.homieProfilePicture.circleImage()
        
        self.dismissB.roundCorners(radius: K.UI.round_px)
        self.dismissB.addLightShadow()
        self.bookB.addNormalShadow()
        self.bookB.roundCorners(radius: K.UI.round_px)
        
        self.dismissB.bordered(color: K.UI.select_box_color)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        self.homieProfilePicture.downloadedFrom(link: homie.photo!)
        self.homieRating.text = String(format: "%.0f", homie.rating!)
        self.homieName.text = homie.name!
        self.homieCommentsHint.text = String(format: "Lo que dicen de %@", homie.name!)
        
        homie.comments { (comment, total) in
            if comment != nil {
                self.comments.append(comment!)
                if self.comments.count == total {
                    self.commentsTable.reloadData()
                    self.commentsTable.layoutIfNeeded()
                    self.commentsHeigth.constant = self.commentsTable.contentSize.height
                    self.contentViewHeigth.constant = self.initialHeigth + (self.commentsTable.contentSize.height - self.initalCommentsHeigth)
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            } else {
                if self.comments.count == 0{
                    UIView.animate(withDuration: 1, animations: {
                        self.commentsTable.alpha = 0
                        self.noCommentsHint.alpha = 1
                        self.loadCommentsB.alpha = 0
                    })
                } else {
                    self.commentsTable.reloadData()
                    self.commentsTable.layoutIfNeeded()
                    self.commentsHeigth.constant = self.commentsTable.contentSize.height
                    self.contentViewHeigth.constant = self.initialHeigth + (self.commentsTable.contentSize.height - self.initalCommentsHeigth)
                }
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmBooking(_ sender: Any) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let _ = service.saveClientHomie(client: K.User.client!, homie: homie)
        MBProgressHUD.hide(for: self.view, animated: true)
        PlacePickerViewController.showPicker(service: self.service, parent: self)
    }
    
    @IBAction func toogleComments(_ sender: Any) {
        self.showComments = !self.showComments
        self.commentsTable.reloadData()
        self.commentsTable.layoutIfNeeded()
        self.commentsHeigth.constant = self.commentsTable.contentSize.height
        self.contentViewHeigth.constant = self.initialHeigth + (self.commentsTable.contentSize.height - self.initalCommentsHeigth)
    }
    
    // Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showComments {
            return comments.count > 10 ? 10 : comments.count
        } else {
            return comments.count > 2 ? 2 : comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellUI = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! HTTableViewCell
        
        let comment = comments[indexPath.row]
        
        cellUI.uiUpdates = {(cell) in
            cell.viewWithTag(1)?.addNormalShadow()
            (cell.viewWithTag(11) as? UILabel)?.text = comment.clientName
            (cell.viewWithTag(12) as? UILabel)?.text = comment.body
            (cell.viewWithTag(2) as? UIImageView)?.circleImage()
        }
        
        return cellUI
    }
    
}
