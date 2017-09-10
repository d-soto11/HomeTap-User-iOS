//
//  Coupon.swift
//  Hometap
//
//  Created by Daniel Soto on 9/10/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase

class Coupon: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let expires = dict["expires"] as? String {
            self.expires = Date(fromString: expires, withFormat: .Custom("yyyy-MM-dd'T'HH:mm"))
        }
        if let multiple = dict["multiple"] {
            self.multiple = (multiple as? Bool)
        }
        if let used = dict["used"] {
            self.used = (used as? Bool)
        }
        if let credits = dict["credits"] {
            self.credits = (credits as? Double)
        }
    }
    
    public class func verify(coupon: String, callback: @escaping (_ c: Coupon?)->Void){
        K.Database.ref().child("appContent").child("coupons").child(coupon).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                let c = Coupon(dict: dict)
                c.uid = coupon
                callback(c)
            } else {
                callback(nil)
            }
        })
    }
    
    public func save(){
        if self.expires != nil {
            original_dictionary["expires"] = self.expires?.toString(format: .Custom("yyyy-MM-dd'T'HH:mm")) as AnyObject
        }
        if self.multiple != nil {
            original_dictionary["multiple"] = self.multiple as AnyObject
        }
        if self.used != nil {
            original_dictionary["used"] = self.used as AnyObject
        }
        if self.credits != nil {
            original_dictionary["credits"] = self.credits as AnyObject
        }
        
        super.save(route: "appContent/coupons")
    }
    
    var expires: Date?
    var multiple: Bool?
    var used: Bool?
    var credits: Double?
    
}
