  //
//  Marketplaceswitchvc.swift
//  Tully Dev
//
//  Created by macbook on 1/6/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import AVFoundation
import MediaPlayer
import Mixpanel

class Marketplaceswitchvc: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    //MARK: - Outlets
    @IBOutlet var market_place_view: UIView!
    @IBOutlet var user_genre_lbl: UILabel!
    @IBOutlet var user_choice_lbl: UILabel!
    @IBOutlet var user_name_ref: UILabel!
    @IBOutlet var user_img_ref: UIImageView!
    @IBOutlet var marketplace_tbl_ref: UITableView!
    @IBOutlet var lbl_author_ref: UILabel!
    @IBOutlet var img_play_pause_ref: UIImageView!
    @IBOutlet var audio_scrubber_ref: UISlider!
    @IBOutlet var inner_view_ref: UIView!
    @IBOutlet var height_constraint_of_view_ref: NSLayoutConstraint!
    @IBOutlet var view2_producer_lbl_ref: UILabel!
    //@IBOutlet var marketplace_switch_ref: UISwitch!
    @IBOutlet var view2_ref: UIView!
    @IBOutlet var view2_nm_lbl_ref: UILabel!
    @IBOutlet var view2_genre_lbl_Ref: UILabel!
    @IBOutlet var view2_type_lbl_ref: UILabel!
    @IBOutlet var bottom_author_lbl_ref: UILabel!
    @IBOutlet var bottom_title_lbl_ref: UILabel!
    @IBOutlet var view2_purchase_btn_ref: UIButton!
    @IBOutlet var progressBar: UIProgressView!
    
    //MARK: - Variables
    var interactor:Interactor? = nil
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    var LatestAudioArray:[DataAudioList] = [DataAudioList]()
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    var panGestureRecognizer: UIPanGestureRecognizer?
    let loadingView = UIView()
    let loadingLabel = UILabel()
    var spinner = UIActivityIndicatorView()
    var timer = Timer()
    var current_time_in_second = 0
    var scroll_height = 0
    var inMarketplace = false
    var for_purchase_beat_id = ""
    var for_purchase_amount = ""
    var current_selected_index : String = ""
    var isInitialized = false
    var current_play_song_index = 0
    var player:AVPlayer? = nil
    var current_playing = false
    var audio_play = false
    var selected_audio_name = ""
    var selected_audio_producer_name = ""
    var selected_index = 0
    var flag_open_setting = false
    
    // For scroll to load more
    var current_page = 0
    var total_pages = 0
    var complete_flag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        self.navigationController?.isNavigationBarHidden = true
        
        do {
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
            try! AVAudioSession.sharedInstance().setActive(true)
        }
        //generate_api_security()
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
        marketplace_tbl_ref.tableFooterView = UIView()
        marketplace_tbl_ref.separatorStyle = UITableViewCellSeparatorStyle.none
        user_img_ref.layer.cornerRadius = user_img_ref.frame.size.width/2;
        user_img_ref.layer.masksToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(Marketplaceswitchvc.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player)
        custom_design()
        get_user_data()
        DispatchQueue.main.async {
            self.get_profile_image()
        }
    }
    
    func custom_design(){
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.view2_purchase_btn_ref.frame
        rectShape.position = self.view2_purchase_btn_ref.center
        rectShape.path = UIBezierPath(roundedRect: self.view2_purchase_btn_ref.bounds, byRoundingCorners: [.bottomLeft , .bottomRight , .topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.view2_purchase_btn_ref.layer.mask = rectShape
        view2_type_lbl_ref.layer.borderColor = UIColor.gray.cgColor
        view2_type_lbl_ref.layer.borderWidth = 1.0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        MyVariables.last_open_tab_for_inttercom_help = 2
        
        flag_open_setting = false
        if(!MyVariables.market_tutorial){
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "h1TutorialSid") as! h1TutorialVC
            vc.tutorial_for = "market"
            self.present(vc, animated: true, completion: nil)
        }
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 21/255, green: 22/255, blue: 29/255, alpha: 1)
        inMarketplace = true
        current_page = 0
        complete_flag = false
        current_play_song_index = 0
        
        view2Clear()
        view2_ref.alpha = 0.0
        
        self.generate_api_security()
        //self.marketplace_on_off()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget(self, action:#selector(Marketplaceswitchvc.play_previous_song))

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action:#selector(Marketplaceswitchvc.btn_play_next_song(_:)))

        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget(self, action:#selector(Marketplaceswitchvc.btn_play_pause_click(_:)))

        commandCenter.skipBackwardCommand.isEnabled = false
        commandCenter.skipForwardCommand.isEnabled = false

        if #available(iOS 9.1, *) {
            commandCenter.changePlaybackPositionCommand.isEnabled = true
        } else {
            // Fallback on earlier versions
            return
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.previousTrackCommand.removeTarget(self)
        commandCenter.nextTrackCommand.removeTarget(self)
        commandCenter.togglePlayPauseCommand.removeTarget(self)
    }
    
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 70 {
                self.market_place_view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.market_place_view.frame.size.width, height: self.market_place_view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.market_place_view.frame = CGRect(x: 0, y: 70, width: self.market_place_view.frame.size.width, height: self.market_place_view.frame.size.height)
                swipe_down_click()
                
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.market_place_view.frame = CGRect(x: 0, y: 70, width: self.market_place_view.frame.size.width, height: self.market_place_view.frame.size.height)
                })
            }
        }
    }
    
    func swipe_down_click(){
        self.tabBarController?.selectedIndex = MyVariables.currently_selected_tab
    }
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer){
        let percentThreshold:CGFloat = 0.3
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        guard let interactor = interactor else { return }
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            self.tabBarController?.selectedIndex = MyVariables.currently_selected_tab
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
    
//    @IBAction func market_watch_on_off_click(_ sender: UISwitch) {
//        if(MyVariables.marketplaceFlag)
//        {
//            // Turn Off marketplace notification
//            UserDefaults.standard.set("false", forKey: "marketplace")
//            MyVariables.marketplaceFlag = false
//            marketplace_switch_ref.isOn = false
//            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//            let settings_data: [String: Any] = ["marketPlace": false]
//
//            userRef.child("settings").updateChildValues(settings_data, withCompletionBlock: { (error, database_ref) in
//                if let error = error
//                {
//                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
//                }
//
//            })
//        }
//        else
//        {
//            //Turn on marketplace notification
//
//            UserDefaults.standard.set("true", forKey: "marketplace")
//            MyVariables.marketplaceFlag = true
//            marketplace_switch_ref.isOn = true
//            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
//            let settings_data: [String: Any] = ["marketPlace": true]
//
//            userRef.child("settings").updateChildValues(settings_data, withCompletionBlock: { (error, database_ref) in
//                if let error = error
//                {
//                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
//                }
//            })
//            Mixpanel.mainInstance().track(event: "Opt - In")
//        }
//    }

    //MARK:-  Get data
    
    func get_user_data(){
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("profile").observe(.value, with: { (snapshot) in
            if((snapshot.value as? NSDictionary) != nil){
                let data = snapshot.value as! NSDictionary
                if((data.value(forKey: "artist_name") as? String) != nil){
                    self.user_name_ref.text = data.value(forKey: "artist_name") as? String
                }
                if((data.value(forKey: "genre") as? String) != nil){
                    self.user_genre_lbl.text = data.value(forKey: "genre") as? String
                }
                if((data.value(forKey: "artist_option") as? String) != nil){
                    let mydata = data.value(forKey: "artist_option") as? String
                    self.user_choice_lbl.text = mydata
                }
            }
        })
    }
    
    func get_profile_image()
    {
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        userRef.child("profile").observe(.value, with: { (snapshot) in
            if((snapshot.value as? NSDictionary) != nil){
                let data = snapshot.value as! NSDictionary
                if((data.value(forKey: "myimg") as? String) != nil){
                    let myImg = data.value(forKey: "myimg") as! String
                    if let url = URL(string: myImg){
                        DispatchQueue.global().async { [weak self] in
                            if let data = try? Data(contentsOf: url) {
                                if let image = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        self?.user_img_ref.image = image
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func get_audio_list_data(token : String)
    {
        DispatchQueue.main.async {
            
            self.myActivityIndicator.startAnimating()
            
            if(self.current_page == 0){
                self.LatestAudioArray.removeAll()
            }
            let myurlstring = MyConstants.marketplace_get_data + String(self.current_page)
            let url=URL(string : myurlstring)
            var request = URLRequest(url: url!)
            request.setValue(token, forHTTPHeaderField: MyConstants.Authorization)
       
            let task=URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                if( error != nil ){
                    DispatchQueue.main.async {
                        self.myActivityIndicator.stopAnimating()
                    }
                    self.display_alert(msg_title : "Error" , msg_desc : (error?.localizedDescription)! ,action_title : "OK")
                }
                else
                {
                    if let urlContent = data
                    {
                        do
                        {
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            let myTotal = (jsonResult["count"] as! String)
                            self.total_pages = Int(ceil(Float(myTotal)!/10))
                            
                            DispatchQueue.main.sync (execute: {
                            let jsonarray = jsonResult.value(forKey: "data") as! NSArray
                            var id1 : String
                            var name1 : String
                            var price1 : String
                            var track1 : String
                            var producer_name1 : String
                            var email1 : String
                            var size1 : String
                            var type1 : String
                            var genre1 : String
                            
                            for json in jsonarray
                            {
                                if((json as AnyObject).value(forKey: "id") as? String != nil){
                                    id1 = (json as AnyObject).value(forKey: "id") as! String
                                }else{
                                    id1 = ""
                                }
                                
                                if((json as AnyObject).value(forKey: "name") as? String != nil){
                                    name1 = (json as AnyObject).value(forKey: "name") as! String
                                }else{
                                    name1 = ""
                                }
                                
                                if((json as AnyObject).value(forKey: "type") as? String != nil){
                                    type1 = (json as AnyObject).value(forKey: "type") as! String
                                }else{
                                    type1 = ""
                                }
                                
                                if((json as AnyObject).value(forKey: "genre") as? String != nil){
                                    genre1 = (json as AnyObject).value(forKey: "genre") as! String
                                }else{
                                    genre1 = ""
                                }
                                
                                if((json as AnyObject).value(forKey: "price") as? String != nil){
                                    price1 = (json as AnyObject).value(forKey: "price") as! String
                                    
                                }else{
                                    price1 = "0"
                                }
                                
                                if((json as AnyObject).value(forKey: "track") as? String != nil){
                                    track1 = (json as AnyObject).value(forKey: "track") as! String
                                    do{
                                       
                                        let mydata = track1.data(using: .utf8)
                                        let jsonResult = try JSONSerialization.jsonObject(with: mydata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                                        if((jsonResult as AnyObject).value(forKey: "url") as? String != nil){
                                            track1 = (jsonResult as AnyObject).value(forKey: "url") as! String
                                        }else{
                                            track1 = ""
                                        }
                                        
                                        if((jsonResult as AnyObject).value(forKey: "size") as? Int64 != nil){
                                            let byte_size = (jsonResult as AnyObject).value(forKey: "size") as! Int64
                                            size1 = String(byte_size/1000)
                                        }else{
                                            size1 = ""
                                        }
                                        
                                    }catch{
                                        track1 = ""
                                        size1 = ""
                                        self.myActivityIndicator.stopAnimating()
                                        self.display_alert(msg_title : "Server error" , msg_desc : "Data not found." ,action_title : "OK")
                                    }
                                }else{
                                    track1 = ""
                                    size1 = ""
                                }
                                
                                if((json as AnyObject).value(forKey: "producer_name") as? String != nil){
                                    producer_name1 = (json as AnyObject).value(forKey: "producer_name") as! String
                                }
                                else{
                                    producer_name1 = ""
                                }
                                
                                if((json as AnyObject).value(forKey: "email") as? String != nil){
                                    email1 = (json as AnyObject).value(forKey: "email") as! String
                                }else{
                                    email1 = ""
                                }
                                let get_audio_data = DataAudioList(id: id1, name: name1, price: price1, track: track1, producer_name: producer_name1, email: email1, size: size1, type: type1, genre: genre1)
                                self.LatestAudioArray.append(get_audio_data)
                            }
                            UIView.transition(with: self.marketplace_tbl_ref, duration: 0.5, options: .transitionCrossDissolve, animations: {self.marketplace_tbl_ref.reloadData()}, completion: nil)
                            })
                            DispatchQueue.main.async {
                                self.myActivityIndicator.stopAnimating()
                            }
                        }catch{
                            DispatchQueue.main.async {
                                self.myActivityIndicator.stopAnimating()
                            }
                            self.display_alert(msg_title : "Server error" , msg_desc : "Data not found." ,action_title : "OK")
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Tableview methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LatestAudioArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
        let last_element = LatestAudioArray.count - 1
        // .......... reached to last cell so load another data ..........
        if(indexPath.row == last_element)
        {
            if(!complete_flag){
                current_page = current_page + 1
                if(current_page < total_pages){
                    self.generate_api_security()
                }else{
                    current_page = total_pages - 1
                    complete_flag = true
                }
            }
        }
            
            if(LatestAudioArray.indices.contains(indexPath.row)){
                let myupdate=LatestAudioArray[indexPath.row]
                let myCell = tableView.dequeueReusableCell(withIdentifier: "marketAudioListCell", for: indexPath) as! market_audio_list_tbl_Cell
                myCell.audio_file_name_lbl_Ref.text = myupdate.name
                myCell.audio_author_nm_lbl_ref.text = myupdate.producer_name
                myCell.btn_play_ref.tag=indexPath.row
                myCell.btn_purchase_ref.tag = indexPath.row
                myCell.btn_purchase_ref.layer.cornerRadius = 5.0
                myCell.btn_purchase_ref.clipsToBounds = true
                
                if(myupdate.price == "0"){
                    myCell.btn_purchase_ref.setTitle("Free", for: .normal)
                }else{
                    
                    myCell.btn_purchase_ref.setTitle("$"+myupdate.price!, for: .normal)
                }
                
                
                myCell.audio_time_lbl_ref.text = ""
                myCell.selectionStyle = UITableViewCellSelectionStyle.none
                
                if (indexPath.row == current_play_song_index){
                    if(current_playing){
                        myCell.change_imageToPause()
                    }else{
                        myCell.change_imageToPlay()
                    }
                }else{
                    myCell.change_imageToPlay()
                }
                
                myCell.tapPlayPause = { (cell) in
                    var play_new_song = false
                    if(self.audio_play){
                        if(self.current_play_song_index == myCell.btn_play_ref.tag){
                            if(self.current_playing){
                                self.player?.pause()
                                self.current_playing=false
                                myCell.change_imageToPlay()
                                self.img_play_pause_ref.image = UIImage(named: "marketplace_play")
                            }else{
                                self.player?.play()
                                self.current_playing=true
                                self.view2_ref.alpha = 1.0
                                myCell.change_imageToPause()
                                self.img_play_pause_ref.image = UIImage(named: "marketplace_pause")
                            }
                        }
                        else
                        {
                            play_new_song = true
                            if(self.current_playing)
                            {
                                self.current_playing = false
                                self.player?.pause()
                                self.player = nil
                                self.timer.invalidate()
                            }
                            myCell.invalid_timer()
                            myCell.audio_time_lbl_ref.text = ""
                        }
                    }else{
                        play_new_song = true
                        if(self.current_playing)
                        {
                            self.current_playing = false
                            self.player?.pause()
                            self.player = nil
                            self.timer.invalidate()
                            self.current_playing = false
                        }
                    }
                    
                    if(play_new_song){
                        self.current_play_song_index = myCell.btn_play_ref.tag
                        
                        DispatchQueue.main.async{
                            self.audio_scrubber_ref.value = 0.0
                            
                            let visible = tableView.indexPathsForVisibleRows
                            
                            for vs in visible!{
                                let gen_index = NSIndexPath(row: vs.row, section: 0)
                                if (vs.row == self.current_play_song_index){
                                    myCell.change_imageToPause()
                                    
                                }else{
                                    let myCell = tableView.cellForRow(at: gen_index as IndexPath) as? market_audio_list_tbl_Cell
                                    myCell?.change_imageToPlay()
                                    
                                    myCell?.invalid_timer()
                                    self.img_play_pause_ref.image = UIImage(named: "marketplace_pause")
                                    myCell?.audio_time_lbl_ref.text = ""
                                }
                            }
                        }
                        
                        if myupdate.track != nil
                        {
                            if(Reachability.isConnectedToNetwork()){
                                self.myActivityIndicator.startAnimating()
                                DispatchQueue.global(qos: .default).async {
                                    self.play_audio_online(myindex: self.current_play_song_index)
                                }
                            }else{
                                self.display_alert(msg_title: "No Internet Connection", msg_desc: "For Play - make sure your device is connected to the internet", action_title: "OK")
                            }
                        }
                    }
                }
                
                myCell.tapPurchase = { (cell) in
                    if(myupdate.price != "0") {
                        let message1 = "Do you want to buy " + myupdate.name! + " for $" + myupdate.price! + "?"
                        let ac = UIAlertController(title: "Confirm Your Purchase", message: message1, preferredStyle: .alert)
                        ac.view.tintColor = UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1)
                        ac.addAction(UIAlertAction(title: "Cancel", style: .default){
                            (result : UIAlertAction) -> Void in
                        })
                        ac.addAction(UIAlertAction(title: "Purchase", style: .default){
                            (result : UIAlertAction) -> Void in
                            self.current_selected_index = myupdate.id!
                            self.generate_token_for_purchase_beat()
                        })
                        self.present(ac, animated: true)
                    }
                    else{
                        self.current_selected_index = myupdate.id!
                        self.generate_token_for_purchase_free_beat()
                    }
                }
                return myCell
            }
            else{
                let myCell = tableView.dequeueReusableCell(withIdentifier: "marketAudioListCell", for: indexPath) as! market_audio_list_tbl_Cell
                return myCell
            }
    }
    
    func generate_token_for_purchase_free_beat(){
        
        ApiAuthentication.get_authentication_token().then({ (token) in
            self.purchase_free_bit(token: token)
        }).catch({ (err) in
            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: err.localizedDescription, action_title: "Ok", myVC: self)
        })
        
        
    }
    
    func purchase_free_bit(token : String){
        if(current_selected_index != "")
        {
            let myuserid = Auth.auth().currentUser?.uid
            if(myuserid != nil)
            {
                let email = Auth.auth().currentUser!.email!
                let name = Auth.auth().currentUser!.displayName!
                self.myActivityIndicator.startAnimating()
                let url=URL(string : MyConstants.marketplace_generate_purchase_free_link)
                var request = URLRequest(url: url!)
                request.setValue(token, forHTTPHeaderField: MyConstants.Authorization)
                
                request.httpMethod = "POST"
                let user_data = "&email="+email+"&name="+name
                let postString = "uid="+myuserid!+"&beat_id="+current_selected_index+user_data
                request.httpBody = postString.data(using: .utf8)
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else{
                        self.myActivityIndicator.stopAnimating()
                        self.current_selected_index = ""
                        self.display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK")
                        return
                    }
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                        DispatchQueue.main.async {
                            self.myActivityIndicator.stopAnimating()
                            self.current_selected_index = ""
                            self.display_alert(msg_title: "Error", msg_desc: String(describing: response), action_title: "OK")
                        }
                        
                    }else{
                        do{
                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                                DispatchQueue.main.async (execute: {
                                    self.myActivityIndicator.stopAnimating()
                                    let status = json["status"] as! Int
                                    if(status == 1){
                                        
                                        
                                        let ac = UIAlertController(title: "Done", message: "Order Complete", preferredStyle: .alert)
                                        let attributes = [NSForegroundColorAttributeName: UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
                                        let titleAttrString = NSMutableAttributedString(string: "Done", attributes: attributes)
                                        ac.setValue(titleAttrString, forKey: "attributedTitle")
                                        ac.view.tintColor = UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1)
                                        ac.addAction(UIAlertAction(title: "OK", style: .default){
                                            (result : UIAlertAction) -> Void in
                                        })
                                        
                                        self.present(ac, animated: true)
                                    }else{
                                        let msg = json["msg"] as! String
                                        self.current_selected_index = ""
                                        self.display_alert(msg_title: "Oops", msg_desc: msg, action_title: "Ok")
                                    }
                                })
                            }
                        } catch let error {
                            self.current_selected_index = ""
                            self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                        }
                    }
                };task.resume()
            }else{
                self.current_selected_index = ""
                self.display_alert(msg_title: "LogIn First", msg_desc: "Please login first", action_title: "OK")
            }
        }
    }
    
    func generate_token_for_purchase_beat(){
        
        ApiAuthentication.get_authentication_token().then({ (token) in
            self.purchase_bit(token: token)
        }).catch({ (err) in
            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: err.localizedDescription, action_title: "Ok", myVC: self)
        })
        
    }
    
    func purchase_bit(token : String)
    {
        if(current_selected_index != "")
        {
            let myuserid = Auth.auth().currentUser?.uid
            if(myuserid != nil)
            {
                let email = Auth.auth().currentUser!.email!
                let name = Auth.auth().currentUser!.displayName!
                self.myActivityIndicator.startAnimating()
                let url=URL(string : MyConstants.marketplace_generate_purchase_link)
                var request = URLRequest(url: url!)
                request.setValue(token, forHTTPHeaderField: MyConstants.Authorization)
                
                request.httpMethod = "POST"
                let user_data = "&email="+email+"&name="+name
                let postString = "user_id="+myuserid!+"&beat_id="+current_selected_index+user_data
                request.httpBody = postString.data(using: .utf8)
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else{
                        self.current_selected_index = ""
                        self.myActivityIndicator.stopAnimating()
                        self.display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK")
                        return
                    }
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                        self.current_selected_index = ""
                        self.myActivityIndicator.stopAnimating()
                        self.display_alert(msg_title: "Error1", msg_desc: String(describing: response), action_title: "OK")
                    }else{
                        do{
                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                                DispatchQueue.main.async (execute: {
                                    self.myActivityIndicator.stopAnimating()
                                    let status = json["status"] as! Int
                                    if(status == 1){
                                        let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pur_req_sid") as! MarketplacePurchaseVC
                                        let pur_url = json["slug"] as! String
                                        child_view.mylink = pur_url
                                        self.addChildViewController(child_view)
                                        child_view.view.frame = self.view.frame
                                        self.view.addSubview(child_view.view)
                                        self.current_selected_index = ""
                                        child_view.didMove(toParentViewController: self)
                                    }else{
                                        self.current_selected_index = ""
                                        let msg = json["msg"] as! String
                                        self.display_alert(msg_title: "Error", msg_desc: msg, action_title: "Ok")
                                    }
                                })
                            }
                        } catch let error {
                            self.current_selected_index = ""
                            self.display_alert(msg_title: "Error3", msg_desc: error.localizedDescription, action_title: "OK")
                        }
                    }
                };task.resume()
            }else{
                current_selected_index = ""
                self.display_alert(msg_title: "LogIn First", msg_desc: "Please login first", action_title: "OK")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    //MARK: - Audio Player methods
    
    func play_audio_online(myindex : Int)
    {
        current_time_in_second = 0
        if(current_playing)
        {
            player?.pause()
            player = nil
            timer.invalidate()
            current_playing = false
        }
        
        if(self.LatestAudioArray.count > myindex){
            let selectedAudio = self.LatestAudioArray[myindex]
            do
            {
                if selectedAudio.track != ""
                {
                    self.isInitialized = false
                    let contentURL = URL(string:selectedAudio.track!)!
                    
                    player = AVPlayer(url: contentURL)
                    let playerLayer = AVPlayerLayer(player: self.player)
                    playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 3.0 / 4.0)
                    self.view.layer.addSublayer(playerLayer)
                    
                    if #available(iOS 10, *) {
                        self.player?.automaticallyWaitsToMinimizeStalling = false
                    }
                    
                    if #available(iOS 10, *) {
                        self.player?.playImmediately(atRate: 1.0)
                        self.audio_play = true
                        self.img_play_pause_ref.image = UIImage(named: "marketplace_pause")
                    } else {
                        self.player?.play()
                        self.audio_play = true
                        self.img_play_pause_ref.image = UIImage(named: "marketplace_pause")
                    }
                    self.current_playing = true
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                    self.becomeFirstResponder()
                    if(!self.isInitialized){
                        self.isInitialized = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            self.scrubber_init()
                        })
                        
                    }else{
                        //self.img_play_pause_ref.image = UIImage(named: "marketplace_play")
                        self.img_play_pause_ref.image = UIImage(named: "marketplace_pause")
                        self.removeLoadingScreen()
                    }
                    
                    DispatchQueue.main.async {
                        self.img_play_pause_ref.image = UIImage(named: "marketplace_pause")
                        self.view2_nm_lbl_ref.text = selectedAudio.name
                        self.view2_producer_lbl_ref.text = selectedAudio.producer_name
                        self.view2_type_lbl_ref.text = selectedAudio.type!.uppercased()
                        self.view2_genre_lbl_Ref.text = selectedAudio.genre
                        
                        self.for_purchase_beat_id = selectedAudio.id!
                        self.selected_audio_name = selectedAudio.name!
                        self.for_purchase_amount = selectedAudio.price!
                        self.selected_audio_producer_name = selectedAudio.producer_name!
                        
                        if(selectedAudio.price == "0"){
                            self.view2_purchase_btn_ref.setTitle("Free", for: .normal)
                        }else{
                            self.view2_purchase_btn_ref.setTitle("$" + selectedAudio.price!, for: .normal)
                        }
                        self.view2_ref.alpha = 1.0
                        self.selected_index = myindex
                        self.bottom_title_lbl_ref.text = selectedAudio.name
                        if(selectedAudio.producer_name != ""){
                            self.bottom_author_lbl_ref.text = "By " + selectedAudio.producer_name!
                        }
                        self.check_file_availability(myURL : contentURL)
                    }
                }else{
                    self.display_alert(msg_title: "Connection Error", msg_desc: "Can not get file from server.", action_title: "OK")
                    self.removeLoadingScreen()
                }
            }
        }else{}
    }
    
    func check_file_availability(myURL : URL){
        let task=URLSession.shared.dataTask(with: myURL) { (data, response, error) in
            if( error != nil ){
                print("error4")
            }else{
                DispatchQueue.main.sync (execute: {
                    if let urlContent = data{
                        do{
                            
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            self.stop_music_player()
                            let jsonArray = jsonResult.value(forKey: "error") as! NSDictionary
                            let msg = jsonArray.value(forKey: "message") as! String
                            self.removeLoadingScreen()
                            self.display_alert(msg_title: "Error", msg_desc: msg, action_title: "OK")
                            self.view2_ref.alpha = 0.0
                        }catch{}
                    }
                })
            }
        }
        task.resume()
    }
    
    func stop_music_player(){
        if(current_playing){
            player?.pause()
        }
        player = nil
        timer.invalidate()
    }
    
    
    @IBAction func btn_play_pause_click(_ sender: UIButton) {
        btn_play_pause_click()
    }
    @IBAction func btn_play_next_song(_ sender: UIButton) {
        
        if(current_play_song_index == 0){
            play_next_song()
        }else{
            play_next_song()
        }
        
    }
    
    func play_previous_song(){
        let gen_index = NSIndexPath(row: current_play_song_index, section: 0)
        let cell1 = marketplace_tbl_ref.cellForRow(at: gen_index as IndexPath) as? market_audio_list_tbl_Cell
        cell1?.audio_time_lbl_ref.text = ""
        current_play_song_index = current_play_song_index - 1
        if(current_play_song_index < 0)
        {
            self.display_alert(msg_title: "First Song", msg_desc: "You are listening first song", action_title: "OK")
            current_play_song_index = 0
        }else{
            self.audio_scrubber_ref.value = 0.0
            let visible = marketplace_tbl_ref.indexPathsForVisibleRows
            for vs in visible!{
                let gen_index = NSIndexPath(row: vs.row, section: 0)
                let cell1 = marketplace_tbl_ref.cellForRow(at: gen_index as IndexPath) as! market_audio_list_tbl_Cell
                cell1.audio_time_lbl_ref.text=""
                if (vs.row == current_play_song_index)
                {
                    cell1.change_imageToPause()
                }else{
                    cell1.change_imageToPlay()
                }
            }
            
            DispatchQueue.main.async{
                if(Reachability.isConnectedToNetwork()){
                    self.myActivityIndicator.startAnimating()
                    DispatchQueue.global(qos: .default).async {
                        self.play_audio_online(myindex: self.current_play_song_index)
                    }
                }else{
                    self.display_alert(msg_title: "No Internet Connection", msg_desc: "For Play - make sure your device is connected to the internet", action_title: "OK")
                }
            }
        }
    }
    
    func play_next_song(){
        let gen_index = NSIndexPath(row: current_play_song_index, section: 0)
        let cell1 = marketplace_tbl_ref.cellForRow(at: gen_index as IndexPath) as? market_audio_list_tbl_Cell
        cell1?.audio_time_lbl_ref.text = ""
        let limit = self.LatestAudioArray.count - 1
        current_play_song_index = current_play_song_index + 1
        if(current_play_song_index > limit)
        {
          
            player?.pause()
            player = nil
            timer.invalidate()
            current_playing = false
            
            let visible = marketplace_tbl_ref.indexPathsForVisibleRows
            for vs in visible!{
                let gen_index = NSIndexPath(row: vs.row, section: 0)
                let cell1 = marketplace_tbl_ref.cellForRow(at: gen_index as IndexPath) as? market_audio_list_tbl_Cell
                cell1?.audio_time_lbl_ref.text=""
                cell1?.change_imageToPlay()
                
            }
            current_play_song_index = 0
            img_play_pause_ref.image = UIImage(named: "marketplace_play")
            self.display_alert(msg_title: "Last Song", msg_desc: "You are listening Last Song.", action_title: "OK")
            
        }
        else
        {
            self.audio_scrubber_ref.value = 0.0
            let visible = marketplace_tbl_ref.indexPathsForVisibleRows
            for vs in visible!{
                let gen_index = NSIndexPath(row: vs.row, section: 0)
                let cell1 = marketplace_tbl_ref.cellForRow(at: gen_index as IndexPath) as? market_audio_list_tbl_Cell
                cell1?.audio_time_lbl_ref.text=""
                if (vs.row == current_play_song_index){
                    cell1?.change_imageToPause()
                }else{
                    cell1?.change_imageToPlay()
                }
            }
            
            DispatchQueue.main.async{
                if(Reachability.isConnectedToNetwork()){
                    self.myActivityIndicator.startAnimating()
                    DispatchQueue.global(qos: .default).async {
                        self.play_audio_online(myindex: self.current_play_song_index)
                    }
                }else{
                    self.display_alert(msg_title: "No Internet Connection", msg_desc: "For Play - make sure your device is connected to the internet", action_title: "OK")
                }
                
            }
        }
    }
    
    func finishedPlaying( _ myNotification:NSNotification)
    {
        if(inMarketplace){
            let gen_index = NSIndexPath(row: current_play_song_index, section: 0)
            let cell1 = marketplace_tbl_ref.cellForRow(at: gen_index as IndexPath) as? market_audio_list_tbl_Cell
            cell1?.audio_time_lbl_ref.text = ""
            play_next_song()
        }
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        let gen_index = NSIndexPath(row: current_play_song_index, section: 0)
        let cell1 = marketplace_tbl_ref.cellForRow(at: gen_index as IndexPath) as? market_audio_list_tbl_Cell
        cell1?.audio_time_lbl_ref.text = ""
        play_next_song()
    }
    
    //MARK: - Manage Scrubber

    var maximumValue = 1.0
    var seekPosition = 0.0
    
    func scrubber_init()
    {
        
        if let max = player?.currentItem?.duration.seconds{
            maximumValue = max
        }
        
        if(maximumValue>0){
            myActivityIndicator.stopAnimating()
            self.audio_scrubber_ref.maximumValue = Float(maximumValue)
            let artwork = MPMediaItemArtwork(image: #imageLiteral(resourceName: "tully.png"))
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle : self.selected_audio_name,
                MPMediaItemPropertyArtist : self.selected_audio_producer_name,
                MPMediaItemPropertyPlaybackDuration : maximumValue,
                MPMediaItemPropertyArtwork : artwork
            ]
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(Marketplaceswitchvc.updatescrubber), userInfo: nil, repeats: true)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.scrubber_init()
            })
        }
    }
    
    func updatescrubber()
    {
        do{
            if( player?.currentItem?.loadedTimeRanges != nil && !(player?.currentItem?.loadedTimeRanges.isEmpty)!){
                let i = player?.currentItem?.loadedTimeRanges.startIndex
                if(i == 0){
                    if(current_playing){
                        guard var loadedSize = try player?.currentItem?.loadedTimeRanges[i!].timeRangeValue.duration.seconds else {return}
                        loadedSize = loadedSize * 2.0
                        loadedSize += seekPosition
                        if(loadedSize > 0){
                            if( loadedSize > maximumValue){
                                loadedSize = maximumValue
                            }
                            progressBar.progress = Float(loadedSize/maximumValue)
                            self.audio_scrubber_ref.value = Float((player?.currentTime().seconds)!)
                            let current = Double((player?.currentTime().seconds)!)
                            setTimetoLabel(time: current)
                            
                        }else{
                            myActivityIndicator.stopAnimating()
                        }
                    }
                }
            }else{
                print("loaded time range < 0")
            }
        }catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func setTimetoLabel(time: Double){
        let mytime = time + 1.5
        let minutes = Int(mytime/60)
        let seconds = Int(mytime) - minutes*60
        let gen_index = NSIndexPath(row: current_play_song_index, section: 0)
        let cell1 = marketplace_tbl_ref.cellForRow(at: gen_index as IndexPath) as? market_audio_list_tbl_Cell
        cell1?.audio_time_lbl_ref.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    @IBAction func audio_scrubber_value_changed(_ sender: Any)
    {
        if(current_playing)
        {
            seekPosition = Double(audio_scrubber_ref.value)
            player?.seek(to: CMTime(seconds: Double(audio_scrubber_ref.value), preferredTimescale: 10) )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                if(self.current_playing){
                    let maxDuration = CMTime(seconds: Double(self.audio_scrubber_ref.value), preferredTimescale: 1)
                    MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(maxDuration)
                    self.player?.play()
                }
            })
        }
    }
    
    //MARK: - Play Pause
    func btn_play_pause_click() {
        if(current_playing)
        {
            if(audio_play)
            {
               player?.pause()
               let maxDuration = CMTime(seconds: Double(audio_scrubber_ref.value), preferredTimescale: 1)
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 0
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(maxDuration)
                audio_play = false
                img_play_pause_ref.image = UIImage(named: "marketplace_play")
                player_changing_btn_play()
            }else{
                player?.play()
                self.view2_ref.alpha = 1.0
                let maxDuration = CMTime(seconds: Double(audio_scrubber_ref.value), preferredTimescale: 1)
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(maxDuration)
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 1
                audio_play = true
                img_play_pause_ref.image = UIImage(named: "marketplace_pause")
                player_changing_btn_pause()
            }
        }else{
            current_play_song_index = -1
            play_next_song()
        }
    }
    
    func player_changing_btn_play(){
        let gen_index = NSIndexPath(row: current_play_song_index, section: 0)
        let cell1 = marketplace_tbl_ref.cellForRow(at: gen_index as IndexPath) as! market_audio_list_tbl_Cell
        cell1.change_imageToPlay()
    }
    
    func player_changing_btn_pause()
    {
        let gen_index = NSIndexPath(row: current_play_song_index, section: 0)
        let cell1 = marketplace_tbl_ref.cellForRow(at: gen_index as IndexPath) as! market_audio_list_tbl_Cell
        cell1.change_imageToPause()
    }
    
    //MARK: - Profile pic change
    
    @IBAction func change_profile_pic(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        myActivityIndicator.startAnimating()
        var selectedImageFromPicker : UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            selectedImageFromPicker = editedImage
        }
        else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = pickedImage
        }
        
        if var selectImage = selectedImageFromPicker
        {
            selectImage = self.resizeImage(image: selectedImageFromPicker!)
            
            if let userid = Auth.auth().currentUser?.uid
            {
                let storageRef = Storage.storage().reference().child("profile_pictures").child("\(userid).png")
                
                let imageData = UIImageJPEGRepresentation(selectImage, 0.1)! as Data
                
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    
                    if let error = error
                    {
                        self.myActivityIndicator.stopAnimating()
                        self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                    }
                    else
                    {
                        if let myurl = metadata?.downloadURL()
                        {
                            let myImg = myurl.absoluteString
                            
                            let pro_img_data: [String: Any] = ["myimg": myImg]
                            let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
                            
                            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changeRequest?.photoURL = myurl
                            changeRequest?.commitChanges { (error) in
                                if let error = error
                                {
                                    
                                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                                }
                            }
                            userRef.child("profile").updateChildValues(pro_img_data, withCompletionBlock: { (error, reference) in
                                
                                if let error = error{
                                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                                }else{
                                    self.user_img_ref.image = selectImage
                                    self.navigationController?.popViewController(animated: true)
                                }
                            })
                            self.myActivityIndicator.stopAnimating()
                        }else{
                            self.myActivityIndicator.stopAnimating()
                        }
                    }
                })
            }
        }else{
            myActivityIndicator.stopAnimating()
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func resizeImage(image: UIImage) -> UIImage {
        let size = image.size
        
        let widthRatio  = 500  / size.width
        let heightRatio = 500 / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion:nil)
    }
    //MARK: - Manage 2ndView
    
    func view2Clear(){
        self.view2_nm_lbl_ref.text = ""
        self.view2_producer_lbl_ref.text = ""
        self.view2_type_lbl_ref.text = ""
        self.view2_genre_lbl_Ref.text = ""
        self.view2_purchase_btn_ref.setTitle("$", for: .normal)
        bottom_title_lbl_ref.text = ""
        bottom_author_lbl_ref.text = ""
        audio_play = false
        player = nil
        progressBar.setProgress(0.0, animated: true)
        self.audio_scrubber_ref.value = 0.0
        for_purchase_beat_id = ""
        for_purchase_amount = ""
        img_play_pause_ref.image = UIImage(named: "marketplace_play")
    }
    
    @IBAction func view2_back_btn_click(_ sender: UIButton) {
        self.view2_ref.alpha = 0.0
    }
    
    @IBAction func view2_purchase_btn_click(_ sender: UIButton) {
        if(for_purchase_amount == "0"){
            self.current_selected_index = self.for_purchase_beat_id
            self.generate_token_for_purchase_free_beat()
        }else{
            let message1 = "Do you want to buy " + selected_audio_name + " for " + view2_purchase_btn_ref.currentTitle! + "?"
            let ac = UIAlertController(title: "Confirm Your Purchase", message: message1, preferredStyle: .alert)
            ac.view.tintColor = UIColor(red: 47/255, green: 201/255, blue: 143/255, alpha: 1)
            ac.addAction(UIAlertAction(title: "Cancel", style: .default){
                (result : UIAlertAction) -> Void in
            })
            ac.addAction(UIAlertAction(title: "Purchase", style: .default){
                (result : UIAlertAction) -> Void in
                self.current_selected_index = self.for_purchase_beat_id
                self.generate_token_for_purchase_beat()
            })
            self.present(ac, animated: true)
        }
    }
    
    //MARK: - Custom loading screen
    
    func setLoadingScreen(myMsg : String) {
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (marketplace_tbl_ref.frame.width / 2) - (width / 2)
        let y = (UIScreen.main.bounds.size.height / 2 ) - 15
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        self.loadingLabel.textColor = UIColor.white
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = myMsg
        self.loadingLabel.frame = CGRect(x: 0, y: 0, width: 160, height: 30)
        self.loadingLabel.isHidden = false
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        self.spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.spinner.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        self.view.addSubview(loadingView)
    }
    
    func removeLoadingScreen() {
        self.spinner.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        self.loadingLabel.isHidden = true
    }
    
    //MARK: - Display Alert
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
        })
        present(ac, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        inMarketplace = false
        
        if let myPlayer = player{
            if(current_playing){
                if(audio_play){
                    myPlayer.pause()
                    audio_play = false
                    timer.invalidate()
                    current_playing = false
                }
            }
            DispatchQueue.main.async {
                self.audio_scrubber_ref.value = 0.0
            }
            player = nil
        }
    }
    
    @IBAction func open_settings(_ sender: UIButton) {
        if(!flag_open_setting){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingVC_Sid") as! SettingVC
            flag_open_setting = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func generate_api_security(){
        ApiAuthentication.get_authentication_token().then({ (token) in
            self.get_audio_list_data(token: token)
        }).catch({ (err) in
            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: err.localizedDescription, action_title: "Ok", myVC: self)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

