//
//  MyConstants.swift
//  Tully Dev
//
//  Created by Kathan on 15/03/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

class MyConstants : NSObject
{
    //MARK: - API
    static var production_server = "https://tullyconnect.com/"
    static var test_server = "http://34.227.113.99/"
    
    static var base_url = MyConstants.test_server
    
    // url - http://34.227.113.99:3000/api/process_audio
    
    static var share_project = MyConstants.base_url + "api/share/project"
    static var share_lyrics = MyConstants.base_url + "api/share/lyrics"
    static var engineer_invite = MyConstants.base_url + "api/engineer/invite"
    static var share_copytotully = MyConstants.base_url + "api/share/audiofile"
    static var share_recordings = MyConstants.base_url + "api/share/recordings"
    static var share_master_recordings = MyConstants.base_url + "api/share/master"
    static var share_purchase_recordings = MyConstants.base_url + "api/share/beat"
    static var home_import_link = MyConstants.base_url + "artist/dashboard"
    
    static var audioProcess = "http://34.227.113.99:3000/api/process_audio"
    static var marketplace_generate_purchase_free_link = MyConstants.base_url + "mobile/api/payment/sellFreeBeats"
    static var marketplace_get_data = MyConstants.base_url + "mobile/api/instore/get?page="
    static var marketplace_generate_purchase_link = MyConstants.base_url + "mobile/api/beat/generate_purchase_link"
    static var audio_analyzer_purchase_link = MyConstants.base_url + "mobile/api/payment/get_analyzer_payment_link"
    static var audio_analyzer_unsubscribe_link = MyConstants.base_url + "mobile/api/payment/cancel_audio_analyzer_subscription"
    static var audio_analyzer_payment_link = MyConstants.base_url + "payment/accept/audio_analyzer/"

    static var dataMouseApi = "https://api.datamuse.com/words?rel_rhy="
    static var api_security_code = "api_code"
    static var api_security_time = "api_time"
    static var Authorization = "Token"
    
    // For Engineer InfoDisplay
    
    static var tEngInfoAll = "tEngineerInfoDisplayAll"
    static var tEngInfoHomeBtn = "tEngineerInfoHomeBtn"
    static var tEngInfoHomeDropdown = "tEngineerInfoHomeDropdown"
    static var tEngInfoSetting = "tEngineerInfoSetting"
    static var tEngInfoHomePlusBtn = "tEngineerInfoHomePlusBtn"
    
    // Notification Token
    
    static var tNotificationToken = "notificationToken"
    
    static var WhiteActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    //MARK: - TextView
    static func closeTextView(myView : UIView){
        myView.endEditing(true)
    }
    
    //MARK: - Activity Indicator
    static func setWhiteActivityIndicator(myView : UIView){
        WhiteActivityIndicator.center = myView.center
        myView.addSubview(WhiteActivityIndicator)
    }
    static func startWhiteActivityIndicator(){
        WhiteActivityIndicator.startAnimating()
    }
    static func stopWhiteActivityIndicator(){
        WhiteActivityIndicator.stopAnimating()
    }
    
    //MARK: - Show & Remove Animate
    
    static func showAnimate(myView : UIView){
        myView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        myView.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            myView.alpha = 1.0
            myView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    static func removeAnimate(myView : UIView, myVC : UIViewController){
        UIView.animate(withDuration: 0.25, animations: {
            myView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            myView.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished){
                myVC.parent?.viewDidLoad()
                myVC.willMove(toParentViewController: nil)
                myView.removeFromSuperview()
                myVC.removeFromParentViewController()
            }
        })
    }
    
    //MARK: - Display Alerts
    
    static func normal_display_alert(msg_title : String , msg_desc : String ,action_title : String, myVC : UIViewController){
        DispatchQueue.main.async {
            let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: action_title, style: .default){
                (result : UIAlertAction) -> Void in
            })
            myVC.present(ac, animated: true)
        }
    }
    
    static func display_alert(msg_title : String , msg_desc : String ,action_title : String, navpop : Bool, myVC : UIViewController){
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
            let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
            let titleAttrString = NSMutableAttributedString(string: msg_title, attributes: attributes)
            ac.setValue(titleAttrString, forKey: "attributedTitle")
            ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
            ac.addAction(UIAlertAction(title: action_title, style: .default){
                (result : UIAlertAction) -> Void in
                if(navpop){
                    myVC.navigationController?.popViewController(animated: true)
                }
            })
            myVC.present(ac, animated: true)
        }
        
    }
    
    static func search_not_found_alert(myVC : UIViewController, searchRef : UISearchBar){
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Please search again", message: "No files can be found with this search result! (Search is case-sensitive).", preferredStyle: .alert)
            
            let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
            let titleAttrString = NSMutableAttributedString(string: "Please search again", attributes: attributes)
            ac.setValue(titleAttrString, forKey: "attributedTitle")
            ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
            ac.addAction(UIAlertAction(title: "Ok", style: .default){
                (result : UIAlertAction) -> Void in
                searchRef.becomeFirstResponder()
            })
            myVC.present(ac, animated: true)
        }
        
    }
    
}
