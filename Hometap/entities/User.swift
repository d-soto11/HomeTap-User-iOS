//
//  User.swift
//  Hometap
//
//  Created by Daniel Soto on 7/13/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation

class User: NSObject {
    
    public init(dict: [String: AnyObject]){
        if let uid = dict["id"] {
            self.uid = (uid as? String)
        }
        if let name = dict["name"] {
            self.name = (name as? String)
        }
        if let birth = dict["birth"] {
            self.birth = Date(fromString: birth as! String, withFormat: .Try)
        }
        if let joined = dict["joined"] {
            self.joined = Date(fromString: joined as! String, withFormat: .Try)
        }
        if let gender = dict["gender"] {
            self.gender = (gender as? Int)
        }
        if let provider = dict["provider"] {
            self.provider = provider
        }
        if let photo = dict["photo"] {
            self.photo = (photo as? String)
        }
        if let email = dict["email"] {
            self.email = (email as? String)
        }
        if let rating = dict["rating"] {
            self.rating = (rating as? Double)
        }
        if let phone = dict["phone"] {
            self.phone = (phone as? String)
        }
        if let votes = dict["votes"] {
            self.votes = (votes as? Int)
        }
    }
    
    var uid: String?
    var name: String?
    var birth: Date?
    var joined: Date?
    var gender: Int?
    var provider: AnyObject?
    var photo: String?
    var email: String?
    var rating: Double?
    var phone: String?
    var votes: Int?
    
}
