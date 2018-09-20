//
//  recordingListData.swift
//  Tully Dev
//
//  Created by macbook on 5/31/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit

class recordingListData : NSObject
{
    var name : String?
    var project_name : String?
    var project_key : String?
    var tid : String?
    var mykey : String?
    var local_file : Bool?
    var downloadURL : String?
    var volume : Float?
    var total_time : Int?
    var current_time : Int?
    var isPlaying : Bool
    var isCheck : Bool
    var isPause : Bool
    var flag : Bool
    var bpm : Int
    var key : String
    
    init(name:String , project_name: String , project_key : String , tid : String , mykey : String, local_file : Bool, downloadURL : String, volume : Float, bpm : Int, key : String)
    {
        self.name = name
        self.project_name = project_name
        self.project_key = project_key
        self.tid = tid
        self.mykey = mykey
        self.local_file = local_file
        self.downloadURL = downloadURL
        self.volume = volume
        self.total_time = 0
        self.current_time = 0
        self.isPlaying = false
        self.isCheck = false
        self.isPause = false
        self.flag = false
        self.bpm = bpm
        self.key = key
    }
}
