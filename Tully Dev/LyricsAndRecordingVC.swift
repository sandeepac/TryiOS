//
//  LyricsAndRecordingVC.swift
//  Tully Dev
//
//  Created by Kathan on 23/06/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LyricsAndRecordingVC: UIViewController, fromLyricsRecording, comeFromLyricsRecording {
   

    @IBOutlet weak var no_files_view_ref: UIView!
    @IBOutlet weak var white_view: UIView!
    var have_data = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        MyVariables.currently_selected_tab = 3
        MyVariables.last_open_tab_for_inttercom_help = 3
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
        
    }
    
    
    
    func fetch_data(){
        self.have_data = false
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("no_project").child("recordings").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
                if(snapshot.childrenCount > 0){
                    UserDefaults.standard.set(false, forKey: "lyricsTabSelected")
                    self.closeView()
                    
                    
//                    self.have_data = true
//                    self.no_files_view_ref.alpha = 0.0
//
//                    let selected_lyrics = UserDefaults.standard.value(forKey: "lyricsTabSelected") as? Bool
//                    if(selected_lyrics == nil){
//                        self.dismiss(animated: false, completion: nil)
//                    }
                    
                }else{
                    userRef.child("no_project").child("lyrics").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot1) in
                        
                        if(snapshot1.exists()){
                            UserDefaults.standard.set(true, forKey: "lyricsTabSelected")
                            self.closeView()
                        }else{
                            userRef.child("projects").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot2) in
                            
                                if(snapshot2.exists()){
                                    
                                    UserDefaults.standard.set(true, forKey: "lyricsTabSelected")
                                    self.closeView()
                                    
//                                    for snap in snapshot2.children
//                                    {
//                                        let userSnap = snap as! DataSnapshot
//                                        let project_value = userSnap.value as! NSDictionary
//
//                                        if((project_value.value(forKey: "lyrics") as? NSDictionary) != nil){
//                                            self.have_data = true
//                                        }
//
//                                        if((project_value.value(forKey: "recordings") as? NSDictionary) != nil)
//                                        {
//                                            if let record_data =  project_value.value(forKey: "recordings") as? NSDictionary{
//                                                if(record_data.count > 1){
//                                                    self.have_data = true
//                                                }
//                                            }
//                                        }
//                                    }
//
//                                    if(self.have_data){
//                                        let selected_lyrics = UserDefaults.standard.value(forKey: "lyricsTabSelected") as? Bool
//                                        if(selected_lyrics == nil){
//                                            self.open_lyrics()
//                                        }
//                                        self.no_files_view_ref.alpha = 0.0
//                                    }else{
//                                        self.no_files_view_ref.alpha = 1.0
//                                    }
                                    
                                }else{
                                    self.no_files_view_ref.alpha = 1.0
                                }
                            })
                        }
                    })
                }
            })
        
    }
    
    @IBAction func open_recording(_ sender: UIButton) {
        open_recording()
    }
    
    @IBAction func open_lyriics(_ sender: UIButton) {
        open_lyrics()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if(MyVariables.open_record_lyrics){
//            MyVariables.open_record_lyrics = false
//            white_view.alpha = 0.0
//        }
       
        let selected_lyrics = UserDefaults.standard.value(forKey: "lyricsTabSelected") as? Bool
        if(selected_lyrics != nil){
            dismiss(animated: false, completion: nil)
//            if(selected_lyrics == true){
//                open_lyrics()
//            }else{
//                open_recording()
//            }
        }
//        }else{
//            if(have_data){
//                open_lyrics()
//            }
//        }
    }
    
    @IBAction func lyrics_btn(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "lyricsTabSelected")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "create_lyrics_sid") as! create_lyrics_VC
        vc.comeFromLyricsRecordingVC = true
        vc.fromLyricsRecording = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func recording_btn(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "lyricsTabSelected")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "record_sid") as! RecordVC
        vc.comeFromLyricsRecording = self
        vc.comeFromLyricsRecordingVC = true
        self.present(vc, animated: false, completion: nil)
    }
    
    func open_lyrics(){
        UserDefaults.standard.set(true, forKey: "lyricsTabSelected")
        closeView()
    }
    
    func open_recording(){
        UserDefaults.standard.set(false, forKey: "lyricsTabSelected")
        closeView()
    }
    
    func comeFromLyricsRecording(isCorrect: Bool) {
        fetch_data()
    }
    
    func comeFromLyricsRecording_Recording(isCorrect: Bool) {
        fetch_data()
    }
    
    func closeView(){
        self.parent?.viewDidLoad()
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}
