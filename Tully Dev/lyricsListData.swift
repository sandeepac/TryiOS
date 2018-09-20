//
//  lyricsListData.swift
//  Tully Dev
//
//  Created by macbook on 6/5/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import Foundation

class lyricsListData : NSObject
{
    var project : String?
    var desc : String?
    var lyrics_key : String?
    var project_key : String?
    var sort_key : String?
    
    init(project:String , desc : String , lyrics_key : String, project_key: String, sort_key : String)
    {
        self.project = project
        self.desc = desc
        self.lyrics_key = lyrics_key
        self.project_key = project_key
        self.sort_key = sort_key
    }
}
