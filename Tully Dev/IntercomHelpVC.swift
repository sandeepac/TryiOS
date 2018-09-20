//
//  IntercomHelpVC.swift
//  Tully Dev
//
//  Created by Kathan on 23/06/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Mixpanel
import Intercom

class IntercomHelpVC: UIViewController {
    
    var is_open = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        MyVariables.currently_selected_tab = 4
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 80/255, blue: 110/255, alpha: 1)
        DispatchQueue.main.async{
            self.is_open = true
            Mixpanel.mainInstance().track(event: "Help support")
            Intercom.presentMessenger()
            self.tabBarController?.selectedIndex = MyVariables.last_open_tab_for_inttercom_help
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
