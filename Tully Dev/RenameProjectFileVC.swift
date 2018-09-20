//
//  RenameProjectFileVC.swift
//  Tully Dev
//
//  Created by macbook on 9/4/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase

protocol renameCompleteProtocol
{
    func renameDone(isSuccessful : Bool,newName : String)
}

class RenameProjectFileVC: UIViewController, UITextViewDelegate
{
    
    var selected_id = ""
    var selected_nm = ""
    var rename_file = false
    var project_id = ""
    var is_project = false
    var is_purchase = false
    var rename_master = false
    var renameCompleteProtocol : renameCompleteProtocol?
    
    @IBOutlet var txtref: UITextField!
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    @IBOutlet var rename_lbl_ref: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        txtref.text = selected_nm
        showAnimate()
        rename_lbl()
        txtref.becomeFirstResponder()
    }
    
    func rename_lbl(){
        if(rename_master){
            rename_lbl_ref.text = "Rename Your Master"
        }else if(rename_file){
            rename_lbl_ref.text = "Rename Your File"
        }else{
            rename_lbl_ref.text = "Rename Your Project"
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        view.endEditing(true)
        return false
    }
    
    func rename_no_project_file()
    {
        myActivityIndicator.startAnimating()
        
        if(txtref.text != "")
        {
            let rename_no_project_file: [String: Any] = ["name": self.txtref.text!]
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            
            userRef.child("no_project").child("recordings").child(selected_id).updateChildValues(rename_no_project_file, withCompletionBlock: { (error, database_ref) in
                
                if let error = error
                {
                    self.txtref.becomeFirstResponder()
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
                else
                {
                    self.myActivityIndicator.stopAnimating()
                    self.renameCompleteProtocol?.renameDone(isSuccessful : true, newName: self.txtref.text!)
                    self.removeAnimate()
                }
            })
        }
        else
        {
            self.myActivityIndicator.stopAnimating()
            display_alert(msg_title: "Required !", msg_desc: "Name can not be null.", action_title: "OK")
        }
    }
    
    func rename_project_file()
    {
        myActivityIndicator.startAnimating()
        
        if(txtref.text != "")
        {
            let rename_project_file: [String: Any] = ["name": self.txtref.text!]
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            userRef.child("projects").child(project_id).child("recordings").child(selected_id).updateChildValues(rename_project_file, withCompletionBlock: { (error, database_ref) in
                
                if let error = error
                {
                    self.txtref.becomeFirstResponder()
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
                else
                {
                    self.myActivityIndicator.stopAnimating()
                    self.renameCompleteProtocol?.renameDone(isSuccessful : true, newName: self.txtref.text!)
                    self.removeAnimate()
                }
            })
        }
        else
        {
            self.myActivityIndicator.stopAnimating()
            display_alert(msg_title: "Required !", msg_desc: "Name can not be null.", action_title: "OK")
        }
    }
    
    func rename_project()
    {
        myActivityIndicator.startAnimating()
        
        if(txtref.text != "")
        {
            let project_name: [String: Any] = ["project_name": self.txtref.text!]
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            userRef.child("projects").child(project_id).updateChildValues(project_name, withCompletionBlock: { (error, database_ref) in
                
                if let error = error
                {
                    self.txtref.becomeFirstResponder()
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
                else
                {
                    self.myActivityIndicator.stopAnimating()
                    self.renameCompleteProtocol?.renameDone(isSuccessful : true, newName: self.txtref.text!)
                    self.removeAnimate()
                }
            })
        }
        else
        {
            self.myActivityIndicator.stopAnimating()
            display_alert(msg_title: "Required !", msg_desc: "Name can not be null.", action_title: "OK")
        }
        
    }
    
    func rename_master_file_folder(){
        myActivityIndicator.startAnimating()
        
        if(txtref.text != "")
        {
            let master_name: [String: Any] = ["name": self.txtref.text!]
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            userRef.child("masters").child(project_id).updateChildValues(master_name, withCompletionBlock: { (error, database_ref) in
                
                if let error = error
                {
                    self.txtref.becomeFirstResponder()
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
                else
                {
                    self.myActivityIndicator.stopAnimating()
                    self.renameCompleteProtocol?.renameDone(isSuccessful : true, newName: self.txtref.text!)
                    self.removeAnimate()
                }
            })
        }
        else
        {
            self.myActivityIndicator.stopAnimating()
            display_alert(msg_title: "Required !", msg_desc: "Name can not be null.", action_title: "OK")
        }
    }
    
    func rename_purchase_file()
    {
        myActivityIndicator.startAnimating()
        
        if(txtref.text != "")
        {
            
            let filename = self.txtref.text!
            let copyfile_nm: [String: Any] = ["title": filename]
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            
            userRef.child("beats").child(project_id).updateChildValues(copyfile_nm, withCompletionBlock: { (error, database_ref) in
                
                if let error = error
                {
                    self.txtref.becomeFirstResponder()
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
                else
                {
                    self.myActivityIndicator.stopAnimating()
                    self.renameCompleteProtocol?.renameDone(isSuccessful : true, newName: self.txtref.text!)
                    self.removeAnimate()
                }
            })
        }
        else
        {
            self.myActivityIndicator.stopAnimating()
            display_alert(msg_title: "Required !", msg_desc: "Name can not be null.", action_title: "OK")
        }
    }
    
    func rename_copytotully_file()
    {
        myActivityIndicator.startAnimating()
        
        if(txtref.text != "")
        {
            
            let filename = self.txtref.text!
            let copyfile_nm: [String: Any] = ["title": filename]
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            
            userRef.child("copytotully").child(project_id).updateChildValues(copyfile_nm, withCompletionBlock: { (error, database_ref) in
                
                if let error = error
                {
                    self.txtref.becomeFirstResponder()
                    self.myActivityIndicator.stopAnimating()
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                }
                else
                {
                    self.myActivityIndicator.stopAnimating()
                    self.renameCompleteProtocol?.renameDone(isSuccessful : true, newName: self.txtref.text!)
                    self.removeAnimate()
                }
            })
        }
        else
        {
            self.myActivityIndicator.stopAnimating()
            display_alert(msg_title: "Required !", msg_desc: "Name can not be null.", action_title: "OK")
        }
    }
    
    @IBAction func rename_file_project(_ sender: UIButton) {
        
        if(rename_master){
            rename_master_file_folder()
        }else if(rename_file)
        {
            
            if(is_project)
            {
                if(project_id == "")
                {
                    rename_no_project_file()
                }
                else
                {
                    rename_project_file()
                }
            }else if(is_purchase){
                rename_purchase_file()
            }
            else
            {
                rename_copytotully_file()
            }
            
        }
        else
        {
            rename_project()
        }
        
    }
    
    @IBAction func cancle_click(_ sender: UIButton) {
        removeAnimate()
    }
    
    //________________________________ Display and Remove with animation ___________________________________
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.parent?.viewDidLoad()
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        })
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
    
    
}
