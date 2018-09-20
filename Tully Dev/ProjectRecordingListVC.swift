//
//  ProjectRecordingListVC.swift
//  Tully Dev
//
//  Created by macbook on 8/20/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import AVFoundation
import RangeSeekSlider
import UICircularProgressRing
import Alamofire
import Promise

class ProjectRecordingListVC: UIViewController , UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, UIDocumentInteractionControllerDelegate, RangeSeekSliderDelegate, renameCompleteProtocol, shareSecureResponseProtocol
{
    
    
    
    //________________________________ Outlets  ___________________________________
    
    @IBOutlet weak var top_contraint_tblview: NSLayoutConstraint!
    @IBOutlet var no_recording_view_ref: UIView!
    @IBOutlet var top_view: UIView!
    @IBOutlet var recording_tbl_ref: UITableView!
    @IBOutlet var select_all_img_ref: UIImageView!
    @IBOutlet var share_delete_view_ref: UIView!
    var controller1 = UIDocumentInteractionController()
    
    @IBOutlet weak var btn_multitrack_play_pause_ref: UIButton!
    var player = AVAudioPlayer()
    @IBOutlet var img_share_ref: UIImageView!
    @IBOutlet var btn_share_ref: UIButton!
    @IBOutlet var download_process_view_ref: UIView!
    @IBOutlet var processRing: UICircularProgressRingView!
    
    //________________________________ Variables  ___________________________________
    
