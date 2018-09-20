//
//  ShareViewController.swift
//  Tully
//
//  Created by macbook on 11/30/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var audioExtFlag = false
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        placeholder = "filename.ext"

        if(contentText.contains(".mp3") || contentText.contains(".m4a") || contentText.contains(".wav"))
        {
            return true
        }
        return false
    }
    
override func didSelectPost()
{
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        myActivityIndicator.center = view.center
        self.view.addSubview(myActivityIndicator)
        myActivityIndicator.startAnimating()
        
        var filename = ""
        if(contentText.contains(".mp3") || contentText.contains(".m4a") || contentText.contains(".wav"))
        {
            audioExtFlag = true
            if let range = contentText.range(of: ".mp3")
            {
                let substring = contentText[..<range.upperBound]
                filename = String(substring)
            }
            else if let range = contentText.range(of: ".m4a")
            {
                let substring = contentText[..<range.upperBound]
                filename = String(substring)
            }
            else if let range = contentText.range(of: ".wav")
            {
                let substring = contentText[..<range.upperBound]
                filename = String(substring)
            }
            else
            {
                print("String not present")
            }
        }
        else
        {
            audioExtFlag = false
        }
        
    if(audioExtFlag)
    {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = item.attachments?.first as? NSItemProvider {
                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                        
                        if error != nil
                        {
                            print(error.localizedDescription)
                        }
                        
                        if let shareURL = url as? NSURL
                        {
                            let myUrl = shareURL.absoluteString
                            
                            if ( myUrl!.contains("drive.google.com"))
                            {
                                let myId = myUrl!.split(separator: "/")
                                if var index = myId.index(of: "d")
                                {
                                    index = index + 1
                                    let audio_id = myId[index]
                                    let download_string = "https://drive.google.com/uc?export=download&id=" + audio_id
                                    let download_url = URL(string: download_string)
                                    self.downloadUrl(audioUrl: download_url!, filename: filename)
                                }
                            }
                            else if( myUrl!.contains("www.dropbox.com"))
                            {
                                let download_string = myUrl! + "?dl=1"
                                let download_url = URL(string: download_string)
                                self.downloadUrl(audioUrl: download_url!, filename: filename)
                            }
                            else if( myUrl!.contains("file:///"))
                            {
                                self.saveAsMailAttachment(audioUrl: shareURL as URL, filename: filename)
                            }
                            else
                            {
                                print("not drive data")
                                self.myActivityIndicator.stopAnimating()
                                self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
                            }
                            
                            //self.downloadUrl(audioUrl : shareURL as URL)
                        }
                        
                    })
                }
            }
        }
    }
    else
    {
            self.myActivityIndicator.stopAnimating()
    }
        //self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
}
    
    // email save as attachment
    
    
    
    func saveAsMailAttachment(audioUrl : URL, filename : String)
    {
        let dataPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.tully.share")!.appendingPathComponent("copytoTully")
        
        do
        {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
        
        let destinationUrl = dataPath.appendingPathComponent(filename)
        
        let mydata = NSData(contentsOf: audioUrl)
        
        do
        {
            try mydata?.write(to: destinationUrl, options: .atomic)
            self.myActivityIndicator.stopAnimating()
            self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
            self.myActivityIndicator.stopAnimating()
            self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
        }
        
        
    }
    
    
    // Download from google drive
    
    func downloadUrl(audioUrl : URL, filename : String)
    {
        let dataPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.tully.share")!.appendingPathComponent("copytoTully")
        
        do
        {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
        
        let destinationUrl = dataPath.appendingPathComponent(filename)
        
        URLSession.shared.downloadTask(with: audioUrl, completionHandler:
            { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    self.myActivityIndicator.stopAnimating()
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                    self.myActivityIndicator.stopAnimating()
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
                }
        }).resume()
        
    }
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.red, NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 16.0)!]
        let titleAttrString = NSMutableAttributedString(string: msg_title, attributes: attributes)
        ac.setValue(titleAttrString, forKey: "attributedTitle")
        ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            //_ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
}

