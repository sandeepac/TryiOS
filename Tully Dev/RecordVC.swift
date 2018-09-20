//
//  RecordVC.swift
//  Tully Dev
//
//  Created by macbook on 5/25/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import SCSiriWaveformView
import CoreBluetooth

protocol comeFromLyricsRecording {
    func comeFromLyricsRecording_Recording(isCorrect : Bool)
}

class RecordVC: UIViewController , AVAudioRecorderDelegate, AVAudioPlayerDelegate, myProtocol , UIDocumentInteractionControllerDelegate, CBCentralManagerDelegate, shareSecureResponseProtocol
{
    
    //________________________________ Outlets  ___________________________________
    
    @IBOutlet var audioWaveView: SCSiriWaveformView!
    @IBOutlet var recordingTimeLabel: UILabel!
    @IBOutlet var lbl_ref_recording: UILabel!
    @IBOutlet var record_btn_ref: UIButton!
    @IBOutlet var play_btn_ref: UIButton!
    @IBOutlet var lbl4: UILabel!
    @IBOutlet var lbl3: UILabel!
    @IBOutlet var lbl2: UILabel!
    @IBOutlet var lbl1: UILabel!
    @IBOutlet var audio_bg_img_ref: UIImageView!
    
    
    //________________________________ Variables  ___________________________________
    var comeFromLyricsRecording : comeFromLyricsRecording?
    var comeFromLyricsRecordingVC = false
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted = false
    var audio_urls = [URL]()
    var isRecording = false
    var isPlaying = false
    var controller1 = UIDocumentInteractionController()
    var second_count_for_animation = 5
    var timer = Timer()
    var older_path = ""
    var current_key = ""
    var project_key = ""
    var waveTimer : Timer!
    var manager:CBCentralManager!
    var flag_bluetooth = false
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "lyricsTabSelected")
        check_record_permission()
        manager = CBCentralManager(delegate: self, queue: nil, options: nil)
        manager.delegate = self
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
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
                audio_urls.append(getFileUrl())
                
                self.lbl_ref_recording.text = "Recording..."
                self.recordingTimeLabel.text = "00:00:00"
                lbl1.text = "1"
                lbl2.text = "2"
                lbl3.text = "3"
                lbl4.text = "4"
                timer.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(animate_4321), userInfo: nil, repeats: true)
                
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
    
    // For check bluetooth is connected or not
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOff{
            flag_bluetooth = false
        }
        else{
            flag_bluetooth = true
        }
    }
    
    @IBAction func open_share_delete(_ sender: Any)
    {
        
        let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        
        alertController.addAction(cancelAction)
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { action in
            self.share_recording()
            
        }
        alertController.addAction(shareAction)
        
        let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.delete_recording()
        }
        alertController.addAction(destroyAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    @IBAction func start_recording(_ sender: UIButton)
    {
        
        if(second_count_for_animation == 5)
        {
            if(isRecording)
            {
                record_btn_ref.setImage(UIImage(named : "RecordingTabRecordBtn"), for: .normal)
                finishAudioRecording(success: true)
                play_btn_ref.isEnabled = true
                isRecording = false
                audioWaveView.frequency = 0.0
                //MyVariables.notification_recording = false
                let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "save_recording_sid") as! SaveRecordingVC
                child_view.myProtocol = self
                self.addChildViewController(child_view)
                child_view.view.frame = self.view.frame
                
                self.view.addSubview(child_view.view)
                child_view.didMove(toParentViewController: self)
            }
            else
            {
                setup_recorder()
                
                
            }
        }
    }
    
    
    func prepare_play()
    {
        do
        {
            let destinationUrl = NSURL(string: older_path)
            audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl! as URL)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch{
            display_alert(msg_title: "Can't Play", msg_desc: "Not able to play", action_title: "ok")
        }
    }
    
    @IBAction func play_recording(_ sender: Any)
    {
        if(isPlaying)
        {
            audioPlayer.stop()
            
            waveTimer.invalidate()
            audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
            record_btn_ref.isEnabled = true
            play_btn_ref.setImage(UIImage(named : "green-play"), for: .normal)
            isPlaying = false
        }
        else
        {
            if(older_path == "")
            {
                display_alert(msg_title: "Record Something", msg_desc: "Please record first, then you can play.", action_title: "OK")
            }
            else
            {
                let destinationUrl = NSURL(string: older_path)
                if FileManager.default.fileExists(atPath: (destinationUrl?.path)!)
                {
                    
                    record_btn_ref.isEnabled = false
                    play_btn_ref.setImage(UIImage(named : "pause"), for: .normal)
                    prepare_play()
                    
                    lbl_ref_recording.text = "Playing... "
                    //recordingTimeLabel.text = ""
                    isPlaying = true
                    
                    waveTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.audioPlayWaveMeters), userInfo: nil, repeats: true)
                    audioPlayer.play()
                    //MyVariables.notification_audio_play = true
                }
                else
                {
                    display_alert(msg_title: "Error", msg_desc: "Audio file is missing.", action_title: "OK")
                }
            }
        }
    }
    
    func finishAudioRecording(success: Bool)
    {
        if success
        {
            audioRecorder.stop()
            audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
            audioRecorder = nil
            meterTimer.invalidate()
            waveTimer.invalidate()
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    
    func updateAudioMeter(timer: Timer){
        if let recorder = audioRecorder{
            if recorder.isRecording{
                let hr = Int((audioRecorder.currentTime / 60) / 60)
                let min = Int(audioRecorder.currentTime / 60)
                let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
                let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
                recordingTimeLabel.text = totalTimeString
                audioRecorder.updateMeters()
            }
        }
    }
    
    func getDocumentsDirectory() -> URL
    {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory
    }
    
    func getFileUrl() -> URL
    {
        let filename = "temp.wav"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            finishAudioRecording(success: false)
        }
        //MyVariables.notification_recording = false
        play_btn_ref.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        record_btn_ref.isEnabled = true
        //audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
        waveTimer.invalidate()
        play_btn_ref.setImage(UIImage(named : "green-play"), for: .normal)
        lbl_ref_recording.text = ""
        recordingTimeLabel.text = ""
        isPlaying = false
        //MyVariables.notification_audio_play = false
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
    
    func delete_recording(){
        if(older_path == ""){
            display_alert(msg_title: "Record Something", msg_desc: "Please record first, then you can delete.", action_title: "OK")
        }else{
            conform_delete_alert(msg_title: "Delete File?", msg_desc: "Are you sure you want to delete this recording?")
        }
    }
    
    func share_recording()
    {
        if(current_key == ""){
            display_alert(msg_title: "Record Something", msg_desc: "Please record first, then you can share.", action_title: "OK")
        }else{
            if let myuserid = Auth.auth().currentUser?.uid
            {
                var no_project_key: [String] = []
                no_project_key.append(current_key)
                let no_project_string = "&no_project_rec_ids="+no_project_key.description
                let project_string = "&project_recs="+""
                let postString = "userid="+myuserid+no_project_string+project_string
                let myurlString = MyConstants.share_recordings
                let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareSecureDownloadVC_sid") as! ShareSecureDownloadVC
                child_view.shareSecureResponseProtocol = self
                child_view.shareString = postString
                child_view.urlString = myurlString
                present(child_view, animated: true, completion: nil)
            }
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
    
    
    
    
    // Display Alert
    
    func conform_delete_alert(msg_title : String , msg_desc : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
        let titleAttrString = NSMutableAttributedString(string: msg_title, attributes: attributes)
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
            do
            {
                if(self.older_path != "" && self.current_key != "" && self.project_key != "")
                {
                    let destinationUrl = NSURL(string: self.older_path)!
                    try FileManager.default.removeItem(atPath: destinationUrl.path!)
                    
                    if(self.project_key == "no_project")
                    {
                        self.remove_no_project_recording()
                    }
                    else
                    {
                        self.remove_project_recording()
                    }
                }
            }
            catch let error as NSError
            {
                self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
            }
        })
        present(ac, animated: true)
    }
    
    func remove_no_project_recording()
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("no_project").child("recordings").child(self.current_key).removeValue(completionBlock: { (error, database_ref) in
            
            if let error = error{
                self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }else{
                self.record_btn_ref.isEnabled = true
                self.waveTimer.invalidate()
                self.play_btn_ref.setImage(UIImage(named : "green-play"), for: .normal)
                self.lbl_ref_recording.text = "Recording..."
                self.recordingTimeLabel.text = "00:00:00"
                self.isPlaying = false
                self.lbl4.text = "4"
                self.lbl3.text = "3"
                self.lbl2.text = "2"
                self.lbl1.text = "1"
                self.play_btn_ref.isEnabled = false
                self.audioWaveView.frequency = 0.0
            }
        })
    }
    
    func remove_project_recording()
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").child(self.project_key).child("recordings").child(self.current_key).removeValue(completionBlock: { (error, database_ref) in
            if let error = error
            {
                self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
            else
            {
                self.display_alert(msg_title: "Deleted!", msg_desc: "File Deleted Successfully.", action_title: "Ok")
            }
        })
    }
    
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
    
    func animate_4321()
    {
        second_count_for_animation = second_count_for_animation - 1
        if(second_count_for_animation == 0)
        {
            timer.invalidate()
            audioWaveView.frequency = 3.0
            second_count_for_animation = 5
            record_btn_ref.setImage(UIImage(named : "recording-stop"), for: .normal)
            audio_bg_img_ref.loadGif(name: "wave")
            audioRecorder.record()
            //MyVariables.notification_recording = true
            //let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(RecordVC.updateMeters))
            //displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            waveTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateWaveMeters), userInfo: nil, repeats: true)
            lbl_ref_recording.text = "Recording... "
            play_btn_ref.isEnabled = false
            isRecording = true
            lbl4.text = ""
            lbl3.text = ""
            lbl2.text = ""
            lbl1.text = ""
        }
        else
        {
            var currentlbl = lbl4!
            if(second_count_for_animation == 3)
            {
                currentlbl = lbl3!
            }
            else if(second_count_for_animation == 2)
            {
                currentlbl = lbl2!
            }
            else if(second_count_for_animation == 1)
            {
                currentlbl = lbl1!
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                currentlbl.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                currentlbl.textColor = UIColor(red: 34/255, green: 209/255, blue: 151/255, alpha: 1.0)
            }, completion: {(finished : Bool) in
                if(finished)
                {
                    UIView.animate(withDuration: 0.5, animations : {
                        currentlbl.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: {(finished : Bool) in
                        if(finished)
                        {
                            currentlbl.textColor = UIColor(red: 95/255, green: 111/255, blue: 137/255, alpha: 1.0)
                        }
                    })
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if(isPlaying)
        {
            self.audioPlayer.stop()
            isPlaying=false
            
        }
    }
    
    @IBAction func close_view(_ sender: Any) {
        
        if(comeFromLyricsRecordingVC){
            self.comeFromLyricsRecording?.comeFromLyricsRecording_Recording(isCorrect: true)
            dismiss(animated: true, completion: nil)
        }else{
            dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setSavedUrl(viewedUrl : String)
    {
        older_path = viewedUrl
    }
    
    func setCurrentKey(savedKey : String)
    {
        current_key = savedKey
    }
    
    func setProjectKey(projectKey : String)
    {
        project_key = projectKey
    }
}
