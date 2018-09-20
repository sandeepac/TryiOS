//  RecordingListVC.swift
//  Tully Dev
//
//  Created by macbook on 5/23/17.
//  Copyright © 2017 Tully. All rights reserved.


import UIKit
import Firebase
import FirebaseDatabase
import AVFoundation
import UICircularProgressRing

//For merge Audio


class RecordingListVC: UIViewController , UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, UIDocumentInteractionControllerDelegate, ExpandabaleHeaderViewDelegate, renameCompleteProtocol, shareSecureResponseProtocol
{
    
    
    //________________________________ Outlets  ___________________________________

    @IBOutlet weak var recording_tab_img_ref: UIImageView!
    //@IBOutlet var no_lyrics_view_ref: UIView!
    @IBOutlet var no_recording_view_ref: UIView!
    @IBOutlet var search_view: UIView!
    @IBOutlet var top_view: UIView!
    @IBOutlet var search_bar_ref: UISearchBar!
    @IBOutlet var recording_tbl_ref: UITableView!
    @IBOutlet var select_all_img_ref: UIImageView!
    @IBOutlet var share_delete_view_ref: UIView!
    var controller1 = UIDocumentInteractionController()
    @IBOutlet var top_contraint_tblview: NSLayoutConstraint!
    var player = AVAudioPlayer()
    @IBOutlet var img_share_ref: UIImageView!
    @IBOutlet var btn_share_ref: UIButton!
    @IBOutlet var download_process_view_ref: UIView!
    @IBOutlet var processRing: UICircularProgressRingView!
    @IBOutlet weak var lyrics_tab_img_ref: UIImageView!
    //________________________________ Variables  ___________________________________
    
