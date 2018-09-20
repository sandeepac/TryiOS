//
//  LogInVC.swift
//  Tully Dev
//
//  Created by macbook on 5/20/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FRHyperLabel
import LocalAuthentication
import Mixpanel

class LogInVC: UIViewController , UITextFieldDelegate
{
    //________________________________ Outlets  ___________________________________
    
    @IBOutlet var btn_facebook_view_ref: UIView!
    @IBOutlet var splash_screen_view: UIView!
    @IBOutlet var btn_facebook_ref: FBSDKLoginButton!
    @IBOutlet var btn_signup_ref: UIButton!
    @IBOutlet var lbl_tully: UILabel!
    @IBOutlet var btn_login_ref: UIButton!
    @IBOutlet var txt_email_ref: UITextField!
    @IBOutlet var txt_pwd_ref: UITextField!
    @IBOutlet var forgot_pwd_lbl_ref: FRHyperLabel!
    @IBOutlet var sign_up_lbl_ref: FRHyperLabel!
    @IBOutlet var term_policy_lbl_ref: FRHyperLabel!
    @IBOutlet var touchid_btn_ref: UIButton!
    @IBOutlet var touchid_img_ref: UIImageView!
    
    //________________________________ Variables  ___________________________________
    
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var come_from_fb = false
    var openTouchId = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let val = UserDefaults.standard.object(forKey: "pushNotification")
        if (val as? String) != nil
        {
            let my_bool = val as! String
            if(my_bool == "false"){
                MyVariables.pushNotification = false
            }
            else{
                MyVariables.pushNotification = true
            }
        }
        else
        {
            MyVariables.pushNotification = true
        }
        
