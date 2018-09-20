//
//  master_data_display_Cell.swift
//  Tully Dev
//
//  Created by macbook on 1/29/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

class master_data_display_Cell: UITableViewCell {

    @IBOutlet var img_width_constraint_ref: NSLayoutConstraint!
    @IBOutlet var name_lbl_ref: UILabel!
    @IBOutlet var down_arrow_img_ref: UIImageView!
    @IBOutlet var file_folder_img_ref: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
