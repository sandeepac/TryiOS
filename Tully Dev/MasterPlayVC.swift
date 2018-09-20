//
//  MasterPlayVC.swift
//  Tully Dev
//
//  Created by macbook on 1/30/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import UICircularProgressRing
import Mixpanel
import CoreBluetooth

class MasterPlayVC: UIViewController, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource , CBCentralManagerDelegate, lyricsCompleteProtocol{

    //MARK: - Outlets
    
    @IBOutlet weak var bpm_subscribe_img_ref: UIImageView!
    @IBOutlet weak var img_analyzer_done_reff: UIImageView!
    @IBOutlet weak var btn_analyzer_detect_ref: UIButton!
    @IBOutlet weak var display_key_lbl: UILabel!
    @IBOutlet weak var display_bpm_lbl: UILabel!
    @IBOutlet weak var bpmDetectPercentage: UILabel!
    @IBOutlet weak var bpmDetectImgRef: UIImageView!
    @IBOutlet weak var bpm_detect_view: UIView!
    @IBOutlet weak var analyzer_bpm: UILabel!
    @IBOutlet weak var analyzer_key: UILabel!
    @IBOutlet weak var bpm_view_ref: UIView!
    @IBOutlet weak var display_bpm_view_ref: UIView!
    @IBOutlet var lyrics_view_ref: UIView!
    @IBOutlet var bottom_constraint_of_bottom_view: NSLayoutConstraint!
    @IBOutlet var bottom_view_height_constraint_ref: NSLayoutConstraint!
    @IBOutlet var top_constraint_of_bottom_view: NSLayoutConstraint!
    @IBOutlet var audio_list_view_ref: UIView!
    @IBOutlet var audio_list_tbl_ref: UITableView!
    @IBOutlet var recording_view_ref: UIView!
    @IBOutlet var whole_view_bottom_constraint: NSLayoutConstraint!
    @IBOutlet var add_lyrics_view_ref: UIView!
    @IBOutlet var btn_play_pause_img_ref: UIImageView!
    @IBOutlet var audio_scrubber_ref: MySlider!
    @IBOutlet var start_time_lbl: UILabel!
    @IBOutlet var end_time_lbl: UILabel!
    
    @IBOutlet var audio_folder_name: UILabel!
    
    @IBOutlet var audio_file_name: UILabel!
    @IBOutlet var lyrics_txt_view_ref: UITextView!
    @IBOutlet var recording_time_lbl_ref: UILabel!
    @IBOutlet var audio_bg_img_ref: UIImageView!
    @IBOutlet var repeat_img_ref: UIImageView!
    @IBOutlet var processRing: UICircularProgressRingView!
    @IBOutlet var download_process_view_ref: UIView!
    @IBOutlet var add_lyrics_img_ref: UIImageView!
    @IBOutlet var bottom_img_rec_height_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_img_rec_width_constraint: NSLayoutConstraint!
    
    //MARK: - Variables
    var timer = Timer()
    var bpmCompleteTimer = Timer()
    var current_playing = false
    var initialize_audio = false
    var flag_lyrics = false
    var flag_recording = false
    var audioPlayer : AVAudioPlayer!
    var currentFileName : String = ""
    var audioArray = [MasterData]()
    var selected_index : Int = 0
    var get_lyrics_text = ""
    var come_as_present = false
    var selected_recording_url : URL? = nil
    var repeat_play = false
    var flag_one_audio_delete = false
    var saved_audio_file_name = ""
    var end_time : Float = 0.0
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var comeFromProject = false
    var manager:CBCentralManager!
    var flag_bluetooth = false
    var folder_id = ""
    var myView : SuperPoweredSpinnerView!
    var audioAnalyzer = AudioAnalyzer()
    var bpm_counter = 0
    
    var selectedProjectBPM = 0
    var selectedProjectKey = ""
    var displayBpmView = false
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn_analyzer_detect_ref.layer.cornerRadius = 10.0
        btn_analyzer_detect_ref.clipsToBounds = true
        
        let x = (bpmDetectImgRef.frame.origin.x - 7)
        myView = SuperPoweredSpinnerView(frame: CGRect(x: x, y: 0, width: 60, height: 60))
        myView.tag = 100
        self.bpm_detect_view.addSubview(myView)
        
        manager = CBCentralManager(delegate: self, queue: nil, options: nil)
        manager.delegate = self
        let screenWidth = UIScreen.main.bounds.width
        let height_width = ((screenWidth / 5) - 28)
        audio_scrubber_ref.setMaximumTrackImage(UIImage(named: "remaining_track_color"), for: .normal)
        //audio_scrubber_ref.addTarget(self, action: #selector(self.updateSliderLabelInstant(sender:)), for: .allEvents)
        bottom_img_rec_width_constraint.constant = height_width
        bottom_img_rec_height_constraint.constant = height_width
        
