//
//  CollabrationVC.swift
//  Tully Dev
//
//  Created by Sandeep Chitode on 24/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase

class CollabrationVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    
    
    var arr = ["sender":"The option applicationIconBadgeNumber being set to 0 is to hide the number that This works. A little more","reciver":"when the application is in the foreground, a native UI alert box appears"]
    var currentProjectId = String()
    var collabrationID = String()
    
    
    @IBOutlet weak var userImg1: UIImageView!
    @IBOutlet weak var userImg2: UIImageView!
    @IBOutlet weak var usercountView: UIView!
    @IBOutlet weak var chatcountLbl: UILabel!
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var chatTbl: UITableView!
    
    @IBOutlet weak var lyricsTxtView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatTbl.delegate = self
        self.chatTbl.dataSource = self
        self.chatTbl.estimatedRowHeight = 50
        self.chatTbl.rowHeight = UITableViewAutomaticDimension
        self.chatTbl.reloadData()
        
        DispatchQueue.main.async {
            self.setUI()
        }

        
        let nibName = UINib(nibName: "reciverCell", bundle: nil)
        chatTbl.register(nibName, forCellReuseIdentifier: "reciverCellIdentifier")
        
        let nibNameLeft = UINib(nibName: "senderCell", bundle: nil)
        chatTbl.register(nibNameLeft, forCellReuseIdentifier: "senderCellIdentifier")
        // Do any additional setup after loading the view.
        
    }
    //MARK:-  UIDesign
    func setUI(){
        Utils.shared.set_CircleImage(imageView: userImg1)
        Utils.shared.set_CircleImage(imageView: userImg2)
        Utils.shared.set_CircleView(view: usercountView)
    }
    //MARK:- groupChat Button Cliked
    @IBAction func groupChatBtnCliked(_ sender: Any) {
        let viewController : ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatViewController
        viewController.currentProjectId = currentProjectId
        viewController.currentCollaborationId = collabrationID
        self.present(viewController, animated: true, completion: nil)
    }
    //MARK:- back button Action
    @IBAction func backBtnTapped(_ sender: Any) {
        if (self.navigationController?.viewControllers.first?.isMember(of: HomeVC.self))! == true {
            self.navigationController?.popToRootViewController(animated: false)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    //MARK:- lyrics sendButton Action
    @IBAction func chatBtnTapped(_ sender: Any) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (arr["reciver"] != nil){
            let cell = chatTbl.dequeueReusableCell(withIdentifier: "reciverCellIdentifier", for: indexPath) as! reciverCell
            cell.reciverLbl.text = arr["reciver"]
            
            return cell
        }else{
            let cell = chatTbl.dequeueReusableCell(withIdentifier: "senderCellIdentifier", for: indexPath) as! senderCell
            cell.senderLbl.text = arr["sender"]
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
