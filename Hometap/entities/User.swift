//
//  User.swift
//  Hometap
//
//  Created by Daniel Soto on 7/13/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase

class User: HometapObject {
    
    public override init(dict: [String: AnyObject]){
        super.init(dict: dict)
        
        if let name = dict["name"] {
            self.name = (name as? String)
        }
        if let birth = dict["birth"] {
            self.birth = Date(fromString: birth as! String, withFormat: .Try)
        }
        if let joined = dict["joined"] {
            self.joined = Date(fromString: joined as! String, withFormat: .Try)
        }
        if let gender = dict["gender"] {
            self.gender = (gender as? Int)
        }
        if let provider = dict["provider"] {
            self.provider = provider
        }
        if let photo = dict["photo"] {
            self.photo = (photo as? String)
        }
        if let email = dict["email"] {
            self.email = (email as? String)
        }
        if let rating = dict["rating"] {
            self.rating = (rating as? Double)
        }
        if let phone = dict["phone"] {
            self.phone = (phone as? String)
        }
        if let votes = dict["votes"] {
            self.votes = (votes as? Int)
        }
    }
    
    public convenience init(user: Firebase.User) {
        var dict = ["name": user.displayName, "email":user.email, "id": user.uid]
        if let pp = user.photoURL {
            dict["photo"] = pp.absoluteString
        }
        self.init(dict: dict as [String : AnyObject])
    }
    
    override func save(route: String) {
        if (self.uid != getCurrentUserUid()) {
            return
        }        
        if self.name != nil {
            original_dictionary["name"] = self.name as AnyObject
        }
        if self.birth != nil {
            original_dictionary["birth"] = self.birth!.toString(format: .Default) as AnyObject
        }
        if self.joined != nil {
            original_dictionary["joined"] = self.joined!.toString(format: .Long) as AnyObject
        }
        if self.gender != nil {
            original_dictionary["gender"] = self.gender as AnyObject
        }
        if self.provider != nil {
            original_dictionary["provider"] = self.provider as AnyObject
        }
        if self.photo != nil {
            original_dictionary["photo"] = self.photo as AnyObject
        }
        if self.email != nil {
            original_dictionary["email"] = self.email as AnyObject
        }
        if self.rating != nil {
            original_dictionary["rating"] = self.rating as AnyObject
        }
        if self.phone != nil {
            original_dictionary["phone"] = self.phone as AnyObject
        }
        if self.votes != nil {
            original_dictionary["votes"] = self.votes as AnyObject
        }
        
        super.save(route: route)
    }
    
    var name: String?
    var birth: Date?
    var joined: Date?
    var gender: Int?
    var provider: AnyObject?
    var photo: String?
    var email: String?
    var rating: Double?
    var phone: String?
    var votes: Int?
    
    public func services_brief() -> [Service]? {
        var services_brief:[Service] = []
        if let srvc = original_dictionary["upcomingServices"] {
            if let srvcDict = srvc as? [String:AnyObject] {
                for (_, service) in srvcDict {
                    if let servDict = service as? [String:AnyObject] {
                        services_brief.append(Service(dict: servDict))
                    }
                }
                return services_brief
            }
        }
        return nil
    }
    
    public func services() -> [Service]? {
        var services_brief:[Service] = []
        if let srvc = original_dictionary["upcomingServices"] {
            if let srvcDict = srvc as? [String:AnyObject] {
                for (id_service, serv) in srvcDict {
                    if (id_service == "cache") {
                        let s = serv as! [String: AnyObject]
                        services_brief.append(Service(dict: s))
                    } else {
                        Service.withID(id: id_service, callback: {(service) in
                            if service != nil {
                                services_brief.append(service!)
                            }
                        })
                    }
                }
                return services_brief
            }
        }
        return nil
    }
    
    public func addCacheService(_ s: Service) {
        var upcoming = original_dictionary["upcomingServices"] as? [String:AnyObject] ?? [:]
        upcoming["cache"] = s.original_dictionary as AnyObject
        self.original_dictionary["upcomingServices"] = upcoming as AnyObject
    }
    
    public func history_brief() -> [Service]? {
        var history_brief:[Service] = []
        if let srvc = original_dictionary["pastServices"] {
            if let srvcDict = srvc as? [String:AnyObject] {
                for (_, service) in srvcDict {
                    if let servDict = service as? [String:AnyObject] {
                        history_brief.append(Service(dict: servDict))
                    }
                }
                return history_brief
            }
        }
        return nil
    }
    
    public func history() -> [Service]? {
        var history:[Service] = []
        if let srvc = original_dictionary["pastServices"] {
            if let srvcDict = srvc as? [String:AnyObject] {
                for (id_service, _) in srvcDict {
                    Service.withID(id: id_service, callback: {(service) in
                        if service != nil {
                            history.append(service!)
                        }
                    })
                }
                return history
            }
        }
        return nil
    }
    
    public func prepareForBriefSave() -> [String:AnyObject] {
        var brief: [String:AnyObject] = ["id":(self.uid! as AnyObject)]
        if self.name != nil {
            brief["name"] = self.name as AnyObject
        }
        if self.photo != nil {
            brief["photo"] = self.photo as AnyObject
        }
        if self.rating != nil {
            brief["rating"] = self.rating as AnyObject
        }
        return brief
    }
    
    public func comments(callback: @escaping (_ c: Comment?, _ total: Int)->Void){
        if let comms = original_dictionary["comments"] {
            if let commsDict = comms as? [String:AnyObject] {
                let total = commsDict.count
                for (id_comment, _) in commsDict {
                    Comment.withID(id: id_comment, callback: {(comment) in
                        callback(comment, total)
                    })
                }
            } else {
                callback(nil, 0)
            }
        } else {
            callback(nil, 0)
        }
    }
    
    public func notifications() -> [Notification]? {
        var notifications:[Notification] = []
        if let not = original_dictionary["notifications"] {
            if let notDict = not as? [String:AnyObject] {
                for (_, notification) in notDict {
                    if let notificationDict = notification as? [String:AnyObject] {
                        notifications.append(Notification(dict: notificationDict))
                    }
                }
                return notifications
            }
        }
        return nil
    }
    
    public func saveNotificationToken(token: String) {
        K.Database.ref().child("clients").child(self.uid!).child("tokens").child(token).setValue(true)
    }
    
    public func useCoupon(coupon: String) {
        K.Database.ref().child("clients").child(self.uid!).child("coupons").child(coupon).setValue(true)
    }
    
    public func clearNotifications() {
        original_dictionary.removeValue(forKey: "notifications")
        K.Database.ref().child("clients").child(self.uid!).child("notifications").removeValue()
    }
    
    public func checkUsedCoupon(coupon: String, callback: @escaping (Bool)->Void) {
        K.Database.ref().child("clients").child(self.uid!).child("coupons").child(coupon).observeSingleEvent(of: .value, with: { (snapshot) in
            callback(snapshot.exists())
        })
    }
    
}
