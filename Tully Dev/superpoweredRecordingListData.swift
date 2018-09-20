//
//  superpoweredRecordingListData.swift
//  Tully Dev
//
//  Created by Kathan on 27/07/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

class superpoweredRecordingListData : NSObject
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
    var left_scrubber_value : Float
    var right_scrubber_value : Float
    
    init(name:String , project_name: String , project_key : String , tid : String , mykey : String, local_file : Bool, downloadURL : String, volume : Float)
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
        self.left_scrubber_value = 0.0
        self.right_scrubber_value = 100.0
        
    }
}
