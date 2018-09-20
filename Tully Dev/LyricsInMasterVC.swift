//
//  LyricsInMasterVC.swift
//  Tully Dev
//
//  Created by macbook on 1/31/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import CoreBluetooth
import Mixpanel

protocol lyricsCompleteProtocol
{
    func lyricsDone(newlyrics : String)
}

class LyricsInMasterVC: UIViewController, UITextViewDelegate, AVAudioPlayerDelegate, CBCentralManagerDelegate, selectedDataProtocol
{
    //MARK: - Outlets
    @IBOutlet var recording_play_pause_img_ref: UIImageView!
    @IBOutlet var lyrics_txtview_upperview_ref: UIView!
    @IBOutlet var heading_writing_view: UIView!
    @IBOutlet var audio_file_name_lbl_ref: UILabel!
    @IBOutlet var lyrics_txtview_ref: CustomTextField!
    @IBOutlet var whole_view_ref: UIView!
    @IBOutlet var audio_scrubber_ref: MyHalfSlider!
    @IBOutlet var whole_view_bottom_constraint: NSLayoutConstraint!
    @IBOutlet var end_time_lbl: UILabel!
    @IBOutlet var start_time_lbl: UILabel!
    @IBOutlet var play_btn_ref: UIButton!
    @IBOutlet var repeat_img_ref: UIImageView!
    @IBOutlet var bottom_play_img_width_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_play_img_height_constraint: NSLayoutConstraint!
    
    //MARK: - Variables
    var lyricsCompleteProtocol : lyricsCompleteProtocol?
    var selected_audio_id = ""
    var selected_audio_file_name = ""
    var flag_update_data = false
    var selectedText_length = 0
    var start_index = 0
    var main_string = ""
    var lyrics_text = ""
    var lyrics_save_flag = false
    var flag_open_recording_view = false
    var repeat_play = false
    var recording_file_url : URL? = nil
    var audioPlayer : AVAudioPlayer!
    var current_playing = false
    var initialize_audio = false
    var timer = Timer()
    var end_time:Float = 0.0
    var count_character = 0
    var open_lyrics_rythm = false
    var backpress = false
    var first_check_and_open = false
    var manager:CBCentralManager!
    var flag_bluetooth = false
    var dest_path : URL? = nil
    var old_string = ""
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    var selectedBPM = 0
    var selectedKey = ""
    
    //MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil, options: nil)
        manager.delegate = self
        let screenWidth = UIScreen.main.bounds.width
        var height_width = ((screenWidth / 5) - 8)
        if(height_width >= 53){
            height_width = 52
        }
        audio_scrubber_ref.setMaximumTrackImage(UIImage(named: "remaining_track_color"), for: .normal)
        bottom_play_img_width_constraint.constant = height_width
        bottom_play_img_height_constraint.constant = height_width
       
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        self.lyrics_txtview_ref.delegate = self
        
        if(lyrics_text != "")
        {
            lyrics_txtview_ref.text = lyrics_text
        }
        lyrics_txtview_ref.becomeFirstResponder()
        
        self.myActivityIndicator.stopAnimating()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(Play_LyricsRecordingVC.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Play_LyricsRecordingVC.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
        lyrics_txtview_ref.currentState = .paste
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        audio_file_name_lbl_ref.text = selected_audio_file_name
        
        if(repeat_play)
        {
            repeat_img_ref.image = UIImage(named: "repeat")
        }
        else
        {
            repeat_img_ref.image = UIImage(named: "repeat-black")
        }
        
        if(!current_playing)
        {
            initialize_audio_and_play()
            initialize_audio = true
        }
    }
    
    //MARK: - Initialize audio
    
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
    
