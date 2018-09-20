//
//  playData.swift
//  Tully Dev
//
//  Created by macbook on 6/23/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import Foundation

class playData : NSObject
{
    var audio_key : String
    
    var audio_url : URL?
    var audio_name : String?
    var audio_size : String?
    var downloadURL : String?
    var local_file : Bool?
    var tid : String
    var bpm : Int
    var key : String
    
    init(audio_key : String, audio_url : URL , audio_name : String , audio_size : String , downloadURL : String, local_file : Bool, tid : String, bpm : Int, key : String)
    {
        self.audio_key = audio_key
        self.audio_url = audio_url
        self.audio_name = audio_name
        self.audio_size = audio_size
        self.downloadURL = downloadURL
        self.local_file = local_file
        self.tid = tid
        self.bpm = bpm
        self.key = key
    }
    
}
