//
//  InviteSentVC.swift
//  Tully Dev
//
//  Created by macbook on 1/17/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

class InviteSentVC: UIViewController {

    @IBOutlet var sent_msg_lbl: UILabel!
    var email_address = ""
    var come_from_settings = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let msg =  "Your invitation has been successfully sent to "+email_address
        sent_msg_lbl.text = msg
        // Do any additional setup after loading the view.
        
    }

    @IBAction func btn_ok_click(_ sender: UIButton) {
        if(come_from_settings){
            self.navigationController?.popViewController(animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func go_back_btn_click(_ sender: UIButton) {
       
        self.navigationController?.popViewController(animated: true)
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
