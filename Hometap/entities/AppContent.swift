//
//  AppContent.swift
//  Hometap
//
//  Created by Daniel Soto on 8/18/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase

class AppContent: NSObject {
    
    public class func loadAppContent(callback: @escaping () -> Void) {
        K.Database.ref().child("appContent").observe(.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                K.Hometap.app_content = AppContent(dict: dict)
                callback()
            }
        })
    }
    
    public init(dict: [String: AnyObject]){
        self.original_dictionary = dict
    }
    var original_dictionary: [String: AnyObject]
    
    public func basic() -> HTBasicService? {
        if let srvc = original_dictionary["services"] {
            if let srvcDict = srvc as? [String:AnyObject] {
                if let basic = srvcDict["basic"] as? [String: AnyObject] {
                    return HTBasicService(dict: basic)
                }
            }
        }
        return nil
    }
    
    public func services() -> [HTAditionalService]? {
        var services_brief:[HTAditionalService] = []
        if let srvc = original_dictionary["services"] {
            if let srvcDict = srvc as? [String:AnyObject] {
                if let add = srvcDict["additional"] as? [String: AnyObject] {
                    for (_, service) in add {
                        if let servDict = service as? [String:AnyObject] {
                            services_brief.append(HTAditionalService(dict: servDict))
                        }
                    }
                    return services_brief
                }
            }
        }
        return nil
    }
    
    public class HTAditionalService: NSObject {
        public init(dict: [String: AnyObject]){
            if let name = dict["name"] {
                self.name = (name as? String)
            }
            if let icon = dict["icon"] {
                self.icon = (icon as? String)
            }
            if let id = dict["id"] {
                self.id = (id as? String)
            }
            if let price = dict["price"] {
                self.price = (price as? Double)
            }
            if let time = dict["time"] {
                self.time = (time as? Int)
            }
        }
        var icon: String?
        var id: String?
        var name: String?
        var price: Double?
        var time: Int?
    }
    public class HTBasicService: NSObject {
        public init(dict: [String: AnyObject]){
            if let price = dict["price"] {
                self.price = (price as? Double)
            }
            if let time = dict["time"] {
                self.time = (time as? Int)
            }
        }
        var price: Double?
        var time: Int?
    }
}
