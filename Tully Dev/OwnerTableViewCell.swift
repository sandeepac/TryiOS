//
//  OwnerTableViewCell.swift
//  Tully Dev
//
//  Created by Prashant  on 27/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

class OwnerTableViewCell: UITableViewCell {

    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var imgOwner: UIImageView!
    @IBOutlet weak var lblOwnerName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
