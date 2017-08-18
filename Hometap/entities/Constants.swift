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

struct K {
    struct Test {
        static var test_val:Bool = true
        
        static func test_func() {
            _ = false
        }
        
    }
    
    struct Helper {
        static let fb_date_short_format:String = "dd-MM-yyyy"
        static let fb_date_format:String = "yyyy-MM-dd'T'HH:mmxxxxx"
        static let fb_date_medium_format:String = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        static let fb_long_date_format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSxxxxx"
        static let fb_time_format: String = "hh:mm a"
    }
    
    struct Database {
        public static func ref() -> DatabaseReference {
            return Firebase.Database.database().reference()
        }
        private static let storageURL: String = "gs://hometap-f173f.appspot.com/"
        public static func storageRef() -> StorageReference {
            return Storage.storage().reference(forURL: storageURL)
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

//func rand() -> UInt32{
//    let randomNumber = arc4random_uniform(9 - 0)
//    return randomNumber
//}

