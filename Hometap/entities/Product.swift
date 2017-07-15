//
//  Product.swift
//  Hometap
//
//  Created by Daniel Soto on 7/14/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation

class Product: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let name = dict["name"] {
            self.name = (name as? Double)
        }
        if let quantity = dict["quantity"] {
            self.quantity = (quantity as? Double)
        }
    }
    
    var name: Double?
    var quantity: Double?
}
