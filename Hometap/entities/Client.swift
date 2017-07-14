//
//  Client.swift
//  Hometap
//
//  Created by Daniel Soto on 7/13/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation

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
    
    var preferences: NSDictionary?
    var credits: Double?
    
    public func services() -> [AnyObject] {
        return []
    }
    
    public func places() -> [AnyObject] {
        return []
    }
    
    public func favorites() -> [AnyObject] {
        return []
    }
}
