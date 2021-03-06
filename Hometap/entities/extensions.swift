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

struct UIViewControllerExtensionKeys {
    static var originalFrame: UInt8 = 0
    static var keyboards: UInt8 = 1
    static var needs: UInt8 = 2
}

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
        self.layoutIfNeeded()
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowPath = shadowPath.cgPath
    }
    
    func addInvertedShadow() {
        self.layoutIfNeeded()
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowPath = shadowPath.cgPath
    }
    
    func addSpecialShadow(size: CGSize, opacitiy: Float = 0.15) {
        self.layoutIfNeeded()
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = size
        self.layer.shadowOpacity = opacitiy
        self.layer.shadowPath = shadowPath.cgPath
    }
    
    func addLightShadow() {
        self.layoutIfNeeded()
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 0.05
        self.layer.shadowPath = shadowPath.cgPath
    }
    
    func clearShadows() {
        self.layer.shadowOpacity = 0.0
    }
    
    func roundCorners(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.shadowRadius = radius
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
    
    public var needsDisplacement: CGFloat {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewControllerExtensionKeys.needs) as? CGFloat else {
                return CGFloat(0)
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &UIViewControllerExtensionKeys.needs, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var originalFrame: CGRect {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewControllerExtensionKeys.originalFrame) as? CGRect else {
                return CGRect.zero
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &UIViewControllerExtensionKeys.originalFrame, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var keyboards: [UITextField] {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewControllerExtensionKeys.keyboards) as? [UITextField] else {
                return []
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &UIViewControllerExtensionKeys.keyboards, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    func showAlert(title:String, message:String, closeButtonTitle:String, special: Bool = true, persistent: Bool = false) {
        if special {
            HTAlertViewController.showHTAlert(title: title, body: message, accpetTitle: closeButtonTitle, parent: self, persistent: persistent)
        } else {
            let alertController = UIAlertController(title: title, message: message,
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: closeButtonTitle, style: .default) { (action: UIAlertAction) in
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true) { }
        }
    }
    
    func setUpSmartKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisplay(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clearKeyboards)))
    }
    
    @objc func keyboardWillDisplay(notification:NSNotification) {
        let userInfo:Dictionary = notification.userInfo!
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: 0.3) { 
             self.view.frame = CGRect(x: 0.0, y: (self.originalFrame.origin.y - (keyboardHeight*self.needsDisplacement)), width: (self.originalFrame.size.width), height: (self.originalFrame.size.height))
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        UIView.animate(withDuration: 0.3) { 
            self.view.frame = self.originalFrame
        }
    }
    
    @objc func clearKeyboards(index: Int = -1) {
        for k in keyboards {
            k.resignFirstResponder()
        }
        if (index > -1 && index < keyboards.count) {
            keyboards[index].becomeFirstResponder()
        }
    }
    
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFill) {
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
                K.Database.Local.save(id: url.absoluteString, data: data)
                mb.hide(animated: true)
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill) {
        if let data = K.Database.Local.getCache(link) {
            if let img = UIImage(data: data) {
                self.image = img
            }
        } else {
            guard let url = URL(string: link) else { return }
            downloadedFrom(url: url, contentMode: mode)
        }
    }
    func circleImage() {
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.clipsToBounds = true
    }
}

extension NSLayoutConstraint {
    
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
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
    
    func empty() -> Bool {
        return self.count == 0
    }
    
    var head: Element? {
        get {
            return self.first
        }
    }
    
    var tail: Array<Element>? {
        get {
            if self.empty() { return nil }
            return Array(self.dropFirst())
        }
    }
    
    func foldl<A>(acc: A, list: Array<Element>,f: (A, Element) -> A) -> A {
        if list.empty() { return acc }
        return foldl(acc: f(acc, list.head!), list: list.tail!, f: f)
    }
    
    subscript(indexes: [Int]) ->  [Element] {
        var result: [Element] = []
        for index in indexes {
            if index > 0 && index < self.count {
                result.append(self[index])
            }
        }
        return result
    }
    
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}

extension Date {
    enum DateFormat {
        case Short
        case Default
        case Medium
        case Long
        case Time
        case Try
        case Custom(String)
    }
    
    func merge(time: Date) -> Date? {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        
        return calendar.date(from: mergedComponments)
    }
    
    init?(fromString: String, withFormat: DateFormat) {
        let dtf = DateFormatter()
        dtf.locale = Locale(identifier: "en_US_POSIX")
        switch withFormat {
        case .Short:
            dtf.dateFormat = K.Helper.fb_date_short_format
        case .Default:
            dtf.dateFormat = K.Helper.fb_date_format
        case .Medium:
            dtf.dateFormat = K.Helper.fb_date_medium_format
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
            dtf.dateFormat = K.Helper.fb_date_short_format
            if let tst_dt = dtf.date(from: fromString) {
                self = tst_dt
                return
            }
            dtf.dateFormat = K.Helper.fb_date_medium_format
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
        case .Custom(let format):
            dtf.dateFormat = format
        }
        
        self = dtf.date(from: fromString)!
    }
    
    func toString(format: DateFormat) -> String? {
        let dtf = DateFormatter()
        dtf.locale = Locale(identifier: "en_US_POSIX")
        switch format {
        case .Short:
            dtf.dateFormat = K.Helper.fb_date_short_format
        case .Default, .Try:
            dtf.dateFormat = K.Helper.fb_date_format
        case .Medium:
            dtf.dateFormat = K.Helper.fb_date_medium_format
        case .Long:
            dtf.dateFormat = K.Helper.fb_long_date_format
        case .Time:
            dtf.dateFormat = K.Helper.fb_time_format
        case .Custom(let format):
            dtf.dateFormat = format
            let str = dtf.string(from: self)
            if str != "" {
                return str
            }
        }
        let str = dtf.string(from: self)
        return str
    }
}

extension String {
    mutating func insert(separator: String, every n: Int) {
        self = inserting(separator: separator, every: n)
    }
    func inserting(separator: String, every n: Int) -> String {
        var result: String = ""
        let characters = Array(self.characters)
        stride(from: 0, to: characters.count, by: n).forEach {
            result += String(characters[$0..<min($0+n, characters.count)])
            if $0+n < characters.count {
                result += separator
            }
        }
        return result
    }
}

extension UIView {
    
    public func viewIsScrolling() -> Bool {
        return anySubViewScrolling(view: self)
    }
    
    private func anySubViewScrolling(view: UIView) -> Bool {
        if let scroll = view as? UIScrollView {
            return scroll.isDragging || scroll.isDecelerating
        }
        var subs = false
        for v in view.subviews {
            subs = subs || anySubViewScrolling(view: v)
        }
        return subs
    }
}

