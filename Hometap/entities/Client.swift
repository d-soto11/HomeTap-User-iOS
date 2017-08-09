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
    
    class func withID(id: String, callback: @escaping (_ s: Client?)->Void){
        K.Database.ref().child("clients").child(id).observe(DataEventType.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                callback(Client(dict: dict))
            } else {
                callback(nil)
            }
        })
    }
    
    public func save() {
        if self.preferences != nil {
            original_dictionary["preferences"] = self.preferences as AnyObject
        }
        if self.credits != nil {
            original_dictionary["credits"] = self.credits as AnyObject
        }
        super.save(route: "clients")
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
                        if homie != nil {
                            favorites.append(homie!)
                        }
                    })
                }
                return favorites
            }
        }
        return nil
    }
    
    public func savePlace(place: Place) {
        if place.uid == nil {
            place.uid = K.Database.ref().child("clients").child(self.uid!).child("places").childByAutoId().key
        }
        let plc_dict = place.prepareForSave()
        var org_places_dict:[String:[String:AnyObject]] = original_dictionary["places"] as? [String:[String:AnyObject]] ?? [:]
        org_places_dict[place.uid!] = plc_dict
        original_dictionary["places"] = org_places_dict as AnyObject
    }
    
    public func saveFavorite(favorite: Homie) -> Bool {
        if favorite.uid == nil {
            return false
        }
        let fav_dict = favorite.prepareForBriefSave()
        var org_fav_dict:[String:[String:AnyObject]] = original_dictionary["favorites"] as? [String:[String:AnyObject]] ?? [:]
        org_fav_dict[favorite.uid!] = fav_dict
        original_dictionary["favorites"] = org_fav_dict as AnyObject
        
        return true
    }
}
