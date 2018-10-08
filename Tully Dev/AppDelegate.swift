//
//  AppDelegate.swift
//  Tully Dev
//
//  Created by macbook on 5/19/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import Fabric
import Crashlytics
import Mixpanel
import Intercom
import FirebaseMessaging
import UserNotifications

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,MessagingDelegate,UNUserNotificationCenterDelegate{
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        UserDefaults.standard.setValue(token, forKey: MyConstants.tNotificationToken)
        
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        if let uid = Auth.auth().currentUser?.uid{
            print(uid)
            
            let token : [String : String] = ["notificationToken" : fcmToken]
            
            FirebaseManager.getRefference().child("users").child(uid).child("settings").updateChildValues(token) { (error, reference) in
                
                if let err = error{
                    print(err.localizedDescription)
                }else{
                    print("set successfully")
                }
                
            }
            
        }else{
            print("uid not found")
        }
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
       // Intercom.setApiKey("dG9rOmY1NTEzZjk0Xzg3NWFfNGNmM184ZGM0X2Q0ZjQ0MzM5ZDM1ZjoxOjA", forAppId:"ne8l5lbm")
        FirebaseApp.configure()
        Intercom.setApiKey("ios_sdk-0c4abb168f0b10fc71407ea6e31c65eae5e10358", forAppId: "ne8l5lbm")
        
       
        Mixpanel.initialize(token: "216fa0cb7c52cffa11009d77e919a3b7")
       
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Fabric.with([Crashlytics.self])
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        //let context = avformat_alloc_context()
       
        let notificationTypes : UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)
        application.isIdleTimerDisabled = true
        MyVariables.pushNotification = true
        
       
        
        return true
    }
    
   
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        let url_absolute = url.path
        if(url_absolute.contains("m4a") || url_absolute.contains("mp3") || url_absolute.contains("wav"))
        {
            
            let fileNameArr = url_absolute.components(separatedBy: "/")
            let myfilename = String(fileNameArr[fileNameArr.count - 1])
            MyVariables.myaudio = NSData(contentsOf: url)
            MyVariables.myTitle = myfilename
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home_tabBar_sid") as! UITabBarController
            vc.selectedIndex = 0
            UIApplication.shared.keyWindow?.rootViewController = vc
            
            return true
        }
        else
        {
            let handle = FBSDKApplicationDelegate.sharedInstance().application(app, open: url,sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            return handle
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any])
    {
    
        if (Intercom.isIntercomPushNotification(userInfo)) {
            Intercom.handlePushNotification(userInfo)
        }else{
            FBSDKAppEvents.activateApp()
        }
        guard
                    let aps = userInfo[AnyHashable("aps")] as? NSDictionary,
                    let alert = aps["alert"] as? NSDictionary,
                    let body = alert["body"] as? String,
                    let title = alert["title"] as? String
                    else {
                        // handle any error here
                        return
                }
        let projectID = userInfo["project_id"]
        let senderName = userInfo["sender_name"]
        let inviteID = userInfo["invite_id"]
        
    
        
        let homeVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVCSid") as! HomeVC
        let acceptVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AcceptInviteVC") as! AcceptInviteVC
        acceptVC.projectId = projectID as! String
        acceptVC.inviter_name = senderName as! String
        acceptVC.inviteId = inviteID as! String
        let viewArray = [homeVC,acceptVC]
        addSubViewControllerDirectly(viewArray)
        
    }
    func addSubViewControllerDirectly(_ viewControllerArray: [Any]?) {
        
        window?.removeFromSuperview()
        
        let nav = UINavigationController()
        nav.isNavigationBarHidden = true
        nav.navigationBar.isTranslucent = false
        if let anArray = viewControllerArray as? [UIViewController] {
            nav.viewControllers = anArray
        }
        
        window?.rootViewController = nav
        
        window?.makeKeyAndVisible()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "nameOfNotification"), object: nil)
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        MyVariables.notifi_data = deviceToken
        Intercom.setDeviceToken(deviceToken)
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
   
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //TimerUIApplication.id
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)
    {
        if shortcutItem.type == "com.tully.app.writelyrics"
        {
            MyVariables.force_touch_open = "lyrics"
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home_tabBar_sid") as! UITabBarController
            vc.selectedIndex = 0
            UIApplication.shared.keyWindow?.rootViewController = vc
            
        }
        else if shortcutItem.type == "com.tully.app.record"
        {
            MyVariables.force_touch_open = "record"
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home_tabBar_sid") as! UITabBarController
            vc.selectedIndex = 0
            UIApplication.shared.keyWindow?.rootViewController = vc
            
        }
        
    }
 
}

