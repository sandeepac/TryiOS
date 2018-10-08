//
//  ShareSecureDownloadVC.swift
//  Tully Dev
//
//  Created by Kathan on 11/04/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Promise

protocol shareSecureResponseProtocol
{
    func shareSecureResponse(allowDownload : Bool, postStringData : String, urlString : String, isCancel : Bool, token : String, type : String, expireTime : Int)
}

class ShareSecureDownloadVC: UIViewController {

    
    var shareSecureResponseProtocol : shareSecureResponseProtocol?
    var shareString = ""
    var urlString = ""
    var master_type = ""
    
    var expire : Int = -1
    var download = false
    
    @IBOutlet weak var noBtn: UIButton!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var notExpireSwitch: UISwitch!
    @IBOutlet weak var hourSwitch: UISwitch!
    @IBOutlet weak var listenSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDesign()
    }
    
    func btnDesign(){
        noBtn.layer.cornerRadius = 22.0
        yesBtn.layer.cornerRadius = 22.0
        noBtn.layer.borderColor = UIColor.white.cgColor
        yesBtn.layer.borderColor = UIColor.white.cgColor
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        noSelected()
        notExpireSwitchSelect()
    }
    
   
    @IBAction func no(_ sender: UIButton) {
        noSelected()
    }
    
    @IBAction func yes(_ sender: UIButton) {
        yesSelected()
        
    }
    @IBAction func notExpireSwitchClick(_ sender: UISwitch) {
        if(sender.isOn){
            notExpireSwitchSelect()
        }else{
            expire = 1
        }
    }
    
    @IBAction func hourSwitchClick(_ sender: UISwitch) {
        if(sender.isOn){
            expire = 60
            listenSwitch.isOn = false
            notExpireSwitch.isOn = false
            hourSwitch.isOn = true
        }else{
            expire = 1
        }
    }
    
    @IBAction func oneListenSwitch(_ sender: UISwitch) {
        if(sender.isOn){
            expire = 0
            notExpireSwitch.isOn = false
            hourSwitch.isOn = false
            listenSwitch.isOn = true
        }else{
            expire = 1
        }
    }
    
    
    
    @IBAction func share(_ sender: UIButton) {
        
        if(expire == 1){
            MyConstants.normal_display_alert(msg_title: Utils.shared.msgExpiretime, msg_desc: "", action_title: "OK", myVC: self)
        }else{
            ApiAuthentication.get_authentication_token().then({ (token) in
                self.shareSecureResponseProtocol?.shareSecureResponse(allowDownload: self.download, postStringData: self.shareString, urlString: self.urlString, isCancel: false, token: token, type: self.master_type, expireTime : self.expire)
                self.dismiss(animated: true, completion: nil)
            }).catch({ (err) in
                MyConstants.normal_display_alert(msg_title: Utils.shared.msgError, msg_desc: err.localizedDescription, action_title: "Ok", myVC: self)
            })
        }
        
        //UIPasteboard.general.string = ""
        
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.shareSecureResponseProtocol?.shareSecureResponse(allowDownload: false, postStringData: "", urlString: urlString, isCancel: true, token: "", type: master_type, expireTime: 1)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: download & expire
    
    func yesSelected(){
        download = true
        yesBtn.backgroundColor = UIColor(red: 36/255, green: 209/255, blue: 152/255, alpha: 1.0)
        yesBtn.layer.borderWidth = 0.0
        noBtn.backgroundColor = UIColor.clear
        noBtn.layer.borderWidth = 1.0
        
    }
    
    func noSelected(){
        download = false
        noBtn.backgroundColor = UIColor(red: 36/255, green: 209/255, blue: 152/255, alpha: 1.0)
        noBtn.layer.borderWidth = 0.0
        yesBtn.backgroundColor = UIColor.clear
        yesBtn.layer.borderWidth = 1.0
        
    }
    
    func notExpireSwitchSelect(){
        expire = -1
        hourSwitch.isOn = false
        listenSwitch.isOn = false
        notExpireSwitch.isOn = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
