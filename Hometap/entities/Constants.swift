//
//  Constants.swift
//  Hometap
//
//  Created by Daniel Soto on 7/12/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase
import JModalController
import ReachabilitySwift

struct K {
    struct Network {
        static var network_available:Bool = true
        static var reachability = Reachability()!
        
        static public func startNetworkUpdates() {
            reachability.whenReachable = { reachability in
                network_available = true
                DispatchQueue.main.async {
                    K.MaterialTapBar.TapBar?.hideSnack()
                }
            }
            reachability.whenUnreachable = { reachability in
                network_available = false
                DispatchQueue.main.async {
                    K.MaterialTapBar.TapBar?.showSnack(message: "Estás en modo sin conexión", permanent: true)
                }
            }
            do {
                try reachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        }
        
    }
    
    struct Helper {
        static let fb_date_short_format:String = "dd-MM-yyyy"
        static let fb_date_format:String = "yyyy-MM-dd'T'HH:mmxxxxx"
        static let fb_date_medium_format:String = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        static let fb_long_date_format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSxxxxx"
        static let fb_time_format: String = "hh:mm a"
    }
    
    struct Hometap {
        static var app_content: AppContent?
        static let google_api_key:String = "AIzaSyDgKHIWf3dix_-npP89ww2SwVSutrwbeWo"
        static let stripe_key:String = "pk_test_0SmAvWdAgsSUtTqj0GMaNrZ2"
        static var callcenter: String = "3017303973"
        static let new_relic_key: String = "AA2dc717c812802b662ee25a6ae127325c597abfb3"
        
        static func call() {
            guard let url = URL(string: "tel://\(K.Hometap.callcenter)") else { return }
            print("calling...")
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
                
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    struct Database {
        public static func ref() -> DatabaseReference {
            return Firebase.Database.database().reference()
        }
        private static let storageURL: String = "gs://hometap-f173f.appspot.com/"
        public static func storageRef() -> StorageReference {
            return Storage.storage().reference(forURL: storageURL)
        }
        struct Local {
            private static var data_cache: [String:Data] = [:]
            private static var model_cache: [String: AnyObject] = [:]
            
            public static func save(id: String, data: Data) {
                data_cache[id] = data
            }
            
            public static func getCache(_ id: String) -> Data? {
                return data_cache[id]
            }
            
            public static func saveModel(id: String, object: AnyObject) {
                model_cache[id] = object
            }
            
            public static func getModel(_ id: String) -> AnyObject? {
                return model_cache[id]
            }
            
            public static func clearModel(_ id: String) {
                model_cache.removeValue(forKey: id)
            }
        }
    }
    
    struct UI {
        static let main_color: UIColor = UIColor(netHex: 0xbad041)
        static let alert_color: UIColor = UIColor(netHex: 0xf94f4f)
        static let second_color: UIColor = UIColor(netHex: 0xffda29)
        static let tab_color: UIColor = UIColor(netHex: 0xcccccc)
        static let history_color: UIColor = UIColor(netHex: 0x808080)
        static let booking_color: UIColor = UIColor(netHex: 0xb8b8b8)
        static let form_color: UIColor = UIColor(netHex: 0x8d8d8d)
        static let select_box_color: UIColor = UIColor(netHex: 0xe5e5e5)
        static let round_px: CGFloat = 20.0
        static let special_round_px: CGFloat = 15.0
        static let light_round_px: CGFloat = 5.0
    }
    
    struct User {
        static let default_ph: String = "https://firebasestorage.googleapis.com/v0/b/hometap-f173f.appspot.com/o/app_content%2Ficon_no_photo.png?alt=media&token=86491cbb-7c44-455d-bc4d-39ff8da3fc54"
        
        static var client:Client?
        static let savingKey: String = "client_saved"
        
        public static func addCacheService(_ s: Service) {
            let _ = s.homie { (h) in
                s.briefName = h?.name ?? "Nuevo servicio"
                s.briefRating = h?.rating ?? 5
                s.briefPhoto = h?.photo ?? ""
                if var cache = K.Database.Local.getModel("cacheUpcomming") as? [Service] {
                    cache.append(s)
                    K.Database.Local.saveModel(id: "cacheUpcomming", object: cache as AnyObject)
                } else {
                    let cache = [s]
                    K.Database.Local.saveModel(id: "cacheUpcomming", object: cache as AnyObject)
                }

            }
        }
        
        public static func loadCachedServices() {
            if let cache = K.Database.Local.getModel("cacheUpcomming") as? [Service] {
                client?.cachedServices = cache
            } else {
                client?.cachedServices = []
            }
        }
        
        public static func clearCachedServices() {
            K.Database.Local.clearModel("cacheUpcomming")
        }
        
        static func reloadClient() {
            if client != nil {
                Client.withID(id: client!.uid!, callback: { (c) in
                    K.User.client = c
                })
            }
        }
        
        static func checkNotifications() {
            if var pending = K.User.client?.notifications() {
                for notification in pending {
                    switch notification.type! {
                    case 1:
                        Service.withID(id: notification.uid!, callback: { (service) in
                            if service != nil {
                                ServiceRatingViewController.rateService(service: service!, parent: K.MaterialTapBar.TapBar!, callback: {
                                    HTAlertViewController.showHTAlert(title: "¿Deseas agendar un servicio con las mismas especificaciones?", body: "", accpetTitle: "¡Claro que sí!", cancelTitle: "Más tarde", confirmation: {
                                        BookingViewController.show(parent: K.MaterialTapBar.TapBar!.currentViewController()!, old: service)
                                    }, cancelation: {
                                        pending.remove(object: notification)
                                        if pending.isEmpty {
                                            K.User.client?.clearNotifications()
                                            K.MaterialTapBar.TapBar?.reloadViewController()
                                        }
                                    }, parent: K.MaterialTapBar.TapBar!)
                                    
                                })
                            }
                        })
                    default:
                        break
                    }
                    
                }
                K.User.client?.clearNotifications()
            }
        }
        
        static func logged_user () -> Firebase.User?{
            return Auth.auth().currentUser
        }
    }
    
    struct MaterialTapBar {
        static var TapBar: MaterialTabBarViewController?
    }
    
}

func getCurrentUserUid()->String?{
    return K.User.client?.uid
}
