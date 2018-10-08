//
//  SignUpVC.swift
//  Tully Dev
//
//  Created by macbook on 5/20/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import Mixpanel

class SignUpVC: UIViewController , UITextFieldDelegate
{
    //MARK: - Outlets & Variables
    
    @IBOutlet var txt_email_ref: UITextField!
    @IBOutlet var txt_pwd_ref: UITextField!
    @IBOutlet var lbl_tully: UILabel!
    @IBOutlet var btn_ref_signup: UIButton!
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        create_design()
    }
    
    @IBAction func go_back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signup_user(_ sender: Any)
    {
        myActivityIndicator.startAnimating()
        var email_flag = false
        var pwd_flag = false
        
        if(txt_email_ref.text == "" && txt_pwd_ref.text == "")
        {
            MyConstants.display_alert(msg_title: "Error", msg_desc: "Enter Email ID & Password.", action_title: "Try again", navpop: true, myVC: self)
        }
        else
        {
            if(txt_email_ref.text == "")
            {
                MyConstants.display_alert(msg_title: "Error", msg_desc: "Enter Email ID.", action_title: "Try again", navpop: true, myVC: self)
            }
            else
            {
                if(isValidEmail(testStr: txt_email_ref.text!))
                {
                    email_flag = true
                }
                else
                {
                    MyConstants.display_alert(msg_title: "Error", msg_desc: "Invalid Email ID", action_title: "Try again", navpop: true, myVC: self)
                    
                }
            }
            
            if(txt_pwd_ref.text == "")
            {
                MyConstants.display_alert(msg_title: "Error", msg_desc: "Enter Password.", action_title: "Try again", navpop: true, myVC: self)
            }else{
                let len = txt_pwd_ref.text!.count
                if(len > 7)
                {
                    pwd_flag = true
                }
                else
                {
                    txt_pwd_ref.text = ""
                    MyConstants.display_alert(msg_title: "Error", msg_desc: "Your password must be at least 8 characters", action_title: "Try again", navpop: true, myVC: self)
                }
            }
        }
        
        if(email_flag == true && pwd_flag == true)
        {
            let email = txt_email_ref.text!
            let pwd = txt_pwd_ref.text!
            
            self.view.endEditing(true)
            
            Auth.auth().createUser(withEmail: email, password: pwd) { (user, error) in
                if let error = error {
                    self.myActivityIndicator.stopAnimating()
                    MyConstants.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", navpop: true, myVC: self)
                }
                else{
//                    let uid = Auth.auth().currentUser?.uid
//                    let userRef = FirebaseManager.getRefference().child(uid!).ref
//                    let currentPlanData : [String : Any] = [ "from" : "ios", "is_subscribe" : false]
//                    userRef.child("settings").child("CollaborationSubscription").setValue(currentPlanData)
                    
                    MyVariables.login_by_fb = false
                    UserDefaults.standard.set(email, forKey: "tully_email")
                    UserDefaults.standard.set(pwd, forKey: "tully_pwd")
                    UserDefaults.standard.removeObject(forKey: "fb_auth_credential")
                    self.myActivityIndicator.stopAnimating()
                    Mixpanel.mainInstance().track(event: "Mobile Signups")
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "login_form_sid") as! FormVC
                    self.present(vc, animated: true, completion: nil)
                    
                }
            }
        }
        else
        {
            myActivityIndicator.stopAnimating()
        }
    }
    
    //________________________________ Close Keyboard  ___________________________________
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //________________________________ Email Validation  ___________________________________
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //________________________________ For some custom design  ___________________________________
    
    func create_design()
    {
        let attributedString = NSMutableAttributedString(string: "TULLY")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(15.0), range: NSRange(location: 0, length: attributedString.length))
        lbl_tully.attributedText = attributedString
        txt_email_ref.layer.cornerRadius = 7.0
        txt_pwd_ref.layer.cornerRadius = 7.0
        btn_ref_signup.layer.cornerRadius = 4.0
        txt_pwd_ref.isSecureTextEntry = true
        
        let indentView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        txt_email_ref.leftView = indentView
        txt_email_ref.leftViewMode = .always
        let indentView1 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        txt_pwd_ref.leftView = indentView1
        txt_pwd_ref.leftViewMode = .always
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
