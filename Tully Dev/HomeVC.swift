//
//  HomeVC.swift
//  Tully Dev
//
//  Created by macbook on 5/24/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import UICircularProgressRing
import Mixpanel
import Intercom
import Crashlytics

//import AudioKit

class HomeVC: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UIDocumentInteractionControllerDelegate, renameCompleteProtocol, Home_Selected_Protocol, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, shareSecureResponseProtocol, UITableViewDelegate, UITableViewDataSource
{
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var masterSizeLblRef: UILabel!
    @IBOutlet weak var homeMasterEngineerInfoVC: UIView!
    @IBOutlet var height_constraint_of_have_file_view: NSLayoutConstraint!
    @IBOutlet var home_file_collectionview_ref: UICollectionView!
    @IBOutlet var home_project_collectionview_ref: UICollectionView!
    @IBOutlet var home_master_collectionview_ref: UICollectionView!
    @IBOutlet var splash_screen_view: UIView!
    @IBOutlet var top_view: UIView!
    @IBOutlet var search_bar_ref: UISearchBar!
    @IBOutlet var search_view: UIView!
    @IBOutlet var download_process_view_ref: UIView!
    @IBOutlet var processRing: UICircularProgressRingView!
    @IBOutlet weak var add_engineer_request_tbl: UIView!
    @IBOutlet var no_file_view_ref: UIView!
    @IBOutlet var have_files_view: UIView!
    @IBOutlet var down_up_img_ref: UIImageView!
    @IBOutlet var add_engineer_request: UIView!
    @IBOutlet var display_project_view_ref: UIView!
    @IBOutlet var display_master_view_ref: UIView!
    @IBOutlet var display_file_view_ref: UIView!
    @IBOutlet var scrollview_ref: UIScrollView!
    @IBOutlet var lbl_all_ref: UILabel!
    
    // MARK: - Variables
    @IBOutlet var select_any_tbl_view_ref: UITableView!
    var project_data = [HomeData]()
    var master_data = [MasterData]()
    var HomeFileData = [HomeFilesData]()
    var display_all_data_flag = false
    var search_text = ""
    var is_selected_all_lyrics = false
    var selected_file_tab = true
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var screenSize : CGRect? = nil
    var screenWidth = 0.0
    var current_selected_index : Int? = nil
    var current_selected_type = ""
    var isAudioRecordingGranted: Bool!
    var controller1 = UIDocumentInteractionController()
    var selected_mode = ""
    var have_file_view_height = 0
    var first_open = false
    var get_from_search = false
    var any_view_open_flag = false
    var width_of_img = 0
    var last_node_of_project = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        set_delegate_datasource()
        self.add_engineer_request.alpha = 0.0
        self.add_engineer_request_tbl.alpha = 0.0
        
        if(!first_open){
            select_any_tbl_view_ref.alpha = 0.0
            first_open = true
        }
        if(have_file_view_height == 0){
            have_file_view_height = Int(self.have_files_view.frame.height)
        }
        
