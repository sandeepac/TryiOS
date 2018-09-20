//
//  importWebWindowVC.swift
//  Tully Dev
//
//  Created by Kathan on 04/08/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

class importWebWindowVC: UIViewController {

    @IBOutlet weak var link_txt_ref: UILabel!
    @IBOutlet weak var copy_btn_ref: UIButton!
    
    @IBOutlet weak var got_it_btn_Ref: UIButton!
    var mylink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        link_txt_ref.text = mylink
        copy_btn_ref.layer.cornerRadius = 10.0
        copy_btn_ref.layer.borderWidth = 1.0
        copy_btn_ref.layer.borderColor = UIColor(red: 34/255, green: 209/255, blue: 151/255, alpha: 1.0).cgColor
        copy_btn_ref.clipsToBounds = true
        got_it_btn_Ref.layer.cornerRadius = 3.0
        got_it_btn_Ref.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }

    @IBAction func got_it_click(_ sender: UIButton) {
        UIPasteboard.general.string = mylink
        dismiss(animated: true, completion: nil)
    }
    @IBAction func copy_btn_click(_ sender: UIButton) {
        UIPasteboard.general.string = mylink
        dismiss(animated: true, completion: nil)
    }
    @IBAction func back_btn_click(_ sender: UIButton) {
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