    var current_playing = false
    var audio_play = false
    var current_play_song_index = 0
    var initialization_flag = true
    var search_text = ""
    var is_open_share_delet_view = false
    var is_selected_all_recordings = false
    var display_select_view = true
    var checked_indexes = [[Int]]()
    var checked_section_indexes = [Int]()
    var come_from_project_data = false
    var sections = [section]()
    var project_name_for_section = ""
    var project_record_list = [recordingListData]()
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var online_play_flag = false
    var online_player : AVPlayer!
    var online_playerItem : AVPlayerItem!
    var total_section = 0
    var current_section = 0
    var selectIndexPath : IndexPath = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "lyricsTabSelected")
        fetch_data()
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        create_design()
        selectIndexPath = IndexPath(row: -1, section: -1)
        let nib = UINib(nibName: "ExpandabaleHeaderView", bundle: nil)
        recording_tbl_ref.register(nib, forHeaderFooterViewReuseIdentifier: "expandabaleHeaderView")
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").keepSynced(true)
        userRef.child("no_project").child("recordings").keepSynced(true)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        if(Auth.auth().currentUser != nil)
        {
            if(MyVariables.force_touch_open != "")
            {
                if(MyVariables.force_touch_open == "record")
                {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "record_sid") as! RecordVC
                    MyVariables.force_touch_open = ""
                    self.present(vc, animated: true, completion: nil)
                }
            }else{
                self.sections.removeAll()
                total_section = 0
                fetch_data()
            }
        }
        else
        {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login_sid") as! LogInVC
            UIApplication.shared.keyWindow?.rootViewController = vc
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            self.tabBarController?.selectedIndex = 3
        MyVariables.currently_selected_tab = 3
        MyVariables.last_open_tab_for_inttercom_help = 3
        
        UserDefaults.standard.set(false, forKey: "lyricsTabSelected")
        lyrics_tab_img_ref.image = #imageLiteral(resourceName: "Lyrics_tab")
        recording_tab_img_ref.image = #imageLiteral(resourceName: "recordingSelected")
        
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
        if(!MyVariables.record_tutorial){
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "h1TutorialSid") as! h1TutorialVC
            vc.tutorial_for = "record"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //________________________________ Create Design  ___________________________________
    
    func create_design(){
        processRing.ringStyle = UICircularProgressRingStyle.inside
        search_view.isHidden = true
        select_all_img_ref.layer.borderColor = UIColor.gray.cgColor
        select_all_img_ref.layer.borderWidth = 1.0
        select_all_img_ref.layer.cornerRadius = 5.0
        select_all_img_ref.layer.masksToBounds = true
    }
    
    func fetch_data(){
        myActivityIndicator.startAnimating()
        DispatchQueue.main.async{
            self.get_no_project_data()
           // self.get_data()
        }
    }
 
    // MARK: -  Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(sections.count > 0){
            return total_section
        }else{
            return 0
        }
    }
 
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sections[section].recording_list.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if(sections[section].is_project){
            return 58
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(sections.count > indexPath.section){
            if(sections[indexPath.section].is_project){
                if(sections[indexPath.section].expanded){
                    return 166
                }else{
                    return 0
                }
            }else{
                return 166
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            view.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(sections.count >= section){
         
        if(sections[section].is_project){
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "expandabaleHeaderView") as! ExpandabaleHeaderView
            headerView.customInit(cate_name: sections[section].cate_name, section: section, delegate: self)
            headerView.btn_checkbox_ref.tag = section
            
            if(display_select_view){
                headerView.display_select_view()
            }else{
                headerView.display_checkbox_view()
            }
            
            if(is_selected_all_recordings){
                headerView.checkbox_checked()
            }else{
                headerView.checkbox_unchecked()
            }
            
            if(!is_selected_all_recordings){
                for x in 0..<checked_section_indexes.count {
                    if(headerView.btn_checkbox_ref.tag == self.checked_section_indexes[x]){
                        headerView.checkbox_checked()
                    }
                }
            }
            
            
            headerView.tapSectionCheckboxClick = { (cell) in
                headerView.section_checkbox_img_ref?.image = UIImage(named: "gray_checkbox")!
                
                var containFlag = false
                var selectedIndex : Int? = nil
                var selectedSection : Int? = nil
                var flag = false
                if(self.checked_section_indexes.count > 0){
                    selectedSection = self.checked_section_indexes[0]
                }
                for x in 0..<self.checked_section_indexes.count {
                    if(headerView.btn_checkbox_ref.tag == self.checked_section_indexes[x]){
                        containFlag = true
                        selectedIndex = x
                    }
                    if(self.checked_section_indexes[x] != selectedSection){
                        flag = true
                    }
                    
                }
                
                if(containFlag)
                {
                    if(self.is_selected_all_recordings)
                    {
                        self.select_all_img_ref.image = nil
                        self.select_all_img_ref.layer.borderColor = UIColor.gray.cgColor
                        self.select_all_img_ref.layer.borderWidth = 1.0
                        self.select_all_img_ref.layer.cornerRadius = 5.0
                        self.select_all_img_ref.layer.masksToBounds = true
                        self.is_selected_all_recordings = false
                    }
                    self.checked_section_indexes.remove(at: selectedIndex!)
                    
                    if(flag == true){
                        flag = false
                        if(self.checked_section_indexes.count > 0){
                            selectedSection = self.checked_section_indexes[0]
                        }
                        for x in 0..<self.checked_section_indexes.count {
                            if(self.checked_section_indexes[x] != selectedSection){
                                flag = true
                            }
                        }
                    }
                    
                    
                    headerView.checkbox_unchecked()
                    
                    var get_rec_indexes = [Int]()
                    for x in 0..<self.checked_indexes.count{
                        if(self.checked_indexes[x][1] == section){
                            get_rec_indexes.append(x)
                        }
                    }
                    self.checked_indexes.remove(at: get_rec_indexes)
                    get_rec_indexes.removeAll()
                  
                    
                    self.recording_tbl_ref.reloadSections(IndexSet(integersIn: section...section), with: UITableViewRowAnimation.automatic)
                }
                else
                {
                    self.checked_section_indexes.append(section)
                    for j in 0..<self.sections[section].recording_list.count
                    {
                        let new_val : [Int] = [j,section]
                        self.checked_indexes.append(new_val)
                    }
                    headerView.checkbox_checked()
                    
                    
                    let selected_length = self.checked_indexes.count

                    var all_rec_length = 0
                    for x in 0..<self.sections.count {
                        all_rec_length += self.sections[x].recording_list.count
                    }
                    
                    if(selected_length == all_rec_length){
                        self.select_all_img_ref.layer.borderWidth = 0.0
                        self.select_all_img_ref.image = UIImage(named: "gray_checkbox")!
                        self.select_all_img_ref.layer.cornerRadius = 5.0
                        self.select_all_img_ref.clipsToBounds = true
                        self.is_selected_all_recordings = true
                    }
                    
                    
                    flag = false
                        if(self.checked_section_indexes.count > 0){
                            selectedSection = self.checked_section_indexes[0]
                        }
                        for x in 0..<self.checked_section_indexes.count {
                            if(self.checked_section_indexes[x] != selectedSection){
                                flag = true
                            }
                        }
                    
                    
                    self.recording_tbl_ref.reloadSections(IndexSet(integersIn: section...section), with: UITableViewRowAnimation.automatic)
                }
                if(flag){
                    self.btn_share_ref.alpha = 0.0
                    self.img_share_ref.alpha = 0.0
                    
                }else{
                    self.btn_share_ref.alpha = 1.0
                    self.img_share_ref.alpha = 1.0
                    
                }
            }
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotiationSection))
            longPressGestureRecognizer.minimumPressDuration = 0.5
            headerView.addGestureRecognizer(longPressGestureRecognizer)
            return headerView
        }else{
            return nil
        }
        }else{
            return nil
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let allRec = self.sections[editActionsForRowAt.section].recording_list.count - 1
        let currentRec  = editActionsForRowAt.row
        
        var y_lbl_pos : CGFloat = 0
        if(currentRec != allRec){
            y_lbl_pos = 1
        }else{
            y_lbl_pos = 0
        }
        
        let rename = UITableViewRowAction(style: .normal, title: "") { action, index in
            let myData = self.sections[editActionsForRowAt.section].recording_list[editActionsForRowAt.row]
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
        rename.setIcon(iconImage: UIImage(named: "rename")!, backColor: UIColor.white, cellHeight: 166.0, action_title: "rename", ylblpos: y_lbl_pos)

        let share = UITableViewRowAction(style: .normal, title: "") { action, index in
            let myData = self.sections[editActionsForRowAt.section].recording_list[editActionsForRowAt.row]
            var no_project_key: [String] = []
            var recording_ids : [NSMutableDictionary] = []
            
            if(myData.project_name != "no_project"){
                let jsonObject: NSMutableDictionary = NSMutableDictionary()
                jsonObject.setValue(myData.mykey!, forKey: myData.project_key!)
                recording_ids.append(jsonObject)
            }else{
                no_project_key.append(myData.mykey!)
            }
            
            self.share_recording(no_project_key: no_project_key, recording_ids: recording_ids)
        }
        share.setIcon(iconImage: UIImage(named: "upload")!, backColor: UIColor.white, cellHeight: 166.0, action_title: "share", ylblpos: y_lbl_pos)

        let delete = UITableViewRowAction(style: .normal, title: "") { action, index in
            let myData = self.sections[editActionsForRowAt.section].recording_list[editActionsForRowAt.row]
            self.delete_selected_recording(select_record_list: myData)
        }
        delete.setIcon(iconImage: UIImage(named: "garbage")!, backColor: UIColor.white, cellHeight: 166.0, action_title: "garbage", ylblpos: y_lbl_pos)
        //delete.backgroundColor = UIColor(patternImage: UIImage(named: "garbage")!)

        return [delete, share, rename]
    }
    
    func renameDone(isSuccessful : Bool,newName : String)
    {
        self.sections.removeAll()
        total_section = 0
        fetch_data()
    }
    
    func addAnnotiationSection(_ gestureRecognizer: UILongPressGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: self.recording_tbl_ref)
        
        if let indexPath = recording_tbl_ref.indexPathForRow(at: touchPoint)
        {
            var myData : section? = nil
            if(indexPath.section != total_section){
                myData = sections[indexPath.section]
            
                let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in}
                alertController.addAction(cancelAction)
                
                let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
                    let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rename_project_sid") as! RenameProjectFileVC
                    child_view.renameCompleteProtocol = self
                    child_view.selected_nm = myData!.cate_name
                    child_view.rename_file = false
                    child_view.is_project = true
                    child_view.project_id = myData!.cate_id
                    self.addChildViewController(child_view)
                    child_view.view.frame = self.view.frame
                    self.view.addSubview(child_view.view)
                    child_view.didMove(toParentViewController: self)
                }
                alertController.addAction(renameAction)
                
                let shareAction = UIAlertAction(title: "Share", style: .default) { action in

                    let no_project_key: [String] = []
                    var recording_ids : [NSMutableDictionary] = []
                    let selected_section = indexPath.section
                    for myRecData in self.sections[selected_section].recording_list
                    {
                        let jsonObject: NSMutableDictionary = NSMutableDictionary()
                        jsonObject.setValue(myRecData.mykey!, forKey: myRecData.project_key!)
                        recording_ids.append(jsonObject)
                    }

                    self.share_recording(no_project_key: no_project_key, recording_ids: recording_ids)


                }
                alertController.addAction(shareAction)
                
                let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                    self.delete_selected_section_recording(selected_section: indexPath.section)
                }
                alertController.addAction(destroyAction)
                
                self.present(alertController, animated: true) {}
            }
        }else{
            let myData = sections[0]
            
            let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in}
            alertController.addAction(cancelAction)
            
            let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
                let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rename_project_sid") as! RenameProjectFileVC
                child_view.renameCompleteProtocol = self
                child_view.selected_nm = myData.cate_name
                child_view.rename_file = false
                child_view.is_project = true
                child_view.project_id = myData.cate_id
                self.addChildViewController(child_view)
                child_view.view.frame = self.view.frame
                self.view.addSubview(child_view.view)
                child_view.didMove(toParentViewController: self)
            }
            alertController.addAction(renameAction)
            
            let shareAction = UIAlertAction(title: "Share", style: .default) { action in
                
                let no_project_key: [String] = []
                var recording_ids : [NSMutableDictionary] = []
                let selected_section = 0
                for myRecData in self.sections[selected_section].recording_list
                {
                    let jsonObject: NSMutableDictionary = NSMutableDictionary()
                    jsonObject.setValue(myRecData.mykey!, forKey: myRecData.project_key!)
                    recording_ids.append(jsonObject)
                }
                
                self.share_recording(no_project_key: no_project_key, recording_ids: recording_ids)
                
                
            }
            alertController.addAction(shareAction)
            
            let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                self.delete_selected_section_recording(selected_section: 0)
            }
            alertController.addAction(destroyAction)
            
            self.present(alertController, animated: true) {}
        }
    }
    
    func delete_selected_section_recording(selected_section : Int){
        let myMsg = "Are you sure you want to delete selected project recordings ?"
        let ac = UIAlertController(title: "Delete", message: myMsg, preferredStyle: .alert)
        let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
        let titleAttrString = NSMutableAttributedString(string: "Delete Selected Project Recording?", attributes: attributes)
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
            
            let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dir_Path = document_path.appendingPathComponent("recordings/projects")
            
            if let uid = Auth.auth().currentUser?.uid{
                let userRef = FirebaseManager.getRefference().child(uid).ref
                
                for select_record_list in self.sections[selected_section].recording_list
                {
                    let audio_name = select_record_list.tid!
                    let destinationUrl = dir_Path.appendingPathComponent(audio_name)
                userRef.child("projects").child(select_record_list.project_key!).child("recordings").child(select_record_list.mykey!).removeValue(completionBlock: { (error, database_ref) in
                        if let error = error{
                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                        }
                    })
                    
                    if FileManager.default.fileExists(atPath: (destinationUrl.path))
                    {
                        do{
                            try FileManager.default.removeItem(atPath: destinationUrl.path)
                            FirebaseManager.delete_project_recording_file(myfilename_tid: audio_name, projectId: select_record_list.project_key!)
                        }catch let error as NSError{
                            self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
                        }
                    }
                }
                self.sections.removeAll()
                self.total_section = 0
                self.fetch_data()
            }
            
            
        })
        present(ac, animated: true)
    }
    
    func addAnnotiationRecording(_ gestureRecognizer: UILongPressGestureRecognizer)
    {
        
            let touchPoint = gestureRecognizer.location(in: self.recording_tbl_ref)
            if let indexPath = recording_tbl_ref.indexPathForRow(at: touchPoint)
            {
                var myData : recordingListData? = nil
                myData = sections[indexPath.section].recording_list[indexPath.row]
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in}
                alertController.addAction(cancelAction)
                
                let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
                    let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rename_project_sid") as! RenameProjectFileVC
                    child_view.renameCompleteProtocol = self
                    child_view.selected_id = myData!.mykey!
                    child_view.selected_nm = myData!.name!
                    child_view.rename_file = true
                    child_view.project_id = myData!.project_key!
                    child_view.is_project = true
                    self.addChildViewController(child_view)
                    child_view.view.frame = self.view.frame
                    self.view.addSubview(child_view.view)
                    child_view.didMove(toParentViewController: self)
                }
                alertController.addAction(renameAction)
                
                let shareAction = UIAlertAction(title: "Share", style: .default) { action in
                    var no_project_key: [String] = []
                    var recording_ids : [NSMutableDictionary] = []
                    if(myData!.project_name != "no_project"){
                        let jsonObject: NSMutableDictionary = NSMutableDictionary()
                        jsonObject.setValue(myData!.mykey!, forKey: myData!.project_key!)
                        recording_ids.append(jsonObject)
                    }else{
                        no_project_key.append(myData!.mykey!)
                    }
                    self.share_recording(no_project_key: no_project_key, recording_ids: recording_ids)
                }
                alertController.addAction(shareAction)
                
                let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                    self.delete_selected_recording(select_record_list: myData!)
                }
                alertController.addAction(destroyAction)
                self.present(alertController, animated: true) {}
            }
    }
    
    
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(sections[indexPath.section].is_project){
            self.selectIndexPath = indexPath
            sections[indexPath.section].expanded = !sections[indexPath.section].expanded
            recording_tbl_ref.beginUpdates()
            recording_tbl_ref.reloadSections([indexPath.section], with: .automatic)
            recording_tbl_ref.endUpdates()
        }
    }
    
    func toogleSection(header: ExpandabaleHeaderView, section : Int)
    {
        if(sections[section].is_project){
            sections[section].expanded = !sections[section].expanded
            recording_tbl_ref.beginUpdates()
            recording_tbl_ref.reloadSections([section], with: .automatic)
            recording_tbl_ref.endUpdates()
        }
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var myData : recordingListData? = nil
        if(sections.count > indexPath.section){
            
        
        myData = sections[indexPath.section].recording_list[indexPath.row]
        
//        if(indexPath.section == total_section){
//             myData = record_list[indexPath.row]
//        } else {
//             myData = sections[indexPath.section].recording_list[indexPath.row]
//        }
        
        //let myData = sections[indexPath.section].recording_list[indexPath.row]
        
        let myCell = tableView.dequeueReusableCell(withIdentifier: "recording_tbl_cell", for: indexPath) as! recording_tbl_cell
        myCell.recording_name.text = myData?.name
        myCell.display_select_view()
        
        if(display_select_view){
            myCell.display_select_view()
        }else{
            myCell.display_checkbox_view()
        }
        
        if(myData?.project_name == "no_project"){
            myCell.recording_project.text = "No Project Assigned"
            myCell.recording_project.textColor = UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1)
        }else{
            myCell.recording_project.text = myData?.project_name
            myCell.recording_project.textColor = UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)
        }
        
        myCell.btn_ref_play_record.tag = indexPath.row
        myCell.btn_checkbox_ref.tag = indexPath.section
        myCell.selectionStyle = UITableViewCellSelectionStyle.none
        myCell.play_starting_time.text = ""
        myCell.play_ending_time.text = ""
        myCell.invalid_timer()
        if (indexPath.row == current_play_song_index && indexPath.section == current_section)
        {
            if(self.current_playing)
            {
                myCell.change_imageToPause()
                myCell.audio_bg_img_ref.loadGif(name: "wave")
                if(initialization_flag){
                    myCell.play_starting_time.text = ""
                    myCell.play_ending_time.text = ""
                    initialization_flag = false
                }else{
                    myCell.play_starting_time.text = ""
                    myCell.play_ending_time.text = ""
//                    myCell.play_starting_time.textColor = UIColor.white
//                    myCell.play_ending_time.textColor = UIColor.white
                }
            }
            else
            {
                myCell.change_imageToPlay()
                myCell.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                if(initialization_flag)
                {
                    myCell.play_starting_time.text = ""
                    myCell.play_ending_time.text = ""
                    initialization_flag = false
                }else{
                    myCell.play_starting_time.text = ""
                    myCell.play_ending_time.text = ""
                    //myCell.play_starting_time.textColor = UIColor.white
                    //myCell.play_ending_time.textColor = UIColor.white
                }
            }
        }else{
            myCell.change_imageToPlay()
            myCell.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
            myCell.play_starting_time.text = ""
            myCell.play_ending_time.text = ""
        }
        
        myCell.tapPlayPause = { (cell) in
            
            var play_new_song = false
            if(self.audio_play)
            {
                if(self.current_play_song_index == myCell.btn_ref_play_record.tag && indexPath.section == self.current_section)
                {
                    if(self.current_playing)
                    {
                        
                        self.player.pause()
                        myCell.pause_audio()
                        self.current_playing=false
                        myCell.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                        myCell.change_imageToPlay()
                    }else{
                        self.player.play()
                        myCell.play_audio()
                        myCell.audio_bg_img_ref.loadGif(name: "wave")
                        self.current_playing=true
                        myCell.change_imageToPause()
                    }
                }
                else
                {
                    play_new_song = true
                    myCell.invalid_timer()
                    myCell.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                    myCell.play_starting_time.text = ""
                    myCell.play_ending_time.text = ""
                }
                
            }
            else
            {
                play_new_song = true
                myCell.play_starting_time.text = ""
                myCell.play_ending_time.text = ""
            }
            
            if(play_new_song)
            {
                self.current_play_song_index = myCell.btn_ref_play_record.tag
                self.current_section = indexPath.section
                let visible = tableView.indexPathsForVisibleRows
                
                for vs in visible!{
                    let gen_index = NSIndexPath(row: vs.row, section: vs.section)
                    let myCell = tableView.cellForRow(at: gen_index as IndexPath) as? recording_tbl_cell
                    if (vs.row == self.current_play_song_index && vs.section == self.current_section)
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
                
                    if(self.audio_play)
                    {
                        
                        if(self.online_play_flag)
                        {
                            self.online_player.pause()
                            self.online_player = nil
                            self.online_play_flag = false
                        }
                        else
                        {
                            self.player.stop()
                            myCell.invalid_timer()
                        }
                    }
                
                    var selectedAudio : recordingListData? = nil
                
                
                    selectedAudio = self.sections[self.current_section].self.recording_list[self.current_play_song_index]
                
                        
                    //let selectedAudio = self.record_list[self.current_play_song_index]
                
                if selectedAudio?.tid != nil
                    {
                        
                        let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        var dir_Path = document_path.appendingPathComponent("recordings/no_project")
                        let audio_name = selectedAudio!.tid!
                       
                        if(selectedAudio?.project_name != "no_project")
                        {
                            dir_Path = document_path.appendingPathComponent("recordings/projects")
                        }
                        
                        
                        let destinationUrl = dir_Path.appendingPathComponent(audio_name)
                        if FileManager.default.fileExists(atPath: destinationUrl.path)
                        {
                            do
                            {
                                try self.player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: destinationUrl.path))
                               
                                self.player.prepareToPlay()
                                self.player.delegate = self
                                
                                for vs in visible!{
                                    let gen_index = NSIndexPath(row: vs.row, section: vs.section)
                                    let myCell = tableView.cellForRow(at: gen_index as IndexPath) as? recording_tbl_cell
                                    if (vs.row == self.current_play_song_index)
                                    {
                                        myCell?.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                                        myCell?.change_imageToPlay()
                                    }
                                    else
                                    {
                                        myCell?.change_imageToPlay()
                                        myCell?.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
//                                        myCell?.play_starting_time.text = ""
//                                        myCell?.play_ending_time.text = ""
                                        myCell?.invalid_timer()
                                    }
                                }
                                myCell.play_starting_time.text = "0:00"
                                myCell.play_ending_time.text = "-" + self.give_time(seconds: Int(self.player.duration))
                                
                                myCell.initialize_time(seconds: Int(self.player.duration))
                                myCell.change_imageToPause()
                                self.player.play()
                                myCell.audio_bg_img_ref.loadGif(name: "wave")
                                self.audio_play = true
                                self.current_playing = true
                                self.myActivityIndicator.stopAnimating()
                            }
                            catch
                            {
                                self.display_alert(msg_title: "Error", msg_desc: "Not able to play audio.", action_title: "OK")
                                self.myActivityIndicator.stopAnimating()
                            }
                        }
                        else
                        {
                            for vs in visible!
                            {
                                let gen_index = NSIndexPath(row: vs.row, section: vs.section)
                                let myCell = tableView.cellForRow(at: gen_index as IndexPath) as? recording_tbl_cell
                                myCell?.audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                                myCell?.change_imageToPlay()
                            }
                            
                            if(Reachability.isConnectedToNetwork())
                            {
                                if(selectedAudio?.downloadURL != ""){
                                    let httpsReference = Storage.storage().reference(forURL:selectedAudio!.downloadURL!)
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
                                        
                                        if FileManager.default.fileExists(atPath: destinationUrl.path)
                                        {
                                            do
                                            {
                                                try self.player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: destinationUrl.path))
                                                self.player.prepareToPlay()
                                                self.player.delegate = self
                                                
                                                myCell.change_imageToPause()
                                                self.player.play()
                                                myCell.play_starting_time.text = "0:00"
                                                myCell.play_ending_time.text = "0:00"
                                                myCell.initialize_time(seconds: Int(self.player.duration))
                                                myCell.audio_bg_img_ref.loadGif(name: "wave")
                                                self.audio_play = true
                                                self.current_playing = true
                                                self.myActivityIndicator.stopAnimating()
                                            }
                                            catch
                                            {
                                                self.display_alert(msg_title: "Error", msg_desc: "Not able to play audio.", action_title: "OK")
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
                                        self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                                    })
                                    self.myActivityIndicator.stopAnimating()
                                }else{
                                    self.myActivityIndicator.stopAnimating()
                                    self.display_alert(msg_title: "Not Found", msg_desc: "Can not found this file in server.", action_title: "OK")
                                }
                                
                            }
                            else
                            {
                                self.myActivityIndicator.stopAnimating()
                                self.display_alert(msg_title: "No Internet Connection", msg_desc: "For download - make sure your device is connected to the internet", action_title: "OK")

                            }
                       
                        }
                }
            }
            
        }
        
        if(is_selected_all_recordings){
            myCell.checkbox_checked()
        }else{
            myCell.checkbox_unchecked()
        }
        
        if(!is_selected_all_recordings){
            for x in 0..<checked_indexes.count {
                if(myCell.btn_ref_play_record.tag == self.checked_indexes[x][0] && myCell.btn_checkbox_ref.tag == self.checked_indexes[x][1]){
                    myCell.checkbox_checked()
                }
            }
        }
        
        myCell.tapCheckboxClick = { (cell) in
            var containFlag = false
            var selectedIndex : Int? = nil
            var selectedSection : Int? = nil
            var flag = false
            if(self.checked_indexes.count > 0){
                selectedSection = self.checked_indexes[0][1]
            }
           
            
            for x in 0..<self.checked_indexes.count {
                if(myCell.btn_ref_play_record.tag == self.checked_indexes[x][0] && myCell.btn_checkbox_ref.tag == self.checked_indexes[x][1]){
                    containFlag = true
                    selectedIndex = x
                    
                }
                let currentSection = self.checked_indexes[x][1]
                if(selectedSection != currentSection){
                    flag = true
                }
                
            }
            
            if(containFlag)
            {
                if(self.is_selected_all_recordings)
                {
                    self.select_all_img_ref.image = nil
                    self.select_all_img_ref.layer.borderColor = UIColor.gray.cgColor
                    self.select_all_img_ref.layer.borderWidth = 1.0
                    self.select_all_img_ref.layer.cornerRadius = 5.0
                    self.select_all_img_ref.layer.masksToBounds = true
                    self.is_selected_all_recordings = false
                }
                
                self.checked_indexes.remove(at: selectedIndex!)
                let current_section = indexPath.section
                if(self.checked_section_indexes.contains(current_section)){
                    let myIndex = self.checked_section_indexes.index(of: current_section)
                    self.checked_section_indexes.remove(at: myIndex!)
                }
                myCell.checkbox_unchecked()
                
                if(flag == true){
                    flag = false
                    if(self.checked_indexes.count > 0){
                        selectedSection = self.checked_indexes[0][1]
                    }
                    
                    for x in 0..<self.checked_indexes.count {
                        let currentSection = self.checked_indexes[x][1]
                        if(selectedSection != currentSection){
                            flag = true
                        }
                        
                    }
                }
                
                
                
                //let selected_length = self.checked_indexes.count
//                if(selected_length < 2)
//                {
//                    self.btn_share_ref.alpha = 1.0
//                    self.img_share_ref.alpha = 1.0
//                }
//                else
//                {
//                    self.btn_share_ref.alpha = 0.0
//                    self.img_share_ref.alpha = 0.0
//                }
                
                self.recording_tbl_ref.reloadSections(IndexSet(integersIn: indexPath.section...indexPath.section), with: UITableViewRowAnimation.automatic)
            }
            else
            {
                
                let new_val : [Int] = [myCell.btn_ref_play_record.tag,myCell.btn_checkbox_ref.tag]
                self.checked_indexes.append(new_val)
                
                
                let selected_length = self.checked_indexes.count
                var all_rec_length = 0
                for x in 0..<self.sections.count {
                    all_rec_length += self.sections[x].recording_list.count
                }
                
                let total_in_section = self.sections[indexPath.section].recording_list.count
                
               
                var audio_in_sec = 0
                for x in 0..<self.checked_indexes.count{
                    if(self.checked_indexes[x][1] == indexPath.section){
                        audio_in_sec = audio_in_sec + 1
                    }
                }
                
                if(audio_in_sec == total_in_section){
                    if(!self.checked_section_indexes.contains(indexPath.section)){
                        self.checked_section_indexes.append(indexPath.section)
                    }
                }
                
                flag = false
               
                
                if(self.checked_indexes.count > 0){
                    selectedSection = self.checked_indexes[0][1]
                }
            
                for x in 0..<self.checked_indexes.count {
                    let currentSection = self.checked_indexes[x][1]
                    if(selectedSection != currentSection){
                        flag = true
                    }
                    
                }
                
                if(selected_length == all_rec_length)
                {
                    self.select_all_img_ref.layer.borderWidth = 0.0
                    self.select_all_img_ref.image = UIImage(named: "gray_checkbox")!
                    self.select_all_img_ref.layer.cornerRadius = 5.0
                    self.select_all_img_ref.clipsToBounds = true
                    self.is_selected_all_recordings = true
                    myCell.checkbox_checked()
                }
                else
                {
                    myCell.checkbox_checked()
                }
                
                
//                if(selected_length < 2)
//                {
//                    self.btn_share_ref.alpha = 1.0
//                    self.img_share_ref.alpha = 1.0
//                }
//                else
//                {
//                    self.btn_share_ref.alpha = 0.0
//                    self.img_share_ref.alpha = 0.0
//                }
                self.recording_tbl_ref.reloadData()
                
                //self.recording_tbl_ref.reloadSections(IndexSet(integersIn: indexPath.section...indexPath.section), with: UITableViewRowAnimation.automatic)
            }
            //}
            if(flag){
                self.btn_share_ref.alpha = 0.0
                self.img_share_ref.alpha = 0.0
                
            }else{
                self.btn_share_ref.alpha = 1.0
                self.img_share_ref.alpha = 1.0
                
            }
        }
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotiationRecording))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        myCell.addGestureRecognizer(longPressGestureRecognizer)
        
        return myCell
        }else{
            let myCell = tableView.dequeueReusableCell(withIdentifier: "recording_tbl_cell", for: indexPath) as! recording_tbl_cell
            return myCell
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        if(self.audio_play)
        {
            if(self.online_play_flag)
            {
                self.online_player = nil
                self.online_play_flag = false
            }
            self.audio_play = false
            current_playing = false
            recording_tbl_ref.reloadData()
        }
    }
   
    func delete_selected_recording(select_record_list : recordingListData){
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
            
            var flag_project = false
            let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            var dir_Path = document_path.appendingPathComponent("recordings/no_project")
            
            
            if(select_record_list.project_name != "no_project")
            {
                dir_Path = document_path.appendingPathComponent("recordings/projects")
            }
            
            let audio_name = select_record_list.tid!
            let destinationUrl = dir_Path.appendingPathComponent(audio_name)
            
            if(select_record_list.project_name == "no_project")
            {
                flag_project = false
                let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                userRef.child("no_project").child("recordings").child(select_record_list.mykey!).removeValue(completionBlock: { (error, database_ref) in
                    
                    if let error = error
                    {
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }else{
                        //self.sections.removeAll()
                        self.total_section = 0
                        self.fetch_data()
                    }
                })
            }
            else
            {
                flag_project = true
                let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            userRef.child("projects").child(select_record_list.project_key!).child("recordings").child(select_record_list.mykey!).removeValue(completionBlock: { (error, database_ref) in
                    
                    if let error = error
                    {
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }else{
                        //self.sections.removeAll()
                        self.total_section = 0
                        self.fetch_data()
                    }
                })
            }
            
            if FileManager.default.fileExists(atPath: (destinationUrl.path))
            {
                do
                {
                    try FileManager.default.removeItem(atPath: destinationUrl.path)
                    if(flag_project)
                    {
                        if(select_record_list.project_key != "")
                        {
                            FirebaseManager.delete_project_recording_file(myfilename_tid: audio_name, projectId: select_record_list.project_key!)
                        }
                    }else{
                        FirebaseManager.delete_noproject_recording_file(myfilename_tid: audio_name)
                    }
                }catch let error as NSError{
                    self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
                }
            }
        })
        present(ac, animated: true)
    }
    
    //________________________________ Get Data  ___________________________________
    
    func get_no_project_data()
    {
        DispatchQueue.main.async
        {
            self.total_section = 0
            self.sections.removeAll()
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            userRef.child("no_project").child("recordings").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                
                for snap in snapshot.children
                {
                    let userSnap = snap as! DataSnapshot
                    let rec_key = userSnap.key
                    let rec_dict = userSnap.value as? [String : AnyObject]
                    let name = rec_dict?["name"] as! String
                    let tid = rec_dict?["tid"] as! String
                    var bpm = 0
                    var key = ""
                    
                    var download_url = rec_dict?["downloadURL"] as? String
                    
                    if(download_url == nil)
                    {
                        download_url = ""
                    }
                    
                    if let audioBpm = rec_dict?["bpm"] as? Int{
                        bpm = audioBpm
                    }
                    if let audioKey = rec_dict?["key"] as? String{
                        key = audioKey
                    }
                    
                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let document_path = paths[0]
                    let dir_Path = document_path.appendingPathComponent("recordings/no_project")
                    let destinationUrl = dir_Path.appendingPathComponent(tid)
                    var local_file = false
                    if FileManager.default.fileExists(atPath: (destinationUrl.path))
                    {
                        local_file = true
                    }
                  
                    let record_data = recordingListData(name: name, project_name: "no_project", project_key: "", tid: tid, mykey: rec_key, local_file: local_file, downloadURL: download_url!, volume: 1.0, bpm: bpm, key: key)
                    self.total_section = self.total_section + 1
                    let section_data = section(cate_id: "", cate_name: "", recording_list: [record_data], expanded: false, is_project: false, sort_key: rec_key)
                    self.sections.append(section_data)
                    
                    //self.record_list.append(record_data)
                }
                
                
//                let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                var dir_Path = document_path.appendingPathComponent("recordings/no_project")
//                let audio_name1 = self.sections[0].recording_list[0].tid
//                let destinationUrl1 = dir_Path.appendingPathComponent(audio_name1!)
//                let audio_name2 = self.sections[0].recording_list[1].tid
//                let destinationUrl2 = dir_Path.appendingPathComponent(audio_name2!)
//                self.merge(audio1: destinationUrl1, audio2: destinationUrl2)
                
//                self.record_list = self.record_list.reversed()
//                if(self.record_list.count > 0)
//                {
//                    //self.recording_tbl_ref.reloadData()
//                }
                
                self.come_from_project_data = true
                self.get_data()
            })
        }
    }
    
    func get_data()
    {
        //self.sections.removeAll()
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!self.come_from_project_data)
            {
                self.get_no_project_data()
            }
            else
            {
                for snap in snapshot.children
                {
                    let userSnap = snap as! DataSnapshot
                    let project_key = userSnap.key
                    let project_value = userSnap.value as! NSDictionary
                    let project_name = project_value.value(forKey: "project_name") as! String
                    var sort_key = ""
                    
                    if((project_value.value(forKey: "recordings") as? NSDictionary) != nil)
                    {
                        if let record_data =  project_value.value(forKey: "recordings") as? NSDictionary{
                            if let get_sort_key = project_value.value(forKey: "recording_modified") as? String{
                                sort_key = get_sort_key
                            }else{
                                sort_key = project_key
                            }
                            
                            if let main_rec = project_value.value(forKey: "project_main_recording") as? String
                            {
                                self.display_project_data(project_name: project_name, project_value: record_data,project_key: project_key,main_recording : main_rec, sort_key: sort_key)
                            }else{
                                self.display_project_data(project_name: project_name, project_value: record_data,project_key: project_key,main_recording : "", sort_key: sort_key)
                            }
                        }
                    }
                }
                self.come_from_project_data = false
                
                let myArrayOfTuples = self.sections.sorted{
                    guard let d1 = $0.sort_key, let d2 = $1.sort_key else { return false }
                    return d1 < d2
                }
                self.sections = myArrayOfTuples
                
                if(self.sections.count > 0)
                {
                    self.myActivityIndicator.stopAnimating()
                    self.recording_tbl_ref.alpha = 1.0
                    self.sections = self.sections.reversed()
                    self.recording_tbl_ref.reloadData()
                }
                else
                {
                    self.myActivityIndicator.stopAnimating()
                    self.recording_tbl_ref.alpha = 0.0
                    self.no_recording_view_ref.alpha = 1.0
                }
            }
        })
    }
    
    func display_project_data(project_name : String , project_value : NSDictionary, project_key : String, main_recording : String, sort_key : String)
    {
        
        project_record_list.removeAll()
        let recording_key = project_value.allKeys as! [String]
        
        for reckey in recording_key
        {
            let rec_dict = project_value.value(forKey: reckey) as? NSDictionary
            let name = rec_dict?.value(forKey: "name") as! String
            let tid = rec_dict?.value(forKey: "tid") as! String
            var bpm = 0
            var key = ""
            
            var download_url = rec_dict?["downloadURL"] as? String
            
            if(download_url == nil)
            {
                download_url = ""
            }
            if let audioBpm = rec_dict?["bpm"] as? Int{
                bpm = audioBpm
            }
            if let audioKey = rec_dict?["key"] as? String{
                key = audioKey
            }
            
            let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dir_Path = document_path.appendingPathComponent("recordings/projects")
            let destinationUrl = dir_Path.appendingPathComponent(tid)
            
            var local_file = false
            if FileManager.default.fileExists(atPath: (destinationUrl.path))
            {
                local_file = true
            }
            
            if(main_recording == "")
            {
                let record_data = recordingListData(name: name, project_name: project_name, project_key: project_key, tid: tid, mykey: reckey, local_file: local_file, downloadURL: download_url!, volume: 1.0, bpm: bpm, key: key)
                self.project_record_list.append(record_data)
            }
            else
            {
                if (tid != main_recording)
                {
                    let record_data = recordingListData(name: name, project_name: project_name, project_key: project_key, tid: tid, mykey: reckey, local_file: local_file, downloadURL: download_url!, volume: 1.0, bpm: bpm, key: key)
                    self.project_record_list.append(record_data)
                }
            }
        }
        
        if(project_record_list.count > 0)
        {
            total_section = total_section + 1
            let section_data = section(cate_id: project_key, cate_name: project_name, recording_list: project_record_list, expanded: false, is_project: true, sort_key: sort_key)
            self.sections.append(section_data)
            //self.recording_tbl_ref.reloadData()
        }
        
        
    }
    
    //________________________________ Search Data  ___________________________________
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.search_text = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        search_bar_ref.resignFirstResponder()
        search_view.isHidden = true
        top_view.isHidden = false
        searchBar.text = ""
        search_text = ""
        get_data()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        if(search_text != ""){
            search_bar_ref.resignFirstResponder()
            search_data()
        }
    }
    
    func search_data()
    {
        self.myActivityIndicator.startAnimating()
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        total_section = 0
        self.sections.removeAll()
        if(search_text == "no_project")
        {
            userRef.child("no_project").child("recordings").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                self.sections.removeAll()
                for snap in snapshot.children
                {
                    let userSnap = snap as! DataSnapshot
                    let rec_key = userSnap.key
                    let rec_dict = userSnap.value as? [String : AnyObject]
                    
                    var name = ""
                    var tid = ""
                    var bpm = 0
                    var key = ""
                    
                    if let nm = rec_dict?["name"] as? String{
                        name = nm
                    }
                    
                    if let title = rec_dict?["tid"] as? String{
                        tid = title
                    }
                    
                    var download_url = rec_dict?["downloadURL"] as? String
                    if(download_url == nil)
                    {
                        download_url = ""
                    }
                    
                    if let audioBpm = rec_dict?["bpm"] as? Int{
                        bpm = audioBpm
                    }
                    if let audioKey = rec_dict?["key"] as? String{
                        key = audioKey
                    }
                    
                    let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let dir_Path = document_path.appendingPathComponent("recordings/no_project")
                    let destinationUrl = dir_Path.appendingPathComponent(tid)
                    
                    if FileManager.default.fileExists(atPath: (destinationUrl.path))
                    {
                        let record_data = recordingListData(name: name, project_name: "no_project", project_key: "", tid: tid, mykey: rec_key, local_file: true, downloadURL: download_url!, volume: 1.0, bpm: bpm, key: key)
                        //self.record_list.append(record_data)
                        let section_data = section(cate_id: "", cate_name: "", recording_list: [record_data], expanded: false, is_project: false, sort_key: rec_key)
                        self.sections.append(section_data)
                    }
                    else
                    {
                        let record_data = recordingListData(name: name, project_name: "no_project", project_key: "", tid: tid, mykey: rec_key, local_file: false, downloadURL: download_url!, volume: 1.0, bpm: bpm, key: key)
                        
                        let section_data = section(cate_id: "", cate_name: "", recording_list: [record_data], expanded: false, is_project: false, sort_key: rec_key)
                        self.sections.append(section_data)
                    }
                }
                let myArrayOfTuples = self.sections.sorted{
                    guard let d1 = $0.sort_key, let d2 = $1.sort_key else { return false }
                    return d1 < d2
                }
                self.sections = myArrayOfTuples
                self.sections = self.sections.reversed()
                self.recording_tbl_ref.reloadData()
                self.myActivityIndicator.stopAnimating()
                
                if(self.sections.count == 0){
                    MyConstants.search_not_found_alert(myVC: self, searchRef: self.search_bar_ref)
                }
                
            })
        }
        else
        {
            userRef.child("projects").queryOrdered(byChild: "project_name").queryStarting(atValue: search_text).queryEnding(atValue:search_text+MyVariables.search_last_char).observeSingleEvent(of: .value, with: { (snapshot) in
                self.sections.removeAll()
                for snap in snapshot.children
                {
                    let userSnap = snap as! DataSnapshot
                    
                    let project_key = userSnap.key
                    let project_value = userSnap.value as! NSDictionary
                    let project_name = project_value.value(forKey: "project_name") as! String
                    var sort_key = ""
                    if((project_value.value(forKey: "recordings") as? NSDictionary) != nil)
                    {
                        let record_data =  project_value.value(forKey: "recordings") as! NSDictionary
                        
                        if let get_sort_key = project_value.value(forKey: "recording_modified") as? String{
                            sort_key = get_sort_key
                        }else{
                            sort_key = project_key
                        }
                        
                        if let main_rec = project_value.value(forKey: "project_main_recording") as? String
                        {
                            self.display_project_data(project_name: project_name, project_value: record_data,project_key: project_key,main_recording : main_rec, sort_key: sort_key)
                        }else{
                            self.display_project_data(project_name: project_name, project_value: record_data,project_key: project_key,main_recording : "", sort_key: sort_key)
                        }
                        
                    }
                }
                let myArrayOfTuples = self.sections.sorted{
                    guard let d1 = $0.sort_key, let d2 = $1.sort_key else { return false }
                    return d1 < d2
                }
                self.sections = myArrayOfTuples
                self.sections = self.sections.reversed()
                self.recording_tbl_ref.reloadData()
                self.myActivityIndicator.stopAnimating()
                
                if(self.sections.count == 0){
                    MyConstants.search_not_found_alert(myVC: self, searchRef: self.search_bar_ref)
                }
                
            })
        }
    }
    
    @IBAction func open_share_delete_view(_ sender: Any)
    {
        manage_delete_share_view()
    }
    
    func manage_delete_share_view()
    {
        if(is_open_share_delet_view)
        {
            share_delete_view_ref.alpha = 0.0
            top_contraint_tblview.constant = 0.0
            is_open_share_delet_view = false
            display_select_view = true
            recording_tbl_ref.reloadData()
        }
        else
        {
            share_delete_view_ref.alpha = 1.0
            top_contraint_tblview.constant = 80.0
            is_open_share_delet_view = true
            display_select_view = false
            recording_tbl_ref.reloadData()
        }
    }

    @IBAction func open_search_view(_ sender: Any)
    {
        search_view.isHidden = false
        top_view.isHidden = true
        search_bar_ref.becomeFirstResponder()
    }
    
    @IBAction func btn_share_selected(_ sender: Any)
    {
        if(checked_indexes.count < 1)
        {
            display_alert(msg_title: "Required", msg_desc: "You must have to select Recording.", action_title: "OK")
        }
        else
        {
            var no_project_key: [String] = []
            var recording_ids : [NSMutableDictionary] = []
            
            for var x in 0..<self.checked_indexes.count {
                let selected_section = self.checked_indexes[x][1]
                let myData = self.sections[selected_section].recording_list[self.checked_indexes[x][0]]
                if(sections[selected_section].is_project){
                    
                    let jsonObject: NSMutableDictionary = NSMutableDictionary()
                    jsonObject.setValue(myData.mykey!, forKey: myData.project_key!)
                    recording_ids.append(jsonObject)
                }else{
                    no_project_key.append(myData.mykey!)
                }
              
            }
            
            share_recording(no_project_key: no_project_key, recording_ids: recording_ids)
            self.deselect_all_recordings()
            self.manage_delete_share_view()
        }
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
    
    func share_recording(no_project_key : [String],recording_ids : [NSMutableDictionary]){
        
        let myuserid = Auth.auth().currentUser?.uid
        if(myuserid != nil)
        {
            do{
                let data =  try JSONSerialization.data(withJSONObject: recording_ids, options:[])
                let mystring = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                let no_project_string = "&no_project_rec_ids="+no_project_key.description
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
    
    
    @IBAction func btn_delete_selected(_ sender: Any)
    {
        if(checked_indexes.count < 1)
        {
            display_alert(msg_title: "Required", msg_desc: "You must have to select Recording.", action_title: "OK")
        }
        else
        {
            DispatchQueue.main.async {
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
                    
                    for x in 0..<self.checked_indexes.count {
                        let selected_section = self.checked_indexes[x][1]
                        let myData = self.sections[selected_section].recording_list[self.checked_indexes[x][0]]
                        self.remove_recording(selectedData: myData)
                        
                    }
                    
                    self.deselect_all_recordings()
                    self.manage_delete_share_view()
                    self.total_section = 0
                    self.sections.removeAll()
                    self.fetch_data()
                })
                self.present(ac, animated: true)
            }
        }
    }
    
    func remove_recording(selectedData : recordingListData?)
    {
        var flag_project = false
        let document_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var dir_Path = document_path.appendingPathComponent("recordings/no_project")
        
        if(selectedData != nil){
            if(selectedData!.project_name != "no_project"){
                dir_Path = document_path.appendingPathComponent("recordings/projects")
            }
            let audio_name = selectedData!.tid!
            let destinationUrl = dir_Path.appendingPathComponent(audio_name)
            if(selectedData!.project_name == "no_project")
            {
                flag_project = false
                let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                userRef.child("no_project").child("recordings").child(selectedData!.mykey!).removeValue(completionBlock: { (error, database_ref) in
                    
                    if let error = error
                    {
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                })
            }
            else
            {
                flag_project = true
                let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            userRef.child("projects").child(selectedData!.project_key!).child("recordings").child(selectedData!.mykey!).removeValue(completionBlock: { (error, database_ref) in
                    
                    if let error = error
                    {
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                })
            }
            if FileManager.default.fileExists(atPath: (destinationUrl.path))
            {
                do
                {
                    try FileManager.default.removeItem(atPath: destinationUrl.path)
                    if(flag_project)
                    {
                        if(selectedData!.project_key != "")
                        {
                            FirebaseManager.delete_project_recording_file(myfilename_tid: audio_name, projectId: selectedData!.project_key!)
                        }
                    }
                    else
                    {
                        FirebaseManager.delete_noproject_recording_file(myfilename_tid: audio_name)
                    }
                }
                catch let error as NSError
                {
                    self.display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "Ok")
                }
            }
        }
        
    }
       
    @IBAction func btn_select_all(_ sender: Any)
    {
        if(is_selected_all_recordings)
        {
            deselect_all_recordings()
        }
        else
        {
            select_all_recordings()
        }
    }
    
    func select_all_recordings()
    {
        select_all_img_ref.layer.borderWidth = 0.0
        checked_indexes.removeAll()
        checked_section_indexes.removeAll()
        
        for i in 0..<sections.count
        {
            self.checked_section_indexes.append(i)
            for j in 0..<sections[i].recording_list.count
            {
                let new_val : [Int] = [j,i]
                self.checked_indexes.append(new_val)
            }
        }
        
        select_all_img_ref.image = UIImage(named: "gray_checkbox")!
        select_all_img_ref.layer.cornerRadius = 5.0
        select_all_img_ref.clipsToBounds = true
        is_selected_all_recordings = true
        
        self.btn_share_ref.alpha = 0.0
        self.img_share_ref.alpha = 0.0
        recording_tbl_ref.reloadData()
        
    }
    
    func deselect_all_recordings()
    {
        select_all_img_ref.image = nil
        select_all_img_ref.layer.borderColor = UIColor.gray.cgColor
        select_all_img_ref.layer.borderWidth = 1.0
        select_all_img_ref.layer.cornerRadius = 5.0
        select_all_img_ref.layer.masksToBounds = true
        is_selected_all_recordings = false
        checked_indexes.removeAll()
        checked_section_indexes.removeAll()
        self.btn_share_ref.alpha = 1.0
        self.img_share_ref.alpha = 1.0
        recording_tbl_ref.reloadData()
        
    }
    
    @IBAction func open_recordvc_btn_click(_ sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "record_sid") as! RecordVC
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if(self.current_playing)
        {
            self.player.stop()
            self.current_playing=false
            self.recording_tbl_ref.reloadData()
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
                    DispatchQueue.main.async{
                        self.myActivityIndicator.stopAnimating()
                    }
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
                                
                                let status = json["status"] as! Int
                                if(status == 1){
                                    let mydata = json["data"] as! NSDictionary
                                    let mylink = mydata["link"] as! String
                                    let activityItem: [String] = [mylink as String]
                                    let avc = UIActivityViewController(activityItems: activityItem, applicationActivities: nil)
                                    self.myActivityIndicator.stopAnimating()
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
    }
    
    @IBAction func open_recording(_ sender: UIButton) {
        
    }
    
    @IBAction func open_lyrics(_ sender: UIButton) {
       self.tabBarController?.selectedIndex = 3
        UserDefaults.standard.set(true, forKey: "lyricsTabSelected")
        self.parent?.viewDidLoad()
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        //let newVC = self.storyboard?.instantiateViewController(withIdentifier: "LyricsVC_sid") as! LyricsVC
        //self.navigationController?.pushViewController(newVC, animated: false)
    }
    
}

extension AVPlayer
{
    var isPlaying : Bool
    {
        return rate != 0 && error == nil
    }
}

extension Array {
    mutating func remove(at indexes: [Int]) {
        for index in indexes.sorted(by: >) {
            remove(at: index)
        }
    }
}

extension UITableViewRowAction {
    
    func setIcon(iconImage: UIImage, backColor: UIColor, cellHeight: CGFloat, action_title: String, ylblpos: CGFloat)
    {
        var iconHeight = 0.0 as CGFloat //cellHeight * iconSizePercentage
        var iconWidth = 0.0 as CGFloat
        
        if(action_title == "garbage"){
            iconHeight = 27.0
            iconWidth = 23.0
        }else if(action_title == "share"){
            iconHeight = 27.0
            iconWidth = 21.0
        }else if(action_title == "rename"){
            iconHeight = 27.0
            iconWidth = 23.0
        }else if(action_title == "engGarbage"){
            iconHeight = 27.0
            iconWidth = 23.0
        }else if(action_title == "engShare"){
            iconHeight = 21.0
            iconWidth = 21.0
        }
        
        let marginy = (cellHeight - iconHeight) / 2 as CGFloat
        let marginx = 27.0 as CGFloat
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: cellHeight, height: cellHeight))
        backView.backgroundColor = backColor
        
        let myImage = UIImageView(frame: CGRect(x: marginx, y: marginy, width: iconWidth, height: iconHeight))
        myImage.image = iconImage
        backView.addSubview(myImage)
        
        let label = UILabel(frame: CGRect(x: 0, y: cellHeight - ylblpos, width: cellHeight, height: 2))
        //label.backgroundColor = UIColor.gray
        label.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        //label.text = "Remove"
        label.textAlignment = .center
        //label.textColor = UIColor.white
        //label.font = UIFont(name: label.font.fontName, size: 14)
        backView.addSubview(label)
        
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: cellHeight, height: cellHeight), false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        backView.layer.render(in: context!)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.backgroundColor = UIColor(patternImage: newImage)
       
        
    }
    
    
    
    
    
}
