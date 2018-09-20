//
//  ChangePwdVC.swift
//  Tully Dev
//
//  Created by macbook on 5/27/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase

class ChangePwdVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var txt_old_password_bg: UITextField!
    @IBOutlet var txt_old_password: UITextField!
    @IBOutlet var txt_new_password_conform_bg: UITextField!
    @IBOutlet var txt_new_password_conform: UITextField!
    @IBOutlet var txt_new_password: UITextField!
    @IBOutlet var txt_new_password_bg: UITextField!
    
    var conform_match = false
    var old_pwd = ""
    var new_pwd = ""
    var new_conform_pwd = ""
    var len1 : Int? = nil
    var len2 : Int? = nil
    var len3 : Int? = nil
    var change_flag = false
    var old_pwd_flag_validate = false
    var new_pwd_flag_validate = false
    var confirm_pwd_flag_validate = false
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txt_old_password_bg.text = "••••••••"
        txt_old_password_bg.textColor = UIColor.lightGray
        txt_new_password_conform_bg.text = "••••••••"
        txt_new_password_conform_bg.textColor = UIColor.lightGray
        txt_new_password_bg.text = "••••••••"
        txt_new_password_bg.textColor = UIColor.lightGray
        
        txt_old_password.borderStyle = .none
        txt_old_password_bg.borderStyle = .none
        txt_new_password.borderStyle = .none
        txt_new_password_bg.borderStyle = .none
        txt_new_password_conform.borderStyle = .none
        txt_new_password_conform_bg.borderStyle = .none
        
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        
        self.navigationController?.isNavigationBarHidden = true
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 21/255, green: 22/255, blue: 29/255, alpha: 1)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField){
        change_flag = true
    }
    
    private func textFieldShouldEndEditing(_ textField: UITextField)
    {
        if textField == txt_old_password{
            validate_old_pwd()
        }
        
        if textField == txt_new_password{
            validate_new_pwd()
        }
        
        if textField == txt_new_password_conform{
            validate_conform_pwd()
        }
    }
    
    func validate_old_pwd()
    {
        if txt_old_password.text == ""{
            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: "Password can not be null.", action_title: "OK", myVC:self)
        }else{
            len1 = Int((txt_old_password.text?.count)!)
            if len1! > 7{
                old_pwd = txt_old_password.text!
                
                old_pwd_flag_validate = true
            }else{
                MyConstants.normal_display_alert(msg_title: "Error", msg_desc: "Password must be at least 8 characters", action_title: "OK", myVC:self)
            }
        }
    }
    
    func validate_new_pwd()
    {
        if txt_new_password.text == ""{
            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: "Password can not be null.", action_title: "OK", myVC:self)
        }else{
            len2 = Int((txt_new_password.text?.count)!)
            if len2! > 7{
                
                new_pwd = txt_new_password.text!
                new_pwd_flag_validate = true
            }else{
                MyConstants.normal_display_alert(msg_title: "Error", msg_desc: "Password must be at least 8 characters", action_title: "OK", myVC:self)
            }
        }
    }
    
    func validate_conform_pwd()
    {
        if txt_new_password_conform.text == ""{
            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: "Password can not be null.", action_title: "OK", myVC:self)
        }else{
            len3 = Int((txt_new_password_conform.text?.count)!)
            if len3! > 7{
                new_conform_pwd = txt_new_password_conform.text!
                confirm_pwd_flag_validate = true
            }else{
                MyConstants.normal_display_alert(msg_title: "Error", msg_desc: "Password must be at least 8 characters", action_title: "OK", myVC:self)
            }
        }
    }
    
    @IBAction func go_back_to_setting(_ sender: Any)
    {
        self.view.endEditing(true)
        if(change_flag){
            let ac = UIAlertController(title: "Change Password?", message: "Are you sure you want to change password?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default)
            {
                (result : UIAlertAction) -> Void in
                self.validate_old_pwd()
                self.validate_new_pwd()
                self.validate_conform_pwd()
                
                if (self.old_pwd_flag_validate == true && self.new_pwd_flag_validate == true && self.confirm_pwd_flag_validate == true){
                    self.change_password()
                }
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .default)
            {
                (result : UIAlertAction) -> Void in
                self.navigationController?.popViewController(animated: true)
            })
            present(ac, animated: true)
            
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func change_password()
    {
        myActivityIndicator.startAnimating()
        if(new_pwd != new_conform_pwd){
            myActivityIndicator.stopAnimating()
            MyConstants.normal_display_alert(msg_title: "Not match !", msg_desc: "Password & Conform password doesn't match", action_title: "OK", myVC:self)
        }else{
            let user = Auth.auth().currentUser
            let currentPassword = old_pwd
            if let myemail = user?.email{
                let credential = EmailAuthProvider.credential(withEmail: myemail, password: currentPassword)
                user?.reauthenticate(with: credential, completion: { (error) in
                    if error != nil{
                        self.myActivityIndicator.stopAnimating()
                        MyConstants.normal_display_alert(msg_title: "Error !", msg_desc: (error?.localizedDescription)!, action_title: "OK", myVC:self)
                    }
                    else
                    {
                        let password = self.new_pwd
                        Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                            if error != nil{
                                self.myActivityIndicator.stopAnimating()
                                MyConstants.normal_display_alert(msg_title: "Error !", msg_desc: (error?.localizedDescription)!, action_title: "OK", myVC:self)
                            }else{
                                if Auth.auth().currentUser != nil{
                                    do{
                                        UserDefaults.standard.set(myemail, forKey: "tully_email")
                                        UserDefaults.standard.set(password, forKey: "tully_pwd")
                                        UserDefaults.standard.removeObject(forKey: "fb_auth_credential")
                                        self.myActivityIndicator.stopAnimating()
                                        try Auth.auth().signOut()
                                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                    }catch let error as NSError{
                                        self.myActivityIndicator.stopAnimating()
                                        MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC:self)
                                    }
                                }else{
                                    self.myActivityIndicator.stopAnimating()
                                }
                                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
