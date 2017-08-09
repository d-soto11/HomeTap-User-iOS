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
        if let date = dict["briefDate"] {
            self.date = Date(fromString: date as! String, withFormat: .Try)
        }
        if let price = dict["price"] {
            self.price = (price as? Double)
        }
        if let price = dict["briefPrice"] {
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
        if let id = dict["idService"] {
            self.uid = (id as? String)
        }
        if let briefName = dict["briefName"] {
            self.briefName = (briefName as? String)
        }
        if let briefRating = dict["briefRating"] {
            self.briefRating = (briefRating as? Double)
        }
        if let briefPhoto = dict["briefPhoto"] {
            self.briefPhoto = (briefPhoto as? String)
        }

    }
    
    class func withID(id: String, callback: @escaping (_ s: Service?)->Void){
        K.Database.ref().child("services").child(id).observe(DataEventType.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                callback(Service(dict: dict))
            } else {
                callback(nil)
            }
        })
    }
    
    public func save() {
        if self.date != nil {
            original_dictionary["date"] = self.date!.toString(format: .Default) as AnyObject
        }
        if self.price != nil {
            original_dictionary["price"] = self.price as AnyObject
        }
        if self.state != nil {
            original_dictionary["state"] = self.state as AnyObject
        }
        if self.comments != nil {
            original_dictionary["comments"] = self.comments as AnyObject
        }
        super.save(route: "clients")
    }
    
    var date: Date?
    var price: Double?
    var state: String?
    var comments: String?
    var briefName: String?
    var briefRating: Double?
    var briefPhoto: String?
    
    var place: Place?
    
    public func homie(callback: @escaping (_:Homie?)->Void) -> Bool {
        if let id = original_dictionary["homieID"] as? String{
            Homie.withID(id: id, callback: callback)
            return true
        }
        return false
    }
    
    public func client(callback: @escaping (_:Client?)->Void) -> Bool {
        if let id = original_dictionary["clientID"] as? String{
            Client.withID(id: id, callback: callback)
            return true
        }
        return false
    }
    
    public func block() -> HTCBlock? {
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
    
    public func saveClientHomie(client: Client, homie: Homie) -> Bool {
        if let idH = homie.uid, let idC = client.uid {
            original_dictionary["clientID"] = idC as AnyObject
            original_dictionary["homieID"] = idH as AnyObject
            return true
        } else {
            return false
        }
    }
    
    public func saveAdditionalServices(services: [AdditionalService]) {
        var services_array:[[String:AnyObject]] = []
        for service in services {
            services_array.append(service.prepareForSave())
        }
        original_dictionary["places"] = services_array as AnyObject
    }

}
