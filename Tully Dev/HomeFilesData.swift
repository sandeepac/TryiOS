//
//  PurchaseData.swift
//  Tully Dev
//
//  Created by Kathan on 19/03/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation

class HomeFilesData : NSObject{
    
    var uid : String?
    var audio_url : URL?
    var audio_name : String?
    var audio_size : String?
    var downloadURL : String?
    var local_file : Bool?
    var tid : String
    var type : String?
    var bpm : Int
    var key : String
    
    init(uid : String , audio_url : URL , audio_name : String , audio_size : String , downloadURL : String, local_file : Bool, tid : String, type : String, bpm : Int, key : String)
    {
        self.uid = uid
        self.audio_url = audio_url
        self.audio_name = audio_name
        self.audio_size = audio_size
        self.downloadURL = downloadURL
        self.local_file = local_file
        self.tid = tid
        self.type = type
        self.bpm = bpm
        self.key = key
    }
    
}

