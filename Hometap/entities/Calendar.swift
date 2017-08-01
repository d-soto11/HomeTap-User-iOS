//
//  Calendar.swift
//  Hometap
//
//  Created by Daniel Soto on 7/14/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation

class HTCalendar: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let start = dict["startDate"] {
            self.start = Date(fromString: start as! String, withFormat: .Try)
        }
        if let end = dict["end"] {
            self.end = Date(fromString: end as! String, withFormat: .Try)
        }
    }
    
    var start: Date?
    var end: Date?
    
    public func days() -> [HTCDay]? {
        var days:[HTCDay] = []
        if let ds = original_dictionary["days"] {
            if let dsDict = ds as? [String:AnyObject] {
                for (_, day) in dsDict {
                    if let dayDict = day as? [String:AnyObject] {
                        days.append(HTCDay(dict: dayDict))
                    }
                }
                return days
            }
        }
        return nil
    }
}

class HTCDay: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let date = dict["date"] {
            self.date = Date(fromString: date as! String, withFormat: .Try)
        }
        if let available = dict["available"] {
            self.available = (available as? Bool)
        }
    }
    
    var date: Date?
    var available: Bool?
    
    public func blocks() -> [HTCBlock]? {
        var blocks:[HTCBlock] = []
        if let bcks = original_dictionary["blocks"] {
            if let bcksDict = bcks as? [String:AnyObject] {
                for (_, block) in bcksDict {
                    if let blockDict = block as? [String:AnyObject] {
                        blocks.append(HTCBlock(dict: blockDict))
                    }
                }
                return blocks
            }
        }
        return nil
    }
}

class HTCBlock: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let startHour = dict["startHour"] {
            self.startHour = Date(fromString: startHour as! String, withFormat: .Time)
        }
        if let endHour = dict["endHour"] {
            self.endHour = Date(fromString: endHour as! String, withFormat: .Time)
        }
    }
    
    var startHour: Date?
    var endHour: Date?
    
    public func service(callback: @escaping (_:Service?)->Void){
        if let id_service = original_dictionary["serviceID"] as? String {
            Service.withID(id: id_service, callback: {(service) in
                callback(service)
            })
        }
    }
}
