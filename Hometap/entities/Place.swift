//
//  Place.swift
//  Hometap
//
//  Created by Daniel Soto on 7/14/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation

class Place: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let lat = dict["lat"] {
            self.lat = (lat as? Double)
        }
        if let long = dict["long"] {
            self.long = (long as? Double)
        }
        if let address = dict["address"] {
            self.address = (address as? String)
        }
        if let area = dict["area"] {
            self.area = (area as? Double)
        }
        if let pets = dict["pets"] {
            self.pets = (pets as? Bool)
        }
        if let wifi = dict["wifi"] {
            self.wifi = (wifi as? String)
        }
        if let rooms = dict["rooms"] {
            self.rooms = (rooms as? Int)
        }
        if let bathrooms = dict["bathrooms"] {
            self.bathrooms = (bathrooms as? Int)
        }
        if let basement = dict["basement"] {
            self.basement = (basement as? Bool)
        }
    }
    
    public func prepareForSave() -> [String:AnyObject] {
        if self.lat != nil {
            original_dictionary["lat"] = self.lat as AnyObject
        }
        if self.long != nil {
            original_dictionary["long"] = self.long as AnyObject
        }
        if self.address != nil {
            original_dictionary["address"] = self.address as AnyObject
        }
        if self.area != nil {
            original_dictionary["area"] = self.area as AnyObject
        }
        if self.pets != nil {
            original_dictionary["pets"] = self.pets as AnyObject
        }
        if self.wifi != nil {
            original_dictionary["wifi"] = self.wifi as AnyObject
        }
        if self.rooms != nil {
            original_dictionary["rooms"] = self.rooms as AnyObject
        }
        if self.bathrooms != nil {
            original_dictionary["bathrooms"] = self.bathrooms as AnyObject
        }
        if self.basement != nil {
            original_dictionary["basement"] = self.basement as AnyObject
        }
        
        return original_dictionary
    }
    
    var lat: Double?
    var long: Double?
    var address: String?
    var area: Double?
    var pets: Bool?
    var wifi: String?
    var rooms: Int?
    var bathrooms: Int?
    var basement: Bool?
    
}
