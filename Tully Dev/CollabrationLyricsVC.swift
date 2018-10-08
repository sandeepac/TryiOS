//
//  CollabrationLyricsVC.swift
//  Tully Dev
//
//  Created by Apple on 08/10/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage


class CollabrationLyricsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate{
    
    @IBOutlet weak var lyrics_bottom_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var lyrics_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var lyrics_tbl: UITableView!
    @IBOutlet weak var lyrics_txtView: UITextView!
    
    var lyriscData = [[String: Any]]()
    var current_project_id = String()
    var collaborationId = String()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lyrics_tbl.delegate = self
        self.lyrics_tbl.dataSource = self
        self.lyrics_txtView.delegate = self
        lyrics_txtView.becomeFirstResponder()
        self.lyrics_tbl.rowHeight = UITableViewAutomaticDimension
        let nibName = UINib(nibName: Utils.shared.reciverNibName, bundle: nil)
        lyrics_tbl.register(nibName, forCellReuseIdentifier: Utils.shared.reciverCellIdentifier)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        getCollabratorsData()
        getDataForTable()
    }
    
    //MARK: update Lyrics
    func updateLyricsData(){
        print(lyriscData.count)
        
        
        let userID = Auth.auth().currentUser?.uid
        let userRef = FirebaseManager.getRefference().ref
        userRef.child("collaborations").child(self.current_project_id).child(self.collaborationId).child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var isLyricsNodePresent = false
            var lyricsNodeId = ""
            
            for i in snapshot.children{
                guard let taskSnapshot = i as? DataSnapshot else {
                    return
                }
                if taskSnapshot.key == "lyrics"{
                    
                    isLyricsNodePresent = true
                    
                    for lyricsChild in taskSnapshot.children {
                        let lyricsNode = lyricsChild as! DataSnapshot
                        
                        lyricsNodeId = (lyricsNode.key as? String)!
                        break
                    }
                    
                }
            }
            
            let values = ["desc": self.lyrics_txtView.text] as [String : Any]
            if isLyricsNodePresent {
                Database.database().reference().child("collaborations").child(self.current_project_id).child(self.collaborationId).child(userID!).child("lyrics").child(lyricsNodeId).setValue(values, withCompletionBlock: { (error, reference) in
                    
                })
            } else {
                Database.database().reference().child("collaborations").child(self.current_project_id).child(self.collaborationId).child(userID!).child("lyrics").childByAutoId().setValue(values, withCompletionBlock: { (error, reference) in
                    
                })
            }
            
        })
    }
    
    //MARK: Save Lyrics
    func saveLyricsData(){
        // self.lyriscData.removeAll()
        
        let userID = Auth.auth().currentUser?.uid
        let userRef = FirebaseManager.getRefference().ref
        userRef.child("collaborations").child(self.current_project_id).child(self.collaborationId).child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var isLyricsNodePresent = false
            var lyricsNodeId = ""
            
            for i in snapshot.children{
                guard let taskSnapshot = i as? DataSnapshot else {
                    return
                }
                if taskSnapshot.key == "lyrics"{
                    
                    isLyricsNodePresent = true
                    
                    for lyricsChild in taskSnapshot.children {
                        let lyricsNode = lyricsChild as! DataSnapshot
                        
                        lyricsNodeId = (lyricsNode.key as? String)!
                        break
                    }
                    
                }
            }
            
            let values = ["desc": self.lyrics_txtView.text] as [String : Any]
            if isLyricsNodePresent {
                Database.database().reference().child("collaborations").child(self.current_project_id).child(self.collaborationId).child(userID!).child("lyrics").child(lyricsNodeId).setValue(values, withCompletionBlock: { (error, reference) in
                    
                })
            } else {
                Database.database().reference().child("collaborations").child(self.current_project_id).child(self.collaborationId).child(userID!).child("lyrics").childByAutoId().setValue(values, withCompletionBlock: { (error, reference) in
                    
                })
            }
            
            self.showToast(message: "Lyrics Saved")
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CollabrationViewController.updateViewController), userInfo: nil, repeats: true)
        })
    }
    func updateViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    func updateIsActiveStatus(isActive: Bool) {
        
        let userID = Auth.auth().currentUser?.uid
        
        let ref = Database.database().reference()
        ref.child("collaborations").child(current_project_id).child(collaborationId).child(userID!).observeSingleEvent(of: .value, with: { (snap) in
            
            if snap.exists() {
                
                guard let taskSnapshot = snap as? DataSnapshot else {
                    return
                }
                
                var receivedData = taskSnapshot.value as! [String: Any]
                
                receivedData["is_active"] = isActive
                ref.child("collaborations").child(self.current_project_id).child(self.collaborationId).child(userID!).setValue(receivedData, withCompletionBlock: { (error, reference) in
                    
                })
            }
        })
    }
    
    //MARK: TextViewDelegate method
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateIsActiveStatus(isActive: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateIsActiveStatus(isActive: false)
    }
    func textViewDidChange(_ textView: UITextView) {
        
        updateLyricsData()
    }
    override func viewWillAppear(_ animated: Bool) {
        
//        containerViewHeightConstraint.constant = CGFloat(containerViewInitialHeight)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    //MARK: Keyboard Notification methods
    func keyboardWillShow(notification:NSNotification) {
        
//        if !isKeyboardAppeared {
//
//            adjustingHeight(show:true, notification: notification)
//
//            isKeyboardAppeared = true
//        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        
//        isRecipientListShown = false
//
//        if isKeyboardAppeared {
//
//            isKeyboardAppeared = false
//
//            adjustingHeight(show:false, notification: notification)
//        }
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        
//        let userInfo = notification.userInfo!
//        
//        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        
//        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
//        
//        let changeInHeight = (keyboardFrame.height) * (show ? 1 : -1)
//        
//        keyboardHeight = Int(keyboardFrame.height)
//        
//        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
//            self.containerViewBottomConstraint.constant += changeInHeight
//        })
    }
    func getCollabratorsData() {
        
        
        
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        ref.child("collaborations").child(current_project_id).child(collaborationId).observeSingleEvent(of: .value, with: { (snap) in
            
            
         //   self.recipientList.removeAll()
            
            if snap.exists() {
                
                
                
                for task in snap.children {
                    
                    
                    
                    guard let taskSnapshot = task as? DataSnapshot else { return }
                    
                    
                    
                    guard let userIdKey = taskSnapshot.key as? String else { return }
                    
                    ref.child(userIdKey).child("profile").observeSingleEvent(of: .value, with: { (innerSnap) in
                        
                        
                        
                        if innerSnap.exists() {
                            
                            
                            
                            var receivedData = innerSnap.value as! [String: Any]
                            
                            
                            
                            receivedData["userId"] = userIdKey
                            
                         //   self.recipientList.append(receivedData)
                            
                            
                            
                         //   self.setImageOnNavigationBar()
                       
                        }
                        
                    })
                    
                    
                }
                
            }
            
        })
        
    }
    func getDataForTable(){
        
        let userID = Auth.auth().currentUser?.uid
        let userRef = FirebaseManager.getRefference().ref
        userRef.child("collaborations").child(self.current_project_id).child(self.collaborationId).observe(.value, with: { (snapshot) in
            self.lyriscData.removeAll()
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
                                self.lyrics_txtView.text = desc
                            }
                        }
                    }
                    
                }else{
                    if let receivedMessage = taskSnapshot.value as? [String: Any] {
                        var lyricsDict = [String: Any]()
                        
                        if let lyrics_color = receivedMessage["lyrics_color"] as? String{
                            lyricsDict["lyrics_color"] = lyrics_color
                        }
                        
                        if let isActive = receivedMessage["is_active"] as? Bool {
                            lyricsDict["is_active"] = isActive
                        }
                        
                        var desc = ""
                        
                        if let lyrics = receivedMessage["lyrics"] as?  NSDictionary {
                            let lyrics_key = lyrics.allKeys as! [String]
                            for key in lyrics_key
                            {
                                let lyrics_data = lyrics.value(forKey: key) as! NSDictionary
                                desc = lyrics_data.value(forKey: "desc") as! String
                                //                                self.lyriscData.append(desc)
                                lyricsDict["desc"] = desc
                            }
                        }
                        
                        if !desc.isEmpty {
                            
                            self.lyriscData.append(lyricsDict)
                        }
                        
                        if !self.lyriscData.isEmpty {
                            
                            self.lyrics_tbl.reloadData()
                        }
                        
                    }
                }
                
                
            }
            
        })
        
    }
    @IBAction func back_btn_cliked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done_btn_cliked(_ sender: Any) {
        saveLyricsData()
    }
    //MARK: - UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyriscData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = lyrics_tbl.dequeueReusableCell(withIdentifier: Utils.shared.reciverCellIdentifier, for: indexPath) as! reciverCell
        
        if let dict = lyriscData[indexPath.row] as? [String: Any] {
            
            let desc = dict["desc"] ?? ""
            cell.reciverLbl.text = desc as? String
            
            let lyricsColor = dict["lyrics_color"] ?? "#000000"
            cell.reciverLbl.textColor = hexStringToUIColor(hex: lyricsColor as! String)
            
            if let isActive = dict["is_active"] as? Bool, isActive {
                
                cell.imageViewObj.loadGif(name: "typing_indicator")
                cell.imageViewWidthConstraint.constant = 50
            }
            else {
                
                cell.imageViewWidthConstraint.constant = 0
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
