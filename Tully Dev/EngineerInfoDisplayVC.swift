//
//  EngineerInfoDisplayVC.swift
//  Tully Dev
//
//  Created by Kathan on 30/08/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation
import Promise
import Firebase

class EngineerInfoDisplayVC {
    
    class func checkAllEngInfoDisplayDone(){
        if let homeBtn = UserDefaults.standard.value(forKey: MyConstants.tEngInfoHomeBtn) as? Bool, let homeDropDown = UserDefaults.standard.value(forKey: MyConstants.tEngInfoHomeDropdown) as? Bool, let infoSetting = UserDefaults.standard.value(forKey: MyConstants.tEngInfoSetting) as? Bool, let homePlusBtn = UserDefaults.standard.value(forKey: MyConstants.tEngInfoHomePlusBtn) as? Bool{
            if(homeBtn == true && homeDropDown == true && infoSetting == true && homePlusBtn == true){
                makeAllEngInfoDisplayDone()
            }
        }
    }
    
    
    class func makeAllEngInfoDisplayDone(){
        UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoAll)
        UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoHomeBtn)
        UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoHomeDropdown)
        UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoSetting)
        UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoHomePlusBtn)
    }
    
    class func checkMasterDataExists() -> Promise<Bool>{
        return Promise<Bool> { ( fulfill, reject) in
            
            if let uid = Auth.auth().currentUser?.uid{
                let userRef = FirebaseManager.getRefference().child(uid).ref
                userRef.child("masters").queryOrdered(byChild: "parent_id").queryEqual(toValue: "0").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists(){
                        makeAllEngInfoDisplayDone()
                        fulfill(true)
                    }else{
                        if let allDisplay = UserDefaults.standard.value(forKey: MyConstants.tEngInfoAll) as? Bool{
                            if(allDisplay){
                                fulfill(true)
                            }else{
                                fulfill(false)
                            }
                        }else{
                            fulfill(false)
                        }
                    }
                })
            }else{
                reject(NSError(domain: "Please Sign In", code: 400))
            }
        }
    }
    
}
