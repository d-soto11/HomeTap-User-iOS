//
//  Homie.swift
//  Hometap
//
//  Created by Daniel Soto on 7/14/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase

class Homie: User {
    
    public override init(dict: [String: AnyObject]){
        super.init(dict: dict)
        
        if let preferences = dict["preferences"] {
            self.preferences = (preferences as? NSDictionary)
        }
        if let folder = dict["folder"] {
            self.folder = (folder as? String)
        }
    }
    
    class func withID(id: String, callback: @escaping (_ s: Homie)->Void){
        K.Database.ref!.child("homies").child(id).observe(FIRDataEventType.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                callback(Homie(dict: dict))
            }
        })
    }
    
    var preferences: NSDictionary?
    var folder: String?    
    
    public func schedule() -> HometapObject? {
        return nil
    }
    
    public func products() -> [Product] {
        return []
    }
    
}
