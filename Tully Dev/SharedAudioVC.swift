//  SharedAudioVC.swift
//  Tully Dev
//
//  Created by macbook on 6/22/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import UICircularProgressRing
import Mixpanel
import CoreBluetooth

class SharedAudioVC: UIViewController , AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource , CBCentralManagerDelegate, giveProjectDataProtocol, get_lyrics_data_protocol, myProtocol, renameCompleteProtocol, looping_protocol, shareSecureResponseProtocol
{
    
    @IBOutlet weak var bpm_subscribe_img_ref: UIImageView!
    //MARK: - Outlets
    @IBOutlet weak var btnInviteOutlet: UIButton!
    @IBOutlet weak var imgInviteOutlet: UIImageView!
    @IBOutlet weak var bpm_detect_view: UIView!
    @IBOutlet weak var bpmDetectPercentage: UILabel!
    @IBOutlet weak var bpmDetectImgRef: UIImageView!
    @IBOutlet var lyrics_view_ref: UIView!
    @IBOutlet weak var bpm_view_ref: UIView!
    @IBOutlet var bottom_constraint_of_bottom_view: NSLayoutConstraint!
    @IBOutlet var bottom_view_height_constraint_ref: NSLayoutConstraint!
    @IBOutlet var top_constraint_of_bottom_view: NSLayoutConstraint!
    @IBOutlet var audio_list_view_ref: UIView!
    @IBOutlet var audio_list_tbl_ref: UITableView!
    @IBOutlet var recording_img_ref: UIImageView!
    @IBOutlet var height_constraint_ref_of_btn_play_pause_img: NSLayoutConstraint!
    @IBOutlet var whole_view_bottom_constraint: NSLayoutConstraint!
    @IBOutlet var recording_start_save_img_ref: UIImageView!
    @IBOutlet var record_btn_ref: UIButton!
    @IBOutlet var add_lyrics_view_ref: UIView!
    @IBOutlet var btn_play_pause_img_ref: UIImageView!
    @IBOutlet var audio_scrubber_ref: MySlider!
    @IBOutlet var start_time_lbl: UILabel!
    @IBOutlet var end_time_lbl: UILabel!
    @IBOutlet var project_name_lbl: UILabel!
    @IBOutlet var audio_file_name: UILabel!
    @IBOutlet var lyrics_txt_view_ref: UITextView!
    @IBOutlet var no_of_recording_lbl_ref: UILabel!
    @IBOutlet var no_of_recording_view_ref: UIView!
    @IBOutlet var processRing: UICircularProgressRingView!
    @IBOutlet var download_process_view_ref: UIView!
    @IBOutlet var add_lyrics_img_ref: UIImageView!
    @IBOutlet var bottom_img_rec_height_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_img_rec_width_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var display_bpm_lbl: UILabel!
    @IBOutlet weak var display_key_lbl: UILabel!
    @IBOutlet weak var display_bpm_view_ref: UIView!
    @IBOutlet weak var analyzer_bpm: UILabel!
    @IBOutlet var loop_lbl_ref: UILabel!
    @IBOutlet var loop_img_ref: UIImageView!
    
    @IBOutlet weak var btn_analyzer_detect_ref: UIButton!
    @IBOutlet weak var img_analyzer_done_reff: UIImageView!
    
    //MARK: - Variables
    var projectCurrentId = String()
    var playSong = ""
    var timer = Timer()
    var bpmCompleteTimer = Timer()
    var current_playing = false
    var initialize_audio = false
    var flag_lyrics = false
    var flag_recording = false
    var audioPlayer : AVAudioPlayer!
    var currentProjectName : String = ""
    var currentProjectId : String = ""
    var currentFileName : String = ""
    var audioArray = [playData]()
    var project_main_rec = [playData]()
    var selected_index : Int = 0
    var get_lyrics_key = ""
    var get_lyrics_text = ""
    var come_as_present = false
    var selected_recording_url : URL? = nil
    var count_recordings = 0
    var repeat_play = false
    var flag_one_audio_delete = false
    var saved_project_data_flag = false
    var saved_audio_file_name = ""
    var end_time : Float = 0.0
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var comeFromProject = false
    var manager:CBCentralManager!
    
    var flag_bluetooth = false
    var is_looping = false
    var looping_start_index = 0
    var looping_end_index = 0
    var play_copy_to_tully_file = false
    var open_play_lyrics_recording = false
    var comeFromHome = false
    
    //for Audio Analyzer
    @IBOutlet weak var analyzer_key: UILabel!
    var myView : SuperPoweredSpinnerView!
    var audioAnalyzer = AudioAnalyzer()
    var bpm_counter = 0
    
    var selectedProjectBPM = 0
    var selectedProjectKey = ""
    var displayBpmView = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if playSong == "fromPlaySong"{
            btnInviteOutlet.isHidden = true
            imgInviteOutlet.isHidden = true
        }else{
            btnInviteOutlet.isHidden = false
            imgInviteOutlet.isHidden = false
        }
        btn_analyzer_detect_ref.layer.cornerRadius = 10.0
        btn_analyzer_detect_ref.clipsToBounds = true
        
        NotificationCenter.default.addObserver(forName:NSNotification.Name(rawValue: "beatLoaderNotification"), object:nil, queue:nil, using:beatLoader)
        manager = CBCentralManager(delegate: self, queue: nil, options: nil)
        manager.delegate = self
        audio_scrubber_ref.setMaximumTrackImage(UIImage(named: "remaining_track_color"), for: .normal)
        audio_scrubber_ref.addTarget(self, action: #selector(self.updateSliderLabelInstant(sender:)), for: .allEvents)
        let screenWidth = UIScreen.main.bounds.width
//        myView = SuperPoweredSpinnerView(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
//        myView.tag = 100
        let height_width = ((screenWidth / 5) - 28)
        bottom_img_rec_width_constraint.constant = height_width
        bottom_img_rec_height_constraint.constant = height_width
        MyVariables.come_from_home = false
        self.navigationController?.isNavigationBarHidden = true
        no_of_recording_view_ref.layer.cornerRadius = 7
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDownGesture)
        
