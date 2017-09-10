//
//  PaymentCard.swift
//  Hometap
//
//  Created by Daniel Soto on 8/27/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase

class PaymentCard: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let name = dict["name"] {
            self.name = (name as? String)
        }
        if let brand = dict["brand"] {
            self.brand = (brand as? String)
        }
        if let number = dict["number"] {
            self.number = (number as? String)
        }
        if let expiration = dict["expiration"] {
            self.expiration = (expiration as? String)
        }
        if let cvc = dict["cvc"] {
            self.cvc = (cvc as? String)
        }
    }
    
    public class func withID(id: String, callback: @escaping (_ pc: PaymentCard?)->Void){
        K.Database.ref().child("creditCards").child(id).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                callback(PaymentCard(dict: dict))
            } else {
                callback(nil)
            }
        })
    }
    
    public func prepareForSave() -> [String:AnyObject] {
        if self.uid != nil {
            original_dictionary["id"] = self.name as AnyObject
        }
        if self.name != nil {
            original_dictionary["name"] = self.name as AnyObject
        }
        if self.brand != nil {
            original_dictionary["brand"] = self.brand as AnyObject
        }
        if self.number != nil {
            original_dictionary["number"] = self.number as AnyObject
        }
        if self.expiration != nil {
            original_dictionary["expiration"] = self.expiration as AnyObject
        }
        if self.cvc != nil {
            original_dictionary["cvc"] = self.cvc as AnyObject
        }
        
        return original_dictionary
    }
    
    public func save() {
        let _ = self.prepareForSave()
        super.save(route: "creditCards")
    }
    
    var name: String?
    var brand: String?
    var number: String?
    var expiration: String?
    var cvc: String?
}
