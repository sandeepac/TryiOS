//
//  InviteEngineerVC.swift
//  Tully Dev
//
//  Created by macbook on 1/17/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
import StoreKit


class InviteEngineerVC: UIViewController {

    @IBOutlet weak var btnPurchasedSendHeight: NSLayoutConstraint!
    @IBOutlet weak var btnPurchasedViewRef: UIView!
    @IBOutlet weak var btnPurchasedSendRef: UIButton!
    @IBOutlet weak var unlimitedHeight: NSLayoutConstraint!
    @IBOutlet weak var basicHeight: NSLayoutConstraint!
    @IBOutlet weak var freeHeight: NSLayoutConstraint!
    @IBOutlet weak var basicPurchaseComplete: UIImageView!
    @IBOutlet weak var unlimitedPurchaseComplete: UIImageView!
    @IBOutlet weak var topSpaceOfMainView: NSLayoutConstraint!
    @IBOutlet weak var topSpaceToTopView: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintOfTopView: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var displayDataView: UIView!
    @IBOutlet weak var admin_access_txtview_ref: UITextView!
    @IBOutlet weak var admin_access_switch_ref: UISwitch!
    @IBOutlet var invite_engineer_txt_ref: UITextField!
    @IBOutlet weak var unlimited_btn_ref: UIButton!
    @IBOutlet weak var freeBtnRef: UIButton!
    @IBOutlet weak var basic_btn_ref: UIButton!
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    @IBOutlet weak var adminAccessViewRef: UIView!
    var send_invite_email = ""
    var comeAsChildView = false
    var currentlySelected = ""
    
