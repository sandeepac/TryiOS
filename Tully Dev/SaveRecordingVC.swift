//
//  SaveRecordingVC.swift
//  Tully Dev
//
//  Created by macbook on 5/29/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import Mixpanel

protocol myProtocol
{
    func setSavedUrl(viewedUrl : String)
    func setCurrentKey(savedKey : String)
    func setProjectKey(projectKey : String)
}

class SaveRecordingVC: UIViewController, UITextFieldDelegate
{
    //________________________________ Outlets  ___________________________________
    
    @IBOutlet var txt_record_nm: UITextField!
    @IBOutlet var imgview_ref: UIImageView!
    
    //________________________________ Variables  ___________________________________
    
    var myProtocol : myProtocol?
    var selected_project = ""
    var selected_project_key = ""
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        showAnimate()
        
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        
        if(selected_project != "")
        {
            //check_project()
        }
        txt_record_nm.becomeFirstResponder()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        view.endEditing(true)
        return false
    }
    
    
    //________________________________ Save Recording  ___________________________________
    
    @IBAction func save_Recording(_ sender: Any)
    {
        myActivityIndicator.startAnimating()
        if(txt_record_nm.text != "")
        {
            if(selected_project == "")
            {
                save_no_project_recording()
            }
            else
            {
                save_project_recording()
            }
        }
        else
        {
            display_alert(msg_title: "Required !", msg_desc: "File Name is required", action_title: "OK")
        }
    }
    
    func save_no_project_recording()
    {
        
        view.endEditing(true)
        let file_name = txt_record_nm.text!
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let dataPath = documentsDirectory.appendingPathComponent("recordings/no_project")
        
        do
        {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "Ok")
        }
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        let location = documentsDirectory.appendingPathComponent("temp.wav")
        //let sticks = String(Date().ticks)
        let sticks  = userRef.child("no_project").child("recordings").childByAutoId().key
        
        let audio_sticks = sticks + ".wav"
        let dest_path = dataPath.appendingPathComponent(audio_sticks)
        let parent_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "record_sid") as! RecordVC
        parent_view.older_path = dest_path.absoluteString
        
        do
        {
            try FileManager.default.moveItem(at: location, to: dest_path)
            
            // Getting file size
            
            let fileDictionary = try FileManager.default.attributesOfItem(atPath: dest_path.path)
            let fileSize = fileDictionary[FileAttributeKey.size]
            let mysize = fileSize as! Int64
            let recording_id  = userRef.child("no_project").child("recordings").childByAutoId().key
            
            let recording_data: [String: Any] = ["name": file_name, "tid": audio_sticks, "size":mysize]
            
        userRef.child("no_project").child("recordings").child(recording_id).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    self.myActivityIndicator.stopAnimating()
                }
            })
            
        userRef.child("remaining_upload").child("no_project").child("recordings").child(recording_id).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                
                if let error = error
                {
                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    self.myActivityIndicator.stopAnimating()
                }
                else
                {
                    self.myActivityIndicator.stopAnimating()
                }
            })
            
            Mixpanel.mainInstance().track(event: "Recording")
            FirebaseManager.sync_noproject_recording_file(myfilename_tid: audio_sticks, myfilePath: dest_path, rec_id: recording_id, delete_remaining: true)
            self.myProtocol?.setSavedUrl(viewedUrl: dest_path.absoluteString)
            self.myProtocol?.setCurrentKey(savedKey: recording_id)
            self.myProtocol?.setProjectKey(projectKey: "no_project")
            self.removeAnimate()
            self.myActivityIndicator.stopAnimating()
            
