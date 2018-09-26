//
//  InviteVC.swift
//  Tully Dev
//
//  Created by Sandeep Chitode on 06/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
class InviteVC: UIViewController {
    //MARK:- Outlet
    @IBOutlet weak var invite_Collaborator_txt_ref: UITextField!
    //MARK:- Variable
    var projectCurrentId = String()
    var status = NSNumber()
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    override func viewDidLoad() {
        super.viewDidLoad()
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
    }
    //MARK:- Custom methods
    func sendInvitation(){
        myActivityIndicator.startAnimating()
        let invite_Collaborator_mail = invite_Collaborator_txt_ref.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if(invite_Collaborator_mail == ""){
            self.myActivityIndicator.stopAnimating()
            display_alert(msg_title: "Not null", msg_desc: MyConstants.InvitationUser, action_title: "OK")
        } else {
            if(Utils.shared.isValidEmail(testStr: invite_Collaborator_mail!)){
                if let current_user = Auth.auth().currentUser?.email{
                    if(current_user == invite_Collaborator_mail){
                        self.myActivityIndicator.stopAnimating()
                        display_alert(msg_title: "Can not send", msg_desc: "You can not send request to yourself", action_title: "OK")
                    } else {
                        // Check Internet connection
                        if(Reachability.isConnectedToNetwork()){
                            if let userId = Auth.auth().currentUser?.uid{
                                ApiAuthentication.get_authentication_token().then({ (token) in
                                    self.CheckUserExist(token: token)
                                    print("tocken-> \(token)")
                                }).catch({ (err) in
                                    MyConstants.normal_display_alert(msg_title: Utils.shared.msgError, msg_desc: err.localizedDescription, action_title: "Ok", myVC: self)
                                })
                                
                            }
                        } else {
                            self.myActivityIndicator.stopAnimating()
                            display_alert(msg_title: Utils.shared.networkEmail, msg_desc: Utils.shared.msgNoNetConnection, action_title: "OK")
                        }
                    }
                }
            } else {
                self.myActivityIndicator.stopAnimating()
                MyConstants.normal_display_alert(msg_title: Utils.shared.msgEnterValidEmail, msg_desc: "", action_title: "OK", myVC: self)
            }
        }
    }
    func savePurchasePlanInFirebase(emailId: String){
        let user = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database().reference()
        if let uid = Auth.auth().currentUser?.uid {
            let inviteData : [String : Any] = ["invite_accept" : false, "project_id" : self.projectCurrentId, "receiver_id" : emailId, "sender_id" : uid, "sender_name" : user!.displayName]
            ref.child("collaborations").child(self.projectCurrentId).child("invitations").childByAutoId().updateChildValues( inviteData) { (error, reference) in
                if let error = error{
                    print(error.localizedDescription)
                    MyConstants.normal_display_alert(msg_title: Utils.shared.msgError, msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                } else {
                    print("Data is uploaded")
                    self.myActivityIndicator.stopAnimating()
                    MyConstants.normal_display_alert(msg_title: Utils.shared.msginviteSend, msg_desc: "", action_title: "OK", myVC: self)
                    self.invite_Collaborator_txt_ref.text = ""
                }
            }
            
        } else {
            MyConstants.normal_display_alert(msg_title: Utils.shared.msgsigninAlert, msg_desc: "", action_title: "OK", myVC: self)
        }
    }
    
    func checkInviteExits(email: String)
    {
        var existFlag = false
        let userRef = FirebaseManager.getRefference().ref
        userRef.child("collaborations").child(self.projectCurrentId).observeSingleEvent(of: .value, with: { (snapshot) in
            print("snapshot-> \(snapshot.exists())")
            if (snapshot.exists()){
                if let data = snapshot.childSnapshot(forPath: "invitations").value as? NSDictionary{
                    for x in data{
                        if let invitations = x.value as? [String:Any] {
                            let senderId = invitations["receiver_id"] as! String
                            if senderId == email{
                                existFlag = true
                                break
                            }
                        }
                    }
                    if existFlag {
                        self.myActivityIndicator.stopAnimating()
                        MyConstants.normal_display_alert(msg_title: "You already send invite to this user", msg_desc: "", action_title: "OK", myVC: self)
                    } else {
                        self.sendInvitation()
                    }
                    
                }
            } else {
                self.sendInvitation()
            }
            
            
        })
    }
    //MARK: CheckUserExist
    func CheckUserExist(token : String)
    {
        let postString = "invite_email="+"\(invite_Collaborator_txt_ref.text!)"
        do{
            let url = URL(string: MyConstants.InvitationUser)!
            var request = URLRequest(url: url)
            request.setValue(token, forHTTPHeaderField: MyConstants.Authorization)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postString.data(using: .utf8)
            let task=URLSession.shared.dataTask(with: request) { (data, response, error) in
                if( error != nil ){
                    print("error")
                }
                else
                {
                    DispatchQueue.main.async (execute: {
                        if let urlContent = data{
                            do{
                                let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSMutableDictionary
                                //print("JsonData"jsonResult)
                                let data_send_status = jsonResult["status"] as! Int
                                if(data_send_status == 0)
                                {
                                    MyConstants.normal_display_alert(msg_title: Utils.shared.msgNotValidTullyUser, msg_desc: "", action_title: "OK", myVC: self)
                                    self.myActivityIndicator.stopAnimating()
                                }else{
                                    self.savePurchasePlanInFirebase(emailId: self.invite_Collaborator_txt_ref.text!)
                                }
                            }
                            catch let err{
                                MyConstants.normal_display_alert(msg_title: Utils.shared.msgError, msg_desc: err.localizedDescription, action_title: "Ok", myVC: self)
                            }
                        }
                    })
                }
            }
            task.resume()
        }
    }
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default){
            (result : UIAlertAction) -> Void in
        })
        present(ac, animated: true)
    }
    //Mark:- Actions
    @IBAction func btnBackClicked(_ sender: UIButton) {
        if (self.navigationController?.viewControllers.first?.isMember(of: HomeVC.self))! == true {
            self.navigationController?.popToRootViewController(animated: false)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func btnSendClicked(_ sender: UIButton) {
        checkInviteExits(email: invite_Collaborator_txt_ref.text!)
    }
    
   
    
}

