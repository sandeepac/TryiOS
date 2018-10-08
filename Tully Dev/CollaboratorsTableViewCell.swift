//
//  CollaboratorsTableViewCell.swift
//  Tully Dev
//
//  Created by Prashant  on 27/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit

class CollaboratorsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblOtherEmails: UILabel!
    @IBOutlet weak var btnDeleteCollaborator: UIButton!
    @IBOutlet weak var lblCollaboratorsName: UILabel!
    @IBOutlet weak var imgCollaborators: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
