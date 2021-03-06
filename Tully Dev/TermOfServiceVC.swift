//
//  TermOfServiceVC.swift
//  Tully Dev
//
//  Created by macbook on 8/15/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import WebKit

class TermOfServiceVC: UIViewController, WKNavigationDelegate, WKUIDelegate {

    
    @IBOutlet var myView: UIView!
    var come_as_present = false
    var myUrlString = "https://drive.google.com/uc?id=0B52VwE7cG-_wQ2NoV1NtbEN5ekU&export=download"
    var myWebView: WKWebView!
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(!come_as_present){
            self.navigationController?.isNavigationBarHidden = true
        }
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        open_link()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 21/255, green: 22/255, blue: 29/255, alpha: 1)
        
    }
    
    func open_link(){
        let url = URL(string: myUrlString)
        let request = URLRequest(url: url!)
        myWebView = WKWebView(frame: self.view.frame)
        myWebView.navigationDelegate = self
        myWebView.uiDelegate = self
        myWebView.load(request)
        self.myView.addSubview(myWebView)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView,didStartProvisionalNavigation navigation: WKNavigation){
        myActivityIndicator.startAnimating()
    }
    
    /* Stop the network activity indicator when the loading finishes */
    func webView(_ webView: WKWebView,didFinish navigation: WKNavigation){
        myActivityIndicator.stopAnimating()
    }
    
    
    @IBAction func go_back(_ sender: UIButton){
        if(come_as_present){
            dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
