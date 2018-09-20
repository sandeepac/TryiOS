//
//  EngineerListData.swift
//  Tully Dev
//
//  Created by macbook on 1/22/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation

class EngineerListData : NSObject
{
    var uid : String?
    var email : String?
    init(uid : String, email : String){
        self.uid = uid
        self.email = email
    }
}
