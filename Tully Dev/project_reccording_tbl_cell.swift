//
//  project_reccording_tbl_cell.swift
//  Tully Dev
//
//  Created by Kathan on 26/07/18.
//  Copyright © 2018 Tully. All rights reserved.
//


import UIKit
import SCSiriWaveformView
import RangeSeekSlider

class project_reccording_tbl_cell: UITableViewCell {
    
    @IBOutlet var recording_name: UILabel!
    @IBOutlet var recording_project: UILabel!
    @IBOutlet var btn_ref_play_record: UIButton!
    @IBOutlet var play_starting_time: UILabel!
    @IBOutlet var play_ending_time: UILabel!
    @IBOutlet var audio_bg_img_ref: UIImageView!
    @IBOutlet var checkbox_img_ref: UIImageView!
    @IBOutlet var btn_checkbox_ref: UIButton!
    @IBOutlet var audio_name_project_lbl: UILabel!
    @IBOutlet var audio_size_lbl: UILabel!
    @IBOutlet var checkbox_view: UIView!
    @IBOutlet weak var volume_slider_ref: UISlider!
    
//    @IBOutlet weak var loop_inner_slider_ref: UISlider!
//    @IBOutlet weak var RangeSeekSliderRef: RangeSeekSlider!
//    
//    @IBOutlet weak var looping_lbl_x_constraint_ref: NSLayoutConstraint!
    var tapPlayPause : ((UITableViewCell) -> Void)?
    var audio_current_sec = 0
    var audio_remaining_sec = 0
    var pause_audio_current_sec = 0
    var pause_audio_remainning_sec = 0
    var max_second = 0
    var timer = Timer()
    var tapCheckboxClick : ((UITableViewCell) -> Void)?
    //var waveTimer : Timer!
    
    @IBAction func btn_checkbox_click(_ sender: Any) {
        tapCheckboxClick?(self)
    }
    
    func display_select_view()
    {
        btn_checkbox_ref.isEnabled = false
        checkbox_view.alpha = 0.0
    }
    
    func display_checkbox_view()
    {
        btn_checkbox_ref.isEnabled = true
        checkbox_view.alpha = 1.0
        checkbox_img_ref.image = nil
        checkbox_img_ref.layer.borderColor = UIColor.gray.cgColor
        checkbox_img_ref.layer.borderWidth = 1.0
        checkbox_img_ref.layer.cornerRadius = 5.0
        checkbox_img_ref.layer.masksToBounds = true
    }
    
    func checkbox_checked()
    {
        checkbox_img_ref.layer.borderWidth = 0.0
        checkbox_img_ref.image = UIImage(named: "gray_checkbox")!
        checkbox_img_ref.layer.cornerRadius = 5.0
        checkbox_img_ref.clipsToBounds = true
    }
    
    func checkbox_unchecked()
    {
        checkbox_img_ref.image = nil
        checkbox_img_ref.layer.borderColor = UIColor.gray.cgColor
        checkbox_img_ref.layer.borderWidth = 1.0
        checkbox_img_ref.layer.cornerRadius = 5.0
        checkbox_img_ref.layer.masksToBounds = true
    }
    
    @IBAction func play_pause_record(_ sender: Any) {
        tapPlayPause?(self)
    }
    
    func change_imageToPlay()
    {
        btn_ref_play_record.setImage(UIImage(named: "recording-list-play"), for: UIControlState.normal)
    }
    
    func change_imageToPause()
    {
        btn_ref_play_record.setImage(UIImage(named: "recording-list-pause"), for: UIControlState.normal)
        audio_bg_img_ref.loadGif(name: "wave")
    }
    
    func initialize_time(seconds : Int)
    {
        self.timer.invalidate()
        audio_current_sec = 0
        max_second = seconds
        audio_remaining_sec = seconds
        play_starting_time.text = "0:00"
        play_ending_time.text = "-" + give_time(seconds: seconds)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update_time), userInfo: nil, repeats: true)
    }
    
    func update_time()
    {
        if(pause_audio_current_sec == 0){
            audio_current_sec = audio_current_sec + 1
            if(audio_current_sec <= max_second){
                if(play_starting_time.text != ""){
                    play_starting_time.text = give_time(seconds: audio_current_sec)
                }
            }
        }
        
        // For remainning time
        if(pause_audio_remainning_sec == 0)
        {
            audio_remaining_sec = audio_remaining_sec - 1
            if(audio_remaining_sec == 0){
                play_ending_time.text = "0:00"
                invalid_timer()
                audio_bg_img_ref.image = UIImage(named: "audio-play-lines")
                change_imageToPlay()
            }else{
                if(play_ending_time.text != ""){
                    play_ending_time.text = "-" + give_time(seconds: audio_remaining_sec)
                }
            }
        }
    }
    
    func pause_audio(){
        pause_audio_current_sec = audio_current_sec
        pause_audio_remainning_sec = audio_remaining_sec
    }
    
    func play_audio(){
        audio_current_sec = pause_audio_current_sec
        audio_remaining_sec = pause_audio_remainning_sec
        pause_audio_remainning_sec = 0
        pause_audio_current_sec = 0
    }
    
    func invalid_timer(){
        self.timer.invalidate()
//        play_ending_time.text = ""
//        play_starting_time.text = ""
    }
    
    func give_time(seconds : Int) -> String
    {
        var dis_sec = 0
        var dis_min = 0
        var dis_hr = 0
        if ( seconds > 60 ){
            let minute = seconds / 60
            dis_sec = seconds % 60
            if ( minute > 60 ){
                dis_hr = minute / 60
                dis_min = minute % 60
            }else{
                dis_min = minute
            }
        }else{
            dis_sec = seconds
        }
        var print_sec : String
        var print_min : String
        var print_hr : String
        if (dis_sec < 10){
            print_sec = "0" + String(dis_sec)
        }else{
            print_sec = String(dis_sec)
        }
        print_min = String(dis_min) + ":"
        if (dis_hr == 0){
            print_hr = ""
        }else{
            print_hr = String(dis_hr) + ":"
        }
        return print_hr + print_min + print_sec
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        
}
