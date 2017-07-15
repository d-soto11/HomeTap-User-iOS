//
//  Constants.swift
//  Hometap
//
//  Created by Daniel Soto on 7/12/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import Foundation
import Firebase

struct K {
    struct Test {
        static var test_val:Bool = true
        
        static func test_func() {
            _ = false
        }
        
    }
    
    struct Helper {
        static let fb_date_format:String = "YYYY-MM-DDThh:mmTZD"
        static let fb_long_date_format: String = "YYYY-MM-DDThh:mm:ss.sTZD"
        static let fb_time_format: String = "hh:mm a"
    }
    
    struct Database {
        static var ref: FIRDatabaseReference? = nil
    }
    
    struct User {
        
        static let email:String = "email"
        static let materias:String = "materiasADictar"
        static let nombre:String = "nombre"
        static let photo:String = "foto"
        static let rating_cramer:String = "ratingCramer"
        static let rating_estudiante: String = "ratingEstudiante"
        static let saldo: String = "saldo"
        static let celular:String = "celular"
        
        static let default_ph: String = "default"
        
        static var loaded_user:[String:Any]?
        static var loaded_user_name_tmp:String?
        
        static func logged_user () -> FIRUser?{
            if let user = FIRAuth.auth()?.currentUser {
                // User is signed in.
                return user
            } else {
                // No user is signed in.
                return nil
            }
            
        }
    }
    
    struct Menu {
        static let inicio: Int = 1
        static let crames: Int = 2
        static let coins: Int = 3
        static let ajustes: Int = 4
        static let ayuda: Int = 5
    }
    
}

func getCurrentUserUid()->String?{
    return K.User.logged_user()?.uid
}

//func rand() -> UInt32{
//    let randomNumber = arc4random_uniform(9 - 0)
//    return randomNumber
//}

