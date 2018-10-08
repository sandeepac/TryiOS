//
//  ArtistModel.swift
//  Tully Dev
//
//  Created by Prashant  on 01/10/18.
//  Copyright © 2018 Tully. All rights reserved.
//

class ArtistsModel{
    var profile : String
    var name: String
    var emailId: String
    init(profile: String, name: String, emailId: String) {
        self.profile = profile
        self.name = name
        self.emailId = emailId
    }
}
