//
//  EngineerRequestVC.swift
//  Tully Dev
//
//  Created by macbook on 1/22/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase

class EngineerRequestVC: UIViewController, UITextViewDelegate {

    //MARK: - Outlets & Variables
    @IBOutlet var email_txt_ref: UITextField!
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    var send_invite_email = ""
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseManager.getRefference().child("engineer").keepSynced(true)
        MyConstants.showAnimate(myView: self.view)
        myActivityIndicator.center = view.center
        self.view.addSubview(myActivityIndicator)
    }

    @IBAction func send_btn_click(_ sender: UIButton) {
        
        myActivityIndicator.startAnimating()
        let invite_engineer_mail = email_txt_ref.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if(invite_engineer_mail == ""){
            MyConstants.display_alert(msg_title: "Not null", msg_desc: "Email address can not null", action_title: "OK", navpop: false, myVC: self)
        }else{
            if(validations.isValidEmail(testStr: invite_engineer_mail!)){
                if let current_user = Auth.auth().currentUser?.email{
                    if(current_user == invite_engineer_mail){
                        DispatchQueue.main.async {
                            self.myActivityIndicator.stopAnimating()
                            MyConstants.display_alert(msg_title: "Can not send", msg_desc: "You can not send request to yourself", action_title: "OK", navpop: false, myVC: self)
                        }
                    }
                    else{
                        // Check Internet connection
                        if(Reachability.isConnectedToNetwork()){
                            if let userId = Auth.auth().currentUser?.uid{
                                let userRef = FirebaseManager.getRefference().child(userId).ref
                                userRef.child("engineer").child("access").queryOrdered(byChild: "email").queryEqual(toValue: invite_engineer_mail!).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if snapshot.exists(){
                                        self.email_txt_ref.text = ""
                                        DispatchQueue.main.async {
                                            self.myActivityIndicator.stopAnimating()
                                            MyConstants.display_alert(msg_title: "Engineer already have access", msg_desc: "", action_title: "OK", navpop: false, myVC: self)
                                        }
                                    }else{
                                        self.save_invite_firebase(my_mail: invite_engineer_mail!)
                                    }
                                })
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.myActivityIndicator.stopAnimating()
                                MyConstants.display_alert(msg_title: "Network error", msg_desc: "Please connect internet.", action_title: "OK", navpop: false, myVC: self)
                            }
                        }
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.myActivityIndicator.stopAnimating()
                    MyConstants.display_alert(msg_title: "Not valid", msg_desc: "Not valid email address.", action_title: "OK", navpop: false, myVC: self)
                }
            }
        }
    }
    
    func save_invite_firebase(my_mail : String)
    {
        
        if let userId = Auth.auth().currentUser?.uid{
            FirebaseManager.getRefference().child("engineer").child("pending_invitation").queryOrdered(byChild: "email").queryEqual(toValue: my_mail).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists()
                {
                    let engineer_value = snapshot.value as! NSDictionary
                    let engineer_keys = engineer_value.allKeys as! [String]
                    if let user = engineer_value.value(forKey: engineer_keys[0]) as? NSDictionary{
                        engineer_value.value(forKey: engineer_keys[0])
                        if let invited_user_ids = user.value(forKey: "invited") as? NSDictionary{
                            if let count_invitation = invited_user_ids.value(forKey: userId) as? Int{
                                if (count_invitation > 4){
                                    DispatchQueue.main.async {
                                        self.myActivityIndicator.stopAnimating()
                                        MyConstants.display_alert(msg_title: "Can't send", msg_desc: "You can not send invitation more than 5 times to same engineer", action_title: "OK", navpop: false, myVC: self)
                                    }
                                }
                                else
                                {
                                    let userData : [String: Int] = [userId : count_invitation + 1]
                                FirebaseManager.getRefference().child("engineer").child("pending_invitation").child(engineer_keys[0]).child("invited").setValue(userData, withCompletionBlock: { (error, db_reference) in
                                        
                                        if let error = error{
                                            DispatchQueue.main.async {
                                                self.myActivityIndicator.stopAnimating()
                                                MyConstants.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", navpop: false, myVC: self)
                                            }
                                        }else{
                                            self.send_invite(my_mail: my_mail)
                                        }
                                    })
                                }
                            }
                            else
                            {
                            FirebaseManager.getRefference().child("engineer").child("pending_invitation").child(engineer_keys[0]).child("invited/"+userId).setValue(1, withCompletionBlock: { (error, db_reference) in
                                    if let error = error{
                                        DispatchQueue.main.async {
                                            self.myActivityIndicator.stopAnimating()
                                            MyConstants.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", navpop: false, myVC: self)
                                        }
                                    }
                                    else{
                                        self.send_invite(my_mail: my_mail)
                                    }
                                })
                            }
                        }
                    }
                }
                else
                {
                    if let userId = Auth.auth().currentUser?.uid{
                        let userData : [String: Int] = [userId : 1]
                        let engineerData: [String: Any] = ["email": my_mail,"invited" : userData]
                   let mykey = FirebaseManager.getRefference().child("engineer").child("pending_invitation").childByAutoId().key
                    FirebaseManager.getRefference().child("engineer").child("pending_invitation").child(mykey).setValue(engineerData, withCompletionBlock: { (error, db_reference) in
                            if let error = error{
                                DispatchQueue.main.async {
                                    self.myActivityIndicator.stopAnimating()
                                    MyConstants.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", navpop: false, myVC: self)
                                }
                            }else{
                                self.send_invite(my_mail: my_mail)
                            }
                        })
                    }
                }
            })
        }
    }
    
    func send_invite(my_mail : String){
        send_invite_email = my_mail
        ApiAuthentication.get_authentication_token().then({ (token) in
            self.send_invite_with_security(token: token)
        }).catch({ (err) in
            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: err.localizedDescription, action_title: "Ok", myVC: self)
        })
    }
    
    
    func send_invite_with_security(token : String)
    {
        if let userId = Auth.auth().currentUser?.uid{
            if send_invite_email != ""{
                let my_mail = send_invite_email
                let postString = "userid="+userId+"&invite_email="+my_mail
                do{
                    let url = URL(string: MyConstants.engineer_invite)!
                    var request = URLRequest(url: url)
                    request.setValue(token, forHTTPHeaderField: MyConstants.Authorization)
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    request.httpBody = postString.data(using: .utf8)
                    let task=URLSession.shared.dataTask(with: request) { (data, response, error) in
                        if( error != nil ){
                            self.myActivityIndicator.stopAnimating()
                            MyConstants.display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK", navpop: false, myVC: self)
                        }
                        else
                        {
                            DispatchQueue.main.async (execute: {
                                if let urlContent = data
                                {
                                    do
                                    {
                                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSMutableDictionary
                                        let data_send_status = jsonResult["status"] as! Int
                                        
                                        if(data_send_status == 1)
                                        {
                                            self.myActivityIndicator.stopAnimating()
                                            MyConstants.removeAnimate(myView: self.view, myVC: self)
                                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "invite_sent_sid") as! InviteSentVC
                                            vc.email_address = my_mail
                                            vc.come_from_settings = true
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                        else{
                                            self.myActivityIndicator.stopAnimating()
                                            
                                            MyConstants.display_alert(msg_title: "validation_error", msg_desc: "All field required.", action_title: "OK", navpop: false, myVC: self)
                                        }
                                    }
                                    catch let err{
                                        
                                        MyConstants.display_alert(msg_title: "Server error", msg_desc: err.localizedDescription, action_title: "OK", navpop: false, myVC: self)
                                    }
                                }
                            })
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    
    @IBAction func cancel_btn_click(_ sender: UIButton) {
        MyConstants.removeAnimate(myView: self.view, myVC: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
