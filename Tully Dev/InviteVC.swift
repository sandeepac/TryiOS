//
//  InviteVC.swift
//  Tully Dev
//
//  Created by Sandeep Chitode on 06/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase

class InviteVC: UIViewController {
    
    
    
    @IBOutlet weak var invite_Collaborator_txt_ref: UITextField!
    var adminSelected = true
    var send_invite_email = ""
    var projectCurrentId = String()
    
var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    override func viewDidLoad() {
        super.viewDidLoad()
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //Mark:- Custom methods
    
    // Email Validation
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func sendInvitation(){
        myActivityIndicator.startAnimating()
        let invite_engineer_mail = invite_Collaborator_txt_ref.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if(invite_engineer_mail == ""){
            self.myActivityIndicator.stopAnimating()
            display_alert(msg_title: "Not null", msg_desc: "Email address can not null", action_title: "OK")
        }else{
            if(isValidEmail(testStr: invite_engineer_mail!)){
                if let current_user = Auth.auth().currentUser?.email{
                    if(current_user == invite_engineer_mail){
                        self.myActivityIndicator.stopAnimating()
                        display_alert(msg_title: "Can not send", msg_desc: "You can not send request to yourself", action_title: "OK")
                    }
                    else{
                        // Check Internet connection
                        if(Reachability.isConnectedToNetwork()){
                            if let userId = Auth.auth().currentUser?.uid{
                                savePurchasePlanInFirebase(emailId: invite_Collaborator_txt_ref.text!)
                            }
                        }else{
                            self.myActivityIndicator.stopAnimating()
                            display_alert(msg_title: "Network error", msg_desc: "Please connect internet.", action_title: "OK")
                        }
                }
            }else{
                self.myActivityIndicator.stopAnimating()
                display_alert(msg_title: "Not valid", msg_desc: "Not valid email address.", action_title: "OK")
            }
        }
        }
    }
    func savePurchasePlanInFirebase(emailId: String){
        let user = Auth.auth().currentUser
        var projectId : String = ""
        var ref: DatabaseReference!
        ref = Database.database().reference()
        if let uid = Auth.auth().currentUser?.uid{
//           let refId = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//            refId.child("projects").queryOrderedByKey().observeSingleEvent(of: .value, with:{ (snapshot) in
//                for snap in snapshot.children
//                {
//                    let userSnap = snap as! DataSnapshot
//                    let project_key = userSnap.key
//                    projectId = project_key
//                    print(projectId)
//
//                }
//            })
           
            let inviteData : [String : Any] = ["invite_accept" : false, "project_id" : self.projectCurrentId, "receiver_id" : emailId, "sender_id" : uid, "sender_name" : user!.displayName]
            ref.child("collaborations").child("invitations").childByAutoId().updateChildValues( inviteData) { (error, reference) in
                if let error = error{
                    print(error.localizedDescription)
                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                } else {
                    print(inviteData)
                    print("Data is uploaded")
                    self.myActivityIndicator.stopAnimating()
                }
            }
            
        } else {
            MyConstants.normal_display_alert(msg_title: "Please signIn again.", msg_desc: "", action_title: "OK", myVC: self)
        }
    }

    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
        })
        present(ac, animated: true)
    }
    //Mark:- Actions
    @IBAction func btnBackClicked(_ sender: UIButton) {
       // let vc : SharedAudioVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SharedAudioSid") as! SharedAudioVC
        //self.navigationController?.popToViewController(vc, animated: true)
        //self.navigationController?.pushViewController(vc, animated: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSendClicked(_ sender: UIButton) {
        sendInvitation()
        //checkInviteFlag()
    }
    func checkInviteFlag() {
//        let ref = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//                let refId = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//                refId.child("projects").queryOrderedByKey().observeSingleEvent(of: .value, with:{ (snapshot) in
//                    for snap in snapshot.children
//                    {
//                        let userSnap = snap as! DataSnapshot
//                        let project_key = userSnap.value as? NSDictionary
//                        print(project_key)
//let va = project_key?.value(forKeyPath: "accept_invite")
//                        print(va)
//
//                    }
//            })

//    let ref = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//       let refId = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//       refId.child("profile").observeSingleEvent(of: .value, with:{ (snapshot) in
//                            for snap in snapshot.children
//                            {
//                                let userSnap = snap as! DataSnapshot
//                                //let project_key = userSnap.value as? NSDictionary
//                               // print(project_key)
//                                let va = userSnap.value(forKeyPath: "artist_name")
//                                print(va)
//
//                            }
//                    })
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.displayName
            print(uid)
//            let email = user.email
//            let photoURL = user.photoURL
            // ...
        }
    }
}