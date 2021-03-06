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
            self.state = (state as? Int)
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
        if let time = dict["time"] {
            self.time = (time as? Int)
        }
        if let block = dict["blockID"] {
            self.blockID = (block as? String)
        }
        if let tk = dict["paymentToken"] {
            self.token = (tk as? String)
        }
        if let rating = dict["rating"] {
            self.rating = (rating as? Double)
        }
        if let client = dict["clientID"] {
            self.clientID = (client as? String)
        }
        if let homie = dict["homieID"] {
            self.homieID = (homie as? String)
        }

    }
    
    class func withID(id: String, callback: @escaping (_ s: Service?)->Void){
        K.Database.ref().child("services").child(id).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
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
        if self.time != nil {
            original_dictionary["time"] = self.time as AnyObject
        }
        if self.blockID != nil {
            original_dictionary["blockID"] = self.blockID as AnyObject
        }
        if self.place != nil {
            original_dictionary["place"] = self.place?.prepareForSave() as AnyObject
        }
        if self.token != nil {
            original_dictionary["paymentToken"] = self.token as AnyObject
        }
        if self.rating != nil {
            original_dictionary["rating"] = self.rating as AnyObject
        }
        if self.homieID != nil {
            original_dictionary["homieID"] = self.homieID as AnyObject
        }
        if self.clientID != nil {
            original_dictionary["clientID"] = self.clientID as AnyObject
        }
        super.save(route: "services")
        self.place?.saveService(service: self)
    }
    
    var date: Date?
    var price: Double?
    var state: Int?
    var comments: String?
    var briefName: String?
    var briefRating: Double?
    var briefPhoto: String?
    var time: Int?
    var blockID: String?
    var token: String?
    
    var place: Place?
    var rating: Double?
    var clientID: String?
    var homieID: String?
    
    public func homie(callback: @escaping (_:Homie?)->Void) -> Bool {
        if let id = homieID{
            Homie.withID(id: id, callback: callback)
            return true
        }
        return false
    }
    
    public func client(callback: @escaping (_:Client?)->Void) -> Bool {
        if let id = clientID{
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
            if let addArray = additionalServices as? [[String:AnyObject]] {
                for service in addArray {
                    add_services.append(AdditionalService(dict: service))
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
            self.clientID = idC
            self.homieID = idH
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
        original_dictionary["additionalServices"] = services_array as AnyObject
    }

}
