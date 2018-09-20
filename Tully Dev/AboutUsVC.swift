//
//  AboutUsVC.swift
//  Tully Dev
//
//  Created by macbook on 8/15/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit

class AboutUsVC: UIViewController {

    @IBOutlet var txtref: UITextView!
    
    override func viewDidAppear(_ animated: Bool) {
        txtref.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 21/255, green: 22/255, blue: 29/255, alpha: 1)
        
    }
    
    @IBAction func go_back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
