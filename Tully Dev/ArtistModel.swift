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
    var colorCode: String
    var userId: String
    var inviteId: String
    var status: String
    
    init(profile: String, name: String, emailId: String, colorCode: String, userId: String, inviteId: String, status: String) {
        self.profile = profile
        self.name = name
        self.emailId = emailId
        self.colorCode = colorCode
        self.userId = userId
        self.inviteId = inviteId
        self.status = status
    }
}
