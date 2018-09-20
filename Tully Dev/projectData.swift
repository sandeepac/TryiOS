//
//  projectData.swift
//  Tully Dev
//
//  Created by macbook on 7/16/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import Foundation

class projectData: NSObject
{
    var myId : String?
    var nm : String?
    init(myId : String, nm : String)
    {
        self.myId = myId
        self.nm = nm
    }
}