        let val1 = UserDefaults.standard.object(forKey: "touchId")
        if (val1 as? String) != nil{
            let my_bool = val1 as! String
            if(my_bool == "false")
            {
                MyVariables.touchId = false
            }
            else
            {
                MyVariables.touchId = true
            }
        }
        else
        {
            MyVariables.touchId = true
        }
        
    }
    
    //________________________________ if alredy login open home  ___________________________________
    
    override func viewDidAppear(_ animated: Bool)
    {
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            openTouchId = false
        }
        else
        {
            if Auth.auth().currentUser != nil
            {
                do
                {
                    try Auth.auth().signOut()
                }
                catch let error as NSError
                {
                    print(error.localizedDescription)
                }
            }
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            openTouchId = true
        }

        if Auth.auth().currentUser != nil
        {
            self.get_tutorial_data()
        }
        else
        {
            if(!come_from_fb){
                splash_screen_view.alpha = 0.0
                myActivityIndicator.center = view.center
                view.addSubview(myActivityIndicator)
                set_touch_id()
                hyperlinks()
                create_design()
            }
            else{
                come_from_fb = false
            }
        }
    }
    
   
    
    // Touch ID Authentication
    func set_touch_id()
    {
        if(MyVariables.touchId)
        {
            touchid_btn_ref.isEnabled = true
            
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 2436:
                    touchid_img_ref.image = #imageLiteral(resourceName: "faceIdImgRef")
                    print("iPhone X")
                default:
                    touchid_img_ref.image = #imageLiteral(resourceName: "touchid")
                    print("unknown")
                }
            }
            
            let val = UserDefaults.standard.object(forKey: "tully_email")
            let val1 = UserDefaults.standard.object(forKey: "fb_auth_credential")
            if ((val as? String) != nil || (val1 as? String) != nil){
                open_touchid_authentication()
            }
        }
        else
        {
            touchid_btn_ref.isEnabled = false
            touchid_img_ref.image = nil
        }
    }
    
    @IBAction func touch_id_authentication_btn_click(_ sender: UIButton)
    {
        open_touchid_authentication()
    }
    
    func open_touchid_authentication()
    {
        txt_email_ref.text = ""
        txt_pwd_ref.text = ""
        view.endEditing(true)
        let authContext : LAContext = LAContext()
        var error : NSError?
        if authContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        {
            authContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: " ", reply: { (wasSuccessful, error) in
                if (wasSuccessful)
                {
                    DispatchQueue.main.async {
                        self.myActivityIndicator.startAnimating()
                        let val = UserDefaults.standard.object(forKey: "fb_auth_credential")
                        if (val as? String) != nil{
                            let credential = FacebookAuthProvider.credential(withAccessToken: val as! String)
                            self.touchIdLogInFb(credential: credential)
                        }else{
                            self.touchIdLogInNormal()
                        }
                    }
                }
            })
        }
        else
        {
            display_alert(msg_title: "Does not support TouchID", msg_desc: "This device is not support TouchID", action_title: "OK")
        }
    }
    
    func touchIdLogInFb(credential : AuthCredential){
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                self.display_alert(msg_title: "error", msg_desc: error.localizedDescription, action_title: "Try again")
                self.myActivityIndicator.stopAnimating()
                return
            }
            else
            {
            FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                    if(snapshot.exists()){
                        MyVariables.login_by_fb = true
                        self.get_tutorial_data()
                    }else{
                        MyVariables.login_by_fb = true
                        Mixpanel.mainInstance().track(event: "Mobile Signups")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "login_form_sid") as! FormVC
                        self.present(vc, animated: true, completion: nil)
                    }
                })
                
            }
        }
    }
    
    func touchIdLogInNormal()
    {
        self.view.endEditing(true)
        
        var email = ""
        var pwd = ""
    
        let val = UserDefaults.standard.object(forKey: "tully_email")
        if (val as? String) != nil{
            email = val as! String
        }
    
        let val1 = UserDefaults.standard.object(forKey: "tully_pwd")
        if (val1 as? String) != nil{
            pwd = val1 as! String
        }
    
        if(email == "" || pwd == ""){
            self.myActivityIndicator.stopAnimating()
            self.display_alert(msg_title: "Signup", msg_desc: "Please signup first, then you can login", action_title: "OK")
        }else{
            Auth.auth().signIn(withEmail: email, password: pwd) { (user, error) in
                if let error = error
                {
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "Try again")
                }
                else
                {
                    self.get_tutorial_data()
                }
            }
        }
    }
    
    //________________________________ Log In  ___________________________________
    
    @IBAction func login_user(_ sender: Any)
    {
        myActivityIndicator.startAnimating()
        var email_flag = false
        var pwd_flag = false
        
        if(txt_email_ref.text == "" && txt_pwd_ref.text == "")
        {
            self.display_alert(msg_title: "Error", msg_desc: "Enter Email ID & Password.", action_title: "Try again")
        }
        else
        {
            if(txt_email_ref.text == "")
            {
                self.display_alert(msg_title: "Error", msg_desc: "Enter Email ID.", action_title: "Try again")
            }
            else
            {
                if(isValidEmail(testStr: txt_email_ref.text!))
                {
                    email_flag = true
                }
                else
                {
                    self.display_alert(msg_title: "Error", msg_desc: "Invalid Email ID", action_title: "Try again")
                }
            }
            
            if(txt_pwd_ref.text == "")
            {
                self.display_alert(msg_title: "Error", msg_desc: "Enter Password.", action_title: "Try again")
            }
            else
            {
                let len = txt_pwd_ref.text!.count
                if(len > 7)
                {
                    pwd_flag = true
                }
                else
                {
                    txt_pwd_ref.text = ""
                    self.display_alert(msg_title: "Error", msg_desc: "Your password must be at least 8 characters", action_title: "Try again")
                }
            }
        }
        
        if(email_flag == true && pwd_flag == true)
        {
            let email = txt_email_ref.text!
            let pwd = txt_pwd_ref.text!
            
            self.view.endEditing(true)
            
            Auth.auth().signIn(withEmail: email, password: pwd) { (user, error) in
                if let error = error
                {
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "Try again")
                }
                else{
                    UserDefaults.standard.set(email, forKey: "tully_email")
                    UserDefaults.standard.set(pwd, forKey: "tully_pwd")
                    UserDefaults.standard.removeObject(forKey: "fb_auth_credential")
                    self.get_tutorial_data()
                    
                }
            }
        }
        else
        {
            myActivityIndicator.stopAnimating()
        }
    }
    
    //________________________________ Facebook Signup  ___________________________________
    
    func facebook_signup(_ sender: Any)
    {
        come_from_fb = true
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil)
            {
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                    }
                }
            }
        }
    }
    
    //________________________________ Get FB User Data  ___________________________________
    
    func getFBUserData()
    {
        myActivityIndicator.startAnimating()
        if((FBSDKAccessToken.current()) != nil)
        {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil)
                {
                    // get email address
                    var myEmail : String = ""
                    if((result as? NSDictionary) != nil)
                    {
                        let result_data = result as! NSDictionary
                        if((result_data.value(forKey: "email") as? String) != nil)
                        {
                            myEmail = result_data.value(forKey: "email") as! String
                        }
                    }
                    
                    // Check email address is currently use or not
                    if myEmail != ""
                    {
                        let tokenString = FBSDKAccessToken.current().tokenString
                        let credential = FacebookAuthProvider.credential(withAccessToken: tokenString!)
                        
                        
                        Auth.auth().signIn(with: credential) { (user, error) in
                            if let error = error {
                                self.display_alert(msg_title: "error", msg_desc: error.localizedDescription, action_title: "Try again")
                                self.myActivityIndicator.stopAnimating()
                                return
                            }
                            else
                            {
                                
                                UserDefaults.standard.set(tokenString, forKey: "fb_auth_credential")
                                
                            FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if(snapshot.exists()){
                                        MyVariables.login_by_fb = true
                                        self.get_tutorial_data()
                                    }else{
                                        MyVariables.login_by_fb = true
                                        Mixpanel.mainInstance().track(event: "Mobile Signups")
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "login_form_sid") as! FormVC
                                        self.present(vc, animated: true, completion: nil)
                                    }
                                })
                               
                            }
                        }
                        
                    }else{
                        self.display_alert(msg_title: "Email Required", msg_desc: "Email address is required", action_title: "Ok")
                        self.myActivityIndicator.stopAnimating()
                    }
                }
            })
        }
    }
    
    //________________________________ For Hyper Link  ___________________________________
    
    func hyperlinks()
    {
        let forgot_pwd_string = "Forgot your password? Get help here."
        let sign_up_string = "Don't have an account? Sign up."
        let term_policy_string = "to Our Terms & Privacy policy"
        let attributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir-Book", size: 16.0)!]
        forgot_pwd_lbl_ref.attributedText = NSAttributedString(string: forgot_pwd_string, attributes: attributes)
        sign_up_lbl_ref.attributedText = NSAttributedString(string: sign_up_string, attributes: attributes)
        term_policy_lbl_ref.attributedText = NSAttributedString(string: term_policy_string, attributes: attributes)
        let handler = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            if (substring == "here")
            {
                self.come_from_fb = true
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "forgot_pwd_sid") as! ForgotPwdVC
                self.present(vc, animated: true, completion: nil)
            }
            else if(substring == "Sign" || substring == "up")
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "signup_sid") as! SignUpVC
                self.present(vc, animated: true, completion: nil)
            }
            else if(substring == "Terms")
            {
                self.come_from_fb = true
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Terms_Of_Service_sid") as! TermOfServiceVC
                vc.come_as_present = true
                self.present(vc, animated: true, completion: nil)
            }
            else if(substring == "Privacy" || substring == "policy")
            {
                self.come_from_fb = true
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "privacy_policy_sid") as! PrivacyPolicyVC
                vc.come_as_present = true
                self.present(vc, animated: true, completion: nil)
            }
            
        }
        forgot_pwd_lbl_ref.setLinksForSubstrings(["here"], withLinkHandler: handler)
        sign_up_lbl_ref.setLinksForSubstrings(["Sign","up"], withLinkHandler: handler)
        term_policy_lbl_ref.setLinksForSubstrings(["Terms","Privacy","policy"], withLinkHandler: handler)
    }
    
    func get_tutorial_data(){
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("settings").child("tutorial_screens").observeSingleEvent(of: .value, with: { (snapshot) in
        
            if (snapshot.exists()){
                if (snapshot.hasChild("TUTS_HOME")){
                    MyVariables.home_tutorial = (snapshot.childSnapshot(forPath: "TUTS_HOME").value as? Bool)!
                }
                if (snapshot.hasChild("TUTS_PLAY")){
                    MyVariables.play_tutorial = (snapshot.childSnapshot(forPath: "TUTS_PLAY").value as? Bool)!
                }
                if (snapshot.hasChild("TUTS_LYRICS")){
                    MyVariables.lyrics_tutorial = (snapshot.childSnapshot(forPath: "TUTS_LYRICS").value as? Bool)!
                }
                if (snapshot.hasChild("TUTS_RECORDING")){
                    MyVariables.record_tutorial = (snapshot.childSnapshot(forPath: "TUTS_RECORDING").value as? Bool)!
                }
                if (snapshot.hasChild("TUTS_MARKET_PLACE")){
                    MyVariables.market_tutorial = (snapshot.childSnapshot(forPath: "TUTS_MARKET_PLACE").value as? Bool)!
                }
            }
            
            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home_tabBar_sid") as! UITabBarController
            UIApplication.shared.keyWindow?.rootViewController = vc
            self.present(vc, animated: true, completion: nil)
        })
        
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
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(17.0), range: NSRange(location: 0, length: attributedString.length))
        lbl_tully.attributedText = attributedString
        btn_signup_ref.layer.cornerRadius = 10.0
        txt_email_ref.layer.cornerRadius = 7.0
        txt_pwd_ref.layer.cornerRadius = 7.0
        btn_facebook_ref.layer.cornerRadius = 10.0
        btn_login_ref.layer.cornerRadius = 4.0
        btn_facebook_view_ref.layer.cornerRadius = 10.0
        let indentView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        txt_email_ref.leftView = indentView
        txt_email_ref.leftViewMode = .always
        let indentView1 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        txt_pwd_ref.leftView = indentView1
        txt_pwd_ref.leftViewMode = .always
        txt_pwd_ref.isSecureTextEntry = true
    }
    
    //________________________________ Close textfield  ___________________________________
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    
    //________________________________ Display Alert  ___________________________________
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
        let titleAttrString = NSMutableAttributedString(string: msg_title, attributes: attributes)
        ac.setValue(titleAttrString, forKey: "attributedTitle")
        ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
}
