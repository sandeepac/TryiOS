//
//  EngineerInfoVC.swift
//  Tully Dev
//
//  Created by Kathan on 30/08/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

class EngineerInfoVC: UIViewController {

    @IBOutlet weak var gotItBtnref: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gotItBtnref.layer.cornerRadius = 5.0
        gotItBtnref.clipsToBounds = true
        // Do any additional setup after loading the view.
    }

    @IBAction func gotItClick(_ sender: UIButton) {
        EngineerInfoDisplayVC.checkAllEngInfoDisplayDone()
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
