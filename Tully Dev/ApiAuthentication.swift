//
//  ApiAuthentication.swift
//  Tully Dev
//
//  Created by Kathan on 12/06/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation
import Firebase
import Promise

class ApiAuthentication : NSObject
{
    
    class func get_authentication_token() -> Promise<String> {
        return Promise<String> { (fulfill, reject) in
            
            var generate_code = false
            let val = UserDefaults.standard.object(forKey: MyConstants.api_security_code)
            if val != nil {
                if let mytimestamp : Int64 = UserDefaults.standard.object(forKey: MyConstants.api_security_time) as? Int64{
                    let current_timestamp = Int64(NSDate().timeIntervalSince1970)
                    let diff = (current_timestamp - (mytimestamp))
                    let minutes = (diff) / 60
                    if(minutes > 56){
                        generate_code = true
                    }
                }
            }else{
                generate_code = true
            }
            
            if(generate_code == true){
                if Auth.auth().currentUser?.uid != nil{
                    Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                        if error == nil {
                            UserDefaults.standard.set(idToken!, forKey: MyConstants.api_security_code)
                            let timestamp = Int64(NSDate().timeIntervalSince1970)
                            UserDefaults.standard.set(timestamp, forKey: MyConstants.api_security_time)
                            fulfill(idToken!)
                        }else{
                            reject(error!)
                        }
                    })
                }else{
                    reject(NSError(domain: "No Data Found", code: 400))
                }
            }else{
                fulfill(val as! String)
            }
            
        }
    }
    
    static func get_authentication_token1(callback: @escaping (String) -> Void){
        var generate_code = false
        let val = UserDefaults.standard.object(forKey: MyConstants.api_security_code)
        if val != nil {
            if let mytimestamp : Int64 = UserDefaults.standard.object(forKey: MyConstants.api_security_time) as? Int64{
                let current_timestamp = Int64(NSDate().timeIntervalSince1970)
                let diff = (current_timestamp - (mytimestamp))
                let minutes = (diff) / 60
                if(minutes > 56){
                    generate_code = true
                }
            }
        }else{
            generate_code = true
        }
        
        if(generate_code == true){
            if Auth.auth().currentUser?.uid != nil{
                Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                    if error == nil {
                        UserDefaults.standard.set(idToken!, forKey: MyConstants.api_security_code)
                        let timestamp = Int64(NSDate().timeIntervalSince1970)
                        UserDefaults.standard.set(timestamp, forKey: MyConstants.api_security_time)
                        // return idToken
                        callback(idToken!)
                    }
                })
            }
        }else{
            callback(val as! String)
        }
    }
}