    var current_playing = false
    var audio_play = false
    var current_play_song_index = 0
    var initialization_flag = true
    var current_project_name = ""
    var is_open_share_delet_view = false
    var is_selected_all_recordings = false
    var display_select_view = true
    var old_indexes = [Int]()
    var checked_indexes = [Int]()
    var come_from_project_data = false
    var multitrack_play = false
    var download_error_flag = false
    var record_list = [superpoweredRecordingListData]()
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var superPowerMixer = SuperpoweredRecorderWrapped()
    var initSuperPower = false
    var superPowerPlaying = false
    var timer = Timer()
    var forSuperPower = false
    var current_super_change_time = false
    var changeSelection = false
    var playerAMeta : [String]? = nil
    var playerBMeta : [String]? = nil
    var flagA = false
    var flagB = false
    var aIndex = 0
    var bIndex = 0
    var bothEOF = false
    var delta : Float = 0.0
    var currentProjectID = ""
    var rangeSelectorActive = false
    var timer1 = Timer()
    var timer2 = Timer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName:NSNotification.Name(rawValue: "audioSuperPowerError"), object:nil, queue:nil, using:audioSuperPowerErrorFunction)
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        recording_tbl_ref.tableFooterView = UIView()
        create_design()
        is_open_share_delet_view = true
        display_select_view = false
    }
    
    func audioSuperPowerErrorFunction(notification:Notification) -> Void {
        mark_all_clear()
        stop_super_power()
        if let extractInfo = notification.userInfo {
            
            let index = Int(extractInfo["index"] as! String)
            let selectedData = record_list[checked_indexes[index!]]
            
            if let audioUrl = selectedData.downloadURL{
                
                let fileName = selectedData.tid
                
                let parameters: [String: String] = [
                    "audioUrl":audioUrl,
                    "storagePath":"projects/" + currentProjectID + "/recording/" + fileName!,
                    "fileName":fileName!,
                    "dbPath": "projects/" + currentProjectID + "/recordings/" + selectedData.mykey!
                ]
                
                ApiAuthentication.get_authentication_token().then({ (token) in
                    
                    let headers: HTTPHeaders = [
                        "token": token,
                        //"Accept": "application/json"
                    ]
                    
                    Alamofire.request(MyConstants.audioProcess, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                        .responseJSON { response in
                            
                            switch response.result {
                            case .success:
                                if let result = response.result.value as? NSDictionary{
                                    let downloadURL = result.value(forKey: "downloadURL") as? String
                                    self.record_list[self.checked_indexes[index!]].downloadURL = downloadURL
                                    self.downloadNewFile(downloadUrl : downloadURL!, audio_name : fileName!)
                                    
                                }
                            case .failure(let error):
                                print(error)
                                MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "ok", myVC: self)
                            }
                    }
                    
                }).catch({ (err) in
                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: err.localizedDescription, action_title: "Ok", myVC: self)
                })
                
            }
            
            //sendAudioForConvert()
           
            // HTTP body: {"foo": [1, 2, 3], "bar": {"baz": "qux"}}
            
        }
    }
    
    func downloadNewFile(downloadUrl : String, audio_name : String) {
        do{
            let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let audio_name = audio_name
            let dir_Path = document_path.appendingPathComponent("recordings/projects")
            
            let destinationUrl = dir_Path.appendingPathComponent(audio_name)
            
            try FileManager.default.createDirectory(atPath: dir_Path.path, withIntermediateDirectories: true, attributes: nil)
            if FileManager.default.fileExists(atPath: destinationUrl.path){
                try FileManager.default.removeItem(atPath: destinationUrl.path)
            }
            
            let httpsReference = Storage.storage().reference(forURL: downloadUrl)
            let connectedRef = FirebaseManager.getDatabase().reference(withPath: ".info/connected")
            connectedRef.observe(.value, with: { snapshot in
                if snapshot.value as? Bool ?? false {
                    self.download_process_view_ref.alpha = 1.0
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
                                // Download completed successfully
                                self.processRing.setProgress(value: 100, animationDuration: 0.1)
                                self.download_process_view_ref.alpha = 0.0
                                self.processRing.setProgress(value: 0, animationDuration: 0.0)
                                
                                if FileManager.default.fileExists(atPath: destinationUrl.path)
                                {
                                    print("convert & save successfully")
                                }
                            }
                            
                            downloadTask.observe(.failure, handler: { (snapshot) in
                                self.download_process_view_ref.alpha = 0.0
                                self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                            })
                            self.myActivityIndicator.stopAnimating()
                    }
                } else {
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "No Internet Connection", msg_desc: "For download - make sure your device is connected to the internet", action_title: "OK")
                }
                
            })
        }catch{
            print("got some error")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.search_data()
    }
    
    //________________________________ Create Design  ___________________________________
    
    func create_design()
    {
        processRing.ringStyle = UICircularProgressRingStyle.inside
        select_all_img_ref.layer.borderColor = UIColor.gray.cgColor
        select_all_img_ref.layer.borderWidth = 1.0
        select_all_img_ref.layer.cornerRadius = 5.0
        select_all_img_ref.layer.masksToBounds = true
    }
    
    //________________________________ Table View Delegate  ___________________________________
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let len = record_list.count
        if(len == 0){
            recording_tbl_ref.isHidden = true
        }else{
            recording_tbl_ref.isHidden = false
        }
        return len
    }

    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myData = record_list[indexPath.row]
        let myCell = tableView.dequeueReusableCell(withIdentifier: "project_reccording_tbl_cell", for: indexPath) as! project_reccording_tbl_cell
        
            myCell.recording_name.text = myData.name
            myCell.volume_slider_ref.tag = indexPath.row
            myCell.volume_slider_ref.addTarget(self, action: #selector(sliderValueChange(sender:)), for: .valueChanged)
            
            if(myData.project_name == "no_project"){
                myCell.recording_project.text = "No Project Assigned"
            }else{
                myCell.recording_project.text = myData.project_name
            }
            
            myCell.btn_ref_play_record.tag = indexPath.row
            myCell.selectionStyle = UITableViewCellSelectionStyle.none
        myCell.display_select_view()
            //myCell.play_starting_time.text = ""
            //myCell.play_ending_time.text = ""
            myCell.change_imageToPlay()
            myCell.btn_checkbox_ref.isEnabled = true
            myCell.checkbox_unchecked()
            
            let recordObject = self.record_list[indexPath.row]
            
            if (recordObject.isPlaying){
                if(initSuperPower){
                    myCell.volume_slider_ref.alpha = 1.0
                }else{
                    myCell.volume_slider_ref.alpha = 0.0
                }
                myCell.change_imageToPause()
                
               // myCell.audio_bg_img_ref.loadGif(name: "wave")
                
            }
            else{
                myCell.change_imageToPlay()
                myCell.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                myCell.volume_slider_ref.alpha = 0.0
            }
            
            if(recordObject.isCheck){
                myCell.checkbox_checked()
            }else{
                myCell.checkbox_unchecked()
            }
//        }
        
        myCell.tapPlayPause = { (cell) in
            var play_new_song = false
            if(self.initSuperPower){
                let tag = myCell.btn_ref_play_record.tag
                if(self.old_indexes.contains(tag)){
                    let sIndex:Int32 = (self.old_indexes[0] == tag ? 0 : 1)
                    if(self.record_list[tag].isPlaying){
                        self.record_list[myCell.btn_ref_play_record.tag].isPlaying = false
                        self.superPowerMixer.pauseAudio(sIndex)
                        myCell.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                        myCell.change_imageToPlay()
                        myCell.volume_slider_ref.alpha = 0.0
                    }else{
                        self.record_list[myCell.btn_ref_play_record.tag].isPlaying = true
                        self.superPowerMixer.playAudio(sIndex)
                        myCell.audio_bg_img_ref.loadGif(name: "wave")
                        myCell.change_imageToPause()
                        myCell.volume_slider_ref.alpha = 1.0
                    }
                }else{
                    self.stop_super_power()
                    self.checked_indexes.removeAll()
                    self.old_indexes.removeAll()
                    play_new_song = true
                }
            }
            else{
                if(self.audio_play){
                    if(self.current_play_song_index == myCell.btn_ref_play_record.tag)
                    {
                        if(self.current_playing)
                        {
                            self.player.pause()
                            self.record_list[myCell.btn_ref_play_record.tag].isPlaying = false
                            myCell.pause_audio()
                            self.current_playing=false
                            myCell.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                            myCell.change_imageToPlay()
                        }else{
                            self.record_list[myCell.btn_ref_play_record.tag].isPlaying = true
                            self.player.play()
                            myCell.play_audio()
                            myCell.audio_bg_img_ref.loadGif(name: "wave")
                            self.current_playing=true
                            myCell.change_imageToPause()
                        }
                    }else{
                        play_new_song = true
                       
                        myCell.play_starting_time.text = ""
                        myCell.play_ending_time.text = ""
                    }
                }
                else{
                    play_new_song = true
                    
                    myCell.play_starting_time.text = ""
                    myCell.play_ending_time.text = ""
                }
            }
            
            if(play_new_song){
                self.current_play_song_index = myCell.btn_ref_play_record.tag
                
                let visible = tableView.indexPathsForVisibleRows
                
                for vs in visible!{
                    let gen_index = NSIndexPath(row: vs.row, section: 0)
                    let myCell = tableView.cellForRow(at: gen_index as IndexPath) as? project_reccording_tbl_cell
                    if (vs.row == self.current_play_song_index)
                    {
                        myCell?.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                        myCell?.change_imageToPlay()
                    }
                    else
                    {
                        myCell?.change_imageToPlay()
                        myCell?.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                        myCell?.play_starting_time.text = ""
                        myCell?.play_ending_time.text = ""
                        myCell?.invalid_timer()
                    }
                }
                
                self.myActivityIndicator.startAnimating()
               // DispatchQueue.main.async
                //    {
                        if(self.audio_play)
                        {
                            self.player.stop()
                            myCell.invalid_timer()
                            self.audio_play = false
                        }
                        
                        self.mark_all_clear()
                        
                        let selectedAudio = self.record_list[self.current_play_song_index]
                        if selectedAudio.tid != nil
                        {
                            let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let audio_name = selectedAudio.tid!
                            let dir_Path = document_path.appendingPathComponent("recordings/projects")
                            
                            let destinationUrl = dir_Path.appendingPathComponent(audio_name)
                            if FileManager.default.fileExists(atPath: destinationUrl.path)
                            {
                                do
                                {
                                    
                                    try self.player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: destinationUrl.path))
                                    self.player.prepareToPlay()
                                    self.player.delegate = self
                                    
                                    for vs in visible!{
                                        let gen_index = NSIndexPath(row: vs.row, section: 0)
                                        let myCell = tableView.cellForRow(at: gen_index as IndexPath) as? project_reccording_tbl_cell
                                        if (vs.row == self.current_play_song_index)
                                        {
                                            myCell?.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                                            myCell?.change_imageToPlay()
                                        }
                                        else
                                        {
                                            myCell?.change_imageToPlay()
                                            myCell?.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                                            myCell?.invalid_timer()
                                        }
                                    }
                                    myCell.play_starting_time.text = "0:00"
                                    myCell.play_ending_time.text = "-" + self.give_time(seconds: Int(self.player.duration))
                                    
                                    
                                    myCell.initialize_time(seconds: Int(self.player.duration))
                                    self.player.play()
                                    selectedAudio.isPlaying = true
                                    //myCell.audio_bg_img_ref.loadGif(name: "wave")
                                    myCell.change_imageToPause()
                                    self.audio_play = true
                                    self.current_playing = true
                                    
                                    self.myActivityIndicator.stopAnimating()
                                    self.record_list[self.current_play_song_index].isPlaying = true
                                   // self.refreshAll()
                                }
                                catch
                                {
                                    selectedAudio.isPlaying = false
                                    self.display_alert(msg_title: "Error", msg_desc: "Not able to play audio.", action_title: "OK")
                                    self.myActivityIndicator.stopAnimating()
                                }
                            }
                            else
                            {
                                if(selectedAudio.downloadURL != ""){
                                    let httpsReference = Storage.storage().reference(forURL: selectedAudio.downloadURL!)
                                    let connectedRef = FirebaseManager.getDatabase().reference(withPath: ".info/connected")
                                    connectedRef.observe(.value, with: { snapshot in
                                        if snapshot.value as? Bool ?? false {
                                            self.download_process_view_ref.alpha = 1.0
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
                                                        // Download completed successfully
                                                        self.processRing.setProgress(value: 100, animationDuration: 0.1)
                                                        self.download_process_view_ref.alpha = 0.0
                                                        self.processRing.setProgress(value: 0, animationDuration: 0.0)
                                                        
                                                        if FileManager.default.fileExists(atPath: destinationUrl.path)
                                                        {
                                                            do
                                                            {
                                                                try self.player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: destinationUrl.path))
                                                                self.player.prepareToPlay()
                                                                self.player.delegate = self
                                                                
                                                                for vs in visible!{
                                                                    let gen_index = NSIndexPath(row: vs.row, section: 0)
                                                                    let myCell = tableView.cellForRow(at: gen_index as IndexPath) as? project_reccording_tbl_cell
                                                                    if (vs.row == self.current_play_song_index)
                                                                    {
                                                                        myCell?.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                                                                        myCell?.change_imageToPlay()
                                                                    }
                                                                    else
                                                                    {
                                                                        myCell?.change_imageToPlay()
                                                                        myCell?.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                                                                        myCell?.invalid_timer()
                                                                    }
                                                                }
                                                                myCell.play_starting_time.text = "0:00"
                                                                myCell.play_ending_time.text = "-" + self.give_time(seconds: Int(self.player.duration))
                                                                
                                                                
                                                                
                                                                myCell.initialize_time(seconds: Int(self.player.duration))
                                                                self.player.play()
                                                                //myCell.audio_bg_img_ref.loadGif(name: "wave")
                                                                myCell.change_imageToPause()
                                                                self.audio_play = true
                                                                self.current_playing = true
                                                                
                                                                self.myActivityIndicator.stopAnimating()
                                                                selectedAudio.isPlaying = true
                                                                self.record_list[self.current_play_song_index].isPlaying = true
                                                                //self.refreshAll()
                                                            }
                                                            catch
                                                            {
                                                                selectedAudio.isPlaying = false
                                                                self.display_alert(msg_title: "Error", msg_desc: "Not able to play audio.", action_title: "OK")
                                                                self.myActivityIndicator.stopAnimating()
                                                            }
                                                        }
                                                    }
                                                    
                                                    downloadTask.observe(.failure, handler: { (snapshot) in
                                                        self.download_process_view_ref.alpha = 0.0
                                                        self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                                                    })
                                                    self.myActivityIndicator.stopAnimating()
                                            }
                                        } else {
                                            self.myActivityIndicator.stopAnimating()
                                            self.display_alert(msg_title: "No Internet Connection", msg_desc: "For download - make sure your device is connected to the internet", action_title: "OK")
                                        }
                                    })
                                }
                                else{
                                    self.myActivityIndicator.stopAnimating()
                                    self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                                }
                                
                            }
                        }
                    }
                //}
        }
        
        myCell.tapCheckboxClick = { (cell) in
            if(self.checked_indexes.contains(myCell.btn_ref_play_record.tag)){
                let remove_index = self.checked_indexes.index(of: myCell.btn_ref_play_record.tag)
                self.checked_indexes.remove(at: remove_index!)
                self.record_list[myCell.btn_ref_play_record.tag].isCheck = false
                myCell.checkbox_unchecked()
            }
            else{
                self.checked_indexes.append(myCell.btn_ref_play_record.tag)
                self.record_list[myCell.btn_ref_play_record.tag].isCheck = true
                myCell.checkbox_checked()
            }
        }
        
