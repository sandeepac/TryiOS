//
//  BigLyricsVC.swift
//  Tully Dev
//
//  Created by macbook on 6/27/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import Mixpanel

protocol send_lyrics_data
{
    func lyrics_info(lyrics_data : String, lyrics_id : String)
}

class BigLyricsVC: UIViewController , UITextViewDelegate, selectedDataProtocol
{

    @IBOutlet var lyrics_txtview_upperview_ref: UIView!
    @IBOutlet var lyrics_txtview_ref: CustomTextField!
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var main_string = ""
    var start_index = 0
    var selectedText_length = 0
    var lyrics_key = ""
    
    var get_data : String = ""
    var project_key : String = ""
    var lyrics_data_ptotocol : send_lyrics_data?
    var count_character = 0
    var open_lyrics_rythm = false
    var backpress = false
    var old_string = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        
        self.lyrics_txtview_ref.becomeFirstResponder()
        self.lyrics_txtview_ref.delegate = self
        self.myActivityIndicator.stopAnimating()
        
        NotificationCenter.default.addObserver(self, selector: #selector(create_lyrics_VC.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(create_lyrics_VC.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        lyrics_txtview_ref.text = main_string

    }
    
    override func viewWillAppear(_ animated: Bool) {
        lyrics_txtview_ref.currentState = .paste
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
        if(get_data != "")
        {
            lyrics_txtview_ref.text = get_data
        }
    }
    
