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
import Alamofire

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: IBOutlets & variables
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerDateLbl: UILabel!
    @IBOutlet weak var recipientTableView: UITableView!
    
    @IBOutlet weak var recipientTableHeightConstraint: NSLayoutConstraint!
    var isKeyboardAppeared = false
    
    var items = [Message]()
    
    var currentProjectId = ""
    var currentCollaborationId = ""

    var alert = UIAlertController()
    
    var recipientList = [[String : Any]]()
    
    var isRecipientListShown = false
    
    //MARK: Constants declaration
    
    let today = "Today"
    let yesterday = "Yesterday"
    let dateFormat = "MMM dd YYYY"
    let dateFomatInTime = "h:mm a"
    let storyboardName = "Main"
    let mimeTypeImage = "png"
    let mimeTypePDF = "pdf"
    let mimeTypeDoc = "doc"
    let textViewPlaceholderText = "Message"
    let textViewPlaceholderColor = UIColor.lightGray
    let textViewTextColor = UIColor.black

    let parameter_collaboration_id = "collaboration_id"
    let parameter_project_id = "project_id"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        
        inputTextView.delegate = self
        
        inputTextView.text = textViewPlaceholderText
        inputTextView.textColor = textViewPlaceholderColor

        headerDateLbl.isHidden = true
        recipientTableView.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        LocalImages.createTullyFolder()
        
        getToken()
    }
    
    //MARK: Keyboard Notification methods
    func keyboardWillShow(notification:NSNotification) {
        
        if !isKeyboardAppeared {
            
            adjustingHeight(show:true, notification: notification)
            
            isKeyboardAppeared = true
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        
        if isKeyboardAppeared {
            
            isKeyboardAppeared = false
            
            adjustingHeight(show:false, notification: notification)
        }
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        
        let userInfo = notification.userInfo!
        
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
    
    //MARK: Downloads messages from firebase
    func fetchData() {
        
        Message.downloadAllMessages(projectId: currentProjectId, completion: {[weak weakSelf = self] (message) in
            
            self.alert.dismiss(animated: true, completion: nil)
            
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
                if let state = weakSelf?.items.isEmpty, !state {
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
        
        if inputTextView.textColor != textViewPlaceholderColor && !inputTextView.text.isEmpty {
            
            self.composeMessage(type: .text, content: self.inputTextView.text!, mimeType: "")
            self.inputTextView.text = ""
        }
        else {
            
            self.inputTextView.resignFirstResponder()
            
            let alert = UIAlertController(title: "Alert", message: "Please enter some text!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func showOptions(_ sender: Any) {
        
        inputTextView.resignFirstResponder()
        
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
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
            //We dont need to add any code for Cancel button
        }
        
        actionSheetController.addAction(photoAction)
        actionSheetController.addAction(documentAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func composeMessage(type: MessageType, content: Any, mimeType: String)  {
        
        let userRef = FirebaseManager.getRefference().child((Auth.auth().currentUser?.uid)!).ref
        
        userRef.child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let data = snapshot.value as? NSDictionary
            
            if((data?.value(forKey: "artist_name") as? String) != nil) {
                
                let name = data?.value(forKey: "artist_name") as? String
                
                let milliseconds = Int64(Date().timeIntervalSince1970 * 1000.0)
                
                let message = Message.init(type: type, content: content, owner: .sender, timestamp: milliseconds, isRead: false, messageUserName: name!)
                
                Message.send(projectId: self.currentProjectId, message: message, mimeType: mimeType, completion: {(_) in
                    
                    //Have to perform UI changes
                })
            }
        })
    }
    
    //MARK: UIImagePickerControllerDelegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.composeMessage(type: .photo, content: pickedImage, mimeType: "image")
        }
        else {
            
            let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.composeMessage(type: .photo, content: pickedImage, mimeType: "image")
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        alert = UIAlertController(title: "", message: "Sending Image", preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: TableView DataSource & Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isRecipientListShown {
            
            return recipientList.count
        }
        else {
            
            return self.items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isRecipientListShown {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatRecipientCell", for: indexPath) as! ChatRecipientCell
            
            cell.clearCellData()
                        
            if let dict = recipientList[indexPath.row] as? [String : Any] {
                
                cell.recipientName.text = dict["user_name"] as? String
                
                cell.profilePic.image = #imageLiteral(resourceName: "Image1")
            }
            return cell
        }
        else {
            
            switch self.items[indexPath.row].owner {
                
            case .receiver:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
                cell.clearCellData()
                
                cell.timestamp.text = getTimestamp(indexPath: indexPath as NSIndexPath)
                
                cell.messageUser.text = getMessageUserName(indexPath: indexPath as NSIndexPath)
                
                switch self.items[indexPath.row].type {
                case .text:
                    cell.message.text = getMessageContent(indexPath: indexPath as NSIndexPath)
                    
                    cell.docImageView.isHidden = true
                    cell.docName.isHidden = true
                    cell.message.isHidden = false
                    cell.messageBackground.isHidden = true
                case .photo:
                    
                    if let image = self.items[indexPath.row].image {
                        cell.messageBackground.image = image
                    } else {
                        cell.messageBackground.image = UIImage.init(named: "loading")
                        self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                            if state {
                                DispatchQueue.main.async {
                                    self.chatTableView.reloadData()
                                }
                            }
                        })
                    }
                    
                    cell.docImageView.isHidden = true
                    cell.docName.isHidden = true
                    cell.message.isHidden = true
                    cell.messageBackground.isHidden = false
                case .docs:
                    
                    cell.docName.text = "Document File"
                    
                    cell.docImageView.isHidden = false
                    cell.docName.isHidden = false
                    cell.message.isHidden = true
                    cell.messageBackground.isHidden = true
                }
                return cell
            case .sender:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
                cell.clearCellData()
                
                cell.timestamp.text = getTimestamp(indexPath: indexPath as NSIndexPath)
                
                cell.messageUser.text = getMessageUserName(indexPath: indexPath as NSIndexPath)
                
                switch self.items[indexPath.row].type {
                case .text:
                    cell.message.text = getMessageContent(indexPath: indexPath as NSIndexPath)
                    
                    cell.docImageView.isHidden = true
                    cell.docName.isHidden = true
                    cell.message.isHidden = false
                    cell.messageBackground.isHidden = true
                case .photo:
                    
                    let isFileExist = LocalImages.checkIsFileExist(timestamp: self.items[indexPath.row].timestamp, mimeType: mimeTypeImage)
                    
                    if isFileExist {
                        
                        cell.messageBackground.alpha = 1.0
                        cell.docImageView.isHidden = true
                        cell.docName.isHidden = true
                    }
                    else {
                        
                        cell.messageBackground.alpha = 0.7
                        cell.docImageView.image = #imageLiteral(resourceName: "file_download")
                        cell.docName.text = "Download"
                        cell.docImageView.isHidden = false
                        cell.docName.isHidden = false
                    }
                    
                    if let image = self.items[indexPath.row].image {
                        cell.messageBackground.image = image
                    } else {
                        cell.messageBackground.image = UIImage.init(named: "loading")
                        self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                            if state {
                                DispatchQueue.main.async {
                                    self.chatTableView.reloadData()
                                }
                            }
                        })
                    }
                    
                    cell.message.isHidden = true
                    cell.messageBackground.isHidden = false
                case .docs:
                    
                    var mimeType = ""
                    
                    let contentString = items[indexPath.row].content as! String
                    
                    if contentString.contains(".\(mimeTypePDF)") {
                        
                        mimeType = mimeTypePDF
                    }
                    else {
                        
                        mimeType = mimeTypeDoc
                    }
                    
                    let isFileExist = LocalImages.checkIsFileExist(timestamp: self.items[indexPath.row].timestamp, mimeType: mimeType)
                    
                    if isFileExist {
                        
                        cell.docImageView.image = #imageLiteral(resourceName: "add_doc_icon")
                    }
                    else {
                        
                        cell.docImageView.image = #imageLiteral(resourceName: "file_download")
                    }
                    
                    cell.docName.text = "Document File"
                    
                    cell.docImageView.isHidden = false
                    cell.docName.isHidden = false
                    cell.message.isHidden = true
                    cell.messageBackground.isHidden = true
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isRecipientListShown {

            
        }
        else {
            
            self.inputTextView.resignFirstResponder()
            
            if !isKeyboardAppeared {
                
                if self.items[indexPath.row].type == .photo {
                    
                    let isFileExist = LocalImages.checkIsFileExist(timestamp: self.items[indexPath.row].timestamp, mimeType: mimeTypeImage)
                    
                    if isFileExist {
                        
                        redirectView(indexPath: indexPath, mimeType: mimeTypeImage)
                    }
                    else {
                        
                        LocalImages.saveImage(url: URL(string: items[indexPath.row].content as! String)!, timestamp: items[indexPath.row].timestamp)
                        
                        chatTableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
                else if self.items[indexPath.row].type == .docs {
                    
                    var mimeType = ""
                    
                    var contentString = items[indexPath.row].content as! String
                    
                    if contentString.contains(".\(mimeTypePDF)") {
                        
                        mimeType = mimeTypePDF
                        contentString = contentString.replacingOccurrences(of: ".\(mimeTypePDF)", with: "")
                    }
                    else {
                        
                        mimeType = mimeTypeDoc
                        contentString = contentString.replacingOccurrences(of: ".\(mimeTypeDoc)", with: "")
                    }
                    
                    let isFileExist = LocalImages.checkIsFileExist(timestamp: self.items[indexPath.row].timestamp, mimeType: mimeType)
                    
                    if isFileExist {
                        
                        redirectView(indexPath: indexPath, mimeType: mimeType)
                    }
                    else {
                        
                        alert = UIAlertController(title: "", message: "Saving Document", preferredStyle: UIAlertControllerStyle.alert)
                        self.present(alert, animated: true, completion: nil)
                        
                        LocalImages.saveDocuments(url: URL(string: contentString)!, timestamp: items[indexPath.row].timestamp, mimeType: mimeType, completion: { (isSaved) in
                            
                            self.alert.dismiss(animated: true, completion: nil)
                        })
                        
                        chatTableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
    
    //MARK: getMessageContent method
    func getMessageContent(indexPath : NSIndexPath) -> String {
        
        return (self.items[indexPath.row].content as? String)!
    }
    
    //MARK: getMessageUserName method
    func getMessageUserName(indexPath : NSIndexPath) -> String {
        
        return self.items[indexPath.row].messageUserName ?? ""
    }
    
    //MARK: getTimestamp method
    func getTimestamp(indexPath : NSIndexPath) -> String {
        
        return getFormattedDate(timestamp: self.items[indexPath.row].timestamp)
    }
    
    //MARK: redirectView method
    func redirectView(indexPath: IndexPath, mimeType: String) {
        
        let viewController : DocumentReaderViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: "DocumentReaderVC") as! DocumentReaderViewController
        
        viewController.fileURL = LocalImages.getFilePath(timestamp: items[indexPath.row].timestamp, mimeType: mimeType)
        
        viewController.type = mimeType
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    //MARK: scrollViewDidEndDragging method
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !items.isEmpty {
            
            setHeaderText()
        }
    }
    
    //MARK: setHeaderText method
    func setHeaderText() {
        
        let firstVisibleIndexPath = chatTableView.indexPathsForVisibleRows?[0]
        
        let timestamp = items[(firstVisibleIndexPath?.row)!].timestamp
        
        let timeInSeconds = Double(timestamp) / 1000
        
        let date = Date(timeIntervalSince1970: TimeInterval(timeInSeconds))
        
        let calendar = NSCalendar.current
        
        var messageDate = ""
        
        if calendar.isDateInYesterday(date) {
            
            messageDate = yesterday
        }
        else if calendar.isDateInToday(date) {
            
            messageDate = today
        }
        else {
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = dateFormat //Specify your format that you want
            messageDate = dateFormatter.string(from: date)
        }
        
        headerDateLbl.isHidden = false
        
        headerDateLbl.text = messageDate
    }
    
    //MARK: getFormattedDate method
    func getFormattedDate(timestamp : Int64) -> String {
        
        let timeInSeconds = Double(timestamp) / 1000
        
        let date = Date(timeIntervalSince1970: TimeInterval(timeInSeconds))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: Calendar.current.timeZone.abbreviation()!) //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = dateFomatInTime //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    
    //MARK: TextViewDelegate method
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == textViewPlaceholderColor {
            textView.text = nil
            textView.textColor = textViewTextColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceholderText
            textView.textColor = textViewPlaceholderColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let lastCharacter = textView.text.last
        
        if lastCharacter == "@" {
            
            print(lastCharacter!)
            
            isRecipientListShown = true
            recipientTableView.isHidden = false
            recipientTableView.reloadData()
            print(recipientList)
        }
        else {
            
            isRecipientListShown = false
            recipientTableView.isHidden = true
            print(textView.text)
        }
        
    }

    //MARK: getToken method
    func getToken() {
        
        // Check Internet connection
        if(Reachability.isConnectedToNetwork()){
            if (Auth.auth().currentUser?.uid) != nil {
                ApiAuthentication.get_authentication_token().then({ (token) in
                    
                    self.getRecipientsList(token: token)
                }).catch({ (err) in
                    MyConstants.normal_display_alert(msg_title: "Error", msg_desc: err.localizedDescription, action_title: "Ok", myVC: self)
                })
            }
        } else {
            
            MyConstants.normal_display_alert(msg_title: "Error", msg_desc: "No internet connection.", action_title: "Ok", myVC: self)
        }
    }
    
    //MARK: getRecipientsList method
    func getRecipientsList(token : String) {
        
        let url = MyConstants.collabrationURL
        
        let parameters = [
            parameter_collaboration_id: "-LNKdZHCW4wPx2-CnxCZ",
            parameter_project_id: currentProjectId
        ]
        
        let headers = [
            MyConstants.Authorization: token
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                
                if let json = response.result.value as? [String : Any] {
                    print(json)
                    self.recipientList = json["users"] as! [[String : Any]]
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ChatViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        alert = UIAlertController(title: "", message: "Sending Document", preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        
        self.composeMessage(type: .docs, content: url, mimeType: url.pathExtension)
    }
}
