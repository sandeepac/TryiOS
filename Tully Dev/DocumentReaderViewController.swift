//
//  DocumentReaderViewController.swift
//  Tully Dev
//
//  Created by Apple on 20/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Alamofire

class DocumentReaderViewController: UIViewController, UIWebViewDelegate {
    
    //MARK: IBOutelets
    @IBOutlet weak var webViewObj: UIWebView!
    @IBOutlet weak var activityIndicatorObj: UIActivityIndicatorView!
    @IBOutlet weak var imageViewObj: UIImageView!
    
    var fileURL : String? = nil
    
    var type = ""
    
    let mimeTypeImage = "png"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: fileURL!)
        
        if type == mimeTypeImage {
            
            activityIndicatorObj.isHidden = true
            
            imageViewObj.image = UIImage(contentsOfFile: fileURL!)
        }
        else {
            
            activityIndicatorObj.startAnimating()
            
            webViewObj.loadRequest(URLRequest.init(url: url!))
        }
    }
    
    //MARK: Button Action methods
    @IBAction func backBtnPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UIWebViewDelegate methods
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        return true
    }
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        
        activityIndicatorObj.isHidden = true
        activityIndicatorObj.stopAnimating()
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        activityIndicatorObj.isHidden = true
        activityIndicatorObj.stopAnimating()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
