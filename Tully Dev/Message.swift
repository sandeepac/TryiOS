//
//  Message.swift
//  Tully Dev
//
//  Created by Apple on 20/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Message {
    
    //MARK: Properties
    var owner: MessageOwner
    var type: MessageType
    var content: Any
    var timestamp: Int
    var isRead: Bool
    var image: UIImage?
    private var fromID: String?
    var messageUserName : String?
    
    
    //MARK: Inits
    init(type: MessageType, content: Any, owner: MessageOwner, timestamp: Int, isRead: Bool, messageUserName: String) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.isRead = isRead
        self.messageUserName = messageUserName
    }
    
    //MARK: Methods
    class func downloadAllMessages(completion: @escaping (Message) -> Swift.Void) {
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            
            Database.database().reference().child("collaborations").child("-LMf8Qil8IvDB8xbQ4Pp").child("-LMf9HvVr2leSi4pb8nt").child("chats").observe(.value, with: { (snap) in
                
                if snap.exists() {
                    
                    for task in snap.children {
                        
                        guard let taskSnapshot = task as? DataSnapshot else {
                            continue
                        }
                        
                        let receivedMessage = taskSnapshot.value as! [String: Any]
                        
                        var type = MessageType.text
                        
                        var content = receivedMessage["messageText"] as? String
                        
                        let fileURL = receivedMessage["fileURL"] as? String
                        
                        if (fileURL?.contains("images"))! {
                            
                            type = .photo
                            
                            content = fileURL
                        }
                        else if (fileURL?.contains("docs"))! {
                            
                            type = .docs
                            
                            content = fileURL
                        }
                        
                        let fromID = receivedMessage["messageUserId"] as? String
                        let timestamp = receivedMessage["messageTime"] as? Int
                        let messageUser = receivedMessage["messageUser"] as? String
                        
                        if fromID == currentUserID {
                            
                            let message = Message.init(type: type, content: content ?? "", owner: .receiver, timestamp: timestamp ?? 0, isRead: true, messageUserName: messageUser ?? "")
                            completion(message)
                        }
                        else {
                            
                            let message = Message.init(type: type, content: content ?? "", owner: .sender, timestamp: timestamp ?? 0, isRead: true, messageUserName: messageUser ?? "")
                            completion(message)
                        }
                    }
                }
            })
        }
    }
    
    func downloadImage(indexpathRow: Int, completion: @escaping (Bool, Int) -> Swift.Void)  {
        if self.type == .photo {
            let imageLink = self.content as! String
            let imageURL = URL.init(string: imageLink)
            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
                if error == nil {
                    self.image = UIImage.init(data: data!)
                    completion(true, indexpathRow)
                }
            }).resume()
        }
    }
    
    class func send(message: Message, completion: @escaping (Bool) -> Swift.Void)  {
        if let currentUserID = Auth.auth().currentUser?.uid {
            
            switch message.type {
            case .docs:
                
                let name = message.messageUserName
                let child = UUID().uuidString
                
                let localFile = message.content as! URL
                
                Storage.storage().reference().child("docs").child(child).putFile(from: localFile, metadata: nil) { metadata, error in
                    
                    if error == nil {
                        
                        let path = metadata?.downloadURL()?.absoluteString
                        
                        let values = ["fileURL": path!, "messageText": "", "messageUserId": currentUserID, "messageTime": message.timestamp, "messageUser": name ?? ""] as [String : Any]
                        
                        Database.database().reference().child("collaborations").child("-LMf8Qil8IvDB8xbQ4Pp").child("-LMf9HvVr2leSi4pb8nt").child("chats").childByAutoId().setValue(values, withCompletionBlock: { (error, reference) in
                            
                        })
                    }
                }
            case .photo:
                
                let name = message.messageUserName
                
                let imageData = UIImageJPEGRepresentation((message.content as! UIImage), 0.5)
                let child = UUID().uuidString
                Storage.storage().reference().child("images").child(child).putData(imageData!, metadata: nil, completion: { (metadata, error) in
                    if error == nil {
                        
                        let path = metadata?.downloadURL()?.absoluteString
                        let values = ["fileURL": path!, "messageText": "", "messageUserId": currentUserID, "messageTime": message.timestamp, "messageUser": name ?? ""] as [String : Any]
                        
                        Database.database().reference().child("collaborations").child("-LMf8Qil8IvDB8xbQ4Pp").child("-LMf9HvVr2leSi4pb8nt").child("chats").childByAutoId().setValue(values, withCompletionBlock: { (error, reference) in
                            
                        })
                    }
                })
                
            case .text:
                
                let name = message.messageUserName
                
                let values = ["fileURL": "", "messageText": message.content, "messageUserId": currentUserID, "messageTime": message.timestamp, "messageUser": name ?? ""]
                
                Database.database().reference().child("collaborations").child("-LMf8Qil8IvDB8xbQ4Pp").child("-LMf9HvVr2leSi4pb8nt").child("chats").childByAutoId().setValue(values, withCompletionBlock: { (error, reference) in
                    
                })
                
            }
        }
    }
}
