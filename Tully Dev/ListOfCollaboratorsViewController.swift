//
//  ListOfCollaboratorsViewController.swift
//  Tully Dev
//
//  Created by Prashant  on 01/10/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage
class ListOfCollaboratorsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var imgInvite: UIImageView!
    @IBOutlet weak var lblOwnerMail: UILabel!
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var tblCollaborators: UITableView!
    @IBOutlet weak var imgOwner: UIImageView!
    @IBOutlet weak var lblOwnerName: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    
    var collaboratioId = String ()
    var currentProjectId = String()
    var allCollaboratorsKey = [String]()
    var artistList = [ArtistsModel]()
    var adminimg: String? = " "
    var collaborationDict = [String : Any]()
    var isCurrentUserIsOwner = false
    var pendingArtistsList = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblOwner.text = "Owner"
        imgOwner.layer.masksToBounds = true
        imgOwner.clipsToBounds = true
        imgOwner.layer.cornerRadius = imgOwner.frame.size.width / 2
        
        lblOwner.layer.masksToBounds = true
        lblOwner.layer.cornerRadius = 15
        
        imgInvite.isHidden = true
        btnInvite.isHidden = true
        
        getCollaboratorsData()
        tblCollaborators.tableFooterView = UIView()
    }
    
    //MARK: TableView Delagate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "collaboratorsCell", for: indexPath) as! CollaboratorsTableViewCell
        cell.imgCollaborators.layer.masksToBounds = true
        cell.imgCollaborators.clipsToBounds = true
        cell.imgCollaborators.layer.cornerRadius = imgOwner.frame.size.width / 2
        let artist : ArtistsModel
        artist = artistList[indexPath.row]
        
        if let inviteStatus = artist.status as? String, !inviteStatus.isEmpty {
            
            cell.lblCollaboratorsName.text = "\(artist.name) (\(inviteStatus))"
        }
        else {
            
            cell.lblCollaboratorsName.text = artist.name
        }
        
        cell.lblOtherEmails.text = artist.emailId
        cell.imgCollaborators.sd_setImage(with: URL(string: artist.profile), placeholderImage: #imageLiteral(resourceName: "Image1"))
        cell.btnDeleteCollaborator.tag = indexPath.row
        
        cell.lblCollaboratorsName.textColor = hexStringToUIColor(hex: artist.colorCode)
        
        cell.btnDeleteCollaborator.addTarget(self, action: #selector(deleteCollaborator), for: .touchUpInside)
        
        if isCurrentUserIsOwner {
            
            cell.btnDeleteCollaborator.isHidden = false
        }
        else {
            
            cell.btnDeleteCollaborator.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artist : ArtistsModel
        artist = artistList[indexPath.row]
        let vc : ShowProfileViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowProfileViewController") as! ShowProfileViewController
        vc.collaboratorName = artist.name
        vc.collaboratorMail = artist.emailId
        vc.collaboratorImg = artist.profile
        vc.projectId = self.currentProjectId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getCollaboratorsData() {
        CollaborationFirebaseManager.getCollaborationBucketDataByCollaborationId(projectId: currentProjectId, collaborationId: collaboratioId, completion: {(dict) in
            
            CollaborationFirebaseManager.getInvitationsBucketValue(projectId: self.currentProjectId, completion: {[weak weakSelf = self] (invitationArray) in
                
                self.pendingArtistsList.removeAll()
                
                for i in 0..<invitationArray.count {
                    
                    if let dict = invitationArray[i] as? [String : Any] {
                        
                        if let inviteStatus = dict["invite_status"] as? String, inviteStatus.caseInsensitiveCompare("sent") == .orderedSame {
                            
                            if let receiverId = dict["receiver_id"] as? String {
                                
                                var pendingArtistDict = [String : Any]()
                                pendingArtistDict["invitationId"] = dict["invitationId"] ?? ""
                                pendingArtistDict["receiver_id"] = receiverId
                                
                                self.pendingArtistsList.append(pendingArtistDict)
                            }
                        }
                    }
                }
                
                self.collaborationDict = dict
                
                self.allCollaboratorsKey = Array(dict.keys)
                
                self.setDataInTable(data: dict)
            })
        })
    }
    
    func setDataInTable(data: [String : Any]) {
        
        var array = [ArtistsModel]()
        
        for i in 0..<allCollaboratorsKey.count {
            
            if let uid = allCollaboratorsKey[i] as? String {
                
                if let dict = data[uid] as? [String : Any] {
                    
                    CollaborationFirebaseManager.getUserProfileData(userId: uid, completion: {(profileDict) in
                        
                        if profileDict.count > 0 {
                            
                            let name = "\(profileDict["artist_name"] ?? "")"
                            let email = "\(profileDict["email"] ?? "NA")"
                            let profileImg = "\(profileDict["myimg"] ?? "")"
                            
                            var color = "#000000"
                            
                            if let colorCode = dict["lyrics_color"] as? String {
                                
                                color = colorCode
                            }
                            
                            if dict["is_owner"] != nil {
                                
                                let userID = Auth.auth().currentUser?.uid
                                
                                if userID == uid {
                                    
                                    self.isCurrentUserIsOwner = true
                                    
                                    self.imgInvite.isHidden = false
                                    self.btnInvite.isHidden = false
                                }
                                else {
                                    
                                    self.isCurrentUserIsOwner = false
                                }
                                
                                self.adminimg = profileImg
                                
                                self.lblOwnerName.text = name
                                self.lblOwnerMail.text = email
                                self.imgOwner.sd_setImage(with: URL(string: profileImg), placeholderImage: #imageLiteral(resourceName: "Image1"))
                                
                                self.lblOwnerName.textColor = hexStringToUIColor(hex:color)
                            }
                            else {
                                
                                let artist = ArtistsModel(profile: profileImg , name: name , emailId: email, colorCode: color, userId: uid, inviteId: "", status: "")
                                array.append(artist)
                            }
                            
                            if i == (self.allCollaboratorsKey.count - 1) {
                                
                                if MyVariables.isOwnerForCollaborationProject {
                                    
                                    self.addPendingArtistsData(artistsArray: array)
                                }
                                else {
                                    
                                    self.artistList.removeAll()
                                    
                                    self.artistList = array
                                    
                                    self.tblCollaborators.reloadData()
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    func addPendingArtistsData(artistsArray: [ArtistsModel]) {
        
        var array = [ArtistsModel]()
        
        if pendingArtistsList.count > 0 {
            
            for i in 0..<pendingArtistsList.count {
                
                if let dict = pendingArtistsList[i] as? [String : Any] {
                    
                    if let uid = dict["receiver_id"] as? String {
                        
                        CollaborationFirebaseManager.getUserProfileData(userId: uid, completion: {(profileDict) in
                            
                            if profileDict.count > 0 {
                                
                                let name = "\(profileDict["artist_name"] ?? "")"
                                let email = "\(profileDict["email"] ?? "NA")"
                                let profileImg = "\(profileDict["myimg"] ?? "")"
                                let inviteId = "\(dict["invitationId"] ?? "")"
                                
                                let color = "#000000"
                                
                                let artist = ArtistsModel(profile: profileImg , name: name , emailId: email, colorCode: color, userId: uid, inviteId: inviteId, status: "Pending")
                                array.append(artist)
                                
                                if i == (self.pendingArtistsList.count - 1) {
                                    
                                    self.artistList.removeAll()
                                    
                                    self.artistList = artistsArray
                                    self.artistList.append(contentsOf: array)
                                    
                                    self.tblCollaborators.reloadData()
                                }
                            }
                        })
                    }
                }
            }
        }
        else {
            
            self.artistList.removeAll()
            
            self.artistList = artistsArray
            
            self.tblCollaborators.reloadData()
        }
    }
    
    func deleteCollaborator(sender: UIButton) {
        let artist : ArtistsModel
        artist = artistList[sender.tag]
        
        let userId = artist.userId
        let inviteId = artist.inviteId
        
        let alertController = UIAlertController(title: "Alert", message: "Are you sure you want to remove the collaborator?", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped")
            
            if inviteId.count > 0 {
                
                CollaborationFirebaseManager.deleteInvitationId(projectId: self.currentProjectId, inviteId: inviteId, completion: {(isRemoved) in
                    
                })
            }
            else {
                
                if let dict = self.collaborationDict[userId] as? [String : Any] {
                    
                    if let id = dict["invite_id"] as? String {
                        
                        CollaborationFirebaseManager.deleteInvitationId(projectId: self.currentProjectId, inviteId: id, completion: {(isRemoved) in
                            
                        })
                    }
                }
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped")
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    /*func getCollaboratorsData() {
        CollaborationFirebaseManager.getCollaborationBucketDataByCollaborationId(projectId: currentProjectId, collaborationId: collaboratioId, completion: {(dict) in
            
            self.collaborationDict = dict
            
            self.allCollaboratorsKey = Array(dict.keys)
            
            self.setDataInTable(data: dict)
        })
    }
    
    func setDataInTable(data: [String : Any]) {
        
        var array = [ArtistsModel]()
        
        for i in 0..<allCollaboratorsKey.count {
            
            if let uid = allCollaboratorsKey[i] as? String {
                
                if let dict = data[uid] as? [String : Any] {
                    
                    CollaborationFirebaseManager.getUserProfileData(userId: uid, completion: {(profileDict) in
                        
                        if profileDict.count > 0 {
                            
                            let name = "\(profileDict["artist_name"] ?? "")"
                            let email = "\(profileDict["email"] ?? "NA")"
                            let profileImg = "\(profileDict["myimg"] ?? "")"
                            
                            var color = "#000000"
                            
                            if let colorCode = dict["lyrics_color"] as? String {
                                
                                color = colorCode
                            }
                            
                            if dict["is_owner"] != nil {
                                
                                let userID = Auth.auth().currentUser?.uid

                                if userID == uid {
                                    
                                    self.isCurrentUserIsOwner = true
                                    
                                    self.imgInvite.isHidden = false
                                    self.btnInvite.isHidden = false
                                }
                                else {
                                    
                                    self.isCurrentUserIsOwner = false
                                }
                                
                                self.adminimg = profileImg
                                
                                self.lblOwnerName.text = name
                                self.lblOwnerMail.text = email
                                self.imgOwner.sd_setImage(with: URL(string: profileImg), placeholderImage: #imageLiteral(resourceName: "Image1"))
                                
                                self.lblOwnerName.textColor = hexStringToUIColor(hex:color)
                            }
                            else {
                                
                                let artist = ArtistsModel(profile: profileImg , name: name , emailId: email, colorCode: color, userId: uid)
                                array.append(artist)
                            }
                            
                            if i == (self.allCollaboratorsKey.count - 1) {
                                
                                self.artistList.removeAll()
                                
                                self.artistList = array
                                
                                self.tblCollaborators.reloadData()
                            }
                        }
                    })
                }
            }
        }
    }
    
    func deleteCollaborator(sender: UIButton) {
        let artist : ArtistsModel
        artist = artistList[sender.tag]
        
        let userId = artist.userId
        
        let alertController = UIAlertController(title: "Alert", message: "Are you sure remove the collabrators", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped")
            
            if let dict = self.collaborationDict[userId] as? [String : Any] {
                
                if let inviteId = dict["invite_id"] as? String {
                    
                    CollaborationFirebaseManager.deleteInvitationId(projectId: self.currentProjectId, inviteId: inviteId, completion: {(isRemoved) in
                        
                    })
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped")
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion:nil)
    }*/
    
    //MARK:- Actions
    @IBAction func actionOwnerBtn(_ sender: UIButton) {
        let vc : ShowProfileViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowProfileViewController") as! ShowProfileViewController
        vc.collaboratorName = lblOwnerName.text ?? ""
        vc.collaboratorMail = lblOwnerMail.text ?? "NA"
        vc.collaboratorImg = adminimg!
        vc.projectId = self.currentProjectId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionBtnInvite(_ sender: UIButton) {
        let vc : InviteVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InviteVC") as! InviteVC
        vc.projectCurrentId = self.currentProjectId
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
