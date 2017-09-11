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
        K.Database.ref().child("clients").child(id).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
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
    
    public func places(callback: @escaping (_ p: Place?, _ total: Int)->Void){
        if let plcs = original_dictionary["places"] {
            if let plcsDict = plcs as? [String:AnyObject] {
                let total = plcsDict.count
                for (idPlace, place) in plcsDict {
                    if let place = place as? Bool {
                        if place {
                            Place.withID(id: idPlace, callback: {(place_loaded) in
                                callback(place_loaded, total)
                            })
                        }
                        
                    }
                }
            }
        } else {
            callback(nil, 0)
        }
    }
    
    public func payments(callback: @escaping (_ p: PaymentCard?, _ total: Int)->Void){
        if let tokens = original_dictionary["creditCardTokens"] {
            if let tokensDict = tokens as? [String:AnyObject] {
                let total = tokensDict.count
                for (token, tk) in tokensDict {
                    if let exists = tk as? Bool {
                        if exists {
                            PaymentCard.withID(id: token, callback: {(payment_card) in
                                callback(payment_card, total)
                            })
                        }
                        
                    }
                }
            }
        } else {
            callback(nil, 0)
        }
    }
    
    public func favorites() -> [Homie]? {
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
    
    public func savePlace(place: Place) {
        K.Database.ref().child("clients").child(self.uid!).child("places").child(place.uid!).setValue(true)
    }
    
    public func removePlace(place: Place) {
        K.Database.ref().child("clients").child(self.uid!).child("places").child(place.uid!).removeValue()
    }
    
    public func savePayment(payment: PaymentCard) {
        K.Database.ref().child("clients").child(self.uid!).child("creditCardTokens").child(payment.uid!).setValue(true)
    }
    
    public func removePayment(payment: PaymentCard) {
        K.Database.ref().child("clients").child(self.uid!).child("creditCardTokens").child(payment.uid!).removeValue()
    }
    
    public func saveFavorite(favorite: Homie) -> Bool {
        if favorite.uid == nil {
            return false
        }
        let fav_dict = favorite.prepareForBriefSave()
        var org_fav_dict:[String:AnyObject] = original_dictionary["favorites"] as? [String:AnyObject] ?? [:]
        org_fav_dict[favorite.uid!] = fav_dict as AnyObject
        original_dictionary["favorites"] = org_fav_dict as AnyObject
        
        return true
    }
}