        let swipeDownGesture1 = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDownGesture1.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeDownGesture1)
        audio_list_tbl_ref.tableFooterView = UIView()
        bpm_detect_view.alpha = 0.0
    }
    
    func check_audio_analyzer_subscription(){
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("settings").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if (snapshot.exists()){
                if(snapshot.hasChild("audioAnalyzer")){
                    if let data = snapshot.childSnapshot(forPath: "audioAnalyzer").value as? NSDictionary{
                        if let check = data.value(forKey: "isActive") as? Bool{
                            if(check){
                                UserDefaults.standard.set("true", forKey: "audioAnalyzerSubscription")
                                MyVariables.audioAnalyzerSubscription = true
                            }else{
                                
                                if let counter = data.value(forKey: "freeTrials") as? Int{
                                    self.bpm_counter = counter
                                }
                                
                                if(self.bpm_counter >= 5){
                                    UserDefaults.standard.set("false", forKey: "audioAnalyzerSubscription")
                                    MyVariables.audioAnalyzerSubscription = false
                                    self.bpm_view_ref.alpha = 0.0
                                    
                                }else{
//                                    self.clear_bpm()
//                                    self.bpm_view_ref.alpha = 1.0
                                    
                                }
                                
                                UserDefaults.standard.set("false", forKey: "audioAnalyzerSubscription")
                                MyVariables.audioAnalyzerSubscription = false
                            }
                        }else{
                            if let counter = data.value(forKey: "freeTrials") as? Int{
                                self.bpm_counter = counter
                            }
                            
                            if(self.bpm_counter >= 5){
                                //self.display_bpm_view_ref.alpha = 0.0
                                self.bpm_view_ref.alpha = 0.0
                                UserDefaults.standard.set("false", forKey: "audioAnalyzerSubscription")
                                MyVariables.audioAnalyzerSubscription = false
                               
                            }else{
//                                self.clear_bpm()
//                                self.bpm_view_ref.alpha = 1.0
//                                self.display_bpm_view_ref.alpha = 1.0
                            }
                        }
                    }
                }else{
                    UserDefaults.standard.set("false", forKey: "audioAnalyzerSubscription")
                    MyVariables.audioAnalyzerSubscription = false
                }
            }
        })
    }
    
    func updateSliderLabelInstant(sender: UISlider!) {
        let value = Int(sender.value)
        DispatchQueue.main.async {
            self.start_time_lbl.text = self.time_to_string(seconds: Int(value))
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
       
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }

        let x = (bpmDetectImgRef.frame.origin.x - 7)
        myView = SuperPoweredSpinnerView(frame: CGRect(x: x, y: 0, width: 60, height: 60))
        myView.tag = 100
        self.bpm_detect_view.addSubview(myView)
        
        self.display_bpm_view_ref.alpha = 1.0
        self.bpm_view_ref.alpha = 0.0
        UserDefaults.standard.set("true", forKey: "audioAnalyzerSubscription")
        MyVariables.audioAnalyzerSubscription = true
        //check_audio_analyzer_subscription()
        bpm_subscribe_img_ref.image = UIImage(named: "bpm_subscribe")
        
        open_play_lyrics_recording = false
        if(!MyVariables.play_tutorial){
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "h1TutorialSid") as! h1TutorialVC
            vc.tutorial_for = "play"
            vc.come_from_share_audio = true
            self.present(vc, animated: true, completion: nil)
        }else{
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
        add_lyrics_img_ref.image = UIImage(named: "plus-icon")
        add_lyrics_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        MyVariables.come_from_home = false
        
        if(is_looping){
            set_lbl_as_unloop()
        }else{
            set_lbl_as_loop()
        }
        
        if(come_as_present)
        {
            if(!comeFromHome){
                get_files()
            }
            
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "Play_Selected_tab")
            self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Home_tab")
            
            project_name_lbl.text = currentProjectName
            if(get_lyrics_text != "")
            {
                UIView.animate(withDuration: 0.5, animations : {
                    self.add_lyrics_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: {(finished : Bool) in
                    if(finished)
                    {
                        UIView.animate(withDuration: 0.5, animations : {
                            self.add_lyrics_img_ref.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                            self.add_lyrics_img_ref.image = UIImage(named: "add_lyrics_green")
                        }, completion: {(finished : Bool) in
                            if(finished)
                            {
                                self.lyrics_txt_view_ref.text = self.get_lyrics_text
                                self.add_lyrics_view_ref.alpha = 0.0
                            }
                        })
                    }
                })
            }else{
                add_lyrics_img_ref.image = UIImage(named: "plus-icon")
                add_lyrics_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            saved_project_data_flag = true
        }
        
        if(MyVariables.home_to_shared)
        {
            MyVariables.home_to_shared = false
            audioArray = MyVariables.audioArray
            selected_index = MyVariables.selected_index
            currentProjectName  = ""
            currentProjectId = ""
            get_lyrics_key = ""
            get_lyrics_text = ""
            count_recordings = 0
            recording_img_ref.image = UIImage(named: "recording-blue")
            //recording_img_ref.image = UIImage(named: "multitrack_list")
            no_of_recording_view_ref.alpha = 0.0
            self.add_lyrics_view_ref.alpha = 1.0
            self.lyrics_txt_view_ref.text = ""
            
            if(audioArray.count > 0)
            {
                initialize_audio = true
                play_copy_to_tully_file = true
                self.initialize_audio_and_play()       
            }
        }
        else
        {
            if(currentProjectName != "")
            {
                if(project_main_rec.count > 0)
                {
                    initialize_audio = true
                    self.play_project_main_rec()
                    get_files()
                }
                else if(selected_recording_url != nil)
                {
                    initialize_audio = true
                    self.play_project_main_rec()
                    get_files()
                }
            }
            else
            {
                if(audioArray.count > 0)
                {
                    initialize_audio = true
                    self.initialize_audio_and_play()
                }
            }
        }
        get_num_of_audio_in_project()
        }
    }
    
    func play_project_main_rec()
    {
        if(selected_recording_url == nil)
        {
            selected_recording_url = project_main_rec[selected_index].audio_url
        }
        
        if selected_index < project_main_rec.count
        {
            let filename = project_main_rec[selected_index].audio_name
            let displayname = filename?.components(separatedBy: ".")
            audio_file_name.text = displayname?[0].removingPercentEncoding
            saved_audio_file_name = (displayname?[0].removingPercentEncoding)!
            
            if(project_main_rec[selected_index].key != ""){
                selectedProjectBPM = project_main_rec[selected_index].bpm
                selectedProjectKey = project_main_rec[selected_index].key
                display_bpm_lbl.text = String(project_main_rec[selected_index].bpm)
                display_key_lbl.text = project_main_rec[selected_index].key
            }else{
                display_bpm_lbl.text = ""
                display_key_lbl.text = ""
            }
            
        }
        
        if let audio_url = selected_recording_url
        {
            if FileManager.default.fileExists(atPath: audio_url.path)
            {
                do
                {
                    
                    
//                    if(MyVariables.audioAnalyzerSubscription){
//
//                        if(project_main_rec[selected_index].key == ""){
//                            selectedProjectBPM = project_main_rec[selected_index].bpm
//                            selectedProjectKey = project_main_rec[selected_index].key
//                            display_bpm_lbl.text = String(project_main_rec[selected_index].bpm)
//                            display_key_lbl.text = project_main_rec[selected_index].key
//                            display_bpm_view_ref.alpha = 1.0
//                            bpm_view_ref.alpha = 0.0
//                        }else{
//                            display_bpm_view_ref.alpha = 0.0
//                            bpm_view_ref.alpha = 1.0
//                            clear_bpm()
//                        }
//
//                    }else{
//                        if(bpm_counter < 5){
//
//                            if(project_main_rec[selected_index].key != ""){
//                                selectedProjectBPM = project_main_rec[selected_index].bpm
//                                selectedProjectKey = project_main_rec[selected_index].key
//                                display_bpm_lbl.text = String(project_main_rec[selected_index].bpm)
//                                display_key_lbl.text = project_main_rec[selected_index].key
//                                display_bpm_view_ref.alpha = 1.0
//                                bpm_view_ref.alpha = 0.0
//                            }else{
//                                display_bpm_view_ref.alpha = 0.0
//                                bpm_view_ref.alpha = 1.0
//                                clear_bpm()
//                            }
//                        }else{
//                            if(project_main_rec[selected_index].key != ""){
//                                selectedProjectBPM = project_main_rec[selected_index].bpm
//                                selectedProjectKey = project_main_rec[selected_index].key
//                                display_bpm_lbl.text = String(project_main_rec[selected_index].bpm)
//                                display_key_lbl.text = project_main_rec[selected_index].key
//                                display_bpm_view_ref.alpha = 1.0
//                                //bpm_view_ref.alpha = 1.0
//                            }else{
//                                display_bpm_view_ref.alpha = 0.0
//                                bpm_view_ref.alpha = 0.0
//                            }
//
//                            lyrics_view_ref.alpha = 1.0
//                        }
//
//                    }
                    
                    audioPlayer = try AVAudioPlayer(contentsOf: audio_url)
                    audioPlayer.delegate = self
                    audioPlayer.play()
                    current_playing = true
                    initialize_audio = true
                    btn_play_pause_img_ref.image = UIImage(named: "white_pause")
                    height_constraint_ref_of_btn_play_pause_img.constant = 30.0
                    btn_play_pause_img_ref.contentMode = .scaleAspectFit
                    
                    project_name_lbl.text = currentProjectName
                    
                    if(currentProjectName != "")
                    {
                        audio_file_name.text = saved_audio_file_name.removingPercentEncoding
                        self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Home_tab")
                    }
                    
                    scrubber_init()
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SharedAudioVC.update_scrubber), userInfo: nil, repeats: true)
                    current_playing = true
                    btn_play_pause_img_ref.image = UIImage(named: "white_pause")
                    height_constraint_ref_of_btn_play_pause_img.constant = 30.0
                    btn_play_pause_img_ref.contentMode = .scaleAspectFit
                    
                }
                catch
                {
                    initialize_audio = false
                    display_alert(msg_title: "Not Found", msg_desc: "File not found.", action_title: "OK")
                }
            }
            else
            {
                if(Reachability.isConnectedToNetwork())
                {
                    self.initialize_audio = false
                    
                    if(project_main_rec[selected_index].downloadURL != ""){
                        let httpsReference = Storage.storage().reference(forURL: project_main_rec[selected_index].downloadURL!)
                        self.tabBarController?.tabBar.items?[0].isEnabled = false
                        self.tabBarController?.tabBar.items?[1].isEnabled = false
                        self.tabBarController?.tabBar.items?[2].isEnabled = false
                        self.tabBarController?.tabBar.items?[3].isEnabled = false
                        self.tabBarController?.tabBar.items?[4].isEnabled = false
                        self.download_process_view_ref.alpha = 1.0
                        
                        let downloadTask = httpsReference.write(toFile: audio_url)
                        downloadTask.observe(.progress) { snapshot in
                            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                                / Double(snapshot.progress!.totalUnitCount)
                            if(percentComplete > 0)
                            {
                                self.processRing.setProgress(value: CGFloat(percentComplete), animationDuration: 0.01) {
                                }
                            }
                        }
                        downloadTask.observe(.success) { snapshot in
                            // Download completed successfully
                            self.processRing.setProgress(value: 100, animationDuration: 0.1)
                            self.download_process_view_ref.alpha = 0.0
                            self.tabBarController?.tabBar.isUserInteractionEnabled = true
                            self.tabBarController?.tabBar.items?[0].isEnabled = true
                            self.tabBarController?.tabBar.items?[1].isEnabled = true
                            self.tabBarController?.tabBar.items?[2].isEnabled = true
                            self.tabBarController?.tabBar.items?[3].isEnabled = true
                            self.tabBarController?.tabBar.items?[4].isEnabled = true
                            self.processRing.setProgress(value: 0, animationDuration: 0.0)
                            self.play_project_main_rec()
                           self.tabBarController?.tabBar.isUserInteractionEnabled = true
                        }
                        downloadTask.observe(.failure, handler: { (snapshot) in
                            self.tabBarController?.tabBar.isUserInteractionEnabled = true
                            self.download_process_view_ref.alpha = 0.0
                            self.tabBarController?.tabBar.items?[0].isEnabled = true
                            self.tabBarController?.tabBar.items?[1].isEnabled = true
                            self.tabBarController?.tabBar.items?[2].isEnabled = true
                            self.tabBarController?.tabBar.items?[3].isEnabled = true
                            self.tabBarController?.tabBar.items?[4].isEnabled = true
                            self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                        })
                    }else{
                        self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                    }
                    
                } else {
                    
                    self.initialize_audio = false
                    let ac = UIAlertController(title: "No Internet Connection", message: "For download - make sure your device is connected to the internet", preferredStyle: .alert)
                    let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
                    let titleAttrString = NSMutableAttributedString(string: "No Internet Connection", attributes: attributes)
                    ac.setValue(titleAttrString, forKey: "attributedTitle")
                    ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
                    ac.addAction(UIAlertAction(title: "ok", style: .default)
                    {
                        (result : UIAlertAction) -> Void in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    self.present(ac, animated: true)
                } 
            }
        }
        else
        {
            initialize_audio = false
            display_alert(msg_title: "Error", msg_desc: "Can't get file path", action_title: "OK")
        }
    }
    
    func initialize_audio_and_play()
    {
        if(selected_recording_url == nil)
        {
            selected_recording_url = audioArray[selected_index].audio_url
        }
        
        if let audio_url = selected_recording_url
        {
            if FileManager.default.fileExists(atPath: audio_url.path)
            {
                do
                {
                    audioPlayer = try AVAudioPlayer(contentsOf: audio_url)
                    
                    if(audioArray[selected_index].key != ""){
                        display_bpm_lbl.text = String(audioArray[selected_index].bpm)
                        display_key_lbl.text = audioArray[selected_index].key
                        selectedProjectBPM = audioArray[selected_index].bpm
                        selectedProjectKey = audioArray[selected_index].key
                    }else{
                        display_bpm_lbl.text = ""
                        display_key_lbl.text = ""
                    }
                    
                    
                    
//                    if(MyVariables.audioAnalyzerSubscription){
//
//                        if(audioArray[selected_index].key != ""){
//                            display_bpm_lbl.text = String(audioArray[selected_index].bpm)
//                            display_key_lbl.text = audioArray[selected_index].key
//                            bpm_view_ref.alpha = 0.0
//                            display_bpm_view_ref.alpha = 1.0
//                        }else{
//                            display_bpm_view_ref.alpha = 0.0
//                            bpm_view_ref.alpha = 1.0
//                            clear_bpm()
//                        }
//
//                    }else{
//                        if(bpm_counter < 5){
//                            if(audioArray[selected_index].key != ""){
//                                display_bpm_lbl.text = String(audioArray[selected_index].bpm)
//                                display_key_lbl.text = audioArray[selected_index].key
//                                display_bpm_view_ref.alpha = 1.0
//                                bpm_view_ref.alpha = 0.0
//                            }else{
//                                display_bpm_view_ref.alpha = 0.0
//                                bpm_view_ref.alpha = 1.0
//                                clear_bpm()
//                            }
//                        }else{
//                            if(audioArray[selected_index].key != ""){
//                                display_bpm_lbl.text = String(audioArray[selected_index].bpm)
//                                display_key_lbl.text = audioArray[selected_index].key
//                                display_bpm_view_ref.alpha = 1.0
//
//                            }else{
//                                display_bpm_view_ref.alpha = 0.0
//                            }
//                            bpm_view_ref.alpha = 0.0
//                            lyrics_view_ref.alpha = 1.0
//                        }
//
//                    }
                    
                    audioPlayer.delegate = self
                    audioPlayer.play()
                    current_playing = true
                    initialize_audio = true
                    btn_play_pause_img_ref.image = UIImage(named: "white_pause")
                    height_constraint_ref_of_btn_play_pause_img.constant = 30.0
                    btn_play_pause_img_ref.contentMode = .scaleAspectFit
                    project_name_lbl.text = currentProjectName
                    
                    if selected_index < audioArray.count
                    {
                        let filename = audioArray[selected_index].audio_name
                        let displayname = filename?.components(separatedBy: ".")
                        audio_file_name.text = displayname?[0].removingPercentEncoding
                        saved_audio_file_name = (displayname?[0].removingPercentEncoding)!
                    }
                    
                    if(currentProjectName != "")
                    {
                        audio_file_name.text = saved_audio_file_name
                        //self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Home_tab")
                        self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Home_tab")
                    }
                    
                    scrubber_init()
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SharedAudioVC.update_scrubber), userInfo: nil, repeats: true)
                    current_playing = true
                    btn_play_pause_img_ref.image = UIImage(named: "white_pause")
                    height_constraint_ref_of_btn_play_pause_img.constant = 30.0
                    btn_play_pause_img_ref.contentMode = .scaleAspectFit
                    
                }
                catch
                {
                    initialize_audio = false
                    display_alert(msg_title: "Not Found", msg_desc: "File not found.", action_title: "OK")
                }
            }
            else
            {
                if(Reachability.isConnectedToNetwork())
                {
                    self.initialize_audio = false
                    if(self.audioArray[self.selected_index].downloadURL != ""){
                        let httpsReference = Storage.storage().reference(forURL: self.audioArray[self.selected_index].downloadURL!)
                        self.tabBarController?.tabBar.items?[1].isEnabled = false
                        self.tabBarController?.tabBar.items?[0].isEnabled = false
                        self.tabBarController?.tabBar.items?[2].isEnabled = false
                        self.tabBarController?.tabBar.items?[3].isEnabled = false
                        self.tabBarController?.tabBar.items?[4].isEnabled = false
                        //UIApplication.shared.beginIgnoringInteractionEvents()
                        let downloadTask = httpsReference.write(toFile: audio_url)
                        self.download_process_view_ref.alpha = 1.0
                        downloadTask.observe(.progress) { snapshot in
                            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                                / Double(snapshot.progress!.totalUnitCount)
                            if(percentComplete > 0)
                            {
                                self.processRing.setProgress(value: CGFloat(percentComplete), animationDuration: 0.01) {
                                }
                            }
                        }
                        downloadTask.observe(.success) { snapshot in
                            // Download completed successfully
                            self.processRing.setProgress(value: 100, animationDuration: 0.1)
                            self.download_process_view_ref.alpha = 0.0
                            self.tabBarController?.tabBar.items?[0].isEnabled = true
                            self.tabBarController?.tabBar.items?[1].isEnabled = true
                            self.tabBarController?.tabBar.items?[2].isEnabled = true
                            self.tabBarController?.tabBar.items?[3].isEnabled = true
                            self.tabBarController?.tabBar.items?[4].isEnabled = true
                            self.processRing.setProgress(value: 0, animationDuration: 0.0)
                            self.initialize_audio_and_play()
                        }
                        downloadTask.observe(.failure, handler: { (snapshot) in
                            
                            self.download_process_view_ref.alpha = 0.0
                            self.tabBarController?.tabBar.items?[0].isEnabled = true
                            self.tabBarController?.tabBar.items?[1].isEnabled = true
                            self.tabBarController?.tabBar.items?[2].isEnabled = true
                            self.tabBarController?.tabBar.items?[3].isEnabled = true
                            self.tabBarController?.tabBar.items?[4].isEnabled = true
                            self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                        })
                    }else{
                        self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                    }
                    
                } else {
                    
                        self.initialize_audio = false
                        let ac = UIAlertController(title: "No Internet Connection", message: "For download - make sure your device is connected to the internet", preferredStyle: .alert)
                        let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
                        let titleAttrString = NSMutableAttributedString(string: "No Internet Connection", attributes: attributes)
                        ac.setValue(titleAttrString, forKey: "attributedTitle")
                        ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
                        ac.addAction(UIAlertAction(title: "ok", style: .default)
                        {
                            (result : UIAlertAction) -> Void in
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                        self.present(ac, animated: true)
 
                }
            
            }
        }
        else
        {
            initialize_audio = false
            display_alert(msg_title: "Error", msg_desc: "Can't get file path", action_title: "OK")
        }
    }
    
    @IBAction func invite_btn_click(_ sender: UIButton) {
//        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//        userRef.child("settings").observeSingleEvent(of: .value, with: { (snapshot) in
//
//            if (snapshot.exists()){
//                if(snapshot.hasChild("CollaborationSubscription")){
//                    if let data = snapshot.childSnapshot(forPath: "CollaborationSubscription").value as? NSDictionary{
//                        if let check = data.value(forKey: "isActive") as? Bool{
//                            if(check){
                                let vc : InviteVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InviteVC") as! InviteVC
                                    vc.projectCurrentId = projectCurrentId
                                self.present(vc, animated:true, completion:nil)
                                print("successfully checked on firebase")
//                            }
//                        }
//                    }
//                } else {
//                    let vc : SubscribeViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubscribeViewController") as! SubscribeViewController
//                    self.present(vc, animated:true, completion:nil)
//                    print("currently on subscribe screen")
//                }
//            }
//        })
    }
    func getExpiryDate(){
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("settings").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if (snapshot.exists()){
                if(snapshot.hasChild("CollaborationSubscription")){
                    if let data = snapshot.childSnapshot(forPath: "CollaborationSubscription").value as? NSDictionary{
                        if let check = data.value(forKey: "subscriptionDate") as? String{
                            let stringDate = check
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd.MM.yyyy"
                            let subscribeDate = dateFormatter.date(from: stringDate)
                            let expiryDate = Calendar.current.date(byAdding: .month, value: 1, to: subscribeDate!)
                            print("purchase date = \(subscribeDate),and expiryDate = \(expiryDate) and today is\(Date())")
                            if expiryDate! == Date() || expiryDate! < Date(){
                                if let uid = Auth.auth().currentUser?.uid{
                                    let userRef = FirebaseManager.getRefference().child(uid).ref
                                    let currentPlanData : [String : Any] = ["isActive" : false, "fromIos" : true, "planType" : "", "subscriptionDate" : ""]
                                    userRef.child("settings").child("CollaborationSubscription").updateChildValues( currentPlanData) { (error, reference) in
                                        if let error = error{
                                            print(error.localizedDescription)
                                            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        })
        
    }
    @IBAction func play_pause_Audio(_ sender: Any)
    {
        if(initialize_audio){
            if(current_playing){
                if let player = audioPlayer{
                    player.pause()
                }
                current_playing = false
                self.btn_play_pause_img_ref.image = UIImage(named: "white_play")
                height_constraint_ref_of_btn_play_pause_img.constant = 35.0
                self.btn_play_pause_img_ref.contentMode = .scaleToFill
            }else{
                if let player = audioPlayer{
                    player.play()
                }
                current_playing = true
                btn_play_pause_img_ref.image = UIImage(named: "white_pause")
                height_constraint_ref_of_btn_play_pause_img.constant = 30.0
                btn_play_pause_img_ref.contentMode = .scaleAspectFit
            }
        }else{
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
        if(initialize_audio){
            if let player = audioPlayer{
                player.currentTime = TimeInterval(audio_scrubber_ref.value)
            }
        }else{
            initialize_audio_and_play()
            initialize_audio = true
            if let player = audioPlayer{
                player.currentTime = TimeInterval(audio_scrubber_ref.value)
            }
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
        btn_play_pause_img_ref.image = UIImage(named: "white_play")
        height_constraint_ref_of_btn_play_pause_img.constant = 35.0
        btn_play_pause_img_ref.contentMode = .scaleToFill
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        audio_complete()
        if(repeat_play)
        {
            initialize_audio_and_play()
            initialize_audio = true
        }
    }
    
    @IBAction func play_previous_recording(_ sender: Any)
    {
        audio_complete()
        
        if(saved_project_data_flag)
        {
            remove_selected_project_data()
        }
        
        if audioArray.isEmpty
        {
            display_alert(msg_title: "No file", msg_desc: "Copy another file.", action_title: "OK")
        }
        else
        {
            selected_index = selected_index - 1
            if(selected_index < 0)
            {
                self.display_alert(msg_title: "First Recording", msg_desc: "This is first recording.", action_title: "OK")
                selected_index = 0
                
                let filename = audioArray[selected_index].audio_name
                selected_recording_url = audioArray[selected_index].audio_url
                let displayname = filename?.components(separatedBy: ".")
                audio_file_name.text = displayname?[0].removingPercentEncoding
                
            }
            else
            {
                if selected_index < audioArray.count
                {
                    selected_recording_url = audioArray[selected_index].audio_url
                    initialize_audio_and_play()
                    initialize_audio = true
                }
                else
                {
                    initialize_audio_and_play()
                    initialize_audio = true
                }
                
            }
        }
    }
    
    
    @IBAction func play_next_recording(_ sender: Any)
    {
        audio_complete()
        
        if(saved_project_data_flag)
        {
            remove_selected_project_data()
        }
        
        if audioArray.isEmpty
        {
            display_alert(msg_title: "No file", msg_desc: "Copy another file.", action_title: "OK")
        }
        else
        {
            let limit = audioArray.count - 1
            
            if(flag_one_audio_delete)
            {
                flag_one_audio_delete = false
            }
            else
            {
                selected_index = selected_index + 1
            }
            
            if(selected_index > limit)
            {
                self.display_alert(msg_title: "Last Recording", msg_desc: "This is last recording.", action_title: "OK")
                selected_index = limit
                let filename = audioArray[selected_index].audio_name
                selected_recording_url = audioArray[selected_index].audio_url
                let displayname = filename?.components(separatedBy: ".")
                audio_file_name.text = displayname?[0].removingPercentEncoding
            }
            else
            {
                if selected_index < audioArray.count
                {
                    selected_recording_url = audioArray[selected_index].audio_url
                    initialize_audio_and_play()
                    initialize_audio = true
                }
                else
                {
                    initialize_audio_and_play()
                    initialize_audio = true
                }
            }
        }
    }
    
    @IBAction func open_playLyricsRecordingVC(_ sender: Any)
    {
        flag_lyrics = true
        if(currentProjectName != "")
        {
            if(get_lyrics_key != "")
            {
                self.open_lyrics()
            }
            else
            {
                UIView.animate(withDuration: 0.5, animations : {
                    self.add_lyrics_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: {(finished : Bool) in
                    if(finished)
                    {
                        UIView.animate(withDuration: 0.5, animations : {
                            self.add_lyrics_img_ref.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                            self.add_lyrics_img_ref.image = UIImage(named: "add_lyrics_green")
                        }, completion: {(finished : Bool) in
                            if(finished)
                            {
                                self.open_lyrics()
                            }
                        })
                        
                        
                    }
                })
            }
        }
        else
        {
            save_audio_in_project()
        }
    }
    
    @IBAction func write_lyrics(_ sender: Any)
    {
        flag_lyrics = true
        if(currentProjectName != "")
        {
            open_lyrics()
        }
        else
        {
            save_audio_in_project()
        }
    }
    
    @IBAction func record_audio(_ sender: Any)
    {
        flag_recording = true
        
        if(currentProjectName == "")
        {
            save_audio_in_project()
        }
        else
        {
            record_audio_click()
        }
    }
    
    func open_recording()
    {
        flag_recording = true
        if(currentProjectName == "")
        {
            save_audio_in_project()
        }
        else
        {
            record_audio_click()
        }
    }
    
    func open_lyrics()
    {
        if(currentProjectName == "")
        {
            flag_lyrics = true
            myActivityIndicator.stopAnimating()
            save_audio_in_project()
        }
        else
        {
                openLyricsRecordingView()
        }
    }
    
    func openLyricsRecordingView()
    {
        if(initialize_audio)
        {
            audio_complete()
        }
        if(!open_play_lyrics_recording){
            
            open_play_lyrics_recording = true
            let vc : Play_LyricsRecordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayLyricsRecordingSid") as! Play_LyricsRecordingVC
            
            vc.get_lyrics_data_protocolobj = self
            vc.selected_project_key = currentProjectId
            vc.selected_project_name = currentProjectName
            vc.count_recordings = count_recordings
            vc.lyrics_key = get_lyrics_key
            vc.lyrics_text = get_lyrics_text
            vc.repeat_play = repeat_play
            vc.selected_audio_file_name = saved_audio_file_name
            vc.is_looping = is_looping
            vc.looping_start_index = looping_start_index
            vc.looping_end_index = looping_end_index
            vc.selectedBPM = selectedProjectBPM
            vc.selectedKey = selectedProjectKey
            
            if(selected_recording_url != nil){
                vc.recording_file_url = selected_recording_url!
            }
            
            myActivityIndicator.stopAnimating()
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func save_audio_in_project()
    {
        if !audioArray.isEmpty{
            let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "create_project_sid") as! CreateProjectVC
            child_view.giveProjectDataProtocol = self
            if(play_copy_to_tully_file){
                selected_index = selected_index + 1
            }
            child_view.audio_id = audioArray[selected_index].audio_key
            child_view.audio_url = audioArray[selected_index].audio_url!
            child_view.audio_name = audioArray[selected_index].audio_name!
            
            if(audioArray[selected_index].key != ""){
                child_view.bpm = audioArray[selected_index].bpm
                child_view.key = audioArray[selected_index].key
            }
            
            self.addChildViewController(child_view)
            child_view.view.frame = self.view.frame
            self.view.addSubview(child_view.view)
            child_view.didMove(toParentViewController: self)
        }
    }
    
    func get_num_of_audio_in_project()
    {
        if(count_recordings > 0)
        {
            recording_img_ref.image = UIImage(named: "Recording_Selected_tab")
            //recording_img_ref.image = UIImage(named: "multitrack_list")
            no_of_recording_lbl_ref.text = String(count_recordings)
            no_of_recording_view_ref.alpha = 1.0
        }
        else
        {
            recording_img_ref.image = UIImage(named: "recording-blue")
            //recording_img_ref.image = UIImage(named: "multitrack_list")
            no_of_recording_view_ref.alpha = 0.0
        }
    }
    
    func record_audio_click()
    {
        if(initialize_audio)
        {
            audio_complete()
        }
        if(!open_play_lyrics_recording){
            open_play_lyrics_recording = true
            let vc : Play_LyricsRecordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayLyricsRecordingSid") as! Play_LyricsRecordingVC
            vc.get_lyrics_data_protocolobj = self
            vc.selected_project_key = currentProjectId
            vc.selected_project_name = currentProjectName
            vc.count_recordings = count_recordings
            vc.lyrics_key = get_lyrics_key
            vc.lyrics_text = get_lyrics_text
            vc.selected_audio_file_name = saved_audio_file_name
            vc.repeat_play = repeat_play
            vc.is_looping = is_looping
            vc.looping_start_index = looping_start_index
            vc.looping_end_index = looping_end_index
            vc.selectedBPM = selectedProjectBPM
            vc.selectedKey = selectedProjectKey
            vc.auto_start_record = true
            if(selected_recording_url != nil)
            {
                vc.recording_file_url = selected_recording_url!
            }
            myActivityIndicator.stopAnimating()
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    func remove_selected_project_data()
    {
        currentProjectName = ""
        get_lyrics_text = ""
        currentProjectId = ""
        selectedProjectBPM = 0
        selectedProjectKey = ""
        recording_img_ref.image = UIImage(named: "recording-blue")
        //recording_img_ref.image = UIImage(named: "multitrack_list")
        no_of_recording_view_ref.alpha = 0.0
        lyrics_txt_view_ref.text = ""
        saved_project_data_flag = false
        count_recordings = 0
        UIView.animate(withDuration: 0.5, animations : {
            self.add_lyrics_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: {(finished : Bool) in
            if(finished)
            {
                UIView.animate(withDuration: 0.5, animations : {
                    self.add_lyrics_img_ref.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    self.add_lyrics_img_ref.image = UIImage(named: "plus-icon")
                }, completion: {(finished : Bool) in
                    if(finished)
                    {
                        self.add_lyrics_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.add_lyrics_view_ref.alpha = 1.0
                    }
                })
            }
        })
    }
    
    @IBAction func go_back(_ sender: Any)
    {
        if(initialize_audio){
            if(Reachability.isConnectedToNetwork()){
                if let player = audioPlayer{
                    if(player.isPlaying){
                        audio_complete()
                    }
                }
            }
        }
        
        self.tabBarController?.tabBar.items![1].image = UIImage(named: "Play_tab")
            self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Home_Selected_tab")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openRecordingListView(_ sender: Any)
    {
        
        if(count_recordings > 0){
            if(initialize_audio){
                audio_complete()
            }
            
            let vc = UIStoryboard(name: "superpowered", bundle: nil).instantiateViewController(withIdentifier: "ProjectRecordingListSid") as! ProjectRecordingListVC
            vc.current_project_name = currentProjectName
            vc.currentProjectID = currentProjectId
            present(vc, animated: true, completion: nil)
        }else{
            display_alert(msg_title: "No recordings", msg_desc: "", action_title: "OK")
        }
        
        
    }
    
    // Get copytotully data
    
    func get_files()
    {
        var free_beat : playData? = nil
        myActivityIndicator.startAnimating()
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("copytotully").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            self.audioArray.removeAll()
            for snap in snapshot.children
            {
                let userSnap = snap as! DataSnapshot
                let rec_key = userSnap.key
                let rec_dict = userSnap.value as? [String : AnyObject]
                let name = rec_dict?["title"] as! String
                let tid = rec_dict?["filename"] as! String
                let byte_size = rec_dict?["size"] as! Int64
                var myurl = rec_dict?["downloadURL"] as? String
                var bpm = 0
                var key = ""
                
                if(myurl == nil)
                {
                    myurl = ""
                }
                
                if let audioBpm = rec_dict?["bpm"] as? Int{
                    bpm = audioBpm
                }
                if let audioKey = rec_dict?["key"] as? String{
                    key = audioKey
                }
                
                var kb_size = String(byte_size/1000)
                kb_size = kb_size + " KB"
                
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let mydir = documentsDirectory.appendingPathComponent("copytoTully/" + tid)
                var have_local_file = false
                
                if(FileManager.default.fileExists(atPath: mydir.path)){
                    have_local_file = true
                }
                
                if(rec_key == "-L1111aaaaaaaaaaaaaa"){
                    free_beat = playData(audio_key : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, bpm: bpm, key: key)
                }else{
                    let temp_audio_data = playData(audio_key : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, bpm: bpm, key: key)
                    self.audioArray.append(temp_audio_data)
                }
            }
            if(free_beat != nil){
                self.audioArray.append(free_beat!)
            }
            
            self.myActivityIndicator.stopAnimating()
            self.audioArray = self.audioArray.reversed()
            self.audio_list_tbl_ref.reloadData()
        })
    }
    
    // Audio List of copytotully & Tableview delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shared_audio_list_tbl_cell", for: indexPath) as! SharedAudio_tbl_cell
        cell.audio_counter_lbl_ref.text = String(indexPath.row + 1)
        cell.audio_name_lbl_ref.text = audioArray[indexPath.row].audio_name?.removingPercentEncoding
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        count_recordings = 0
        recording_img_ref.image = UIImage(named: "recording-blue")
        //recording_img_ref.image = UIImage(named: "multitrack_list")
        no_of_recording_view_ref.alpha = 0.0
        audio_complete()
        
        if(saved_project_data_flag)
        {
            remove_selected_project_data()
        }
        selected_index = indexPath.row
        selected_recording_url = audioArray[selected_index].audio_url
        clear_looping()
        
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }, completion: nil)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.down:
                swipe_down_gesture_called()
            
            case UISwipeGestureRecognizerDirection.up:
                swipe_up_gesture_called()
            
            default:
                break
            }
        }
    }
    
    func swipe_down_gesture_called()
    {
        audio_list_view_ref.alpha = 0.0
        lyrics_view_ref.alpha = 1.0
        top_constraint_of_bottom_view.constant = 1
        bottom_constraint_of_bottom_view.constant = 0
    }
    
    func swipe_up_gesture_called()
    {
        audio_list_view_ref.alpha = 1.0
        let height = audio_list_view_ref.frame.height
        lyrics_view_ref.alpha = 0.0
        top_constraint_of_bottom_view.constant = -(height)
        bottom_constraint_of_bottom_view.constant = height
    }
    
    @IBAction func loop_btn_click(_ sender: UIButton) {
        if(is_looping){
            clear_looping()
            
        }else{
            
            if(initialize_audio)
            {
                if(audioPlayer.isPlaying)
                {
                    audio_complete()
                }
            }
            
            let vc : LoopRecordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loop_recording_sid") as! LoopRecordingVC
            vc.recording_file_url = selected_recording_url
            vc.myProtocol = self
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        if(initialize_audio){
            if let player = audioPlayer{
                if(player.isPlaying){
                    audio_complete()
                }
            }
        }
        
        self.tabBarController?.tabBar.items![1].image = UIImage(named: "Play_tab")
        self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Home_Selected_tab")
        
    }
    
    // Broadcast button click
    
    @IBAction func broadcast_btn_click(_ sender: Any)
    {
    
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
    
    @IBAction func dot_btn_click(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        alertController.addAction(cancelAction)
        
        if(currentProjectName == ""){
            let createAction = UIAlertAction(title: "Create", style: .default) { action in
                self.flag_lyrics = true
                if(self.currentProjectName != "")
                {
                    self.open_lyrics()
                }
                else
                {
                    self.save_audio_in_project()
                }
            }
            alertController.addAction(createAction)
        }
        else
        {
            let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
                self.rename_project()
            }
            alertController.addAction(renameAction)
        }
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { action in
            self.share_project()
        }
        
        
        alertController.addAction(shareAction)
        
        alertController.view.tintColor = UIColor(red: 49/255, green: 208/255, blue: 152/255, alpha: 1)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func rename_project()
    {
        let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rename_project_sid") as! RenameProjectFileVC
        child_view.renameCompleteProtocol = self
        child_view.selected_nm = currentProjectName
        child_view.rename_file = false
        child_view.is_project = true
        child_view.project_id = currentProjectId
    
        self.addChildViewController(child_view)
        child_view.view.frame = self.view.frame
        self.view.addSubview(child_view.view)
        child_view.didMove(toParentViewController: self)
    }
    
    func renameDone(isSuccessful : Bool,newName : String)
    {
        currentProjectName = newName
        project_name_lbl.text = currentProjectName
    }
    
    func share_project()
    {
        if(currentProjectId != "")
        {
            let myuserid = Auth.auth().currentUser?.uid
            if(myuserid != nil)
            {
                let postString = "userid="+myuserid!+"&projectid="+self.currentProjectId
                let myurlString = MyConstants.share_project
                let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareSecureDownloadVC_sid") as! ShareSecureDownloadVC
                child_view.shareSecureResponseProtocol = self
                child_view.shareString = postString
                child_view.urlString = myurlString
                present(child_view, animated: true, completion: nil)
                
            }
        }else{
            var copytotully_ids : [String] = []
            copytotully_ids.append(audioArray[selected_index].audio_key)
            
            share_copytotully(audio_ids: copytotully_ids)
            //display_alert(msg_title: "Create project first !", msg_desc: "After creating project you can share", action_title: "OK")
        }
    }
    
    func share_copytotully(audio_ids : [String])
    {
        let myuserid = Auth.auth().currentUser?.uid
        if(myuserid != nil)
        {
            let copytotully_ids = audio_ids.joined(separator: ",")
            let postString = "userid="+myuserid!+"&ids="+copytotully_ids
            let myurlString = MyConstants.share_copytotully
            let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareSecureDownloadVC_sid") as! ShareSecureDownloadVC
            child_view.shareSecureResponseProtocol = self
            child_view.shareString = postString
            child_view.urlString = myurlString
            present(child_view, animated: true, completion: nil)
        }
    }
    
    //MARK: - Share Security
    
    func shareSecureResponse(allowDownload: Bool, postStringData: String, urlString: String, isCancel: Bool, token: String, type: String, expireTime: Int) {
        if(!isCancel){
            share_data(myString : postStringData, MyUrlString : urlString, allowDownload_shareSecurity : allowDownload, token: token, type: type, expireTime: expireTime)
        }
    }
    
    func share_data(myString : String, MyUrlString : String, allowDownload_shareSecurity : Bool, token : String, type : String, expireTime: Int){
        
        self.myActivityIndicator.startAnimating()
        var my_share_data : [NSMutableDictionary] = []
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(allowDownload_shareSecurity, forKey: "allow_download")
        jsonObject.setValue(type, forKey: "type")
        jsonObject.setValue(expireTime, forKey: "expiry")
        my_share_data.append(jsonObject)
        
        do{
            let data =  try JSONSerialization.data(withJSONObject: my_share_data, options:[])
            let mystring = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            
            var request = URLRequest(url: URL(string: MyUrlString)!)
            request.setValue(token, forHTTPHeaderField: MyConstants.Authorization)
            request.httpMethod = "POST"
            let share_string = "&config="+mystring!
            
            let postString = myString+share_string
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else{
                    self.myActivityIndicator.stopAnimating()
                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK", myVC: self)
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                    self.myActivityIndicator.stopAnimating()
                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: String(describing: response), action_title: "OK", myVC: self)
                }else{
                    do{
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                            DispatchQueue.main.async (execute: {
                                self.myActivityIndicator.stopAnimating()
                                let status = json["status"] as! Int
                                if(status == 1){
                                    let mydata = json["data"] as! NSDictionary
                                    let mylink = mydata["link"] as! String
                                    let activityItem: [String] = [mylink as String]
                                    let avc = UIActivityViewController(activityItems: activityItem, applicationActivities: nil)
                                    self.present(avc, animated: true, completion: nil)
                                }else{
                                    let msg = json["msg"] as! String
                                    self.myActivityIndicator.stopAnimating()
                                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: msg, action_title: "Ok", myVC: self)
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
        }catch let error {
            DispatchQueue.main.async {
                self.myActivityIndicator.stopAnimating()
                self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
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
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setProjectData(projectId : String, projectName : String, recording_url : URL)
    {
       // myActivityIndicator.startAnimating()
        self.currentProjectName = projectName
        self.currentProjectId = projectId
        project_name_lbl.text = projectName
        selected_recording_url = recording_url
        //self.initialize_audio_and_play()
        //initialize_audio = true
        saved_project_data_flag = true
        if(flag_recording)
        {
            flag_recording = false
            record_audio_click()
            //myActivityIndicator.stopAnimating()
        }
        
        if(flag_lyrics)
        {
            flag_lyrics = false
            open_lyrics()
            //myActivityIndicator.stopAnimating()
        }
        
        //audioArray.remove(at: selected_index)
        flag_one_audio_delete = true
    }
    
    func lyrics_data(lyrics_key: String, lyrics_txt: String, count_recording: Int, repeat_play_data: Bool, is_looping: Bool, looping_start_index: Int, looping_end_index: Int)
    {
        get_lyrics_key = lyrics_key
        get_lyrics_text = lyrics_txt
        count_recordings = count_recording
        repeat_play = repeat_play_data
        self.is_looping = is_looping
        self.looping_start_index = looping_start_index
        self.looping_end_index = looping_end_index
        
        if(get_lyrics_text != "")
        {
            lyrics_txt_view_ref.text = get_lyrics_text
            add_lyrics_view_ref.alpha = 0.0
        }
        project_name_lbl.text = currentProjectName
        get_num_of_audio_in_project()
    }
    
    func setSavedUrl(viewedUrl : String)
    {
        count_recordings = count_recordings + 1
        get_num_of_audio_in_project()
    }
    
    func setCurrentKey(savedKey : String)
    {
        //current_key = savedKey
    }
    
    func setProjectKey(projectKey : String)
    {
        project_name_lbl.text = currentProjectName
        //project_key = projectKey
    }
    
    func looping_range(start_time: Float, end_time: Float) {
        //goto_big_lyrics = false
        if(start_time == 0.0 && end_time == 0.0){
            is_looping = false
            repeat_play = false
            set_lbl_as_loop()
        }else{
            is_looping = true
            repeat_play = true
            set_lbl_as_unloop()
        }
        looping_start_index = Int(start_time)
        looping_end_index = Int(end_time)
        initialize_audio_and_play()
        initialize_audio = true
    }
    
    func clear_looping(){
        repeat_play = false
        is_looping = false
        set_lbl_as_loop()
        looping_start_index = 0
        looping_end_index = 0
        initialize_audio_and_play()
        initialize_audio = true
    }
    
    func set_lbl_as_loop(){
        loop_lbl_ref.text = "Loop"
        loop_img_ref.image = UIImage(named: "loop")
        loop_lbl_ref.textColor = UIColor(red: 59/255, green: 79/255, blue: 111/255, alpha: 1.0)
    }
    
    func set_lbl_as_unloop(){
        loop_lbl_ref.text = "UnLoop"
        loop_img_ref.image = UIImage(named: "loop-green")
        loop_lbl_ref.textColor = UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1.0)
        //loop_lbl_ref.textColor = UIColor.green
    }
    
    //MARK: For Audio Analyzer
    
    
    @IBAction func btn_detect_click(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.get_bpm_and_key()
        }
        
//        if(MyVariables.audioAnalyzerSubscription){
//            self.bpm_detect_view.alpha = 1.0
//            DispatchQueue.main.async {
//                self.get_bpm_and_key()
//            }
//        }else{
//            if(bpm_counter < 5){
//                self.bpm_detect_view.alpha = 1.0
//                DispatchQueue.main.async {
//                    self.get_bpm_and_key()
//                }
//            }
//        }
        
    }
    
    func get_bpm_and_key(){
        self.bpm_detect_view.alpha = 1.0
        DispatchQueue.main.async {
            if let audio_url = self.selected_recording_url
            {
                if FileManager.default.fileExists(atPath: audio_url.path)
                {
                    if let data = self.audioAnalyzer.analyze(audio_url.absoluteString){
                        
                        let my_val = data.split(separator: ",")
                        if String(my_val[0]) != ""{
                            
                            if String(my_val[1]) != ""{
                                
                                
                                if(self.currentProjectId != ""){
                                    self.project_main_rec[self.selected_index].bpm = Int(my_val[0])!
                                    self.project_main_rec[self.selected_index].key = String(my_val[1])
                                    self.selectedProjectKey = String(my_val[1])
                                    self.selectedProjectBPM = Int(my_val[0])!
                                    self.set_project_bpm_to_firebase(bpm: Int(my_val[0])!, key: String(my_val[1]))
                                }else{
                                    self.audioArray[self.selected_index].bpm = Int(my_val[0])!
                                    self.audioArray[self.selected_index].key = String(my_val[1])
                                    self.selectedProjectKey = String(my_val[1])
                                    self.selectedProjectBPM = Int(my_val[0])!
                                    
                                    self.set_copytotully_bpm_to_firebase(bpm: Int(my_val[0])!, key: String(my_val[1]))
                                }
                              //  self.update_bpm_counter()
                            }
                        }
                        
                       // timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SharedAudioVC.update_scrubber), userInfo: nil, repeats: true)
                        
                        self.bpmCompleteTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(SharedAudioVC.bpmCompleteDetect), userInfo: nil, repeats: false)
                        
                        //self.bpm_subscribe_img_ref.image = UIImage(named: "bpm_subscribe")
                        
                    }
                }else{
                    self.bpm_detect_view.alpha = 0.0
                    self.display_alert(msg_title: "File Not Found.", msg_desc: "", action_title: "OK")
                }
            }
        }
    }
    
    func bpmCompleteDetect(){
        analyzer_bpm.text = String(selectedProjectBPM)
        analyzer_key.text = selectedProjectKey
        display_bpm_lbl.text = String(selectedProjectBPM)
        display_key_lbl.text = selectedProjectKey
        btn_analyzer_detect_ref.alpha = 0.0
        img_analyzer_done_reff.alpha = 1.0
        bpm_detect_view.alpha = 0.0
        bpmCompleteTimer.invalidate()
    }
    
    func update_bpm_counter(){
        bpm_counter += 1
        let bpm_data : [String : Any] = ["freeTrials" : bpm_counter]
        if let uid = Auth.auth().currentUser?.uid{
        let userRef = FirebaseManager.getRefference().child(uid)
            
        userRef.child("settings").child("audioAnalyzer").updateChildValues(bpm_data, withCompletionBlock: { (error, database_ref) in
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    self.myActivityIndicator.stopAnimating()
                }
            
            })
        }
    }
    
    func clear_bpm(){
        self.btn_analyzer_detect_ref.alpha = 1.0
        self.img_analyzer_done_reff.alpha = 0.0
        self.analyzer_key.text = "---"
        self.analyzer_bpm.text = "---"
    }
    
    func set_project_bpm_to_firebase(bpm : Int, key : String){
        let bpm_data : [String : Any] = ["bpm" : bpm, "key" : key]
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid)
            let audioKey = project_main_rec[selected_index].audio_key
        userRef.child("projects").child(currentProjectId).child("recordings").child(audioKey).updateChildValues(bpm_data, withCompletionBlock: { (error, database_ref) in
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    self.myActivityIndicator.stopAnimating()
                }
            })
        }
    }
    
    func set_copytotully_bpm_to_firebase(bpm : Int, key : String){
        let bpm_data : [String : Any] = ["bpm" : bpm, "key" : key]
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid)
            let audioKey = audioArray[selected_index].audio_key
            userRef.child("copytotully").child(audioKey).updateChildValues(bpm_data, withCompletionBlock: { (error, database_ref) in
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    self.myActivityIndicator.stopAnimating()
                }
            })
        }
    }
    
    func beatLoader(notification:Notification) -> Void {
        if let extractInfo = notification.userInfo {
            print(" my data: \(String(describing: extractInfo["data1"]))");
        }
    }
    
    @IBAction func btn_bpm_click(_ sender: UIButton) {
        
        
        if(displayBpmView){
            self.lyrics_view_ref.alpha = 1.0
            self.bpm_view_ref.alpha = 0.0
            bpm_subscribe_img_ref.image = UIImage(named: "bpm_subscribe")
            displayBpmView = false
        }else{
            self.clear_bpm()
            self.lyrics_view_ref.alpha = 0.0
            self.bpm_view_ref.alpha = 1.0
            self.display_bpm_view_ref.alpha = 1.0
            bpm_subscribe_img_ref.image = UIImage(named: "bpm_subscribe_selected")
            displayBpmView = true
        }
        
        
//        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//        userRef.child("settings").observeSingleEvent(of: .value, with: { (snapshot) in
//
//            if (snapshot.exists()){
//                if(snapshot.hasChild("audioAnalyzer")){
//                    if let data = snapshot.childSnapshot(forPath: "audioAnalyzer").value as? NSDictionary{
//                        if let check = data.value(forKey: "isActive") as? Bool{
//                            if(check){
//                                if let viewWithTag = self.view.viewWithTag(100) {
//                                    viewWithTag.removeFromSuperview()
//                                    let x = (self.bpmDetectImgRef.frame.origin.x - 7)
//                                    self.myView = SuperPoweredSpinnerView(frame: CGRect(x: x, y: 0, width: 60, height: 60))
//                                    self.myView.tag = 100
//                                    self.bpm_detect_view.addSubview(self.myView)
//                                }
//                                UserDefaults.standard.set("true", forKey: "audioAnalyzerSubscription")
//                                MyVariables.audioAnalyzerSubscription = true
//                                self.clear_bpm()
//                                self.bpm_view_ref.alpha = 1.0
//                                self.display_bpm_view_ref.alpha = 1.0
//                            }else{
//
//                                self.display_bpm_view_ref.alpha = 0.0
//                                UserDefaults.standard.set("false", forKey: "audioAnalyzerSubscription")
//                                MyVariables.audioAnalyzerSubscription = false
//                                let vc = UIStoryboard(name: "superpowered", bundle: nil).instantiateViewController(withIdentifier: "SuperPoweredSubscribeVC") as! SuperPoweredSubscribeVC
//                                self.present(vc, animated: true, completion: nil)
//
//                            }
//                        }else{
//                            if let counter = data.value(forKey: "freeTrials") as? Int{
//                                self.bpm_counter = counter
//                            }
//
//                            if(self.bpm_counter >= 5){
//                                self.display_bpm_view_ref.alpha = 0.0
//                                UserDefaults.standard.set("false", forKey: "audioAnalyzerSubscription")
//                                MyVariables.audioAnalyzerSubscription = false
//                                let vc = UIStoryboard(name: "superpowered", bundle: nil).instantiateViewController(withIdentifier: "SuperPoweredSubscribeVC") as! SuperPoweredSubscribeVC
//                                self.present(vc, animated: true, completion: nil)
//                            }else{
//                                self.clear_bpm()
//                                self.bpm_view_ref.alpha = 1.0
//                                self.display_bpm_view_ref.alpha = 1.0
//                            }
//                        }
//                    }
//                }else{
//
//                    UserDefaults.standard.set("false", forKey: "audioAnalyzerSubscription")
//                    MyVariables.audioAnalyzerSubscription = false
//                }
//            }
//        })
    }
    
    @IBAction func open_lyrics(_ sender: UIButton) {
        
        self.lyrics_view_ref.alpha = 1.0
        self.bpm_view_ref.alpha = 0.0
        bpm_subscribe_img_ref.image = UIImage(named: "bpm_subscribe")
        displayBpmView = false
        
    }
    
}



extension UIAlertAction{
    @NSManaged var image : UIImage?
    
    convenience init(title: String?, style: UIAlertActionStyle,image : UIImage?, handler: ((UIAlertAction) -> Swift.Void)? = nil ){
        self.init(title: title, style: style, handler: handler)
        self.image = image
    }
}
