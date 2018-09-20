//
//  RateUsVC.swift
//  Tully Dev
//
//  Created by macbook on 5/27/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit

class RateUsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        MyConstants.showAnimate(myView : self.view)
    }

    @IBAction func give_rate(_ sender: Any) {
        let app_id = 1270452390
        let url = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id\(app_id)?mt=8&action=write-review")!
        UIApplication.shared.openURL(url)
    }
    
    @IBAction func close_view(_ sender: Any) {
        MyConstants.removeAnimate(myView: self.view, myVC: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
