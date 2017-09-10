//
//  HomiePickerViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/19/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD
import RestEssentials

class HomiePickerViewController: UIViewController {

    @IBOutlet weak var homie1: UIView!
    @IBOutlet weak var homie2: UIView!
    @IBOutlet weak var homie3: UIView!
    @IBOutlet weak var noHomieHintTitle: UILabel!
    @IBOutlet weak var noHomieHint: UILabel!
    @IBOutlet weak var noHomieB: UIButton!
    
    private var service: Service!
    private var blocks:[HTCBlock] = []
    private var loaded_homies: [Homie] = []
    
    private var homie_views: [UIView] = []
    
    public class func pickHomie(service: Service, parent: UIViewController) {
        let homie_picker = HomiePickerViewController.init(nibName: "HomiePickerViewController", bundle: nil)
        homie_picker.service = service

        parent.show(homie_picker, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let mb = MBProgressHUD.showAdded(to: self.view, animated: true)
        mb.label.text = "Buscando homies"
        
        homie1.tag = 51
        homie2.tag = 52
        homie3.tag = 53
        
        self.homie1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHomie1)))
        self.homie2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHomie2)))
        self.homie3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHomie3)))
        
        homie_views = [homie1, homie2, homie3]
        
        
        guard let url = RestController.make(urlString: "https://us-central1-hometap-f173f.cloudfunctions.net") else {
            mb.hide(animated: true)
            self.showAlert(title: "Sin conexión", message: "No hemos podido comunicarnos con tus homies, por favor revisa tu conexión a internet e intenta de nuevo.", closeButtonTitle: "Ok")
            return
        }
        
        let query: JSON = ["date": service.date!.toString(format: .Custom("YYYY-MM-dd'T'HH:mm"))!,
                           "time": service.time!]
        
        url.post(query, at: "homies") { (result, httpResponse) in
            do {
                let json = try result.value()
                if let homies = json.array{
                    for homie in homies {
                        print(homie)
                        let block = HTCBlock(dict: [:])
                        block.uid = homie["blockID"].string
                        block.date = Date(fromString: homie["date"].string!, withFormat: .Custom("YYYY-MM-dd"))
                        block.startHour = Date(fromString: homie["initialTime"].string!, withFormat: .Custom("HH:mm"))
                        block.endHour = Date(fromString: homie["finalTime"].string!, withFormat: .Custom("HH:mm"))
                        block.homieID = homie["id"].string!
                        self.blocks.append(block)
                    }
                    
                    {} ~> {
                        mb.hide(animated: true)
                        self.reloadUI()
                    }
                } else {
                    {} ~> {
                        mb.hide(animated: true)
                        self.showAlert(title: "Sin conexión", message: "No hemos podido comunicarnos con tus homies, por favor revisa tu conexión a internet e intenta de nuevo.", closeButtonTitle: "Ok")
                    }
                }
            } catch {
                mb.hide(animated: true)
                self.showAlert(title: "Sin conexión", message: "No hemos podido comunicarnos con tus homies, por favor revisa tu conexión a internet e intenta de nuevo.", closeButtonTitle: "Ok")
                self.reloadUI()
                return
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.homie1.addNormalShadow()
        self.homie1.roundCorners(radius: K.UI.light_round_px)
        self.homie2.addNormalShadow()
        self.homie2.roundCorners(radius: K.UI.light_round_px)
        self.homie3.addNormalShadow()
        self.homie3.roundCorners(radius: K.UI.light_round_px)
    }
    
    private func reloadUI() {
        if blocks.count == 0 {
            UIView.animate(withDuration: 1, animations: {
                self.noHomieHint.alpha = 1
                self.noHomieHintTitle.alpha = 1
                self.noHomieB.alpha = 1
            })
        } else {
            for (index, block) in blocks.enumerated() {
                let v = homie_views[index]
                UIView.animate(withDuration: 1, animations: {
                    v.alpha = 1
                    v.clipsToBounds = true
                })
                let mb = MBProgressHUD.showAdded(to: v, animated: true)
                
                let same_day = (service.date!.toString(format: .Custom("YYYY-MM-dd")) == block.date!.toString(format: .Custom("YYYY-MM-dd")))
                if (!same_day) {
                    v.viewWithTag(100)?.backgroundColor = K.UI.second_color
                }
                Homie.withID(id: block.homieID!, callback: { (homie) in
                    (v.viewWithTag(12) as? UILabel)?.text = String(format: "%.0f", homie?.rating ?? 0)
                    (v.viewWithTag(11) as? UILabel)?.text = homie?.name!
                    
                    (v.viewWithTag(100)?.viewWithTag(20) as? UILabel)?.text = block.date!.toString(format: .Custom("dd/MM/YYYY"))
                    (v.viewWithTag(100)?.viewWithTag(21) as? UILabel)?.text = block.startHour!.toString(format: .Time)
                    mb.hide(animated: true)
                    (v.viewWithTag(1) as? UIImageView)?.downloadedFrom(link: homie?.photo ?? "")
                    (v.viewWithTag(1) as? UIImageView)?.circleImage()
                    
                    self.loaded_homies.append(homie!)
                })
                
                
            }
        }
    }
    
    public func selectHomie1() {
        let homie = loaded_homies[0]
        let block = blocks[0]
        service.blockID = block.uid
        service.date = block.date!.merge(time: block.startHour!)
        HomieConfirmViewController.confirmHomie(service: self.service, homie: homie, parent: self)
        print("First")
    }
    
    public func selectHomie2() {
        let homie = loaded_homies[1]
        let block = blocks[1]
        service.blockID = block.uid
        service.date = block.date!.merge(time: block.startHour!)
        HomieConfirmViewController.confirmHomie(service: self.service, homie: homie, parent: self)
    }
    
    public func selectHomie3() {
        let homie = loaded_homies[2]
        let block = blocks[2]
        service.blockID = block.uid
        service.date = block.date!.merge(time: block.startHour!)
        HomieConfirmViewController.confirmHomie(service: self.service, homie: homie, parent: self)
    }


    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
