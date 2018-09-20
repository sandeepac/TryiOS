//
//  ConverFileVC.swift
//  Tully Dev
//
//  Created by Kathan on 11/08/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

class ConverFileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close_btn_click(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func convertInBackground(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        
    }
    

}
