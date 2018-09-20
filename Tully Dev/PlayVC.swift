//
//  PlayVC.swift
//  Tully Dev
//
//  Created by macbook on 5/24/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import UICircularProgressRing

class PlayVC: UIViewController , UITableViewDelegate , UITableViewDataSource , UIDocumentInteractionControllerDelegate, renameCompleteProtocol, shareSecureResponseProtocol
{
    
    
    //MARK: - Outlets
    
    
    @IBOutlet var top_view: UIView!
    @IBOutlet var search_bar_ref: UISearchBar!
    @IBOutlet var search_view: UIView!
    @IBOutlet var play_tbl_ref: UITableView!
    @IBOutlet var share_delete_view_ref: UIView!
    @IBOutlet var select_all_img_ref: UIImageView!
    @IBOutlet var top_contraint_tblview: NSLayoutConstraint!
    @IBOutlet var blank_vikew_ref: UIView!
    @IBOutlet var btn_share_ref: UIButton!
    @IBOutlet var img_share_ref: UIImageView!
    @IBOutlet var download_process_view_ref: UIView!
    @IBOutlet var processRing: UICircularProgressRingView!
    
    //MARK: - Variables
    
    var is_selected_all_lyrics = false
    var is_open_share_delet_view = false
    var display_select_view = true
    var checked_indexes = [Int]()
    var controller1 = UIDocumentInteractionController()
    var audio_data  = [playData]()
    var audio_data1  = [playData]()
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var selected_index : Int? = nil
    var startKey = ""
    var completion_flag = false
    var search_text = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if(Auth.auth().currentUser?.uid != nil)
        {
            if(MyVariables.come_from_home){
                blank_vikew_ref.alpha = 1.0
            }else{
                blank_vikew_ref.alpha = 0.0
            }
            self.navigationController?.isNavigationBarHidden = true
            myActivityIndicator.center = view.center
            self.view.addSubview(myActivityIndicator)
            create_design()
        }
        else
        {
            do{
                try Auth.auth().signOut()
                self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
            }catch let error as NSError{
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        MyVariables.currently_selected_tab = 1
        MyVariables.last_open_tab_for_inttercom_help = 1
        self.tabBarController?.selectedIndex = 1
        search_view.isHidden = true
        top_view.isHidden = false
        search_text = ""
        if(!MyVariables.play_tutorial){
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "h1TutorialSid") as! h1TutorialVC
            vc.tutorial_for = "play"
            self.present(vc, animated: true, completion: nil)
        }
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
        if(MyVariables.come_from_home){
            blank_vikew_ref.alpha = 1.0
            MyVariables.come_from_home = false
            let vc : SharedAudioVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SharedAudioSid") as! SharedAudioVC
            vc.come_as_present = true
            blank_vikew_ref.alpha = 0.0
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            MyVariables.come_from_home = false
            blank_vikew_ref.alpha = 0.0
        }
        clean_pagination()
        get_files()
    }
    
    //MARK: - Tableview Delegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let len = audio_data.count
        if(len == 0)
        {
            play_tbl_ref.isHidden = true
        }
        else
        {
            play_tbl_ref.isHidden = false
        }
        return len
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myData = audio_data[indexPath.row]        
        //let last_element = audio_data.count - 1
        
       //  .......... reached to last cell so load another data ..........
//        if(indexPath.row == last_element){
//            if(!completion_flag){
//                get_files()
//            }
//        }
        
        let myCell = tableView.dequeueReusableCell(withIdentifier: "play_tbl_cell_identifier", for: indexPath) as! play_tbl_cell
        myCell.select_btn_ref.tag = indexPath.row
        if(myData.audio_key == "-L1111aaaaaaaaaaaaaa"){
            myCell.file_img_ref.image = UIImage(named: "marketplace_file.pdf")
        }else{
            myCell.file_img_ref.image = UIImage(named: "home_audio_file.pdf")
        }
        if(display_select_view)
        {
            myCell.display_select_view()
        }
        else
        {
            myCell.display_checkbox_view()
        }
        
        if(is_selected_all_lyrics)
        {
            myCell.checkbox_checked()
        }
        else
        {
            myCell.checkbox_unchecked()
        }
        
