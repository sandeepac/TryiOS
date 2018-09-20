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
   // var title = String()
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
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let inviteData : [String : Any] = ["invite_accept" : true]
        ref.child("collaborations").child(projectId).child("invitations").child(inviteId).updateChildValues(inviteData)
        print(projectId)
        print("data updated")
    }
}
