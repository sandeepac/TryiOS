//
//  MarketplacePurchaseVC.swift
//  Tully Dev
//
//  Created by Kathan on 08/03/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

protocol dismissProtocol
{
    func dismissView()
}

class MarketplacePurchaseVC: UIViewController {

    @IBOutlet weak var also_sent_mail_lbl_ref: UILabel!
    @IBOutlet weak var purchase_link_lbl_ref: UILabel!
    @IBOutlet var copy_btn_ref: UIButton!
    @IBOutlet var email_txt_ref: UITextField!
    var mylink = ""
    
    var dismissProtocol : dismissProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarController?.tabBar.isHidden = true
        email_txt_ref.text = mylink
        copy_btn_ref.layer.cornerRadius = 10.0
        copy_btn_ref.layer.borderWidth = 1.0
        copy_btn_ref.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0).cgColor
        copy_btn_ref.clipsToBounds = true
        MyConstants.showAnimate(myView : self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        purchase_link_lbl_ref.text = "Purchase Link"
        also_sent_mail_lbl_ref.alpha = 1.0
    }
    
    @IBAction func send_btn_click(_ sender: UIButton) {
        UIApplication.shared.open(URL(string : mylink)!, options: [:], completionHandler: { (status) in
        })
        self.dismissProtocol?.dismissView()
        MyConstants.removeAnimate(myView : self.view, myVC : self)
    }
    
    @IBAction func cancel_btn_click(_ sender: UIButton) {
        UIPasteboard.general.string = mylink
        self.dismissProtocol?.dismissView()
        MyConstants.removeAnimate(myView : self.view, myVC : self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

