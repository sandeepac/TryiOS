//
//  lyrics_tbl_cell.swift
//  Tully Dev
//
//  Created by macbook on 5/24/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit

class lyrics_tbl_cell: UITableViewCell
{   
    @IBOutlet var desc: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var checkbox_view: UIView!
    @IBOutlet var checkbox_img_ref: UIImageView!
    @IBOutlet var select_view: UIView!
    @IBOutlet var select_btn_ref: UIButton!
    @IBOutlet var checkbox_btn_ref: UIButton!
    var tapSelectLyrics : ((UITableViewCell) -> Void)?
    var tapCheckboxClick : ((UITableViewCell) -> Void)?
    
    @IBAction func select_lyrics(_ sender: Any) {
        tapSelectLyrics?(self)
    }
    
    @IBAction func btn_checkbox_click(_ sender: Any) {
        tapCheckboxClick?(self)
    }

    func display_select_view(){
        checkbox_btn_ref.isEnabled = false
        checkbox_view.alpha = 0.0
        select_btn_ref.isEnabled = true
        select_view.alpha = 1.0
    }
    
    func display_checkbox_view(){
        checkbox_btn_ref.isEnabled = true
        checkbox_view.alpha = 1.0
        select_btn_ref.isEnabled = false
        select_view.alpha = 0.0
    }

    func checkbox_checked(){
        checkbox_img_ref.layer.borderWidth = 0.0
        checkbox_img_ref.image = UIImage(named: "gray_checkbox")!
        checkbox_img_ref.layer.cornerRadius = 5.0
        checkbox_img_ref.clipsToBounds = true
    }
    
    func checkbox_unchecked(){
        checkbox_img_ref.image = nil
        checkbox_img_ref.layer.borderColor = UIColor.gray.cgColor
        checkbox_img_ref.layer.borderWidth = 1.0
        checkbox_img_ref.layer.cornerRadius = 5.0
        checkbox_img_ref.layer.masksToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
