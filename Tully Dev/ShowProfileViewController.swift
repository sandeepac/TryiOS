//
//  ShowProfileViewController.swift
//  Tully Dev
//
//  Created by Prashant  on 28/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
class ShowProfileViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var lblMailId: UILabel!
    @IBOutlet weak var btnInvite: UIBarButtonItem!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    // MARK: - Variables
    
    var collaboratorName = String()
    var collaboratorMail = String()
    var collaboratorImg = String()
    var projectId = String ()
    var ownerKey = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = Auth.auth().currentUser?.uid
        navigationBar.topItem?.title = collaboratorName
        imgProfile.layer.masksToBounds = true
        imgProfile.clipsToBounds = true
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2
        lblName.text = collaboratorName
        lblMailId.text = collaboratorMail
        if collaboratorImg == " " {
            imgProfile.image = #imageLiteral(resourceName: "Image1")
        } else {
            imgProfile.sd_setImage(with: URL(string: collaboratorImg), placeholderImage: #imageLiteral(resourceName: "Image1"))
        }
        
        //        if uid == ownerKey {
        //            self.btnInvite.isEnabled = true
        //           // btnRemove.isHidden = false
        //        } else {
        self.btnInvite.title = ""
        self.btnInvite.tintColor = .clear
        self.btnInvite.isEnabled = false
        //        }
        
    }
    
    @IBAction func actionInvite(_ sender: UIBarButtonItem) {
        let vc : InviteVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InviteVC") as! InviteVC
        vc.projectCurrentId = projectId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
