//
//  FavoriteSearchViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 9/11/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class FavoriteSearchViewController: UIViewController {

    @IBOutlet weak var homiePhoto: UIImageView!
    @IBOutlet weak var homieHint: UILabel!
    @IBOutlet weak var serviceDate: UILabel!
    @IBOutlet weak var serviceTime: UILabel!
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var bookB: UIButton!
    
    private var container: UIViewController!
    private var centerY: NSLayoutConstraint!
    
    private var results: [FavoriteSearchResult]!
    private var confirmation: (()->Void)!
    private var cancelation: (()->Void)!
    
    private var currentResult: Int! = -1
    
    public class func showSearchResults(results: [FavoriteSearchResult], confirmation: @escaping ()->Void, cancelation: @ escaping ()->Void, parent: UIViewController) {
        let alert = UIStoryboard(name: "Favorites", bundle: nil).instantiateViewController(withIdentifier: "Search") as! FavoriteSearchViewController
        
        let blackView = UIView()
        blackView.tag = 96
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
        let c4 = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: blackView, attribute: .height, multiplier: 1, constant: 0)
        parent.view.addConstraints([c1, c2, alert.centerY, c4])
        
        
        UIView.animate(withDuration: 0.3) {
            parent.view.layoutIfNeeded()
            parent.view.viewWithTag(96)?.alpha = 0.7
            alert.view.alpha = 1
        }
        
        alert.results = results
        alert.container = parent
        alert.cancelation = cancelation
        alert.confirmation = confirmation
        
        parent.addChildViewController(alert)
        alert.didMove(toParentViewController: parent)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        self.cancelB.roundCorners(radius: K.UI.special_round_px)
        self.nextB.roundCorners(radius: K.UI.round_px)
        self.bookB.roundCorners(radius: K.UI.round_px)
        self.homiePhoto.circleImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadNextResult()
    }
    
    public func loadNextResult() {
        currentResult = currentResult + 1
        if currentResult < results.count {
            let res = results[currentResult]
            self.homiePhoto.downloadedFrom(link: res.photo)
            self.homieHint.text = String(format:"%@ puede prestarte un servicio básico el:", res.name.components(separatedBy: " ")[0])
            self.serviceDate.text = res.date
            self.serviceTime.text = res.time
        } else {
            self.dismiss()
            self.cancelation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func next(_ sender: Any) {
        self.loadNextResult()
    }
    
    @IBAction func book(_ sender: Any) {
        BookingViewController.show(parent: self, favorite: results[currentResult])
    }
    
    private func dismiss() {
        self.centerY.constant = self.container.view.frame.height
        UIView.animate(withDuration: 0.3, animations: {
            self.container.view.layoutIfNeeded()
            self.container.view.viewWithTag(96)?.alpha = 0
            self.view.alpha = 0
        }) { (finished) in
            self.container.view.viewWithTag(96)?.removeFromSuperview()
            self.view.removeFromSuperview()
            self.didMove(toParentViewController: nil)
        }
    }
}

class FavoriteSearchResult {
    let name: String!
    let photo: String!
    let date: String!
    let time: String!
    let blockID: String!
    let homieID: String!
    
    init(name: String, photo: String, date: String, time: String, block: String, homie: String) {
        self.name = name
        self.photo = photo
        self.date = date
        self.blockID = block
        self.time = time
        self.homieID = homie
    }
}
