//
//  create_lyrics_VC.swift
//  Tully Dev
//
//  Created by macbook on 5/24/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import Mixpanel
import SQLite

protocol fromLyricsRecording{
    func comeFromLyricsRecording(isCorrect : Bool)
}

class create_lyrics_VC: UIViewController ,UITextViewDelegate, selectedDataProtocol {
    
    //________________________________ Outlets  ___________________________________
    @IBOutlet var heading_project_name: UILabel!
    @IBOutlet var heading_project_view: UIView!
    @IBOutlet var heading_lyrics_rhyme_view: UIView!
    @IBOutlet var heading_lyrics_create_view: UIView!
    @IBOutlet var lyrics_txtview_ref: CustomTextField!
    
    @IBOutlet var lyrics_txtview_upperview_ref: UIView!
    var comeFromLyricsRecordingVC = false
    //________________________________ Variables  ___________________________________
    
    var start_index = 0
    var selectedText_length = 0
    var main_string = ""
    var update_flag = false
    var update_key = ""
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var flag_update_data = false
    var current_project = ""
    var selected_project_key = ""
    var count_character = 0
    var open_lyrics_rythm = false
    //var force_touch_click = false
    var current_project_name = ""
    var backpress = false
    var old_string = ""
    var fromLyricsRecording : fromLyricsRecording?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "lyricsTabSelected")
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        self.myActivityIndicator.startAnimating()
        
        if(current_project != "" && current_project != "no_project")
        {
            //self.check_project()
            print(current_project)
             self.selected_project_key = current_project
            update_flag = true
        }
        
        //let textViewRecognizer = UITapGestureRecognizer()
        //textViewRecognizer.addTarget(self, action: #selector(tappedTextView(_:)))
        //lyrics_txtview_upperview_ref.addGestureRecognizer(textViewRecognizer)
        
        self.lyrics_txtview_ref.becomeFirstResponder()
        self.lyrics_txtview_ref.delegate = self
        self.myActivityIndicator.stopAnimating()
        
        NotificationCenter.default.addObserver(self, selector: #selector(create_lyrics_VC.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(create_lyrics_VC.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        if(update_flag)
        {
            lyrics_txtview_ref.text = main_string
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        lyrics_txtview_ref.currentState = .paste
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
        if(current_project == "")
        {
            heading_lyrics()
        }
        else
        {
            heading_project()
        }
    }
    
    func heading_lyrics()
    {
        heading_lyrics_create_view.alpha = 1.0
        heading_lyrics_rhyme_view.alpha = 0.0
        heading_project_view.alpha = 0.0
    }
    
    func heading_lyrics_rhyme()
    {
        heading_lyrics_create_view.alpha = 0.0
        heading_lyrics_rhyme_view.alpha = 1.0
        heading_project_view.alpha = 0.0
    }
    
    func heading_project()
    {
        heading_lyrics_create_view.alpha = 1.0
        heading_lyrics_rhyme_view.alpha = 0.0
        heading_project_view.alpha = 1.0
        heading_project_name.text = current_project_name
    }
    
    func updateTextView(notification : Notification)
    {
        let userInfo = notification.userInfo!
        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            lyrics_txtview_ref.contentInset = UIEdgeInsets.zero
        }else
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
                if let textRange = lyrics_txtview_ref.selectedTextRange
                {
                    
                    var selectedText = lyrics_txtview_ref.text(in: textRange)
                    
                    if (selectedText != nil && !(selectedText?.isEmpty)! && open_lyrics_rythm == false && (!(selectedText?.contains(" "))!))
                    {
                        
                    if(Reachability.isConnectedToNetwork())
                    {
                       selectedText = selectedText?.replacingOccurrences(of: "\n", with: "")
                        let len = selectedText!.count
                        heading_lyrics_rhyme()
                        if(len > 0)
                        {
                            //lyrics_txtview_ref.currentState = .copy
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
                            MyVariables.lyticsTextCopy = old_string
                            
                            open_lyrics_rythm = true
                            //view.endEditing(true)
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
                            heading_lyrics_rhyme()
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
                        
                                let attributes = [NSForegroundColorAttributeName: UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 17.0)!] as [String : Any]
                                attributedString.addAttributes(attributes, range: txt_view_range)
                                
                                let attributes_selected = [NSForegroundColorAttributeName: UIColor.white, NSBackgroundColorAttributeName: UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1)] as [String : Any]
                                attributedString.addAttributes(attributes_selected , range: myrange)
                                lyrics_txtview_ref.currentState = .none
                                lyrics_txtview_ref.attributedText = attributedString
                                old_string = selectedText!
                                MyVariables.lyticsTextCopy = old_string
                                
                                open_lyrics_rythm = true
                                let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataMouseData_sid") as! DataMouseVC
                                popvc.myProtocol = self
                                popvc.mySelectedWord = selectedText!
                                self.addChildViewController(popvc)
                                popvc.view.frame = self.view.frame
                                lyrics_txtview_ref.currentState = .none
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
        flag_update_data = true
        count_character = count_character + 1
        
        if(count_character == 50){
            self.count_character = 0
            if(Reachability.isConnectedToNetwork())
            {
                self.save_lyrics()
                self.update_flag = true
            }
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
                lyrics_txtview_ref.currentState = .select
                //lyrics_txtview_ref.currentState = .all
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
    
    @IBAction func close_create_lyrics(_ sender: Any)
    {
        if(flag_update_data)
        {
            if(lyrics_txtview_ref.text != "")
            {
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
                
                save_lyrics()
            }
        }
        
        
        if(comeFromLyricsRecordingVC){
            self.fromLyricsRecording?.comeFromLyricsRecording(isCorrect: true)
            dismiss(animated: true, completion: nil)
        }else{
            self.fromLyricsRecording?.comeFromLyricsRecording(isCorrect: false)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func save_lyrics(_ sender: Any)
    {
        if(flag_update_data)
        {
            if(lyrics_txtview_ref.text != "")
            {
                save_lyrics()
            }
        }
        
        if(comeFromLyricsRecordingVC){
            self.fromLyricsRecording?.comeFromLyricsRecording(isCorrect: true)
            dismiss(animated: true, completion: nil)
        }else{
            self.fromLyricsRecording?.comeFromLyricsRecording(isCorrect: false)
            dismiss(animated: true, completion: nil)
        }
        
        
//        if(comeFromLyricsRecordingVC){
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LyricsVC_sid") as! create_lyrics_VC
//            present(vc, animated: false, completion: nil)
//
//        }else{
//
//        }
        
    }
    
    func save_lyrics()
    {
        if(lyrics_txtview_ref.text != "")
        {
            if(current_project == "" || current_project == "no_project")
            {
                if(update_flag)
                {
                    no_project_update_lyrics()
                }
                else
                {
                    no_project_insert_lyrics()
                }
            }
            else
            {
                if(selected_project_key == "")
                {
                    self.display_alert(msg_title:  "Server Error", msg_desc: "Can't create project", action_title: "try again")
                   // _ = check_project()
                }
                else
                {
                    if(update_flag)
                    {
                        update_lyrics()
                    }
                    else
                    {
                        insert_lyrics()
                    }
                }
            }
        }
        else
        {
            self.display_alert(msg_title: "Required !", msg_desc: "Write Lyrics.", action_title: "Ok")
        }
    }
    
    func no_project_insert_lyrics()
    {
        self.myActivityIndicator.startAnimating()
        DispatchQueue.main.async
        {
                let lyrics_data: [String: Any] = ["desc": self.lyrics_txtview_ref.text]
                let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                let mykey = userRef.child("no_project").child("lyrics").childByAutoId().key
                self.update_key = mykey
                userRef.child("no_project").child("lyrics").child(mykey).setValue(lyrics_data, withCompletionBlock: { (error, database) in
                    
                    if let error = error
                    {
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                        self.myActivityIndicator.stopAnimating()
                    }else{
                        Mixpanel.mainInstance().track(event: "Writing lyrics")
                        self.flag_update_data = true
                        self.myActivityIndicator.stopAnimating()
                    }
                    
                })
        }
    }
    
    func no_project_update_lyrics()
    {
        self.myActivityIndicator.startAnimating()
        DispatchQueue.main.async
        {
                let lyrics_data: [String: Any] = ["desc": self.lyrics_txtview_ref.text]
                let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                userRef.child("no_project").child("lyrics").child(self.update_key).updateChildValues(lyrics_data, withCompletionBlock: { (error, database_ref) in
                    
                    if let error = error
                    {
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                        self.myActivityIndicator.stopAnimating()
                    }
                    else
                    {
                        //self.display_alert(msg_title: "Updated", msg_desc: "Updated Successfully", action_title: "OK")
                        Mixpanel.mainInstance().track(event: "Update lyrics")
                        self.flag_update_data = false
                        self.myActivityIndicator.stopAnimating()
                    }
                })
        }
    }
    
    
    func insert_lyrics()
    {
        myActivityIndicator.startAnimating()
        DispatchQueue.main.async
        {
                let lyrics_data: [String: Any] = ["desc": self.lyrics_txtview_ref.text]
                let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                
                if(self.selected_project_key != "")
                {
                    let mykey = userRef.child("projects").child(self.selected_project_key).child("lyrics").childByAutoId().key
                    self.update_key = mykey
                userRef.child("projects").child(self.selected_project_key).child("lyrics").child(mykey).setValue(lyrics_data, withCompletionBlock: { (error, database_ref) in
                        
                        if let error = error
                        {
                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                            self.flag_update_data = true
                            self.myActivityIndicator.stopAnimating()
                        }
                        else
                        {
                            Mixpanel.mainInstance().track(event: "Writing lyrics in project")
                            self.flag_update_data = false
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
        DispatchQueue.main.async
        {
                let lyrics_data: [String: Any] = ["desc": self.lyrics_txtview_ref.text]
                let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                
                if(self.selected_project_key != "")
                {
                userRef.child("projects").child(self.selected_project_key).child("lyrics").child(self.update_key).updateChildValues(lyrics_data, withCompletionBlock: { (error, database_ref) in
                        
                        if let error = error
                        {
                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                            self.myActivityIndicator.stopAnimating()
                        }
                        else
                        {
                            Mixpanel.mainInstance().track(event: "Update lyrics in project")
                            self.flag_update_data = false
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
    
    
    
    func getSelectedString(selectedWord : String)
    {
        
        DispatchQueue.main.async {
           // let newIndex = self.start_index + self.selectedText_length
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
        }
        
        
        if(current_project == "")
        {
            heading_lyrics()
        }
        else
        {
            heading_project()
        }
        flag_update_data = true
        open_lyrics_rythm = false
        lyrics_txtview_ref.currentState = .select
        //lyrics_txtview_ref.currentState = .all
        //force_touch_click = false
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        myActivityIndicator.stopAnimating()
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


