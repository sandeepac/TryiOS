//
//  selectedEngineerVC.swift
//  Tully Dev
//
//  Created by Kathan on 23/08/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase

class selectedEngineerVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var adminAccessSwitchRef: UISwitch!
    @IBOutlet weak var fileCollectionView: UICollectionView!
    @IBOutlet weak var engineerLblRef: UILabel!
    var engineerId = ""
    var engineerMail = ""
   
    var master_data = [MasterData]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(engineerId)
        engineerLblRef.text = engineerMail
        //collection_view_layout()
        get_files_data()
        // Do any additional setup after loading the view.
    }
    
//    func collection_view_layout()
//    {
//        DispatchQueue.main.async {
//            let layout_master : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//            layout_master.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            let master_width = self.home_master_collectionview_ref.frame.width
//            layout_master.scrollDirection = UICollectionViewScrollDirection.horizontal
//            self.width_of_img = Int(master_width/3.7)
//            layout_master.itemSize = CGSize(width: master_width/5, height: 82)
//            layout_master.minimumInteritemSpacing = 0
//            layout_master.minimumLineSpacing = 20
//            self.home_master_collectionview_ref.collectionViewLayout = layout_master
//
//            let layout_project : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//            layout_project.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            let project_width = self.home_project_collectionview_ref.frame.width
//            layout_project.scrollDirection = UICollectionViewScrollDirection.horizontal
//            layout_project.itemSize = CGSize(width: project_width/5, height: 82)
//            layout_project.minimumInteritemSpacing = 0
//            layout_project.minimumLineSpacing = 50
//            self.home_project_collectionview_ref.collectionViewLayout = layout_project
//            self.home_file_collectionview_ref.isScrollEnabled = false
//        }
//
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 21/255, green: 22/255, blue: 29/255, alpha: 1)
    }
    
    func get_files_data()
    {
        self.master_data.removeAll()
            if let uid = Auth.auth().currentUser?.uid{
                let userRef = FirebaseManager.getRefference().child(uid).ref
                
                let searchId = "0:"+engineerId
                
                userRef.child("masters").queryOrdered(byChild: "parentEngineer").queryEqual(toValue: searchId).observeSingleEvent(of: .value, with: { (snapshot) in
                    
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
                            
                            
                            let masterdata = MasterData(id: master_key, name: name, parent_id: "0", type: type, count: count, downloadUrl: downloadUrl, lyrics: lyrics, filename: fname, bpm: bpm, key: key)
                            
                            self.master_data.append(masterdata)
                            
                            
                        }
                        
                        let layout_file : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                        layout_file.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                        let file_width = self.fileCollectionView.frame.width
                        layout_file.scrollDirection = UICollectionViewScrollDirection.vertical
                        layout_file.itemSize = CGSize(width: file_width/3.7, height: 82)
                        layout_file.minimumInteritemSpacing = 0
                        layout_file.minimumLineSpacing = 20
                        self.fileCollectionView.reloadData()
//                        self.home_file_collectionview_ref.collectionViewLayout = layout_file
//                        let new_height = CGFloat(((self.HomeFileData.count/3) * 102))
//                        let scroll_height = ((CGFloat(self.have_file_view_height) + new_height) - 50)
//                        //let scroll_height = ((CGFloat(self.have_file_view_height) + new_height) - 50 - 137)
//                        self.height_constraint_of_have_file_view.constant = scroll_height
                        
                        
                        //
                       // self.fileCollectionView.reloadData()
                       
                    }
                })
            }
        
    }
    
    //MARK: COllectionView Delegate & Datasourcs
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return 0
        return master_data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let current_data = master_data[indexPath.row]
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "engineer_file_cvcell", for: indexPath) as! HomeFileCVCell
        
        if(current_data.type == "folder"){
            //myCell.img_width_constraint_ref.constant = CGFloat(width_of_img)
            //myCell.img_height_constraint_ref.constant = CGFloat(width_of_img)
            myCell.file_img_ref.image = UIImage(named: "master-folder.pdf")
            myCell.desc_lbl_ref.text = String(current_data.count!) + " items"
        }else{
            //myCell.img_width_constraint_ref.constant = CGFloat(width_of_img - 15)
            //myCell.img_height_constraint_ref.constant = CGFloat(width_of_img - 10)
            myCell.file_img_ref.image = UIImage(named: "engineerFile.pdf")
            myCell.desc_lbl_ref.text = String(current_data.count!) + " KB"
        }
        
        myCell.title_lbl_ref.text = current_data.name?.removingPercentEncoding
       
        return myCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
       
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
        
    }

    @IBAction func adminAccessChange(_ sender: UISwitch) {
        
        if(adminAccessSwitchRef.isOn){
            setAdminAccess(access: true)
        }else{
            setAdminAccess(access: false)
        }
        
    }
    
    func setAdminAccess(access : Bool){
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid).ref
            
            let currentPlanData : [String : Bool] = ["adminAccess" : access]
            
            userRef.child("engineer").child("access").child(engineerId).updateChildValues( currentPlanData) { (error, reference) in
                if let error = error{
                    print(error.localizedDescription)
                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                }
            }
            
        }else{
            MyConstants.normal_display_alert(msg_title: "Please signIn again.", msg_desc: "", action_title: "OK", myVC: self)
        }
    }
   
    @IBAction func goback(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
