//
//  AcceptInviteVC.swift
//  Tully Dev
//
//  Created by Sandeep Chitode on 06/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
class AcceptInviteVC: UIViewController {

    @IBOutlet weak var activityIdicator: UIActivityIndicatorView!
    @IBOutlet weak var lbl_inviter_name: UILabel!
    var inviter_name : String!
    var projectId = String()
    var inviteId = String()
    var collabrationId = String()
    var ref: DatabaseReference!
    var body = String()
    var collaborationId = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIdicator.isHidden = true
        lbl_inviter_name.text = "\(inviter_name!) \(Utils.shared.invited_you_to_collaborate)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func btnCloseClicked(_ sender: UIButton) {
       self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAcceptClicked(_ sender: UIButton) {
        ref = Database.database().reference()

        let inviteData : [String : Any] = ["invite_status" : "accept"]
        ref.child("collaborations").child(projectId).child("invitations").child(inviteId).updateChildValues(inviteData)
        let vc : HomeVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVCSid") as! HomeVC
        //vc.currentProjectId = self.projectId
        self.navigationController?.pushViewController(vc, animated: true)
        print("data updated")
    }
    
    @IBAction func btnDeclineClicked(_ sender: UIButton) {
        ref = Database.database().reference()
        let userid = Auth.auth().currentUser?.uid
        let projectIdToDelete = ref.child(userid!).child("projects").child(projectId)
        
        let inviteData : [String : Any] = ["invite_status" : "decline"]
        ref.child("collaborations").child(projectId).child("invitations").child(inviteId).updateChildValues(inviteData)
        
        projectIdToDelete.removeValue { error, _ in
            //error in deleting projectId
        }
        self.navigationController?.popViewController(animated: true)

        }
    
//    func getCollaborationId(){
//        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//        userRef.child("projects").observeSingleEvent(of: .value, with: { (snapshot) in
//
//            if (snapshot.exists()){
//                if(snapshot.hasChild(self.projectId)){
//                    if let data = snapshot.childSnapshot(forPath: self.projectId).value as? NSDictionary{
//                        print("Data->",data)
//                        if let check = data.value(forKey: "collaboration_id") as? String{
//
//                            self.collaborationId = check
//                            let vc : CollabrationViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CollabrationViewController") as! CollabrationViewController
//                            vc.currentProjectId = self.projectId
//                            vc.collabrationID = self.collaborationId
//                            self.navigationController?.pushViewController(vc, animated: true)
//                            print("Collaboration id = \(self.collaborationId)")
//
//                        }
//                    }
//                }
//            }
//        })
    
   //}
    

}