    //MARK: - Textview Methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
            lyrics_save_flag = false
    }
    
    func updateTextView(notification : Notification){
       
        let userInfo = notification.userInfo!
        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            lyrics_txtview_ref.contentInset = UIEdgeInsets.zero
            whole_view_bottom_constraint.constant = 0.0
        }
        else{
            lyrics_txtview_ref.contentInset = UIEdgeInsetsMake(0, 0, keyboardEndFrame.height - 200, 0)
            lyrics_txtview_ref.scrollIndicatorInsets = lyrics_txtview_ref.contentInset
            whole_view_bottom_constraint.constant = keyboardEndFrame.height - 80
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
    
   
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        flag_update_data = true
        count_character = count_character + 1
        
        if(count_character == 50){
            self.count_character = 0
            if(Reachability.isConnectedToNetwork())
            {
                //self.save_lyrics(<#Any#>)
               // self.update_flag = true
                if(!lyrics_save_flag)
                {
                    lyrics_text = lyrics_txtview_ref.text
                    if(lyrics_text != "")
                    {
                        update_lyrics()
                    }
                }

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
    
    //MARK: - Save lyrics
    
    @IBAction func save_lyrics(_ sender: Any)
    {
        lyrics_text = lyrics_txtview_ref.text
        if(lyrics_text != "")
        {
            update_lyrics()
        }
        lyricsCompleteProtocol?.lyricsDone(newlyrics: lyrics_text)
        self.navigationController?.popViewController(animated: true)
    }
    
    func update_lyrics()
    {
        if(!lyrics_save_flag)
        {
            lyrics_text = lyrics_txtview_ref.text
            if(lyrics_text != "")
            {
                myActivityIndicator.startAnimating()
                let lyrics_data: [String: Any] = ["lyrics": self.lyrics_text]
                let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                userRef.child("masters").child(self.selected_audio_id).updateChildValues(lyrics_data, withCompletionBlock: { (error, database_ref) in
                    if let error = error{
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                        self.myActivityIndicator.stopAnimating()
                    }else{
                        Mixpanel.mainInstance().track(event: "Update lyrics in project")
                        self.lyrics_save_flag = true
                        self.myActivityIndicator.stopAnimating()
                    }
                })
            }
        }
    }
    
    func close_view()
    {
        if(initialize_audio)
        {
            audio_complete()
        }
        
        if(!lyrics_save_flag)
        {
            lyrics_text = lyrics_txtview_ref.text
            if(lyrics_text != "")
            {
                update_lyrics()
            }
            lyricsCompleteProtocol?.lyricsDone(newlyrics: lyrics_text)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
   
    
    //MARK: - Audio
    
    @IBAction func play_btn_click(_ sender: Any)
    {
        if(initialize_audio)
        {
            if(current_playing)
            {
                audioPlayer.pause()
                current_playing = false
                recording_play_pause_img_ref.image = UIImage(named: "green-play")
            }
            else
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
    
    func scrubber_init()
    {
        end_time = Float(audioPlayer.duration)
        audio_scrubber_ref.maximumValue = end_time
        start_time_lbl.text = time_to_string(seconds: 0)
        end_time_lbl.text = "-" + time_to_string(seconds: Int(end_time))
    }
    
    func update_scrubber()
    {
        let current_time = Float(audioPlayer.currentTime)
        audio_scrubber_ref.value = current_time
        start_time_lbl.text = time_to_string(seconds: Int(current_time))
        let audio_remaining_seconds = Int (audioPlayer.duration) - Int(current_time)
        if(audio_remaining_seconds == 0)
        {
            audio_complete()
        }
        else
        {
            end_time_lbl.text = "-" + time_to_string(seconds: audio_remaining_seconds)
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
        audioPlayer.stop()
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
    
    @IBAction func play_recording_again_btn_click(_ sender: Any)
    {
        if(repeat_play)
        {
            repeat_play = false
            repeat_img_ref.image = UIImage(named: "repeat-black")
        }
        else
        {
            repeat_play = true
            repeat_img_ref.image = UIImage(named: "repeat")
        }
    }
    //MARK: - Broadcast
    
    @IBAction func broadcast_btn_click(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        alertController.addAction(cancelAction)
        
        let speaker_action = UIAlertAction(title: "Speaker", style: .default) { action in
            self.play_audio_in_speaker()
        }
        alertController.addAction(speaker_action)
        
        let headphone_action = UIAlertAction(title: "Headphone", style: .default) { action in
            self.play_audio_in_headphone()
        }
        alertController.addAction(headphone_action)
        
        let bluetooth_action = UIAlertAction(title: "Bluetooth", style: .default) { action in
            self.play_audio_in_bluetooth()
        }
        alertController.addAction(bluetooth_action)
        alertController.view.tintColor = UIColor(red: 49/255, green: 208/255, blue: 152/255, alpha: 1)
        self.present(alertController, animated: true) {
        }
    }
    
    func play_audio_in_speaker()
    {
        let session = AVAudioSession.sharedInstance()
        do
        {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try session.setActive(true)
            initialize_audio = true
            initialize_audio_and_play()
        }
        catch let error {
            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
        }
    }
    
    func play_audio_in_headphone()
    {
        let session = AVAudioSession.sharedInstance()
        do
        {
            
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            //let headphone_val = AVAudioSessionCategoryOptions.mixWithOthers.rawValue
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.init(rawValue: AVAudioSessionCategoryOptions.mixWithOthers.rawValue)!)
            try session.setActive(true)
            //initialize_audio = true
            //initialize_audio_and_play()
        }
        catch let error {
            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
        }
        
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        
        for description in currentRoute.outputs {
            if description.portType == AVAudioSessionPortHeadphones {
                
            } else {
                play_audio_in_speaker()
                display_alert(msg_title: "Attach headphone", msg_desc: "After attach headphone music will play in it.", action_title: "OK")
                
            }
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
    
    func play_audio_in_bluetooth()
    {
        
        if(flag_bluetooth)
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .allowBluetooth)
                try session.setActive(true)
                //initialize_audio = true
                //initialize_audio_and_play()
            }
            catch let error {
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        }
        else
        {
            display_alert(msg_title: "Attach bluetooth device", msg_desc: "After attach bluetooth device, music will play in it.", action_title: "OK")
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
    
        view.endEditing(true)
        
        if(initialize_audio)
        {
            audio_complete()
        }
        
        if(!lyrics_save_flag)
        {
            lyrics_text = lyrics_txtview_ref.text
            if(lyrics_text != "")
            {
                update_lyrics()
            }
        }
        
        
        if(lyrics_text != "")
        {
            //get_lyrics_data_protocolobj?.lyrics_data(lyrics_key: lyrics_key, lyrics_txt: lyrics_text, count_recording: count_recordings, repeat_play_data: repeat_play)
        }
        else{
            //get_lyrics_data_protocolobj?.lyrics_data(lyrics_key: "", lyrics_txt: "", count_recording: count_recordings, repeat_play_data: repeat_play)
        }
        
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
            self.flag_update_data = true
            self.open_lyrics_rythm = false
            self.lyrics_txtview_ref.currentState = .select
        }
        
    }
 
}
