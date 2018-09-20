//
//  EditProfileVC.swift
//  Tully Dev
//
//  Created by macbook on 5/27/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import LocalAuthentication

class EditProfileVC: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
{

    @IBOutlet var artist_name_txt: UITextField!
    @IBOutlet var genre_lbl: UILabel!
    @IBOutlet var email_lbl: UILabel!
    @IBOutlet var fb_name_lbl: UILabel!
    
    
    @IBOutlet var pickerview_ref: UIView!
    
    //@IBOutlet var select_genre_ref: UIView!
    //@IBOutlet var submit_view_ref: UIView!
    //@IBOutlet var pickerview_ref: UIView!
    
    var txt_change = false
    var saved = false
    var selectedGenre = ""
    var genreFlag = false
    var facebookBoo = false
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var genre_arr = ["Alternative Music","Blues","Classical Music","Country Music","Dance Music","Easy Listening","Electronic Music","European Music (Folk / Pop)","Hip Hop / Rap","Indie Pop","Inspirational (incl. Gospel)","Asian Pop (J-Pop, K-pop)","Jazz","Latin Music","New Age","Opera","Pop (Popular music)","R&B / Soul","Reggae","Rock","Singer / Songwriter (inc. Folk)","World Music / Beats"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
        artist_name_txt.borderStyle = .none
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        get_profile_data()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 21/255, green: 22/255, blue: 29/255, alpha: 1)
        
    }
    
    func get_profile_data()
    {
        myActivityIndicator.startAnimating()
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        email_lbl.text = Auth.auth().currentUser?.email
        
        let userInfo1 = Auth.auth().currentUser!.providerData.count
        
        for i in 0..<userInfo1 {
            let userInfo = Auth.auth().currentUser?.providerData[i]
            let provide_id = userInfo!.providerID
            if(provide_id == "facebook.com"){
                facebookBoo = true
                fb_name_lbl.text = userInfo!.displayName
            }
        }
        
        userRef.child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            if((data?.value(forKey: "artist_name") as? String) != nil)
            {
                let name = data?.value(forKey: "artist_name") as? String
                self.artist_name_txt.text = name
                
            }
            if((data?.value(forKey: "genre") as? String) != nil)
            {
                self.genre_lbl.text = data?.value(forKey: "genre") as? String
            }
            if((data?.value(forKey: "login") as? String) != nil)
            {
                self.fb_name_lbl.text = data?.value(forKey: "artist_name") as? String
            }
            else
            {
                self.fb_name_lbl.text = ""
                
            }
            self.myActivityIndicator.stopAnimating()
        })
    
    }

    @IBAction func go_back_to_setting(_ sender: Any) {
        
        if(txt_change || genreFlag)
        {
            if(!saved)
            {
                set_artist_name()
            }
            else
            {
                if(genreFlag)
                {
                    updateGenre()
                }
                else
                {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func updateGenre()
    {
        myActivityIndicator.startAnimating()
        genreFlag = false
        if(selectedGenre != "")
        {
            let artist_data: [String: Any] = ["genre": selectedGenre]
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            
            userRef.child("profile").updateChildValues(artist_data, withCompletionBlock: { (error, database_ref) in
                
                if let error = error
                {
                    self.artist_name_txt.becomeFirstResponder()
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
                else
                {
                    self.saved = true
                    self.myActivityIndicator.stopAnimating()
                    self.navigationController?.popViewController(animated: true)
                    
                }
            })
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func set_artist_name()
    {
        myActivityIndicator.startAnimating()
      
        if(artist_name_txt.text != "")
        {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = self.artist_name_txt.text!
            changeRequest?.commitChanges { (error) in
                if let error = error
                {
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
            }
            
            let artist_data: [String: Any] = ["artist_name": self.artist_name_txt.text!]
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            
                userRef.child("profile").updateChildValues(artist_data, withCompletionBlock: { (error, database_ref) in
                    if let error = error
                    {
                        self.artist_name_txt.becomeFirstResponder()
                        self.myActivityIndicator.stopAnimating()
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                    else
                    {
                        self.saved = true
                        self.myActivityIndicator.stopAnimating()
                        
                        if(self.genreFlag)
                        {
                            self.updateGenre()
                        }
                        else
                        {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
        }
        else
        {
            self.myActivityIndicator.stopAnimating()
            self.navigationController?.popViewController(animated: true)
            //display_alert(msg_title: "Required !", msg_desc: "Name can not be null.", action_title: "OK")
        }
    }
    
    //________________________________ For Picker View  ___________________________________
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return genre_arr.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return genre_arr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGenre = genre_arr[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: genre_arr[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
        return attributedString
    }

    @IBAction func open_close_picker_view(_ sender: UIButton) {
        pickerview_ref.alpha = 1.0
    }
    
    @IBAction func btn_fb_connect(_ sender: UIButton) {
        
        if (!facebookBoo){
            facebook_signup()
        }
    }
    
    //________________________________ Facebook Signup  ___________________________________
    
    func facebook_signup()
    {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil)
            {
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil
                {
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
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().currentUser?.link(with: credential, completion: { (user, error) in
            if let error = error {
                self.display_alert(msg_title: "error", msg_desc: error.localizedDescription, action_title: "Try again")
                self.myActivityIndicator.stopAnimating()
                return
            }
            else
            {
                self.myActivityIndicator.stopAnimating()
            }
        })
    }
   
    @IBAction func btn_close_popup_view(_ sender: UIButton)
    {
        pickerview_ref.alpha = 0.0
        
        if(selectedGenre == "")
        {
            selectedGenre = genre_arr[0]
        }
        genreFlag = true
        self.genre_lbl.text = selectedGenre
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField)
    {
        artist_name_txt.text = ""
        txt_change = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        set_artist_name()
        return true
    }
    
    // Display Alert
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            self.artist_name_txt.becomeFirstResponder()
        })
        present(ac, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
