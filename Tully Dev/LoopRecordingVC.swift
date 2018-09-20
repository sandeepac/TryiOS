//
//  LoopRecordingVC.swift
//  Tully Dev
//
//  Created by Kathan on 17/03/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import AVFoundation
import RangeSeekSlider
import Mixpanel

protocol looping_protocol{
    func looping_range(start_time : Float, end_time : Float)
}

class LoopRecordingVC: UIViewController, AVAudioPlayerDelegate, RangeSeekSliderDelegate {
    
    @IBOutlet var current_time_lbl_ref: UILabel!
    @IBOutlet var range_seek_view_ref: UIView!
    @IBOutlet var btn_cancel_ref: UIButton!
    @IBOutlet var play_pause_img_ref: UIImageView!
    @IBOutlet var btn_apply_ref: UIButton!
    @IBOutlet var RangeSeekSliderRef: RangeSeekSlider!
    
    @IBOutlet var loop_inner_slider_ref: UISlider!
    
    @IBOutlet var right_seek_slider_lbl_ref: UILabel!
    @IBOutlet var left_seek_slider_lbl_ref: UILabel!
    
    @IBOutlet var looping_lbl_x_constraint_ref: NSLayoutConstraint!
    var audioPlayer : AVAudioPlayer!
    var recording_file_url : URL? = nil
    var audioDuration:Float = 0.0
    var looping_start_index:Float = 0.0
    var looping_end_index:Float = 0.0
    var timer = Timer()
    var max_not_initialize = true
    var myProtocol : looping_protocol?
    var currentPlaying = false
    var start_x = 0.0
    var start_y = 0.0
    var end_x = 0.0
    var end_y = 0.0
    var start_end_height = 0.0
    var left_scrubber_value:Float = 0.0
    var right_scrubber_value:Float = 100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RangeSeekSliderRef.delegate = self
        RangeSeekSliderRef.minDistance = 1.0
        Mixpanel.mainInstance().track(event: "Loop function")
        loop_inner_slider_ref.addTarget(self, action: #selector(self.updateSliderLabelInstant(sender:)), for: .allEvents)
        
        loop_inner_slider_ref.setThumbImage(UIImage(named: "loop_line"), for: .normal)
        btn_custom_design()
        initialize_audio_and_play()
        
    }
    
    func btn_custom_design(){
        btn_apply_ref.layer.cornerRadius = 5.0
        btn_apply_ref.clipsToBounds = true
        btn_cancel_ref.layer.cornerRadius = 5.0
        btn_cancel_ref.clipsToBounds = true
    }
    
    func initialize_audio_and_play()
    {
        if  let audio_url = recording_file_url
        {
            if FileManager.default.fileExists(atPath: audio_url.path)
            {
                do
                {
                    audioPlayer = try AVAudioPlayer(contentsOf: audio_url)
                    audioPlayer.delegate = self
                    audioPlayer.play()
                    scrubber_init()
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LoopRecordingVC.update_scrubber), userInfo: nil, repeats: true)
                    currentPlaying = true
                    play_pause_img_ref.image = UIImage(named: "pause")
                }
                catch
                {
                    MyConstants.display_alert(msg_title: "Not Found", msg_desc: "File not found.", action_title: "OK", navpop: false, myVC: self)
                    dismiss(animated: true, completion: nil)
                }
            }
            else
            {
                MyConstants.display_alert(msg_title: "Not Found", msg_desc: "File not found.", action_title: "OK", navpop: false, myVC: self)
                dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            MyConstants.display_alert(msg_title: "Error", msg_desc: "Can't get file path.", action_title: "OK", navpop: false, myVC: self)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        currentPlaying = false
        play_pause_img_ref.image = UIImage(named: "green-play")
        initialize_audio_and_play()
    }
    
    func scrubber_init()
    {
        audioDuration = Float(audioPlayer.duration)
        if(max_not_initialize){
            looping_end_index = audioDuration
            max_not_initialize = false
        }
        
        loop_inner_slider_ref.minimumValue = 0.0
        loop_inner_slider_ref.maximumValue = 100
        
        RangeSeekSliderRef.minValue = 0.0
        RangeSeekSliderRef.maxValue = 100
        
        audioPlayer.currentTime = TimeInterval(looping_start_index)
    }
    
    func time_to_string(seconds : Int) -> String
    {
        var dis_sec = 0
        var dis_min = 0
        var dis_hr = 0
        
        if ( seconds > 60 )
        {
            let minute = seconds / 60
            dis_sec = seconds % 60
            
            if ( minute > 60 )
            {
                dis_hr = minute / 60
                dis_min = minute % 60
            }
            else
            {
                dis_min = minute
            }
        }
        else
        {
            dis_sec = seconds
        }
        
        var print_sec : String
        var print_min : String
        var print_hr : String
        
        if (dis_sec < 10)
        {
            print_sec = "0" + String(dis_sec)
        }
        else
        {
            print_sec = String(dis_sec)
        }
        
        print_min = String(dis_min) + ":"
        
        if (dis_hr == 0)
        {
            print_hr = ""
        }
        else
        {
            print_hr = String(dis_hr) + ":"
        }
        
        return print_hr + print_min + print_sec
    }
    
