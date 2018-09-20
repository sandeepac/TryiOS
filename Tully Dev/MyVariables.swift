//
//  MyVariables.swift
//  Tully Dev
//
//  Created by macbook on 6/23/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit

class MyVariables : NSObject{
    static var myaudio : NSData? = nil
    static var myTitle : String? = ""
    static var pushNotification = true
    static var touchId = true
    static var marketplaceFlag = false
    static var come_from_home = false
    static var home_to_shared = false
    static var audioArray = [playData]()
    static var selected_index : Int = 0
    static var login_by_fb = false
    static var video_play = false
    static var force_touch_open = ""
    static var notification_audio_play = false
    static var notification_recording = false
    static var currently_selected_tab = 0
    static var notifi_data : Data? = nil
    static var current_play_song_index = 0
    static var home_tutorial = false
    static var play_tutorial = false
    static var market_tutorial = false
    static var lyrics_tutorial = false
    static var record_tutorial = false
    
    static var last_open_tab_for_inttercom_help : Int = 0
    
    static var audioAnalyzerSubscription = false
    static var open_home_tutorial = false
    static var open_record_lyrics = true
    //static var goto_home_from_form = false
    static var search_last_char = "\u{f8ff}"
    
    static var lyticsTextCopy = ""
    
    
    
    //static final HOME_TUTS = "HOME_TUTS"
    
}
