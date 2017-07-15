//
//  Service.swift
//  Hometap
//
//  Created by Daniel Soto on 7/14/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase

class Service: HometapObject {
    public override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let date = dict["date"] {
            self.date = Date(fromString: date as! String, withFormat: .Try)
        }
        if let price = dict["price"] {
            self.price = (price as? Double)
        }
        if let state = dict["state"] {
            self.state = (state as? String)
        }
        if let comments = dict["comments"] {
            self.comments = (comments as? String)
        }
        if let place = dict["place"] {
            self.place = Place(dict: (place as? [String:AnyObject])!)
        }

    }
    
    class func withID(id: String, callback: @escaping (_ s: Service)->Void){
        K.Database.ref!.child("services").child(id).observe(FIRDataEventType.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                callback(Service(dict: dict))
            }
        })
    }
    
    var date: Date?
    var price: Double?
    var state: String?
    var comments: String?
    var place: Place?
    
    public func homie() -> Homie? {
        return nil
    }
    
    public func client() -> Client? {
        return nil
    }
    
    public func block() -> HometapObject? {
        return nil
    }
    
    public func additionalServices() -> [AdditionalService]? {
        var add_services:[AdditionalService] = []
        if let additionalServices = original_dictionary["additionalServices"] {
            if let addDict = additionalServices as? [String:AnyObject] {
                for (_, service) in addDict {
                    if let servDict = service as? [String:AnyObject] {
                        add_services.append(AdditionalService(dict: servDict))
                    }
                }
                return add_services
            }
            
        }
        
        return nil
    }
    
    public func products() -> [Product]? {
        var products:[Product] = []
        if let prod = original_dictionary["products"] {
            if let prodDict = prod as? [String:AnyObject] {
                for (_, product) in prodDict {
                    if let productDict = product as? [String:AnyObject] {
                        products.append(Product(dict: productDict))
                    }
                }
                return products
            }
            
        }
        
        return nil
    }

}
