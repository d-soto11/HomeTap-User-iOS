//
//  Notification.swift
//  Hometap
//
//  Created by Daniel Soto on 9/7/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation

class Notification: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)

        if let type = dict["tipo"] {
            self.type = (type as? Int)
        }
    }
    
    var type: Int?
    
}