//        myCell.loop_inner_slider_ref.addTarget(self, action: #selector(LoopInnerSliderValueChange(sender:)), for: .valueChanged)
        
        
//        myCell.RangeSeekSliderRef.delegate = self
//        myCell.RangeSeekSliderRef.tag = indexPath.row
//        myCell.RangeSeekSliderRef.minDistance = 1.0
//        myCell.RangeSeekSliderRef.minValue = 0
//        myCell.RangeSeekSliderRef.maxValue = 100
        
//        myCell.loop_inner_slider_ref.tag = indexPath.row
//        myCell.loop_inner_slider_ref.setThumbImage(UIImage(named: "loop_line"), for: .normal)
//        myCell.loop_inner_slider_ref.minimumValue = 0.0
//        myCell.loop_inner_slider_ref.maximumValue = 100
     
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotiationRecording))
        longPressGestureRecognizer.minimumPressDuration = 1
        myCell.addGestureRecognizer(longPressGestureRecognizer)
        return myCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        print("in edit")
        if(rangeSelectorActive){
            return []
        }else{
            let rename = UITableViewRowAction(style: .normal, title: "") { action, index in
                
                let myData = self.record_list[editActionsForRowAt.row]
                let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rename_project_sid") as! RenameProjectFileVC
                child_view.renameCompleteProtocol = self
                child_view.selected_id = myData.mykey!
                child_view.selected_nm = myData.name!
                child_view.rename_file = true
                child_view.project_id = myData.project_key!
                child_view.is_project = true
                self.addChildViewController(child_view)
                child_view.view.frame = self.view.frame
                self.view.addSubview(child_view.view)
                child_view.didMove(toParentViewController: self)
            }
            rename.setIcon(iconImage: UIImage(named: "rename")!, backColor: UIColor.white, cellHeight: 200.0, action_title: "rename", ylblpos: 1)
            
            let share = UITableViewRowAction(style: .normal, title: "") { action, index in
                let myData = self.record_list[editActionsForRowAt.row]
                var recording_ids : [NSMutableDictionary] = []
                let jsonObject: NSMutableDictionary = NSMutableDictionary()
                jsonObject.setValue(myData.mykey!, forKey: myData.project_key!)
                recording_ids.append(jsonObject)
                self.share_recording(recording_ids: recording_ids)
                
            }
            share.setIcon(iconImage: UIImage(named: "upload")!, backColor: UIColor.white, cellHeight: 200.0, action_title: "share", ylblpos: 1)
            
            let delete = UITableViewRowAction(style: .normal, title: "") { action, index in
                
                let myMsg = "Are you sure you want to delete Selected Recording ?"
                let ac = UIAlertController(title: "Delete", message: myMsg, preferredStyle: .alert)
                let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
                let titleAttrString = NSMutableAttributedString(string: "Delete Selected Recording?", attributes: attributes)
                ac.setValue(titleAttrString, forKey: "attributedTitle")
                ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
                ac.addAction(UIAlertAction(title: "Cancel", style: .default)
                {
                    (result : UIAlertAction) -> Void in
                    _ = self.navigationController?.popViewController(animated: true)
                })
                ac.addAction(UIAlertAction(title: "Delete", style: .default)
                {
                    (result : UIAlertAction) -> Void in
                    self.remove_recording(selected_index : editActionsForRowAt.row)
                    self.search_data()
                })
                self.present(ac, animated: true)
            }
            delete.setIcon(iconImage: UIImage(named: "garbage")!, backColor: UIColor.white, cellHeight: 200.0, action_title: "garbage", ylblpos: 1)
            //delete.backgroundColor = UIColor(patternImage: UIImage(named: "garbage")!)
            
            return [delete, share, rename]
            //return []

        }
        
        
    }
    
    func addAnnotiationRecording(_ gestureRecognizer: UILongPressGestureRecognizer)
    {
        
        let touchPoint = gestureRecognizer.location(in: self.recording_tbl_ref)
        if let indexPath = recording_tbl_ref.indexPathForRow(at: touchPoint)
        {
            let myData = record_list[indexPath.row]
            
            let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in}
            alertController.addAction(cancelAction)
            
            let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
                let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rename_project_sid") as! RenameProjectFileVC
                child_view.renameCompleteProtocol = self
                child_view.selected_id = myData.mykey!
                child_view.selected_nm = myData.name!
                child_view.rename_file = true
                child_view.project_id = myData.project_key!
                child_view.is_project = true
                self.addChildViewController(child_view)
                child_view.view.frame = self.view.frame
                self.view.addSubview(child_view.view)
                child_view.didMove(toParentViewController: self)
            }
            alertController.addAction(renameAction)
            
            let shareAction = UIAlertAction(title: "Share", style: .default) { action in
                
                var recording_ids : [NSMutableDictionary] = []
                let jsonObject: NSMutableDictionary = NSMutableDictionary()
                jsonObject.setValue(myData.mykey!, forKey: myData.project_key!)
                recording_ids.append(jsonObject)
                self.share_recording(recording_ids: recording_ids)
            }
            alertController.addAction(shareAction)
            
            
            let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                let myMsg = "Are you sure you want to delete Selected Recording ?"
                let ac = UIAlertController(title: "Delete", message: myMsg, preferredStyle: .alert)
                let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
                let titleAttrString = NSMutableAttributedString(string: "Delete Selected Recording?", attributes: attributes)
                ac.setValue(titleAttrString, forKey: "attributedTitle")
                ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
                ac.addAction(UIAlertAction(title: "Cancel", style: .default)
                {
                    (result : UIAlertAction) -> Void in
                    _ = self.navigationController?.popViewController(animated: true)
                })
                ac.addAction(UIAlertAction(title: "Delete", style: .default)
                {
                    (result : UIAlertAction) -> Void in
                    self.remove_recording(selected_index : indexPath.row)
                    self.search_data()
                })
                self.present(ac, animated: true)
                
            }
            alertController.addAction(destroyAction)
            self.present(alertController, animated: true) {}
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        audio_play = false
        current_playing = false
        mark_all_clear()
        refreshAll()
        //recording_tbl_ref.reloadData()
    }
    
    //________________________________ Get Data  ___________________________________
    
    
    func display_project_data(project_name : String , project_value : NSDictionary, project_key : String)
    {
        let recording_key = project_value.allKeys as! [String]
        //recording_key.reversed()
        for key in recording_key
        {
            let rec_dict = project_value.value(forKey: key) as? NSDictionary
            
            var name = ""
            if let nm = rec_dict?.value(forKey: "name") as? String{
                name = nm
            }
            var tid = ""
            if let tid1 = rec_dict?.value(forKey: "tid") as? String{
                tid = tid1
            }
            var download_url = ""
            if let durl = rec_dict?["downloadURL"] as? String{
                download_url = durl
            }
            
            let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dir_Path = document_path.appendingPathComponent("recordings/projects")
            let destinationUrl = dir_Path.appendingPathComponent(tid)
            
            var local_file = false
            if FileManager.default.fileExists(atPath: (destinationUrl.path))
            {
                local_file = true
            }
            
            let record_data = superpoweredRecordingListData(name: name, project_name: project_name, project_key: project_key, tid: tid, mykey: key, local_file: local_file, downloadURL: download_url, volume: 1.0)
            self.record_list.append(record_data)
        }
        
        let myArrayOfTuples = self.record_list.sorted{
            guard let d1 = $0.mykey, let d2 = $1.mykey else { return false }
            return d1 > d2
        }
        self.record_list = myArrayOfTuples
        self.myActivityIndicator.startAnimating()
        //self.recording_tbl_ref.reloadData()
    }
    
    //________________________________ Search Data  ___________________________________
    
    
    func search_data()
    {
        self.myActivityIndicator.startAnimating()
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        if(currentProjectID != "")
        {
         userRef.child("projects").child(currentProjectID).child("recordings").observeSingleEvent(of: .value, with: { (snapshot) in
                self.record_list.removeAll()
            
                if(snapshot.exists()){
                    if let record_data = snapshot.value as? NSDictionary{
                            self.display_project_data(project_name: self.current_project_name, project_value: record_data,project_key: self.currentProjectID)
                    }
                }
            
                self.recording_tbl_ref.reloadData()
                self.myActivityIndicator.stopAnimating()
            })
        }
        
    }
    
    // MARK: - Share Delete Recording
    
    @IBAction func open_share_delete_view(_ sender: Any)
    {
        if(self.current_playing)
        {
            player.stop()
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func manage_delete_share_view()
    {
        //        if(is_open_share_delet_view)
        //        {
        //            share_delete_view_ref.alpha = 0.0
        //            //top_contraint_tblview.constant = 0.0
        //            is_open_share_delet_view = false
        //            display_select_view = true
        //            recording_tbl_ref.reloadData()
        //        }
        //        else
        //        {
        //            share_delete_view_ref.alpha = 1.0
        //            //top_contraint_tblview.constant = 80.0
        //            is_open_share_delet_view = true
        //            display_select_view = false
        //            recording_tbl_ref.reloadData()
        //        }
    }
    
    @IBAction func open_search_view(_ sender: Any)
    {
        manage_delete_share_view()
    }
    
    @IBAction func btn_share_selected(_ sender: Any)
    {
        if(checked_indexes.count < 1)
        {
            display_alert(msg_title: "Required", msg_desc: "You must have to select Recording.", action_title: "OK")
        }
        else
        {
            var recording_ids : [NSMutableDictionary] = []
            for i in 0..<record_list.count
            {
                if(checked_indexes.contains(i))
                {
                    let jsonObject: NSMutableDictionary = NSMutableDictionary()
                    jsonObject.setValue(record_list[i].mykey!, forKey: record_list[i].project_key!)
                    recording_ids.append(jsonObject)
                }
            }
            share_recording(recording_ids: recording_ids)
            
            self.deselect_all_recordings()
            self.manage_delete_share_view()
        }
    }
    
    func share_recording(recording_ids : [NSMutableDictionary])
    {
        let myuserid = Auth.auth().currentUser?.uid
        if(myuserid != nil)
        {
            do{
                let data =  try JSONSerialization.data(withJSONObject: recording_ids, options:[])
                let mystring = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                let no_project_string = "&no_project_rec_ids="+""
                let project_string = "&project_recs="+mystring!
                let postString = "userid="+myuserid!+no_project_string+project_string
                let myurlString = MyConstants.share_recordings
                let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareSecureDownloadVC_sid") as! ShareSecureDownloadVC
                child_view.shareSecureResponseProtocol = self
                child_view.shareString = postString
                child_view.urlString = myurlString
                present(child_view, animated: true, completion: nil)
            }catch let err{
                self.display_alert(msg_title: "Server error", msg_desc: err.localizedDescription, action_title: "OK")
            }
        }
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
                    self.display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: String(describing: response), action_title: "OK")
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
                                    self.display_alert(msg_title: "Error", msg_desc: msg, action_title: "Ok")
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
    
    
    @IBAction func btn_delete_selected(_ sender: Any)
    {
        if(checked_indexes.count < 1)
        {
            display_alert(msg_title: "Required", msg_desc: "You must have to select Recording.", action_title: "OK")
        }
        else
        {
            let myMsg = "Are you sure you want to delete Selected Recording ?"
            let ac = UIAlertController(title: "Delete", message: myMsg, preferredStyle: .alert)
            let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
            let titleAttrString = NSMutableAttributedString(string: "Delete Selected Recording?", attributes: attributes)
            ac.setValue(titleAttrString, forKey: "attributedTitle")
            ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
            ac.addAction(UIAlertAction(title: "Cancel", style: .default)
            {
                (result : UIAlertAction) -> Void in
            })
            ac.addAction(UIAlertAction(title: "Delete", style: .default)
            {
                (result : UIAlertAction) -> Void in
                
                for i in 0..<self.record_list.count
                {
                    if(self.checked_indexes.contains(i))
                    {
                        self.remove_recording(selected_index : i)
                    }
                }
                self.deselect_all_recordings()
                self.manage_delete_share_view()
                self.search_data()
            })
            present(ac, animated: true)
        }
    }
    
    func remove_recording(selected_index : Int)
    {
        let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir_Path = document_path.appendingPathComponent("recordings/projects")
        let audio_name = self.record_list[selected_index].tid!
        let destinationUrl = dir_Path.appendingPathComponent(audio_name)
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
    userRef.child("projects").child(self.record_list[selected_index].project_key!).child("recordings").child(self.record_list[selected_index].mykey!).removeValue(completionBlock: { (error, database_ref) in
            
            if let error = error
            {
                self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        })
        
        if FileManager.default.fileExists(atPath: (destinationUrl.path)){
            do{
                try FileManager.default.removeItem(atPath: destinationUrl.path)
                FirebaseManager.delete_project_recording_file(myfilename_tid: audio_name, projectId: self.record_list[selected_index].project_key!)
            }catch let error as NSError{
                self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
            }
        }
    }
    
    @IBAction func btn_select_all(_ sender: Any)
    {
        if(is_selected_all_recordings)
        {
            deselect_all_recordings()
        }else{
            select_all_recordings()
        }
    }
    
    func select_all_recordings()
    {
        select_all_img_ref.layer.borderWidth = 0.0
        checked_indexes.removeAll()
        for i in 0..<record_list.count
        {
            checked_indexes.append(i)
        }
        select_all_img_ref.image = UIImage(named: "gray_checkbox")!
        select_all_img_ref.layer.cornerRadius = 5.0
        select_all_img_ref.clipsToBounds = true
        is_selected_all_recordings = true
        recording_tbl_ref.reloadData()
    }
    
    func deselect_all_recordings(){
        select_all_img_ref.image = nil
        select_all_img_ref.layer.borderColor = UIColor.gray.cgColor
        select_all_img_ref.layer.borderWidth = 1.0
        select_all_img_ref.layer.cornerRadius = 5.0
        select_all_img_ref.layer.masksToBounds = true
        is_selected_all_recordings = false
        checked_indexes.removeAll()
        recording_tbl_ref.reloadData()
    }
    
    func renameDone(isSuccessful : Bool,newName : String){
        search_data()
    }
    
    //MARK: Volume Change
    
    func sliderValueChange(sender: UISlider) {
        let currentValue = sender.value    // get slider's value
        let row = sender.tag               // get slider's row in table
        if(old_indexes.count == 2){
            self.record_list[row].volume = currentValue
            delta = abs(record_list[old_indexes[0]].volume! - record_list[old_indexes[1]].volume!)
            superPowerMixer.onVolumeChange(record_list[old_indexes[0]].volume!, record_list[old_indexes[1]].volume!,delta)
        }
    }
    
    //MARK: Multitrack
    @IBAction func multitrack_previous_btn_click(_ sender: UIButton) {
        print("prevois click")
    }
    
    @IBAction func multitrack_play_pause_click(_ sender: UIButton) {
        if(self.audio_play){
            mark_single_clear(index: self.current_play_song_index)
            initSuperPower = false
        }
        if(superPowerPlaying){
            superPowerMixer.onPlayPause(0)
            superPowerPlaying = false
            btn_multitrack_play_pause_ref.setBackgroundImage(UIImage(named: "Multitrack-play.pdf"), for: .normal)
            mark_item_play_pause(index: old_indexes[0], boo: false)
            mark_item_play_pause(index: old_indexes[1], boo: false)
            refreshUI(index: old_indexes[0])
            refreshUI(index: old_indexes[1])
        }else{
            if(checked_indexes.count > 2){
                display_alert(msg_title: "Select only 2 file for mixing play", msg_desc: "", action_title: "Ok")
            }else if(checked_indexes.count < 2){
                display_alert(msg_title: "Select only 2 file for mixing play", msg_desc: "", action_title: "Ok")
            } else if(checked_indexes.count == 2){
                changeSelection = false
                if(old_indexes.count > 0){
                    for i in checked_indexes{
                        if (!old_indexes.contains(i)){
                            changeSelection = true
                            break
                        }
                    }
                }else{
                    changeSelection = true
                }
                
                if(changeSelection){
                    self.myActivityIndicator.startAnimating()
                    old_indexes.removeAll()
                    for i in checked_indexes{
                        old_indexes.append(i)
                    }
                    if(initSuperPower){
                        stop_super_power()
                    }
                    check_exist_else_download(index: 0)
                }else{
                    superPowerMixer.onPlayPause(1)
                    superPowerPlaying = true
                    btn_multitrack_play_pause_ref.setBackgroundImage(UIImage(named: "multitrack_pause.pdf"), for: .normal)
                    mark_item_play_pause(index: old_indexes[0], boo: true)
                    mark_item_play_pause(index: old_indexes[1], boo: true)
                    refreshUI(index: old_indexes[0])
                    refreshUI(index: old_indexes[1])
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update_time), userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    func check_exist_else_download(index : Int){
        if(index < 2){
            let selectedAudio = self.record_list[self.old_indexes[index]]
            if selectedAudio.tid != nil
            {
                let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let audio_name = selectedAudio.tid!
                let dir_Path = document_path.appendingPathComponent("recordings/projects")
                let destinationUrl = dir_Path.appendingPathComponent(audio_name)
                if FileManager.default.fileExists(atPath: destinationUrl.path)
                {
                    let new_index = index + 1
                    check_exist_else_download(index: new_index)
                }else
                {
                    if(selectedAudio.downloadURL != ""){
                        let httpsReference = Storage.storage().reference(forURL: selectedAudio.downloadURL!)
                        let connectedRef = FirebaseManager.getDatabase().reference(withPath: ".info/connected")
                        connectedRef.observe(.value, with: { snapshot in
                            if snapshot.value as? Bool ?? false {
                                self.download_process_view_ref.alpha = 1.0
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
                                            self.processRing.setProgress(value: 0, animationDuration: 0.0)
                                            if FileManager.default.fileExists(atPath: destinationUrl.path)
                                            {
                                                let new_index = index + 1
                                                self.check_exist_else_download(index: new_index)
                                            }
                                        }
                                        
                                        downloadTask.observe(.failure, handler: { (snapshot) in
                                            self.download_error_flag = true
                                            self.download_process_view_ref.alpha = 0.0
                                            self.myActivityIndicator.stopAnimating()
                                            self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                                        })
                                        self.myActivityIndicator.stopAnimating()
                                        // self.play_audio_online(myurl: selectedAudio.downloadURL!)
                                }
                            } else {
                                self.download_error_flag = true
                                self.myActivityIndicator.stopAnimating()
                                self.display_alert(msg_title: "No Internet Connection", msg_desc: "For download - make sure your device is connected to the internet", action_title: "OK")
                            }
                        })
                    }
                    else{
                        download_error_flag = true
                        self.myActivityIndicator.stopAnimating()
                        self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                    }
                }
            }
        }else{
            if(!download_error_flag){
                //Go and mix
                print("Go for the function")
                mix_and_play()
            }else{
                download_error_flag = false
                self.myActivityIndicator.stopAnimating()
                self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
            }
        }
    }
    
    func mix_and_play(){
        if(old_indexes.count == 1){
            //print("only one audio is there play directly")
            self.myActivityIndicator.stopAnimating()
            display_alert(msg_title: "Select only 2 file for mixing play", msg_desc: "", action_title: "Ok")
        }else if(old_indexes.count == 2){
            let id1 = self.record_list[self.old_indexes[0]].tid
            let id2 = self.record_list[self.old_indexes[1]].tid
            
            let vol1 = self.record_list[self.old_indexes[0]].volume
            let vol2 = self.record_list[self.old_indexes[1]].volume
            
            let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dir_Path = document_path.appendingPathComponent("recordings/projects")
            let url1 = dir_Path.appendingPathComponent(id1!).absoluteString
            let url2 = dir_Path.appendingPathComponent(id2!).absoluteString
            
            //superPowerMixer = SuperpoweredRecorderWrapped()
            superPowerMixer.initializeData(url1, url2)
            superPowerMixer.onPlayPause(1)
            superPowerMixer.onCrossFader(0.5)
            
            initSuperPower = true
            superPowerPlaying = true
            
            mark_item_play_pause(index: old_indexes[0], boo: true)
            mark_item_play_pause(index: old_indexes[1], boo: true)
            refreshUI(index: old_indexes[0])
            refreshUI(index: old_indexes[1])
            
            btn_multitrack_play_pause_ref.setBackgroundImage(UIImage(named: "multitrack_pause.pdf"), for: .normal)
           
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update_time), userInfo: nil, repeats: true)
            self.myActivityIndicator.stopAnimating()
            
//            self.timer1 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update_time), userInfo: nil, repeats: true)
//            self.timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update_time), userInfo: nil, repeats: true)
            
        }else{
            display_alert(msg_title: "select something for play", msg_desc: "", action_title: "Ok")
        }
    }
    
    func mark_item_play_pause(index : Int, boo : Bool){
        self.record_list[index].isPlaying = boo
    }
    
    func mark_item_checked(index : Int, boo : Bool){
        self.record_list[index].isCheck = boo
    }
    
    func mark_item_clear(index : Int){
        self.record_list[index].isCheck = false
        self.record_list[index].isPlaying = false
        self.record_list[index].current_time = 0;
        self.record_list[index].total_time = 0;
    }
    
    func mark_all_clear(){
        for rec in self.record_list{
            rec.current_time = 0;
            rec.isCheck = false;
            rec.isPlaying = false;
            rec.total_time = 0;
        }
    }
    
    func mark_single_clear(index : Int){
        self.current_playing=false
        self.player.stop()
        self.audio_play = false
        mark_item_clear(index:index)
        refreshUI(index:index)
    }
    
    func refreshUI(index: Int){
        var indexPathArray : [IndexPath] = []
        let gen_index = NSIndexPath(row: index, section: 0)
        indexPathArray.append(gen_index as IndexPath)
        if(indexPathArray.count > 0){
            UIView.setAnimationsEnabled(false)
            self.recording_tbl_ref.beginUpdates()
            recording_tbl_ref.reloadRows(at: indexPathArray, with: .none)
            self.recording_tbl_ref.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func refreshAll(){
        var indexPathArray : [IndexPath] = []
        for  index in 0 ..< self.record_list.count{
            let gen_index = NSIndexPath(row: index, section: 0)
            indexPathArray.append(gen_index as IndexPath)
            if(indexPathArray.count > 0){
                UIView.setAnimationsEnabled(false)
                self.recording_tbl_ref.beginUpdates()
                recording_tbl_ref.reloadRows(at: indexPathArray, with: .none)
                self.recording_tbl_ref.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
        }
    }

    func update_time(){
        
        if let pAmeta = superPowerMixer.currentPlayerTimeA(){
            playerAMeta = pAmeta.components(separatedBy: ",")
        }
        if let pBmeta = superPowerMixer.currentPlayerTimeB(){
            playerBMeta = pBmeta.components(separatedBy: ",")
        }
        
        let secondsA = playerAMeta![0]
        let isPlayingA = playerAMeta![1]
        let endOfFileA = playerAMeta![2]
        let durationA = playerAMeta![3]
        
        let secondsB = playerBMeta![0]
        let isPlayingB = playerBMeta![1]
        let endOfFileB = playerBMeta![2]
        let durationB = playerBMeta![3]
        
        if (old_indexes.count==2){
            aIndex = old_indexes[0]
            bIndex = old_indexes[1]
            
            if (isPlayingA == "1"){
                
                self.record_list[aIndex].isPlaying = (isPlayingA == "1")
                self.record_list[aIndex].total_time = Int(durationA)
                self.record_list[aIndex].flag = true
                if let current_second = Int(secondsA){
                    self.record_list[aIndex].current_time = current_second
                    let gen_index = NSIndexPath(row: aIndex, section: 0)
                    
                    if let myCell = recording_tbl_ref.cellForRow(at: gen_index as IndexPath) as? project_reccording_tbl_cell{
                        myCell.play_starting_time.text = give_time(seconds : current_second)
                        let audio_remaining_sec = Int(durationA)! - current_second
                        myCell.play_ending_time.text = "-" + give_time(seconds: audio_remaining_sec)
                    }
                }
                
            }
            
            if (isPlayingB == "1"){
                
                self.record_list[bIndex].isPlaying = (isPlayingB == "1")
                self.record_list[bIndex].total_time = Int(durationB)
                self.record_list[bIndex].flag = true
                if let current_second = Int(secondsB){
                    self.record_list[bIndex].current_time = current_second
                    let gen_index = NSIndexPath(row: bIndex, section: 0)
                    
                    if let myCell = recording_tbl_ref.cellForRow(at: gen_index as IndexPath) as? project_reccording_tbl_cell{
                        myCell.play_starting_time.text = give_time(seconds : current_second)
                        let audio_remaining_sec = Int(durationB)! - current_second
                        myCell.play_ending_time.text = "-" + give_time(seconds: audio_remaining_sec)
                    }
                }
                
            }
            
            if(endOfFileA == "1" && flagA == false){
                flagA = true
                self.record_list[aIndex].flag = false
                mark_item_play_pause(index: aIndex, boo: false)
                refreshUI(index: aIndex)
            }
            
            if(endOfFileB == "1" && flagB == false){
                flagB = true
                self.record_list[bIndex].flag = false
                mark_item_play_pause(index: bIndex, boo: false)
                refreshUI(index: bIndex)
            }
            
            if (isPlayingA == "1"){
                flagA = false
            }
            if (isPlayingB == "1"){
                flagB = false
            }
            
            if(endOfFileA == "1" && endOfFileB == "1"){
                self.timer.invalidate()
                superPowerPlaying = false
                btn_multitrack_play_pause_ref.setBackgroundImage(UIImage(named: "Multitrack-play.pdf"), for: .normal)
            }
        }
        else{
            self.timer.invalidate()
        }
    }
    
    func stop_super_power(){
        superPowerMixer.stopPlay()
        superPowerPlaying = false
        initSuperPower = false
        btn_multitrack_play_pause_ref.setBackgroundImage(UIImage(named: "Multitrack-play.pdf"), for: .normal)
        refreshAll()
    }
    
    @IBAction func multitrack_earphone(_ sender: UIButton) {
        print("earphone click")
    }
    
    func give_time(seconds : Int) -> String
    {
        var dis_sec = 0
        var dis_min = 0
        var dis_hr = 0
        if ( seconds > 60 ){
            let minute = seconds / 60
            dis_sec = seconds % 60
            if ( minute > 60 ){
                dis_hr = minute / 60
                dis_min = minute % 60
            }else{
                dis_min = minute
            }
        }else{
            dis_sec = seconds
        }
        var print_sec : String
        var print_min : String
        var print_hr : String
        if (dis_sec < 10){
            print_sec = "0" + String(dis_sec)
        }else{
            print_sec = String(dis_sec)
        }
        print_min = String(dis_min) + ":"
        if (dis_hr == 0){
            print_hr = ""
        }else{
            print_hr = String(dis_hr) + ":"
        }
        return print_hr + print_min + print_sec
    }
    
    //For Slider & RangeseekSlider
    /*
    func scrubber_init()
    {
        audioDuration = Float(audioPlayer.duration)
        if(max_not_initialize){
            looping_end_index = audioDuration
            max_not_initialize = false
        }
        
        loop_inner_slider_ref.minimumValue = 0.0
        loop_inner_slider_ref.maximumValue = 100
        
        RangeSeekSliderRef.minValue = 0.0
        RangeSeekSliderRef.maxValue = 100
        
        audioPlayer.currentTime = TimeInterval(looping_start_index)
    }
     
    
    
    func update_scrubber()
    {
        var current_time = Float(audioPlayer.currentTime)
        
        if(current_time > looping_end_index){
            audioPlayer.currentTime = TimeInterval(looping_start_index)
            current_time = Float(audioPlayer.currentTime)
            //initialize_audio_and_play()
        }
        current_time_lbl_ref.text = time_to_string(seconds: Int(current_time))
        var p = (current_time * 100) / audioDuration
        
        if(p < left_scrubber_value){
            p = left_scrubber_value
        }
        if(p > right_scrubber_value){
            p = right_scrubber_value
        }
        
        loop_inner_slider_ref.setValue(p, animated:true)
        let left_pos = loop_inner_slider_ref.thumbCenterX - 18
        looping_lbl_x_constraint_ref.constant = left_pos
    }
    
    func updateSliderLabelInstant(sender: UISlider!) {
        let value = sender.value
        DispatchQueue.main.async {
            let left_pos = self.loop_inner_slider_ref.thumbCenterX - 18
            self.looping_lbl_x_constraint_ref.constant = left_pos
            let p1 = (value * self.audioDuration) / 100
            self.current_time_lbl_ref.text = self.time_to_string(seconds: Int(p1))
            
        }
    }
 
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        
        left_scrubber_value = Float(minValue)
        right_scrubber_value = Float(maxValue)
        
        let p1 = (left_scrubber_value * audioDuration) / 100
        let p2 = (right_scrubber_value * audioDuration) / 100
        
        looping_start_index = Float(p1)
        looping_end_index = Float(p2)
        
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        
        loop_inner_slider_ref.value = Float(minValue)
        let left_pos = self.loop_inner_slider_ref.thumbCenterX - 18
        self.looping_lbl_x_constraint_ref.constant = left_pos
        let cur_time = time_to_string(seconds: Int(looping_start_index))
        self.current_time_lbl_ref.text = cur_time
        left_seek_slider_lbl_ref.text = cur_time
        return ""
        //return cur_time
        
    }
    
    
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        right_seek_slider_lbl_ref.text = time_to_string(seconds: Int(looping_end_index))
        return ""
        //return time_to_string(seconds: Int(looping_end_index))
        
    }*/
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        
        let row = slider.tag
        
        self.record_list[row].left_scrubber_value = Float(minValue)
        self.record_list[row].right_scrubber_value = Float(maxValue)
        
        
        print(slider.tag)
        print(minValue)
        print(maxValue)
        
//        left_scrubber_value = Float(minValue)
//        right_scrubber_value = Float(maxValue)
//
//        let p1 = (left_scrubber_value * audioDuration) / 100
//        let p2 = (right_scrubber_value * audioDuration) / 100
//
//        looping_start_index = Float(p1)
//        looping_end_index = Float(p2)
        
    }
    
    func didStartTouches(in slider: RangeSeekSlider) {
        rangeSelectorActive = true
        print("start touch")
    }
    
    func didEndTouches(in slider: RangeSeekSlider) {
        rangeSelectorActive = false
        print("touch end")
    }
    
     func LoopInnerSliderValueChange(sender: UISlider) {
        
        let loop_inner_slider_value = sender.value    // get slider's value
        let row = sender.tag               // get slider's row in table
        
        print(row)
        print(loop_inner_slider_value)
        
        let left_scrubber_value = self.record_list[row].left_scrubber_value
        let right_scrubber_value = self.record_list[row].right_scrubber_value
        
        if(loop_inner_slider_value < left_scrubber_value){
            
        }
        
//        if(loop_inner_slider_ref.value < left_scrubber_value){
//            loop_inner_slider_ref.value = left_scrubber_value
//        }
//        if(loop_inner_slider_ref.value > right_scrubber_value){
//            loop_inner_slider_ref.value = right_scrubber_value
//        }
//        let left_pos = loop_inner_slider_ref.thumbCenterX - 18
//        looping_lbl_x_constraint_ref.constant = left_pos
//
//        let p1 = (loop_inner_slider_ref.value * audioDuration) / 100
//
//        audioPlayer.currentTime = TimeInterval(p1)
    }
    
    //MARK: - Display Alert
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            //_ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if(initSuperPower){
           stop_super_power()
            initSuperPower = false
        }
        
        if(self.audio_play){
            self.player.stop()
            self.audio_play = false
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
