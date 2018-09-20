//
//  Manager.swift
//  Tully Dev
//
//  Created by macbook on 5/21/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase

class FirebaseManager : NSObject
{
    static var db : Database? = nil
    static var databaseRef : DatabaseReference? = nil
    
    static func getDatabase() -> Database{
        if (db == nil){
            db = Database.database()
            if (!db!.isPersistenceEnabled){
                db!.isPersistenceEnabled = true
            }
        }
        return db!;
    }
    
    static func getRefference() -> DatabaseReference{
        if (databaseRef == nil){
            databaseRef = FirebaseManager.getDatabase().reference()
        }
        return databaseRef!
    }

    static func sync_project_recording_file(myfilename_tid : String, myfilePath : URL, projectId : String, rec_id : String, delete_remaining : Bool)
    {
        if let userid = Auth.auth().currentUser?.uid
        {
            let currentStorageRef = Storage.storage().reference().child(userid).child("projects").child(projectId).child("recording").child(myfilename_tid)
            if let uploadAudioData = NSData(contentsOf: myfilePath.absoluteURL)
            {
                let metadata1 = StorageMetadata()
                var contentType = ""
                let url_absolute = myfilePath.absoluteString
                
                if(url_absolute.contains("caf")){
                    contentType = "audio/x-caf"
                }else if(url_absolute.contains("mp3")){
                    contentType = "audio/mp3"
                }else if(url_absolute.contains("m4a")){
                    contentType = "audio/x-m4a"
                }else{
                    contentType = "audio/wav"
                }
                
                metadata1.contentType = contentType
                currentStorageRef.putData(uploadAudioData as Data, metadata: metadata1, completion: { (metadata, error) in
                    if let error = error
                    {
                        print(error.localizedDescription)
                    }
                    else
                    {
                        let myurl = metadata?.downloadURL()
                        let DownloadURL = myurl?.absoluteString
                        let userRef = FirebaseManager.getRefference().child((userid)).ref
                        let download_url_data: [String: Any] = ["downloadURL": DownloadURL!, "mime": contentType]
                        
                    userRef.child("projects").child(projectId).child("recordings").child(rec_id).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if (snapshot.exists() && snapshot.hasChild("name")){
                            userRef.child("projects").child(projectId).child("recordings").child(rec_id).updateChildValues(download_url_data, withCompletionBlock: { (error, reference) in
                                    if let error = error{
                                        print(error.localizedDescription)
                                    }else{
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadData"), object: nil)
                                        if(delete_remaining){
                                        userRef.child("remaining_upload").child("projects").child(projectId).child("recordings").child(rec_id).removeValue(completionBlock: { (error, database_ref) in
                                                if error != nil
                                                {
                                                    print(error!.localizedDescription)
                                                }
                                            })
                                        }
                                    }
                                })
                            }else{
                                delete_project_recording_file(myfilename_tid: myfilename_tid, projectId: projectId)
                            }
                        })
                    }
                })
            }
        }
    }
    
    static func delete_project_recording_file(myfilename_tid : String, projectId : String)
    {
        if let userid = Auth.auth().currentUser?.uid
        {
            let currentStorageRef = Storage.storage().reference().child(userid).child("projects").child(projectId).child("recording").child(myfilename_tid)
            
            currentStorageRef.delete { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    static func sync_noproject_recording_file(myfilename_tid : String, myfilePath : URL, rec_id : String, delete_remaining : Bool)
    {
        if let userid = Auth.auth().currentUser?.uid
        {
            let currentStorageRef = Storage.storage().reference().child(userid).child("no_project").child("recording").child(myfilename_tid)
            if let uploadAudioData = NSData(contentsOf: myfilePath.absoluteURL)
            {
                let metadata1 = StorageMetadata()
                metadata1.contentType = "audio/x-wav"
                currentStorageRef.putData(uploadAudioData as Data, metadata: metadata1, completion: { (metadata, error) in
                    if let error = error
                    {
                        print("get some error in sync project recording")
                        print(error.localizedDescription)
                    }
                    else{
                        let myurl = metadata?.downloadURL()
                        let DownloadURL = myurl?.absoluteString
                        let userRef = FirebaseManager.getRefference().child((userid)).ref
                        let download_url_data: [String: Any] = ["downloadURL": DownloadURL!, "mime":"audio/x-wav"]
                    userRef.child("no_project").child("recordings").child(rec_id).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if (snapshot.exists() && snapshot.hasChild("name"))
                            {
                            userRef.child("no_project").child("recordings").child(rec_id).updateChildValues(download_url_data, withCompletionBlock: { (error, reference) in
                                    if let error = error
                                    {
                                        print(error.localizedDescription)
                                    }else{
                                        if(delete_remaining){
                                        userRef.child("remaining_upload").child("no_project").child("recordings").child(rec_id).removeValue(completionBlock: { (error, database_ref) in
                                                if error != nil
                                                {
                                                    print(error!.localizedDescription)
                                                }
                                                
                                            })
                                        }
                                    }
                                })
                            }else{
                                delete_noproject_recording_file(myfilename_tid: myfilename_tid)
                            }
                            
                        })
                      
                    }
                })
            }
        }
    }
    
    static func delete_noproject_recording_file(myfilename_tid : String)
    {
        if let userid = Auth.auth().currentUser?.uid
        {
            let currentStorageRef = Storage.storage().reference().child(userid).child("no_project").child("recording").child(myfilename_tid)
            
            currentStorageRef.delete { error in
                if let error = error {
                    print("get error when delete noproject-recording_file")
                    print(error.localizedDescription)
                } else {
                    // File deleted successfully
                }
            }
        }
    }
    
    static func delete_master_recording_file(myfilename_tid : String)
    {
        if let userid = Auth.auth().currentUser?.uid
        {
            let currentStorageRef = Storage.storage().reference().child(userid).child("masters").child(myfilename_tid)
            currentStorageRef.delete { error in
                if let error = error {
                    print("get error when delete noproject-recording_file")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    static func sync_copytotully_file(metadata1 : StorageMetadata, uploadAudioData : Data, current_id : String, file_name : String, delete_remaining : Bool)
    {
        if let userid = Auth.auth().currentUser?.uid
        {
        let currentStorageRef = Storage.storage().reference().child(userid).child("copytoTully").child(file_name)
        currentStorageRef.putData(uploadAudioData as Data, metadata: metadata1, completion: { (metadata2, error) in
            
            if let error = error
            {
                print("get some error in sync project recording")
                print(error.localizedDescription)
            }
            else
            {
                let userRef = FirebaseManager.getRefference().child((userid)).ref
                let myurl = metadata2?.downloadURL()
                let DownloadURL = myurl?.absoluteString
                let copytotully_data: [String: Any] = ["downloadURL": DownloadURL!]
                userRef.child("copytotully").child(current_id).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if (snapshot.exists() && snapshot.hasChild("filename"))
                    {
                    userRef.child("copytotully").child(current_id).updateChildValues(copytotully_data, withCompletionBlock: { (error, database) in
                            if let error = error
                            {
                                print(error.localizedDescription)
                            }else{
                                
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadData"), object: nil)
                                
                                if(delete_remaining){
                                userRef.child("remaining_upload").child("copytotully").child(current_id).removeValue(completionBlock: { (error, database_ref) in
                                        if error != nil
                                        {
                                            print(error?.localizedDescription)
                                            //self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                                        }
                                    })
                                }
                            }
                        })
                    }else{
                        delete_copyToTully_file(file_name: file_name)
                    }
                })
            }
        })
        }
    }

    
    static func delete_copyToTully_file(file_name : String)
    {
        if let userid = Auth.auth().currentUser?.uid
        {
            let currentStorageRef = Storage.storage().reference().child(userid).child("copytoTully").child(file_name)
            currentStorageRef.delete { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }  
    }
    
   
}
