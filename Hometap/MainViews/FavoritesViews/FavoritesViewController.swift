//
//  FavoritesViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 9/11/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase
import RestEssentials

class FavoritesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var noFavoritesHintTitle: UILabel!
    @IBOutlet weak var noFavoritesHint: UILabel!
    @IBOutlet weak var favoritesHint: UILabel!
    @IBOutlet weak var favoritesSeparator: UIView!
    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    
    private var favorites: [Homie]!
    
    public class func showFavorites(parent: UIViewController) {
        let st = UIStoryboard(name: "Favorites", bundle: nil)
        let favs = st.instantiateViewController(withIdentifier: "Favorites") as! FavoritesViewController
        favs.favorites = K.User.client?.favorites() ?? []
        parent.show(favs, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        let screenWidth = self.favoritesCollectionView.frame.size.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/2, height: screenWidth*1.3/2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.favoritesCollectionView.collectionViewLayout = layout
        
        self.favoritesCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        if self.favorites.count > 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.noFavoritesHint.alpha = 0
                self.noFavoritesHintTitle.alpha = 0
                self.favoritesHint.alpha = 1
                self.favoritesSeparator.alpha = 1
                self.favoritesCollectionView.alpha = 1
            })
            MBProgressHUD.hide(for: self.view, animated: true)
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.noFavoritesHint.alpha = 1
                self.noFavoritesHintTitle.alpha = 1
                self.favoritesHint.alpha = 0
                self.favoritesSeparator.alpha = 0
                self.favoritesCollectionView.alpha = 0
            })
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Favorites:
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellUI = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! HTCollectionViewCell
        
        let homie = favorites[indexPath.row]
        
        cellUI.uiUpdates = {(cell) in
            cell.viewWithTag(1)?.addNormalShadow()
            cell.viewWithTag(1)?.roundCorners(radius: K.UI.light_round_px)
            (cell.viewWithTag(1)?.viewWithTag(11) as? UILabel)?.text = homie.name ?? "Homie"
            (cell.viewWithTag(1)?.viewWithTag(2) as? UIImageView)?.downloadedFrom(link: homie.photo ?? "")
            (cell.viewWithTag(1)?.viewWithTag(2) as? UIImageView)?.circleImage()
        }
        
        return cellUI
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Search favorite
    }

}