        self.navigationController?.isNavigationBarHidden = true

        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        get_parent_name()
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
    override func viewWillAppear(_ animated: Bool)
    {
        check_audio_analyzer_subscription()
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
        add_lyrics_img_ref.image = UIImage(named: "plus-icon")
        add_lyrics_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        self.tabBarController?.tabBar.items![1].image = UIImage(named: "Play_Selected_tab")
        self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Home_tab")
        
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
            }
            else
            {
                add_lyrics_img_ref.image = UIImage(named: "plus-icon")
                add_lyrics_img_ref.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            
    
            if(audioArray.count > 0)
            {
                initialize_audio = true
                self.initialize_audio_and_play()
            }
        
    }
    
    func get_parent_name(){
        if(folder_id == "0"){
            audio_folder_name.text = ""
        }else{
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            userRef.child("masters").child(folder_id).observeSingleEvent(of: .value, with: { (snapshot) in
                if(snapshot.exists()){
                    let mydata = snapshot.value as! NSDictionary
                    if let current_name = mydata.value(forKey: "name") as? String{
                        print(current_name)
                        self.audio_folder_name.text = current_name
                    }
                }
            })
        }
    }
    
    
    
    func initialize_audio_and_play()
    {
        if(selected_recording_url == nil)
        {
             let audioID = audioArray[selected_index].filename
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let mydir = documentsDirectory.appendingPathComponent("masters/" + audioID)
                selected_recording_url = mydir
            
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
                        self.lyrics_view_ref.alpha = 1.0
                        self.bpm_view_ref.alpha = 0.0
                        bpm_subscribe_img_ref.image = UIImage(named: "bpm_subscribe")
                        displayBpmView = false
                        
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
                    
                    if selected_index < audioArray.count
                    {
                        let filename = audioArray[selected_index].name
                        let displayname = filename?.components(separatedBy: ".")
                        audio_file_name.text = displayname?[0]
                        saved_audio_file_name = (displayname?[0])!
                    }
                    
                    scrubber_init()
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SharedAudioVC.update_scrubber), userInfo: nil, repeats: true)
                    current_playing = true
                    btn_play_pause_img_ref.image = UIImage(named: "white_pause")
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
                    
