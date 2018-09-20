//
//  ChatViewController.swift
//  Tully Dev
//
//  Created by Apple on 17/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: IBOutlets & variables
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    
    var isKeyboardAppered = false
    
    var items = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        
        inputTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: Keyboard Notification methods
    func keyboardWillShow(notification:NSNotification) {
        
        if !isKeyboardAppered {
            
            adjustingHeight(show:true, notification: notification)
            
            isKeyboardAppered = true
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        
        isKeyboardAppered = false
        
        adjustingHeight(show:false, notification: notification)
        
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        
        var userInfo = notification.userInfo!
        
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        let changeInHeight = (keyboardFrame.height) * (show ? 1 : -1)
        
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.containerViewBottomConstraint.constant += changeInHeight
        })
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    //MARK: Downloads messages
    func fetchData() {
        
        Message.downloadAllMessages(completion: {[weak weakSelf = self] (message) in
            
            let recievedMessageText = message.content as! String
            let recievedTimestamp = message.timestamp
            
            for i in 0..<self.items.count {
                
                let messageText = self.items[i].content as! String
                let timestamp = self.items[i].timestamp
                
                if messageText == recievedMessageText && timestamp == recievedTimestamp {
                    
                    return
                }
            }
            
            weakSelf?.items.append(message)
            
            weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
            DispatchQueue.main.async {
                if let state = weakSelf?.items.isEmpty, state == false {
                    weakSelf?.chatTableView.reloadData()
                    weakSelf?.chatTableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        })
    }
    
    //MARK: Button Action methods
    @IBAction func backBtnPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        
        if let text = self.inputTextField.text {
            
            if !text.isEmpty {
                self.composeMessage(type: .text, content: self.inputTextField.text!)
                self.inputTextField.text = ""
            }
        }
    }
    
    @IBAction func showOptions(_ sender: Any) {
        
        inputTextField.resignFirstResponder()
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoAction: UIAlertAction = UIAlertAction(title: "Choose Photo", style: .default) { action -> Void in
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let documentAction: UIAlertAction = UIAlertAction(title: "Document", style: .default) { action -> Void in
            
            let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.microsoft.word.doc","org.openxmlformats.wordprocessingml.document", kUTTypePDF as String], in: .import)
            
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        actionSheetController.addAction(photoAction)
        actionSheetController.addAction(documentAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func composeMessage(type: MessageType, content: Any)  {
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        
        userRef.child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let data = snapshot.value as? NSDictionary
            
            if((data?.value(forKey: "artist_name") as? String) != nil) {
                
                let name = data?.value(forKey: "artist_name") as? String
                
                let message = Message.init(type: type, content: content, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false, messageUserName: name!)
                
                Message.send(message: message, completion: {(_) in
                    
                })
            }
        })
    }
    
    //MARK: UIImagePickerControllerDelegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.composeMessage(type: .photo, content: pickedImage)
        }
        else {
            
            let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.composeMessage(type: .photo, content: pickedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: TableView DataSource & Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.items[indexPath.row].owner {
            
        case .receiver:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
            cell.clearCellData()
            
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
                
                cell.timestamp.text = getFormattedDate(timestamp: self.items[indexPath.row].timestamp)
                
                cell.messageUser.text = self.items[indexPath.row].messageUserName
            case .photo:
                
                cell.timestamp.text = getFormattedDate(timestamp: self.items[indexPath.row].timestamp)
                
                cell.messageUser.text = self.items[indexPath.row].messageUserName
                
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.chatTableView.reloadData()
                            }
                        }
                    })
                }
            case .docs:
                cell.message.text = "Document File"
                
                cell.timestamp.text = getFormattedDate(timestamp: self.items[indexPath.row].timestamp)
                
                cell.messageUser.text = self.items[indexPath.row].messageUserName
            }
            return cell
        case .sender:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
            cell.clearCellData()
            //            cell.profilePic.image = self.currentUser?.profilePic
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
                
                cell.timestamp.text = getFormattedDate(timestamp: self.items[indexPath.row].timestamp)
                
                cell.messageUser.text = self.items[indexPath.row].messageUserName
                
            case .photo:
                
                cell.timestamp.text = getFormattedDate(timestamp: self.items[indexPath.row].timestamp)
                
                cell.messageUser.text = self.items[indexPath.row].messageUserName
                
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.chatTableView.reloadData()
                            }
                        }
                    })
                }
            case .docs:
                cell.message.text = "Document File"
                
                cell.timestamp.text = getFormattedDate(timestamp: self.items[indexPath.row].timestamp)
                
                cell.messageUser.text = self.items[indexPath.row].messageUserName
                
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.inputTextField.resignFirstResponder()
    }
    
    func getFormattedDate(timestamp : Int) -> String {
        
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: Calendar.current.timeZone.abbreviation()!) //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm a" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        return strDate
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

extension ChatViewController: UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        self.composeMessage(type: .docs, content: url)
        
    }
}
