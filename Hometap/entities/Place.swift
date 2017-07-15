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
