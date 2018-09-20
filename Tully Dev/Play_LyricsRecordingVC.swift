
//
//  PlayLyricsRecordingVC.swift
//  Tully Dev
//
//  Created by macbook on 6/22/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import SCSiriWaveformView
import Mixpanel
import CoreBluetooth

protocol get_lyrics_data_protocol {
    func lyrics_data(lyrics_key : String, lyrics_txt : String, count_recording : Int,repeat_play_data : Bool, is_looping : Bool, looping_start_index : Int, looping_end_index : Int)
}

class Play_LyricsRecordingVC: UIViewController, UITextViewDelegate, selectedDataProtocol, send_lyrics_data, AVAudioPlayerDelegate, AVAudioRecorderDelegate, CBCentralManagerDelegate, myProtocol, looping_protocol
{
    
    
    @IBOutlet weak var recording_view_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var display_key_lbl: UILabel!
    @IBOutlet weak var display_bpm_lbl: UILabel!
    @IBOutlet weak var display_bpm_view_ref: UIView!
    @IBOutlet var bottom_layout_of_recording_constraint: NSLayoutConstraint!
    
    @IBOutlet var lyrics_txtview_upperview_ref: UIView!
    @IBOutlet var audioWaveView: SCSiriWaveformView!
    @IBOutlet var heading_writing_view: UIView!
    @IBOutlet var audio_file_name_lbl_ref: UILabel!
    @IBOutlet var project_name_lbl_ref: UILabel!
    @IBOutlet var heading_recording_view: UIView!
    @IBOutlet var heading_lyrics_view: UIView!
    @IBOutlet var recording_img_ref: UIImageView!
    @IBOutlet var note_img_ref: UIImageView!
    @IBOutlet var no_of_recording_view_ref: UIView!
    @IBOutlet var lyrics_txtview_ref: CustomTextField!
    @IBOutlet var whole_view_ref: UIView!
    @IBOutlet var play_recording_view: UIView!
    @IBOutlet var audio_scrubber_ref: MyHalfSlider!
    
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    @IBOutlet var audio_bg_img_ref: UIImageView!
    @IBOutlet var no_of_recording_lbl_ref: UILabel!
    @IBOutlet var record_img_ref: UIImageView!
    @IBOutlet var end_time_lbl: UILabel!
    @IBOutlet var start_time_lbl: UILabel!
    @IBOutlet var play_btn_ref: UIButton!
    @IBOutlet var record_btn_ref: UIButton!
    @IBOutlet var recording_view_ref: UIView!
    @IBOutlet var recording_time_lbl_ref: UILabel!
    @IBOutlet var recording_play_pause_img_ref: UIImageView!
    @IBOutlet var bottom_note_img_width_constraint: NSLayoutConstraint!
    
    @IBOutlet var loop_img_ref: UIImageView!
    @IBOutlet var bottom_record_img_height_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_record_img_width_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_play_img_width_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_play_img_height_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_note_img_height_constraint: NSLayoutConstraint!
    
    var collabration = String()
    var selected_project_key = ""
    var selected_project_name = ""
    var selected_audio_file_name = ""
    var flag_update_data = false
    var start_index = 0
    var selectedText_length = 0
    var main_string = ""
    var lyrics_key = ""
    var lyrics_text = ""
    var lyrics_save_flag = false
    var open_big_lyrics_flag = false
    var close_view_flag = false
    var update_flag = false
    var project_desc = ""
    var get_lyrics_data_protocolobj : get_lyrics_data_protocol?
    var flag_open_recording_view = false
    var repeat_play = false
    var recording_file_url : URL? = nil
    var audioPlayer : AVAudioPlayer!
    var current_playing = false
    var initialize_audio = false
    var timer = Timer()
    var count_recordings = 0
    var auto_start_record = false
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted = false
    var isRecording = false
    var meterTimer:Timer!
    var flag_lyrics_from_another_tab = true
    var end_time:Float = 0.0
    var count_character = 0
    var open_lyrics_rythm = false
    var backpress = false
    var first_check_and_open = false
    var waveTimer : Timer!
    var goto_big_lyrics = false
    var keyboardHeight : CGFloat = 0.0
    
    
    @IBOutlet var whole_view_bottom_constraint: NSLayoutConstraint!
    @IBOutlet var loop_lbl_ref: UILabel!
    
    var manager:CBCentralManager!
    var flag_bluetooth = false
    var dest_path : URL? = nil
    var audio_sticks = ""
    
    //For Looping
    
    var is_looping = false
    var looping_start_index = 0
    var looping_end_index = 0
    var old_string = ""
    
