//
//  MasterData.swift
//  Tully Dev
//
//  Created by macbook on 1/28/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation

class MasterData : NSObject{
    
    var id : String?
    var name : String?
    var parent_id : String?
    var type : String?
    var count : Int!
    var downloadUrl : String?
    var lyrics : String?
    var filename : String
    var bpm : Int
    var key : String
    
    init(id : String, name : String, parent_id : String, type : String, count : Int, downloadUrl : String, lyrics : String, filename : String, bpm : Int, key : String){
        self.id = id
        self.name = name
        self.parent_id = parent_id
        self.type = type
        self.count = count
        self.downloadUrl = downloadUrl
        self.lyrics = lyrics
        self.filename = filename
        self.bpm = bpm
        self.key = key
    }
    
}
