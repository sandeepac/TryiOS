//
//  h1TutorialVC.swift
//  Tully Dev
//
//  Created by Kathan on 23/04/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase

class h1TutorialVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet var coming_soon_lbl_ref: UILabel!
    @IBOutlet var record_3_txt_view: UIView!
    @IBOutlet var pageControl: CustomImagePageControl!
    @IBOutlet var tutorial_lbl_ref: UILabel!
    @IBOutlet var ImageSliderScrollView: UIScrollView!
    var imagesArray = [UIImageView()]
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    var height : CGFloat = 0.0
    var width : CGFloat = 0.0
    var tutorial_for = ""
    //home,play,market,lyrics,record
    let homeImgArr = ["h1.pdf","h2.pdf"]
    let playImgArr = ["p1.pdf","p2.pdf","p3.pdf","p4.pdf","p5.pdf"]
    let marketImgArr = ["m1.pdf","m2.pdf"]
    let lyricsImgArr = ["l1.pdf","l2.pdf"]
    let recordImgArr = ["r1.pdf"]
    let home_text = ["Files, Projects are stored in homescreen.","Click and hold files and projects to share."]
    let play_text = ["Loop, Record and Write your ideas, hooks, verse's.","Loop specific parts of the audio you might be writing too.","","Write while listening to your beat at the same time.","You have access to a full rhyming catalog by selecting a word."]
    let market_text = ["","Help - Live chat, Tully support will help you with any questions you have."]
    let lyrics_text = ["All your lyrics are stored here.","You will see \"no project assigned\" when your writing without listening to a beat inside the Tully app."]
    let record_text = ["Record ideas and vocals as your listening to beats in the studio or external speakers."]
    var length = 0
    var selected_text = [String]()
    var come_from_share_audio = false
    
    @IBOutlet var marketplace_1_txt_view: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        coming_soon_lbl_ref.layer.cornerRadius = 5.0
        coming_soon_lbl_ref.clipsToBounds = true
        height = self.view.frame.height - 151
        width = self.view.frame.width
        choose_tutorial_screen()
    }
    
    func choose_tutorial_screen(){
        imagesArray.removeAll()
        if(tutorial_for == "home"){
            length = homeImgArr.count
            for i in 0..<length
            {
                selected_text.append(home_text[i])
                let iview = UIImageView(image: UIImage(named: homeImgArr[i])!)
                imagesArray.append(iview)
            }
            configurePageControl()
            get_slider()
            
        }else if(tutorial_for == "play"){
            length = playImgArr.count
            for i in 0..<length
            {
                selected_text.append(play_text[i])
                let iview = UIImageView(image: UIImage(named: playImgArr[i])!)
                imagesArray.append(iview)
            }
            configurePageControl()
            get_slider()
            
        }else if(tutorial_for == "market"){
            length = marketImgArr.count
            for i in 0..<length
            {
                selected_text.append(market_text[i])
                let iview = UIImageView(image: UIImage(named: marketImgArr[i])!)
                imagesArray.append(iview)
            }
            configurePageControl()
            get_slider()
            
        }else if(tutorial_for == "lyrics"){
            length = lyricsImgArr.count
            for i in 0..<length
            {
                selected_text.append(lyrics_text[i])
                let iview = UIImageView(image: UIImage(named: lyricsImgArr[i])!)
                imagesArray.append(iview)
            }
            configurePageControl()
            get_slider()
            
        }else if(tutorial_for == "record"){
            length = recordImgArr.count
            for i in 0..<length
            {
                selected_text.append(record_text[i])
                let iview = UIImageView(image: UIImage(named: recordImgArr[i])!)
                imagesArray.append(iview)
            }
            configurePageControl()
            get_slider()
            
        }
        
        ImageSliderScrollView.delegate = self
        ImageSliderScrollView.isPagingEnabled = true
        
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
    func get_slider(){
        
            var countIndex = CGFloat(0)
            for image in self.imagesArray {
                let x_pos = countIndex * self.width
                image.frame = CGRect(x: x_pos, y: 0, width: self.width, height: self.height)
                image.contentMode = .scaleAspectFit
                self.ImageSliderScrollView.addSubview(image)
                countIndex = countIndex + 1
            }
            
            self.ImageSliderScrollView.contentSize = CGSize(width: self.width * CGFloat(self.length),height: self.height)
            if(selected_text.count > 0){
                if(tutorial_for == "market"){
                    marketplace_1_txt_view.alpha = 1.0
                    record_3_txt_view.alpha = 0.0
                }
                self.tutorial_lbl_ref.text = self.selected_text.first
            }
        
            self.pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
        
        
    }
    
    func configurePageControl() {
        self.pageControl.numberOfPages = length
        self.pageControl.currentPage = 0
        
        pageControl.pageIndicatorTintColor = UIColor.white
        
        pageControl.currentPageIndicatorTintColor = UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1.0)
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage(sender: AnyObject) -> () {
        DispatchQueue.main.async {
            let pageNumber = self.pageControl.currentPage + 1
            let x = CGFloat(self.pageControl.currentPage) * self.ImageSliderScrollView.frame.size.width
            if(self.selected_text.count >= pageNumber){
                if(self.tutorial_for == "market" && pageNumber == 0){
                    self.marketplace_1_txt_view.alpha = 1.0
                    self.record_3_txt_view.alpha = 0.0
                }else if(self.tutorial_for == "play" && pageNumber == 2){
                    self.record_3_txt_view.alpha = 1.0
                    self.marketplace_1_txt_view.alpha = 0.0
                }else{
                    self.marketplace_1_txt_view.alpha = 0.0
                    self.record_3_txt_view.alpha = 0.0
                }
                if(self.selected_text.count >= pageNumber){
                    self.tutorial_lbl_ref.text = self.selected_text[pageNumber]
                }
            }
            self.ImageSliderScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(ImageSliderScrollView.contentOffset.x / ImageSliderScrollView.frame.size.width)
        if(selected_text.count >= Int(pageNumber)){
            if(tutorial_for == "market" && pageNumber == 0){
                marketplace_1_txt_view.alpha = 1.0
                record_3_txt_view.alpha = 0.0
            }else if(tutorial_for == "play" && pageNumber == 2){
                record_3_txt_view.alpha = 1.0
                marketplace_1_txt_view.alpha = 0.0
            }else{
                marketplace_1_txt_view.alpha = 0.0
                record_3_txt_view.alpha = 0.0
            }
            tutorial_lbl_ref.text = selected_text[Int(pageNumber)]
        }
        pageControl.currentPage = Int(pageNumber)
    }

    @IBAction func cancel_btn_click(_ sender: UIButton) {
        if(tutorial_for == "lyrics"){
            seen_tutorial(myScreen: "TUTS_LYRICS")
            MyVariables.lyrics_tutorial = true
        }else if(tutorial_for == "record"){
            seen_tutorial(myScreen: "TUTS_RECORDING")
            MyVariables.record_tutorial = true
        }
        close_view()
    }
    
    @IBAction func continue_btn_click(_ sender: UIButton) {
        let pageNumber = pageControl.currentPage + 1
        if(pageNumber == length){
            if(tutorial_for == "lyrics"){
                seen_tutorial(myScreen: "TUTS_LYRICS")
                MyVariables.lyrics_tutorial = true
            }else if(tutorial_for == "record"){
                seen_tutorial(myScreen: "TUTS_RECORDING")
                MyVariables.record_tutorial = true
            }
            close_view()
        }else{
            
            let x = CGFloat(pageControl.currentPage + 1) * ImageSliderScrollView.frame.size.width
            if(selected_text.count >= pageNumber){
                if(tutorial_for == "market" && pageNumber == 0){
                    marketplace_1_txt_view.alpha = 1.0
                    record_3_txt_view.alpha = 0.0
                }else if(tutorial_for == "play" && pageNumber == 2){
                    record_3_txt_view.alpha = 1.0
                    marketplace_1_txt_view.alpha = 0.0
                }else{
                    marketplace_1_txt_view.alpha = 0.0
                    record_3_txt_view.alpha = 0.0
                }
                tutorial_lbl_ref.text = selected_text[pageNumber]
            }
            ImageSliderScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
            pageControl.currentPage = Int(pageNumber)
        }
    }
    
    func seen_tutorial(myScreen : String){
        let set_market_place: [String: Any] = [myScreen: true]
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("settings").child("tutorial_screens").updateChildValues(set_market_place, withCompletionBlock: { (error, database) in
            if let error = error
            {
                print(error.localizedDescription)
            }
        })
    }
    
    func close_view(){
        if(!come_from_share_audio){
            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home_tabBar_sid") as! UITabBarController
            
            if(tutorial_for == "home"){
                seen_tutorial(myScreen: "TUTS_HOME")
                MyVariables.home_tutorial = true
            }else if(tutorial_for == "play"){
                vc.selectedIndex = 1
                seen_tutorial(myScreen: "TUTS_PLAY")
                MyVariables.play_tutorial = true
            }else if(tutorial_for == "market"){
                vc.selectedIndex = 2
                seen_tutorial(myScreen: "TUTS_MARKET_PLACE")
                MyVariables.market_tutorial = true
            }else if(tutorial_for == "lyrics"){
                vc.selectedIndex = 3
                seen_tutorial(myScreen: "TUTS_LYRICS")
                MyVariables.lyrics_tutorial = true
            }else if(tutorial_for == "record"){
                vc.selectedIndex = 4
                seen_tutorial(myScreen: "TUTS_RECORDING")
                MyVariables.record_tutorial = true
            }
            dismiss(animated: true, completion: nil)
            self.present(vc, animated: false, completion: nil)
        }else{
            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
            dismiss(animated: true, completion: nil)
            seen_tutorial(myScreen: "TUTS_PLAY")
            MyVariables.play_tutorial = true
            let vc : SharedAudioVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SharedAudioSid") as! SharedAudioVC
            vc.come_as_present = true
            self.present(vc, animated: true, completion: nil)
            //self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
