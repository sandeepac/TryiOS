//
//  LyricsVC.swift
//  Tully Dev
//
//  Created by macbook on 5/24/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase

class LyricsVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource
{
    //________________________________ Outlets  ___________________________________
    
    @IBOutlet weak var recording_tab_img_ref: UIImageView!
    @IBOutlet weak var lyrics_tab_img_ref: UIImageView!
    @IBOutlet var no_lyrics_view_ref: UIView!
    @IBOutlet var top_view: UIView!
    @IBOutlet var search_view: UIView!
    @IBOutlet var lyrics_tbl_view_ref: UITableView!
    @IBOutlet var search_bar_ref: UISearchBar!
    @IBOutlet var share_delete_view_ref: UIView!
    @IBOutlet var top_contraint_tblview: NSLayoutConstraint!
    @IBOutlet var select_all_img_ref: UIImageView!
    
    //________________________________ Variables  ___________________________________
    
    
    @IBOutlet var img_share_ref: UIImageView!
    @IBOutlet var btn_share_ref: UIButton!
    var is_open_share_delet_view = false
    var lyrics_list = [lyricsListData]()
    var lyrics_list_project = [lyricsListData]()
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var search_text = ""
    var display_select_view = true
    var is_selected_all_lyrics = false
    var come_from_project_data = false
    var checked_indexes = [Int]()
    var len = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        let selected_lyrics = UserDefaults.standard.value(forKey: "lyricsTabSelected") as? Bool
        if(selected_lyrics != nil){
            if(selected_lyrics == true){
                UserDefaults.standard.set(true, forKey: "lyricsTabSelected")
                self.lyrics_list.removeAll()
                self.get_no_project_data()
            }else{
                open_recording()
            }
        }else{
            checkOpenLyricsRecording()
        }
        
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        lyrics_tbl_view_ref.tableFooterView = UIView()
        if(!MyVariables.lyrics_tutorial){
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "h1TutorialSid") as! h1TutorialVC
            vc.tutorial_for = "lyrics"
            self.present(vc, animated: true, completion: nil)
        }
        let userRef = FirebaseManager.getRefference().child(Auth.auth().currentUser!.uid).ref
        userRef.child("no_project").child("lyrics").keepSynced(true)
        userRef.child("projects").keepSynced(true)
        create_design()
    }
    
    func checkOpenLyricsRecording(){
       
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("no_project").child("recordings").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if(!snapshot.exists()){
                userRef.child("no_project").child("lyrics").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot1) in
                    if(!snapshot1.exists()){
                        userRef.child("projects").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot2) in
                            if(!snapshot2.exists()){
                                
                                UserDefaults.standard.removeObject(forKey: "lyricsTabSelected")
                                
                                let child_view = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LyricsAndRecordingVC") as! LyricsAndRecordingVC
                                self.addChildViewController(child_view)
                                child_view.view.frame = self.view.frame
                                self.view.addSubview(child_view.view)
                                
                                child_view.didMove(toParentViewController: self)
                                
                                
                            }else{
                               UserDefaults.standard.set(true, forKey: "lyricsTabSelected")
                                self.get_no_project_data()
                            }
                        })
                    }else{
                        UserDefaults.standard.set(true, forKey: "lyricsTabSelected")
                        self.get_no_project_data()
                    }
                })
            }else{
                UserDefaults.standard.set(true, forKey: "lyricsTabSelected")
                self.get_no_project_data()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.selectedIndex = 3
        
        lyrics_tab_img_ref.image = #imageLiteral(resourceName: "lyricsSelected")
        recording_tab_img_ref.image = #imageLiteral(resourceName: "Recording_tab")
        
        MyVariables.currently_selected_tab = 3
        MyVariables.last_open_tab_for_inttercom_help = 3
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if(Auth.auth().currentUser != nil)
        {
            if(MyVariables.force_touch_open != "")
            {
                if(MyVariables.force_touch_open == "lyrics")
                {
                    let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "create_lyrics_sid") as! create_lyrics_VC
                    MyVariables.force_touch_open = ""
                    self.present(popvc, animated: true, completion: nil)
                }
            }
            else
            {
                self.lyrics_list.removeAll()
                self.get_no_project_data()
            }
        }
        else
        {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login_sid") as! LogInVC
            UIApplication.shared.keyWindow?.rootViewController = vc
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //________________________________ Custom Design  ___________________________________
    
    func create_design()
    {
        search_view.isHidden = true
        select_all_img_ref.layer.borderColor = UIColor.gray.cgColor
        select_all_img_ref.layer.borderWidth = 1.0
        select_all_img_ref.layer.cornerRadius = 5.0
        select_all_img_ref.layer.masksToBounds = true
    }
    
    //________________________________ Table view delegates  ___________________________________
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        len = lyrics_list.count
        if(self.len == 0)
        {
            self.lyrics_tbl_view_ref.isHidden = true
        }
        else
        {
            self.lyrics_tbl_view_ref.isHidden = false
        }
        return len
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myData = lyrics_list[indexPath.row]
        let myCell = tableView.dequeueReusableCell(withIdentifier: "lyrics_tbl_cell", for: indexPath) as! lyrics_tbl_cell
        myCell.select_btn_ref.tag = indexPath.row
        
        if(display_select_view){
            myCell.display_select_view()
        }
        else{
            myCell.display_checkbox_view()
        }
        
        if(is_selected_all_lyrics){
            myCell.checkbox_checked()
        }
        else{
            myCell.checkbox_unchecked()
        }
        
        if(!is_selected_all_lyrics){
            if(checked_indexes.contains(indexPath.row)){
                myCell.checkbox_checked()
            }
        }
        
        if(myData.project == "no_project")
        {
            myCell.name.text = "No Project Assigned"
            myCell.name.textColor = UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1)
        }
        else
        {
            myCell.name.text = myData.project
            myCell.name.textColor = UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)
        }
        
        myCell.desc.text = myData.desc
        myCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        myCell.tapSelectLyrics = { (cell) in
            let myData = self.lyrics_list[myCell.select_btn_ref.tag]
            let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "create_lyrics_sid") as! create_lyrics_VC
            
            if let desc = myData.desc
            {
                popvc.main_string = desc
            }
            
            if let project = myData.project
            {
                popvc.current_project = project
            }
            
            if let mykey = myData.lyrics_key
            {
                popvc.update_key = mykey
            }

            popvc.update_flag = true
            self.present(popvc, animated: true, completion: nil)
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
                let all_lyrics_length = self.lyrics_list.count
                if(selected_length == all_lyrics_length)
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
        }
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotiationLyrics(press:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        myCell.addGestureRecognizer(longPressGestureRecognizer)
        return myCell    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            let myData = self.lyrics_list[indexPath.row]
            let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "create_lyrics_sid") as! create_lyrics_VC
            
            if let desc = myData.desc{
                popvc.main_string = desc
            }
            if let project_name = myData.project{
                popvc.current_project_name = project_name
            }
            if let project = myData.project_key{
                popvc.current_project = project
            }
            if let mykey = myData.lyrics_key{
                popvc.update_key = mykey
            }
            popvc.update_flag = true
            
            self.present(popvc, animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let share = UITableViewRowAction(style: .normal, title: "") { action, index in
            var no_project_lyrics : [String] = []
            var project_lyrics : [String] = []
            
            if(self.lyrics_list[editActionsForRowAt.row].project_key == ""){
                no_project_lyrics.append(self.lyrics_list[editActionsForRowAt.row].lyrics_key!)
            }else{
                project_lyrics.append(self.lyrics_list[editActionsForRowAt.row].project_key!)
            }
            
            self.share_project_noproject_lyrics(no_project_lyrics: no_project_lyrics, project_lyrics: project_lyrics)
        }
        share.setIcon(iconImage: UIImage(named: "upload")!, backColor: UIColor.white, cellHeight: 74.0, action_title: "share", ylblpos: 1)
        
        let delete = UITableViewRowAction(style: .normal, title: "") { action, index in
            let ac = UIAlertController(title: "Delete", message: "Are you sure you want to delete?", preferredStyle: .alert)
            let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
            let titleAttrString = NSMutableAttributedString(string: "Delete", attributes: attributes)
            ac.setValue(titleAttrString, forKey: "attributedTitle")
            ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
            ac.addAction(UIAlertAction(title: "Cancel", style: .default)
            {
                (result : UIAlertAction) -> Void in
            })
            ac.addAction(UIAlertAction(title: "Delete", style: .default)
            {
                (result : UIAlertAction) -> Void in
                if let pkey = self.lyrics_list[index.row].project_key{
                    if let lkey = self.lyrics_list[index.row].lyrics_key{
                        self.delete_lyrics(project_key: pkey, lyrics_key: lkey)
                        self.get_no_project_data()
                    }
                }
            })
            self.present(ac, animated: true)
        }
        delete.setIcon(iconImage: UIImage(named: "garbage")!, backColor: UIColor.white, cellHeight: 74.0, action_title: "garbage", ylblpos: 1)
        //delete.backgroundColor = UIColor(patternImage: UIImage(named: "garbage")!)
        
        return [delete, share]
    }
    
    func addAnnotiationLyrics(press: UILongPressGestureRecognizer)
    {
        let touchPoint = press.location(in: self.lyrics_tbl_view_ref)
        let indexPath = self.lyrics_tbl_view_ref.indexPathForRow(at: touchPoint)
        if let index = indexPath
        {
            let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in}
            alertController.addAction(cancelAction)
            
            let shareAction = UIAlertAction(title: "Share", style: .default) { action in
                
                var no_project_lyrics : [String] = []
                var project_lyrics : [String] = []
               
                if(self.lyrics_list[index.row].project_key == ""){
                    no_project_lyrics.append(self.lyrics_list[index.row].lyrics_key!)
                }else{
                    project_lyrics.append(self.lyrics_list[index.row].project_key!)
                }
                
                self.share_project_noproject_lyrics(no_project_lyrics: no_project_lyrics, project_lyrics: project_lyrics)
                
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
                })
                ac.addAction(UIAlertAction(title: "Delete", style: .default)
                {
                    (result : UIAlertAction) -> Void in
                    if let pkey = self.lyrics_list[index.row].project_key{
                        if let lkey = self.lyrics_list[index.row].lyrics_key{
                            self.delete_lyrics(project_key: pkey, lyrics_key: lkey)
                            self.get_no_project_data()
                        }
                    }
                })
                self.present(ac, animated: true)
            }
            alertController.addAction(destroyAction)
            self.present(alertController, animated: true) {}
        }
    }
    
    //________________________________ Fetch & Display Lyrics  ___________________________________
    
    func get_no_project_data()
    {
        myActivityIndicator.startAnimating()
       
            if Auth.auth().currentUser?.uid != nil
            {
                let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                userRef.child("no_project").child("lyrics").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                
                    self.lyrics_list.removeAll()
                    for snap in snapshot.children
                    {
                        let userSnap = snap as! DataSnapshot
                        if userSnap.key != ""
                        {
                            let lyrics_key = userSnap.key
                            if userSnap.value != nil
                            {
                                let data = userSnap.value as! NSDictionary
                                var lyrics_data = ""
                                if((data.value(forKey: "desc") as? String) != nil)
                                {
                                    lyrics_data = data.value(forKey: "desc") as! String
                                }
                                let lyrics_data_insert = lyricsListData(project: "no_project", desc: lyrics_data, lyrics_key:lyrics_key, project_key:"", sort_key: lyrics_key)
                                self.lyrics_list.append(lyrics_data_insert)
                            }
                        }
                    }
                    self.come_from_project_data = true
                    
                    self.get_data()
                })
            }
            else
            {
                self.display_alert(msg_title: "Login First", msg_desc: "Please Login", action_title: "OK")
            }
    }
    
    func get_data()
    {
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        
        userRef.child("projects").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!self.come_from_project_data)
            {
                self.get_no_project_data()
            }
            else
            {
                self.lyrics_list_project.removeAll()
                for snap in snapshot.children
                {
                    let userSnap = snap as! DataSnapshot
                    if userSnap.key != ""
                    {
                        let project_key = userSnap.key
                        var mysort_key = ""
                        if userSnap.value != nil
                        {
                            let project_value = userSnap.value as! NSDictionary
                            
                            if let get_sort_key = project_value.value(forKey: "lyrics_modified") as? String{
                                mysort_key = get_sort_key
                            }else{
                                mysort_key = project_key
                            }
                            
                            if((project_value.value(forKey: "project_name") as? String) != nil)
                            {
                                let project_name = project_value.value(forKey: "project_name") as! String
                                if((project_value.value(forKey: "lyrics") as? NSDictionary) != nil)
                                {
                                    let lyrics_data =  project_value.value(forKey: "lyrics") as! NSDictionary
                                    self.display_project_data(project_name: project_name, project_value: lyrics_data,project_key: project_key, sort_key: mysort_key)
                                }
                            }
                        }
                    }
                }
                self.come_from_project_data = false
                self.myActivityIndicator.stopAnimating()
                
                self.lyrics_list_project = self.lyrics_list_project.reversed()
                
                for i in self.lyrics_list_project{
                    self.lyrics_list.append(i)
                }
                
                if(self.lyrics_list.count > 0)
                {
                    let myArrayOfTuples = self.lyrics_list.sorted{
                        guard let d1 = $0.sort_key, let d2 = $1.sort_key else { return false }
                        return d1 < d2
                    }
                    
                    self.lyrics_list = myArrayOfTuples
                    self.lyrics_list = self.lyrics_list.reversed()
                    self.lyrics_tbl_view_ref.reloadData()
                }
                else
                {
                    self.lyrics_tbl_view_ref.reloadData()
                    self.no_lyrics_view_ref.alpha = 1.0
                    self.checkOpenLyricsRecording()
                }
            }
        })
    }
    
    func display_project_data(project_name : String , project_value : NSDictionary, project_key : String, sort_key : String)
    {
        let lyrics_key = project_value.allKeys as! [String]
        for key in lyrics_key
        {
            let lyrics_data = project_value.value(forKey: key) as! NSDictionary
            let desc = lyrics_data.value(forKey: "desc") as! String
            let lyrics_data_insert = lyricsListData(project: project_name, desc: desc, lyrics_key:key, project_key:project_key, sort_key: sort_key)
            self.lyrics_list_project.append(lyrics_data_insert)
        }
        //self.lyrics_tbl_view_ref.reloadData()
    }
    
    //________________________________ select / deselect Lyrics  ___________________________________
    
    @IBAction func select_all_lyrics(_ sender: Any)
    {
        if(is_selected_all_lyrics){
            deselect_all_lyrics()
        }
        else{
            select_all_lyrics()
        }
    }
    
    func select_all_lyrics()
    {
        select_all_img_ref.layer.borderWidth = 0.0
        checked_indexes.removeAll()
        for i in 0..<lyrics_list.count
        {
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
        }else{
            self.btn_share_ref.alpha = 0.0
            self.img_share_ref.alpha = 0.0
        }
        lyrics_tbl_view_ref.reloadData()
    }
    
    func deselect_all_lyrics()
    {
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
        lyrics_tbl_view_ref.reloadData()
    }
    
    //________________________________ Manage delete , share view  ___________________________________
    
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
            lyrics_tbl_view_ref.reloadData()
        }
        else
        {
            share_delete_view_ref.alpha = 1.0
            top_contraint_tblview.constant = 80.0
            is_open_share_delet_view = true
            display_select_view = false
            lyrics_tbl_view_ref.reloadData()
        }
    }
    
    //________________________________ Delete Lyrics  ___________________________________
    
    @IBAction func delete_lyrics(_ sender: Any)
    {
        myActivityIndicator.startAnimating()
        if(checked_indexes.count < 1)
        {
            display_alert(msg_title: "Required", msg_desc: "You must have to select lyrics.", action_title: "OK")
            myActivityIndicator.stopAnimating()
        }
        else
        {
            let myMsg = "Are you sure you want to delete Selected Lyrics ?"
            let ac = UIAlertController(title: "Delete", message: myMsg, preferredStyle: .alert)
            let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
            let titleAttrString = NSMutableAttributedString(string: "Delete Selected Lyrics?", attributes: attributes)
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
                
                let limit = self.lyrics_list.count
                for i in 0 ..< limit
                {
                    if(self.checked_indexes.contains(i))
                    {
                        self.delete_lyrics(project_key: self.lyrics_list[i].project_key!, lyrics_key: self.lyrics_list[i].lyrics_key!)
                    }
                    if(i == limit - 1)
                    {
                        self.share_delete_view_ref.alpha = 0.0
                        self.top_contraint_tblview.constant = 0.0
                        self.is_open_share_delet_view = false
                        self.display_select_view = true
                        self.lyrics_list.removeAll()
                        self.lyrics_tbl_view_ref.reloadData()
                        self.get_no_project_data()
                    }
                }
            })
            present(ac, animated: true)
        }
    }
    
    func delete_lyrics(project_key : String,lyrics_key : String)
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        if(project_key == "")
        {
        userRef.child("no_project").child("lyrics").child(lyrics_key).removeValue(completionBlock: { (error, database_ref) in
                
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    self.myActivityIndicator.stopAnimating()
                }
                else{
                    
                    self.myActivityIndicator.stopAnimating()
                   
                }
            })
        }
        else
        {
        userRef.child("projects").child(project_key).child("lyrics").child(lyrics_key).removeValue(completionBlock: { (error, database_ref) in
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    self.myActivityIndicator.stopAnimating()
                }
                else{
                    self.myActivityIndicator.stopAnimating()
                    //self.get_no_project_data()
                }
            })
        }
    }
    
    //________________________________ Share Lyrics  ___________________________________
    
    @IBAction func share_lyrics(_ sender: Any)
    {
        myActivityIndicator.startAnimating()
        if(checked_indexes.count < 1)
        {
            display_alert(msg_title: "Required", msg_desc: "You must have to select lyrics.", action_title: "OK")
            myActivityIndicator.stopAnimating()
        }
        else
        {
            //var activityItem: [String] = ["Lyrics" as String]
            var no_project_lyrics : [String] = []
            var project_lyrics : [String] = []
            for i in 0..<lyrics_list.count
            {
                if(checked_indexes.contains(i))
                {
                    if(lyrics_list[i].project_key == ""){
                        no_project_lyrics.append(lyrics_list[i].lyrics_key!)
                    }else{
                        project_lyrics.append(lyrics_list[i].project_key!)
                    }
                }
            }
            share_project_noproject_lyrics(no_project_lyrics: no_project_lyrics, project_lyrics: project_lyrics)
            self.deselect_all_lyrics()
            self.manage_delete_share_view()
        }
    }
    
    func share_project_noproject_lyrics(no_project_lyrics : [String], project_lyrics : [String])
    {
        let myuserid = Auth.auth().currentUser?.uid
        if(myuserid != nil)
        {
            self.myActivityIndicator.startAnimating()
            var request = URLRequest(url: URL(string: MyConstants.share_lyrics)!)
            request.httpMethod = "POST"
            let no_project_string = "&no_project_lyrics_ids="+no_project_lyrics.joined(separator: ",")
            let project_string = "&project_lyrics="+project_lyrics.joined(separator: ",")
            let postString = "userid="+myuserid!+no_project_string+project_string
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                
                guard let data = data, error == nil else{
                   
                    DispatchQueue.main.async (execute: {
                        self.myActivityIndicator.stopAnimating()
                    })
                    self.display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                    DispatchQueue.main.async (execute: {
                        self.myActivityIndicator.stopAnimating()
                    })
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
                        
                        DispatchQueue.main.async (execute: {
                            self.myActivityIndicator.stopAnimating()
                        })
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                }
            };task.resume()
        }
    }
    
    //________________________________ Search Lyrics  ___________________________________
    
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
        
        if(search_text == "no_project")
        {
            userRef.child("no_project").child("lyrics").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                self.lyrics_list.removeAll()
                
                for snap in snapshot.children
                {
                    let userSnap = snap as! DataSnapshot
                    let lyrics_key = userSnap.key
                    let data = userSnap.value as! NSDictionary
                    var lyrics_data = ""
                    if((data.value(forKey: "desc") as? String) != nil)
                    {
                        lyrics_data = data.value(forKey: "desc") as! String
                    }
                    let lyrics_data_insert = lyricsListData(project: "no_project", desc: lyrics_data, lyrics_key:lyrics_key, project_key:"", sort_key: lyrics_key)
                    self.lyrics_list.append(lyrics_data_insert)
                }
                
                
                
                if(self.lyrics_list.count > 0)
                {
                    let myArrayOfTuples = self.lyrics_list.sorted{
                        guard let d1 = $0.sort_key, let d2 = $1.sort_key else { return false }
                        return d1 < d2
                    }
                    self.lyrics_list = myArrayOfTuples
                    
                    self.lyrics_list = self.lyrics_list.reversed()
                    
                }
                self.lyrics_tbl_view_ref.reloadData()
                self.myActivityIndicator.stopAnimating()
                
                if(self.lyrics_list.count == 0){
                    MyConstants.search_not_found_alert(myVC: self, searchRef: self.search_bar_ref)
                }
                
                
            })
        }
        else
        {
            userRef.child("projects").queryOrdered(byChild: "project_name").queryStarting(atValue: search_text).queryEnding(atValue:search_text+MyVariables.search_last_char).observeSingleEvent(of: .value, with: { (snapshot) in
                self.lyrics_list.removeAll()
                self.lyrics_list_project.removeAll()
               
                for snap in snapshot.children
                {
                    let userSnap = snap as! DataSnapshot
                    if (userSnap.hasChild("lyrics")){
                        let project_key = userSnap.key
                        let project_value = userSnap.value as! NSDictionary
                        let project_name = project_value.value(forKey: "project_name") as! String
                        let lyrics_data =  project_value.value(forKey: "lyrics") as! NSDictionary
                        var mysort_key = ""
                        if let get_sort_key = project_value.value(forKey: "lyrics_modified") as? String{
                            mysort_key = get_sort_key
                        }else{
                            mysort_key = project_key
                        }
                        
                        self.display_project_data(project_name: project_name, project_value: lyrics_data,project_key: project_key, sort_key: mysort_key)
                    }
                }
                
                self.lyrics_list_project = self.lyrics_list_project.reversed()
                
                for i in self.lyrics_list_project{
                    self.lyrics_list.append(i)
                }
                
                if(self.lyrics_list.count > 0)
                {
                    let myArrayOfTuples = self.lyrics_list.sorted{
                        guard let d1 = $0.sort_key, let d2 = $1.sort_key else { return false }
                        return d1 < d2
                    }
                    self.lyrics_list = myArrayOfTuples
                    self.lyrics_list = self.lyrics_list.reversed()
                }
                
                self.lyrics_tbl_view_ref.reloadData()
                self.myActivityIndicator.stopAnimating()
                
                if(self.lyrics_list.count == 0){
                    MyConstants.search_not_found_alert(myVC: self, searchRef: self.search_bar_ref)
                }
                
            })
        }
    }
    
    
    @IBAction func open_recording(_ sender: UIButton) {
        
        open_recording()
        
       // let newVC = self.storyboard?.instantiateViewController(withIdentifier: "RecordingListVC_sid") as! RecordingListVC
       // self.navigationController?.pushViewController(newVC, animated: false)
    }
    
    func open_recording(){
        self.tabBarController?.selectedIndex = 3
        
        let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordingListVC_sid") as! RecordingListVC
        
        self.addChildViewController(child_view)
        child_view.view.frame = self.view.frame
        self.view.addSubview(child_view.view)
        
        child_view.didMove(toParentViewController: self)
    }
    
    @IBAction func open_lyrics(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 3
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "LyricsVC_sid") as! LyricsVC
        self.navigationController?.pushViewController(newVC, animated: false)
    }
    
    //________________________________ Display Alert  ___________________________________
    
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
}
