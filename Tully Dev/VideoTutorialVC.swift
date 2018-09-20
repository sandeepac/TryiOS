//
//  VideoTutorialVC.swift
//  Tully Dev
//
//  Created by macbook on 9/8/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoTutorialVC: UIViewController, AVPlayerViewControllerDelegate{

    var player = AVPlayer()
    let playerController = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let path = Bundle.main.path(forResource: "Ios", ofType:"mp4") else {
            print("not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VideoTutorialVC.videoDidFinish(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }
    
    
    
    func videoDidFinish(_ notification: NSNotification) {
        dismiss(animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(MyVariables.video_play)
        {
            player.pause()
            playerController.removeFromParentViewController()
            dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(MyVariables.video_play)
        {
            MyVariables.video_play = false
            dismiss(animated: false, completion: nil)
        }
        else
        {
            playerController.player = player
            playerController.isEditing = false
            MyVariables.video_play = true
            self.player.play()
            present(playerController, animated: false) {
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
}
