//
//  FormVC.swift
//  Tully Dev
//
//  Created by macbook on 5/21/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import Mixpanel

class FormVC: UIViewController, UIPickerViewDelegate , UIPickerViewDataSource, UITextFieldDelegate
{
    //MARK: - Outlets
    
    @IBOutlet var select_genre_ref: UIView!
    @IBOutlet var submit_view_ref: UIView!
    @IBOutlet var pickerview_ref: UIView!
    @IBOutlet var checkbox_btn_solo_artist: UIButton!
    @IBOutlet var checkbox_btn_producer: UIButton!
    @IBOutlet var checkbox_btn_band: UIButton!
    @IBOutlet var checkbox_btn_engineer: UIButton!
    @IBOutlet var btn_genre_ref: UIButton!
    @IBOutlet var img_btn_solo_artist: UIImageView!
    @IBOutlet var img_btn_producer: UIImageView!
    @IBOutlet var img_btn_band: UIImageView!
    @IBOutlet var img_btn_engineer: UIImageView!
    @IBOutlet var artist_nm_txt_ref: UITextField!
    @IBOutlet var submit_btn_width_constraint_ref: NSLayoutConstraint!
    @IBOutlet var submit_btn_height_constraint_ref: NSLayoutConstraint!
    
    //MARK: - Variables
    
