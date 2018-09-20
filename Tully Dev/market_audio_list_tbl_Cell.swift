//
//  market_audio_list_tbl_Cell.swift
//  Tully Dev
//
//  Created by Mili Shah on 07/02/18.
//  Copyright © 2018 Mili Shah. All rights reserved.
//

import UIKit

class market_audio_list_tbl_Cell: UITableViewCell {

    
    @IBOutlet var audio_file_name_lbl_Ref: UILabel!
    @IBOutlet var btn_purchase_ref: UIButton!
    @IBOutlet var btn_play_ref: UIButton!
    @IBOutlet var audio_play_pause_img_ref: UIImageView!
    @IBOutlet var audio_time_lbl_ref: UILabel!
    @IBOutlet var audio_author_nm_lbl_ref: UILabel!
    var tapPlayPause : ((UITableViewCell) -> Void)?
    var tapPurchase : ((UITableViewCell) -> Void)?
    
    
    @IBAction func btn_play_pause_audio(_ sender: UIButton) {
        tapPlayPause?(self)
    }
    
    @IBAction func purchase_bit_btn_click(_ sender: UIButton) {
        tapPurchase?(self)
    }
    
    func change_imageToPlay(){
        audio_play_pause_img_ref.image = UIImage(named: "marketplace_play")
    }
    
    func change_imageToPause(){
        audio_play_pause_img_ref.image = UIImage(named: "marketplace_pause")
    }
    
    func invalid_timer(){
        audio_time_lbl_ref.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
