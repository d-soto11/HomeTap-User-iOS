//
//  AdditionalServices.swift
//  Hometap
//
//  Created by Daniel Soto on 7/14/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation

class AdditionalService: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let price = dict["price"] {
            self.price = (price as? Double)
        }
        if let descriptionH = dict["description"] {
            self.descriptionH = (descriptionH as? String)
        }
        if let icon = dict["icon"] {
            self.icon = (icon as? String)
        }
    }
    
    var price: Double?
    var descriptionH: String?
    var icon: String?
    
    public func prepareForSave() -> [String:AnyObject] {
        if self.price != nil {
            original_dictionary["price"] = self.price as AnyObject
        }
        if self.descriptionH != nil {
            original_dictionary["description"] = self.descriptionH as AnyObject
        }
        if self.icon != nil {
            original_dictionary["icon"] = self.icon as AnyObject
        }
        return original_dictionary
    }

}
