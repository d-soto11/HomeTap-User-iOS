//
//  extensions.swift
//  Hometap
//
//  Created by Daniel Soto on 7/12/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import MBProgressHUD

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension UIView {
    
    func addNormalShadow() {
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowPath = shadowPath.cgPath
    }
    
    func addSpecialShadow(size: CGSize) {
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = size
        self.layer.shadowOpacity = 0.15
        self.layer.shadowPath = shadowPath.cgPath
    }
    
    func addLightShadow() {
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 0.05
        self.layer.shadowPath = shadowPath.cgPath
    }
    
    func clearShadows() {
        self.layer.shadowOpacity = 0.0;
    }
    
    func roundCorners(radius: CGFloat) {
        self.layer.cornerRadius = radius;
    }
    
    func bordered(color:UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1.0
    }
    
    func addInnerShadow() {
        self.layer.borderColor = UIColor(netHex:0x545454).withAlphaComponent(0.3).cgColor
        self.layer.borderWidth = 1.0
    }
}

extension UIViewController {
    func showAlert(title:String, message:String, closeButtonTitle:String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: closeButtonTitle, style: .default) { (action: UIAlertAction) in
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true) { }
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        let mb = MBProgressHUD.showAdded(to: self, animated: true)
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                mb.hide(animated: true)
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    func circleImage() {
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.clipsToBounds = true
    }
}

// Logical

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

extension Date {
    enum DateFormat {
        case Default
        case Long
        case Time
        case Try
    }
    
    init?(fromString: String, withFormat: DateFormat) {
        let dtf = DateFormatter()
        switch withFormat {
        case .Default:
            dtf.dateFormat = K.Helper.fb_date_format
        case .Long:
            dtf.dateFormat = K.Helper.fb_long_date_format
        case .Time:
            dtf.dateFormat = K.Helper.fb_time_format
        case .Try:
            dtf.dateFormat = K.Helper.fb_date_format
            if let tst_dt = dtf.date(from: fromString) {
                self = tst_dt
                return
            }
            dtf.dateFormat = K.Helper.fb_long_date_format
            if let tst_dt = dtf.date(from: fromString) {
                self = tst_dt
                return
            }
            dtf.dateFormat = K.Helper.fb_time_format
            if let tst_dt = dtf.date(from: fromString) {
                self = tst_dt
                return
            }
            else {
                return nil
            }
        }
        
        self = dtf.date(from: fromString)!
    }
    
    func toString(format: DateFormat) -> String? {
        let dtf = DateFormatter()
        switch format {
        case .Default:
            dtf.dateFormat = K.Helper.fb_date_format
        case .Long:
            dtf.dateFormat = K.Helper.fb_long_date_format
        case .Time:
            dtf.dateFormat = K.Helper.fb_time_format
        case .Try:
            dtf.dateFormat = K.Helper.fb_date_format
            var str = dtf.string(from: self)
            if str != "" {
                return str
            }
            dtf.dateFormat = K.Helper.fb_long_date_format
            str = dtf.string(from: self)
            if str != "" {
                return str
            }
            dtf.dateFormat = K.Helper.fb_time_format
            str = dtf.string(from: self)
            if str != "" {
                return str
            }
            else {
                return nil
            }
        }
        let str = dtf.string(from: self)
        return str
    }
}

