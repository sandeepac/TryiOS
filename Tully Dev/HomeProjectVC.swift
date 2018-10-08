//
//  HomeProjectVC.swift
//  Tully Dev
//
//  Created by macbook on 7/7/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import UICircularProgressRing
import Mixpanel

class HomeProjectVC: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, AVAudioPlayerDelegate, shareSecureResponseProtocol,get_coll_data_protocol
{
    
    //jakir
    var count_recordings = 0
    var get_lyrics_key = ""
    var repeat_play = false
    var saved_audio_file_name = ""
    var is_looping = false
    var looping_start_index = 0
    var looping_end_index = 0
    var selectedProjectBPM = 0
    var selectedProjectKey = ""
    var selected_recording_url : URL? = nil
    var get_lyrics_text = ""
    var audioArray = [playData]()
    //MARK: - Outlets
    
    @IBOutlet var project_name_lbl_ref: UILabel!
    @IBOutlet var lyrics_counter_label: UILabel!
    @IBOutlet var recording_cv_ref: UICollectionView!
    @IBOutlet var recording_counter_label: UILabel!
    @IBOutlet var recording_play_btn_ref: UIButton!
    
    @IBOutlet weak var collabration_btn: UIButton!
    
    @IBOutlet var lyrics_cv_ref: UICollectionView!
    @IBOutlet var top_view_constraint_ref: NSLayoutConstraint!
    @IBOutlet var share_delete_view_ref: UIView!
    @IBOutlet var main_rec_img_ref: UIImageView!
    @IBOutlet var download_process_view_ref: UIView!
    @IBOutlet var processRing: UICircularProgressRingView!
    
