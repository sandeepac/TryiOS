//
//  CreateProjectVC.swift
//  Tully Dev
//
//  Created by macbook on 6/25/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Firebase
import Mixpanel

protocol giveProjectDataProtocol
{
    func setProjectData(projectId : String, projectName : String, recording_url : URL)
}
class CreateProjectVC: UIViewController, UITextFieldDelegate
{
    
    @IBOutlet var imgview_ref: UIImageView!
    @IBOutlet var txt_project_nm: UITextField!
    
    var project_id : String = ""
    var bpm = 0
    var key = ""
    var project_name : String = ""
    var audio_url : URL? = nil
    var audio_name : String = ""
    var audio_id : String = ""
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var giveProjectDataProtocol : giveProjectDataProtocol?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        MyConstants.showAnimate(myView: self.view)
        custom_design()
        txt_project_nm.becomeFirstResponder()
    }
    
    func custom_design()
    {
        imgview_ref.layer.cornerRadius = 5.0
        imgview_ref.clipsToBounds = true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        view.endEditing(true)
        return false
    }
    
    @IBAction func btn_cancel(_ sender: Any) {
        MyConstants.removeAnimate(myView: self.view, myVC: self)
    }
    
    @IBAction func btn_careate_project(_ sender: Any)
    {
        myActivityIndicator.startAnimating()

            self.project_name = self.txt_project_nm.text!
            if(self.project_name != "")
            {
                if(self.project_name == "no_project")
                {
                    MyConstants.normal_display_alert(msg_title: "Validation Error", msg_desc: "You can not give project name as 'no_project', Try another name", action_title: "Try again", myVC: self)
                    self.myActivityIndicator.stopAnimating()
                }
                else
                {
                    let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                    userRef.child("projects").queryOrdered(byChild: "project_name").queryEqual(toValue: self.project_name).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if snapshot.exists()
                        {
                            MyConstants.normal_display_alert(msg_title: "Project Name Exists", msg_desc: self.project_name + " project already exists", action_title: "OK", myVC: self)
                            self.myActivityIndicator.stopAnimating()
                        }
                        else
                        {
                            self.create_new_project()
                        }
                    })
                }
            }else{
                MyConstants.normal_display_alert(msg_title: "Required !", msg_desc: "Project Name is required", action_title: "OK", myVC: self)
            }
    }
    
    func create_new_project()
    {
        view.endEditing(true)
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
    
        self.project_id = userRef.child("projects").childByAutoId().key
        let file_name = txt_project_nm.text!
        let project_name: [String: Any] = ["project_name": file_name]
    
        userRef.child("projects").child(self.project_id).setValue(project_name, withCompletionBlock: { (error, database_ref) in
                            
        if let error = error
        {
            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
            self.myActivityIndicator.stopAnimating()
        }
        else
        {
            if(self.audio_id == "-L1111aaaaaaaaaaaaaa"){
                Mixpanel.mainInstance().track(event: "Free Beat Project Created")
            }
            Mixpanel.mainInstance().track(event: "Creating project")
            self.mixpanel_project_event()
            self.project_id = database_ref.key
        }
        })
        
        save_recording_in_project()
    }
    
    func mixpanel_project_event(){
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("projects").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let count = snapshot.childrenCount
            if(count == 5){
                Mixpanel.mainInstance().track(event: "5 Projects Created")
            }else if(count == 20){
                Mixpanel.mainInstance().track(event: "20 Projects Created")
            }else if(count == 50){
                Mixpanel.mainInstance().track(event: "50 Projects Created")
            }else if(count == 75){
                Mixpanel.mainInstance().track(event: "50 Projects Created")
            }else if(count > 100){
                Mixpanel.mainInstance().track(event: "100+ Projects Created")
            }
        })
    }
    
    func save_recording_in_project()
    {
        if(audio_url != nil)
        {
            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let dataPath = documentsDirectory.appendingPathComponent("recordings/projects")
            do{
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError
            {
                MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
            }
            
            let fileNameArr = audio_url!.absoluteString.components(separatedBy: ".")
            let myfilenameExt = fileNameArr[fileNameArr.count - 1]
            let sticks = userRef.child("projects").child(self.project_id).child("recordings").childByAutoId().key
            let audio_sticks = sticks + "." + myfilenameExt
            let dest_path = dataPath.appendingPathComponent(audio_sticks)
            
            
            do
            {
                try FileManager.default.copyItem(at: audio_url!, to: dest_path)
                let fileDictionary = try FileManager.default.attributesOfItem(atPath: audio_url!.path)
                let fileSize = fileDictionary[FileAttributeKey.size]
                let mysize = fileSize as! Int64
                
                    var recording_data: [String: Any] = ["name": self.audio_name, "tid": audio_sticks, "size":mysize]
                
                    if(key != ""){
                        recording_data = ["name": self.audio_name, "tid": audio_sticks, "size": mysize, "bpm": bpm, "key": key]
                    }
                
                        if(self.project_id != "")
                        {
                            let file_name = self.txt_project_nm.text!
                            let recording_key = userRef.child("projects").child(self.project_id).child("recordings").childByAutoId().key
                            let my_project_recording: [String: Any] = ["project_name": file_name , "project_main_recording" : audio_sticks]
                            
                            
                            
                        userRef.child("projects").child(self.project_id).setValue(my_project_recording, withCompletionBlock: { (error, database_ref) in
                                
                                if let error = error
                                {
                                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                                    self.myActivityIndicator.stopAnimating()
                                }
                            })
                        userRef.child("projects").child(self.project_id).child("recordings").child(recording_key).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                                    
                                    if let error = error
                                    {
                                        MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                                        self.myActivityIndicator.stopAnimating()
                                    }
                                    else
                                    {
                                        self.audio_url = dest_path
                                        self.myActivityIndicator.stopAnimating()
                                        MyConstants.removeAnimate(myView: self.view, myVC: self)
                                    }
                            })
                            
                        userRef.child("remaining_upload").child("projects").child(self.project_id).child("recordings").child(recording_key).setValue(recording_data, withCompletionBlock: { (error, database_ref) in
                                
                                if let error = error
                                {
                                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
                                    self.myActivityIndicator.stopAnimating()
                                }else{
                                    self.myActivityIndicator.stopAnimating()
                                }
                            })
                            
                            FirebaseManager.sync_project_recording_file(myfilename_tid: audio_sticks, myfilePath: dest_path, projectId: self.project_id, rec_id: recording_key, delete_remaining: true)
                            
                            self.giveProjectDataProtocol?.setProjectData(projectId : self.project_id, projectName : self.project_name, recording_url : self.audio_url!)
                            Singleton.shared.projectID = self.project_id
                            print(Singleton.shared.projectID)
                            self.myActivityIndicator.stopAnimating()
                            MyConstants.removeAnimate(myView: self.view, myVC: self)
                            
                        }
                        else
                        {
                            MyConstants.normal_display_alert(msg_title: "Project Not Found", msg_desc: "Can't found project.", action_title: "OK", myVC: self)
                            self.myActivityIndicator.stopAnimating()
                        }
                self.giveProjectDataProtocol?.setProjectData(projectId : self.project_id, projectName : self.project_name, recording_url : self.audio_url!)
                self.myActivityIndicator.stopAnimating()
                MyConstants.removeAnimate(myView: self.view, myVC: self)
            }catch let error as NSError {
                MyConstants.normal_display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK", myVC: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
