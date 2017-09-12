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
            cell.viewWithTag(1)?.clearShadows()
            cell.viewWithTag(1)?.addNormalShadow()
            cell.viewWithTag(1)?.roundCorners(radius: K.UI.light_round_px)
            (cell.viewWithTag(1)?.viewWithTag(11) as? UILabel)?.text = homie.name ?? "Homie"
            (cell.viewWithTag(1)?.viewWithTag(2) as? UIImageView)?.downloadedFrom(link: homie.photo ?? "")
            (cell.viewWithTag(1)?.viewWithTag(2) as? UIImageView)?.circleImage()
        }
        
        cellUI.layoutIfNeeded()
        
        return cellUI
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Search favorite
        let selected_homie = favorites[indexPath.row]
        var results: [FavoriteSearchResult] = []
        let mb = MBProgressHUD.showAdded(to: self.view, animated: true)
        guard let url = RestController.make(urlString: "https://us-central1-hometap-f173f.cloudfunctions.net") else {
            mb.hide(animated: true)
            self.showAlert(title: "Sin conexión", message: "No hemos podido comunicarnos con tus homie, por favor revisa tu conexión a internet e intenta de nuevo.", closeButtonTitle: "Ok")
            return
        }
        
        let query: JSON = ["date": Date().addingTimeInterval(60 * 60 * 24).toString(format: .Custom("YYYY-MM-dd"))!,
                           "id": selected_homie.uid ?? "none"]
        
        url.post(query, at: "favoritehomie") { (result, httpResponse) in
            do {
                let json = try result.value()
                if let blocks = json.array{
                    for block in blocks {
                        let date = Date(fromString: block["date"].string!, withFormat: .Custom("yyyy-MM-dd"))
                        let time = Date(fromString: block["initialTime"].string!, withFormat: .Custom("HH:mm"))?.toString(format: .Time)
                        let res = FavoriteSearchResult(name: selected_homie.name!, photo: selected_homie.photo!, date: date!.toString(format: .Custom("dd/MM/yyyy"))!, time: time!, block: block["blockID"].string!, homie: selected_homie.uid!)
                        results.append(res)
                    }
                    
                    DispatchQueue.main.async {
                        mb.hide(animated: true)
                        // Show resutls
                        FavoriteSearchViewController.showSearchResults(results: results, confirmation: {
                            // Book with selected homie
                        }, cancelation: {
                            self.showAlert(title: "Lo sentimos", message: String(format: "%@ no tiene más fechas disponibles próximamente.", selected_homie.name!), closeButtonTitle: "Ok")
                        }, parent: self)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        mb.hide(animated: true)
                        self.showAlert(title: "Sin conexión", message: "No hemos podido revisar el horario de tu homie, por favor revisa tu conexión a internet e intenta de nuevo.", closeButtonTitle: "Ok")
                    }
                }
            } catch {
                mb.hide(animated: true)
                self.showAlert(title: "Sin conexión", message: "No hemos podido revisar el horario de tu homie, por favor revisa tu conexión a internet e intenta de nuevo.", closeButtonTitle: "Ok")
                return
            }
        }
    }

}
