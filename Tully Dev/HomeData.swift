//
//  HomeData.swift
//  Tully Dev
//
//  Created by macbook on 7/6/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import Foundation

class HomeData: NSObject
{
    var type : String?
    var myId : String?
    var nm : String?
    var my_img : String?
    var sdesc : String?
    var local_file : Bool?
    var download_url : String?
    var audioName : String?
    
    init(type : String, myId : String, nm : String, my_img : String, sdesc : String, local_file : Bool, download_url : String, audioName : String)
    {
        self.type = type
        self.myId = myId
        self.nm = nm
        self.my_img = my_img
        self.sdesc = sdesc
        self.local_file = local_file
        self.download_url = download_url
        self.audioName = audioName
    }
}
