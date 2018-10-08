//
//  CollabrationViewController.swift
//  Tully Dev
//
//  Created by Sandeep Chitode on 27/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import SCSiriWaveformView
import Mixpanel
import CoreBluetooth
import SDWebImage
import UICircularProgressRing

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-150, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
protocol get_coll_data_protocol {
    func lyrics_data(lyrics_key : String, lyrics_txt : String, count_recording : Int,repeat_play_data : Bool, is_looping : Bool, looping_start_index : Int, looping_end_index : Int)
}
class CollabrationViewController: UIViewController,UITextViewDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, send_lyrics_data, CBCentralManagerDelegate,UITableViewDelegate,UITableViewDataSource, looping_protocol {
    
    var currentProjectId = String()
    var collabrationID = String()
    var current_project_main_rec = String()
    var recipientList = [[String:Any]]()
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    @IBOutlet weak var userImg1: UIImageView!
    @IBOutlet weak var userImg2: UIImageView!
    @IBOutlet weak var usercountView: UIView!
    @IBOutlet weak var chatcountLbl: UILabel!
    @IBOutlet weak var chatTbl: UITableView!
    @IBOutlet weak var lyricsTxtView: UITextView!
    
    @IBOutlet weak var lyricsTxtViewBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var recording_view_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var display_key_lbl: UILabel!
    @IBOutlet weak var display_bpm_lbl: UILabel!
    @IBOutlet weak var display_bpm_view_ref: UIView!
    @IBOutlet var bottom_layout_of_recording_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var lyrisc_txtbottom_constraints: NSLayoutConstraint!
    @IBOutlet weak var lyrisc_bottom_constraints: NSLayoutConstraint!
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
    @IBOutlet var whole_view_ref: UIView!
    @IBOutlet var play_recording_view: UIView!
    @IBOutlet var audio_scrubber_ref: MyHalfSlider!
    @IBOutlet var download_process_view_ref: UIView!
    @IBOutlet var processRing: UICircularProgressRingView!
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    @IBOutlet var audio_bg_img_ref: UIImageView!
    @IBOutlet var no_of_recording_lbl_ref: UILabel!
    
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var user_image_view: UIView!
    @IBOutlet var record_img_ref: UIImageView!
    @IBOutlet var end_time_lbl: UILabel!
    @IBOutlet var start_time_lbl: UILabel!
    @IBOutlet var play_btn_ref: UIButton!
    @IBOutlet var record_btn_ref: UIButton!
    @IBOutlet var recording_view_ref: UIView!
    @IBOutlet var recording_time_lbl_ref: UILabel!
    @IBOutlet var recording_play_pause_img_ref: UIImageView!
    
    @IBOutlet weak var fullscreen_lyrics: UIButton!
    @IBOutlet weak var showAudio_btn: UIButton!
    
    @IBOutlet var bottom_note_img_width_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var Lyrics_textView_Height_Constraints: NSLayoutConstraint!
    @IBOutlet var loop_img_ref: UIImageView!
    
    @IBOutlet weak var LyricstxtViewBottom: NSLayoutConstraint!
    @IBOutlet var bottom_record_img_height_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_record_img_width_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_play_img_width_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_play_img_height_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_note_img_height_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var lyrics_chatTbl_bottom: NSLayoutConstraint!
    @IBOutlet weak var lyrics_chattbl_bottom: NSLayoutConstraint!
    @IBOutlet weak var lyer_bottom: NSLayoutConstraint!
    @IBOutlet weak var lyrics_textView_bottom_Const: NSLayoutConstraint!
    @IBOutlet var whole_view_bottom_constraint: NSLayoutConstraint!
    @IBOutlet var loop_lbl_ref: UILabel!
    @IBOutlet weak var innerViewBottomConstraint: NSLayoutConstraint!
    
    var collabration = String()
    var fromUserLyricsTap = String()
    var lyriscData = [[String: Any]]()
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
    var get_coll_data_protocolobj : get_coll_data_protocol?
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
    
    
    var manager:CBCentralManager!
    var flag_bluetooth = false
    var dest_path : URL? = nil
    var audio_sticks = ""
    var isKeyboardAppeared = false
    
    //For Looping
    
    var is_looping = false
    var looping_start_index = 0
    var looping_end_index = 0
    var old_string = ""
    
    var selectedKey = ""
    var selectedBPM = 0
    
    let textViewPlaceholderColor = UIColor.lightGray
    let textViewTextColor = UIColor.black
    