        if(!MyVariables.home_tutorial){
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "h1TutorialSid") as! h1TutorialVC
            vc.tutorial_for = "home"
            self.present(vc, animated: true, completion: nil)
        }
        
        let myrect = CGRect(x: 0, y: 0, width: scrollview_ref.frame.width, height: scrollview_ref.frame.height)
        scrollview_ref.scrollRectToVisible(myrect, animated: false)
        screenSize = UIScreen.main.bounds
        screenWidth = Double(screenSize!.width)
        self.navigationController?.isNavigationBarHidden = true
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        intercom_update_user()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        }catch {}
        
        search_view.isHidden = true
        collection_view_layout()
        select_any_tbl_view_ref.tableFooterView = UIView()
        setNotificationToken()
        //touchid_settings()
       // get_copy_to_tully_data()
    }
    func checkPushNotificationKey(){
        if let found = UserDefaults.standard.value(forKey: "setPushNotificationKey") as? Bool{
            if(!found){
                setNotificationToken()
            }
        }else{
            setNotificationToken()
        }
    }
    
    
    func setNotificationToken(){
        if let fcmToken = UserDefaults.standard.value(forKey: MyConstants.tNotificationToken) as? String{
            if let uid = Auth.auth().currentUser?.uid{
                print(uid)
                let token : [String : String] = [MyConstants.tNotificationToken : fcmToken]
                let userRef = FirebaseManager.getRefference().child(uid).ref
                
                userRef.child("settings").updateChildValues(token) { (error, reference) in
                    if let err = error{
                        print(err.localizedDescription)
                    }else{
                        print("set successfully")
                        UserDefaults.standard.setValue(true, forKey: "setPushNotificationKey")
                    }
                }
            }else{
                print("uid not found")
            }
        }
    }
    
    
    
    
    func intercom_update_user(){
        if let uid = Auth.auth().currentUser?.uid{
            DispatchQueue.main.async{
                let userRef = FirebaseManager.getRefference().child(uid).ref
                userRef.keepSynced(true)
                Intercom.registerUser(withUserId: (Auth.auth().currentUser!.uid))
                let userAttributes = ICMUserAttributes()
                if let uname = Auth.auth().currentUser?.displayName{
                    userAttributes.name = uname
                }
                if let uemail = Auth.auth().currentUser?.email{
                    userAttributes.email = uemail
                }
                Intercom.updateUser(userAttributes)
            }
        }
    }
    
    // Set datasource & delegates
    
    func set_delegate_datasource(){
        home_master_collectionview_ref.dataSource = self
        home_master_collectionview_ref.delegate = self
        home_project_collectionview_ref.dataSource = self
        home_project_collectionview_ref.delegate = self
        home_file_collectionview_ref.dataSource = self
        home_file_collectionview_ref.delegate = self
        //select_any_collection_view_ref.delegate = self
        //select_any_collection_view_ref.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        let new_height = CGFloat(((self.HomeFileData.count/3) * 102))
        let scroll_height = ((CGFloat(self.have_file_view_height) + new_height) - 50)
        //let scroll_height = ((CGFloat(self.have_file_view_height) + new_height) - 50 - 137)
        self.height_constraint_of_have_file_view.constant = scroll_height
    }
    
    // MARK: - ViewAppear Methods
    
    override func viewWillAppear(_ animated: Bool) {
        self.add_engineer_request.alpha = 0.0
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(_:)), name: Notification.Name(rawValue: "reloadData"), object: nil)
        //self.tabBarController?.selectedIndex = 0
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
        MyVariables.currently_selected_tab = 0
        MyVariables.last_open_tab_for_inttercom_help = 0
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.items![1].image = UIImage(named: "Play_tab")
        self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Home_Selected_tab")
        add_engineer_request_tbl.alpha = 0.0
        check_record_permission()
        upload_remaining()
        share_remaining()
        btn_all_click()
    }
    
    @objc func reloadData(_ notification: Notification) {
        btn_all_click()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
      //if(MyVariables.home_tutorial){
        let myrect = CGRect(x: 0, y: 0, width: scrollview_ref.frame.width, height: scrollview_ref.frame.height)
        scrollview_ref.scrollRectToVisible(myrect, animated: true)
        
        if(Auth.auth().currentUser != nil)
        {
            Crashlytics.sharedInstance().setUserIdentifier(Auth.auth().currentUser?.uid)
            Crashlytics.sharedInstance().setUserEmail(Auth.auth().currentUser?.email)
            Crashlytics.sharedInstance().setUserName(Auth.auth().currentUser?.displayName)
            
            if(MyVariables.force_touch_open != "")
            {
                if(MyVariables.force_touch_open == "lyrics")
                {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home_tabBar_sid") as! UITabBarController
                    vc.selectedIndex = 3
                    self.present(vc, animated: false, completion: nil)
                }
                else if(MyVariables.force_touch_open == "record")
                {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home_tabBar_sid") as! UITabBarController
                    vc.selectedIndex = 4
                    self.present(vc, animated: false, completion: nil)
                }
            }else{
                splash_screen_view.alpha = 0.0
                if(MyVariables.myaudio != nil && MyVariables.myTitle != "")
                {
                    create_audio_file()
                }
            }
        }else{
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login_sid") as! LogInVC
            UIApplication.shared.keyWindow?.rootViewController = vc
            self.present(vc, animated: true, completion: nil)
        }
       // }
    }
    
    // MARK :- For Recording 
    
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
    
    // MARK: - Collection View Layout
    
    func collection_view_layout()
    {
        DispatchQueue.main.async {
            let layout_master : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout_master.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let master_width = self.home_master_collectionview_ref.frame.width
            layout_master.scrollDirection = UICollectionViewScrollDirection.horizontal
            self.width_of_img = Int(master_width/3.7)
            layout_master.itemSize = CGSize(width: master_width/5, height: 82)
            layout_master.minimumInteritemSpacing = 0
            layout_master.minimumLineSpacing = 20
            self.home_master_collectionview_ref.collectionViewLayout = layout_master
            
            let layout_project : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout_project.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let project_width = self.home_project_collectionview_ref.frame.width
            layout_project.scrollDirection = UICollectionViewScrollDirection.horizontal
            layout_project.itemSize = CGSize(width: project_width/5, height: 82)
            layout_project.minimumInteritemSpacing = 0
            layout_project.minimumLineSpacing = 50
            self.home_project_collectionview_ref.collectionViewLayout = layout_project
            self.home_file_collectionview_ref.isScrollEnabled = false
        }
        
    }
    
    //________________________________ Create Audio file  ___________________________________
    
    func getFileUrl() -> URL
    {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("copytoTully")
        do
        {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "Ok")
        }
        let dest_path = dataPath.appendingPathComponent(MyVariables.myTitle!)
        return dest_path
    }
    
    func create_audio_file()
    {
        do
        {
            let fileUrl = getFileUrl()
            try MyVariables.myaudio?.write(to: fileUrl, options: .atomic)
            let fileDictionary = try FileManager.default.attributesOfItem(atPath: fileUrl.path)
            let fileSize = fileDictionary[FileAttributeKey.size] as! Int64
            var kb_size = String(fileSize/1000)
            kb_size = kb_size + " KB"
            let current_name =  MyVariables.myTitle!.split(separator: ".").first!
            var copytotully_key = ""
            if(MyVariables.myTitle != "")
            {
                let file_name = MyVariables.myTitle!
                
                if let uploadAudioData = NSData(contentsOf: fileUrl.absoluteURL)
                {
                    let metadata1 = StorageMetadata()
                    var contentType = ""
                    let url_absolute = fileUrl.absoluteString
                    
                    if(url_absolute.contains("m4a"))
                    {
                        contentType = "audio/x-m4a"
                    }
                    if(url_absolute.contains("mp3"))
                    {
                        contentType = "audio/mp3"
                    }
                    if(url_absolute.contains("wav"))
                    {
                        contentType = "audio/wav"
                    }
                    metadata1.contentType = contentType
                    
                    let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                    
                    copytotully_key  = userRef.child("copytotully").childByAutoId().key
                    let current_name =  file_name.split(separator: ".").first!
                    let copytotully_data: [String: Any] = ["mime":contentType, "filename" : file_name, "size" : fileSize, "title" : current_name]
                    
                    userRef.child("copytotully").child(copytotully_key).setValue(copytotully_data, withCompletionBlock: { (error, database) in
                        if let error = error
                        {
                            print(error.localizedDescription)
                        }
                    })
                
                userRef.child("remaining_upload").child("copytotully").child(copytotully_key).setValue(copytotully_data, withCompletionBlock: { (error, database_ref) in
                        
                        if let error = error
                        {
                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                            self.myActivityIndicator.stopAnimating()
                        }else{
                            self.myActivityIndicator.stopAnimating()
                        }
                    })
                    
                    Mixpanel.mainInstance().track(event: "Production Imported in iOS")
                    FirebaseManager.sync_copytotully_file(metadata1: metadata1, uploadAudioData: uploadAudioData as Data, current_id: copytotully_key, file_name: file_name, delete_remaining: true)
                }
                let temp_audio_data = HomeFilesData(uid : copytotully_key, audio_url: fileUrl, audio_name: String(current_name), audio_size: kb_size, downloadURL : "", local_file: true, tid: MyVariables.myTitle!, type: "copytotully", bpm: 0, key: "")
                
                var audio_data  = [playData]()
                let play_data = playData(audio_key : copytotully_key, audio_url: fileUrl, audio_name: String(current_name), audio_size: kb_size, downloadURL : "", local_file: true, tid: MyVariables.myTitle!, bpm: 0, key: "")
                audio_data.append(play_data)
                self.HomeFileData.append(temp_audio_data)
                MyVariables.come_from_home = true
                MyVariables.home_to_shared = true
                MyVariables.audioArray = audio_data
                MyVariables.selected_index = 0
                self.tabBarController?.selectedIndex = 1
                MyVariables.myaudio = nil
            }
        }
        catch {
            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "Ok")
        }
    }
    
    // Share from google drive link
    
    func share_remaining()
    {
        let mydir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.tully.share")!.appendingPathComponent("copytoTully")
        let dataPath = mydir.path
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: dataPath)
        {
            
            let documentsDirectory1 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dataPath1 = documentsDirectory1.appendingPathComponent("copytoTully")
            do
            {
                try FileManager.default.createDirectory(atPath: dataPath1.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError
            {
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "Ok")
            }
            
            do
            {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: mydir, includingPropertiesForKeys: nil, options: [])
                 let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                
                for myUrl in directoryContents
                {
                    
                    let copytotully_key  = userRef.child("copytotully").childByAutoId().key
                    let fileDictionary = try FileManager.default.attributesOfItem(atPath: myUrl.path)
                    let fileNameArr = myUrl.absoluteString.components(separatedBy: "/")
                    let myfilename = fileNameArr[fileNameArr.count - 1]
                    let myfile = myfilename.components(separatedBy: ".")
                    let myExt = myfile[myfile.count - 1]
                    let newName = copytotully_key + "." + myExt
                    let fileSize = fileDictionary[FileAttributeKey.size] as! Int64
                    let dest_path1 = dataPath1.appendingPathComponent(newName)
                    
                    do {
                        try FileManager.default.moveItem(at: myUrl, to: dest_path1)
                        if let uploadAudioData = NSData(contentsOf: dest_path1.absoluteURL)
                        {
                            let metadata1 = StorageMetadata()
                            var contentType = ""
                            let url_absolute = dest_path1.absoluteString
                            
                            if(url_absolute.contains("m4a"))
                            {
                                contentType = "audio/x-m4a"
                            }
                            if(url_absolute.contains("mp3"))
                            {
                                contentType = "audio/mp3"
                            }
                            if(url_absolute.contains("wav"))
                            {
                                contentType = "audio/wav"
                            }
                             metadata1.contentType = contentType
                            
                           
                            
                            let cname =  myfilename.split(separator: ".").first!
                            let current_name = cname.removingPercentEncoding!
                            let copytotully_data: [String: Any] = ["mime":contentType, "filename" : newName, "size" : fileSize, "title" : current_name]
                            
                            userRef.child("copytotully").child(copytotully_key).setValue(copytotully_data, withCompletionBlock: { (error, database) in
                                if let error = error
                                {
                                    print(error.localizedDescription)
                                }
                            })
                            
                        userRef.child("remaining_upload").child("copytotully").child(copytotully_key).setValue(copytotully_data, withCompletionBlock: { (error, database_ref) in
                                
                                if let error = error
                                {
                                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                                    self.myActivityIndicator.stopAnimating()
                                }
                                else
                                {
                                    self.myActivityIndicator.stopAnimating()
                                }
                            })
                            
                            Mixpanel.mainInstance().track(event: "Production Imported in iOS")
                            FirebaseManager.sync_copytotully_file(metadata1: metadata1, uploadAudioData: uploadAudioData as Data, current_id: copytotully_key, file_name: newName, delete_remaining: true)
                        }
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
            catch let error as NSError
            {
                myActivityIndicator.stopAnimating()
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        }
    }
    
    func get_master_data()
    {
        self.master_data.removeAll()
        get_from_search = false
        if(search_text != "")
        {
            search_data()
        }
        else
        {
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid).ref
            
            userRef.child("masters").queryOrdered(byChild: "parent_id").queryEqual(toValue: "0").observe(.value, with: { (snapshot) in
            
            //userRef.child("masters").queryOrdered(byChild: "parent_id").queryEqual(toValue: "0").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    self.master_data.removeAll()
                    for snap in snapshot.children{
                        let userSnap = snap as! DataSnapshot
                        let master_key = userSnap.key
                        let master_value = userSnap.value as! NSDictionary
                        
                        var name = ""
                        var type = ""
                        var count = 0
                        var downloadUrl = ""
                        var lyrics = ""
                        var fname = ""
                        
                        if let current_name = master_value.value(forKey: "name") as? String{
                            name = current_name
                        }
                        
                        if let current_type = master_value.value(forKey: "type") as? String{
                            type = current_type
                        }
                        
                        if let current_count = master_value.value(forKey: "count") as? Int{
                            count = current_count
                        }
                        
                        if let current_size = master_value.value(forKey: "size") as? Int64{
                            count = Int(current_size/1000)
                        }
                        
                        if let current_downloadUrl = master_value.value(forKey: "downloadURL") as? String{
                            downloadUrl = current_downloadUrl
                        }
                        
                        if let current_lyrics = master_value.value(forKey: "lyrics") as? String{
                            lyrics = current_lyrics
                        }
                        
                        if let current_fname = master_value.value(forKey: "filename") as? String{
                            fname = current_fname
                        }
                        
                        var bpm = 0
                        var key = ""
                        
                        if let audioBpm = master_value.value(forKey: "bpm") as? Int{
                            bpm = audioBpm
                        }
                        if let audioKey = master_value.value(forKey: "key") as? String{
                            key = audioKey
                        }
                    
                        
                        let masterdata = MasterData(id: master_key, name: name, parent_id: "0", type: type, count: count, downloadUrl: downloadUrl, lyrics: lyrics, filename: fname, bpm: bpm, key: key)
                        
                        self.master_data.append(masterdata)
                        self.home_master_collectionview_ref.reloadData()
                        if(self.current_selected_type == "master" && self.any_view_open_flag == true){
                            self.select_any_tbl_view_ref.reloadData()
//                            let layout_any : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//                            layout_any.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                            let master_width = self.select_any_collection_view_ref.frame.width
//                            layout_any.scrollDirection = UICollectionViewScrollDirection.vertical
//                            layout_any.itemSize = CGSize(width: master_width/3.7, height: 82)
//                            layout_any.minimumInteritemSpacing = 0
//                            layout_any.minimumLineSpacing = 20
//                            self.select_any_collection_view_ref.reloadData()
//                            self.select_any_collection_view_ref.collectionViewLayout = layout_any
                        }
                    }
                    self.get_master_size()
                }else{
                    self.home_master_collectionview_ref.reloadData()
                    self.select_any_tbl_view_ref.reloadData()
                }
            })
            }
        }
 
    }
    
    func get_master_size(){
     
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid).ref
            
            userRef.child("settings").child("engineerAdminAccess").observe(.value, with: { (snapshot) in
                if(snapshot.exists()){
                    if let data = snapshot.value as? NSDictionary{
                        if let currentPlan = data.value(forKey: "planType") as? String{
                            print(currentPlan)
                            if(currentPlan == "basic"){
                                self.getMasterDataUsed(totalSize: "1TB")
                            }else if(currentPlan == "unlimited"){
                                self.getMasterDataUsed(totalSize: "Unlimited")
                            }
                        }else{
                            self.getMasterDataUsed(totalSize: "5GB")
                        }
                    }else{
                        self.getMasterDataUsed(totalSize: "5GB")
                    }
                }else{
                    self.getMasterDataUsed(totalSize: "5GB")
                }
            })
        }
    }
    
    func getMasterDataUsed(totalSize : String){
        
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid).ref
            
            userRef.child("profile").child("storageUsed").observe(.value, with: { (snapshot) in
                if(snapshot.exists()){
                    if let data = snapshot.value as? NSDictionary{
                        if let currentSize = data.value(forKey: "masters") as? Int64{
                            let usedSize = ByteCountFormatter.string(fromByteCount: currentSize, countStyle: .file)
                            let masterSizeString = usedSize + " / " + totalSize
                            self.masterSizeLblRef.text = masterSizeString
                        }else{
                            self.masterSizeLblRef.text = ""
                        }
                    }else{
                        self.masterSizeLblRef.text = ""
                    }
                }else{
                    self.masterSizeLblRef.text = ""
                }
            })
        }
        
        
    }
    
    
    //________________________________ Get Project Data  ___________________________________
    
    func get_project_data()
    {
        if(search_text != "")
        {
            search_data()
        }
        else
        {
            myActivityIndicator.startAnimating()
            if let uid = Auth.auth().currentUser?.uid{
                let userRef = FirebaseManager.getRefference().child(uid).ref
                
                userRef.child("projects").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                    self.project_data.removeAll()
                    for snap in snapshot.children
                    {
                        let userSnap = snap as! DataSnapshot
                        let project_key = userSnap.key
                        let project_value = userSnap.value as! NSDictionary
                        var main_recording = ""
                        var project_name = ""
                        if let pname = project_value.value(forKey: "project_name") as? String{
                            project_name = pname
                        }
                        if let recording = project_value.value(forKey: "project_main_recording") as? String{
                            main_recording = recording
                        }
                        self.count_project_data(project_name: project_name, project_value: project_value, project_key: project_key, project_main_recording: main_recording)
                        self.last_node_of_project = project_key
                    }
                    self.project_view_layout()
                })
            }
        }
    }
    
    func project_view_layout(){
        self.project_data.reverse()
        self.home_project_collectionview_ref.reloadData()
        if(self.current_selected_type == "project"  && self.any_view_open_flag == true){
            self.select_any_tbl_view_ref.reloadData()
        }
        self.collection_view_layout()
        self.myActivityIndicator.stopAnimating()
    }
    
    func count_project_data(project_name : String , project_value : NSDictionary, project_key : String, project_main_recording: String)
    {
        var total_recordings = 0
        var total_lyrics = 0
        var downloadURL = ""
        if((project_value.value(forKey: "recordings") as? NSDictionary) != nil)
        {
            let record_data =  project_value.value(forKey: "recordings") as! NSDictionary
            let recording_key = record_data.allKeys as! [String]
            for key in recording_key
            {
                let rec_dict = record_data.value(forKey: key) as? NSDictionary
                if (rec_dict?.value(forKey: "name") as? String) != nil
                {
                    total_recordings = total_recordings + 1
                    if(rec_dict?.value(forKey: "tid") as? String == project_main_recording){
                        if let myurl = rec_dict?.value(forKey: "downloadURL") as? String{
                            downloadURL = myurl
                        }else{
                            downloadURL = ""
                        }
                    }
                }
            }
        }
        
        if((project_value.value(forKey: "lyrics") as? NSDictionary) != nil)
        {
            let lyrics_data =  project_value.value(forKey: "lyrics") as! NSDictionary
            let lyrics_keys = lyrics_data.allKeys as! [String]
            for key in lyrics_keys
            {
                let lyrics_dict = lyrics_data.value(forKey: key) as? NSDictionary
                if (lyrics_dict?.value(forKey: "desc") as? String) != nil
                {
                    total_lyrics = total_lyrics + 1
                }
            }
        }
        
        let all_total = total_recordings + total_lyrics
        let sdesc = String(all_total) + " items"
        let mydata = HomeData(type: "project", myId: project_key, nm: project_name, my_img: "home_project.png", sdesc: sdesc, local_file: true, download_url: downloadURL)
        self.project_data.append(mydata)
    }
    
    //________________________________ Get copy to tully data  ___________________________________
    
    
    func get_files_data()
    {
        self.HomeFileData.removeAll()
        var HomeFileData2 = [HomeFilesData]()
        get_from_search = false
        
        if(search_text != ""){
            search_data()
        }
        else
        {
            if let uid = Auth.auth().currentUser?.uid{
                let userRef = FirebaseManager.getRefference().child(uid).ref
                userRef.child("beats").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists(){
                        
                        for snap in snapshot.children
                        {
                            let userSnap = snap as! DataSnapshot
                            let rec_key = userSnap.key
                            let rec_dict = userSnap.value as? [String : AnyObject]
                            let name = rec_dict?["title"] as! String
                            let tid = rec_dict?["filename"] as! String
                            let byte_size = rec_dict?["size"] as! Int64
                            var myurl = rec_dict?["downloadURL"] as? String
                            
                            if(myurl == nil)
                            {
                                myurl = ""
                            }
                            
                            var bpm = 0
                            var key = ""
                            
                            if let audioBpm = rec_dict?["bpm"] as? Int{
                                bpm = audioBpm
                            }
                            if let audioKey = rec_dict?["key"] as? String{
                                key = audioKey
                            }
                            
                            let kb_size = ByteCountFormatter.string(fromByteCount: byte_size, countStyle: .file)
                            
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let mydir = documentsDirectory.appendingPathComponent("purchase/" + tid)
                            var have_local_file = false
                            
                            if(FileManager.default.fileExists(atPath: mydir.path))
                            {
                                have_local_file = true
                                do
                                {
                                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: mydir.path)
                                    let creationDate = fileAttributes[FileAttributeKey.creationDate] as! Date
                                    let currentDate = Date()
                                    let diff = currentDate.interval(ofComponent: .day, fromDate: creationDate)
                                    
                                    if( diff > 29 ){
                                        do{
                                            try FileManager.default.removeItem(atPath: mydir.path)
                                        }catch let error as NSError{
                                            self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
                                        }
                                    }
                                } catch let error {
                                    print("Error getting file modification attribute date: \(error.localizedDescription)")
                                }
                            }
                            
                            let temp_audio_data = HomeFilesData(uid : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, type: "purchase", bpm: bpm, key: key)
                            HomeFileData2.append(temp_audio_data)
                        }
                        self.get_copy_to_tully_files_data(HomeFileData2: HomeFileData2)
                    }else{
                        self.get_copy_to_tully_files_data(HomeFileData2: HomeFileData2)
                    }
                })
            }
        }
    }
    
    func get_copy_to_tully_files_data(HomeFileData2 : [HomeFilesData])
    {
        var HomeFileData1 = [HomeFilesData]()
        
        var free_beat : HomeFilesData? = nil
        if(search_text != "")
        {
            search_data()
        }
        else
        {
        myActivityIndicator.startAnimating()
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid).ref
            
            userRef.child("copytotully").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    HomeFileData1.removeAll()
                   
                    for snap in snapshot.children
                    {
                        let userSnap = snap as! DataSnapshot
                        let rec_key = userSnap.key
                        let rec_dict = userSnap.value as? [String : AnyObject]
                        let name = rec_dict?["title"] as! String
                        let tid = rec_dict?["filename"] as! String
                        
                        var byte_size : Int64 = 0
                        if let bsize = rec_dict?["size"] as? Int64{
                            byte_size = bsize
                        }
                        
                        var myurl = rec_dict?["downloadURL"] as? String
                        
                        if(myurl == nil){
                            myurl = ""
                        }
                        
                        var bpm = 0
                        var key = ""
                        
                        if let audioBpm = rec_dict?["bpm"] as? Int{
                            bpm = audioBpm
                        }
                        if let audioKey = rec_dict?["key"] as? String{
                            key = audioKey
                        }
                        
                        let kb_size = ByteCountFormatter.string(fromByteCount: byte_size, countStyle: .file)
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let mydir = documentsDirectory.appendingPathComponent("copytoTully/" + tid)
                        var have_local_file = false
                        
                        if(FileManager.default.fileExists(atPath: mydir.path))
                        {
                            have_local_file = true
                            do
                            {
                                let fileAttributes = try FileManager.default.attributesOfItem(atPath: mydir.path)
                                let creationDate = fileAttributes[FileAttributeKey.creationDate] as! Date
                                let currentDate = Date()
                                let diff = currentDate.interval(ofComponent: .day, fromDate: creationDate)
                                
                                if( diff > 29 ){
                                    do{
                                        try FileManager.default.removeItem(atPath: mydir.path)
                                    }catch let error as NSError{
                                        self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
                                    }
                                }
                            } catch let error {
                                print("Error getting file modification attribute date: \(error.localizedDescription)")
                            }
                        }
                        
                        if(self.search_text != "")
                        {
                            if name.lowercased().range(of: self.search_text) != nil
                            {
                                if(rec_key == "-L1111aaaaaaaaaaaaaa"){
                                    free_beat = HomeFilesData(uid : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, type: "freebeat", bpm: bpm, key: key)
                                }else{
                                    let temp_audio_data = HomeFilesData(uid : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, type: "copytotully", bpm: bpm, key: key)
                                    HomeFileData1.append(temp_audio_data)
                                }
                            }
                        }
                        else
                        {
                            if(rec_key == "-L1111aaaaaaaaaaaaaa"){
                                free_beat = HomeFilesData(uid : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, type: "freebeat", bpm: bpm, key: key)
                            }else{
                                let temp_audio_data = HomeFilesData(uid : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, type: "copytotully", bpm: bpm, key: key)
                                HomeFileData1.append(temp_audio_data)
                            }
                        }
                    }
                    
                    self.HomeFileData.removeAll()
                    
                    for data in HomeFileData2{
                        self.HomeFileData.append(data)
                    }
                    
                    for data in HomeFileData1{
                        self.HomeFileData.append(data)
                    }
                    
                }else{
                    self.HomeFileData.removeAll()
                    
                    for data in HomeFileData2{
                        self.HomeFileData.append(data)
                    }
                    
                    for data in HomeFileData1{
                        self.HomeFileData.append(data)
                    }
                }
                
                
                
                if(self.HomeFileData.count >= 0)
                {
                    
                    let myArrayOfTuples = self.HomeFileData.sorted{
                        guard let d1 = $0.uid, let d2 = $1.uid else { return false }
                        return d1 < d2
                    }
                    self.HomeFileData = myArrayOfTuples
                    
                    if(free_beat != nil){
                        self.HomeFileData.append(free_beat!)
                    }
                    
                    let temp_audio_data = HomeFilesData(uid : "tully", audio_url: URL(string: "http://tullyconnect.com")!, audio_name: "Getting Started", audio_size: "Video", downloadURL : "", local_file: false, tid: "", type: "video", bpm: 0, key: "")
                    self.HomeFileData.append(temp_audio_data)
                    
                    self.HomeFileData.reverse()
                    
                    if(self.current_selected_type == "file"  && self.any_view_open_flag == true){
                        self.select_any_tbl_view_ref.reloadData()
                    }else{
                        let layout_file : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                        layout_file.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                        let file_width = self.home_file_collectionview_ref.frame.width
                        layout_file.scrollDirection = UICollectionViewScrollDirection.vertical
                        layout_file.itemSize = CGSize(width: file_width/3.7, height: 82)
                        layout_file.minimumInteritemSpacing = 0
                        layout_file.minimumLineSpacing = 20
                        self.home_file_collectionview_ref.reloadData()
                        self.home_file_collectionview_ref.collectionViewLayout = layout_file
                        let new_height = CGFloat(((self.HomeFileData.count/3) * 102))
                        let scroll_height = ((CGFloat(self.have_file_view_height) + new_height) - 50)
                        //let scroll_height = ((CGFloat(self.have_file_view_height) + new_height) - 50 - 137)
                        self.height_constraint_of_have_file_view.constant = scroll_height
                    }
                    self.myActivityIndicator.stopAnimating()
                }else{
                    self.myActivityIndicator.stopAnimating()
                }
                
            })
            }
        }
    }
    
    //________________________________ Get All btn click  ___________________________________
    
    func btn_get_all_click()
    {
        selected_file_tab = true
        btn_all_click()
    }
    
    func btn_all_click()
    {
        
            self.display_all_data_flag = true
            self.project_data.removeAll()
            self.master_data.removeAll()
            self.HomeFileData.removeAll()
            self.get_master_data()
            self.get_project_data()
            self.get_files_data()
        
        
    }
    
    //________________________________ File btn click  ___________________________________
    
    func btn_files_click()
    {
        selected_file_tab = true
        if(display_all_data_flag){
            display_all_data_flag = false
        }
        self.HomeFileData.removeAll()
        get_files_data()
    }
    
    //________________________________ Project btn click  ___________________________________
    
    func btn_projects_click()
    {
        selected_file_tab = false
        if(display_all_data_flag){
            display_all_data_flag = false
        }
        self.project_data.removeAll()
        get_project_data()
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        self.current_selected_index = editActionsForRowAt.row
        let rename = UITableViewRowAction(style: .normal, title: "") { action, index in
            
            self.rename_project_file_master()
            
        }
        rename.setIcon(iconImage: UIImage(named: "rename")!, backColor: UIColor.white, cellHeight: 74.0, action_title: "rename", ylblpos: 6)
        
        let share = UITableViewRowAction(style: .normal, title: "") { action, index in
            self.share_project_file()
        }
        share.setIcon(iconImage: UIImage(named: "upload")!, backColor: UIColor.white, cellHeight: 74.0, action_title: "share", ylblpos: 6)
        
        let delete = UITableViewRowAction(style: .normal, title: "") { action, index in
            self.delete_project_file_btn_click()
        }
        delete.setIcon(iconImage: UIImage(named: "garbage")!, backColor: UIColor.white, cellHeight: 74.0, action_title: "garbage", ylblpos: 6)
        //delete.backgroundColor = UIColor(patternImage: UIImage(named: "garbage")!)
        
        return [delete, share, rename]
    }
    
    
    //_______ TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(current_selected_type == "master"){
            self.add_engineer_request.alpha = 0.0
            let total = master_data.count
            if(total == 0){
                totalMasterDropdownZero()
                self.add_engineer_request_tbl.alpha = 0.0
                
            }else{
                self.add_engineer_request_tbl.alpha = 0.0
            }
            return total
        }else if(current_selected_type == "project"){
            self.add_engineer_request_tbl.alpha = 0.0
            self.homeMasterEngineerInfoVC.alpha = 0.0
            return project_data.count
        }else{
            self.add_engineer_request_tbl.alpha = 0.0
            self.homeMasterEngineerInfoVC.alpha = 0.0
            return HomeFileData.count
        }
    }
    
    func totalMasterDropdownZero(){
        EngineerInfoDisplayVC.checkMasterDataExists().then { (found) in
            if(found){
                self.openEngineerInSelfVC()
                //Dont push this get in this view
            }else{
                if let display = UserDefaults.standard.value(forKey: MyConstants.tEngInfoHomeDropdown) as? Bool{
                    if(display){
                        self.openEngineerInSelfVC()
                    }else{
                        UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoHomeDropdown)
                        self.openEngineerInfoDisplayVC()
                    }
                }else{
                    UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoHomeDropdown)
                    self.openEngineerInfoDisplayVC()
                }
            }
            }.catch { (err) in
                MyConstants.normal_display_alert(msg_title: err.localizedDescription, msg_desc: "", action_title: "Ok", myVC: self)
        }
    }
    
    func openEngineerInSelfVC(){
        let sb = UIStoryboard(name: "engineer", bundle: nil)
        let child_view = sb.instantiateViewController(withIdentifier: "invite_engineer_sid") as! InviteEngineerVC
        child_view.comeAsChildView = true
        self.addChildViewController(child_view)
        child_view.view.frame = self.view.frame
        self.homeMasterEngineerInfoVC.addSubview(child_view.view)
        self.homeMasterEngineerInfoVC.alpha = 1.0
        child_view.didMove(toParentViewController: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(current_selected_type == "master"){
            let current_data = master_data[indexPath.row]
            
            let myCell = tableView.dequeueReusableCell(withIdentifier: "HomeAnyTV_Cell", for: indexPath) as! HomeAnyTVCell
            
            if(current_data.type == "folder"){
                //myCell.img_width_constraint_ref.constant = CGFloat(width_of_img)
                //myCell.img_height_constraint_ref.constant = CGFloat(width_of_img)
                myCell.file_img_ref.image = UIImage(named: "master-folder.pdf")
                myCell.file_desc_lbl_ref.text = String(current_data.count!) + " items"
            }else{
                //myCell.img_width_constraint_ref.constant = CGFloat(width_of_img - 15)
                //myCell.img_height_constraint_ref.constant = CGFloat(width_of_img - 10)
                myCell.file_img_ref.image = UIImage(named: "engineerFile.pdf")
                myCell.file_desc_lbl_ref.text = String(current_data.count!) + " KB"
            }
            
            myCell.file_name_lbl_ref.text = current_data.name?.removingPercentEncoding
            
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotiationMaster(press:)))
            longPressGestureRecognizer.minimumPressDuration = 0.5
            myCell.addGestureRecognizer(longPressGestureRecognizer)
            return myCell
            
        }else if(current_selected_type == "project"){
            let current_data = project_data[indexPath.row]
            let myCell = tableView.dequeueReusableCell(withIdentifier: "HomeAnyTV_Cell", for: indexPath) as! HomeAnyTVCell
            // myCell.img_width_constraint_ref.constant = CGFloat(width_of_img)
            // myCell.img_height_constraint_ref.constant = CGFloat(width_of_img)
            myCell.file_img_ref.image = UIImage(named: "home_project.pdf")
            myCell.file_name_lbl_ref.text = current_data.nm?.removingPercentEncoding
            myCell.file_desc_lbl_ref.text = current_data.sdesc
            
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotiationProject(press:)))
            longPressGestureRecognizer.minimumPressDuration = 0.5
            myCell.addGestureRecognizer(longPressGestureRecognizer)
            return myCell
        }else{
            //if(HomeFileData.count < indexPath.row ){
            let current_data = HomeFileData[indexPath.row]
            let myCell = tableView.dequeueReusableCell(withIdentifier: "HomeAnyTV_Cell", for: indexPath) as! HomeAnyTVCell
            
            myCell.file_name_lbl_ref.text = current_data.audio_name?.removingPercentEncoding
            myCell.file_desc_lbl_ref.text = current_data.audio_size
            
            if(current_data.type == "copytotully"){
                myCell.file_img_ref.image = UIImage(named: "home_audio_file.pdf")
            }else if(current_data.type == "purchase"){
                myCell.file_img_ref.image = UIImage(named: "marketplace_file.pdf")
            }else if(current_data.type == "freebeat"){
                myCell.file_img_ref.image = UIImage(named: "marketplace_file.pdf")
            }else{
                myCell.file_img_ref.image = UIImage(named: "marketplace_file.pdf")
            }
            
            if(current_data.type != "video"){
                let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotiationFile(press:)))
                longPressGestureRecognizer.minimumPressDuration = 0.5
                myCell.addGestureRecognizer(longPressGestureRecognizer)
            }
            
            return myCell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(current_selected_type == "master"){
            let current_data = master_data[indexPath.row]
    
            if current_data.type == "folder"{
                let vc : MasterDataDisplayVC = UIStoryboard(name: "master", bundle: nil).instantiateViewController(withIdentifier: "master_data_vc_sid") as! MasterDataDisplayVC
                vc.parentID = current_data.id!
                vc.parentCount = current_data.count!
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                
                var master_file_data = [MasterData]()
                var selected_file = 0
                
                for  i in 0..<master_data.count{
                    if(master_data[i].type == "file"){
                        master_file_data.append(master_data[i])
                    }
                    if(i == indexPath.row){
                        selected_file = (master_file_data.count - 1)
                    }
                }
                
                let vc : MasterPlayVC = UIStoryboard(name: "master", bundle: nil).instantiateViewController(withIdentifier: "masterplayvc_sid") as! MasterPlayVC
                
                vc.audioArray = master_file_data
                vc.selected_index = selected_file
                vc.folder_id = master_file_data[selected_file].parent_id!
                vc.get_lyrics_text = master_file_data[selected_file].lyrics!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            
            
            
            
        }else if(current_selected_type == "project"){
            let current_data = project_data[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "home_project_sid") as! HomeProjectVC
            vc.current_project_id = current_data.myId!
            vc.current_project_nm = current_data.nm!
            vc.current_project_download_url = current_data.download_url!
            vc.come_from_push = true
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            if(HomeFileData[indexPath.row].uid == "tully"){
                Mixpanel.mainInstance().track(event: "Getting started")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoTutorialVC_sid") as! VideoTutorialVC
                self.present(vc, animated: true, completion: nil)
            }else{
                if(self.HomeFileData[indexPath.row].uid == "-L1111aaaaaaaaaaaaaa"){
                    Mixpanel.mainInstance().track(event: "Free beat")
                }
                let vc : SharedAudioVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SharedAudioSid") as! SharedAudioVC
                //var mydata = self.HomeFileData
                
                var mydata = [playData]()
                
                for item in HomeFileData{
                    
                    let tmp = playData(audio_key: item.uid!, audio_url: item.audio_url!, audio_name: item.audio_name!, audio_size: item.audio_size!, downloadURL: item.downloadURL!, local_file: item.local_file!, tid: item.tid, bpm: item.bpm, key: item.key)
                    
                    mydata.append(tmp)
                }
                
                mydata.remove(at: 0)
                //let myIndex = mydata.count - (indexPath.row)
                vc.audioArray = mydata
                vc.selected_index = indexPath.row - 1
                vc.come_as_present = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //________________________________ Collection View Delegate  ___________________________________
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == home_master_collectionview_ref{
            let total = master_data.count
            if(total == 0){
                if(!get_from_search){
                    self.add_engineer_request_tbl.alpha = 1.0
                }else{
                    self.add_engineer_request_tbl.alpha = 0.0
                }
            }else{
                self.add_engineer_request_tbl.alpha = 0.0
            }
            return total
           
        }else if collectionView == home_project_collectionview_ref{
            return project_data.count
        }else{
            return HomeFileData.count
        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if(width_of_img > 50){
            width_of_img = 50
        }
        if collectionView == home_master_collectionview_ref{
            let current_data = master_data[indexPath.row]
            let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_master_cvcell", for: indexPath) as! HomeMasterCVCell
            myCell.title_lbl_ref.text = current_data.name?.removingPercentEncoding
            
            if(current_data.type == "folder"){
                myCell.img_width_constraint_ref.constant = CGFloat(width_of_img)
                myCell.img_height_constraint_ref.constant = CGFloat(width_of_img)
                myCell.home_img_ref.image = UIImage(named: "master-folder.pdf")
                myCell.desc_lbl_ref.text = String(current_data.count!) + " items"
            }else{
                myCell.img_width_constraint_ref.constant = CGFloat(width_of_img - 15)
                myCell.img_height_constraint_ref.constant = CGFloat(width_of_img - 10)
                myCell.home_img_ref.image = UIImage(named: "engineerFile.pdf")
                myCell.desc_lbl_ref.text = String(current_data.count!) + " KB"
            }
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotiationMaster(press:)))
            longPressGestureRecognizer.minimumPressDuration = 0.5
            myCell.addGestureRecognizer(longPressGestureRecognizer)
            return myCell
        }
        else if collectionView == home_project_collectionview_ref{
            let current_data = project_data[indexPath.row]
            let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_project_cvcell", for: indexPath) as! HomeProjectCVCell
            myCell.title_lbl_ref.text = current_data.nm?.removingPercentEncoding
            myCell.desc_lbl_ref.text = current_data.sdesc
            
            myCell.img_width_constraint_ref.constant = CGFloat(width_of_img)
            myCell.img_height_constraint_ref.constant = CGFloat(width_of_img)
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotiationProject(press:)))
            longPressGestureRecognizer.minimumPressDuration = 0.5
            myCell.addGestureRecognizer(longPressGestureRecognizer)
            return myCell
        }else{
            
            let current_data = HomeFileData[indexPath.row]
            let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_file_cvcell", for: indexPath) as! HomeFileCVCell
            
            myCell.title_lbl_ref.text = current_data.audio_name?.removingPercentEncoding
            myCell.desc_lbl_ref.text = current_data.audio_size
            
            myCell.img_width_constraint_ref.constant = CGFloat(width_of_img - 15)
            myCell.img_height_constraint_ref.constant = CGFloat(width_of_img - 10)
            
            if(current_data.type == "copytotully"){
                myCell.file_img_ref.image = UIImage(named: "home_audio_file.pdf")
            }else if(current_data.type == "purchase"){
                myCell.file_img_ref.image = UIImage(named: "marketplace_file.pdf")
            }else if(current_data.type == "freebeat"){
                myCell.file_img_ref.image = UIImage(named: "marketplace_file.pdf")
            }else{
                myCell.file_img_ref.image = UIImage(named: "marketplace_file.pdf")
            }
            
            if(current_data.type != "video"){
                let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotiationFile(press:)))
                longPressGestureRecognizer.minimumPressDuration = 0.5
                myCell.addGestureRecognizer(longPressGestureRecognizer)
            }
            
            return myCell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        cell.layer.transform = CATransform3DMakeScale(0.5,0.5,0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }, completion: nil)
    }
    
    func addAnnotiationMaster(press : UILongPressGestureRecognizer)
    {

        var indexPath : IndexPath? = nil
        
        if(select_any_tbl_view_ref.alpha == 1.0){
            
            let touchPoint = press.location(in: self.select_any_tbl_view_ref)
            indexPath = self.select_any_tbl_view_ref.indexPathForRow(at: touchPoint)
            
        }else{
            current_selected_type="master"
            let p = press.location(in: self.home_master_collectionview_ref)
             indexPath = self.home_master_collectionview_ref.indexPathForItem(at: p)
        }
        //let p = press.location(in: self.home_master_collectionview_ref)
        //let indexPath = self.home_master_collectionview_ref.indexPathForItem(at: p)
        
        if let index = indexPath {
            //_ = self.home_master_collectionview_ref.cellForItem(at: index)
            //self.current_selected_type = "master"
            self.current_selected_index = index.row
            let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in}
            alertController.addAction(cancelAction)
            let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
                self.rename_project_file_master()
            }
            alertController.addAction(renameAction)
            
            
            let shareAction = UIAlertAction(title: "Share", style: .default) { action in
                self.share_master()
            }
            alertController.addAction(shareAction)
            
            
            let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                
                let ac = UIAlertController(title: "Delete", message: "Are you sure you want to delete?", preferredStyle: .alert)
                let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
                let titleAttrString = NSMutableAttributedString(string: "Delete", attributes: attributes)
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
                    if(self.select_any_tbl_view_ref.alpha == 1.0){
                        let selectedData = self.master_data[self.current_selected_index!]
                        self.delete_master(myData: selectedData)
                        
                    }else{
                        let selectedData = self.master_data[self.current_selected_index!]
                        self.delete_master(myData: selectedData)
                        
                    }
                    
                })
                self.present(ac, animated: true)
                
            }
            alertController.addAction(destroyAction)
            
            
            self.present(alertController, animated: true) {}
        }
        else {
            display_alert(msg_title: "Not find", msg_desc: "Could not find index path", action_title: "OK")
        }
    }
    
    func addAnnotiationProject(press : UILongPressGestureRecognizer)
    {
        var indexPath : IndexPath? = nil
        if(select_any_tbl_view_ref.alpha == 1.0){
            let touchPoint = press.location(in: self.select_any_tbl_view_ref)
            indexPath = self.select_any_tbl_view_ref.indexPathForRow(at: touchPoint)
            
        }else{
            current_selected_type="project"
            let p = press.location(in: self.home_project_collectionview_ref)
            indexPath = self.home_project_collectionview_ref.indexPathForItem(at: p)
        }
        
        if let index = indexPath {
            //self.current_selected_type = "project"
            self.current_selected_index = index.row
            let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in}
            alertController.addAction(cancelAction)
            let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
                self.rename_project_file_master()
            }
            alertController.addAction(renameAction)
            
            let shareAction = UIAlertAction(title: "Share", style: .default) { action in
                self.share_project_file()
            }
            alertController.addAction(shareAction)
            
            let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                self.delete_project_file_btn_click()
            }
            alertController.addAction(destroyAction)
            self.present(alertController, animated: true) {}
        }
        else {
            display_alert(msg_title: "Not find", msg_desc: "Could not find index path", action_title: "OK")
        }
    }
    
    
    func addAnnotiationFile(press : UILongPressGestureRecognizer)
    {
        var indexPath : IndexPath? = nil
        if(select_any_tbl_view_ref.alpha == 1.0){
            let touchPoint = press.location(in: self.select_any_tbl_view_ref)
            indexPath = self.select_any_tbl_view_ref.indexPathForRow(at: touchPoint)
            
        }else{
            
            let p = press.location(in: self.home_file_collectionview_ref)
            indexPath = self.home_file_collectionview_ref.indexPathForItem(at: p)
        }
        
        if let index = indexPath {
            self.current_selected_index = index.row
            if(self.HomeFileData[current_selected_index!].type == "copytotully" || self.HomeFileData[current_selected_index!].type == "freebeat"){
                current_selected_type="file"
            }else{
                current_selected_type="purchase"
            }
            if(self.HomeFileData[current_selected_index!].uid != "tully"){
                let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in}
                alertController.addAction(cancelAction)
                let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
                    self.rename_project_file_master()
                }
                alertController.addAction(renameAction)
                
                let shareAction = UIAlertAction(title: "Share", style: .default) { action in
                    self.share_project_file()
                }
                alertController.addAction(shareAction)
                
                let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                    self.delete_project_file_btn_click()
                }
                alertController.addAction(destroyAction)
                self.present(alertController, animated: true) {}
            }
            
        }
        else {
            display_alert(msg_title: "Not find", msg_desc: "Could not find index path", action_title: "OK")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(collectionView == home_master_collectionview_ref){
            
            let current_data = master_data[indexPath.row]
            
            if current_data.type == "folder"{
                let vc : MasterDataDisplayVC = UIStoryboard(name: "master", bundle: nil).instantiateViewController(withIdentifier: "master_data_vc_sid") as! MasterDataDisplayVC
                vc.parentID = current_data.id!
                vc.parentCount = current_data.count!
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                
                var master_file_data = [MasterData]()
                var selected_file = 0
                
                for  i in 0..<master_data.count{
                    if(master_data[i].type == "file"){
                        master_file_data.append(master_data[i])
                    }
                    if(i == indexPath.row){
                        selected_file = (master_file_data.count - 1)
                    }
                }
                
                let vc : MasterPlayVC = UIStoryboard(name: "master", bundle: nil).instantiateViewController(withIdentifier: "masterplayvc_sid") as! MasterPlayVC
                
                vc.audioArray = master_file_data
                vc.selected_index = selected_file
                vc.folder_id = master_file_data[selected_file].parent_id!
                vc.get_lyrics_text = master_file_data[selected_file].lyrics!
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if(collectionView == home_project_collectionview_ref){
            
            let current_data = project_data[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "home_project_sid") as! HomeProjectVC
            vc.current_project_id = current_data.myId!
            vc.current_project_nm = current_data.nm!
            vc.current_project_download_url = current_data.download_url!
            vc.come_from_push = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if collectionView == home_file_collectionview_ref{
            if(HomeFileData[indexPath.row].uid == "tully"){
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoTutorialVC_sid") as! VideoTutorialVC
                self.present(vc, animated: true, completion: nil)
            }else{
                let vc : SharedAudioVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SharedAudioSid") as! SharedAudioVC
                vc.playSong = "fromPlaySong"
                var mydata = [playData]()
                
                for item in HomeFileData{

                    let tmp_data = playData(audio_key: item.uid!, audio_url: item.audio_url!, audio_name: item.audio_name!, audio_size: item.audio_size!, downloadURL: item.downloadURL!, local_file: item.local_file!, tid: item.tid, bpm: item.bpm, key: item.key)
                    
                    mydata.append(tmp_data)
                    
                }
                
                if(mydata.count > 0){
                    mydata.remove(at: 0)
                    vc.audioArray = mydata
                    vc.selected_index = indexPath.row - 1
                    vc.come_as_present = true
                    vc.comeFromHome = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    //MARK: - Delete, Rename, Share File / Project / Master
    
    func share_master(){
        if(current_selected_index != nil)
        {
            share_recording(myid: self.master_data[current_selected_index!].id!, type: self.master_data[current_selected_index!].type!)
        }
    }
    
    func delete_master(myData : MasterData){
        if (myData.type=="folder"){
            delete_master_data(parent_id: myData.id!, loadAction: false)
        }else{
            delete_master_file(myData: myData)
        }
    }
   
    func update_counter(){
        if let userId = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(userId).ref
            userRef.child("masters").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    let count = snapshot.childrenCount
                    userRef.child("profile/totalItems").setValue(count)
                    self.get_master_data()
                }else{
                    userRef.child("profile/totalItems").setValue(0)
                    self.get_master_data()
                }
            })
        }
    }
    
    func delete_master_data(parent_id : String, loadAction : Bool){
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid).ref
            userRef.child("masters").queryOrdered(byChild: "parent_id").queryEqual(toValue: parent_id).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    
                    for snap in snapshot.children{
                        let userSnap = snap as! DataSnapshot
                        let master_key = userSnap.key
                        let master_value = userSnap.value as! NSDictionary
                        
                        var name = ""
                        var type = ""
                        var count = 0
                        var downloadUrl = ""
                        var lyrics = ""
                        var fname = ""
                        
                        if let current_name = master_value.value(forKey: "name") as? String{
                            name = current_name
                        }
                        
                        if let current_type = master_value.value(forKey: "type") as? String{
                            type = current_type
                        }
                        
                        if let current_count = master_value.value(forKey: "count") as? Int{
                            count = current_count
                        }
                        
                        if let current_size = master_value.value(forKey: "size") as? Int64{
                            count = Int(current_size/1000)
                        }
                        
                        if let current_downloadUrl = master_value.value(forKey: "downloadURL") as? String{
                            downloadUrl = current_downloadUrl
                        }
                        
                        if let current_lyrics = master_value.value(forKey: "lyrics") as? String{
                            lyrics = current_lyrics
                        }
                        
                        if let current_fname = master_value.value(forKey: "filename") as? String{
                            fname = current_fname
                        }
                        
                        var bpm = 0
                        var key = ""
                        
                        if let audioBpm = master_value.value(forKey: "bpm") as? Int{
                            bpm = audioBpm
                        }
                        if let audioKey = master_value.value(forKey: "key") as? String{
                            key = audioKey
                        }
                        
                        let masterdata = MasterData(id: master_key, name: name, parent_id: parent_id, type: type, count: count, downloadUrl: downloadUrl, lyrics: lyrics, filename: fname, bpm: bpm, key: key)
                        
                        
                        if(type == "file"){
                            self.delete_master_file(myData: masterdata)
                        }
                        
                    }
                    snapshot.ref.child(parent_id).removeValue()
                    self.update_counter()
                    
                }
                else{
                    snapshot.ref.child(parent_id).removeValue()
                    self.update_counter()
                    
                }
            })
        }
    }
    
    func delete_master_file(myData : MasterData){
        let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let userid = Auth.auth().currentUser?.uid
        let destinationUrl = document_path.appendingPathComponent("masters/" + myData.filename)
        let userRef = FirebaseManager.getRefference().child(userid!).ref
        userRef.child("masters").child(myData.id!).removeValue()
        if FileManager.default.fileExists(atPath: (destinationUrl.path)){
            do{
                try FileManager.default.removeItem(atPath: destinationUrl.path)
            }catch let error as NSError{
                self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
            }
        }
        FirebaseManager.delete_master_recording_file(myfilename_tid: myData.filename)
        update_counter()
    }
    
    func rename_project_file_master()
    {
        if(current_selected_index != nil && current_selected_type != "")
        {
            let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rename_project_sid") as! RenameProjectFileVC
            child_view.renameCompleteProtocol = self
            
            if(current_selected_type == "master"){
                child_view.selected_nm = self.master_data[current_selected_index!].name!
                child_view.rename_file = false
                child_view.is_project = false
                child_view.is_purchase = false
                child_view.rename_master = true
                child_view.project_id = self.master_data[current_selected_index!].id!
            }else if(current_selected_type == "project"){
                child_view.selected_nm = self.project_data[current_selected_index!].nm!
                child_view.rename_file = false
                child_view.is_project = true
                child_view.is_purchase = false
                child_view.project_id = self.project_data[current_selected_index!].myId!
            }else{
                child_view.selected_nm = self.HomeFileData[current_selected_index!].audio_name!
                child_view.rename_file = true
                child_view.is_project = false
                if(self.HomeFileData[current_selected_index!].type == "purchase"){
                    child_view.is_purchase = true
                }else{
                    child_view.is_purchase = false
                }
                
                child_view.project_id = self.HomeFileData[current_selected_index!].uid!
            }
            self.addChildViewController(child_view)
            child_view.view.frame = self.view.frame
            self.view.addSubview(child_view.view)
            child_view.didMove(toParentViewController: self)
            btn_all_click()
        }
    }
    
    func share_project_file()
    {
        if(current_selected_type == "file" ){
            if (self.HomeFileData[current_selected_index!].downloadURL != ""){
                share_copytotully(audio_id: self.HomeFileData[current_selected_index!].uid!)
            }else{
                self.myActivityIndicator.stopAnimating()
                self.display_alert(msg_title: "Uploading file", msg_desc: "File is still uploading or broken.", action_title: "OK")
            }
        }else if(current_selected_type == "purchase"){
            let current_audio_id = self.HomeFileData[current_selected_index!].uid
            //share_recording(audio_name: current_audio_name, folder_name: "purchase", downloadURL: self.HomeFileData[current_selected_index!].downloadURL!)
            share_recording(myid: current_audio_id!, type: "purchase")
        }else if(current_selected_type == "project"){
            share_project()
        }
    }
    
    @IBAction func send_request_to_engineer(_ sender: UIButton) {
        
        EngineerInfoDisplayVC.checkMasterDataExists().then { (found) in
            if(found){
                self.openEngineerInviteVC()
            }else{
                if let display = UserDefaults.standard.value(forKey: MyConstants.tEngInfoHomeBtn) as? Bool{
                    if(display){
                        self.openEngineerInviteVC()
                    }else{
                        UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoHomeBtn)
                        self.openEngineerInfoDisplayVC()
                    }
                }else{
                    UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoHomeBtn)
                    self.openEngineerInfoDisplayVC()
                }
            }
        }.catch { (err) in
            MyConstants.normal_display_alert(msg_title: err.localizedDescription, msg_desc: "", action_title: "Ok", myVC: self)
        }
        
        
    }
    
    func openEngineerInviteVC(){
        let sb = UIStoryboard(name: "engineer", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "invite_engineer_sid") as! InviteEngineerVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openEngineerInfoDisplayVC(){
        let vc = UIStoryboard(name: "engineer", bundle: nil).instantiateViewController(withIdentifier: "EngineerInfoVC") as! EngineerInfoVC
        present(vc, animated: true, completion: nil)
    }
    
    func share_project()
    {
        if(current_selected_index != nil)
        {
            let current_project_id = self.project_data[current_selected_index!].myId!
            let myuserid = Auth.auth().currentUser?.uid
            if(myuserid != nil)
            {
                self.myActivityIndicator.startAnimating()
                if (self.project_data[current_selected_index!].download_url != ""){
                    self.share_checked_project(myuserid: myuserid!, current_project_id: current_project_id)
                }else{
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Uploading file", msg_desc: "File is still uploading or broken.", action_title: "OK")
                }
            }
        }
    }
    
    func share_checked_project(myuserid : String,current_project_id : String){
        let myuserid = Auth.auth().currentUser?.uid
        if(myuserid != nil){
            Mixpanel.mainInstance().track(event: "Sharing for Projects")
            let postString = "userid="+myuserid!+"&projectid="+current_project_id
            let myurlString = MyConstants.share_project
            let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareSecureDownloadVC_sid") as! ShareSecureDownloadVC
            child_view.shareSecureResponseProtocol = self
            child_view.shareString = postString
            child_view.urlString = myurlString
            present(child_view, animated: true, completion: nil)
        }
    }
    
    func share_copytotully(audio_id : String)
    {
        
        if let myuserid = Auth.auth().currentUser?.uid
        {
            let postString = "userid="+myuserid+"&ids="+audio_id
            let myurlString = MyConstants.share_copytotully
            Mixpanel.mainInstance().track(event: "Sharing for Files")
            if(audio_id == "-L1111aaaaaaaaaaaaaa"){
                
                ApiAuthentication.get_authentication_token().then({ (token) in
                    self.share_free_beat(token: token)
                }).catch({ (err) in
                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: err.localizedDescription, action_title: "Ok", myVC: self)
                })
                
                
            }else{
                
                let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareSecureDownloadVC_sid") as! ShareSecureDownloadVC
                child_view.shareSecureResponseProtocol = self
                child_view.shareString = postString
                child_view.urlString = myurlString
                present(child_view, animated: true, completion: nil)
            }
        }
    }
    
    func share_free_beat(token : String){
        if let myuserid = Auth.auth().currentUser?.uid{
            let postString = "userid="+myuserid+"&ids="+"-L1111aaaaaaaaaaaaaa"
            let myurlString = MyConstants.share_copytotully
            share_data(myString: postString, MyUrlString: myurlString, allowDownload_shareSecurity: true, token: token, type: "", expireTime: -1)
        }
        
    }
   
    func share_recording(myid : String,type : String)
    {
        let myuserid = Auth.auth().currentUser?.uid
        if(myuserid != nil)
        {
            let postString = "userid="+myuserid!+"&ids="+myid
            
            var myurlString = ""
            if(type == "purchase"){
                myurlString = MyConstants.share_purchase_recordings
            }else{
                myurlString = MyConstants.share_master_recordings
            }
            
            if(type != "folder"){
                Mixpanel.mainInstance().track(event: "Sharing for Files")
            }
            
            let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareSecureDownloadVC_sid") as! ShareSecureDownloadVC
            child_view.shareSecureResponseProtocol = self
            child_view.shareString = postString
            child_view.urlString = myurlString
            if(type != "purchase"){
                child_view.master_type = type
            }
            present(child_view, animated: true, completion: nil)
        }
    }
    
    //________________________________ Search  ___________________________________
    
    @IBAction func open_search_view(_ sender: Any) {
        search_view.isHidden = false
        top_view.isHidden = true
        search_bar_ref.becomeFirstResponder()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        self.search_text = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search_bar_ref.resignFirstResponder()
        search_view.isHidden = true
        top_view.isHidden = false
        searchBar.text = ""
        search_text = ""
        btn_all_click()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        if(search_text != ""){
            search_bar_ref.resignFirstResponder()
            search_data()
        }
    }
    
    func search_data()
    {
        search_master()
        self.myActivityIndicator.stopAnimating()
    }
    
    func search_master(){
        
        if(search_text != "")
        {
            self.master_data.removeAll()
            if let uid = Auth.auth().currentUser?.uid{
                let userRef = FirebaseManager.getRefference().child(uid).ref
                
                userRef.child("masters").queryOrdered(byChild: "name").queryStarting(atValue: search_text).queryEnding(atValue: search_text+MyVariables.search_last_char).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists(){
                        self.master_data.removeAll()
                        self.get_from_search = true
                        for snap in snapshot.children{
                            let userSnap = snap as! DataSnapshot
                            let master_key = userSnap.key
                            let master_value = userSnap.value as! NSDictionary
                            
                            var name = ""
                            var type = ""
                            var count = 0
                            var downloadUrl = ""
                            var lyrics = ""
                            var fname = ""
                            var parent_id = ""
                            
                            if let current_name = master_value.value(forKey: "name") as? String{
                                name = current_name
                            }
                            
                            if let current_type = master_value.value(forKey: "type") as? String{
                                type = current_type
                            }
                            
                            if let current_count = master_value.value(forKey: "count") as? Int{
                                count = current_count
                            }
                            
                            if let pid = master_value.value(forKey: "parent_id") as? String{
                                parent_id = pid
                            }
                            
                            if let current_size = master_value.value(forKey: "size") as? Int64{
                                count = Int(current_size/1000)
                            }
                            
                            if let current_downloadUrl = master_value.value(forKey: "downloadURL") as? String{
                                downloadUrl = current_downloadUrl
                            }
                            
                            if let current_lyrics = master_value.value(forKey: "lyrics") as? String{
                                lyrics = current_lyrics
                            }
                            
                            if let current_fname = master_value.value(forKey: "filename") as? String{
                                fname = current_fname
                            }
                            
                            if(parent_id == " 0"){
                                
                                
                                var bpm = 0
                                var key = ""
                                
                                if let audioBpm = master_value.value(forKey: "bpm") as? Int{
                                    bpm = audioBpm
                                }
                                if let audioKey = master_value.value(forKey: "key") as? String{
                                    key = audioKey
                                }
                                
                                
                                let masterdata = MasterData(id: master_key, name: name, parent_id: "0", type: type, count: count, downloadUrl: downloadUrl, lyrics: lyrics, filename: fname, bpm: bpm, key: key)
                                self.master_data.append(masterdata)
                            }
                            
                        }
                        self.search_project()
                    }else{
                        self.search_project()
                    }
                    
                })
                
            }
        }
    }
    
   
    func search_project(){
        if(search_text != "")
        {
            self.project_data.removeAll()
            
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            
            userRef.child("projects").queryOrdered(byChild: "project_name").queryStarting(atValue: search_text).queryEnding(atValue: search_text+MyVariables.search_last_char).observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.project_data.removeAll()
            
                if snapshot.exists(){
                    for snap in snapshot.children
                    {
                        var project_name = ""
                        var main_recording = ""
                        let userSnap = snap as! DataSnapshot
                        let project_key = userSnap.key
                        let project_value = userSnap.value as! NSDictionary
                        if let current_name = project_value.value(forKey: "project_name") as? String{
                            project_name = current_name
                        }
                        if let recording = project_value.value(forKey: "project_main_recording") as? String{
                            main_recording = recording
                        }
                        self.count_project_data(project_name: project_name, project_value: project_value, project_key: project_key, project_main_recording: main_recording)
                    }
                    self.project_data = self.project_data.reversed()
                        self.search_purchase_file()
                }
                else{
                    self.search_purchase_file()
                }
            })
        }
    }
    
    func search_purchase_file(){
        if(search_text != "")
        {
            self.HomeFileData.removeAll()
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            userRef.child("beats").queryOrdered(byChild: "title").queryStarting(atValue: search_text).queryEnding(atValue: search_text+MyVariables.search_last_char).observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.HomeFileData.removeAll()
                
                if(snapshot.exists()){
                    for snap in snapshot.children
                    {
                        var byte_size = 0
                        var tid = ""
                        let userSnap = snap as! DataSnapshot
                        let rec_key = userSnap.key
                        let rec_dict = userSnap.value as? [String : AnyObject]
                        var name = ""
                        
                        if let current_title = rec_dict?["title"] as? String{
                            name = current_title
                        }
                        if let current_name = rec_dict?["filename"] as? String{
                            tid = current_name
                        }
                        if let current_size = rec_dict?["size"] as? Int64{
                            byte_size = Int(current_size)
                        }
                        
                        var myurl = rec_dict?["downloadURL"] as? String
                        
                        if(myurl == nil)
                        {
                            myurl = ""
                        }
                        
                        var bpm = 0
                        var key = ""
                        
                        if let audioBpm = rec_dict?["bpm"] as? Int{
                            bpm = audioBpm
                        }
                        if let audioKey = rec_dict?["key"] as? String{
                            key = audioKey
                        }
                        
                        let kb_size = ByteCountFormatter.string(fromByteCount: Int64(byte_size), countStyle: .file)
                        
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let mydir = documentsDirectory.appendingPathComponent("copytoTully/" + tid)
                        var have_local_file = false
                        
                        if(FileManager.default.fileExists(atPath: mydir.path))
                        {
                            have_local_file = true
                            
                            do
                            {
                                let fileAttributes = try FileManager.default.attributesOfItem(atPath: mydir.path)
                                let creationDate = fileAttributes[FileAttributeKey.creationDate] as! Date
                                let currentDate = Date()
                                let diff = currentDate.interval(ofComponent: .day, fromDate: creationDate)
                                
                                if( diff > 29 )
                                {
                                    DispatchQueue.main.async
                                        {
                                            do
                                            {
                                                try FileManager.default.removeItem(atPath: mydir.path)
                                            }
                                            catch let error as NSError
                                            {
                                                self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
                                            }
                                    }
                                }
                                
                            } catch let error {
                                print("Error getting file modification attribute date: \(error.localizedDescription)")
                            }
                        }
                        
                        let temp_audio_data = HomeFilesData(uid : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, type: "purchase", bpm: bpm, key: key)
                        self.HomeFileData.append(temp_audio_data)
                        
                    }
                    self.search_file()
                }else{
                   self.search_file()
                }
                
            })
            
        }
    }
    
    func search_file(){
        if(search_text != "")
        {
            //self.HomeFileData.removeAll()
            
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            
            
            
            userRef.child("copytotully").queryOrdered(byChild: "title").queryStarting(atValue: search_text).queryEnding(atValue: search_text+MyVariables.search_last_char).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if(snapshot.exists()){
                    for snap in snapshot.children
                    {
                        var byte_size = 0
                        var tid = ""
                        let userSnap = snap as! DataSnapshot
                        let rec_key = userSnap.key
                        let rec_dict = userSnap.value as? [String : AnyObject]
                        var name = ""
                        
                        
                        if let current_title = rec_dict?["title"] as? String{
                            name = current_title
                        }
                        if let current_name = rec_dict?["filename"] as? String{
                            tid = current_name
                        }
                        if let current_size = rec_dict?["size"] as? Int64{
                            byte_size = Int(current_size)
                        }
                        
                        var myurl = rec_dict?["downloadURL"] as? String
                        
                        if(myurl == nil)
                        {
                            myurl = ""
                        }
                        
                        var bpm = 0
                        var key = ""
                        
                        if let audioBpm = rec_dict?["bpm"] as? Int{
                            bpm = audioBpm
                        }
                        if let audioKey = rec_dict?["key"] as? String{
                            key = audioKey
                        }
                        
                        let kb_size = ByteCountFormatter.string(fromByteCount: Int64(byte_size), countStyle: .file)
                        
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let mydir = documentsDirectory.appendingPathComponent("copytoTully/" + tid)
                        var have_local_file = false
                        
                        if(FileManager.default.fileExists(atPath: mydir.path))
                        {
                            have_local_file = true
                            
                            do
                            {
                                let fileAttributes = try FileManager.default.attributesOfItem(atPath: mydir.path)
                                let creationDate = fileAttributes[FileAttributeKey.creationDate] as! Date
                                let currentDate = Date()
                                let diff = currentDate.interval(ofComponent: .day, fromDate: creationDate)
                                
                                if( diff > 29 )
                                {
                                    DispatchQueue.main.async{
                                        do{
                                            try FileManager.default.removeItem(atPath: mydir.path)
                                        }catch let error as NSError{
                                            self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
                                        }
                                    }
                                }
                            } catch let error {
                                print("Error getting file modification attribute date: \(error.localizedDescription)")
                            }
                        }
                        
                        let temp_audio_data = HomeFilesData(uid : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, type: "copytotully", bpm: bpm, key: key)
                        self.HomeFileData.append(temp_audio_data)
                        
                    }
                    
                    self.home_file_collectionview_ref.reloadData()
                    if(self.current_selected_type == "file"){
                        self.select_any_tbl_view_ref.reloadData()
                    }
                    
                    self.home_master_collectionview_ref.reloadData()
                    self.home_project_collectionview_ref.reloadData()
                    self.home_file_collectionview_ref.reloadData()
                    if( self.any_view_open_flag == true){
                        self.select_any_tbl_view_ref.reloadData()
                    }
                    
                    if(self.HomeFileData.count == 0 && self.master_data.count == 0 && self.project_data.count == 0){
                        MyConstants.search_not_found_alert(myVC: self, searchRef: self.search_bar_ref)
                    }
                    
                }else{
                    self.home_master_collectionview_ref.reloadData()
                    self.home_project_collectionview_ref.reloadData()
                    self.home_file_collectionview_ref.reloadData()
                    if( self.any_view_open_flag == true){
                        self.select_any_tbl_view_ref.reloadData()
                    }
                    
                    if(self.HomeFileData.count == 0 && self.master_data.count == 0 && self.project_data.count == 0){
                        MyConstants.search_not_found_alert(myVC: self, searchRef: self.search_bar_ref)
                    }
                }
            })
        }
    }
    
    //________________________________ Delete Project  ___________________________________
    
    @IBAction func share_project(_ sender: Any) {
        share_project_file()
    }
    
    //________________________________ Share Project  ___________________________________
    
    @IBAction func delete_project(_ sender: Any) {
        delete_project_file_btn_click()
    }
    
    func delete_project_file_btn_click()
    {
        if(current_selected_index == nil)
        {
            display_alert(msg_title: "Required", msg_desc: "You must have to select Project / Recording.", action_title: "OK")
        }
        else
        {
            let myMsg = "Are you sure you want to delete?"
            let ac = UIAlertController(title: "Delete", message: myMsg, preferredStyle: .alert)
            let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
            let titleAttrString = NSMutableAttributedString(string: "Delete", attributes: attributes)
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
                if(self.current_selected_type == "file"){
                    self.remove_copy_to(audio_name: self.HomeFileData[self.current_selected_index!].tid, myId: self.HomeFileData[self.current_selected_index!].uid!)
                }else if(self.current_selected_type == "purchase"){
                    self.remove_purchase_beat(audio_name: self.HomeFileData[self.current_selected_index!].tid, myId: self.HomeFileData[self.current_selected_index!].uid!)
                }else if(self.current_selected_type == "project"){
                    self.get_project_recording(project_id: self.project_data[self.current_selected_index!].myId!)
                    self.remove_project(remove_project_id: self.project_data[self.current_selected_index!].myId!)
                }
                //self.btn_all_click()
            })
            present(ac, animated: true)
        }
    }
    
    //________________________________ Remove copy to tully files  ___________________________________
    
    func remove_copy_to(audio_name : String, myId : String)
    {
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("copytotully").child(myId).removeValue(completionBlock: { (error, database_ref) in
            if let error = error
            {
                self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        })
        
        FirebaseManager.delete_copyToTully_file(file_name: audio_name)
        
        let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir_Path = document_path.appendingPathComponent("copytoTully")
        let destinationUrl = dir_Path.appendingPathComponent(audio_name)
        if FileManager.default.fileExists(atPath: (destinationUrl.path)){
            do{
                try FileManager.default.removeItem(atPath: destinationUrl.path)
            }catch let error as NSError{
                self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
            }
        }
        self.btn_all_click()
        
    }
    
    //________________________________ Remove copy to tully files  ___________________________________
    
    func remove_purchase_beat(audio_name : String, myId : String)
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("beats").child(myId).removeValue(completionBlock: { (error, database_ref) in
            if let error = error
            {
                self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        })
        
        let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir_Path = document_path.appendingPathComponent("copytoTully")
        let destinationUrl = dir_Path.appendingPathComponent(audio_name)
        if FileManager.default.fileExists(atPath: (destinationUrl.path)){
            do{
                try FileManager.default.removeItem(atPath: destinationUrl.path)
            }catch let error as NSError{
                self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
            }
        }
        self.btn_all_click()
    }
    
    //________________________________ Get All Project Recording  ___________________________________
    
    func get_project_recording(project_id : String)
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children
            {
                let userSnap = snap as! DataSnapshot
                let project_key = userSnap.key
                let project_value = userSnap.value as! NSDictionary
                if(project_key == project_id)
                {
                    if((project_value.value(forKey: "recordings") as? NSDictionary) != nil)
                    {
                        let record_data =  project_value.value(forKey: "recordings") as! NSDictionary
                        let recording_key = record_data.allKeys as! [String]
                        for key in recording_key
                        {
                            let rec_dict = record_data.value(forKey: key) as? NSDictionary
                            if let tid = rec_dict?.value(forKey: "tid") as? String{
                                self.remove_recording(audio_nm: tid, current_project : project_id)
                            }
                            
                        }
                    }
                }
            }
        })
    }
    
    //________________________________ Remove Each Recording  ___________________________________
    
    func remove_recording(audio_nm : String, current_project : String)
    {
        let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir_Path = document_path.appendingPathComponent("recordings/projects")
        let audio_name = audio_nm
        let destinationUrl = dir_Path.appendingPathComponent(audio_name)
        FirebaseManager.delete_project_recording_file(myfilename_tid: audio_name, projectId: current_project)
        
        if FileManager.default.fileExists(atPath: (destinationUrl.path))
        {
            do
            {
                try FileManager.default.removeItem(atPath: destinationUrl.path)
            }
            catch let error as NSError
            {
                self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
            }
        }
        else
        {
            //display_alert(msg_title: "Recording not found", msg_desc: "Recorded file is missing.", action_title: "OK")
        }
        
    }
    
    //________________________________ Remove Project  ___________________________________
    
    func remove_project(remove_project_id : String)
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").child(remove_project_id).removeValue(completionBlock: { (error, database_ref) in
            if let error = error
            {
                self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                self.myActivityIndicator.stopAnimating()
            }
            else
            {
                self.myActivityIndicator.stopAnimating()
            }
        })
        self.btn_all_click()
    }
    
    func get_data_of_selected_tab()
    {
        if(display_all_data_flag)
        {
            self.btn_all_click()
        }
        else
        {
            self.project_data.removeAll()
            if(selected_file_tab)
            {
                get_files_data()
            }
            else
            {
                get_project_data()
            }
        }
    }
    
    //________________________________ Display Alert  ___________________________________
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
        let titleAttrString = NSMutableAttributedString(string: msg_title, attributes: attributes)
        ac.setValue(titleAttrString, forKey: "attributedTitle")
        ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            //_ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    //MARK: - Protocol Methods
    
    func renameDone(isSuccessful : Bool,newName : String)
    {
        btn_all_click()
    }
    
    func selectDone(newSelect: String) {
        down_up_img_ref.image = UIImage(named: "gray_down_arrow")
        current_selected_type = newSelect
        
        if(newSelect == "master"){
            lbl_all_ref.text = "Masters"
            any_view_open_flag = true
            select_any_tbl_view_ref.alpha = 1.0
            get_master_data()
            //select_any_collection_view_ref.reloadData()
        }else if(newSelect == "purchase"){
            lbl_all_ref.text = "Beats"
            any_view_open_flag = true
            select_any_tbl_view_ref.alpha = 1.0
            get_files_data()
            //select_any_collection_view_ref.reloadData()
        }else if(newSelect == "project"){
            lbl_all_ref.text = "Projects"
            any_view_open_flag = true
            select_any_tbl_view_ref.alpha = 1.0
            get_project_data()
            //select_any_collection_view_ref.reloadData()
        }else if(newSelect == "file"){
            lbl_all_ref.text = "Files"
            any_view_open_flag = true
            select_any_tbl_view_ref.alpha = 1.0
            get_files_data()
            //select_any_collection_view_ref.reloadData()
        }else{
            lbl_all_ref.text = "All"
            any_view_open_flag = false
            add_engineer_request_tbl.alpha = 0.0
            select_any_tbl_view_ref.alpha = 0.0
            display_master_view_ref.alpha = 1.0
            display_project_view_ref.alpha = 1.0
            display_file_view_ref.alpha = 1.0
            btn_all_click()
        }
    }
    
    //MARK: - Upload Remaining
    func upload_remaining()
    {
        if(Reachability.isConnectedToNetwork())
        {
            if let uid = Auth.auth().currentUser?.uid{
                let userRef = FirebaseManager.getRefference().child(uid).ref
                userRef.child("remaining_upload").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                    for snap in snapshot.children
                    {
                        let userSnap = snap as! DataSnapshot
                        let snap_key = userSnap.key
                        let remaining_data = userSnap.value as! NSDictionary
                        if(snap_key == "copytotully")
                        {
                            self.upload_remaining_copytotully(copytotully_data: remaining_data)
                        }
                        if(snap_key == "no_project")
                        {
                            if((remaining_data.value(forKey: "recordings") as? NSDictionary) != nil)
                            {
                                let record_data =  remaining_data.value(forKey: "recordings") as! NSDictionary
                                self.upload_remaining_noproject(noproject_data: record_data)
                            }
                        }
                        if(snap_key == "projects")
                        {
                            let recording_key = remaining_data.allKeys as! [String]
                            for key in recording_key
                            {
                                if((remaining_data.value(forKey: key) as? NSDictionary) != nil)
                                {
                                    let project_record_data =  remaining_data.value(forKey: key) as! NSDictionary
                                    if((project_record_data.value(forKey: "recordings") as? NSDictionary) != nil)
                                    {
                                        let record_data =  project_record_data.value(forKey: "recordings") as! NSDictionary
                                        self.upload_remaining_project(record_data: record_data,project_key : key)
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    func upload_remaining_project(record_data : NSDictionary, project_key : String)
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        let recording_key = record_data.allKeys as! [String]
        for key in recording_key
        {
            let rec_dict = record_data.value(forKey: key) as? NSDictionary
            let tid = rec_dict?.value(forKey: "tid") as! String
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let document_path = paths[0]
            let dir_Path = document_path.appendingPathComponent("recordings/projects")
            let mydir = dir_Path.appendingPathComponent(tid)
            
            if(FileManager.default.fileExists(atPath: mydir.path))
            {
                
                let cname = rec_dict?["name"] as! String
                let current_name = cname.removingPercentEncoding!
                let fileSize = rec_dict?["size"] as! Int64
                let project_data: [String: Any] = ["name": current_name, "tid": tid, "size":fileSize]
            userRef.child("projects").child(project_key).child("recordings").child(key).setValue(project_data, withCompletionBlock: { (error, database) in
                    if let error = error
                    {
                        print(error.localizedDescription)
                    }
                    else
                    {
                        FirebaseManager.sync_project_recording_file(myfilename_tid: tid, myfilePath: mydir, projectId: project_key, rec_id: key, delete_remaining: true)
                    
                    }
                })
            }
            else
            {
            userRef.child("projects").child(project_key).child("recordings").child(key).removeValue(completionBlock: { (error, database_ref) in
                    if error != nil
                    {
                        //self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                })
            userRef.child("remaining_upload").child("projects").child(project_key).child("recordings").child(key).removeValue(completionBlock: { (error, database_ref) in
                    if error != nil
                    {
                        //self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                })
            }
        }
       
    }
    
    
    func upload_remaining_noproject(noproject_data : NSDictionary)
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        let recording_key = noproject_data.allKeys as! [String]
        for key in recording_key
        {
            let rec_dict = noproject_data.value(forKey: key) as? NSDictionary
            let tid = rec_dict?.value(forKey: "tid") as! String
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let document_path = paths[0]
            let dir_Path = document_path.appendingPathComponent("recordings/no_project")
            let mydir = dir_Path.appendingPathComponent(tid)
            
            if(FileManager.default.fileExists(atPath: mydir.path))
            {
               
                
                    let cname = rec_dict?["name"] as! String
                    let current_name = cname.removingPercentEncoding!
                    let fileSize = rec_dict?["size"] as! Int64
                    let noproject_data: [String: Any] = ["name": current_name, "tid": tid, "size":fileSize]
                    
                   userRef.child("no_project").child("recordings").child(key).setValue(noproject_data, withCompletionBlock: { (error, database) in
                        if let error = error
                        {
                            print(error.localizedDescription)
                        }
                        else
                        {
                            FirebaseManager.sync_noproject_recording_file(myfilename_tid: tid, myfilePath: mydir, rec_id: key, delete_remaining: true)
                        
                        }
                    })
            }
            else
            {
               userRef.child("no_project").child("recordings").child(key).removeValue(completionBlock: { (error, database_ref) in
                if error != nil
                    {
                        //self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                })
              userRef.child("remaining_upload").child("no_project").child("recordings").child(key).removeValue(completionBlock: { (error, database_ref) in
                if error != nil
                    {
                        //self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                })
            }
        }
    }
    
    func upload_remaining_copytotully(copytotully_data : NSDictionary)
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        let recording_key = copytotully_data.allKeys as! [String]
        for key in recording_key
        {
            let rec_dict = copytotully_data.value(forKey: key) as? NSDictionary
            let filename = rec_dict?.value(forKey: "filename") as! String
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let mydir = documentsDirectory.appendingPathComponent("copytoTully/" + filename)
            
            if(FileManager.default.fileExists(atPath: mydir.path))
            {
                if let uploadAudioData = NSData(contentsOf: mydir.absoluteURL)
                {
                    
                    let cname = rec_dict?["title"] as! String
                    let current_name = cname.removingPercentEncoding!
                    let fileSize = rec_dict?["size"] as! Int64
                    let contentType = rec_dict?["mime"] as! String
                    let copytotully_data: [String: Any] = ["mime":contentType, "filename" : filename, "size" : fileSize, "title" : current_name]
                    let metadata1 = StorageMetadata()
                    metadata1.contentType = contentType
                    userRef.child("copytotully").child(key).setValue(copytotully_data, withCompletionBlock: { (error, database) in
                        if let error = error
                        {
                            print(error.localizedDescription)
                        }
                        else
                        {
                            FirebaseManager.sync_copytotully_file(metadata1: metadata1, uploadAudioData: uploadAudioData as Data, current_id: key, file_name: filename, delete_remaining: true)
                        
                        }
                    })
                }
            }else{
        userRef.child("remaining_upload").child("copytotully").child(key).removeValue(completionBlock: { (error, database_ref) in
                if error != nil
                    {
                        //self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                    
                })
            }
        }
    }
    
    
    @IBAction func master_scrollview_left_scroll_btn_click(_ sender: UIButton) {
        let collectionBounds = self.home_master_collectionview_ref.bounds
        let contentOffset = CGFloat(floor(self.home_master_collectionview_ref.contentOffset.x - collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
    }
    
    @IBAction func master_scrollview_right_scroll_btn_click(_ sender: UIButton) {
        let collectionBounds = self.home_master_collectionview_ref.bounds
        let contentOffset = CGFloat(floor(self.home_master_collectionview_ref.contentOffset.x + collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
    }
    
    func moveCollectionToFrame(contentOffset : CGFloat) {
        
        let frame: CGRect = CGRect(x : contentOffset ,y : self.home_master_collectionview_ref.contentOffset.y ,width : self.home_master_collectionview_ref.frame.width,height : self.home_master_collectionview_ref.frame.height)
        self.home_master_collectionview_ref.scrollRectToVisible(frame, animated: true)
    }
    
    // Engineer
    @IBAction func open_custom_dropdown(_ sender: UIButton) {
        lbl_all_ref.text = "All"
        let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeSelectVC_sid") as! HomeSelectVC
        child_view.Home_Selected_Protocol = self
        //child_view.count_master = purchase_data.count
        child_view.selected_mode = current_selected_type
        self.addChildViewController(child_view)
        child_view.view.frame = self.view.frame
        self.view.addSubview(child_view.view)
        down_up_img_ref.image = UIImage(named: "gray_up_arrow")
        child_view.didMove(toParentViewController: self)
    }
    
    //MARK: - Share Security
    
    func shareSecureResponse(allowDownload: Bool, postStringData: String, urlString: String, isCancel: Bool, token: String, type: String, expireTime: Int) {
        if(!isCancel){
            share_data(myString : postStringData, MyUrlString : urlString, allowDownload_shareSecurity : allowDownload, token: token, type: type, expireTime: expireTime)
        }
    }
    
    func share_data(myString : String, MyUrlString : String, allowDownload_shareSecurity : Bool, token : String, type : String, expireTime: Int){
        
        myActivityIndicator.startAnimating()
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
                    DispatchQueue.main.async {
                        self.myActivityIndicator.stopAnimating()
                        self.display_alert(msg_title: "Error", msg_desc: String(describing: response), action_title: "OK")
                    }
                    
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
    
    @IBAction func plusBtnClick(_ sender: UIButton) {
       
            EngineerInfoDisplayVC.checkMasterDataExists().then { (found) in
                if(found){
                    self.openEngineerInviteVC()
                }else{
                    if let display = UserDefaults.standard.value(forKey: MyConstants.tEngInfoHomePlusBtn) as? Bool{
                        if(display){
                            self.openEngineerInviteVC()
                        }else{
                            UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoHomePlusBtn)
                            self.openEngineerInfoDisplayVC()
                        }
                    }else{
                        UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoHomePlusBtn)
                        self.openEngineerInfoDisplayVC()
                    }
                }
                }.catch { (err) in
                    MyConstants.normal_display_alert(msg_title: err.localizedDescription, msg_desc: "", action_title: "Ok", myVC: self)
            }
        
        
    }
    
    
    @IBAction func open_engineer_request(_ sender: UIButton) {
        
        let child_view = UIStoryboard(name: "superpowered", bundle: nil).instantiateViewController(withIdentifier: "importWebWindowVC") as! importWebWindowVC
        child_view.mylink = MyConstants.home_import_link
        self.present(child_view, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension Date
{
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}


