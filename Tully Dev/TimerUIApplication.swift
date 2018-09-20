//
//  TimerUIApplication.swift
//  Tully Dev
//
//  Created by macbook on 11/14/17.
//  Copyright © 2017 Tully. All rights reserved.

import Foundation
import UIKit
import Firebase
    
extension NSNotification.Name {
        public static let TimeOutUserInteraction: NSNotification.Name = NSNotification.Name(rawValue: "TimeOutUserInteraction")
    
}

class TimerUIApplication: UIApplication {
        
    static let ApplicationDidTimoutNotification = "AppTimout"
    let timeoutInSeconds: TimeInterval = 30 * 60
    var idleTimer: Timer?
    var initialize_notification = false
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        if(!initialize_notification){
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(appWillResignActive(_:)),
                                                   name: .UIApplicationWillResignActive,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(appDidBecomeActive(_:)),
                                                   name: .UIApplicationDidBecomeActive,
                                                   object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
            initialize_notification = true
        }
        
        if idleTimer != nil {
            self.resetIdleTimer()
        }
        
        if let touches = event.allTouches {
            for touch in touches {
                if touch.phase == UITouchPhase.began {
                    self.resetIdleTimer()
                }
            }
        }
    }
    
    func resetIdleTimer(){
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds, target: self, selector: #selector(self.idleTimerExceeded), userInfo: nil, repeats: false)
    }
    
    func idleTimerExceeded(){
        NotificationCenter.default.post(name:Notification.Name.TimeOutUserInteraction, object: nil)
        if(!MyVariables.notification_recording && !MyVariables.notification_audio_play){
            if Auth.auth().currentUser != nil{
                do{
                    try Auth.auth().signOut()
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                    let yourVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login_sid") as! LogInVC
                    appDelegate.window?.rootViewController = yourVC
                    appDelegate.window?.makeKeyAndVisible()
                }catch let error as NSError{
                    print(error.localizedDescription)
                }
            }
        }else{
            resetIdleTimer()
        }
    }
    
    @objc func appWillResignActive(_ notification: Notification) {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
    }
    
    @objc private func appDidBecomeActive(_ notification: Notification) {
        resetIdleTimer()
    }
}

