//
//  SharedAudio_tbl_cell.swift
//  Tully Dev
//
//  Created by macbook on 1/9/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

class SharedAudio_tbl_cell: UITableViewCell {

    @IBOutlet var audio_name_lbl_ref: UILabel!
    @IBOutlet var audio_counter_lbl_ref: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
