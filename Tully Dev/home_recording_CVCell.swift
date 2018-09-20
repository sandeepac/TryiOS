//
//  home_recording_CVCell.swift
//  Tully Dev
//
//  Created by macbook on 7/7/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit

class home_recording_CVCell: UICollectionViewCell
{
    @IBOutlet var recording_title_lbl_ref: UILabel!
    @IBOutlet var audio_bg_img_ref: UIImageView!
    @IBOutlet var recording_play_btn_img_ref: UIImageView!
    @IBOutlet var recording_view_ref: UIView!
    @IBOutlet var recording_play_btn_ref: UIButton!
    @IBOutlet var recording_cate_lbl_ref: UILabel!
    var tapPlayPause : ((UICollectionViewCell) -> Void)?
    
    func change_imageToPlay(){
        recording_play_btn_img_ref.image = UIImage(named: "recording-list-play")
        audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
    }
    
    func change_imageToPause(){
        recording_play_btn_img_ref.image = UIImage(named: "recording-list-pause")
        audio_bg_img_ref.loadGif(name: "wave")
    }
    
    @IBAction func play_recording(_ sender: Any) {
        tapPlayPause?(self)
    }
}
