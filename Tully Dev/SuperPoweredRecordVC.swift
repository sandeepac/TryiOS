//
//  SuperPoweredRecordVC.swift
//  Tully Dev
//
//  Created by Kathan on 02/07/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit


class SuperPoweredRecordVC: UIViewController {
//    var superpowered:Superpowered!
//    var displayLink:CADisplayLink!
//    var layers:[CALayer]!
    
     let vari = SuperpoweredRecorderWrapped()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vari.initializeData("", "")
        vari.onPlayPause(1)
        vari.onCrossFader(0.5)
        
    }
    
    @objc func onDisplayLink() {
        // Get t
    }

    @IBAction func play_btn_click(_ sender: UIButton) {
        vari.onPlayPause(0)
        vari.initializeData("", "")
        vari.onPlayPause(1)
        vari.onCrossFader(0.5)
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
