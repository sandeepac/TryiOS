//
//  SubscribeViewController.swift
//  Tully Dev
//
//  Created by Prashant  on 07/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase

class SubscribeViewController: UIViewController {
    var currentlySelected = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        getNotification()
    }
    func getNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseComplete(_:)), name: Notification.Name(rawValue: "purchaseComplete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed(_:)), name: Notification.Name(rawValue: "purchaseFailed"), object: nil)
    }
    //Mark:- Custom Methods
    @objc func purchaseComplete(_ notification: Notification) {
            savePurchasePlanInFirebase()
    }

    @objc func purchaseFailed(_ notification: Notification) {
        MyConstants.normal_display_alert(msg_title: "Purchase Failed", msg_desc: "", action_title: "OK", myVC: self)
    }
    func savePurchasePlanInFirebase(){
        if let uid = Auth.auth().currentUser?.uid{
            let userRef = FirebaseManager.getRefference().child(uid).ref
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let subscriptionDate = formatter.string(from: date)
            let currentPlanData : [String : Any] = ["isActive" : true, "fromIos" : true, "planType" : currentlySelected, "subscriptionDate" : subscriptionDate]
            userRef.child("settings").child("CollaborationSubscription").updateChildValues( currentPlanData) { (error, reference) in
                if let error = error{
                    print(error.localizedDescription)
                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                } else {
                    let vc : InviteVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InviteVC") as! InviteVC
                    self.present(vc, animated:true, completion:nil)
                }
            }
            
        } else {
            MyConstants.normal_display_alert(msg_title: "Please signIn again.", msg_desc: "", action_title: "OK", myVC: self)
        }
    }
    
    
    //Mark : - Actions
    
    @IBAction func close_subscribe_btn_click(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func subscribe_plan_btn_click(_ sender: UIButton) {
        currentlySelected = "CollaboratorSubscription"
        IAPService.shared.getProducts()
        IAPService.shared.purchase(product: .inviteCollaboratorSubscription)
    }
    
}
