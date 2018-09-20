//
//  HomeSelectVC.swift
//  Tully Dev
//
//  Created by macbook on 1/15/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

//MARK: - Protocols
protocol Home_Selected_Protocol{
    func selectDone(newSelect : String)
}

//MARK: - Home Select View
class HomeSelectVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet var btn_project_ref: UIButton!
    @IBOutlet var btn_file_Ref: UIButton!
    @IBOutlet weak var btn_master_ref: UIButton!
    //MARK: - Variables
    var Home_Selected_Protocol : Home_Selected_Protocol?
    var selected_mode = ""
    var count_master = 0
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        set_btn_design()
        MyConstants.showAnimate(myView: self.view)
    }
    
    //MARK: - Design of button
    func set_btn_design(){
        if(selected_mode != ""){
            if(selected_mode == "file"){
                btn_file_Ref.backgroundColor = UIColor(red: 34/255, green: 209/255, blue: 151/255, alpha: 1)
                btn_file_Ref.setTitleColor(UIColor.white, for: UIControlState.normal)
            }else if(selected_mode == "project"){
                btn_project_ref.backgroundColor = UIColor(red: 34/255, green: 209/255, blue: 151/255, alpha: 1)
                btn_project_ref.setTitleColor(UIColor.white, for: UIControlState.normal)
            }else if(selected_mode == "master"){
                btn_master_ref.backgroundColor = UIColor(red: 34/255, green: 209/255, blue: 151/255, alpha: 1)
                btn_master_ref.setTitleColor(UIColor.white, for: UIControlState.normal)
            }
        }
    }
    
    
    //MARK: - file, Master , Project Click
    @IBAction func btn_file_click(_ sender: Any){
        selected_mode = "file"
        Home_Selected_Protocol?.selectDone(newSelect: selected_mode)
        MyConstants.removeAnimate(myView: self.view, myVC: self)
    }
    
    
    @IBAction func btn_master_click(_ sender: UIButton) {
        
        selected_mode = "master"
        //selected_mode = "purchase"
        Home_Selected_Protocol?.selectDone(newSelect: selected_mode)
        MyConstants.removeAnimate(myView: self.view, myVC: self)
        
//        if(count_master == 0){
//
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home_tabBar_sid") as! UITabBarController
//            vc.selectedIndex = 2
//            self.present(vc, animated: false, completion: nil)
//            MyConstants.removeAnimate(myView: self.view, myVC: self)
//        }else{
//            selected_mode = "master"
//            //selected_mode = "purchase"
//            Home_Selected_Protocol?.selectDone(newSelect: selected_mode)
//            MyConstants.removeAnimate(myView: self.view, myVC: self)
//        }
        
    }
    @IBAction func btn_project_click(_ sender: UIButton) {
        selected_mode = "project"
        Home_Selected_Protocol?.selectDone(newSelect: selected_mode)
        MyConstants.removeAnimate(myView: self.view, myVC: self)
    }
    
    @IBAction func all_btn_click(_ sender: UIButton) {
        selected_mode = "all"
        Home_Selected_Protocol?.selectDone(newSelect: selected_mode)
        MyConstants.removeAnimate(myView: self.view, myVC: self)
    }
    
    @IBAction func btn_close_view_click(_ sender: UIButton) {
        Home_Selected_Protocol?.selectDone(newSelect: selected_mode)
        MyConstants.removeAnimate(myView: self.view, myVC: self)
    }
}