    var allCollaboratorsKey = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.setUI()
        }
        self.chatTbl.delegate = self
        self.chatTbl.dataSource = self
        self.lyricsTxtView.delegate = self
        lyricsTxtView.becomeFirstResponder()
        self.chatTbl.rowHeight = UITableViewAutomaticDimension
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CollabrationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let nibName = UINib(nibName: Utils.shared.reciverNibName, bundle: nil)
        chatTbl.register(nibName, forCellReuseIdentifier: Utils.shared.reciverCellIdentifier)
        manager = CBCentralManager(delegate: self, queue: nil, options: nil)
        manager.delegate = self
        let screenWidth = UIScreen.main.bounds.width
        var height_width = ((screenWidth / 5) - 8)
        
        if(height_width >= 53){
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
        audio_scrubber_ref.setMaximumTrackImage(UIImage(named: Utils.shared.audio_scrubber_color), for: .normal)
        audio_scrubber_ref.addTarget(self, action: #selector(self.updateSliderLabelInstant(sender:)), for: .allEvents)
        note_img_ref.image = UIImage(named: Utils.shared.note_img_name)
        //  self.lyrics_txtview_ref.delegate = self
        
        if(lyrics_key != "" && lyrics_text != "")
        {
            //   lyrics_txtview_ref.text = lyrics_text
        }
        no_of_recording_view_ref.layer.cornerRadius = 6
        get_num_of_audio_in_project()
        
        self.myActivityIndicator.stopAnimating()
        keyboardHeight = KeyboardService.keyboardHeight()
        recording_view_height_constraint.constant = keyboardHeight
        self.view.layoutIfNeeded()
        
        //        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(CollabrationViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CollabrationViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        check_record_permission()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(CollabrationViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CollabrationViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: Keyboard Hide
    func dismissKeyboard() {
        view.endEditing(true)
    }
    //MARK: Update textView constraints with Keyboard Hide Or Show
    func updateTextView(notification : Notification){
         if(flag_open_recording_view){
            whole_view_bottom_constraint.constant = 40.0
            play_recording_view.alpha = 0.0
            flag_open_recording_view = false
        }
        
        let userInfo = notification.userInfo!
        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            //lyrics_txtview_ref.contentInset = UIEdgeInsets.zero
            //  lyrics_txtview_ref.contentInset = UIEdgeInsetsMake(0, 0, keyboardEndFrame.height - 200, 0)
            whole_view_bottom_constraint.constant = 40.0
        }else{
            // lyrics_txtview_ref.contentInset = UIEdgeInsetsMake(0, 0, keyboardEndFrame.height - 200, 0)
            //  lyrics_txtview_ref.scrollIndicatorInsets = lyrics_txtview_ref.contentInset
            self.play_recording_view.isHidden = false
            whole_view_bottom_constraint.constant = keyboardEndFrame.height - 20
        }
        //   lyrics_txtview_ref.scrollRangeToVisible(lyrics_txtview_ref.selectedRange)
    }
    
    
    func updateSliderLabelInstant(sender: UISlider!) {
        let value = Int(sender.value)
        DispatchQueue.main.async {
            self.start_time_lbl.text = self.time_to_string(seconds: Int(value))
        }
    }
    func get_num_of_audio_in_project()
    {
        if(count_recordings > 0)
        {
            recording_img_ref.image = UIImage(named: Utils.shared.recording_imgNamed)
            no_of_recording_lbl_ref.text = String(count_recordings)
            no_of_recording_view_ref.alpha = 1.0
        }
        else
        {
            recording_img_ref.image = UIImage(named: Utils.shared.bluerecordingimgNamed )
            no_of_recording_view_ref.alpha = 0.0
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
    func getCollabratorsData() {
        
        
        
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        ref.child("collaborations").child(currentProjectId).child(collabrationID).observeSingleEvent(of: .value, with: { (snap) in
            
            
            self.recipientList.removeAll()
            
            if snap.exists() {
                
                
                
                for task in snap.children {
                    
                    
                    
                    guard let taskSnapshot = task as? DataSnapshot else { return }
                    
                    
                    
                    guard let userIdKey = taskSnapshot.key as? String else { return }
                    
                    ref.child(userIdKey).child("profile").observeSingleEvent(of: .value, with: { (innerSnap) in
                        
                        
                        
                        if innerSnap.exists() {
                            
                            
                            
                            var receivedData = innerSnap.value as! [String: Any]
                            
                            
                            
                            receivedData["userId"] = userIdKey
                            
                            self.recipientList.append(receivedData)
                            
                            
                            
                            self.setImageOnNavigationBar()
                            
                        }
                        
                    })
                   
                    
                }
                
            }
            
        })
        
    }
    
    
    
    func setImageOnNavigationBar() {
        
        if recipientList.count == 1 {
            
            userImg2.isHidden = true
            chatcountLbl.isHidden = true
        }
        else if recipientList.count == 2 {
            
            userImg2.isHidden = false
            chatcountLbl.isHidden = true
        }
        else {
            
            userImg2.isHidden = false
            chatcountLbl.isHidden = false
        }
        
        if !recipientList.isEmpty {
            
            chatcountLbl.text = "+\(recipientList.count - 2)"
        }
        
        var imgUrl1 = "", imgUrl2 = ""
        
        for i in recipientList {
            
            if let myimg = i["myimg"] as? String {
                
                if imgUrl1.isEmpty {
                    
                    imgUrl1 = myimg
                }
                else {
                    
                    imgUrl2 = myimg
                }
            }
        }
        
        userImg1.sd_setImage(with: URL(string: imgUrl1), placeholderImage: #imageLiteral(resourceName: "Image1"))
        userImg2.sd_setImage(with: URL(string: imgUrl2), placeholderImage: #imageLiteral(resourceName: "Image1"))
    }
    
    func getDataForTable(){
        
        let userID = Auth.auth().currentUser?.uid
        let userRef = FirebaseManager.getRefference().ref
        userRef.child("collaborations").child(self.currentProjectId).child(self.collabrationID).observe(.value, with: { (snapshot) in
            self.lyriscData.removeAll()
            for i in snapshot.children{
                guard let taskSnapshot = i as? DataSnapshot else {
                    return
                }
                if taskSnapshot.key == userID{
                    if let receivedMessage = taskSnapshot.value as? [String: Any] {
                        if let lyrics = receivedMessage["lyrics"] as?  NSDictionary {
                            let lyrics_key = lyrics.allKeys as! [String]
                            for key in lyrics_key
                            {
                                let lyrics_data = lyrics.value(forKey: key) as! NSDictionary
                                let desc = lyrics_data.value(forKey: "desc") as! String
                                self.lyricsTxtView.text = desc
                            }
                        }
                    }
                    
                }else{
                    if let receivedMessage = taskSnapshot.value as? [String: Any] {
                        var lyricsDict = [String: Any]()
                        
                        if let lyrics_color = receivedMessage["lyrics_color"] as? String{
                            lyricsDict["lyrics_color"] = lyrics_color
                        }
                        
                        if let isActive = receivedMessage["is_active"] as? Bool {
                            lyricsDict["is_active"] = isActive
                        }
                        
                        var desc = ""
                        
                        if let lyrics = receivedMessage["lyrics"] as?  NSDictionary {
                            let lyrics_key = lyrics.allKeys as! [String]
                            for key in lyrics_key
                            {
                                let lyrics_data = lyrics.value(forKey: key) as! NSDictionary
                                desc = lyrics_data.value(forKey: "desc") as! String
                                //                                self.lyriscData.append(desc)
                                lyricsDict["desc"] = desc
                            }
                        }
                        
                        if !desc.isEmpty {
                            
                            self.lyriscData.append(lyricsDict)
                        }
                        
                        if !self.lyriscData.isEmpty {
                            
                            self.chatTbl.reloadData()
                        }
                        
                    }
                }
                
                
            }
            
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
            self.showAudio_btn.isHidden = true
            recipientList.removeAll()
            getCollabratorsData()
            getDataForTable()
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
                    
                    UIView.animate(withDuration: 0.1, animations : {
                        self.note_img_ref.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                        //  self.lyrics_txtview_ref.becomeFirstResponder()
                    }, completion: {(finished : Bool) in
                        if(finished)
                        {
                            UIView.animate(withDuration: 0.5, animations : {
                                self.note_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                //self.lyrics_txtview_ref.becomeFirstResponder()
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
    //MARK: Keyboard Notification methods
    func keyboardWillShow(notification:NSNotification) {
        
        if !isKeyboardAppeared {
            
            adjustingHeight(show:true, notification: notification)
            
            isKeyboardAppeared = true
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
    
        if isKeyboardAppeared {
            
            isKeyboardAppeared = false
            
            adjustingHeight(show:false, notification: notification)
        }
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        
        let userInfo = notification.userInfo!
        
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        let changeInHeight = (keyboardFrame.height) * (show ? 1 : -1)
        let viewHeight = (show ? 1 : -1)
        // let viewHeight = (show ? 135 : -135)
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            
            // self.lyrics_textView_bottom_Const.constant += changeInHeight
            self.recording_view_height_constraint.constant += CGFloat(viewHeight)
            //            self.lyrics_chattbl_bottom.constant += changeInHeight
        })
    }
    
    //MARK: TextViewDelegate method
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateIsActiveStatus(isActive: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateIsActiveStatus(isActive: false)
    }
    func textViewDidChange(_ textView: UITextView) {
   
        updateLyricsData()
    }
    
    //    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //        self.view.endEditing(true)
    //        return false
    //    }
    
    func updateIsActiveStatus(isActive: Bool) {
        
        let userID = Auth.auth().currentUser?.uid
        
        let ref = Database.database().reference()
        ref.child("collaborations").child(currentProjectId).child(collabrationID).child(userID!).observeSingleEvent(of: .value, with: { (snap) in
            
            if snap.exists() {
                
                guard let taskSnapshot = snap as? DataSnapshot else {
                    return
                }
                
                var receivedData = taskSnapshot.value as! [String: Any]
                
                receivedData["is_active"] = isActive
                ref.child("collaborations").child(self.currentProjectId).child(self.collabrationID).child(userID!).setValue(receivedData, withCompletionBlock: { (error, reference) in
                    
                })
            }
        })
    }
    
    func set_lbl_as_unloop(){
        repeat_play = true
        loop_lbl_ref.text = "UnLoop"
        loop_img_ref.image = UIImage(named: "loop-green")
        loop_lbl_ref.textColor = UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1.0)
    }
    func lyrics_info(lyrics_data: String, lyrics_id: String) {
        //   lyrics_txtview_ref.text = lyrics_data
        lyrics_key = lyrics_id
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
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CollabrationViewController.update_scrubber), userInfo: nil, repeats: true)
                    current_playing = true
                    recording_play_pause_img_ref.image = UIImage(named: "pause")
                }
                catch
                {
                    display_alert(msg_title: Utils.shared.not_found, msg_desc: Utils.shared.file_not_found, action_title: "OK")
                }
            }
            else
            {
                display_alert(msg_title: Utils.shared.not_found, msg_desc: Utils.shared.file_not_found, action_title: "OK")
            }
        }
        else
        {
            display_alert(msg_title: Utils.shared.error, msg_desc: Utils.shared.cant_get_file_path, action_title: "OK")
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
        recording_play_pause_img_ref.image = UIImage(named: Utils.shared.recordingGrrenimgNamed)
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
    
    func set_lbl_as_loop(){
        repeat_play = false
        loop_lbl_ref.text = "Loop"
        loop_img_ref.image = UIImage(named: "loop")
        loop_lbl_ref.textColor = UIColor(red: 59/255, green: 79/255, blue: 111/255, alpha: 1.0)
        
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
            open_close_recording_view()
            if(isRecording)
            {
                //                if let my_txt = lyrics_txtview_ref.text{
                //                    lyrics_text = my_txt
                //                }else{
                //                    display_alert(msg_title: "Lyrics can not be null", msg_desc: "", action_title: "OK")
                //                }
                //lyrics_text = lyrics_txtview_ref.text
                // self.tabBarController?.tabBar.isHidden = false
                
                finishAudioRecording(success: true)
                
                isRecording = false
                
                self.record_img_ref.image = UIImage(named : Utils.shared.recordingStartimg)
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
            else
            {
                if(!lyrics_save_flag)
                {
                    //    lyrics_text = lyrics_txtview_ref.text
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
            recording_img_ref.image = UIImage(named: Utils.shared.recording_imgNamed)
            let recording_data: [String: Any] = ["name": file_name, "tid": audio_sticks, "size":mysize]
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            
            let recording_key  = userRef.child("projects").child(self.selected_project_key).child("recordings").childByAutoId().key
            if(self.selected_project_key != "")
            {
                userRef.child("projects").child(self.selected_project_key).child("recordings").child(recording_key).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                    if let error = error
                    {
                        self.display_alert(msg_title: Utils.shared.error, msg_desc: error.localizedDescription, action_title: "OK")
                    }
                    if(self.selected_audio_file_name == "Free Beat"){
                        Mixpanel.mainInstance().track(event: "Free Beat Recording")
                    }
                    Mixpanel.mainInstance().track(event: "Recording in project")
                    userRef.child("remaining_upload").child("projects").child(self.selected_project_key).child("recordings").child(recording_key).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                        
                        if let error = error{
                            MyConstants.normal_display_alert(msg_title:Utils.shared.error, msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
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
                self.display_alert(msg_title: Utils.shared.project_not_found, msg_desc: Utils.shared.cant_found_project, action_title: "OK")
            }
            
            if(!Reachability.isConnectedToNetwork())
            {
                userRef.child("remaining_upload").child("projects").child(self.selected_project_key).child("recordings").child(recording_key).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                    
                    if let error = error
                    {
                        self.display_alert(msg_title: Utils.shared.error, msg_desc: error.localizedDescription, action_title: "OK")
                    }
                })
            }
        }
        catch let error as NSError {
            display_alert(msg_title: Utils.shared.error, msg_desc: error.localizedDescription, action_title: "OK")
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
                display_alert(msg_title: Utils.shared.error, msg_desc: error.localizedDescription, action_title: "OK")
            }
            
        }
        else
        {
            display_alert(msg_title: Utils.shared.error, msg_desc: Utils.shared.msgDontUseMicrophone, action_title: "OK")
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
            display_alert(msg_title: Utils.shared.error, msg_desc: error.localizedDescription, action_title: "Ok")
        }
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        let sticks  = userRef.child("copytotully").childByAutoId().key
        audio_sticks = sticks + ".wav"
        dest_path = dataPath.appendingPathComponent(audio_sticks)
        return dest_path!
        
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
                        self.display_alert(msg_title: Utils.shared.error, msg_desc: error.localizedDescription, action_title: "OK")
                        self.myActivityIndicator.stopAnimating()
                    }else{
                        Mixpanel.mainInstance().track(event:Utils.shared.updatelyrics)
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
                self.display_alert(msg_title: Utils.shared.project_not_found, msg_desc: Utils.shared.cant_found_project, action_title: "OK")
                self.myActivityIndicator.stopAnimating()
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
        //vc.get_data = lyrics_txtview_ref.text
        vc.lyrics_key = lyrics_key
        self.present(vc, animated: true, completion: nil)
    }
    func insert_lyrics()
    {
        self.myActivityIndicator.startAnimating()
        if(self.lyrics_text == "")
        {
            self.display_alert(msg_title: Utils.shared.cant_null, msg_desc: Utils.shared.please_write_something, action_title: "OK")
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
                            self.display_alert(msg_title: Utils.shared.error, msg_desc: error.localizedDescription, action_title: "OK")
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
                    self.display_alert(msg_title: Utils.shared.project_not_found, msg_desc: Utils.shared.cant_found_project, action_title: "OK")
                    self.myActivityIndicator.stopAnimating()
                }
            }
        }
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
            display_alert(msg_title: Utils.shared.error, msg_desc: Utils.shared.recording_failed, action_title: "OK")
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
    //MARK:-  UIDesign
    func setUI(){
        Utils.shared.set_CircleImage(imageView: userImg1)
        Utils.shared.set_CircleImage(imageView: userImg2)
        Utils.shared.set_CircleView(view: usercountView)
        self.display_bpm_view_ref.isHidden = true
        userImg2.isHidden = true
        //        usercountView.isHidden = true
        chatcountLbl.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- groupChat Button Cliked
    @IBAction func groupChatBtnCliked(_ sender: Any) {
        if let player = audioPlayer{
            player.pause()
        }
        let viewController : ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatViewController
        viewController.recipientListForHeader = self.recipientList
        viewController.currentProjectId = currentProjectId
        viewController.currentCollaborationId = collabrationID
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func save_lyrics(_ sender: Any)
    {
        
        if let player = audioPlayer{
            player.pause()
        }
        self.dismissKeyboard()
        saveLyricsData()
        
    }
    //MARK: update Lyrics
    func updateLyricsData(){
        print(lyriscData.count)
       
        
        let userID = Auth.auth().currentUser?.uid
        let userRef = FirebaseManager.getRefference().ref
        userRef.child("collaborations").child(self.currentProjectId).child(self.collabrationID).child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var isLyricsNodePresent = false
            var lyricsNodeId = ""
            
            for i in snapshot.children{
                guard let taskSnapshot = i as? DataSnapshot else {
                    return
                }
                if taskSnapshot.key == "lyrics"{
                    
                    isLyricsNodePresent = true
                    
                    for lyricsChild in taskSnapshot.children {
                        let lyricsNode = lyricsChild as! DataSnapshot
                        
                        lyricsNodeId = (lyricsNode.key as? String)!
                        break
                    }
                    
                }
            }
            
            let values = ["desc": self.lyricsTxtView.text] as [String : Any]
            if isLyricsNodePresent {
                Database.database().reference().child("collaborations").child(self.currentProjectId).child(self.collabrationID).child(userID!).child("lyrics").child(lyricsNodeId).setValue(values, withCompletionBlock: { (error, reference) in
                    
                })
            } else {
                Database.database().reference().child("collaborations").child(self.currentProjectId).child(self.collabrationID).child(userID!).child("lyrics").childByAutoId().setValue(values, withCompletionBlock: { (error, reference) in
                    
                })
            }
            
        })
    }
    
    //MARK: Save Lyrics
    func saveLyricsData(){
       // self.lyriscData.removeAll()
        
        let userID = Auth.auth().currentUser?.uid
        let userRef = FirebaseManager.getRefference().ref
        userRef.child("collaborations").child(self.currentProjectId).child(self.collabrationID).child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var isLyricsNodePresent = false
            var lyricsNodeId = ""
            
            for i in snapshot.children{
                guard let taskSnapshot = i as? DataSnapshot else {
                    return
                }
                if taskSnapshot.key == "lyrics"{
                    
                    isLyricsNodePresent = true
                    
                    for lyricsChild in taskSnapshot.children {
                        let lyricsNode = lyricsChild as! DataSnapshot
                        
                        lyricsNodeId = (lyricsNode.key as? String)!
                        break
                    }
                    
                }
            }
            
            let values = ["desc": self.lyricsTxtView.text] as [String : Any]
            if isLyricsNodePresent {
                Database.database().reference().child("collaborations").child(self.currentProjectId).child(self.collabrationID).child(userID!).child("lyrics").child(lyricsNodeId).setValue(values, withCompletionBlock: { (error, reference) in
                    
                })
            } else {
                Database.database().reference().child("collaborations").child(self.currentProjectId).child(self.collabrationID).child(userID!).child("lyrics").childByAutoId().setValue(values, withCompletionBlock: { (error, reference) in
                    
                })
            }
            
            self.showToast(message: "Lyrics Saved")
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CollabrationViewController.updateViewController), userInfo: nil, repeats: true)
        })
    }
    func updateViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showAudio_btn_clicked(_ sender: Any) {
        self.play_recording_view.isHidden = false
        whole_view_bottom_constraint.constant = -15
        lyricsTxtView.becomeFirstResponder()
        self.showAudio_btn.isHidden = true
        self.fullscreen_lyrics.isHidden = false
    }
    @IBAction func full_screen_lyrics(_ sender: Any)
    {
       
        if let player = audioPlayer{
            player.pause()
        }
        self.dismissKeyboard()
        whole_view_bottom_constraint.constant = -40
        self.play_recording_view.isHidden = true
        self.fullscreen_lyrics.isHidden = true
        self.showAudio_btn.isHidden = false
        
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
                recording_play_pause_img_ref.image = UIImage(named: Utils.shared.recordingGrrenimgNamed)
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
    @IBAction func record_btn_click(_ sender: Any)
    {
        record_btn_click_fun()
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
            display_alert(msg_title: Utils.shared.noRecording, msg_desc: Utils.shared.noRecordingfound, action_title: "OK")
        }
        
        
    }
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
    
    //MARK: - UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyriscData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTbl.dequeueReusableCell(withIdentifier: Utils.shared.reciverCellIdentifier, for: indexPath) as! reciverCell
        
        if let dict = lyriscData[indexPath.row] as? [String: Any] {
            
            let desc = dict["desc"] ?? ""
            cell.reciverLbl.text = desc as? String
            
            let lyricsColor = dict["lyrics_color"] ?? "#000000"
            cell.reciverLbl.textColor = hexStringToUIColor(hex: lyricsColor as! String)
            
            if let isActive = dict["is_active"] as? Bool, isActive {
                
                cell.imageViewObj.loadGif(name: "typing_indicator")
                cell.imageViewWidthConstraint.constant = 50
            }
            else {
                
                cell.imageViewWidthConstraint.constant = 0
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

