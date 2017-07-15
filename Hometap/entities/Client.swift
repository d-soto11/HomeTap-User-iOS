//
//  Client.swift
//  Hometap
//
//  Created by Daniel Soto on 7/13/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase

class Client: User {
    
    public override init(dict: [String: AnyObject]){
        super.init(dict: dict)
        
        if let preferences = dict["preferences"] {
            self.preferences = (preferences as? NSDictionary)
        }
        if let credits = dict["credits"] {
            self.credits = (credits as? Double)
        }
    }
    
    class func withID(id: String, callback: @escaping (_ s: Client)->Void){
        K.Database.ref!.child("clients").child(id).observe(FIRDataEventType.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                callback(Client(dict: dict))
            }
        })
    }
    
    public func save() -> Bool {
        if self.name != nil {
            original_dictionary["name"] = self.name as AnyObject
        }
        if self.birth != nil {
            original_dictionary["birth"] = self.birth!.toString(format: .Default) as AnyObject
        }
        if self.joined != nil {
            original_dictionary["joined"] = self.joined!.toString(format: .Long) as AnyObject
        }
        if self.gender != nil {
            original_dictionary["gender"] = self.gender as AnyObject
        }
        if self.provider != nil {
            original_dictionary["provider"] = self.provider as AnyObject
        }
        if self.photo != nil {
            original_dictionary["photo"] = self.photo as AnyObject
        }
        if self.email != nil {
            original_dictionary["email"] = self.email as AnyObject
        }
        if self.rating != nil {
            original_dictionary["rating"] = self.rating as AnyObject
        }
        if self.phone != nil {
            original_dictionary["phone"] = self.phone as AnyObject
        }
        if self.votes != nil {
            original_dictionary["votes"] = self.votes as AnyObject
        }
        
        super.save(route: "clients")
        
        return true
    }
    
    var preferences: NSDictionary?
    var credits: Double?
    
    public func places() -> [Place]? {
        var places:[Place] = []
        if let plcs = original_dictionary["places"] {
            if let plcsDict = plcs as? [String:AnyObject] {
                for (_, place) in plcsDict {
                    if let servDict = place as? [String:AnyObject] {
                        places.append(Place(dict: servDict))
                    }
                }
                return places
            }
        }
        return nil
    }
    
    public func favorites_brief() -> [Homie]? {
        var favorites_brief:[Homie] = []
        if let fvts = original_dictionary["favorites"] {
            if let fvtsDict = fvts as? [String:AnyObject] {
                for (_, fav) in fvtsDict {
                    if let favFict = fav as? [String:AnyObject] {
                        favorites_brief.append(Homie(dict: favFict))
                    }
                }
                return favorites_brief
            }
        }
        return nil
    }
    
    public func favorites() -> [Homie]? {
        var favorites:[Homie] = []
        if let srvc = original_dictionary["favorites"] {
            if let srvcDict = srvc as? [String:AnyObject] {
                for (id_homie, _) in srvcDict {
                    Homie.withID(id: id_homie, callback: {(homie) in
                        favorites.append(homie)
                    })
                }
                return favorites
            }
        }
        return nil
    }
}
