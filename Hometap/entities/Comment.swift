//
//  Comment.swift
//  Hometap
//
//  Created by Daniel Soto on 8/19/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase

class Comment: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let body = dict["body"] {
            self.body = (body as? String)
        }
        if let clientID = dict["clientID"] {
            self.clientID = (clientID as? String)
        }
        if let clientName = dict["clientName"] {
            self.clientName = (clientName as? String)
        }
        if let date = dict["date"] {
            self.date = Date(fromString: (date as! String), withFormat: .Try)
        }
        if let homieID = dict["homieID"] {
            self.homieID = (homieID as? String)
        }
        if let rating = dict["rating"] {
            self.rating = (rating as? Double)
        }
    }
    
    class func withID(id: String, callback: @escaping (_ s: Comment?)->Void){
        K.Database.ref().child("comments").child(id).observe(DataEventType.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                callback(Comment(dict: dict))
            } else {
                callback(nil)
            }
        })
    }
    
    public func save() {
        if self.body != nil {
            original_dictionary["body"] = self.body as AnyObject
        }
        if self.clientID != nil {
            original_dictionary["clientID"] = self.clientID as AnyObject
        }
        if self.clientName != nil {
            original_dictionary["clientName"] = self.clientName as AnyObject
        }
        if self.date != nil {
            original_dictionary["date"] = self.date?.toString(format: .Default) as AnyObject
        }
        if self.homieID != nil {
            original_dictionary["homieID"] = self.homieID as AnyObject
        }
        if self.rating != nil {
            original_dictionary["rating"] = self.rating as AnyObject
        }
        super.save(route: "comments")
    }
    
    var body: String?
    var clientID: String?
    var clientName: String?
    var date: Date?
    var homieID: String?
    var rating: Double?
    
}