    var selectedKey = ""
    var selectedBPM = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //if collabration = ""
        manager = CBCentralManager(delegate: self, queue: nil, options: nil)
        manager.delegate = self
        let screenWidth = UIScreen.main.bounds.width
        var height_width = ((screenWidth / 5) - 8)
        
        if(height_width >= 53)
        {
            height_width = 52
        }
        
        bottom_note_img_width_constraint.constant = height_width
        bottom_note_img_height_constraint.constant = height_width
        bottom_play_img_width_constraint.constant = height_width
        bottom_play_img_height_constraint.constant = height_width
        bottom_record_img_width_constraint.constant = height_width
        bottom_record_img_height_constraint.constant = height_width
        
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        audio_scrubber_ref.setMaximumTrackImage(UIImage(named: "remaining_track_color"), for: .normal)
        audio_scrubber_ref.addTarget(self, action: #selector(self.updateSliderLabelInstant(sender:)), for: .allEvents)
        note_img_ref.image = UIImage(named: "note-blue")
        self.lyrics_txtview_ref.delegate = self
        
        if(lyrics_key != "" && lyrics_text != "")
        {
            lyrics_txtview_ref.text = lyrics_text
        }
        no_of_recording_view_ref.layer.cornerRadius = 6
        get_num_of_audio_in_project()
        
        self.myActivityIndicator.stopAnimating()
        keyboardHeight = KeyboardService.keyboardHeight()
        recording_view_height_constraint.constant = keyboardHeight
        self.view.layoutIfNeeded()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(Play_LyricsRecordingVC.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Play_LyricsRecordingVC.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        check_record_permission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
        lyrics_txtview_ref.currentState = .paste
        self.tabBarController?.tabBar.items![1].image = UIImage(named: "Play_Selected_tab")
        self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Home_tab")
        
        goto_big_lyrics = false
        
        if(selectedKey == ""){
            display_bpm_view_ref.alpha = 0.0
        }else{
            display_bpm_view_ref.alpha = 1.0
            display_key_lbl.text = selectedKey
            display_bpm_lbl.text = String(selectedBPM)
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if(!isAudioRecordingGranted){
            check_record_permission()
        }
        
        project_name_lbl_ref.text = selected_project_name
        audio_file_name_lbl_ref.text = selected_audio_file_name
        if(auto_start_record){
            record_btn_click_fun()
        }
        else
        {
            if(flag_lyrics_from_another_tab)
            {
                heading_lyrics()
                UIView.animate(withDuration: 0.1, animations : {
                    self.note_img_ref.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.lyrics_txtview_ref.becomeFirstResponder()
                }, completion: {(finished : Bool) in
                    if(finished)
                    {
                        UIView.animate(withDuration: 0.5, animations : {
                            self.note_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self.lyrics_txtview_ref.becomeFirstResponder()
                        }, completion: {(finished : Bool) in
                            if(finished)
                            {
                                self.note_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            }
                        })
                    }
                })
            }
        }
        
        
        if(is_looping){
            set_lbl_as_unloop()
        }else{
            set_lbl_as_loop()
        }
        
        if(!current_playing)
        {
            initialize_audio_and_play()
            initialize_audio = true
        }
    }
    
    // For check bluetooth is connected or not
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOff{
            flag_bluetooth = false
        }
        else{
            flag_bluetooth = true
        }
    }
    
    func heading_recording(){
        heading_recording_view.alpha = 1.0
        heading_lyrics_view.alpha = 0.0
        heading_writing_view.alpha = 0.0
    }
    
    func heading_lyrics(){
        heading_recording_view.alpha = 0.0
        heading_writing_view.alpha = 1.0
        heading_lyrics_view.alpha = 0.0
    }
    
    func heading_lyrics_select_word(){
        heading_recording_view.alpha = 0.0
        heading_writing_view.alpha = 0.0
        heading_lyrics_view.alpha = 1.0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(!isRecording){
            lyrics_save_flag = false
            heading_lyrics()
        }
        else{
            self.view.endEditing(true)
            whole_view_bottom_constraint.constant = 175.0 - (self.tabBarController?.tabBar.frame.height)!
            play_recording_view.alpha = 1.0
            flag_open_recording_view = true
        }
    }
    
    func updateTextView(notification : Notification){
        if(flag_open_recording_view){
            whole_view_bottom_constraint.constant = 40.0
            play_recording_view.alpha = 0.0
            flag_open_recording_view = false
        }
        
        let userInfo = notification.userInfo!
        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to: view.window)
        
        print(keyboardEndFrameScreenCoordinates.height)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            //lyrics_txtview_ref.contentInset = UIEdgeInsets.zero
            lyrics_txtview_ref.contentInset = UIEdgeInsetsMake(0, 0, keyboardEndFrame.height - 200, 0)
            whole_view_bottom_constraint.constant = 40.0
        }else{
            lyrics_txtview_ref.contentInset = UIEdgeInsetsMake(0, 0, keyboardEndFrame.height - 200, 0)
            lyrics_txtview_ref.scrollIndicatorInsets = lyrics_txtview_ref.contentInset
            whole_view_bottom_constraint.constant = keyboardEndFrame.height - 40
        }
        lyrics_txtview_ref.scrollRangeToVisible(lyrics_txtview_ref.selectedRange)
    }
    
    
    
    public func textViewDidChangeSelection(_ textView: UITextView)
    {
        lyrics_save_flag = false
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
                                //self.view.endEditing(true)
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
                    else{
                        main_string = lyrics_txtview_ref.text
                    }
                }
            }
        }
    }
    
    func insert_lyrics()
    {
        self.myActivityIndicator.startAnimating()
        if(self.lyrics_text == "")
        {
            self.display_alert(msg_title: "Can't null", msg_desc: "Please write something", action_title: "OK")
            self.myActivityIndicator.stopAnimating()
        }else{
            let lyrics_data: [String: Any] = ["desc": self.lyrics_text]
            if let uid = Auth.auth().currentUser?.uid{
                let userRef = FirebaseManager.getRefference().child(uid).ref
                if(self.selected_project_key != "")
                {
                    let mykey = userRef.child("projects").child(self.selected_project_key).child("lyrics").childByAutoId().key
                    self.lyrics_key = mykey
                 userRef.child("projects").child(self.selected_project_key).child("lyrics").child(mykey).setValue(lyrics_data, withCompletionBlock: { (error, database_ref) in
                        
                        if let error = error
                        {
                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                            self.myActivityIndicator.stopAnimating()
                        }
                        else
                        {
                            if(self.selected_audio_file_name == "Free Beat"){
                                Mixpanel.mainInstance().track(event: "Free Beat lyrics")
                            }
                            Mixpanel.mainInstance().track(event: "Writing lyrics in project")
                            self.lyrics_save_flag = true
                            self.myActivityIndicator.stopAnimating()
                        }
                    })
                }else{
                    self.display_alert(msg_title: "Project Not Found", msg_desc: "Can't found project.", action_title: "OK")
                    self.myActivityIndicator.stopAnimating()
                }
            }
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
                open_lyrics_rythm = false
            }
        }
        return true
    }
    
    @IBAction func save_lyrics(_ sender: Any)
    {
        if(initialize_audio){
            audio_complete()
        }
        view.endEditing(true)
        lyrics_text = lyrics_txtview_ref.text
        if(lyrics_save_flag)
        {
            self.close_view()
        }
        else
        {
            if(isRecording)
            {
                open_close_recording_view()
                lyrics_text = lyrics_txtview_ref.text
                self.tabBarController?.tabBar.isHidden = false
                
                finishAudioRecording(success: true)
                
                isRecording = false
                
                self.record_img_ref.image = UIImage(named : "recording-start")
                self.record_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.record_img_ref.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }, completion: { (isComplete) in
                    if(isComplete)
                    {
                        
                        self.record_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.audioWaveView.frequency = 0.0
                        self.save_project_recording()
                        
                    }
                })
            }
            else if(lyrics_text != "")
            {
                if(lyrics_key == "")
                {
                    insert_lyrics()
                    close_view_flag = true
                    if(!Reachability.isConnectedToNetwork())
                    {
                        close_view()
                        self.lyrics_save_flag = true
                    }
                    
                }
                else
                {
                    update_lyrics()
                    close_view()
                }
            }
            else
            {
                close_view()
            }
        }
    }
    
    func save_project_recording()
    {
        do
        {
            let fileDictionary = try FileManager.default.attributesOfItem(atPath: dest_path!.path)
            let fileSize = fileDictionary[FileAttributeKey.size]
            let mysize = fileSize as! Int64
            let file_name = "Recording " + String(count_recordings + 1)
            count_recordings = count_recordings + 1
            no_of_recording_lbl_ref.text = String(count_recordings)
            no_of_recording_view_ref.alpha = 1.0
            recording_img_ref.image = UIImage(named: "Recording_Selected_tab")
            let recording_data: [String: Any] = ["name": file_name, "tid": audio_sticks, "size":mysize]
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            
            let recording_key  = userRef.child("projects").child(self.selected_project_key).child("recordings").childByAutoId().key
            if(self.selected_project_key != "")
            {
                userRef.child("projects").child(self.selected_project_key).child("recordings").child(recording_key).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                    if let error = error
                    {
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                    if(self.selected_audio_file_name == "Free Beat"){
                        Mixpanel.mainInstance().track(event: "Free Beat Recording")
                    }
                    Mixpanel.mainInstance().track(event: "Recording in project")
                userRef.child("remaining_upload").child("projects").child(self.selected_project_key).child("recordings").child(recording_key).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                        
                        if let error = error{
                            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                            self.myActivityIndicator.stopAnimating()
                        }else{
                            self.myActivityIndicator.stopAnimating()
                        }
                    })
                    
                    FirebaseManager.sync_project_recording_file(myfilename_tid: self.audio_sticks, myfilePath: self.dest_path!, projectId: self.selected_project_key, rec_id: recording_key, delete_remaining: true)
                    
                })
            }
            else
            {
                self.display_alert(msg_title: "Project Not Found", msg_desc: "Can't found project.", action_title: "OK")
            }
            
            if(!Reachability.isConnectedToNetwork())
            {
            userRef.child("remaining_upload").child("projects").child(self.selected_project_key).child("recordings").child(recording_key).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                    
                    if let error = error
                    {
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                })
            }
        }
        catch let error as NSError {
            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
        }
    }
    
    func save_lyrics()
    {
        lyrics_text = lyrics_txtview_ref.text
        if(!lyrics_save_flag)
        {
            if(lyrics_text != "")
            {
                if(lyrics_key == "")
                {
                    insert_lyrics()
                }
                else
                {
                    update_lyrics()
                }
            }
        }
    }
    
    
    func update_lyrics()
    {
        myActivityIndicator.startAnimating()
        
        if let uid = Auth.auth().currentUser?.uid{
            let lyrics_data: [String: Any] = ["desc": self.lyrics_text]
            let userRef = FirebaseManager.getRefference().child(uid).ref
            
            if(self.selected_project_key != "")
            {
            userRef.child("projects").child(self.selected_project_key).child("lyrics").child(self.lyrics_key).updateChildValues(lyrics_data, withCompletionBlock: { (error, database_ref) in
                    
                    if let error = error{
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                        self.myActivityIndicator.stopAnimating()
                    }else{
                        Mixpanel.mainInstance().track(event: "Update lyrics in project")
                        self.lyrics_save_flag = true
                        if(self.open_big_lyrics_flag){
                            self.open_big_lyrics()
                        }
                        self.myActivityIndicator.stopAnimating()
                    }
                })
            }
            else
            {
                self.display_alert(msg_title: "Project Not Found", msg_desc: "Can't found project.", action_title: "OK")
                self.myActivityIndicator.stopAnimating()
            }
        }
    }
    
    func close_view()
    {
        if(initialize_audio){
            audio_complete()
        }
        
        if(isRecording)
        {
            open_close_recording_view()
            lyrics_text = lyrics_txtview_ref.text
            self.tabBarController?.tabBar.isHidden = false
            
            finishAudioRecording(success: true)
            isRecording = false
            
            self.record_img_ref.image = UIImage(named : "recording-start")
            self.record_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.record_img_ref.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: { (isComplete) in
                if(isComplete)
                {
                    self.open_big_lyrics_flag = false
                    self.record_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.audioWaveView.frequency = 0.0
                    self.save_project_recording()
                    if(self.lyrics_key != "")
                    {
                        self.get_lyrics_data_protocolobj?.lyrics_data(lyrics_key: self.lyrics_key, lyrics_txt: self.lyrics_text, count_recording: self.count_recordings, repeat_play_data: self.repeat_play, is_looping: self.is_looping, looping_start_index: self.looping_start_index, looping_end_index: self.looping_end_index)
                    }
                }
            })
            
        }else{
            if(lyrics_key != "")
            {
                get_lyrics_data_protocolobj?.lyrics_data(lyrics_key: lyrics_key, lyrics_txt: lyrics_text, count_recording: count_recordings, repeat_play_data: repeat_play, is_looping: self.is_looping, looping_start_index: self.looping_start_index, looping_end_index: self.looping_end_index)
            }
        }
        flag_lyrics_from_another_tab = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func full_screen_lyrics(_ sender: Any)
    {
        view.endEditing(true)
        self.flag_lyrics_from_another_tab = false
        lyrics_text = lyrics_txtview_ref.text
        
        if(isRecording)
        {
            open_close_recording_view()
            lyrics_text = lyrics_txtview_ref.text
            self.tabBarController?.tabBar.isHidden = false
            
            finishAudioRecording(success: true)
            isRecording = false
            
            self.record_img_ref.image = UIImage(named : "recording-start")
            self.record_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.open_big_lyrics_flag = true
            self.record_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.audioWaveView.frequency = 0.0
            self.save_project_recording()
            self.open_big_lyrics()
            
        }else{
            if(lyrics_save_flag){
                open_big_lyrics()
            }else{
                if(lyrics_text != ""){
                    if(lyrics_key == ""){
                        open_big_lyrics_flag = true
                        insert_lyrics()
                    }else{
                        open_big_lyrics_flag = true
                        update_lyrics()
                    }
                }
                self.open_big_lyrics()
            }
        }
    }
    
    func open_big_lyrics()
    {
        goto_big_lyrics = true
        open_big_lyrics_flag = false
        let vc : BigLyricsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "big_lyrics_sid") as! BigLyricsVC
        vc.lyrics_data_ptotocol = self
        vc.project_key = selected_project_key
        vc.get_data = lyrics_txtview_ref.text
        vc.lyrics_key = lyrics_key
        self.present(vc, animated: true, completion: nil)
    }
    
    func initialize_audio_and_play()
    {
        if  let audio_url = recording_file_url
        {
            if FileManager.default.fileExists(atPath: audio_url.path)
            {
                do
                {
                    audioPlayer = try AVAudioPlayer(contentsOf: audio_url)
                    audioPlayer.delegate = self
                    audioPlayer.play()
                    scrubber_init()
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Play_LyricsRecordingVC.update_scrubber), userInfo: nil, repeats: true)
                    current_playing = true
                    recording_play_pause_img_ref.image = UIImage(named: "pause")
                }
                catch
                {
                    display_alert(msg_title: "Not Found", msg_desc: "File not found.", action_title: "OK")
                }
            }
            else
            {
                display_alert(msg_title: "Not Found", msg_desc: "File not found.", action_title: "OK")
            }
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Can't get file path", action_title: "OK")
        }
    }
    
    @IBAction func play_btn_click(_ sender: Any)
    {
        if(initialize_audio)
        {
            if(current_playing)
            {
                if let player = audioPlayer{
                    player.pause()
                }
                current_playing = false
                recording_play_pause_img_ref.image = UIImage(named: "green-play")
            }
            else
            {
                if let player = audioPlayer{
                    player.play()
                }
                current_playing = true
                recording_play_pause_img_ref.image = UIImage(named: "pause")
            }
        }
        else
        {
            initialize_audio_and_play()
            initialize_audio = true
        }
    }
    
    func scrubber_init()
    {
        if(looping_end_index == 0){
            end_time = Float(audioPlayer.duration)
        }else{
            end_time = Float(looping_end_index)
        }
        
        
        if(is_looping){
            audio_scrubber_ref.minimumValue = Float(looping_start_index)
            audio_scrubber_ref.maximumValue = Float(looping_end_index)
            audioPlayer.currentTime = TimeInterval(looping_start_index)
            start_time_lbl.text = time_to_string(seconds: looping_start_index)
            end_time_lbl.text = "-" + time_to_string(seconds: Int(looping_end_index))
        }else{
            audio_scrubber_ref.minimumValue = 0.0
            audio_scrubber_ref.maximumValue = end_time
            start_time_lbl.text = time_to_string(seconds: 0)
            end_time_lbl.text = "-" + time_to_string(seconds: Int(end_time))
        }
        
    }
    
    func update_scrubber()
    {
        let current_time = Float(audioPlayer.currentTime)
        audio_scrubber_ref.value = current_time
        start_time_lbl.text = time_to_string(seconds: Int(current_time))
        
        
        if(looping_end_index == 0){
            let audio_remaining_seconds = Int (audioPlayer.duration) - Int(current_time)
            if(audio_remaining_seconds == 0){
                audio_complete()
                if(repeat_play)
                {
                    initialize_audio_and_play()
                    initialize_audio = true
                }
            }else{
                end_time_lbl.text = "-" + time_to_string(seconds: audio_remaining_seconds)
            }
        }else{
            let audio_remaining_seconds = Int (looping_end_index) - Int(current_time)
            if(Int(current_time) >= looping_end_index || audio_remaining_seconds == 0){
                audio_complete()
                if(repeat_play)
                {
                    initialize_audio_and_play()
                    initialize_audio = true
                }
            }else{
                end_time_lbl.text = "-" + time_to_string(seconds: audio_remaining_seconds)
            }
        }
    }
    
    
    @IBAction func audio_scrubber_value_changed(_ sender: Any)
    {
        if(initialize_audio)
        {
            audioPlayer.currentTime = TimeInterval(audio_scrubber_ref.value)
        }
        else
        {
            initialize_audio_and_play()
            initialize_audio = true
            audioPlayer.currentTime = TimeInterval(audio_scrubber_ref.value)
        }
    }
    
    func time_to_string(seconds : Int) -> String
    {
        var dis_sec = 0
        var dis_min = 0
        var dis_hr = 0
        
        if ( seconds > 60 )
        {
            let minute = seconds / 60
            dis_sec = seconds % 60
            
            if ( minute > 60 )
            {
                dis_hr = minute / 60
                dis_min = minute % 60
            }
            else
            {
                dis_min = minute
            }
        }
        else
        {
            dis_sec = seconds
        }
        
        var print_sec : String
        var print_min : String
        var print_hr : String
        
        if (dis_sec < 10)
        {
            print_sec = "0" + String(dis_sec)
        }
        else
        {
            print_sec = String(dis_sec)
        }
        
        print_min = String(dis_min) + ":"
        
        if (dis_hr == 0)
        {
            print_hr = ""
        }
        else
        {
            print_hr = String(dis_hr) + ":"
        }
        
        return print_hr + print_min + print_sec
    }
    
    func audio_complete()
    {
        if let player = audioPlayer{
            player.stop()
        }
        initialize_audio = false
        current_playing = false
        timer.invalidate()
        start_time_lbl.text = time_to_string(seconds: 0)
        end_time_lbl.text = "-" + time_to_string(seconds: Int(end_time))
        audio_scrubber_ref.value = 0.0
        recording_play_pause_img_ref.image = UIImage(named: "green-play")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        audio_complete()
        if(repeat_play)
        {
            initialize_audio_and_play()
            initialize_audio = true
        }
    }
    // Siri Wave Meters
    
    func audioPlayWaveMeters() {
        DispatchQueue.main.async {
            self.audioPlayer.updateMeters()
            let normalizedValue:CGFloat = pow(10, CGFloat(self.audioPlayer.averagePower(forChannel: 0))/20)
            self.audioWaveView.update(withLevel: normalizedValue)
        }
    }
    
    func updateWaveMeters() {
        if audioRecorder.isRecording
        {
            self.audioRecorder.updateMeters()
            let normalizedValue:CGFloat = pow(10, CGFloat(self.audioRecorder.averagePower(forChannel: 0))/20)
            self.audioWaveView.update(withLevel: normalizedValue)
        }
    }
    
    // Record Audio
    
    @IBAction func record_btn_click(_ sender: Any)
    {
        record_btn_click_fun()
    }
    
    func record_btn_click_fun()
    {
        view.endEditing(true)
        if(!isAudioRecordingGranted)
        {
            check_record_permission()
        }
        else
        {
            heading_recording()
            open_close_recording_view()
            if(isRecording)
            {
                if let my_txt = lyrics_txtview_ref.text{
                    lyrics_text = my_txt
                }else{
                    display_alert(msg_title: "Lyrics can not be null", msg_desc: "", action_title: "OK")
                }
                //lyrics_text = lyrics_txtview_ref.text
                self.tabBarController?.tabBar.isHidden = false
                
                finishAudioRecording(success: true)
                
                isRecording = false
                
                self.record_img_ref.image = UIImage(named : "recording-start")
                self.record_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.record_img_ref.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }, completion: { (isComplete) in
                    if(isComplete)
                    {
                        self.record_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.audioWaveView.frequency = 0.0
                        self.save_project_recording()
                    }
                })
                
                heading_lyrics()
            self.lyrics_txtview_ref.becomeFirstResponder()
                
                
            }
            else
            {
                if(!lyrics_save_flag)
                {
                    lyrics_text = lyrics_txtview_ref.text
                    if(Reachability.isConnectedToNetwork())
                    {
                        if(lyrics_text != "")
                        {
                            if(lyrics_key == "")
                            {
                                insert_lyrics()
                            }
                            else
                            {
                                update_lyrics()
                            }
                        }
                    }
                }
                lyrics_save_flag = false
                self.tabBarController?.tabBar.isHidden = true
                setup_recorder()
                
            }
        }
    }
    
    func open_close_recording_view()
    {
        if(flag_open_recording_view)
        {
            whole_view_bottom_constraint.constant = 40.0
            recording_view_ref.alpha = 0.0
            flag_open_recording_view = false
            bottom_layout_of_recording_constraint.constant = 0
        }else{
            whole_view_bottom_constraint.constant = keyboardHeight - 40
            bottom_layout_of_recording_constraint.constant = -(self.tabBarController?.tabBar.frame.height)!
            recording_view_ref.alpha = 1.0
            flag_open_recording_view = true
        }
    }
    
    func check_record_permission()
    {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                    if(self.first_check_and_open)
                    {
                        self.record_btn_click_fun()
                        self.first_check_and_open = false
                    }
                    
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    
    func setup_recorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                
                let currentRoute = AVAudioSession.sharedInstance().currentRoute
                if currentRoute.outputs != nil {
                    for description in currentRoute.outputs {
                        if description.portType == AVAudioSessionPortHeadphones {
                            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                        }
                        if(description.portType == AVAudioSessionPortBluetoothHFP){
                            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .allowBluetooth)
                        }
                        else {
                            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                        }
                    }
                }
                try session.setActive(true)
                
                let settings = [
                    AVFormatIDKey:kAudioFormatLinearPCM,
                    AVSampleRateKey:44100.0,
                    AVNumberOfChannelsKey:2,
                    AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue
                    ] as [String : Any]
                
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                
                self.isRecording = true
                self.record_img_ref.image = UIImage(named : "recording-stop")
                self.record_img_ref.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.record_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: { (isComplete) in
                    if(isComplete)
                    {
                        self.record_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.audio_bg_img_ref.loadGif(name: "wave")
                        self.audioWaveView?.frequency = 3.0
                        
                        if (self.audioRecorder != nil){
                            self.audioRecorder.record()
                            
                            self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
                            
                            self.waveTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateWaveMeters), userInfo: nil, repeats: true)
                        }
                    }
                })
                
            }
            catch let error {
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
            
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")
        }
    }
    
    func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recording_time_lbl_ref.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    func getFileUrl() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let dataPath = documentsDirectory.appendingPathComponent("recordings/projects")
        
        do
        {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "Ok")
        }
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        let sticks  = userRef.child("copytotully").childByAutoId().key
        audio_sticks = sticks + ".wav"
        dest_path = dataPath.appendingPathComponent(audio_sticks)
        return dest_path!
        
    }
    
    func finishAudioRecording(success: Bool)
    {
        if success
        {
            audioRecorder.stop()
            if((waveTimer) != nil)
            {
                waveTimer.invalidate()
                meterTimer.invalidate()
            }
            
            audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
            audioRecorder = nil
        }else{
            display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag{
            finishAudioRecording(success: false)
        }
        
    }
    
    @IBAction func openRecordingListView(_ sender: Any)
    {
        
        if(count_recordings > 0){
            if(initialize_audio){
                audio_complete()
            }
            let vc = UIStoryboard(name: "superpowered", bundle: nil).instantiateViewController(withIdentifier: "ProjectRecordingListSid") as! ProjectRecordingListVC
            vc.current_project_name = selected_project_name
            vc.currentProjectID = self.selected_project_key
            present(vc, animated: true, completion: nil)
        }else{
            display_alert(msg_title: "No recordings", msg_desc: "", action_title: "OK")
        }
        
        
    }
    
    func get_num_of_audio_in_project()
    {
        if(count_recordings > 0)
        {
            recording_img_ref.image = UIImage(named: "Recording_Selected_tab")
            no_of_recording_lbl_ref.text = String(count_recordings)
            no_of_recording_view_ref.alpha = 1.0
        }
        else
        {
            recording_img_ref.image = UIImage(named: "recording-blue")
            no_of_recording_view_ref.alpha = 0.0
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backpress = false
        lyrics_txtview_upperview_ref.alpha = 0.0
        //self.lyrics_txtview_ref.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        auto_start_record = false
        flag_lyrics_from_another_tab = false
        view.endEditing(true)
        
        if(initialize_audio)
        {
            if(!goto_big_lyrics)
            {
                audio_complete()
            }
        }
        
        if(isRecording)
        {
            //record_btn_ref.setImage(UIImage(named : "recording-start"), for: .normal)
            self.record_img_ref.image = UIImage(named : "recording-start")
            finishAudioRecording(success: true)
            isRecording = false
            open_close_recording_view()
            self.tabBarController?.tabBar.isHidden = false
            self.save_project_recording()
        }
        
        if(!Reachability.isConnectedToNetwork())
        {
            lyrics_save_flag = true
        }
        
        if(!lyrics_save_flag)
        {
            lyrics_text = lyrics_txtview_ref.text
            if(lyrics_text != "")
            {
                if(lyrics_key == "")
                {
                    insert_lyrics()
                }
                else
                {
                    update_lyrics()
                }
            }
        }
        lyrics_save_flag = false
        
        if(lyrics_text != "")
        {
            get_lyrics_data_protocolobj?.lyrics_data(lyrics_key: lyrics_key, lyrics_txt: lyrics_text, count_recording: count_recordings, repeat_play_data: repeat_play, is_looping: self.is_looping, looping_start_index: self.looping_start_index, looping_end_index: self.looping_end_index)
        }
        else{
            get_lyrics_data_protocolobj?.lyrics_data(lyrics_key: "", lyrics_txt: "", count_recording: count_recordings, repeat_play_data: repeat_play, is_looping: self.is_looping, looping_start_index: self.looping_start_index, looping_end_index: self.looping_end_index)
        }
        
        
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "Play_tab")
            self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Home_Selected_tab")
        
        
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
        
        flag_lyrics_from_another_tab = true
        
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
            self.lyrics_text = self.main_string
            self.heading_lyrics()
            self.flag_update_data = true
            self.open_lyrics_rythm = false
            self.lyrics_txtview_ref.currentState = .select
        }
        
        //lyrics_txtview_ref.becomeFirstResponder()
    }
    
    
    func lyrics_info(lyrics_data : String, lyrics_id : String)
    {
        lyrics_txtview_ref.text = lyrics_data
        lyrics_key = lyrics_id
    }
    
    func setSavedUrl(viewedUrl : String)
    {
        count_recordings = count_recordings + 1
        lyrics_txtview_ref.text = lyrics_text
        get_num_of_audio_in_project()
        if(open_big_lyrics_flag)
        {
            open_big_lyrics()
        }
    }
    func setCurrentKey(savedKey : String){
        if(initialize_audio)
        {
            if(!current_playing)
            {
                audioPlayer.play()
                current_playing = true
                recording_play_pause_img_ref.image = UIImage(named: "pause")
            }
        }
        else
        {
            initialize_audio_and_play()
            initialize_audio = true
        }
    }
    func setProjectKey(projectKey : String){}
    
    
    
    //MARK: - For Looping
    
    @IBAction func loop_btn_click(_ sender: UIButton) {
        
        if(is_looping){
            is_looping = false
            set_lbl_as_loop()
            looping_start_index = 0
            looping_end_index = 0
            initialize_audio_and_play()
            initialize_audio = true
            
        }else{
            
            if(initialize_audio)
            {
                if(audioPlayer.isPlaying)
                {
                    audio_complete()
                }
            }
            
            if(isRecording)
            {
                //record_btn_ref.setImage(UIImage(named : "recording-start"), for: .normal)
                self.record_img_ref.image = UIImage(named : "recording-start")
                finishAudioRecording(success: true)
                isRecording = false
                open_close_recording_view()
                self.tabBarController?.tabBar.isHidden = false
                self.save_project_recording()
            }
            
            let vc : LoopRecordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loop_recording_sid") as! LoopRecordingVC
            vc.recording_file_url = recording_file_url
            vc.myProtocol = self
            self.present(vc, animated: true, completion: nil)
            
            //
        }
    }
    
    func looping_range(start_time: Float, end_time: Float) {
        //goto_big_lyrics = false
        
        flag_lyrics_from_another_tab = false
        if(start_time == 0.0 && end_time == 0.0){
            is_looping = false
            set_lbl_as_loop()
        }else{
            is_looping = true
            set_lbl_as_unloop()
        }
        looping_start_index = Int(start_time)
        looping_end_index = Int(end_time)
        initialize_audio_and_play()
        initialize_audio = true
        
        
    }
    
    func set_lbl_as_loop(){
        repeat_play = false
        loop_lbl_ref.text = "Loop"
        loop_img_ref.image = UIImage(named: "loop")
        loop_lbl_ref.textColor = UIColor(red: 59/255, green: 79/255, blue: 111/255, alpha: 1.0)
        
    }
    
    func set_lbl_as_unloop(){
        repeat_play = true
        loop_lbl_ref.text = "UnLoop"
        loop_img_ref.image = UIImage(named: "loop-green")
        loop_lbl_ref.textColor = UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1.0)
    }
    
    func updateSliderLabelInstant(sender: UISlider!) {
        let value = Int(sender.value)
        DispatchQueue.main.async {
            self.start_time_lbl.text = self.time_to_string(seconds: Int(value))
        }
    }
    
}