    //MARK: - Variables
    var OwnerLyricsData =  [String]()
    var OwnerLyricsProjectName = [String]()
    var lyrics_list = [lyricsListData]()
    var record_list = [recordingListData]()
    var audio_data  = [playData]()
    var player = AVAudioPlayer()
    var current_playing = false
    var audio_play = false
    var current_play_song_index = 0
    var initialization_flag = true
    var is_open_share_delet_view = false
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var current_project_id = ""
    var current_project_nm = ""
    var AudioName = String()
    var current_project_main_rec = ""
    var current_project_main_rec_bpm = 0
    var current_project_main_rec_bpm_key = ""
    var current_project_main_rec_key = ""
    var current_project_main_rec_nm = ""
    var current_project_download_url = ""
    var main_song_playing = false
    var come_from_push = false
    var collaborationId = String()
    override func viewDidLoad(){
        super.viewDidLoad()
        
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        self.navigationController?.isNavigationBarHidden = true
        project_name_lbl_ref.text = current_project_nm
        get_data()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.CheckcollabrationID()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
    }
    func lyrics_data(lyrics_key: String, lyrics_txt: String, count_recording: Int, repeat_play_data: Bool, is_looping: Bool, looping_start_index: Int, looping_end_index: Int) {
        get_lyrics_key = lyrics_key
        get_lyrics_text = lyrics_txt
        count_recordings = count_recording
        repeat_play = repeat_play_data
        self.is_looping = is_looping
        self.looping_start_index = looping_start_index
        self.looping_end_index = looping_end_index
        
        if(get_lyrics_text != "")
        {
            // lyrics_txt_view_ref.text = get_lyrics_text
            // add_lyrics_view_ref.alpha = 0.0
        }
        //project_name_lbl.text = currentProjectName
        get_num_of_audio_in_project()
    }
    func get_num_of_audio_in_project()
    {
        if(count_recordings > 0)
        {
            //recording_img_ref.image = UIImage(named: "Recording_Selected_tab")
            //recording_img_ref.image = UIImage(named: "multitrack_list")
            // no_of_recording_lbl_ref.text = String(count_recordings)
            // no_of_recording_view_ref.alpha = 1.0
        }
        else
        {
            // recording_img_ref.image = UIImage(named: "recording-blue")
            //recording_img_ref.image = UIImage(named: "multitrack_list")
            //no_of_recording_view_ref.alpha = 0.0
        }
    }
    func CheckcollabrationID(){
        OwnerLyricsProjectName.removeAll()
        OwnerLyricsProjectName.append(self.current_project_nm)
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()){
                if(snapshot.hasChild(self.current_project_id)){
                    if let data = snapshot.childSnapshot(forPath: self.current_project_id).value as? NSDictionary{
                        
                        if let check = data.value(forKey: "collaboration_id") as? String{
                            
                            self.collaborationId = check
                            print(self.collaborationId)
                           self.OwnerLyrics()
                        } else {
                            print("when collabrationID Not Get")
                        }
                    }
                }
            }
        })
    }
    //MARK: Owner Lyrics
    func OwnerLyrics(){
        let userID = Auth.auth().currentUser?.uid
        let userRef = FirebaseManager.getRefference().ref
        userRef.child("collaborations").child(self.current_project_id).child(self.collaborationId).observe(.value, with: { (snapshot) in
            
            self.OwnerLyricsData.removeAll()
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
                                self.OwnerLyricsData.append(desc)
                            }
                            if !self.OwnerLyricsData.isEmpty{
                                self.lyrics_cv_ref.reloadData()
                            }
                        }
                    }
                    
                }else{
                    print("wrongData")
                }
                
                
            }
            
        })
        

    }
    //MARK: - Play main recording
    
    @IBAction func play_project_main_recording(_ sender: Any){
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if (snapshot.exists()){
                if(snapshot.hasChild(self.current_project_id)){
                    if let data = snapshot.childSnapshot(forPath: self.current_project_id).value as? NSDictionary{
                        if let check = data.value(forKey: "collaboration_id") as? String{
                            
                            self.collaborationId = check
                            //Jakir
                            //self.getData()
                            let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let dir_Path = document_path.appendingPathComponent("recordings/projects")
                            print(self.current_project_main_rec)
                            let audio_name = self.current_project_main_rec
                            let name = self.saved_audio_file_name
                            let destinationUrl = dir_Path.appendingPathComponent(audio_name)
                            print(destinationUrl)
                    
                            if FileManager.default.fileExists(atPath: destinationUrl.path)
                            {
                                let vc : CollabrationViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CollabrationViewController") as! CollabrationViewController
                                
                                vc.currentProjectId = self.current_project_id
                                
                                vc.collabrationID = self.collaborationId
                                vc.collabration = "collabration"
                                vc.selected_audio_file_name = self.AudioName
                                //                         let vc : Play_LyricsRecordingVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayLyricsRecordingSid") as! Play_LyricsRecordingVC
                                vc.get_coll_data_protocolobj = self
                                vc.selected_project_key = self.current_project_id
                                vc.selected_project_name = self.current_project_nm
                                vc.count_recordings = self.count_recordings
                                vc.lyrics_key = self.get_lyrics_key
                                vc.lyrics_text = self.self.get_lyrics_key
                                vc.repeat_play = self.repeat_play
                                vc.selected_audio_file_name = self.AudioName
                                print(self.saved_audio_file_name)
                                vc.is_looping = self.is_looping
                                vc.looping_start_index = self.looping_start_index
                                vc.looping_end_index = self.looping_end_index
                                vc.selectedBPM = self.selectedProjectBPM
                                vc.selectedKey = self.selectedProjectKey
                                vc.recording_file_url = destinationUrl
                                
                                if(self.selected_recording_url != nil){
                                    vc.recording_file_url = self.selected_recording_url!
                                }
                                
                                self.navigationController?.pushViewController(vc, animated: true)
                                
                            } else {
                                //Jakir
                                
                                
                                print(self.current_project_download_url)
                                if (Reachability.isConnectedToNetwork()){
                                    DispatchQueue.main.async
                                        {
                                        
                                            if(self.current_project_download_url != ""){
                                                let httpsReference = Storage.storage().reference(forURL: self.current_project_download_url)
                                                self.download_process_view_ref.alpha = 1.0
                                                self.tabBarController?.tabBar.items?[0].isEnabled = false
                                                self.tabBarController?.tabBar.items?[1].isEnabled = false
                                                self.tabBarController?.tabBar.items?[2].isEnabled = false
                                                self.tabBarController?.tabBar.items?[3].isEnabled = false
                                                self.tabBarController?.tabBar.items?[4].isEnabled = false
                                                let downloadTask = httpsReference.write(toFile: destinationUrl)
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
                                                    //self.main_rec()
                                                    let vc : CollabrationViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CollabrationViewController") as! CollabrationViewController
                                                    vc.currentProjectId = self.current_project_id
                                                    vc.collabrationID = self.collaborationId
                                                    vc.selected_audio_file_name = self.AudioName
                                                    vc.get_coll_data_protocolobj = self
                                                    vc.selected_project_key = self.current_project_id
                                                    vc.selected_project_name = self.current_project_nm
                                                    vc.count_recordings = self.count_recordings
                                                    vc.lyrics_key = self.get_lyrics_key
                                                    vc.lyrics_text = self.self.get_lyrics_key
                                                    vc.repeat_play = self.repeat_play
                                                    vc.is_looping = self.is_looping
                                                    vc.looping_start_index = self.looping_start_index
                                                    vc.looping_end_index = self.looping_end_index
                                                    vc.selectedBPM = self.selectedProjectBPM
                                                    vc.selectedKey = self.selectedProjectKey
                                                    vc.selected_audio_file_name = self.AudioName
                                                    
                                                    vc.recording_file_url = destinationUrl
                                                    self.navigationController?.pushViewController(vc, animated: true)
                                                }
                                                downloadTask.observe(.failure, handler: { (snapshot) in
                                                    self.download_process_view_ref.alpha = 0.0
                                                    self.tabBarController?.tabBar.items?[0].isEnabled = true
                                                    self.tabBarController?.tabBar.items?[1].isEnabled = true
                                                    self.tabBarController?.tabBar.items?[2].isEnabled = true
                                                    self.tabBarController?.tabBar.items?[3].isEnabled = true
                                                    self.tabBarController?.tabBar.items?[4].isEnabled = true
                                                    MyConstants.normal_display_alert(msg_title: "Not Found", msg_desc: "File not found on the server.", action_title: "OK", myVC: self)
                                                    
                                                })
                                            } else {
                                                
                                                MyConstants.normal_display_alert(msg_title: "Not Found", msg_desc: "File not found on the server.", action_title: "OK", myVC: self)
                                            }
                                    }
                                } else {
                                    MyConstants.normal_display_alert(msg_title: "No Internet Connection", msg_desc: "For download - make sure your device is connected to the internet.", action_title: "OK", myVC: self)
                                }
                            }
                            
                        } else {
                            self.main_rec()
                        }
                    }
                }
            }
        })
        
    }
    func getData(){
        print("CurrentProjectID->",self.current_project_id)
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").queryOrderedByKey().observe(.value, with: { (snapshot) in
            print(snapshot)
            for snap in snapshot.children
            {
                let userSnap = snap as! DataSnapshot
                let project_key = userSnap.key
                let project_value = userSnap.value as! NSDictionary
                var project_name = ""
                var bpm = 0
                var key = ""
                
                if let pname = project_value.value(forKey: "project_name") as? String{
                    project_name = pname
                }
                
                if(project_key == self.current_project_id)
                {
                    if let main_rec = project_value.value(forKey: "project_main_recording") as? String
                    {
                        self.current_project_main_rec = main_rec
                        
                    }
                    if((project_value.value(forKey: "recordings") as? NSDictionary) != nil)
                    {
                        let record_data =  project_value.value(forKey: "recordings") as! NSDictionary
                        
                        let recording_key = record_data.allKeys as! [String]
                        for reckey in recording_key
                        {
                            let rec_dict = record_data.value(forKey: reckey) as? NSDictionary
                            print("Record Data->",rec_dict)
                            let name = rec_dict?.value(forKey: "name") as? String
                            let tid = rec_dict?.value(forKey: "tid") as? String
                            var download_url = rec_dict?["downloadURL"] as? String
                            // self.recording_file_url = download_url
                            print("downloadURL->",download_url)
                            self.saved_audio_file_name = name!
                            print("tid",tid)
                            print("download_url",download_url)
                            if let audioBpm = rec_dict?["bpm"] as? Int{
                                bpm = audioBpm
                            }
                            if let audioKey = rec_dict?["key"] as? String{
                                key = audioKey
                            }
                            
                            if(download_url == nil)
                            {
                                download_url = ""
                            }
                            
                            let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let dir_Path = document_path.appendingPathComponent("recordings/projects")
                            print(dir_Path)
                            if let mtTid = tid{
                                let destinationUrl = dir_Path.appendingPathComponent(mtTid)
                                print(destinationUrl)
                                var local_file = false
                                if FileManager.default.fileExists(atPath: (destinationUrl.path))
                                {
                                    local_file = true
                                }
                                
                                //self.recording_file_url = destinationUrl
                            }
                            
                        }
                        
                    }
                    if((project_value.value(forKey: "lyrics") as? NSDictionary) != nil)
                    {
                        let lyrics_data =  project_value.value(forKey: "lyrics") as! NSDictionary
                        let lyrics_key = lyrics_data.allKeys as! [String]
                        for key in lyrics_key
                        {
                            let lyrics_data = lyrics_data.value(forKey: key) as! NSDictionary
                            let desc = lyrics_data.value(forKey: "desc") as! String
                            let lyrics_data_insert = lyricsListData(project: project_name, desc: desc, lyrics_key:key, project_key:project_key, sort_key: "")
                            // self.lyrics_list.append(lyrics_data_insert)
                        }
                    }
                    
                }
            }
            
        })
    }
    func main_rec()
    {
        let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir_Path = document_path.appendingPathComponent("recordings/projects")
        
        let audio_name = self.current_project_main_rec
        let destinationUrl = dir_Path.appendingPathComponent(audio_name)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path)
        {
            
            let temp_audio_data = playData(audio_key: current_project_main_rec_key, audio_url: destinationUrl, audio_name: self.current_project_main_rec_nm, audio_size: "", downloadURL: "", local_file: false, tid: current_project_main_rec, bpm: current_project_main_rec_bpm, key: current_project_main_rec_bpm_key)
            audio_data.append(temp_audio_data)
            
            let vc : SharedAudioVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SharedAudioSid") as! SharedAudioVC
            print("Lyrics Data -> ",self.lyrics_list)
            if self.lyrics_list.isEmpty{
                vc.projectCurrentId = self.current_project_id
                vc.project_main_rec = self.audio_data
                vc.selected_index = 0
                vc.come_as_present = true
                vc.comeFromProject = true
                vc.currentProjectId = current_project_id
                vc.currentProjectName = current_project_nm
                vc.currentFileName = self.current_project_main_rec_nm
                vc.saved_audio_file_name = self.current_project_main_rec_nm
                vc.selected_recording_url = destinationUrl
                vc.count_recordings = self.record_list.count
                
                if(lyrics_list.count > 0)
                {
                    vc.get_lyrics_key = lyrics_list[0].lyrics_key!
                    vc.get_lyrics_text = lyrics_list[0].desc!
                }
                self.navigationController?.pushViewController(vc, animated: true)
            
                
                
                
                
            }else{
                let myData = self.lyrics_list[0]
                vc.projectCurrentId = myData.project_key!
                vc.project_main_rec = self.audio_data
                vc.selected_index = 0
                vc.come_as_present = true
                vc.comeFromProject = true
                vc.currentProjectId = current_project_id
                vc.currentProjectName = current_project_nm
                print(current_project_nm)
                vc.currentFileName = self.current_project_main_rec_nm
                vc.saved_audio_file_name = self.current_project_main_rec_nm
                print(destinationUrl)
                vc.selected_recording_url = destinationUrl
                vc.count_recordings = self.record_list.count
                
                if(lyrics_list.count > 0)
                {
                    vc.get_lyrics_key = lyrics_list[0].lyrics_key!
                    vc.get_lyrics_text = lyrics_list[0].desc!
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if (Reachability.isConnectedToNetwork()){
                DispatchQueue.main.async
                    {
                        if(self.current_project_download_url != ""){
                            let httpsReference = Storage.storage().reference(forURL: self.current_project_download_url)
                            self.download_process_view_ref.alpha = 1.0
                            self.tabBarController?.tabBar.items?[0].isEnabled = false
                            self.tabBarController?.tabBar.items?[1].isEnabled = false
                            self.tabBarController?.tabBar.items?[2].isEnabled = false
                            self.tabBarController?.tabBar.items?[3].isEnabled = false
                            self.tabBarController?.tabBar.items?[4].isEnabled = false
                            let downloadTask = httpsReference.write(toFile: destinationUrl)
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
                                self.main_rec()
                            }
                            downloadTask.observe(.failure, handler: { (snapshot) in
                                self.download_process_view_ref.alpha = 0.0
                                self.tabBarController?.tabBar.items?[0].isEnabled = true
                                self.tabBarController?.tabBar.items?[1].isEnabled = true
                                self.tabBarController?.tabBar.items?[2].isEnabled = true
                                self.tabBarController?.tabBar.items?[3].isEnabled = true
                                self.tabBarController?.tabBar.items?[4].isEnabled = true
                                MyConstants.normal_display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK", myVC: self)
                            })
                        } else {
                            MyConstants.normal_display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK", myVC: self)
                        }
                }
            } else {
                MyConstants.normal_display_alert(msg_title: "No Internet Connection", msg_desc: "For download - make sure your device is connected to the internet.", action_title: "OK", myVC: self)
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        current_playing = false
        recording_cv_ref.reloadData()
    }
    
    //MARK: - Get Data
    
    func get_data()
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").queryOrderedByKey().observe(.value, with: { (snapshot) in
            self.lyrics_list.removeAll()
            self.record_list.removeAll()
            for snap in snapshot.children
            {
                let userSnap = snap as! DataSnapshot
                let project_key = userSnap.key
                let project_value = userSnap.value as! NSDictionary
                var project_name = ""
                var bpm = 0
                var key = ""
                
                if let pname = project_value.value(forKey: "project_name") as? String{
                    project_name = pname
                }
                
                if(project_key == self.current_project_id)
                {
                    if let main_rec = project_value.value(forKey: "project_main_recording") as? String
                    {
                        self.current_project_main_rec = main_rec
                        
                    }
                    if((project_value.value(forKey: "recordings") as? NSDictionary) != nil)
                    {
                        let record_data =  project_value.value(forKey: "recordings") as! NSDictionary
                        let recording_key = record_data.allKeys as! [String]
                        for reckey in recording_key
                        {
                            let rec_dict = record_data.value(forKey: reckey) as? NSDictionary
                            let name = rec_dict?.value(forKey: "name") as? String
                            let tid = rec_dict?.value(forKey: "tid") as? String
                            var download_url = rec_dict?["downloadURL"] as? String
                            if let audioBpm = rec_dict?["bpm"] as? Int{
                                bpm = audioBpm
                            }
                            if let audioKey = rec_dict?["key"] as? String{
                                key = audioKey
                            }
                            
                            if(download_url == nil)
                            {
                                download_url = ""
                            }
                            
                            let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let dir_Path = document_path.appendingPathComponent("recordings/projects")
                            
                            if let mtTid = tid{
                                let destinationUrl = dir_Path.appendingPathComponent(mtTid)
                                
                                var local_file = false
                                if FileManager.default.fileExists(atPath: (destinationUrl.path))
                                {
                                    local_file = true
                                }
                                
                                if (tid != self.current_project_main_rec)
                                {
                                    let record_data = recordingListData(name: name!, project_name: project_name, project_key: project_key, tid: tid!, mykey: reckey, local_file: local_file, downloadURL: download_url!, volume: 1.0, bpm: bpm, key: key)
                                    self.record_list.append(record_data)
                                }
                                else
                                {
                                    self.current_project_main_rec_nm = name!
                                    self.current_project_main_rec_key = reckey
                                    self.current_project_main_rec_bpm_key = key
                                    self.current_project_main_rec_bpm = bpm
                                }
                            }
                            
                        }
                    }
                    if((project_value.value(forKey: "lyrics") as? NSDictionary) != nil)
                    {
                        let lyrics_data =  project_value.value(forKey: "lyrics") as! NSDictionary
                        let lyrics_key = lyrics_data.allKeys as! [String]
                        for key in lyrics_key
                        {
                            let lyrics_data = lyrics_data.value(forKey: key) as! NSDictionary
                            let desc = lyrics_data.value(forKey: "desc") as! String
                            let lyrics_data_insert = lyricsListData(project: project_name, desc: desc, lyrics_key:key, project_key:project_key, sort_key: "")
                            self.lyrics_list.append(lyrics_data_insert)
                        }
                    }
                    self.record_list = self.record_list.reversed()
                    self.lyrics_list = self.lyrics_list.reversed()
                    if self.lyrics_list.isEmpty{
                        self.collabration_btn.isHidden = true
                        
                    }else{
                        self.collabration_btn.isHidden = true
                    }
                    if self.record_list.isEmpty{
                        print("empty")
                    }else{
                        print("notEmpty")
                    }
                    self.lyrics_cv_ref.reloadData()
                    self.recording_cv_ref.reloadData()
                }
            }
        })
    }
    
    //MARK: - Collection view delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.lyrics_cv_ref){
            lyrics_counter_label.text = String(lyrics_list.count)
            //return lyrics_list.count
            return OwnerLyricsData.count
        }else{
            recording_counter_label.text = String(record_list.count)
            return record_list.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if(collectionView == self.lyrics_cv_ref)
        {
            print(lyrics_list)
          //  let selected_lyrics = self.lyrics_list[indexPath.row]
            let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_lyrics_CVCell", for: indexPath) as! home_lyrics_CVCell
            myCell.lyrics_view_ref.layer.cornerRadius = 5.0
            myCell.lyrics_view_ref.layer.borderWidth = 1
            myCell.lyrics_view_ref.layer.borderColor = UIColor.gray.cgColor
//            if(selected_lyrics.project == "no_project"){
//                myCell.lyrics_title_ref.text = "No Project Assigned"
//            }else{
//                myCell.lyrics_title_ref.text = selected_lyrics.project
//            }
            myCell.lyrics_title_ref.text = self.OwnerLyricsProjectName[indexPath.row]
            myCell.lyrics_desc_ref.text =  self.OwnerLyricsData[indexPath.row]//selected_lyrics.desc
            return myCell
        }
        else
        {
            let myData = record_list[indexPath.row]
            print(myData.downloadURL)
            if self.current_project_download_url == ""{
                self.current_project_download_url = myData.downloadURL!
            }
            let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_record_CVCell", for: indexPath) as!  home_recording_CVCell
            myCell.recording_view_ref.layer.cornerRadius = 5.0
            myCell.recording_view_ref.layer.borderWidth = 1
            myCell.recording_view_ref.layer.borderColor = UIColor.gray.cgColor
            myCell.recording_title_lbl_ref.text = myData.name
            myCell.recording_cate_lbl_ref.text = myData.project_name
            myCell.recording_play_btn_ref.tag = indexPath.row
            if (indexPath.row == current_play_song_index){
                if(self.current_playing){
                    myCell.change_imageToPause()
                    if(initialization_flag){
                        initialization_flag = false
                    }
                }else{
                    myCell.change_imageToPlay()
                    if(initialization_flag){
                        initialization_flag = false
                    }
                }
            }else{
                myCell.change_imageToPlay()
            }
            
            myCell.tapPlayPause = { (cell) in
                if(self.main_song_playing){
                    self.main_song_playing = false
                    self.player.stop()
                    self.audio_play = false
                    self.current_playing = false
                    self.main_rec_img_ref.image = UIImage(named: "recording-list-play")
                }
                var play_new_song = false
                if(self.audio_play)
                {
                    if(self.current_play_song_index == myCell.recording_play_btn_ref.tag)
                    {
                        if(self.current_playing){
                            self.player.pause()
                            self.current_playing=false
                            myCell.change_imageToPlay()
                        }else{
                            self.player.play()
                            self.current_playing=true
                            myCell.change_imageToPause()
                        }
                    }else{
                        play_new_song = true
                    }
                }else{
                    play_new_song = true
                }
                
                if(play_new_song)
                {
                    self.current_play_song_index = myCell.recording_play_btn_ref.tag
                    let visible = collectionView.indexPathsForVisibleItems
                    for vs in visible
                    {
                        let gen_index = NSIndexPath(row: vs.row, section: 0)
                        let myCell = collectionView.cellForItem(at: gen_index as IndexPath) as! home_recording_CVCell
                        if (vs.row == self.current_play_song_index){
                            myCell.change_imageToPlay()
                        }else{
                            myCell.change_imageToPlay()
                        }
                    }
                    self.myActivityIndicator.startAnimating()
                    DispatchQueue.main.async
                        {
                            if(self.audio_play){
                                self.player.stop()
                                self.audio_play = false
                            }
                            let selectedAudio = self.record_list[self.current_play_song_index]
                            if selectedAudio.tid != nil
                            {
                                let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let dir_Path = document_path.appendingPathComponent("recordings/projects")
                                let audio_name = selectedAudio.tid!
                                let destinationUrl = dir_Path.appendingPathComponent(audio_name)
                                
                                if FileManager.default.fileExists(atPath: destinationUrl.path){
                                    do{
                                        try self.player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: destinationUrl.path))
                                        self.player.prepareToPlay()
                                        self.player.delegate = self
                                        for vs in visible{
                                            let gen_index = NSIndexPath(row: vs.row, section: 0)
                                            let myCell = collectionView.cellForItem(at: gen_index as IndexPath) as! home_recording_CVCell
                                            if (vs.row == self.current_play_song_index){
                                                myCell.change_imageToPause()
                                            }else{
                                                myCell.change_imageToPlay()
                                            }
                                        }
                                        self.player.play()
                                        self.audio_play = true
                                        self.current_playing = true
                                        self.myActivityIndicator.stopAnimating()
                                    }catch{
                                        MyConstants.normal_display_alert(msg_title: "Error", msg_desc: "Not able to play audio.", action_title: "OK", myVC: self)
                                        self.myActivityIndicator.stopAnimating()
                                    }
                                }else{
                                    
                                    if (Reachability.isConnectedToNetwork()){
                                        let visible = collectionView.indexPathsForVisibleItems
                                        for vs in visible
                                        {
                                            let gen_index = NSIndexPath(row: vs.row, section: 0)
                                            let myCell = collectionView.cellForItem(at: gen_index as IndexPath) as! home_recording_CVCell
                                            myCell.change_imageToPlay()
                                        }
                                        print(selectedAudio.downloadURL)
                                        if(selectedAudio.downloadURL != ""){
                                            let httpsReference = Storage.storage().reference(forURL: selectedAudio.downloadURL!)
                                            self.download_process_view_ref.alpha = 1.0
                                            self.tabBarController?.tabBar.items?[0].isEnabled = false
                                            self.tabBarController?.tabBar.items?[1].isEnabled = false
                                            self.tabBarController?.tabBar.items?[2].isEnabled = false
                                            self.tabBarController?.tabBar.items?[3].isEnabled = false
                                            self.tabBarController?.tabBar.items?[4].isEnabled = false
                                            DispatchQueue.main.async
                                                {
                                                    let downloadTask = httpsReference.write(toFile: destinationUrl)
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
                                                        self.processRing.setProgress(value: 100, animationDuration: 0.1)
                                                        self.download_process_view_ref.alpha = 0.0
                                                        self.tabBarController?.tabBar.items?[0].isEnabled = true
                                                        self.tabBarController?.tabBar.items?[1].isEnabled = true
                                                        self.tabBarController?.tabBar.items?[2].isEnabled = true
                                                        self.tabBarController?.tabBar.items?[3].isEnabled = true
                                                        self.tabBarController?.tabBar.items?[4].isEnabled = true
                                                        self.processRing.setProgress(value: 0, animationDuration: 0.0)
                                                        
                                                        if FileManager.default.fileExists(atPath: destinationUrl.path)
                                                        {
                                                            do
                                                            {
                                                                try self.player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: destinationUrl.path))
                                                                self.player.prepareToPlay()
                                                                self.player.delegate = self
                                                                for vs in visible
                                                                {
                                                                    let gen_index = NSIndexPath(row: vs.row, section: 0)
                                                                    let myCell = collectionView.cellForItem(at: gen_index as IndexPath) as! home_recording_CVCell
                                                                    if (vs.row == self.current_play_song_index){
                                                                        myCell.change_imageToPause()
                                                                    }else{
                                                                        myCell.change_imageToPlay()
                                                                    }
                                                                }
                                                                self.player.play()
                                                                self.audio_play = true
                                                                self.current_playing = true
                                                                self.myActivityIndicator.stopAnimating()
                                                            }catch{
                                                                MyConstants.normal_display_alert(msg_title: "Error", msg_desc: "Not able to play audio.", action_title: "OK", myVC: self)
                                                                self.myActivityIndicator.stopAnimating()
                                                            }
                                                        }
                                                    }
                                                    downloadTask.observe(.failure, handler: { (snapshot) in
                                                        self.download_process_view_ref.alpha = 0.0
                                                        self.tabBarController?.tabBar.items?[0].isEnabled = true
                                                        self.tabBarController?.tabBar.items?[1].isEnabled = true
                                                        self.tabBarController?.tabBar.items?[2].isEnabled = true
                                                        self.tabBarController?.tabBar.items?[3].isEnabled = true
                                                        self.tabBarController?.tabBar.items?[4].isEnabled = true
                                                        MyConstants.normal_display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK", myVC: self)
                                                    })
                                            }
                                            self.myActivityIndicator.stopAnimating()
                                        }else{
                                            self.myActivityIndicator.stopAnimating()
                                            MyConstants.normal_display_alert(msg_title: "No Internet Connection", msg_desc: "For download - make sure your device is connected to the internet", action_title: "OK", myVC: self)
                                        }
                                    } else {
                                        self.myActivityIndicator.stopAnimating()
                                        MyConstants.normal_display_alert(msg_title: "No Internet Connection", msg_desc: "For download - make sure your device is connected to the internet", action_title: "OK", myVC: self)
                                    }
                                }
                            }
                    }
                }
            }
            return myCell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(collectionView == self.lyrics_cv_ref)
        {
            let vc : CollabrationLyricsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CollabrationLyricsVC") as! CollabrationLyricsVC
            vc.current_project_id = current_project_id
            vc.collaborationId = collaborationId
           self.navigationController?.pushViewController(vc, animated: true)
//            let myData = self.lyrics_list[indexPath.row]
//            print(indexPath.row)
//            print(myData.project_key)
//            let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "create_lyrics_sid") as! create_lyrics_VC
//            if let desc = myData.desc{
//                popvc.main_string = desc
//            }
//            if let project_name = myData.project{
//                popvc.current_project_name = project_name
//            }
//            if let project_key = myData.project_key{
//                popvc.current_project = project_key
//            }
//            if let mykey = myData.lyrics_key{
//                popvc.update_key = mykey
//            }
//            popvc.update_flag = true
//
//            self.present(popvc, animated: true, completion: nil)
        }
    }
    
    //MARK: - Share and delete
    
    @IBAction func open_hide_share_delete_view(_ sender: Any)
    {
        if(is_open_share_delet_view)
        {
            share_delete_view_ref.alpha = 0.0
            top_view_constraint_ref.constant = 0.0
            is_open_share_delet_view = false
        }else{
            share_delete_view_ref.alpha = 1.0
            top_view_constraint_ref.constant = 80.0
            is_open_share_delet_view = true
        }
    }
    
    @IBAction func share_project(_ sender: UIButton){
        share_project_btn_click()
    }
    
    func share_project_btn_click()
    {
        let myuserid = Auth.auth().currentUser?.uid
        if(myuserid != nil){
            Mixpanel.mainInstance().track(event: "Sharing for Projects")
            let postString = "userid="+myuserid!+"&projectid="+self.current_project_id
            let myurlString = MyConstants.share_project
            let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareSecureDownloadVC_sid") as! ShareSecureDownloadVC
            child_view.shareSecureResponseProtocol = self
            child_view.shareString = postString
            child_view.urlString = myurlString
            present(child_view, animated: true, completion: nil)
        }
    }
    
    //MARK: - Delete project
    
    @IBAction func delete_project(_ sender: UIButton) {
        delete_project_btn_click()
    }
    
    
    func delete_project_btn_click(){
        let myMsg = "Are you sure you want to delete this project ?"
        let ac = UIAlertController(title: "Delete", message: myMsg, preferredStyle: .alert)
        let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
        let titleAttrString = NSMutableAttributedString(string: "Delete Project?", attributes: attributes)
        ac.setValue(titleAttrString, forKey: "attributedTitle")
        ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
        ac.addAction(UIAlertAction(title: "Cancel", style: .default)
        {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
            self.myActivityIndicator.stopAnimating()
        })
        ac.addAction(UIAlertAction(title: "Delete", style: .default)
        {
            (result : UIAlertAction) -> Void in
            self.get_project_recording()
        })
        present(ac, animated: true)
    }
    
    //MARK : - Get Project Recording
    
    func get_project_recording()
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children
            {
                let userSnap = snap as! DataSnapshot
                let project_key = userSnap.key
                let project_value = userSnap.value as! NSDictionary
                if(project_key == self.current_project_id)
                {
                    if((project_value.value(forKey: "recordings") as? NSDictionary) != nil){
                        let record_data =  project_value.value(forKey: "recordings") as! NSDictionary
                        let recording_key = record_data.allKeys as! [String]
                        for key in recording_key{
                            let rec_dict = record_data.value(forKey: key) as? NSDictionary
                            let tid = rec_dict?.value(forKey: "tid") as! String
                            self.remove_recording(audio_nm: tid)
                        }
                        self.remove_project()
                    }else{
                        self.remove_project()
                    }
                }
            }
        })
    }
    
    //MARK: - Remove Recording
    
    func remove_recording(audio_nm : String)
    {
        let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir_Path = document_path.appendingPathComponent("recordings/projects")
        let audio_name = audio_nm
        let destinationUrl = dir_Path.appendingPathComponent(audio_name)
        if FileManager.default.fileExists(atPath: (destinationUrl.path))
        {
            do{
                try FileManager.default.removeItem(atPath: destinationUrl.path)
            }catch let error as NSError{
                MyConstants.normal_display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok", myVC: self)
            }
        }
    }
    
    //MARK: - Remove Project
    
    func remove_project()
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").child(self.current_project_id).removeValue(completionBlock: { (error, database_ref) in
            if let error = error{
                MyConstants.normal_display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok", myVC: self)
                self.myActivityIndicator.stopAnimating()
            }else{
                self.myActivityIndicator.stopAnimating()
                self.close_view()
            }
        })
    }
    
    //MARK: - Share Security
    
    func shareSecureResponse(allowDownload: Bool, postStringData: String, urlString: String, isCancel: Bool, token: String, type: String, expireTime: Int) {
        if(!isCancel){
            share_data(myString : postStringData, MyUrlString : urlString, allowDownload_shareSecurity : allowDownload, token: token, expireTime: expireTime)
        }
    }
    
    func share_data(myString : String, MyUrlString : String, allowDownload_shareSecurity : Bool, token : String, expireTime: Int){
        self.myActivityIndicator.startAnimating()
        var my_share_data : [NSMutableDictionary] = []
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(allowDownload_shareSecurity, forKey: "allow_download")
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
                            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "Ok", myVC: self)
                        }
                    }
                }
            };task.resume()
        }catch let error {
            DispatchQueue.main.async {
                self.myActivityIndicator.stopAnimating()
                MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "Ok", myVC: self)
            }
        }
        
    }
    //MARK: - Collabration Cliked
    @IBAction func colabrationBtnTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayLyricsRecordingSid") as! Play_LyricsRecordingVC
        
        vc.collabration = "collabration"
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: - Close View
    
    @IBAction func close_view(_ sender: Any){
        close_view()
    }
    
    func close_view()
    {
        
        if current_playing{
            self.player.stop()
            current_playing = false
        }
        if(come_from_push){
            self.navigationController?.popViewController(animated: true)
            come_from_push = false
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