    func updateTextView(notification : Notification)
    {
        let userInfo = notification.userInfo!
        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            lyrics_txtview_ref.contentInset = UIEdgeInsets.zero
        }
        else
        {
            lyrics_txtview_ref.contentInset = UIEdgeInsetsMake(0, 0, keyboardEndFrame.height, 0)
            lyrics_txtview_ref.scrollIndicatorInsets = lyrics_txtview_ref.contentInset
        }
        lyrics_txtview_ref.scrollRangeToVisible(lyrics_txtview_ref.selectedRange)
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView)
    {
        if(!backpress)
        {
            do
            {
                if let textRange = lyrics_txtview_ref.selectedTextRange {
                    
                    var selectedText = lyrics_txtview_ref.text(in: textRange)
                    
                    if (selectedText != nil && !(selectedText?.isEmpty)! && open_lyrics_rythm == false && (!(selectedText?.contains(" "))!))
                    {
                        if(Reachability.isConnectedToNetwork())
                        {
                        selectedText = selectedText?.replacingOccurrences(of: "\n", with: "")
                        let len = selectedText!.count
                        
                        if(len > 0)
                        {
                            
                            selectedText_length = len
                            main_string = lyrics_txtview_ref.text
                            
                            start_index = lyrics_txtview_ref.offset(from: lyrics_txtview_ref.beginningOfDocument, to: textRange.start)
                            
                            if(start_index == 0)
                            {
                                main_string = " " + main_string
                                start_index = start_index + 1
                            }
                            
                            let myrange = NSMakeRange(start_index, selectedText_length)
                            let attributedString = NSMutableAttributedString(string:main_string)
                            selectedText = selectedText?.replacingOccurrences(of: "\n", with: "")
                            let txt_view_range = NSMakeRange(0, (main_string.count))
                            lyrics_txtview_ref.currentState = .none
                            let attributes = [NSForegroundColorAttributeName: UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 17.0)!] as [String : Any]
                            attributedString.addAttributes(attributes, range: txt_view_range)
                            
                            let attributes_selected = [NSForegroundColorAttributeName: UIColor.white, NSBackgroundColorAttributeName: UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1)] as [String : Any]
                            attributedString.addAttributes(attributes_selected , range: myrange)
                            lyrics_txtview_ref.attributedText = attributedString
                            old_string = selectedText!
                            open_lyrics_rythm = true
                            let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataMouseData_sid") as! DataMouseVC
                            popvc.myProtocol = self
                            popvc.mySelectedWord = selectedText!
                            self.addChildViewController(popvc)
                            popvc.view.frame = self.view.frame
                            self.view.addSubview(popvc.view)
                            popvc.didMove(toParentViewController: self)
                            
                        }
                        }
                        else
                        {
                            selectedText = selectedText?.replacingOccurrences(of: "\n", with: "")
                            let len = selectedText!.count
                            
                            if(len > 0)
                            {
                                
                                selectedText_length = len
                                main_string = lyrics_txtview_ref.text
                                start_index = lyrics_txtview_ref.offset(from: lyrics_txtview_ref.beginningOfDocument, to: textRange.start)
                                
                                if(start_index == 0)
                                {
                                    main_string = " " + main_string
                                    start_index = start_index + 1
                                }
                                
                                let myrange = NSMakeRange(start_index, selectedText_length)
                                let attributedString = NSMutableAttributedString(string:main_string)
                                
                                let txt_view_range = NSMakeRange(0, (main_string.count))
                                
                                lyrics_txtview_ref.currentState = .none
                                let attributes = [NSForegroundColorAttributeName: UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 17.0)!] as [String : Any]
                                attributedString.addAttributes(attributes, range: txt_view_range)
                                
                                let attributes_selected = [NSForegroundColorAttributeName: UIColor.white, NSBackgroundColorAttributeName: UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1)] as [String : Any]
                                attributedString.addAttributes(attributes_selected , range: myrange)
                                
                                lyrics_txtview_ref.attributedText = attributedString
                                old_string = selectedText!
                                open_lyrics_rythm = true
                                let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataMouseData_sid") as! DataMouseVC
                                popvc.myProtocol = self
                                popvc.mySelectedWord = selectedText!
                                self.addChildViewController(popvc)
                                popvc.view.frame = self.view.frame
                                self.view.addSubview(popvc.view)
                                popvc.didMove(toParentViewController: self)
                                
                            }
                            
                        }
                        
                    }
                    else
                    {
                        main_string = lyrics_txtview_ref.text
                    }
                }
            }
            //catch{}
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //flag_update_data = true
        count_character = count_character + 1
        
        if(count_character == 50){
            self.count_character = 0
            if(Reachability.isConnectedToNetwork())
            {
                self.save_lyrics()
            }
            
            //self.update_flag = true
        }
        
        let  char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            lyrics_txtview_upperview_ref.alpha = 1.0
            backpress = true
        }
        else
        {
            backpress = false
            if(open_lyrics_rythm)
            {
                if self.childViewControllers.count > 0{
                    let viewControllers:[UIViewController] = self.childViewControllers
                    for viewContoller in viewControllers{
                        viewContoller.willMove(toParentViewController: nil)
                        viewContoller.view.removeFromSuperview()
                        viewContoller.removeFromParentViewController()
                    }
                }
                let attributedString = NSMutableAttributedString(string:main_string)
                let txt_view_range = NSMakeRange(0, (main_string.count))
                
                let attributes = [NSForegroundColorAttributeName: UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 17.0)!] as [String : Any]
                attributedString.addAttributes(attributes, range: txt_view_range)
                lyrics_txtview_ref.attributedText = attributedString
                open_lyrics_rythm = false
            }
        }
        return true
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backpress = false
        lyrics_txtview_upperview_ref.alpha = 0.0
        //self.lyrics_txtview_ref.resignFirstResponder()
    }
    
    
    func getSelectedString(selectedWord : String)
    {
        DispatchQueue.main.async {
            let range = NSRange(location: self.start_index, length: self.selectedText_length)
            
            let newRange = Range(range, in: self.main_string)
            
            let new_text = self.main_string.replacingOccurrences(of: self.old_string, with: selectedWord, options: String.CompareOptions.caseInsensitive, range: newRange)
            let attributedString1 = NSMutableAttributedString(string:new_text)
            let txt_view_range1 = NSMakeRange(0, (new_text.count))
            let attributes1 = [NSForegroundColorAttributeName: UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 17.0)!] as [String : Any]
            attributedString1.addAttributes(attributes1, range: txt_view_range1)
            self.lyrics_txtview_ref.attributedText = attributedString1
            self.lyrics_txtview_ref.text = new_text
            
            self.main_string = new_text.trimmingCharacters(in: .whitespaces)
            
            let attributedString = NSMutableAttributedString(string:self.main_string)
            let txt_view_range = NSMakeRange(0, (self.main_string.count))
            
            let attributes = [NSForegroundColorAttributeName: UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 17.0)!] as [String : Any]
            attributedString.addAttributes(attributes, range: txt_view_range)
            self.lyrics_txtview_ref.attributedText = attributedString
            self.open_lyrics_rythm = false
            self.lyrics_txtview_ref.currentState = .select
        }
        
    }
    
    
    @IBAction func close_view(_ sender: Any) {
        let total_count = lyrics_txtview_ref.text.count
        if(total_count >= 100 && total_count < 250)
        {
            Mixpanel.mainInstance().track(event: "100 word count")
        }
        else if(total_count >= 250 && total_count < 500)
        {
            Mixpanel.mainInstance().track(event: "250 word count")
        }
        else if(total_count >= 500)
        {
            Mixpanel.mainInstance().track(event: "500+ word count")
        }
        lyrics_data_ptotocol?.lyrics_info(lyrics_data: lyrics_txtview_ref.text, lyrics_id: lyrics_key)
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save_create_lyrics(_ sender: Any) {
        save_lyrics()
        lyrics_data_ptotocol?.lyrics_info(lyrics_data: lyrics_txtview_ref.text, lyrics_id: lyrics_key)
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
        
    }
    
    func save_lyrics()
    {
        if(lyrics_key == ""){
            insert_lyrics()
        }else{
            update_lyrics()
        }
    }
    
    func insert_lyrics()
    {
        myActivityIndicator.startAnimating()
        DispatchQueue.main.async
        {
                let lyrics_data: [String: Any] = ["desc": self.lyrics_txtview_ref.text]
                let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                
                if(self.project_key != "")
                {
                    let mykey = userRef.child("projects").child(self.project_key).child("lyrics").childByAutoId().key
                userRef.child("projects").child(self.project_key).child("lyrics").child(mykey).setValue(lyrics_data, withCompletionBlock: { (error, database_ref) in
                        
                        if let error = error{
                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                            self.myActivityIndicator.stopAnimating()
                        }else{
                            Mixpanel.mainInstance().track(event: "Writing lyrics in project")
                            self.myActivityIndicator.stopAnimating()
                        }
                    })
                }
                else
                {
                    self.display_alert(msg_title: "Project Not Found", msg_desc: "Can't found project.", action_title: "OK")
                }
        }
    }
    
   
    
    func update_lyrics()
    {
        myActivityIndicator.startAnimating()
        
         
        let lyrics_data: [String: Any] = ["desc": self.lyrics_txtview_ref.text]
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            
            if(self.project_key != "")
            {
                userRef.child("projects").child(self.project_key).child("lyrics").child(self.lyrics_key).updateChildValues(lyrics_data, withCompletionBlock: { (error, database_ref) in
                    
                    if let error = error
                    {
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                        self.myActivityIndicator.stopAnimating()
                    }
                    else
                    {
                        //self.dismiss(animated: true, completion: nil)
                       // self.flag_update_data = false
                        Mixpanel.mainInstance().track(event: "Update lyrics in project")
                        self.myActivityIndicator.stopAnimating()
                    }
                })
            }
            else
            {
                self.display_alert(msg_title: "Project Not Found", msg_desc: "Can't found project.", action_title: "OK")
            }
        
    }
    
    // Display Alert
    
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

