//
//  PendingInviteModel.swift
//  Tully Dev
//
//  Created by Prashant  on 09/10/18.
//  Copyright © 2018 Tully. All rights reserved.
//

class PendingInviteModel{
    var profile : String
    var name: String
    var emailId: String
    var status : String
    var userId : String
    var inviteId : String
    
    init(profile: String, name: String, emailId: String, status: String, userId: String, inviteId: String) {
        self.profile = profile
        self.name = name
        self.emailId = emailId
        self.status = status
        self.userId = userId
        self.inviteId = inviteId
    }
}
