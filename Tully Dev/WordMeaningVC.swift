//
//  WordMeaningVC.swift
//  Tully Dev
//
//  Created by macbook on 6/7/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Mixpanel

class WordMeaningVC: UIViewController
{
    
    @IBOutlet var txtview_ref: UITextView!
    var myword = ""
    var mydesc = ""
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        MyConstants.showAnimate(myView: self.view)
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        if(myword != ""){
            printWordMeaning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Mixpanel.mainInstance().track(event: "Definition Selected")
    }
    
    func printWordMeaning()
    {
        let desc_word = self.myword.capitalized + " - " + mydesc
        
        let selectedText_length = (self.myword.count)
        let myrange = NSMakeRange(0, selectedText_length)
        let attributedString = NSMutableAttributedString(string:desc_word)
                            
        let txt_view_range = NSMakeRange(0, (desc_word.count))
                            
        let attributes = [NSForegroundColorAttributeName: UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!] as [String : Any]
        attributedString.addAttributes(attributes, range: txt_view_range)
        
        let attributes_selected = [NSForegroundColorAttributeName: UIColor(red: 34/255, green: 209/255, blue: 151/255, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir-Black", size: 16.0)!] as [String : Any]
        attributedString.addAttributes(attributes_selected , range: myrange)
 
        self.txtview_ref.attributedText = attributedString
        self.txtview_ref.setContentOffset(.zero, animated: true)
    }

    @IBAction func close_btn_click(_ sender: Any) {
        MyConstants.removeAnimate(myView: self.view, myVC: self)
    }
    
    @IBAction func close_view(_ sender: Any) {
        MyConstants.removeAnimate(myView: self.view, myVC: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
