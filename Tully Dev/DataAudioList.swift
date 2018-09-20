//
//  DataAudioList.swift
//  Tully Dev
//
//  Created by Mili Shah on 07/02/18.
//  Copyright © 2018 Mili Shah. All rights reserved.
//

import Foundation

class DataAudioList
{
    var id : String?
    var name : String?
    var price : String?
    var track : String?
    var producer_name : String?
    var email : String?
    var size : String?
    var type : String?
    var genre : String?
 
    init(id : String?, name : String?, price : String?, track : String?, producer_name : String?, email : String?, size : String, type : String?, genre : String) {
        self.id = id
        self.name = name
        self.price = price
        self.track = track
        self.producer_name = producer_name
        self.email = email
        self.size = size
        self.type = type
        self.genre = genre
    }
}