//            if(!Reachability.isConnectedToNetwork())
//            {
//            userRef.child("remaining_upload").child("no_project").child("recordings").child(recording_id).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
//                    
//                    if let error = error
//                    {
//                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
//                        self.myActivityIndicator.stopAnimating()
//                    }
//                    else
//                    {
//                        self.myActivityIndicator.stopAnimating()
//                    }
//                })
//                self.myProtocol?.setSavedUrl(viewedUrl: dest_path.absoluteString)
//                self.myProtocol?.setCurrentKey(savedKey: recording_id)
//                self.myProtocol?.setProjectKey(projectKey: "no_project")
//                self.removeAnimate()
//                self.myActivityIndicator.stopAnimating()
//            }
        }
        catch let error as NSError {
            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            myActivityIndicator.stopAnimating()
        }
    }
    
    func save_project_recording()
    {
        
        view.endEditing(true)
        let file_name = txt_record_nm.text!
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let dataPath = documentsDirectory.appendingPathComponent("recordings/projects")
        
        do
        {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "Ok")
        }
        
        let location = documentsDirectory.appendingPathComponent("temp.wav")
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        
        let sticks  = userRef.child("projects").child(self.selected_project_key).child("recordings").childByAutoId().key
        //let sticks = String(Date().ticks)
        let audio_sticks = sticks + ".wav"
        let dest_path = dataPath.appendingPathComponent(audio_sticks)
        
        let parent_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "record_sid") as! RecordVC
        parent_view.older_path = dest_path.absoluteString
        
        do
        {
            try FileManager.default.moveItem(at: location, to: dest_path)
            
            let fileDictionary = try FileManager.default.attributesOfItem(atPath: dest_path.path)
            let fileSize = fileDictionary[FileAttributeKey.size]
            let mysize = fileSize as! Int64
            
            let recording_data: [String: Any] = ["name": file_name, "tid": audio_sticks, "size":mysize]
            let recording_key  = userRef.child("projects").child(self.selected_project_key).child("recordings").childByAutoId().key
            
            if(self.selected_project_key != "")
            {
            userRef.child("projects").child(self.selected_project_key).child("recordings").child(recording_key).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                    if let error = error
                    {
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                        self.myActivityIndicator.stopAnimating()
                    }
                })
                
            userRef.child("remaining_upload").child("projects").child(self.selected_project_key).child("recordings").child(recording_key).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                    
                    if let error = error{
                        MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                        self.myActivityIndicator.stopAnimating()
                    }else{
                        self.myActivityIndicator.stopAnimating()
                    }
                })
                
                Mixpanel.mainInstance().track(event: "Recording in project")
                FirebaseManager.sync_project_recording_file(myfilename_tid: audio_sticks, myfilePath: dest_path, projectId: self.selected_project_key, rec_id: recording_key, delete_remaining: true)
                self.myProtocol?.setSavedUrl(viewedUrl: dest_path.absoluteString)
                self.myProtocol?.setCurrentKey(savedKey:recording_key)
                self.myProtocol?.setProjectKey(projectKey: self.selected_project_key)
                self.myActivityIndicator.stopAnimating()
                self.removeAnimate()
                
            }
            else
            {
                self.display_alert(msg_title: "Project Not Found", msg_desc: "Can't found project.", action_title: "OK")
                self.myActivityIndicator.stopAnimating()
            }
            
//            if(!Reachability.isConnectedToNetwork())
//            {
//            userRef.child("remaining_upload").child("projects").child(self.selected_project_key).child("recordings").child(recording_key).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
//
//                    if let error = error
//                    {
//                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
//                        self.myActivityIndicator.stopAnimating()
//                    }else{
//                        self.myActivityIndicator.stopAnimating()
//                    }
//                })
//                self.myProtocol?.setSavedUrl(viewedUrl: dest_path.absoluteString)
//                self.myProtocol?.setCurrentKey(savedKey:recording_key)
//                self.myProtocol?.setProjectKey(projectKey: self.selected_project_key)
//                self.myActivityIndicator.stopAnimating()
//                self.removeAnimate()
//            }
        }
        catch let error as NSError {
            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
        }
    }
    
    
    // Display Alert
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    
    @IBAction func close_view(_ sender: Any)
    {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}