    func update_scrubber()
    {
        var current_time = Float(audioPlayer.currentTime)
        
        if(current_time > looping_end_index){
            audioPlayer.currentTime = TimeInterval(looping_start_index)
            current_time = Float(audioPlayer.currentTime)
            //initialize_audio_and_play()
        }
        current_time_lbl_ref.text = time_to_string(seconds: Int(current_time))
        var p = (current_time * 100) / audioDuration
        
        if(p < left_scrubber_value){
            p = left_scrubber_value
        }
        if(p > right_scrubber_value){
            p = right_scrubber_value
        }
        
        loop_inner_slider_ref.setValue(p, animated:true)
        let left_pos = loop_inner_slider_ref.thumbCenterX - 18
        looping_lbl_x_constraint_ref.constant = left_pos
    }
    
    
    
    func updateSliderLabelInstant(sender: UISlider!) {
        let value = sender.value
        DispatchQueue.main.async {
            let left_pos = self.loop_inner_slider_ref.thumbCenterX - 18
            self.looping_lbl_x_constraint_ref.constant = left_pos
            let p1 = (value * self.audioDuration) / 100
            self.current_time_lbl_ref.text = self.time_to_string(seconds: Int(p1))
            
        }
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        
        left_scrubber_value = Float(minValue)
        right_scrubber_value = Float(maxValue)
        
        let p1 = (left_scrubber_value * audioDuration) / 100
        let p2 = (right_scrubber_value * audioDuration) / 100
        
        looping_start_index = Float(p1)
        looping_end_index = Float(p2)
        
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        
        loop_inner_slider_ref.value = Float(minValue)
        let left_pos = self.loop_inner_slider_ref.thumbCenterX - 18
        self.looping_lbl_x_constraint_ref.constant = left_pos
        let cur_time = time_to_string(seconds: Int(looping_start_index))
        self.current_time_lbl_ref.text = cur_time
        left_seek_slider_lbl_ref.text = cur_time
        return ""
        //return cur_time
        
    }
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        right_seek_slider_lbl_ref.text = time_to_string(seconds: Int(looping_end_index))
        return ""
        //return time_to_string(seconds: Int(looping_end_index))
        
    }
    
    func didEndTouches(in slider: RangeSeekSlider) {
        if let player = audioPlayer{
            player.currentTime = TimeInterval(looping_start_index)
        }
    }
    
    func stop_player(){
        if let player = audioPlayer{
            if(player.play()){
                currentPlaying = false
                player.stop()
                timer.invalidate()
                play_pause_img_ref.image = UIImage(named: "green-play")
            }
        }
    }
    
    
    @IBAction func btn_play_pause_click(_ sender: UIButton) {
        if(currentPlaying){
            audioPlayer.pause()
            timer.invalidate()
            currentPlaying = false
            play_pause_img_ref.image = UIImage(named: "green-play")
        }else{
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LoopRecordingVC.update_scrubber), userInfo: nil, repeats: true)
            currentPlaying = true
            play_pause_img_ref.image = UIImage(named: "pause")
            audioPlayer.play()
        }
    }
    
    
    @IBAction func btn_apply_click(_ sender: UIButton) {
        stop_player()
        myProtocol?.looping_range(start_time: looping_start_index, end_time: looping_end_index)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_cancel_click(_ sender: UIButton) {
        stop_player()
        myProtocol?.looping_range(start_time: 0.0, end_time: 0.0)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func LoopInnerSliderValueChange(_ sender: UISlider) {
        if(loop_inner_slider_ref.value < left_scrubber_value){
            loop_inner_slider_ref.value = left_scrubber_value
        }
        if(loop_inner_slider_ref.value > right_scrubber_value){
            loop_inner_slider_ref.value = right_scrubber_value
        }
        let left_pos = loop_inner_slider_ref.thumbCenterX - 18
        looping_lbl_x_constraint_ref.constant = left_pos
        
        let p1 = (loop_inner_slider_ref.value * audioDuration) / 100
        
        audioPlayer.currentTime = TimeInterval(p1)
    }
    
    @IBAction func go_back(_ sender: UIButton) {
        stop_player()
        myProtocol?.looping_range(start_time: 0.0, end_time: 0.0)
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension UISlider {
    var thumbCenterX: CGFloat {
        let trackRect = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        return thumbRect.midX
    }
}
