//
//  Calendar.swift
//  Hometap
//
//  Created by Daniel Soto on 7/14/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation

class HTCBlock: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let startHour = dict["initialTime"] {
            self.startHour = Date(fromString: startHour as! String, withFormat: .Custom("HH:mm"))
        }
        if let endHour = dict["finalTime"] {
            self.endHour = Date(fromString: endHour as! String, withFormat: .Custom("HH:mm"))
        }
        if let date = dict["date"] {
            self.date = Date(fromString: date as! String, withFormat: .Custom("YYYY-MM-dd"))
        }
        if let homie = dict["id"] {
            self.homieID = homie as? String
        }
    }
    
    var startHour: Date?
    var endHour: Date?
    var date: Date?
    var homieID: String?
    
    public func service(callback: @escaping (_:Service?)->Void) -> Bool{
        if let id_service = original_dictionary["serviceID"] as? String {
            Service.withID(id: id_service, callback: {(service) in
                callback(service)
            })
            return true
        }
        
        return false
    }
}
