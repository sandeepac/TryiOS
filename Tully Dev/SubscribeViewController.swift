//
//  SubscribeViewController.swift
//  Tully Dev
//
//  Created by Apple  on 07/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase

class SubscribeViewController: UIViewController {
    var currentlySelected = ""
    var projectId = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotification()
    }
    
    
    //MARK:- Custom Methods
    
    func getNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseComplete(_:)), name: Notification.Name(rawValue: "purchaseComplete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed(_:)), name: Notification.Name(rawValue: "purchaseFailed"), object: nil)
    }
    @objc func purchaseComplete(_ notification: Notification) {
        savePurchasePlanInFirebase()
    }
    
    @objc func purchaseFailed(_ notification: Notification) {
        MyConstants.normal_display_alert(msg_title: "Purchase Failed", msg_desc: "", action_title: "OK", myVC: self)
    }
    func savePurchasePlanInFirebase(){
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid).ref
            let milliseconds = Int64(Date().timeIntervalSince1970 * 1000.0)
            let currentPlanData : [String : Any] = [ "from" : "ios", "is_subscribe" : true, "plan_type" : currentlySelected, "start_date" : milliseconds]
            userRef.child("settings").child("CollaborationSubscription").updateChildValues( currentPlanData) { (error, reference) in
                if let error = error{
                    print(error.localizedDescription)
                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                } else {
                    let vc : InviteVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InviteVC") as! InviteVC
                    vc.projectCurrentId = self.projectId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            MyConstants.normal_display_alert(msg_title: Utils.shared.msgsigninAlert, msg_desc: "", action_title: "OK", myVC: self)
        }
    }
    
    
    //Mark : - Actions
    
    @IBAction func close_subscribe_btn_click(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func subscribe_plan_btn_click(_ sender: UIButton) {
        currentlySelected = "collaboration_subscription"
        IAPService.shared.getProducts()
        IAPService.shared.purchase(product: .inviteCollaboratorSubscription)
    }
    
}