    let checkedImage = UIImage(named: "ic_check_box")! as UIImage
    let uncheckedImage = UIImage(named: "ic_check_box_outline_blank")! as UIImage
    var genre_arr = ["Alternative Music","Blues","Classical Music","Country Music","Dance Music","Easy Listening","Electronic Music","European Music (Folk / Pop)","Hip Hop / Rap","Indie Pop","Inspirational (incl. Gospel)","Asian Pop (J-Pop, K-pop)","Jazz","Latin Music","New Age","Opera","Pop (Popular music)","R&B / Soul","Reggae","Rock","Singer / Songwriter (inc. Folk)","World Music / Beats"]
    var artist_flag = false
    var producer_flag = false
    var band_flag = false
    var engineer_flag = false
    var selectedGenre = ""
    var selected_options = [String]()
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        let screenSize = UIScreen.main.bounds
        let btnWidth = (CGFloat(screenSize.height)/6.5)
        let btnHeight = btnWidth - 10
        submit_btn_height_constraint_ref.constant = btnHeight
        submit_btn_width_constraint_ref.constant = btnWidth
        MyVariables.home_tutorial = false
        MyVariables.play_tutorial = false
        MyVariables.market_tutorial = false
        MyVariables.lyrics_tutorial = false
        MyVariables.record_tutorial = false
        create_design()
    }
    
    //MARK: - Custom design
    
    func create_design()
    {
        artist_nm_txt_ref.layer.cornerRadius = 7.0
        checkbox_btn_solo_artist.layer.cornerRadius = 5.0
        checkbox_btn_producer.layer.cornerRadius = 5.0
        checkbox_btn_band.layer.cornerRadius = 5.0
        checkbox_btn_engineer.layer.cornerRadius = 5.0
        let indentView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        artist_nm_txt_ref.leftView = indentView
        artist_nm_txt_ref.leftViewMode = .always
    }
    
    func set_genre(){
        btn_genre_ref.setTitle(selectedGenre, for: .normal)
    }
    
    //MARK: - Checkboxes

    @IBAction func checkbox_solo_artist(_ sender: Any)
    {
        view.endEditing(true)
        if(artist_flag){
            img_btn_solo_artist.image = UIImage(named: "ic_check_box_outline_blank")!
            if(selected_options.contains("Solo Artist")){
                let myindex = selected_options.index(of: "Solo Artist")
                selected_options.remove(at: myindex!)
            }
            artist_flag = false
        }else{
            img_btn_solo_artist.image = UIImage(named: "ic_check_box")!
            selected_options.append("Solo Artist")
            artist_flag = true
        }
    }

    @IBAction func checkbox_producer(_ sender: Any)
    {
        view.endEditing(true)
        if(producer_flag){
            img_btn_producer.image = UIImage(named: "ic_check_box_outline_blank")!
            if(selected_options.contains("Producer")){
                let myindex = selected_options.index(of: "Producer")
                selected_options.remove(at: myindex!)
            }
            producer_flag = false
        }else{
            img_btn_producer.image = UIImage(named: "ic_check_box")!
            selected_options.append("Producer")
            producer_flag = true
        }
    }
    
    @IBAction func checkbox_band(_ sender: Any)
    {
        view.endEditing(true)
        if(band_flag){
            img_btn_band.image = UIImage(named: "ic_check_box_outline_blank")!
            if(selected_options.contains("Band")){
                let myindex = selected_options.index(of: "Band")
                selected_options.remove(at: myindex!)
            }
            band_flag = false
        }else{
            img_btn_band.image = UIImage(named: "ic_check_box")!
            selected_options.append("Band")
            band_flag = true
        }
    }
    
    @IBAction func checkbox_engineer(_ sender: Any)
    {
        view.endEditing(true)
        if(engineer_flag){
            img_btn_engineer.image = UIImage(named: "ic_check_box_outline_blank")!
            if(selected_options.contains("Engineer")){
                let myindex = selected_options.index(of: "Engineer")
                selected_options.remove(at: myindex!)
            }
            engineer_flag = false
        }else{
            img_btn_engineer.image = UIImage(named: "ic_check_box")!
            selected_options.append("Engineer")
            engineer_flag = true
        }
    }
    
    @IBAction func open_genre_picker(_ sender: Any){
        select_genre_ref.alpha = 0.0
        submit_view_ref.alpha = 0.0
        pickerview_ref.alpha = 1.0
    }
    
    @IBAction func btn_close_popup_view(_ sender: Any)
    {
        select_genre_ref.alpha = 1.0
        submit_view_ref.alpha = 1.0
        pickerview_ref.alpha = 0.0
        if(selectedGenre == ""){
            selectedGenre = genre_arr[0]
        }
        let s1 = "  "
        let mytitle = s1 + selectedGenre
        btn_genre_ref.setTitle(mytitle, for: .normal)
    }
    
    //MARK: - Form Submit
    
    @IBAction func form_submit(_ sender: Any)
    {
        self.submit_click()
        
//        let ac = UIAlertController(title: "\"Enable Touch Id for Tully?\"", message: "Log on to access your profile", preferredStyle: .alert)
//        let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
//        let titleAttrString = NSMutableAttributedString(string: "\"Enable Touch Id for Tully?\"", attributes: attributes)
//        ac.setValue(titleAttrString, forKey: "attributedTitle")
//        ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
//        ac.addAction(UIAlertAction(title: "Not Now", style: .default)
//        {
//            (result : UIAlertAction) -> Void in
//            UserDefaults.standard.set("false", forKey: "touchId")
//            MyVariables.touchId = false
//
//            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//            let settings_data: [String: Any] = ["touchId": false]
//
//            userRef.child("settings").updateChildValues(settings_data, withCompletionBlock: { (error, database_ref) in
//                if let error = error{
//                    MyConstants.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", navpop: true, myVC: self)
//                }
//            })
//            self.submit_click()
//        })
//        ac.addAction(UIAlertAction(title: "Enable", style: .default)
//        {
//            (result : UIAlertAction) -> Void in
//
//        })
//        present(ac, animated: true)
    }
    
    func submit_click()
    {
        myActivityIndicator.startAnimating()
        var artist_flag = false
        var option_flag = false
        var genre_flag = false
        
        if(artist_nm_txt_ref.text == ""){
            MyConstants.display_alert(msg_title: "Error", msg_desc: "Enter Artist Name", action_title: "Try again", navpop: true, myVC: self)
        }else{
            artist_flag = true
        }
        
        if(selectedGenre == ""){
            MyConstants.display_alert(msg_title: "Error", msg_desc: "Select Primary Genre", action_title: "Try again", navpop: true, myVC: self)
        }else{
            genre_flag = true
        }
        
        if(selected_options.count<1){
             MyConstants.display_alert(msg_title: "Error", msg_desc: "Select Primary Genre", action_title: "Try again", navpop: true, myVC: self)
        }else{
            option_flag = true
        }
        
        if(artist_flag == true && genre_flag == true && option_flag == true){
            let artist_name = artist_nm_txt_ref.text!
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = artist_name
            changeRequest?.commitChanges { (error) in
                if let error = error{
                    self.myActivityIndicator.stopAnimating()
                     MyConstants.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", navpop: true, myVC: self)
                }
            }
            
            var artist_option = ""
            for option in selected_options{
                artist_option = artist_option + option
                artist_option = artist_option + "-"
            }
            artist_option.removeLast()
            let genre = selectedGenre
            self.view.endEditing(true)
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            let profile: [String: Any] = ["artist_name": artist_name, "artist_option": artist_option, "genre": genre]
            userRef.child("profile").updateChildValues(profile, withCompletionBlock: { (error, reference) in
                if let error = error
                {
                    self.myActivityIndicator.stopAnimating()
                    MyConstants.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", navpop: true, myVC: self)
                }
                else
                {
                    self.myActivityIndicator.stopAnimating()
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "managetutorialscreenvcsid") as! ManageTutorialScreenVC
//                    self.present(vc, animated: false, completion: nil)
                    MyVariables.home_tutorial = false
                    MyVariables.play_tutorial = false
                    MyVariables.market_tutorial = false
                    MyVariables.lyrics_tutorial = false
                    MyVariables.record_tutorial = false
                    self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
                    // MyVariables.goto_home_from_form = true
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home_tabBar_sid") as! UITabBarController
                    Mixpanel.mainInstance().track(event: "Daily Signups")
                    UIApplication.shared.keyWindow?.rootViewController = vc
                    //self.present(vc, animated: false, completion: nil)
                }
            })
        }else{
            myActivityIndicator.stopAnimating()
        }
    }
    
    //MARK: - For Picker View
    
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

    //MARK: - Close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
