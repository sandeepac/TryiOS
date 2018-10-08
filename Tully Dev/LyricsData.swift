//
//  LyricsData.swift
//  Tully Dev
//
//  Created by Apple on 08/10/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation
import Foundation

class LyricsData: NSObject
{
   
    var is_active : Bool?
    var is_owner : Bool?
    var desc : String?
    
    
    
    init(is_active : Bool, is_owner : Bool, desc : String)
    {
        self.is_active = is_active
        self.is_owner = is_owner
        self.desc = desc
    }
}
