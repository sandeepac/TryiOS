//
//  CollaborationFirebaseManager.swift
//  Tully Dev
//
//  Created by Apple on 17/10/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation
import Firebase

class CollaborationFirebaseManager {

    class func getInvitationsBucketValue(projectId: String, completion: @escaping ([[String : Any]]) -> Swift.Void) {
        
        let ref = FirebaseManager.getRefference().ref
        ref.child("collaborations").child(projectId).child("invitations").observe(.value, with: { (snapshot) in
            
            var invitationArray = [[String : Any]]()

            if snapshot.exists() {
                
                for task in snapshot.children {

                    guard let taskSnapshot = task as? DataSnapshot else {
                        continue
                    }
                    
                    var dict = taskSnapshot.value as! [String: Any]
                    dict["invitationId"] = taskSnapshot.key 
                        
                    invitationArray.append(dict)
                }
                
                completion(invitationArray)
            }
            else {
                
                completion(invitationArray)
            }
        })
    }
    
    class func getUserProfileData(userId: String, completion: @escaping ([String : Any]) -> Swift.Void) {
        
        let ref = FirebaseManager.getRefference().ref
        ref.child(userId).child("profile").observeSingleEvent(of:.value, with: { snapshot in
            
            var dict = [String : Any]()
            
            if snapshot.exists() {

                dict = (snapshot.value as? [String : Any])!
                
                completion(dict)
            }
            else {
                
                completion(dict)
            }
        })
    }
    
    class func deleteInvitationId(projectId: String, inviteId: String, completion: @escaping (Bool) -> Swift.Void) {
        
        let ref = Database.database().reference()
        let IdToDelete = ref.child("collaborations").child(projectId).child("invitations").child(inviteId)
        
        IdToDelete.removeValue { error, _ in
            //error in deleting projectId
            
            if error == nil {
                
                completion(true)
            }
        }

    }
    
    class func getCollaborationBucketDataByCollaborationId(projectId: String, collaborationId: String, completion: @escaping ([String : Any]) -> Swift.Void) {
        
        let ref = FirebaseManager.getRefference().ref
        ref.child("collaborations").child(projectId).child(collaborationId).observe(.value, with: { snapshot in
            
            var dict = [String : Any]()
            
            if snapshot.exists() {
                
                dict = (snapshot.value as? [String : Any])!
                
                completion(dict)
            }
            else {
                
                completion(dict)
            }
        })
    }
    
    class func getUserDataFromCollaborationBucketByCollaborationId(projectId: String, collaborationId: String, userId: String, completion: @escaping ([String : Any]) -> Swift.Void) {

        let ref = FirebaseManager.getRefference().ref
    ref.child("collaborations").child(projectId).child(collaborationId).child(userId).observeSingleEvent(of:.value, with: { snapshot in
            
            var dict = [String : Any]()
            
            if snapshot.exists() {
                
                dict = (snapshot.value as? [String : Any])!
                
                completion(dict)
            }
            else {
                
                completion(dict)
            }
        })
    }
}
