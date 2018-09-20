//
//  ParentData.swift
//  Tully Dev
//
//  Created by macbook on 1/31/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation

class ParentData : NSObject{
    
    var id : String?
    var count : Int?
    
    init(id : String, count : Int){
        self.id = id
        self.count = count
    }
    
}