    var adminSelected = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        if(comeAsChildView){
            topView.alpha = 0.0
            heightConstraintOfTopView.constant = 0.0
        }
        basicPurchaseComplete.alpha = 0.0
        unlimitedPurchaseComplete.alpha = 0.0
        btnPurchasedSendRef.alpha = 0.0
        btnPurchasedSendHeight.constant = 40.0
        
//        guard SubscriptionService.shared.currentSession.Id != nil,
//            SubscriptionService.shared.hasReceiptData else {
//                print("please restore")
//                return
//        }
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseComplete(_:)), name: Notification.Name(rawValue: "purchaseComplete"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed(_:)), name: Notification.Name(rawValue: "purchaseFailed"), object: nil)
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("engineer").child("access").keepSynced(true)
        FirebaseManager.getRefference().child("engineer").child("pending_invitation").keepSynced(true)
        custom_design()
        getCurrentPlan()
        // Do any additional setup after loading the view.
    }
    
    func getCurrentPlan(){
        
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid).ref
            
            userRef.child("settings").child("engineerAdminAccess").observeSingleEvent(of: .value, with: { (snapshot) in
                if(snapshot.exists()){
                    if let data = snapshot.value as? NSDictionary{
                        if let currentPlan = data.value(forKey: "planType") as? String{
                            print(currentPlan)
                            if(currentPlan == "basic"){
                                self.basicPlanSelected()
                            }else if(currentPlan == "unlimited"){
                                self.unlimitedPlanSelected()
                            }
                        }
                    }
                }else{
                    
                }
            })
            
        }
    }
    
    func custom_design()
    {
        invite_engineer_txt_ref.leftViewMode = UITextFieldViewMode.always
        let myView = UIView(frame : CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: CGRect(x: 15, y: 8, width: 15, height: 15))
        imageView.contentMode = UIViewContentMode.center
        let image = UIImage(named: "expand.pdf")
        imageView.image = image
        myView.addSubview(imageView)
        invite_engineer_txt_ref.leftView = myView
        
        basic_btn_ref.layer.cornerRadius = 5.0
        unlimited_btn_ref.layer.cornerRadius = 5.0
        freeBtnRef.layer.cornerRadius = 5.0
        
        basic_btn_ref.clipsToBounds = true
        unlimited_btn_ref.clipsToBounds = true
        freeBtnRef.clipsToBounds = true
        
    }
    
    @IBAction func adminAccessSwitch(_ sender: UISwitch) {
        
        if(admin_access_switch_ref.isOn){
            adminSelected = true
        }else{
            adminSelected = false
        }
    }
  
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        view.endEditing(true)
        return false
    }
    
    @IBAction func go_back(_ sender: UIButton) {
        if(comeAsChildView){
            self.parent?.viewDidLoad()
            self.willMove(toParentViewController: nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // Email Validation
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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
                            if let myData = invited_user_ids.value(forKey: userId) as? NSDictionary{
                                 if let count_invitation = myData.value(forKey: "sentCount") as? Int{
                                    if (count_invitation > 4){
                                        self.myActivityIndicator.stopAnimating()
                                        self.display_alert(msg_title: "Can't send", msg_desc: "You can not send invitation more than 5 times to same engineer", action_title: "OK")
                                    }
                                    else
                                    {
                                        
                                        let userData : [String: Any] = ["sentCount" : count_invitation + 1, "isAdmin" : self.adminSelected]
                                        
                                        FirebaseManager.getRefference().child("engineer").child("pending_invitation").child(engineer_keys[0]).child("invited/"+userId+"/").setValue(userData, withCompletionBlock: { (error, db_reference) in
                                            
                                            if let error = error{
                                                self.myActivityIndicator.stopAnimating()
                                                self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                                            }
                                            else{
                                                self.send_invite(my_mail: my_mail)
                                            }
                                            
                                        })
                                    }
                                 }else{
                                    let userData : [String: Any] = ["sentCount" : 1, "isAdmin" : self.adminSelected]
                                    
                                    FirebaseManager.getRefference().child("engineer").child("pending_invitation").child(engineer_keys[0]).child("invited/"+userId+"/").setValue(userData, withCompletionBlock: { (error, db_reference) in
                                        
                                        if let error = error{
                                            self.myActivityIndicator.stopAnimating()
                                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                                        }
                                        else{
                                            self.send_invite(my_mail: my_mail)
                                        }
                                        
                                    })
                                }
                            }
                            else
                            {
                                let userData : [String: Any] = ["sentCount" : 1, "isAdmin" : self.adminSelected]
                                
                           FirebaseManager.getRefference().child("engineer").child("pending_invitation").child(engineer_keys[0]).child("invited/"+userId+"/").setValue(userData, withCompletionBlock: { (error, db_reference) in
                                    
                                    if let error = error{
                                        self.myActivityIndicator.stopAnimating()
                                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
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
                        let myData : [String: Any] = ["sentCount" : 1, "isAdmin" : self.adminSelected]
                        
                        let userData : [String: Any] = [userId : myData]
                        let engineer_key = FirebaseManager.getRefference().child("engineer").child("pending_invitation").childByAutoId().key
                        let engineerData: [String: Any] = ["email": my_mail,"invited" : userData]
                        FirebaseManager.getRefference().child("engineer").child("pending_invitation").child(engineer_key).setValue(engineerData, withCompletionBlock: { (error, db_reference) in
                            
                            if let error = error{
                                self.myActivityIndicator.stopAnimating()
                                self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                            }
                            else{
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
                            self.display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK")
                        }
                        else
                        {
                            DispatchQueue.main.async (execute: {
                                if let urlContent = data{
                                    do{
                                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSMutableDictionary
                                        let data_send_status = jsonResult["status"] as! Int
                                        if(data_send_status == 1)
                                        {
                                            self.myActivityIndicator.stopAnimating()
                                            let sb = UIStoryboard(name: "engineer", bundle: nil)
                                            let vc = sb.instantiateViewController(withIdentifier: "invite_sent_sid") as! InviteSentVC
                                            vc.email_address = my_mail
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }else{
                                            self.myActivityIndicator.stopAnimating()
                                            self.display_alert(msg_title: "validation_error", msg_desc: "All field required.", action_title: "OK")
                                        }
                                    }
                                    catch let err{
                                        self.myActivityIndicator.stopAnimating()
                                        self.display_alert(msg_title: "Server error", msg_desc: err.localizedDescription, action_title: "OK")
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
    
    
    @IBAction func btnPurchasedSendClick(_ sender: UIButton) {
        sendInvitation()
    }
    
    //MARK: Admin Access Plan
    
    
    @IBAction func free_plan_btn_click(_ sender: UIButton) {
        currentlySelected = "free"
        sendInvitation()
    }
    
    func sendInvitation(){
        myActivityIndicator.startAnimating()
        let invite_engineer_mail = invite_engineer_txt_ref.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
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
                                let userRef = FirebaseManager.getRefference().child(userId).ref
                                userRef.child("engineer").child("access").queryOrdered(byChild: "email").queryEqual(toValue: invite_engineer_mail!).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if snapshot.exists(){
                                        self.myActivityIndicator.stopAnimating()
                                        self.invite_engineer_txt_ref.text = ""
                                        self.display_alert(msg_title: "Engineer already have access", msg_desc: "", action_title: "OK")
                                    }else{
                                        self.save_invite_firebase(my_mail: invite_engineer_mail!)
                                    }
                                })
                            }
                        }else{
                            self.myActivityIndicator.stopAnimating()
                            display_alert(msg_title: "Network error", msg_desc: "Please connect internet.", action_title: "OK")
                        }
                    }
                }
            }else{
                self.myActivityIndicator.stopAnimating()
                display_alert(msg_title: "Not valid", msg_desc: "Not valid email address.", action_title: "OK")
            }
        }
    }
    
    @IBAction func basic_plan_btn_click(_ sender: UIButton) {
        currentlySelected = "basic"
        IAPService.shared.getProducts()
        IAPService.shared.purchase(product: .basicEngineerSubscription)
    }
    @IBAction func unlimited_plan_btn_click(_ sender: UIButton) {
        currentlySelected = "unlimited"
        IAPService.shared.getProducts()
        IAPService.shared.purchase(product: .UnlimitedEngineerSubscription)
    }

    @objc func purchaseComplete(_ notification: Notification) {
        if(currentlySelected == "basic"){
            savePurchasePlanInFirebase()
            basicPlanSelected()
        }else if(currentlySelected == "unlimited"){
            savePurchasePlanInFirebase()
            unlimitedPlanSelected()
        }
    }
    
    func savePurchasePlanInFirebase(){
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid).ref
            
            let currentPlanData : [String : Any] = ["isActive" : true, "fromIos" : true, "planType" : currentlySelected]
            
            userRef.child("settings").child("engineerAdminAccess").updateChildValues( currentPlanData) { (error, reference) in
                if let error = error{
                    print(error.localizedDescription)
                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                }else{
                    self.sendInvitation()
                }
            }
            
        }else{
            MyConstants.normal_display_alert(msg_title: "Please signIn again.", msg_desc: "", action_title: "OK", myVC: self)
        }
    }
    
    func basicPlanSelected(){
        freeHeight.constant = 0.0
        basic_btn_ref.alpha = 0.0
        freeBtnRef.alpha = 0.0
        basicPurchaseComplete.alpha = 1.0
        btnPurchasedSendRef.alpha = 1.0
        btnPurchasedSendHeight.constant = 87.0
    }
    
    func unlimitedPlanSelected(){
        freeHeight.constant = 0.0
        freeBtnRef.alpha = 0.0
        basicHeight.constant = 0.0
        basicPurchaseComplete.alpha = 0.0
        basic_btn_ref.alpha = 0.0
        unlimited_btn_ref.alpha = 0.0
        unlimitedPurchaseComplete.alpha = 1.0
        btnPurchasedSendRef.alpha = 1.0
        btnPurchasedSendHeight.constant = 87.0
    }
    
    @objc func purchaseFailed(_ notification: Notification) {
        MyConstants.normal_display_alert(msg_title: "Purchase Failed", msg_desc: "", action_title: "OK", myVC: self)
    }
    
    
    
    //________________________________ Display Alert ___________________________________
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
        })
        present(ac, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
