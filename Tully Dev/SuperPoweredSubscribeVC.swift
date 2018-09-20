//
//  SuperPoweredSubscribeVC.swift
//  Tully Dev
//
//  Created by Kathan on 26/07/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import FirebaseAuth
import Promise

class SuperPoweredSubscribeVC: UIViewController, dismissProtocol {

    @IBOutlet weak var bpm_detect_view: UIView!
    @IBOutlet weak var bpmDetectImgRef: UIImageView!
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var myView : SuperPoweredSpinnerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        
        let x = (bpmDetectImgRef.frame.origin.x - 7)
        myView = SuperPoweredSpinnerView(frame: CGRect(x: x, y: 0, width: 60, height: 60))
        self.bpm_detect_view.addSubview(myView)
        // Do any additional setup after loading the view.
    }
    @IBAction func btn_continue_click(_ sender: UIButton) {
        
        IAPService.shared.getProducts()
        IAPService.shared.purchase(product: .autoRenewingSubscription)
        
        //ApiAuthentication.get_authentication_token(callback: self.subscribeBpm)
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }

    @IBAction func close_view(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func super_power_subscribe(_ sender: UIButton) {
        
        ApiAuthentication.get_authentication_token().then({ (token) in
            
            self.myActivityIndicator.startAnimating()
            self.subscribeBpm(token: token)
            
        }).catch({ (err) in
            
            self.display_alert(msg_title: "Error", msg_desc: err.localizedDescription, action_title: "Ok")
            
        })
        
        //ApiAuthentication.get_authentication_token(callback: self.subscribeBpm)
        //self.myActivityIndicator.startAnimating()
    }
        
    func subscribeBpm(token : String){
        self.myActivityIndicator.startAnimating()
        if let myuserid = Auth.auth().currentUser?.uid{
            if let email = Auth.auth().currentUser!.email{
                if let name = Auth.auth().currentUser!.displayName{
                    
                    let MyUrlString = MyConstants.audio_analyzer_purchase_link
                    var request = URLRequest(url: URL(string: MyUrlString)!)
                    request.setValue(token, forHTTPHeaderField: MyConstants.Authorization)
                    request.httpMethod = "POST"
                    
                    let user_data = "&email="+email+"&name="+name
                    let postString = "uid="+myuserid+"&token="+token+user_data
                    //let myString = "uid="+myuserid
                    
                    //let postString = myString+share_string
                    request.httpBody = postString.data(using: .utf8)
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else{
                            DispatchQueue.main.async{
                                self.myActivityIndicator.stopAnimating()
                            }
                            self.display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK")
                            
                            return
                        }
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                            DispatchQueue.main.async{
                                self.myActivityIndicator.stopAnimating()
                            }
                            self.display_alert(msg_title: "Error", msg_desc: String(describing: response), action_title: "OK")
                        }else{
                            do{
                                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                                    DispatchQueue.main.async (execute: {
                                        
                                        let status = json["status"] as! Int
                                        if(status == 1){
                                            let key = json["access"] as! String
                                            
                                            //let mydata = json["data"] as! NSDictionary
                                            // let mylink1 = mydata["link"] as! String
                                            let mylink = MyConstants.audio_analyzer_payment_link + key
                                            
                                            let child_view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pur_req_sid") as! MarketplacePurchaseVC
                                            child_view.dismissProtocol = self
                                            child_view.mylink = mylink
                                            
                                            self.addChildViewController(child_view)
                                            child_view.view.frame = self.view.frame
                                            self.view.addSubview(child_view.view)
                                            child_view.didMove(toParentViewController: self)
                                            
                                            
                                        }else{
                                            let msg = json["msg"] as! String
                                            self.myActivityIndicator.stopAnimating()
                                            self.display_alert(msg_title: "Error", msg_desc: msg, action_title: "Ok")
                                        }
                                    })
                                }
                            } catch let error {
                                DispatchQueue.main.async {
                                    self.myActivityIndicator.stopAnimating()
                                    self.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                                }
                            }
                        }
                    };task.resume()
                    
                }
            }
        }
    }
    
    func dismissView(){
        self.dismiss(animated: false, completion: nil)
    }
        
    // Display Alert
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