                    if(audioArray[selected_index].downloadUrl != ""){
                        let httpsReference = Storage.storage().reference(forURL: audioArray[selected_index].downloadUrl!)
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
                            self.processRing.setProgress(value: 0, animationDuration: 0.0)
                            self.initialize_audio_and_play()
                        }
                        downloadTask.observe(.failure, handler: { (snapshot) in
                            self.download_process_view_ref.alpha = 0.0
                            self.myActivityIndicator.stopAnimating()
                            self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                        })
                    }else{
                        self.myActivityIndicator.stopAnimating()
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
    
    @IBAction func play_pause_Audio(_ sender: Any)
    {
        if(initialize_audio)
        {
            if(current_playing)
            {
                audioPlayer.pause()
                current_playing = false
                self.btn_play_pause_img_ref.image = UIImage(named: "white_play")
            }
            else
            {
                audioPlayer.play()
                current_playing = true
                btn_play_pause_img_ref.image = UIImage(named: "white_pause")
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
        btn_play_pause_img_ref.image = UIImage(named: "white_play")
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
                
                let filename = audioArray[selected_index].name
                if let audioID = audioArray[selected_index].id{
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let mydir = documentsDirectory.appendingPathComponent("masters/" + audioID)
                    selected_recording_url = mydir
                }
                let displayname = filename?.components(separatedBy: ".")
                audio_file_name.text = displayname?[0]
            }
            else
            {
                if selected_index < audioArray.count
                {
                    if let audioID = audioArray[selected_index].id{
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let mydir = documentsDirectory.appendingPathComponent("masters/" + audioID)
                        selected_recording_url = mydir
                    }
                    
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

        
        if audioArray.isEmpty
        {
            display_alert(msg_title: "No file", msg_desc: "Copy another file.", action_title: "OK")
        }
        else
        {
            let limit = audioArray.count - 1
            
            if(flag_one_audio_delete){
                flag_one_audio_delete = false
            }else{
                selected_index = selected_index + 1
            }
            
            if(selected_index > limit){
                self.display_alert(msg_title: "Last Recording", msg_desc: "This is last recording.", action_title: "OK")
                selected_index = limit
                let filename = audioArray[selected_index].name
                if let audioID = audioArray[selected_index].id{
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let mydir = documentsDirectory.appendingPathComponent("masters/" + audioID)
                    selected_recording_url = mydir
                }
                let displayname = filename?.components(separatedBy: ".")
                audio_file_name.text = displayname?[0]
            }else{
                if selected_index < audioArray.count
                {
                    if let audioID = audioArray[selected_index].id{
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let mydir = documentsDirectory.appendingPathComponent("masters/" + audioID)
                        selected_recording_url = mydir
                    }
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
        let vc : LyricsInMasterVC = UIStoryboard(name: "master", bundle: nil).instantiateViewController(withIdentifier: "LyricsInMasterVCSid") as! LyricsInMasterVC
        //vc.get_lyrics_data_protocolobj = self
        vc.lyricsCompleteProtocol = self
        vc.selected_audio_id = audioArray[selected_index].id!
        vc.recording_file_url = selected_recording_url
        vc.lyrics_text = get_lyrics_text
        vc.repeat_play = repeat_play
        vc.selected_audio_file_name = saved_audio_file_name
        vc.selectedBPM = selectedProjectBPM
        vc.selectedKey = selectedProjectKey
        
        myActivityIndicator.stopAnimating()
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func write_lyrics(_ sender: Any)
    {
        let vc : LyricsInMasterVC = UIStoryboard(name: "master", bundle: nil).instantiateViewController(withIdentifier: "LyricsInMasterVCSid") as! LyricsInMasterVC
        //vc.get_lyrics_data_protocolobj = self
        
        vc.selected_audio_id = audioArray[selected_index].id!
        vc.recording_file_url = selected_recording_url
        vc.lyrics_text = get_lyrics_text
        vc.repeat_play = repeat_play
        vc.selected_audio_file_name = saved_audio_file_name
        vc.selectedBPM = selectedProjectBPM
        vc.selectedKey = selectedProjectKey
        
        myActivityIndicator.stopAnimating()
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    @IBAction func go_back(_ sender: Any)
    {
        if(initialize_audio)
        {
            if(Reachability.isConnectedToNetwork())
            {
                if(audioPlayer.isPlaying)
                {
                    audio_complete()
                }
            }
            
        }
        
        self.tabBarController?.tabBar.items![1].image = UIImage(named: "Play_tab")
            self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Home_Selected_tab")
        
        self.navigationController?.popViewController(animated: true)
    }
        
    //MARK: - Tableview delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shared_audio_list_tbl_cell", for: indexPath) as! SharedAudio_tbl_cell
        cell.audio_counter_lbl_ref.text = String(indexPath.row + 1)
        cell.audio_name_lbl_ref.text = audioArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        audio_complete()
        
        selected_index = indexPath.row
        if let audioID = audioArray[selected_index].id{
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let mydir = documentsDirectory.appendingPathComponent("masters/" + audioID)
            selected_recording_url = mydir
        }
        initialize_audio_and_play()
        initialize_audio = true
        
        
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
        //bottom_view_height_constraint_ref.constant = height
        top_constraint_of_bottom_view.constant = -(height)
        bottom_constraint_of_bottom_view.constant = height
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if(initialize_audio)
        {
            if(audioPlayer.isPlaying)
            {
                audio_complete()
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
        
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { action in
            //self.share_project()
        }
        
        
        alertController.addAction(shareAction)
        
        alertController.view.tintColor = UIColor(red: 49/255, green: 208/255, blue: 152/255, alpha: 1)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    /*
    func share_project()
    {
        if(currentProjectId != "")
        {
            let myuserid = Auth.auth().currentUser?.uid
            if(myuserid != nil)
            {
                let userRef = FirebaseManager.getRefference().child(myuserid!).ref
                userRef.child("projects").child(currentProjectId).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if (snapshot.exists() && snapshot.hasChild("project_name")){
                        
                        var share_project_flag = true
                        
                        let project_value = snapshot.value as! NSDictionary
                        
                        
                        if((project_value.value(forKey: "recordings") as? NSDictionary) != nil)
                        {
                            let record_data =  project_value.value(forKey: "recordings") as! NSDictionary
                            let recording_key = record_data.allKeys as! [String]
                            for key in recording_key
                            {
                                let rec_dict = record_data.value(forKey: key) as? NSDictionary
                                let download_url = rec_dict?["downloadURL"] as? String
                                
                                if(download_url == nil)
                                {
                                    share_project_flag = false
                                }
                            }
                            
                            if(share_project_flag)
                            {
                                self.myActivityIndicator.startAnimating()
                                var request = URLRequest(url: URL(string: "http://tullyconnect.com/api/share/project")!)
                                request.httpMethod = "POST"
                                let postString = "userid="+myuserid!+"&projectid="+self.currentProjectId
                                request.httpBody = postString.data(using: .utf8)
                                
                                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                                    
                                    guard let data = data, error == nil else
                                    {
                                        self.myActivityIndicator.stopAnimating()
                                        self.display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK")
                                        return
                                    }
                                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
                                    {
                                        self.myActivityIndicator.stopAnimating()
                                        self.display_alert(msg_title: "Error", msg_desc: String(describing: response), action_title: "OK")
                                    }
                                    else
                                    {
                                        do
                                        {
                                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                                            {
                                                DispatchQueue.main.async (execute: {
                                                    self.myActivityIndicator.stopAnimating()
                                                    let status = json["status"] as! Int
                                                    if(status == 1)
                                                    {
                                                        
                                                        let mydata = json["data"] as! NSDictionary
                                                        let mylink = mydata["link"] as! String
                                                        Mixpanel.mainInstance().track(event: "Share project")
                                                        let activityItem: [AnyObject] = [mylink as String as AnyObject]
                                                        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
                                                        
                                                        self.present(avc, animated: true, completion: nil)
                                                    }
                                                    else
                                                    {
                                                        let msg = json["msg"] as! String
                                                        self.display_alert(msg_title: "Error", msg_desc: msg, action_title: "Ok")
                                                    }
                                                })
                                            }
                                            
                                        } catch let error {
                                            
                                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                                        }
                                    }
                                }
                                task.resume()
                            }
                                
                                //}
                            else
                            {
                                self.display_alert(msg_title: "Uploading file", msg_desc: "File still uploading to cloud", action_title: "OK")
                                
                            }
                            
                            
                        }
                    }
                    //}
                })
            }
        }
        else
        {
            display_alert(msg_title: "Create project first !", msg_desc: "After creating project you can share", action_title: "OK")
        }
    }
    */
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
    
    func lyricsDone(newlyrics: String) {
        get_lyrics_text = newlyrics
        lyrics_txt_view_ref.text = newlyrics
        add_lyrics_view_ref.alpha = 0.0
    }
    /*
    func lyrics_data(lyrics_key : String, lyrics_txt : String, count_recording: Int, repeat_play_data: Bool)
    {
        
        get_lyrics_text = lyrics_txt
        repeat_play = repeat_play_data
        
        if(repeat_play)
        {
            repeat_img_ref.image = UIImage(named: "repeat")
        }
        else
        {
            repeat_img_ref.image = UIImage(named: "repeat-black")
        }
        
        if(get_lyrics_text != "")
        {
            lyrics_txt_view_ref.text = get_lyrics_text
            add_lyrics_view_ref.alpha = 0.0
        }
    }
 
    */
    @IBAction func lyrics_click(_ sender: UIButton) {
        self.lyrics_view_ref.alpha = 1.0
        self.bpm_view_ref.alpha = 0.0
        bpm_subscribe_img_ref.image = UIImage(named: "bpm_subscribe")
        displayBpmView = false
        
    }
 
    @IBAction func btn_detect_click(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            self.get_bpm_and_key()
        }
        
//        bpm_subscribe_img_ref.image = UIImage(named: "bpm_subscribe_selected")
//        print("detect click")
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
                                
                                self.selectedProjectKey = String(my_val[1])
                                self.selectedProjectBPM = Int(my_val[0])!
                                
                                self.audioArray[self.selected_index].bpm = Int(my_val[0])!
                                self.audioArray[self.selected_index].key = String(my_val[1])
                                self.set_master_bpm_to_firebase(bpm: Int(my_val[0])!, key: String(my_val[1]))
                                
                                //self.update_bpm_counter()
                            }
                        }
                        
                        self.bpmCompleteTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(SharedAudioVC.bpmCompleteDetect), userInfo: nil, repeats: false)
                        
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
    
    func set_master_bpm_to_firebase(bpm : Int, key : String){
        let bpm_data : [String : Any] = ["bpm" : bpm, "key" : key]
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid)
            let audioKey = audioArray[selected_index].id!
        userRef.child("masters").child(audioKey).updateChildValues(bpm_data, withCompletionBlock: { (error, database_ref) in
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
        
//        bpm_subscribe_img_ref.image = UIImage(named: "bpm_subscribe_selected")
//
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
}

