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

    @IBOutlet weak var lbl_inviter_name: UILabel!
    var inviter_name : String!
    var projectId = String()
    var inviteId = String()
    var ref: DatabaseReference!
    var body = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_inviter_name.text = "\(inviter_name!) invited you to collaborate"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func btnCloseClicked(_ sender: UIButton) {
       self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAcceptClicked(_ sender: UIButton) {
        ref = Database.database().reference()

        let inviteData : [String : Any] = ["invite_accept" : true]
        ref.child("collaborations").child(projectId).child("invitations").child(inviteId).updateChildValues(inviteData)
        print(projectId)
        let vc : CollabrationVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CollabrationVC") as! CollabrationVC
        vc.currentProjectId = projectId
        self.navigationController?.pushViewController(vc, animated: true)
        print("data updated")
    }
    
    @IBAction func btnDeclineClicked(_ sender: UIButton) {
        ref = Database.database().reference()
        let userid = Auth.auth().currentUser?.uid
        let projectIdToDelete = ref.child(userid!).child("projects").child(projectId)
        
            let invitationsStorageRef = ref.child("collaborations").child(projectId).child("invitations").child(inviteId)
        invitationsStorageRef.removeValue { error, _ in
            //error in delete invitation
        }
        projectIdToDelete.removeValue { error, _ in
            //error in deleting projectId
        }
        self.navigationController?.popViewController(animated: true)

        }

    
}
