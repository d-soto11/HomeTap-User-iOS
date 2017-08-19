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
    
    class func withID(id: String, callback: @escaping (_ s: Homie?)->Void){
        K.Database.ref().child("homies").child(id).observe(DataEventType.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                callback(Homie(dict: dict))
            } else {
                callback(nil)
            }
        })
    }
    
    public func save() {
        if self.preferences != nil {
            original_dictionary["preferences"] = self.preferences as AnyObject
        }
        if self.folder != nil {
            original_dictionary["folder"] = self.folder as AnyObject
        }
        
        super.save(route: "homies")
    }
    
    var preferences: NSDictionary?
    var folder: String?    
    
    public func schedule() -> [HTCBlock]? {
        return nil
    }
    
    public func products() -> [Product] {
        return []
    }
    
    public func comments() -> [Comment]? {
        var comments:[Comment] = []
        if let comms = original_dictionary["comments"] {
            if let commsDict = comms as? [String:AnyObject] {
                for (id_comment, _) in commsDict {
                    Comment.withID(id: id_comment, callback: {(comment) in
                        if comment != nil {
                            comments.append(comment!)
                        }
                    })
                }
                return comments
            }
        }
        return nil
    }
    
}
