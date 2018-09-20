//
//  section.swift
//  Tully Dev
//
//  Created by macbook on 1/7/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation

struct section{
    var cate_id : String
    var cate_name : String
    var recording_list : [recordingListData]
    var expanded : Bool
    var is_project : Bool
    var sort_key : String?
    
    init(cate_id : String, cate_name: String, recording_list : [recordingListData], expanded: Bool, is_project : Bool, sort_key : String)
    {
        self.cate_id = cate_id
        self.cate_name = cate_name
        self.recording_list = recording_list
        self.expanded = expanded
        self.is_project = is_project
        self.sort_key = sort_key
    }
    
}
