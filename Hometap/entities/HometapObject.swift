//
//  HometapObject.swift
//  Hometap
//
//  Created by Daniel Soto on 7/14/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase

class HometapObject: NSObject {
    
    public init(dict: [String: AnyObject]){
        original_dictionary = dict
        
        if let uid = dict["id"] {
            self.uid = (uid as? String)!
        }
        
    }
    
    public func save(route: String) {
        if uid == nil {
            let saving_ref = K.Database.ref().child(route).childByAutoId()
            saving_ref.setValue(original_dictionary)
            uid = saving_ref.key
        } else {
            K.Database.ref().child(route).child(uid!).setValue(original_dictionary)
        }
    }
    
    var original_dictionary: [String:AnyObject]
    var uid: String?
    
}
