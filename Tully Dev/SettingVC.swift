//
//  SettingVC.swift
//  Tully Dev
//
//  Created by macbook on 5/26/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class SettingVC: UIViewController, MFMailComposeViewControllerDelegate {

    //@IBOutlet var ref_btn_logout: UIButton!
    
    @IBOutlet var marketplaceSwitch: UISwitch!
    @IBOutlet var pushNotificationSwitch: UISwitch!
    @IBOutlet var ref_btn_logout: UIButton!
    @IBOutlet var touchIdSwitch: UISwitch!
    @IBOutlet weak var audioAnalyzerSwitch: UISwitch!
    
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var subsscriptionId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        set_notification_switch()
        custom_design()
        receiptValidation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 21/255, green: 22/255, blue: 29/255, alpha: 1)
    }
    
//    @IBAction func market_watch_on_off_click(_ sender: UISwitch) {
//        if(MyVariables.marketplaceFlag)
//        {
//            // Turn Off marketplace notification
//            UserDefaults.standard.set("false", forKey: "marketplace")
//            MyVariables.marketplaceFlag = false
//            marketplace_switch_ref.isOn = false
//            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//            let settings_data: [String: Any] = ["marketPlace": false]
//            
//        {
//            //Turn on marketplace notification
//            
//            UserDefaults.standard.set("true", forKey: "marketplace")
//            MyVariables.marketplaceFlag = true
//            marketplace_switch_ref.isOn = true
//            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//            let settings_data: [String: Any] = ["marketPlace": true]
//            
//            userRef.child("settings").updateChildValues(settings_data, withCompletionBlock: { (error, database_ref) in
//                if let error = error
//                {
//                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
//                }
//            })
//            Mixpanel.mainInstance().track(event: "Opt - In")
//        }
//    }
    
    func receiptValidation() {
        let SUBSCRIPTION_SECRET = "yourpasswordift"
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        if FileManager.default.fileExists(atPath: receiptPath!){
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
            //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
            
            print(base64encodedReceipt!)
            
            
            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":SUBSCRIPTION_SECRET]
            
            guard JSONSerialization.isValidJSONObject(requestDictionary) else {  print("requestDictionary is not valid JSON");  return }
            do {
                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
                let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"  // this works but as noted above it's best to use your own trusted server
                guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
                let session = URLSession(configuration: URLSessionConfiguration.default)
                var request = URLRequest(url: validationURL)
                request.httpMethod = "POST"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
                    if let data = data , error == nil {
                        do {
                            let appReceiptJSON = try JSONSerialization.jsonObject(with: data)
                            print("success. here is the json representation of the app receipt: \(appReceiptJSON)")
                            // if you are using your server this will be a json representation of whatever your server provided
                        } catch let error as NSError {
                            print("json serialization failed with error: \(error)")
                        }
                    } else {
                        print("the upload task returned an error: \(error)")
                    }
                }
                task.resume()
            } catch let error as NSError {
                print("json serialization failed with error: \(error)")
            } 
        }
    }
    
    func set_notification_switch()
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("settings").observe(.value, with: { (snapshot) in
            
            if (snapshot.exists()){
                if(snapshot.hasChild("audioAnalyzer")){
                    if let data = snapshot.childSnapshot(forPath: "audioAnalyzer").value as? NSDictionary{
                        if let check = data.value(forKey: "isActive") as? Bool{
                            if(check){
                                UserDefaults.standard.set("true", forKey: "audioAnalyzerSubscription")
                                MyVariables.audioAnalyzerSubscription = true
                                self.audioAnalyzerSwitch.isOn = true
                            }else{
                                 UserDefaults.standard.set("false", forKey: "audioAnalyzerSubscription")
                                MyVariables.audioAnalyzerSubscription = false
                                self.audioAnalyzerSwitch.isOn = false
                            }
                        }
                        
                        if let sid = data.value(forKey: "subscriptionId") as? String{
                            self.subsscriptionId = sid
                        }
                    }
                }else{
                     UserDefaults.standard.set("false", forKey: "audioAnalyzerSubscription")
                    MyVariables.audioAnalyzerSubscription = false
                    self.audioAnalyzerSwitch.isOn = false
                }
                
                if (snapshot.hasChild("marketPlace")){
                    if let check = snapshot.childSnapshot(forPath: "marketPlace").value as? Bool{
                        if(check){
                            UserDefaults.standard.set("true", forKey: "marketplace")
                            MyVariables.marketplaceFlag = true
                            self.marketplaceSwitch.isOn = true
                        }else{
                            UserDefaults.standard.set("false", forKey: "marketplace")
                            MyVariables.marketplaceFlag = false
                            self.marketplaceSwitch.isOn = false
                        }
                    }
                }else{
                    UserDefaults.standard.set("false", forKey: "marketplace")
                    MyVariables.marketplaceFlag = false
                    self.marketplaceSwitch.isOn = false
                }
                
                if (snapshot.hasChild("pushNotification")){
                    if let check = snapshot.childSnapshot(forPath: "pushNotification").value as? Bool{
                        if(check){
                            UserDefaults.standard.set("true", forKey: "pushNotification")
                            MyVariables.pushNotification = true
                            self.pushNotificationSwitch.isOn = true
                        }else{
                            UserDefaults.standard.set("false", forKey: "pushNotification")
                            MyVariables.pushNotification = false
                            self.pushNotificationSwitch.isOn = false
                        }
                    }
                }else{
                    UserDefaults.standard.set("false", forKey: "pushNotification")
                    MyVariables.pushNotification = false
                    self.pushNotificationSwitch.isOn = false
                }
                
                if (snapshot.hasChild("touchId")){
                    if let check = snapshot.childSnapshot(forPath: "touchId").value as? Bool{
                        if(check){
                            UserDefaults.standard.set("true", forKey: "touchId")
                            MyVariables.touchId = true
                            self.touchIdSwitch.isOn = true
                        }else{
                            UserDefaults.standard.set("false", forKey: "touchId")
                            MyVariables.touchId = false
                            self.touchIdSwitch.isOn = false
                        }
                    }
                }else{
                    UserDefaults.standard.set("false", forKey: "touchId")
                    MyVariables.touchId = false
                    self.touchIdSwitch.isOn = false
                }
                
                if (snapshot.hasChild("touchId")){
                    MyVariables.touchId = (snapshot.childSnapshot(forPath: "touchId").value as? Bool)!
                }
                
            }else{
                MyVariables.audioAnalyzerSubscription = false
                MyVariables.touchId = false
                MyVariables.pushNotification = false
                MyVariables.marketplaceFlag = false
                
                self.marketplaceSwitch.isOn = false
                self.touchIdSwitch.isOn = false
                self.pushNotificationSwitch.isOn = false
                self.audioAnalyzerSwitch.isOn = false
            }
            
        })
        
    }
    
    @IBAction func log_out(_ sender: Any)
    {
        if Auth.auth().currentUser != nil{
            do{
                try Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: "setPushNotificationKey")
            }catch let error as NSError{
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        }
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login_sid") as! LogInVC
        UIApplication.shared.keyWindow?.rootViewController = vc
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func custom_design()
    {
        ref_btn_logout.layer.cornerRadius = 5.0
        ref_btn_logout.layer.borderWidth = 1
        ref_btn_logout.layer.borderColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 1).cgColor
    }
    
    @IBAction func rate_tully(_ sender: Any)
    {
        let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rate_us_sid") as! RateUsVC
        self.addChildViewController(popvc)
        popvc.view.frame = self.view.frame
        self.view.addSubview(popvc.view)
        popvc.didMove(toParentViewController: self)
    }
    
    // Display Alert
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            //_ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    @IBAction func go_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func touch_id_on_off_click(_ sender: UISwitch)
    {
        if(MyVariables.touchId)
        {
            // Turn Off touchID
            
            UserDefaults.standard.set("false", forKey: "touchId")
            MyVariables.touchId = false
            touchIdSwitch.isOn = false
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            let settings_data: [String: Any] = ["touchId": false]
            
            userRef.child("settings").updateChildValues(settings_data, withCompletionBlock: { (error, database_ref) in
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
                
            })
        }
        else
        {
            //Turn on touchID
            UserDefaults.standard.set("true", forKey: "touchId")
            MyVariables.touchId = true
            touchIdSwitch.isOn = true
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            let settings_data: [String: Any] = ["touchId": true]
            
            userRef.child("settings").updateChildValues(settings_data, withCompletionBlock: { (error, database_ref) in
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
                
            })
            
        }
        
    }
    
    @IBAction func push_notification_on_off_click(_ sender: Any)
    {
        if(MyVariables.pushNotification)
        {
            // Turn Off push notification
            UIApplication.shared.unregisterForRemoteNotifications()
            UserDefaults.standard.set("false", forKey: "pushNotification")
            MyVariables.pushNotification = false
            pushNotificationSwitch.isOn = false
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            let settings_data: [String: Any] = ["pushNotification": false]
            
            userRef.child("settings").updateChildValues(settings_data, withCompletionBlock: { (error, database_ref) in
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
                
            })
        }
        else
        {
            //Turn on push notification
            
            let notificationTypes : UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            UIApplication.shared.registerForRemoteNotifications()
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UserDefaults.standard.set("true", forKey: "pushNotification")
            MyVariables.pushNotification = true
            pushNotificationSwitch.isOn = true
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            let settings_data: [String: Any] = ["pushNotification": true]
            
            userRef.child("settings").updateChildValues(settings_data, withCompletionBlock: { (error, database_ref) in
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
            })
        }
    }
    
    @IBAction func btn_help_click(_ sender: UIButton)
    {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@tullyapp.com"])
            present(mail, animated: true)
        }
    }
   
    @IBAction func audioAnalyzerOnOffClick(_ sender: UISwitch) {
        
        UIApplication.shared.openURL(URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")!)
        
//        if(MyVariables.audioAnalyzerSubscription)
//        {
//            if(subsscriptionId.trimmingCharacters(in: .whitespaces) != ""){
//                ApiAuthentication.get_authentication_token(callback: self.unSubscribeBpm)
//            }else{
//                audioAnalyzerSwitch.setOn(false, animated: false)
//
//                let vc = UIStoryboard(name: "superpowered", bundle: nil).instantiateViewController(withIdentifier: "SuperPoweredSubscribeVC") as! SuperPoweredSubscribeVC
//                self.present(vc, animated: true, completion: nil)
//            }
//
//        }
//        else
//        {
//             audioAnalyzerSwitch.setOn(false, animated: false)
//            let vc = UIStoryboard(name: "superpowered", bundle: nil).instantiateViewController(withIdentifier: "SuperPoweredSubscribeVC") as! SuperPoweredSubscribeVC
//            self.present(vc, animated: true, completion: nil)
//        }
        
    }
    
    func unSubscribeBpm(token : String){
        self.myActivityIndicator.startAnimating()
        if let myuserid = Auth.auth().currentUser?.uid{
            
            let MyUrlString = MyConstants.audio_analyzer_unsubscribe_link
            var request = URLRequest(url: URL(string: MyUrlString)!)
            request.setValue(token, forHTTPHeaderField: MyConstants.Authorization)
            request.httpMethod = "POST"
            
            let user_data = "&subscription_id="+subsscriptionId
            let postString = "uid="+myuserid+"&token="+token+user_data
            //let myString = "uid="+myuserid
            
            //let postString = myString+share_string
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else{
                    DispatchQueue.main.async{
                        self.myActivityIndicator.stopAnimating()
                    }
                    self.display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: String(describing: response), action_title: "OK")
                }else{
                    do{
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                            DispatchQueue.main.async (execute: {
                                let status = json["status"] as! Int
                                if(status == 1){
                                    let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                                    let settings_data: [String: Any] = ["isActive": false, "subscriptionId": ""]
                        
                                    userRef.child("settings").child("audioAnalyzer").updateChildValues(settings_data, withCompletionBlock: { (error, database_ref) in
                                        if let error = error
                                        {
                                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                                        }else{
                                            UserDefaults.standard.set("false", forKey: "audioAnalyzerSubscription")
                                            MyVariables.audioAnalyzerSubscription = false
                                            self.audioAnalyzerSwitch.isOn = false
                                            self.myActivityIndicator.stopAnimating()
                                            self.display_alert(msg_title: "Unsubscribe Successfully.", msg_desc: "", action_title: "Ok")
                                        }
                                    })
                                    
                                }else{
                                    let msg = json["msg"] as! String
                                    self.myActivityIndicator.stopAnimating()
                                    self.display_alert(msg_title: "Error", msg_desc: msg, action_title: "Ok")
                                }
                            })
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            self.myActivityIndicator.stopAnimating()
                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                        }
                    }
                }
            };task.resume()
        }
    }
    
    @IBAction func market_watch_on_off_click(_ sender: UISwitch) {
        if(MyVariables.marketplaceFlag)
        {
            // Turn Off marketplace notification
            UserDefaults.standard.set("false", forKey: "marketplace")
            MyVariables.marketplaceFlag = false
            marketplaceSwitch.isOn = false
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            let settings_data: [String: Any] = ["marketPlace": false]
            
            userRef.child("settings").updateChildValues(settings_data, withCompletionBlock: { (error, database_ref) in
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
                
            })
        }
        else
        {
            //Turn on marketplace notification
            
            UserDefaults.standard.set("true", forKey: "marketplace")
            MyVariables.marketplaceFlag = true
            marketplaceSwitch.isOn = true
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            let settings_data: [String: Any] = ["marketPlace": true]
            
            userRef.child("settings").updateChildValues(settings_data, withCompletionBlock: { (error, database_ref) in
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
            })
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil)
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
