//
//  DataMouseTblCell.swift
//  Tully Dev
//
//  Created by macbook on 6/3/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit

class DataMouseTblCell: UITableViewCell {
    
    @IBOutlet var data_option_lbl: UILabel!
    @IBOutlet var data_detail_btn_Ref: UIButton!
    @IBOutlet var data_img_ref: UIImageView!
    @IBOutlet var right_arrow_img_ref: UIImageView!
    var tapOpenDetail : ((UITableViewCell) -> Void)?
   
    @IBAction func open_data_detail(_ sender: Any) {
        tapOpenDetail?(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
