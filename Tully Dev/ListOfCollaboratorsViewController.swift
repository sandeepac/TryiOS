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
    
    
    var refArtist: DatabaseReference!
    let userRef = FirebaseManager.getRefference().ref
    var collaboratioId = String ()
    var currentProjectId = String()
    var allCollaboratorsKey = [String]()
    var adminKey = String ()
    var removeUserId = ""
    var isAdmin = Bool()
    var artistList = [ArtistsModel]()
    var adminName: String? = " "
    var adminEmail: String? = " "
    var adminimg: String? = " "
    var adminColor = String()
    var colorArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
           checkForAdmin()
        lblOwner.text = "Owner"
        imgOwner.layer.masksToBounds = true
        imgOwner.clipsToBounds = true
        imgOwner.layer.cornerRadius = imgOwner.frame.size.width / 2
        getUserKey()
        tblCollaborators.tableFooterView = UIView()
    }
    
    
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
        cell.lblCollaboratorsName.text = artist.name
        cell.lblOtherEmails.text = artist.emailId
        cell.imgCollaborators.sd_setImage(with: URL(string: artist.profile), placeholderImage: #imageLiteral(resourceName: "Image1"))
        cell.btnDeleteCollaborator.tag = indexPath.row
        if isAdmin {
            imgInvite.isHidden = false
            btnInvite.isHidden = false
            cell.btnDeleteCollaborator.isHidden = false
            lblOwner.text = "Owner"
        } else {
            imgInvite.isHidden = true
            btnInvite.isHidden = true
            cell.btnDeleteCollaborator.isHidden = true
            lblOwner.text = "Admin"
        }
        cell.lblCollaboratorsName.textColor = hexStringToUIColor(hex: colorArray[indexPath.row])
        cell.btnDeleteCollaborator.addTarget(self, action: #selector(deleteCollaborator), for: .touchUpInside)
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
        vc.ownerKey = self.adminKey
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getUserKey(){
        
        userRef.child("collaborations").child(self.currentProjectId).observe(.value, with: { snapshot in
            if let data = snapshot.childSnapshot(forPath: self.collaboratioId).value as? NSDictionary{
                self.allCollaboratorsKey = data.allKeys as! [String]
                self.maintainAdiminAtTop()
            }
        })
        
    }
    
    
    func getArtist(data: [String]){
        
        self.artistList.removeAll()
        for userKey in data{
            userRef.child(userKey).child("profile").observe(.value, with: { snapshot in
                if let snapDict = snapshot.value as? [String:AnyObject] {
                    var name = snapDict["artist_name"] as? String
                    var email = snapDict["email"] as? String
                    var profileImg = snapDict["myimg"] as? String
                    
                    if email == nil{
                        email = "NA"
                    }
                    if name == nil{
                        name = " "
                    }
                    if profileImg == nil{
                        profileImg = " "
                    }
                    let artist = ArtistsModel(profile: profileImg! , name: name! , emailId: email!)
                    self.artistList.append(artist)
                    self.tblCollaborators.reloadData()
                }
            })
            
        }
    }
    func maintainAdiminAtTop(){
        for uid in self.allCollaboratorsKey{
            userRef.child("collaborations").child(self.currentProjectId).child(self.collaboratioId).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild("is_owner"){
                    self.adminKey = uid
                     self.allCollaboratorsKey = self.allCollaboratorsKey.filter{$0 != self.adminKey}
                    self.ownerData(key: self.adminKey)
                    self.getColor(users:[self.adminKey])
                }
                
            })
            if self.adminKey != ""{
                print("all colaborates except \(self.allCollaboratorsKey)")
                break
            }
        }
    }
    
    func ownerData(key: String){
        lblOwner.layer.masksToBounds = true
        lblOwner.layer.cornerRadius = 15
        userRef.child(adminKey).child("profile").observe(.value, with: { snapshot in
            if let snapDict = snapshot.value as? [String:AnyObject] {
                
                self.adminName = snapDict["artist_name"] as! String
                self.adminEmail = snapDict["email"] as? String
                var profileImg = snapDict["myimg"] as? String
                self.adminimg = profileImg
                if self.adminEmail == nil{
                    self.adminEmail = "NA"
                }
                if self.adminName == nil{
                    self.adminName = " "
                }
                if self.adminimg == nil{
                    self.adminimg = " "
                }

                self.lblOwnerName.text = self.adminName
                self.lblOwnerMail.text = self.adminEmail
                
                if self.adminimg == " " {
                    self.imgOwner.image = #imageLiteral(resourceName: "Image1")
                } else {
                    self.imgOwner.sd_setImage(with: URL(string: self.adminimg!), placeholderImage: #imageLiteral(resourceName: "Image1"))
                }

            }
        })
        
        
    }
   
    
        func deleteCollaborator(sender: UIButton){
        let artist : ArtistsModel
        artist = artistList[sender.tag]

        let titleString = artist.name
        
        let alertController = UIAlertController(title: "Alert", message: "are you sure you want to remove \(titleString)", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped")
            
            let id = self.allCollaboratorsKey[sender.tag]
            self.removeUserId = id
            self.deleteCollaborater(user: id)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped")
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion:nil)
        
    }
    
    func deleteCollaborater(user: String){
        
        userRef.child("collaborations").child(self.currentProjectId).child(self.collaboratioId).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()){
                if(snapshot.hasChild(user)){
                    if let data = snapshot.childSnapshot(forPath: user).value as? NSDictionary{
                        let id = data.value(forKey: "invite_id")
                        self.deleteSingleUser(inviteId: id as! String)
                    }
                }
            }
        })
        
    }
    func getColor(users:[String]){
        self.colorArray.removeAll()
        for user in users{
            userRef.child("collaborations").child(self.currentProjectId).child(self.collaboratioId).observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.exists()){
                    if(snapshot.hasChild(user)){
                        if let data = snapshot.childSnapshot(forPath: user).value as? NSDictionary{
                            if self.adminKey == user{
                                let color = data.value(forKey: "lyrics_color")
                                self.adminColor = color as! String
                                self.lblOwnerName.textColor = hexStringToUIColor(hex:self.adminColor)
                                self.adminKey = ""
                                self.getColor(users:self.allCollaboratorsKey)
                                self.getArtist(data: self.allCollaboratorsKey)
                                print("Admin color = \(self.adminColor)")
                            }
                           else{
                                if let color = data.value(forKey: "lyrics_color"){
                                self.colorArray.append(color as! String)
                                self.colorArray = self.colorArray.filter{$0 != self.adminColor}
                                print("Color array is = \(self.colorArray)")
                                }

                            }
                            
                            
                        }
                    }
                }
            })
        }
        
    }
    func deleteSingleUser(inviteId: String){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let inviteIdToDelete = ref.child("collaborations").child(self.currentProjectId).child("invitations").child(inviteId)
        inviteIdToDelete.removeValue { error, _ in
            //error in deleting projectId
        }
        artistList.removeAll()
        tblCollaborators.reloadData()
    }

    func checkForAdmin(){
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()){
                if(snapshot.hasChild(self.currentProjectId)){
                    if let data = snapshot.childSnapshot(forPath: self.currentProjectId).value as? NSDictionary{
                        if let check = data.value(forKey: "is_owner") as? Bool{
                            if(check){
                                self.isAdmin = true
                            } else {
                                self.isAdmin = false
                            }
                        }
                    }
                }
            }
        })
    }

    //MARK:- Actions
    @IBAction func actionOwnerBtn(_ sender: UIButton) {
        let vc : ShowProfileViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowProfileViewController") as! ShowProfileViewController
        vc.collaboratorName = adminName!
        vc.collaboratorMail = adminEmail!
        vc.collaboratorImg = adminimg!
        vc.projectId = self.currentProjectId
        vc.ownerKey = self.adminKey
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
