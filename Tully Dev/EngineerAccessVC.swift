//
//  EngineerAccessVC.swift
//  Tully Dev
//
//  Created by macbook on 1/18/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase

class EngineerAccessVC: UIViewController , UITableViewDelegate, UITableViewDataSource{
    

    @IBOutlet var engineer_tbl_ref: UITableView!
    @IBOutlet var submit_btn_ref: UIButton!
    @IBOutlet var admin_access_txt_ref: UITextField!
    
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var eng_list = [EngineerListData]()
    var userRef : DatabaseReference? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myActivityIndicator.center = view.center
        self.view.addSubview(myActivityIndicator)
        engineer_tbl_ref.tableFooterView = UIView()
        FirebaseManager.getRefference().child("engineer").child("users").keepSynced(true)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 21/255, green: 22/255, blue: 29/255, alpha: 1)
        if let uid = Auth.auth().currentUser?.uid {
            userRef = FirebaseManager.getRefference().child(uid).ref
            get_engineer_list()
        }
    }
    
    // Engineer List
    
    func get_engineer_list(){
        myActivityIndicator.startAnimating()
            userRef!.child("engineer").child("access").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                self.eng_list.removeAll()
                for snap in snapshot.children{
                    let userSnap = snap as! DataSnapshot
                    if userSnap.key != "" && userSnap.value != nil {
                        if let eng_current_data = userSnap.value as? NSDictionary{
                            if let email = eng_current_data.value(forKey: "email") as? String{
                                let eng_data = EngineerListData(uid: userSnap.key, email: email)
                                self.eng_list.append(eng_data)
                            }
                        }
                    }
                }
                self.myActivityIndicator.stopAnimating()
                if(self.eng_list.count > 0){
                    self.engineer_tbl_ref.reloadData()
                }
            })
    }
    
    // TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eng_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mycell = tableView.dequeueReusableCell(withIdentifier: "Engineer_tbl_ref", for: indexPath)
        mycell.textLabel?.text = eng_list[indexPath.row].email
        return mycell
        
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .normal, title: "") { action, index in
            let myMsg = "Are you sure you want to delete Selected Engineer ?"
            let ac = UIAlertController(title: "Delete", message: myMsg, preferredStyle: .alert)
            let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
            let titleAttrString = NSMutableAttributedString(string: "Delete Selected Engineer?", attributes: attributes)
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
                self.delete_eng(selected_index: editActionsForRowAt.row)
            })
            self.present(ac, animated: true)
        }
        delete.setIcon(iconImage: UIImage(named: "whitegarbage")!, backColor: UIColor.red, cellHeight: 48.0, action_title: "engGarbage", ylblpos: 4)
        
        let share = UITableViewRowAction(style: .normal, title: "") { action, index in
            
            print("edit click")
            
            let vc : selectedEngineerVC = UIStoryboard.init(name: "engineer", bundle: nil).instantiateViewController(withIdentifier: "selectedEngineerVC") as! selectedEngineerVC
            vc.engineerId = self.eng_list[editActionsForRowAt.row].uid!
            vc.engineerMail = self.eng_list[editActionsForRowAt.row].email!
            self.navigationController?.pushViewController(vc, animated: true)
            
//            let sb = UIStoryboard(name: "engineer", bundle: nil)
//
//            let vc : selectedEngineerVC = sb.instantiateViewController(withIdentifier: "selectedEngineerVC") as! selectedEngineerVC
//            vc.engineerId = self.eng_list[editActionsForRowAt.row].email!
//            self.navigationController?.pushViewController(vc, animated: true)
      
            
        }
        
        share.setIcon(iconImage: UIImage(named: "settings")!, backColor: UIColor.white, cellHeight: 48.0, action_title: "engShare", ylblpos: 4)
        
        return [delete,share]
    }
   
    
    // Delete Engineer
    
    func delete_eng(selected_index : Int)
    {
        if(eng_list.count >= selected_index){
            if let eng_id = eng_list[selected_index].uid{
                userRef!.child("engineer").child("access").child(eng_id).removeValue(completionBlock: { (error, dbreference) in
                    if let error = error{
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }else{
                    FirebaseManager.getRefference().child("engineer").child("users").child(eng_id).child("received_invitation").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                            for snap in snapshot.children
                            {
                                let userSnap = snap as! DataSnapshot
                                let project_key = userSnap.key
                                let project_value = userSnap.value as! String
                                if(project_value == Auth.auth().currentUser?.uid)
                                {
                                    snapshot.ref.child(project_key).removeValue(completionBlock: { (error, dbreference) in
                                        if let error = error{
                                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                                        }
                                        else
                                        {
                                            self.engineer_tbl_ref.beginUpdates()
                                            self.eng_list.remove(at: selected_index)
                                            let myindex = IndexPath(row: selected_index, section: 0)
                                            self.engineer_tbl_ref.deleteRows(at: [myindex], with: .left)
                                            self.engineer_tbl_ref.endUpdates()
                                        }
                                    })
                                }
                            }
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func add_new_request(_ sender: UIButton) {
        
        EngineerInfoDisplayVC.checkMasterDataExists().then { (found) in
            if(found){
                self.openEngineerInviteVC()
            }else{
                if let display = UserDefaults.standard.value(forKey: MyConstants.tEngInfoSetting) as? Bool{
                    if(display){
                        self.openEngineerInviteVC()
                    }else{
                        UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoSetting)
                        self.openEngineerInfoDisplayVC()
                    }
                }else{
                    UserDefaults.standard.set(true, forKey: MyConstants.tEngInfoSetting)
                    self.openEngineerInfoDisplayVC()
                }
            }
            }.catch { (err) in
                MyConstants.normal_display_alert(msg_title: err.localizedDescription, msg_desc: "", action_title: "Ok", myVC: self)
        }
        
    }
    
    func openEngineerInfoDisplayVC(){
        let vc = UIStoryboard(name: "engineer", bundle: nil).instantiateViewController(withIdentifier: "EngineerInfoVC") as! EngineerInfoVC
        present(vc, animated: true, completion: nil)
    }
    
    func openEngineerInviteVC(){
        let sb = UIStoryboard(name: "engineer", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "invite_engineer_sid") as! InviteEngineerVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func submit_btn_click(_ sender: UIButton) {
        
    }
    
    @IBAction func go_back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Display ALert
    
    func display_alert(msg_title : String, msg_desc : String, action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .destructive, handler: { (action) in
            
        }))
        self.present(ac, animated: true)
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
