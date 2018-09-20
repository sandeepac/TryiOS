//
//  MasterDataDisplayVC.swift
//  Tully Dev
//
//  Created by macbook on 1/29/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
import UICircularProgressRing
import Mixpanel
import Alamofire

class MasterDataDisplayVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate, renameCompleteProtocol, shareSecureResponseProtocol{
    
    
    
    //MARK: - Outlets
    @IBOutlet var masterDataTblRef: UITableView!
    @IBOutlet var processRing: UICircularProgressRingView!
    @IBOutlet var download_process_view_ref: UIView!
    @IBOutlet var back_arrow_img_ref: UIImageView!
    
    //MARK: - Variables
    var master_data = [MasterData]()
    var nav_stack = [[String]]()
    var parentID = ""
    var parentCount = 0
    var controller1 = UIDocumentInteractionController()
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var flag_delete_folder = false
    var flag_decrease = false
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        back_arrow_img_ref.alpha = 0.0
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        nav_stack.append(["0","0"])
        get_master_data(parent_id: parentID)
        masterDataTblRef.tableFooterView = UIView()
    }

    //MARK: - Get Master Data
    func get_master_data(parent_id : String){
        
            if let uid = Auth.auth().currentUser?.uid{
                let userRef = FirebaseManager.getRefference().child(uid).ref
                userRef.child("masters").queryOrdered(byChild: "parent_id").queryEqual(toValue: parent_id).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists(){
                        self.back_arrow_img_ref.alpha = 1.0
                        var nodeArr = [MasterData]()
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
                            
                            nodeArr.append(masterdata)
                        }
                        self.master_data = nodeArr
                        self.masterDataTblRef.reloadData()
                        
                    }else{
                        
                        if(self.nav_stack.count == 1){
                            self.navigationController?.popViewController(animated: true)
                        }else{
                            let counter = self.nav_stack.count - 1
                            self.parentID = self.nav_stack[counter][0]
                            self.parentCount = Int(self.nav_stack[counter][1])!
                            _ = self.nav_stack.popLast()
                            self.get_master_data(parent_id: self.parentID)
                        }
                    }
                })
            }
    }

    
    //MARK: - Tableview delegates & datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return master_data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let current_Data = master_data[indexPath.row]
        let myCell : master_data_display_Cell = tableView.dequeueReusableCell(withIdentifier: "master_data_display_tbl_cell", for: indexPath) as! master_data_display_Cell
        myCell.name_lbl_ref.text = current_Data.name
        if current_Data.type == "folder"{
            myCell.file_folder_img_ref.image = UIImage(named: "master-folder.pdf")
            myCell.img_width_constraint_ref.constant = 35.0
            myCell.down_arrow_img_ref.alpha = 1.0
        }else{
            myCell.file_folder_img_ref.image = UIImage(named: "marketplace_file.pdf")
            myCell.img_width_constraint_ref.constant = 27.0
            myCell.down_arrow_img_ref.alpha = 0.0
        }
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotiationMaster))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        myCell.addGestureRecognizer(longPressGestureRecognizer)
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if master_data[indexPath.row].type == "folder"{
            if let selected_pid = master_data[indexPath.row].id{
                self.nav_stack.append([self.parentID,String(self.parentCount)])
                self.parentID = selected_pid
                self.parentCount = master_data[indexPath.row].count
                
                self.master_data.removeAll()
                get_master_data(parent_id: selected_pid)
            }
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
            vc.get_lyrics_text = master_file_data[selected_file].lyrics!
            vc.folder_id = master_file_data[selected_file].parent_id!
            self.masterDataTblRef.reloadData()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func addAnnotiationMaster(_ gestureRecognizer: UILongPressGestureRecognizer)
    {
        let touchPoint = gestureRecognizer.location(in: self.masterDataTblRef)
        if let indexPath = masterDataTblRef.indexPathForRow(at: touchPoint)
        {
            let selectedData = master_data[indexPath.row]
            let alertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in}
            alertController.addAction(cancelAction)
            
            let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
                self.rename_master(selectedData: selectedData)
            }
            alertController.addAction(renameAction)
            
            let shareAction = UIAlertAction(title: "Share", style: .default) { action in
                self.share_file(myData: selectedData)
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
                    self.deleteMasters(myData: selectedData)
                })
                self.present(ac, animated: true)
                
            }
            alertController.addAction(destroyAction)
            self.present(alertController, animated: true) {}
        }
    }
    
   
    //MARK: - Rename Share & Delete Project
    
    func rename_master(selectedData : MasterData)
    {
        let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rename_project_sid") as! RenameProjectFileVC
        child_view.renameCompleteProtocol = self
        child_view.selected_nm = selectedData.name!
        child_view.rename_file = false
        child_view.is_project = false
        child_view.rename_master = true
        child_view.project_id = selectedData.id!
        self.addChildViewController(child_view)
        child_view.view.frame = self.view.frame
        self.view.addSubview(child_view.view)
        child_view.didMove(toParentViewController: self)
    }
  
    func deleteMasters(myData : MasterData){
        if(myData.type == "folder"){
            if let currentID = myData.id{
                if let userId = Auth.auth().currentUser?.uid{
                    let userRef = FirebaseManager.getRefference().child(userId).ref
                    userRef.child("masters").queryOrdered(byChild: "parent_id").queryEqual(toValue: currentID).observeSingleEvent(of: .value, with: { (snapshot) in
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
                                
                                let masterdata = MasterData(id: master_key, name: name, parent_id: currentID, type: type, count: count, downloadUrl: downloadUrl, lyrics: lyrics, filename: fname, bpm: bpm, key: key)
                                
                                if(type == "file"){
                                    self.delete_master_file(myData: masterdata)
                                }
                            }
                            snapshot.ref.child(currentID).removeValue()
                            self.updateParentCount(myData: myData)
                        }else{
                            snapshot.ref.child(currentID).removeValue()
                            self.updateParentCount(myData: myData)
                        }
                        
                    })
                }
            }
        }else{
            self.delete_master_file(myData: myData)
            self.updateParentCount(myData: myData)
        }
    }
    
    func share_file(myData : MasterData)
    {
        let myuserid = Auth.auth().currentUser?.uid
        if(myuserid != nil)
        {
            let postString = "userid="+myuserid!+"&ids="+myData.id!
            let myurlString = MyConstants.share_master_recordings
            Mixpanel.mainInstance().track(event: "Sharing for Files")
            
            let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareSecureDownloadVC_sid") as! ShareSecureDownloadVC
            child_view.shareSecureResponseProtocol = self
            child_view.shareString = postString
            child_view.urlString = myurlString
            child_view.master_type = myData.type!
            present(child_view, animated: true, completion: nil)
            
        }
    }
    
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
                    
                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK", myVC: self)
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                    DispatchQueue.main.async {
                        self.myActivityIndicator.stopAnimating()
                        MyConstants.normal_display_alert(msg_title: "Error", msg_desc: String(describing: response), action_title: "OK", myVC: self)
                        
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
                                    
                                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: msg, action_title: "OK", myVC: self)
                                }
                            })
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            self.myActivityIndicator.stopAnimating()
                            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                        }
                    }
                }
            };task.resume()
        }catch let error {
            DispatchQueue.main.async {
                self.myActivityIndicator.stopAnimating()
                MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
            }
        }
    }
    
    
    func share_data1(myString : String, MyUrlString : String, allowDownload_shareSecurity : Bool, token : String, type : String, expireTime: Int){
        
        myActivityIndicator.startAnimating()
        
        var my_share_data : [NSMutableDictionary] = []
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(allowDownload_shareSecurity, forKey: "allow_download")
        jsonObject.setValue(type, forKey: "type")
        jsonObject.setValue(expireTime, forKey: "expiry")
        my_share_data.append(jsonObject)
        
        do{

            let data =  try JSONSerialization.data(withJSONObject: my_share_data, options:[])
            let dataString = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))

            let parameters: [String: Any] = [
                "userid": "AtmcA5IYjddt2wrIEYtiMdut08D2",
                "ids": "-LIzjl_HDOuiP8fBamuc",
                "config": dataString!
            ]
            
            let headers: HTTPHeaders = [
                "token": token,
            ]
            
            Alamofire.request(MyUrlString, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        if let result = response.result.value as? NSDictionary{
                            if let status = result.value(forKey: "status") as? Int{
                                if(status == 1){
                                    if let dict = result.value(forKey: "data") as? NSDictionary{
                                        if let myLink = dict.value(forKey: "link") as? String{
                                            let activityItem: [String] = [myLink]
                                            let avc = UIActivityViewController(activityItems: activityItem, applicationActivities: nil)
                                            self.present(avc, animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                            
                        }
                    case .failure(let error):
                        self.myActivityIndicator.stopAnimating()
                        MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "ok", myVC: self)
                    }
            }
        }catch let error {
            self.myActivityIndicator.stopAnimating()
            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
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
                MyConstants.normal_display_alert(msg_title: "Error !", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                
            }
        }
        
        FirebaseManager.delete_master_recording_file(myfilename_tid: myData.filename)
        
    }
    
    func updateParentCount(myData : MasterData){
        if let parentID = myData.parent_id{
            if let userId = Auth.auth().currentUser?.uid{
                let userRef = FirebaseManager.getRefference().child(userId).ref
                userRef.child("masters").queryOrdered(byChild: "parent_id").queryEqual(toValue: parentID).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists(){
                        let count = snapshot.childrenCount
                        userRef.child("masters/"+parentID).child("count").setValue(count)
                        self.updateUserCounter(parent_id: myData.parent_id!)
                    }else{
                        userRef.child("masters/"+parentID).child("count").setValue(0)
                        self.updateUserCounter(parent_id: myData.parent_id!)
                    }
                })
            }
        }
    }
    
    func updateUserCounter(parent_id : String){
        if let userId = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(userId).ref
            userRef.child("masters").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    let count = snapshot.childrenCount
                    userRef.child("profile/totalItems").setValue(count)
                    self.get_master_data(parent_id: parent_id)
                }else{
                    userRef.child("profile/totalItems").setValue(0)
                    self.get_master_data(parent_id: parent_id)
                }
            })
        }
    }
    
    @IBAction func go_back(_ sender: UIButton) {
        if(nav_stack.count > 0){
            self.master_data.removeAll()
            if let val = nav_stack.popLast(){
                if(val[0] == "0"){
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.parentID = val[0]
                    self.parentCount = Int(val[1])!
                    get_master_data(parent_id: self.parentID)
                }
                
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func renameDone(isSuccessful: Bool, newName: String) {
        get_master_data(parent_id: self.parentID)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