        if(!is_selected_all_lyrics){
            if(checked_indexes.contains(indexPath.row)){
                myCell.checkbox_checked()
            }
        }
        
        
        myData.audio_name = myData.audio_name?.removingPercentEncoding
        myCell.fileName.text = myData.audio_name
        myCell.fileSize.text = myData.audio_size
        myCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        myCell.tapSelectAudio = { (cell) in
            let vc : SharedAudioVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SharedAudioSid") as! SharedAudioVC
            vc.audioArray = self.audio_data
            
            let selected_index : IndexPath = indexPath
            vc.selected_index = selected_index.row
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        myCell.tapCheckboxClick = { (cell) in
            if(self.checked_indexes.contains(myCell.select_btn_ref.tag))
            {
                if(self.is_selected_all_lyrics)
                {
                    self.select_all_img_ref.image = nil
                    self.select_all_img_ref.layer.borderColor = UIColor.gray.cgColor
                    self.select_all_img_ref.layer.borderWidth = 1.0
                    self.select_all_img_ref.layer.cornerRadius = 5.0
                    self.select_all_img_ref.layer.masksToBounds = true
                    self.is_selected_all_lyrics = false
                    let remove_index = self.checked_indexes.index(of: myCell.select_btn_ref.tag)
                    self.checked_indexes.remove(at: remove_index!)
                    myCell.checkbox_unchecked()
                }
                else
                {
                    let remove_index = self.checked_indexes.index(of: myCell.select_btn_ref.tag)
                    self.checked_indexes.remove(at: remove_index!)
                    myCell.checkbox_unchecked()
                }
                
                let selected_length = self.checked_indexes.count
                
                if(selected_length < 2)
                {
                    self.btn_share_ref.alpha = 1.0
                    self.img_share_ref.alpha = 1.0
                }
                else
                {
                    self.btn_share_ref.alpha = 0.0
                    self.img_share_ref.alpha = 0.0
                }
            }
            else
            {
                self.checked_indexes.append(myCell.select_btn_ref.tag)
                let selected_length = self.checked_indexes.count
                
                if(selected_length < 2)
                {
                    self.btn_share_ref.alpha = 1.0
                    self.img_share_ref.alpha = 1.0
                }
                else
                {
                    self.btn_share_ref.alpha = 0.0
                    self.img_share_ref.alpha = 0.0
                }
                
                let all_audio_length = self.audio_data.count
                if(selected_length == all_audio_length)
                {
                    self.select_all_img_ref.layer.borderWidth = 0.0
                    self.select_all_img_ref.image = UIImage(named: "gray_checkbox")!
                    self.select_all_img_ref.layer.cornerRadius = 5.0
                    self.select_all_img_ref.clipsToBounds = true
                    self.is_selected_all_lyrics = true
                    myCell.checkbox_checked()
                }
                else
                {
                    myCell.checkbox_checked()
                }
            }
        }
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotiationFile(press:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        myCell.addGestureRecognizer(longPressGestureRecognizer)
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }, completion: nil)
    }
    
    // Delete Share & Rename file
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let rename = UITableViewRowAction(style: .normal, title: "") { action, index in
            
            self.rename_file(current_selected_index : editActionsForRowAt.row)
        }
        rename.setIcon(iconImage: UIImage(named: "rename")!, backColor: UIColor.white, cellHeight: 74.0, action_title: "rename", ylblpos: 6)
        
        let share = UITableViewRowAction(style: .normal, title: "") { action, index in
            let current_audio_name = self.audio_data[editActionsForRowAt.row].audio_key
            self.share_copytotully(audio_ids: [current_audio_name])
        }
        share.setIcon(iconImage: UIImage(named: "upload")!, backColor: UIColor.white, cellHeight: 74.0, action_title: "share", ylblpos: 6)
        
        let delete = UITableViewRowAction(style: .normal, title: "") { action, index in
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
                
                self.remove_copy_to(audio_name: self.audio_data[editActionsForRowAt.row].tid, myId: self.audio_data[editActionsForRowAt.row].audio_key)
                
            })
            self.present(ac, animated: true)
        }
        delete.setIcon(iconImage: UIImage(named: "garbage")!, backColor: UIColor.white, cellHeight: 74.0, action_title: "garbage", ylblpos: 6)
        //delete.backgroundColor = UIColor(patternImage: UIImage(named: "garbage")!)
        
        return [delete, share, rename]
    }
    
    
    func addAnnotiationFile(press: UILongPressGestureRecognizer)
    {
        let touchPoint = press.location(in: self.play_tbl_ref)
        let indexPath = self.play_tbl_ref.indexPathForRow(at: touchPoint)
        if let index = indexPath
        {
            let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in}
            alertController.addAction(cancelAction)
            let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
                self.rename_file(current_selected_index : index.row)
            }
            alertController.addAction(renameAction)
            
            let shareAction = UIAlertAction(title: "Share", style: .default) { action in
                let current_audio_name = self.audio_data[index.row].audio_key
                self.share_copytotully(audio_ids: [current_audio_name])
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
                    
                    self.remove_copy_to(audio_name: self.audio_data[index.row].tid, myId: self.audio_data[index.row].audio_key)
                    
                })
                self.present(ac, animated: true)
            }
            alertController.addAction(destroyAction)
            self.present(alertController, animated: true) {}
        }
    }
        
    func rename_file(current_selected_index : Int)
    {
        let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rename_project_sid") as! RenameProjectFileVC
        child_view.renameCompleteProtocol = self
        child_view.selected_nm = self.audio_data[current_selected_index].audio_name!
        child_view.rename_file = true
        child_view.is_project = false
        child_view.project_id = self.audio_data[current_selected_index].audio_key
        self.addChildViewController(child_view)
        child_view.view.frame = self.view.frame
        self.view.addSubview(child_view.view)
        child_view.didMove(toParentViewController: self)
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
        clean_pagination()
        get_files()
    }
    
    //MARK: - Get Files
    
    func get_files()
    {
        var free_beat : playData? = nil
            myActivityIndicator.startAnimating()
            
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            userRef.child("copytotully").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.audio_data.removeAll()
                
                
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
                    
                    if(rec_key == "-L1111aaaaaaaaaaaaaa"){
                        free_beat = playData(audio_key : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, bpm: bpm, key: key)
                    }else{
                        let temp_audio_data = playData(audio_key : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, bpm: bpm, key: key)
                        
                        self.audio_data.append(temp_audio_data)
                    }
                }
                if(free_beat != nil){
                    self.audio_data.append(free_beat!)
                }
                
                self.audio_data = self.audio_data.reversed()
                self.play_tbl_ref.reloadData()
                self.myActivityIndicator.stopAnimating()
            })
        
    }
    
    func get_files1()
    {
        myActivityIndicator.startAnimating()
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        let orderbykey = userRef.child("copytotully").queryOrderedByKey()
        
        if(startKey == ""){
            orderbykey.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let children = snapshot.children.allObjects.first as? DataSnapshot else {return}
                self.startKey = children.key
                self.audio_data1.removeAll()
                self.audio_data.removeAll()
                for snap in snapshot.children{
                    let userSnap = snap as! DataSnapshot
                    let rec_key = userSnap.key
                    if(self.startKey != rec_key){
                        self.put_data_in_array(userSnap: userSnap)
                    }
                }
                self.audio_data1 = self.audio_data1.reversed()
                self.myActivityIndicator.stopAnimating()
                for i in self.audio_data1{
                    self.audio_data.append(i)
                }
                //UIView.transition(with: self.play_tbl_ref, duration: 1.0, options: .transitionCrossDissolve, animations: {self.play_tbl_ref.reloadData()}, completion: nil)
                self.play_tbl_ref.reloadData()
                
            })
        }else{
            orderbykey.queryEnding(atValue: startKey).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let children = snapshot.children.allObjects.first as? DataSnapshot else {return}
                if(children.key == self.startKey){
                    self.completion_flag = true
                }
                self.startKey = children.key
                self.audio_data1.removeAll()
                for snap in snapshot.children{
                    let userSnap = snap as! DataSnapshot
                    let rec_key = userSnap.key
                    if(self.startKey != rec_key || self.completion_flag == true){
                        self.put_data_in_array(userSnap: userSnap)
                    }
                }
                self.audio_data1 = self.audio_data1.reversed()
                self.myActivityIndicator.stopAnimating()
                for i in self.audio_data1{
                    self.audio_data.append(i)
                }
                self.play_tbl_ref.reloadData()
            })
        }
    }
    
    func put_data_in_array(userSnap : DataSnapshot){
        let rec_key = userSnap.key
        let rec_dict = userSnap.value as? [String : AnyObject]
        let name = rec_dict?["title"] as! String
        let tid = rec_dict?["filename"] as! String
        let byte_size = rec_dict?["size"] as! Int64
        var myurl = rec_dict?["downloadURL"] as? String
        var bpm = 0
        var key = ""
        
        if(myurl == nil){
            myurl = ""
        }
        
        if let audioBpm = rec_dict?["bpm"] as? Int{
            bpm = audioBpm
        }
        if let audioKey = rec_dict?["key"] as? String{
            key = audioKey
        }
        
        let kb_size = ByteCountFormatter.string(fromByteCount: byte_size, countStyle: .file)
//        var kb_size = String(byte_size/1000)
//        kb_size = kb_size + " KB"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let mydir = documentsDirectory.appendingPathComponent("copytoTully/" + tid)
        var have_local_file = false
        
        if(FileManager.default.fileExists(atPath: mydir.path)){
            have_local_file = true
        }
        
        let temp_audio_data = playData(audio_key : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, bpm: bpm, key: key)
        audio_data1.append(temp_audio_data)
    }
    
    func clean_pagination(){
        startKey = ""
        completion_flag = false
    }
    
    //________________________________ Manage Share - Delete view  ___________________________________
    
    @IBAction func open_share_delete_view(_ sender: Any) {
        manage_delete_share_view()
    }
    
    func manage_delete_share_view(){
        if(is_open_share_delet_view){
            share_delete_view_ref.alpha = 0.0
            top_contraint_tblview.constant = 0.0
            is_open_share_delet_view = false
            display_select_view = true
            self.play_tbl_ref.reloadData()
        }else{
            share_delete_view_ref.alpha = 1.0
            top_contraint_tblview.constant = 80.0
            is_open_share_delet_view = true
            display_select_view = false
            self.play_tbl_ref.reloadData()
        }
    }
    
    //________________________________ Select - Deselect Recordings   ___________________________________
    
    @IBAction func select_all_play_records(_ sender: Any) {
        if(is_selected_all_lyrics){
            deselect_all_recordings()
        }else{
            select_all_recordings()
        }
    }
    
    func select_all_recordings(){
        select_all_img_ref.layer.borderWidth = 0.0
        checked_indexes.removeAll()
        for i in 0..<audio_data.count{
            checked_indexes.append(i)
        }
        select_all_img_ref.image = UIImage(named: "gray_checkbox")!
        select_all_img_ref.layer.cornerRadius = 5.0
        select_all_img_ref.clipsToBounds = true
        is_selected_all_lyrics = true
        let selected_length = self.checked_indexes.count
        if(selected_length < 2)
        {
            self.btn_share_ref.alpha = 1.0
            self.img_share_ref.alpha = 1.0
        }
        else
        {
            self.btn_share_ref.alpha = 0.0
            self.img_share_ref.alpha = 0.0
        }
        self.play_tbl_ref.reloadData()
        
    }
    
    func deselect_all_recordings(){
        select_all_img_ref.image = nil
        select_all_img_ref.layer.borderColor = UIColor.gray.cgColor
        select_all_img_ref.layer.borderWidth = 1.0
        select_all_img_ref.layer.cornerRadius = 5.0
        select_all_img_ref.layer.masksToBounds = true
        is_selected_all_lyrics = false
        checked_indexes.removeAll()
        let selected_length = self.checked_indexes.count
        if(selected_length < 2)
        {
            self.btn_share_ref.alpha = 1.0
            self.img_share_ref.alpha = 1.0
        }
        else
        {
            self.btn_share_ref.alpha = 0.0
            self.img_share_ref.alpha = 0.0
        }
        self.play_tbl_ref.reloadData()
        
    }
    
    //________________________________ Share recording  ___________________________________

    @IBAction func share_play_record(_ sender: Any)
    {
        if(checked_indexes.count < 1){
            display_alert(msg_title: "Required", msg_desc: "You must have to select Recording.", action_title: "OK")
        }else{
            var copytotully_ids : [String] = []
            for i in 0..<audio_data.count
            {
                if(checked_indexes.contains(i))
                {
                    copytotully_ids.append(audio_data[i].audio_key)
                }
            }
            share_copytotully(audio_ids: copytotully_ids)
            self.deselect_all_recordings()
            self.manage_delete_share_view()
        }
    }
    
    //________________________________ Delete Recording  ___________________________________
    
    @IBAction func delete_play_record(_ sender: Any)
    {
        if(checked_indexes.count < 1){
            display_alert(msg_title: "Required", msg_desc: "You must have to select Recording.", action_title: "OK")
        }else{
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
                for i in 0..<self.audio_data.count{
                    if(self.checked_indexes.contains(i)){
                        self.remove_recording(selected_index : i)
                    }
                }
                self.deselect_all_recordings()
                self.manage_delete_share_view()
                self.clean_pagination()
                self.get_files()
            })
            present(ac, animated: true)
        }
    }
    
    func remove_recording(selected_index : Int){
        let recording_key = self.audio_data[selected_index].audio_key
        let destinationUrl = self.audio_data[selected_index].audio_url!
        let fileName = self.audio_data[selected_index].audio_name!
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("copytotully").child(recording_key).removeValue(completionBlock: { (error, database_ref) in
            if let error = error{
                self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }else{
                if FileManager.default.fileExists(atPath: (destinationUrl.path)){
                    do{
                        FirebaseManager.delete_copyToTully_file(file_name: fileName)
                        try FileManager.default.removeItem(atPath: destinationUrl.path)
                    }catch _ as NSError{}
                }
            }
        })
    }
    
    func renameDone(isSuccessful : Bool,newName : String){
        clean_pagination()
        get_files()
    }
    
    //________________________________ Custom Design  ___________________________________
    
    func create_design(){
        play_tbl_ref.tableFooterView = UIView()
        select_all_img_ref.layer.borderColor = UIColor.gray.cgColor
        select_all_img_ref.layer.borderWidth = 1.0
        select_all_img_ref.layer.cornerRadius = 5.0
        select_all_img_ref.layer.masksToBounds = true
    }
    
    //________________________________ Display Alert ___________________________________
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String){
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    //________________________________ Prepare Segue - for data passing  ___________________________________

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "open_play_record_in_play"){
            let vc : SharedAudioVC = segue.destination as! SharedAudioVC
            vc.audioArray = audio_data
            let selected_index : IndexPath = self.play_tbl_ref.indexPath(for: sender as! UITableViewCell)!
            vc.selected_index = selected_index.row   
        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
        //resetAllData()
        MyVariables.come_from_home = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.blank_vikew_ref.alpha = 0.0
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
    
    func resetAllData(){
        checked_indexes.removeAll()
        is_selected_all_lyrics = false
        if(is_open_share_delet_view){
            share_delete_view_ref.alpha = 0.0
            top_contraint_tblview.constant = 0.0
            is_open_share_delet_view = false
            display_select_view = true
        }
    }
    
    @IBAction func open_search_view(_ sender: UIButton) {
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
        get_files()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        if(search_text != ""){
            search_bar_ref.resignFirstResponder()
            search_data()
        }
    }
    
    func search_data()
    {
        var free_beat : playData? = nil
        myActivityIndicator.startAnimating()
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("copytotully").queryOrdered(byChild: "title").queryStarting(atValue: search_text).queryEnding(atValue: search_text+MyVariables.search_last_char).observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.audio_data.removeAll()
            
            
            for snap in snapshot.children
            {
                let userSnap = snap as! DataSnapshot
                let rec_key = userSnap.key
                let rec_dict = userSnap.value as? [String : AnyObject]
                
                var name = ""
                var tid = ""
                
                if let nm = rec_dict?["title"] as? String{
                    name = nm
                }
                
                if let title = rec_dict?["filename"] as? String{
                    tid = title
                }
                
               
                var byte_size : Int64 = 0
                //let byte_size = rec_dict?["size"] as? Int64
                if let size = rec_dict?["size"] as? Int64{
                    byte_size = size
                }
                var myurl = rec_dict?["downloadURL"] as? String
                
                if(myurl == nil)
                {
                    myurl = ""
                }

                let kb_size = ByteCountFormatter.string(fromByteCount: byte_size, countStyle: .file)
                var bpm = 0
                var key = ""
                
                if let audioBpm = rec_dict?["bpm"] as? Int{
                    bpm = audioBpm
                }
                if let audioKey = rec_dict?["key"] as? String{
                    key = audioKey
                }
                
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
                
                if(rec_key == "-L1111aaaaaaaaaaaaaa"){
                    free_beat = playData(audio_key : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, bpm: bpm, key: key)
                }else{
                    let temp_audio_data = playData(audio_key : rec_key, audio_url: mydir, audio_name: name, audio_size: kb_size, downloadURL : myurl!, local_file: have_local_file, tid: tid, bpm: bpm, key: key)
                    
                    self.audio_data.append(temp_audio_data)
                }
            }
            if(free_beat != nil){
                self.audio_data.append(free_beat!)
            }
            
            self.audio_data = self.audio_data.reversed()
            self.play_tbl_ref.reloadData()
            
            if(self.audio_data.count == 0){
                MyConstants.search_not_found_alert(myVC: self, searchRef: self.search_bar_ref)
            }
            
            self.myActivityIndicator.stopAnimating()
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
