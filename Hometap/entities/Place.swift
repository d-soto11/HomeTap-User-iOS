//
//  Place.swift
//  Hometap
//
//  Created by Daniel Soto on 7/14/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase

class Place: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let name = dict["nickname"] {
            self.name = (name as? String)
        }
        if let lat = dict["lat"] {
            self.lat = (lat as? Double)
        }
        if let long = dict["lng"] {
            self.lng = (long as? Double)
        }
        if let address = dict["address"] {
            self.address = (address as? String)
        }
        if let area = dict["area"] {
            self.area = (area as? Double)
        }
        if let pets = dict["hasPets"] {
            self.pets = (pets as? Bool)
        }
        if let wifi = dict["wifi"] {
            self.wifi = (wifi as? String)
        }
        if let rooms = dict["rooms"] {
            self.rooms = (rooms as? Int)
        }
        if let floors = dict["floors"] {
            self.floors = (floors as? Int)
        }
        if let interior = dict["interior"] {
            self.interior = (interior as? String)
        }
        if let tower = dict["tower"] {
            self.tower = (tower as? String)
        }
        if let bathrooms = dict["bathrooms"] {
            self.bathrooms = (bathrooms as? Int)
        }
        if let basement = dict["basement"] {
            self.basement = (basement as? Bool)
        }
        if let apartament = dict["isApartament"] {
            self.apartament = (apartament as? Bool)
        }
    }
    
    public class func withID(id: String, callback: @escaping (_ s: Place?)->Void){
        K.Database.ref().child("places").child(id).observe(DataEventType.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                callback(Place(dict: dict))
            } else {
                callback(nil)
            }
        })
    }
    
    public func prepareForSave() -> [String:AnyObject] {
        if self.uid != nil {
            original_dictionary["id"] = self.uid as AnyObject
        }
        if self.name != nil {
            original_dictionary["nickname"] = self.name as AnyObject
        }
        if self.lat != nil {
            original_dictionary["lat"] = self.lat as AnyObject
        }
        if self.lng != nil {
            original_dictionary["lng"] = self.lng as AnyObject
        }
        if self.address != nil {
            original_dictionary["address"] = self.address as AnyObject
        }
        if self.area != nil {
            original_dictionary["area"] = self.area as AnyObject
        }
        if self.pets != nil {
            original_dictionary["hasPets"] = self.pets as AnyObject
        }
        if self.wifi != nil {
            original_dictionary["wifi"] = self.wifi as AnyObject
        }
        if self.rooms != nil {
            original_dictionary["rooms"] = self.rooms as AnyObject
        }
        if self.floors != nil {
            original_dictionary["floors"] = self.floors as AnyObject
        } else {
            original_dictionary["floors"] = 1 as AnyObject
        }
        if self.bathrooms != nil {
            original_dictionary["bathrooms"] = self.bathrooms as AnyObject
        }
        if self.interior != nil {
            original_dictionary["interior"] = self.interior as AnyObject
        }
        if self.tower != nil {
            original_dictionary["tower"] = self.tower as AnyObject
        }
        if self.basement != nil {
            original_dictionary["basement"] = self.basement as AnyObject
        }
        if self.apartament != nil {
            original_dictionary["isApartament"] = self.apartament as AnyObject
        }
        
        original_dictionary["clientID"] = K.User.client?.uid as AnyObject
        
        return original_dictionary
    }
    
    public func save() {
        let _ = self.prepareForSave()
        super.save(route: "places")
    }
    
    public func saveService(service: Service) {
        if self.uid != nil && service.uid != nil {
            K.Database.ref().child("places").child(self.uid!).child("services").child(service.uid!).setValue(true)
        }
    }
    
    var name: String?
    var lat: Double?
    var lng: Double?
    var address: String?
    var area: Double?
    var pets: Bool?
    var wifi: String?
    var rooms: Int?
    var tower: String?
    var interior: String?
    var floors: Int?
    var bathrooms: Int?
    var basement: Bool?
    var apartament: Bool?
    
}
