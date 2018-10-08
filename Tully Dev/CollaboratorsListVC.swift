//
//  CollaboratorsListVC.swift
//  Tully Dev
//
//  Created by Prashant  on 27/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import QuartzCore
import Firebase
class CollaboratorsListVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet weak var lblOwnerMail: UILabel!
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var tblCollaborators: UITableView!
    @IBOutlet weak var imgOwner: UIImageView!
    @IBOutlet weak var lblOwnerName: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    //MARK: - Variables
    var collaboratioId = String ()
    var currentProjectId = String()
    var collaborators = [String]()
    var allCollaboratorsKey = [String]()
    var adminKey = String ()
    var allCollaboratorsName = [Any]()
    var allCollaboratorsEmail = [Any]()
    var collaboratorsProfileImg = [String]()
    var adminEmail = String()
    var adminName = String()
    var adminimg = String()
    var removedstring = String()
    var removeUserKey = String()
    var removeUserId = ""
    var addColor = ""
    let collaboratorsCellId = "collaboratorsCell"
    var isAdmin = Bool()
    var colorCode = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        removeUserId  = ""
        imgOwner.layer.masksToBounds = true
        imgOwner.clipsToBounds = true
        imgOwner.layer.cornerRadius = imgOwner.frame.size.width / 2
        checkForAdmin()
        getDataForTable()
        tblCollaborators.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        tblCollaborators.reloadData()
    }
    //MARK: - TableView DataSource & Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCollaboratorsName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collaboratorsCell", for: indexPath) as! CollaboratorsTableViewCell
        print("admin status=\(isAdmin)")
        if isAdmin {
            btnInvite.isHidden = false
            cell.btnDeleteCollaborator.isHidden = false
            lblOwner.text = "Owner"
        } else {
            btnInvite.isHidden = true
            cell.btnDeleteCollaborator.isHidden = true
            lblOwner.text = "Admin"
        }
        cell.imgCollaborators.layer.masksToBounds = true
        cell.imgCollaborators.clipsToBounds = true
        cell.imgCollaborators.layer.cornerRadius = imgOwner.frame.size.width / 2
        cell.lblCollaboratorsName.text = allCollaboratorsName[indexPath.row] as? String
        if collaboratorsProfileImg[indexPath.row] ==  " " {
        cell.imgCollaborators.image = #imageLiteral(resourceName: "profile-icon")
        } else {
        cell.imgCollaborators.image = image(img: collaboratorsProfileImg[indexPath.row] as! String)
        }
        cell.lblOtherEmails.text = allCollaboratorsEmail[indexPath.row] as! String
        cell.btnDeleteCollaborator.tag = indexPath.row
        
        cell.btnDeleteCollaborator.addTarget(self, action: #selector(deleteCollaborator), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc : ShowProfileViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowProfileViewController") as! ShowProfileViewController
        vc.collaboratorName = allCollaboratorsName[indexPath.row] as! String
        vc.collaboratorMail = allCollaboratorsEmail[indexPath.row] as! String
        vc.collaboratorImg = collaboratorsProfileImg[indexPath.row] as! String
        vc.projectId = self.currentProjectId
        vc.ownerKey = self.adminKey
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: - Custom methods

    @objc func deleteCollaborator(sender: UIButton){
        let titleString = self.allCollaboratorsName[sender.tag] as! String
       
        let alertController = UIAlertController(title: "Alert", message: "are you sure you want to remove \(titleString)", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped")
            
            let id = self.allCollaboratorsKey[sender.tag] as! String
            self.removeUserKey = id
            self.deleteCollaborater(user: id)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped")
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion:nil)
        
    }
    
    func getDataForTable(){
        let userRef = FirebaseManager.getRefference().ref
        userRef.child("collaborations").child(self.currentProjectId).observeSingleEvent(of: .value, with: { (snapshot) in
            print("snapshot-> \(snapshot.exists())")
            if (snapshot.exists()){
                if let data = snapshot.childSnapshot(forPath: self.collaboratioId).value as? NSDictionary{
                    self.allCollaboratorsKey = data.allKeys as! [String]
                }
                if self.removeUserId  == "remove" {
                self.allCollaboratorsKey = self.allCollaboratorsKey.filter{$0 != self.removeUserKey}
                }
            }
            self.maintainAdiminAtTop()
        })
    }
    func image(img: String)-> UIImage{
        var profleImg = UIImage()
        let imageUrlString = img
        if imageUrlString == ""{
            return #imageLiteral(resourceName: "profile-icon")
        } else {
            let imageUrl:URL = URL(string: imageUrlString)!
            print(imageUrl)
            let imageData:NSData = (NSData(contentsOf: imageUrl))!
            let image = UIImage(data: imageData as Data)
            profleImg = image!
            return profleImg
        }
        
    }
    func ownerData(){
        lblOwner.layer.masksToBounds = true
        lblOwner.layer.cornerRadius = 15
        lblOwnerName.text = adminName
        if adminEmail.contains(" ") {
            lblOwnerMail.text = " "
        } else {
            lblOwnerMail.text = adminEmail as? String
        }
        
        if adminimg == " " {
            imgOwner.image = #imageLiteral(resourceName: "profile-icon")
        } else {
            imgOwner.image = image(img: adminimg)
        }
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
                                self.isAdmin = true
                            }
                        }
                    }
                }
            }
        })
    }
    
    func getData(data: [String]){
        let userRef = FirebaseManager.getRefference().ref
        for userKey in data{
            userRef.child(userKey).child("profile").observeSingleEvent(of: .value, with: { (snap) in
                
                if let snapDict = snap.value as? [String:AnyObject] {
                    let name = snapDict["artist_name"] as? String
                    let email = snapDict["email"] as? String
                    let profileImg = snapDict["myimg"] as? String
                    let unwripename = name!
                    
                    if self.adminKey == userKey{
                        self.adminName = unwripename
                        if email == nil{
                            self.adminEmail = " "
                        } else{
                            self.adminEmail = email!
                        }
                        if profileImg == nil{
                            self.adminimg = " "
                        } else {
                            self.adminimg = profileImg!
                        }
                        self.ownerData()
                    } else{
                        self.allCollaboratorsName.append(unwripename)
                        if email == nil{
                            self.allCollaboratorsEmail.append(" ")
                        } else {
                            let unwripe = email!
                            self.allCollaboratorsEmail.append(unwripe)
                        }
                        
                        if profileImg == nil {
                            self.collaboratorsProfileImg.append(" ")
                        } else{
                            self.collaboratorsProfileImg.append(profileImg!)
                        }
                    }
                }
                
                    self.tblCollaborators.reloadData()
                
            })
        }
        

    }
    func maintainAdiminAtTop(){
        let userRef = FirebaseManager.getRefference().ref
        for uid in self.allCollaboratorsKey{
        userRef.child("collaborations").child(self.currentProjectId).child(self.collaboratioId).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild("is_owner"){
                    self.adminKey = uid
                    self.getData(data: [self.adminKey])
                    self.ownerData()
                    self.allCollaboratorsKey = self.allCollaboratorsKey.filter{$0 != self.adminKey}
                }else{
                    self.tblCollaborators.reloadData()
                }
            })
        }
        if self.removeUserId  == "remove" {
            self.allCollaboratorsKey = self.allCollaboratorsKey.filter{$0 != self.removeUserKey}
        }
        self.getData(data: self.allCollaboratorsKey)
        tblCollaborators.reloadData()
    }
    
    func deleteCollaborater(user: String){

        let userRef = FirebaseManager.getRefference().ref
            userRef.child("collaborations").child(self.currentProjectId).child(self.collaboratioId).observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.exists()){
                    if(snapshot.hasChild(user)){
                        if let data = snapshot.childSnapshot(forPath: user).value as? NSDictionary{
                            //if self.addColor == "start"{
                                let color = data.value(forKey: "lyrics_color")
                               // self.colorCode.append(color as! String)
                            //}

                            let id = data.value(forKey: "invite_id")
                            self.deleteSingleUser(inviteId: id as! String)
                    }
                    }
                }
            })
        
    }
    
    func getColor(keys:[String]){
        for i in keys{
            addColor = "start"
            deleteCollaborater(user: i)
            print("color code = \(colorCode)")
        }
    }
    
    func deleteSingleUser(inviteId: String){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let inviteIdToDelete = ref.child("collaborations").child(self.currentProjectId).child("invitations").child(inviteId)
        inviteIdToDelete.removeValue { error, _ in
            //error in deleting projectId
        }
        self.allCollaboratorsEmail.removeAll()
        self.collaboratorsProfileImg.removeAll()
        self.allCollaboratorsName.removeAll()
        self.allCollaboratorsKey.removeAll()
        removeUserId  = "remove"
        getDataForTable()
        maintainAdiminAtTop()
        self.getData(data: self.allCollaboratorsKey)
        tblCollaborators.reloadData()
    }
    //MARK: - Actions
    
    @IBAction func actionBtnInvite(_ sender: UIButton) {
        let vc : InviteVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InviteVC") as! InviteVC
        vc.projectCurrentId = self.currentProjectId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionOwnerBtn(_ sender: UIButton) {
        
        let vc : ShowProfileViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowProfileViewController") as! ShowProfileViewController
        vc.collaboratorName = adminName
        vc.collaboratorMail = adminEmail
        vc.collaboratorImg = adminimg
        vc.projectId = self.currentProjectId
        vc.ownerKey = self.adminKey
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.allCollaboratorsEmail.removeAll()
        self.collaboratorsProfileImg.removeAll()
        self.allCollaboratorsName.removeAll()
        self.allCollaboratorsKey.removeAll()
        self.navigationController?.popViewController(animated: true)
    }
    
}
