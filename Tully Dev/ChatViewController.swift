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
import SDWebImage

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: IBOutlets & variables
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerDateLbl: UILabel!
    @IBOutlet weak var recipientTableView: UITableView!
    @IBOutlet weak var recipientTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImageView1: UIImageView!
    @IBOutlet weak var headerImageView2: UIImageView!
    @IBOutlet weak var collaboratorCountLbl: UILabel!
    
    var isKeyboardAppeared = false
    
    var items = [Message]()
    var recipientList = [[String : Any]]()
    var currentProjectId = ""
    var currentCollaborationId = ""
    
    var alert = UIAlertController()
    
    var recipientListForHeader = [[String : Any]]()
    var filterRecipientList = [[String : Any]]()
    
    var isRecipientListShown = false
    var isSearching = false
    
    var keyboardHeight = 0
    var containerViewInitialHeight = 54
    
    //MARK: Constants declaration
    
    let dateFormat = "MMM dd YYYY"
    let dateFomatInTime = "h:mm a"
    let storyboardName = "Main"
    let mimeTypeImage = "png"
    let mimeTypePDF = "pdf"
    let mimeTypeDoc = "doc"
    let textViewPlaceholderColor = UIColor.lightGray
    let textViewTextColor = UIColor.black
    
    let parameter_collaboration_id = "collaboration_id"
    let parameter_project_id = "project_id"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextView.delegate = self
        
        inputTextView.text = Utils.shared.textViewPlaceholderText
        inputTextView.textColor = textViewPlaceholderColor
        inputTextView.autocorrectionType = .no

        chatTableView.keyboardDismissMode = .none
        
        headerDateLbl.isHidden = true
        recipientTableHeightConstraint.constant = 0
        
        LocalImages.createTullyFolder()
        
        getToken()
        
        fetchData()
        
        setImageOnNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        containerViewHeightConstraint.constant = CGFloat(containerViewInitialHeight)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: Keyboard Notification methods
    func keyboardWillShow(notification:NSNotification) {
        
        if !isKeyboardAppeared {
            
            adjustingHeight(show:true, notification: notification)
            
            isKeyboardAppeared = true
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        
        isRecipientListShown = false
        
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
        
        keyboardHeight = Int(keyboardFrame.height)
        
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.containerViewBottomConstraint.constant += changeInHeight
        })
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    //MARK: Downloads messages from firebase
    func fetchData() {
        
        Message.downloadAllMessages(projectId: currentProjectId, collaborationId: currentCollaborationId, completion: {[weak weakSelf = self] (message) in
            
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
//                    weakSelf?.chatTableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        })
    }
    
    //MARK: Button Action methods
    @IBAction func backBtnPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func settingBtnPressed(_ sender: Any) {
        
        inputTextView.resignFirstResponder()
        
        let vc : ListOfCollaboratorsViewController = UIStoryboard.init(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: "ListOfCollaboratorsViewController") as! ListOfCollaboratorsViewController
        vc.collaboratioId = currentCollaborationId
        vc.currentProjectId = currentProjectId
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        
        if inputTextView.textColor != textViewPlaceholderColor && !inputTextView.text.isEmpty {
            
            self.composeMessage(type: .text, content: self.inputTextView.text!, mimeType: "")
            self.inputTextView.text = ""
        }
        else {
            
            self.inputTextView.resignFirstResponder()
            
            let alert = UIAlertController(title: "", message: Utils.shared.blankTextViewPopup, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: Utils.shared.okText, style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func showOptions(_ sender: Any) {
        
        inputTextView.resignFirstResponder()
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoAction: UIAlertAction = UIAlertAction(title: Utils.shared.choosePhoto, style: .default) { action -> Void in
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let documentAction: UIAlertAction = UIAlertAction(title: Utils.shared.document, style: .default) { action -> Void in
            
            let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.microsoft.word.doc","org.openxmlformats.wordprocessingml.document", kUTTypePDF as String], in: .import)
            
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: Utils.shared.cancel, style: .cancel) { action -> Void in
            
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
            
            if snapshot.exists() {
                
                let data = snapshot.value as? NSDictionary
                
                if((data?.value(forKey: "artist_name") as? String) != nil) {
                    
                    let name = data?.value(forKey: "artist_name") as? String
                    
                    let milliseconds = Int64(Date().timeIntervalSince1970 * 1000.0)
                    
                    let currentUserID = Auth.auth().currentUser?.uid as! String
                    
                    let message = Message.init(type: type, content: content, owner: .sender, timestamp: milliseconds, messageUserName: name!, fromID: currentUserID)
                    
                    Message.send(projectId: self.currentProjectId, message: message, mimeType: mimeType, completion: {(_) in
                        
                        //Have to perform UI changes
                    })
                }
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
        
        alert = UIAlertController(title: "", message: Utils.shared.uploading, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: TableView DataSource & Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 1 {
            
            if isSearching {
                
                return filterRecipientList.count
            }
            else {
                
                return recipientList.count
            }
        }
        else {
            
            return self.items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 1 {
            
            let cell = recipientTableView.dequeueReusableCell(withIdentifier: "chatRecipientCell", for: indexPath) as! ChatRecipientCell
            
            cell.clearCellData()
            
            var array = [[String : Any]]()
            
            if isSearching {
                
                array = filterRecipientList
            }
            else {
                
                array = recipientList
            }
            
            if let dict = array[indexPath.row] as? [String : Any] {
                
                cell.recipientName.text = dict["artist_name"] as? String
                
                if let imageString = dict["myimg"] as? String {
                    
                    cell.profilePic.sd_setImage(with: URL(string: imageString), placeholderImage: #imageLiteral(resourceName: "Image1"))
                }
                else {
                    
                    cell.profilePic.image = #imageLiteral(resourceName: "Image1")
                }
            }
            return cell
        }
        else {
            
            switch self.items[indexPath.row].owner {
                
            case .receiver:
                
                let cell = chatTableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
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
                    
                    //                    if let imgUrl = self.items[indexPath.row].content as? String {
                    //
                    //                        cell.messageBackground.sd_setImage(with: URL(string: imgUrl), placeholderImage: #imageLiteral(resourceName: "loading"))
                    //                    }
                    //                    else {
                    //
                    //                        cell.messageBackground.image = UIImage.init(named: "loading")
                    //                    }
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
                let cell = chatTableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
                cell.clearCellData()
                
                cell.timestamp.text = getTimestamp(indexPath: indexPath as NSIndexPath)
                
                cell.messageUser.text = getMessageUserName(indexPath: indexPath as NSIndexPath)
                
                let imgUrl = getImageForRecipient(userId: items[indexPath.row].fromID!)
                if !imgUrl.isEmpty {
                    
                    cell.profilePic.sd_setImage(with: URL(string: imgUrl), placeholderImage: #imageLiteral(resourceName: "Image1"))
                }
                else {
                    
                    cell.profilePic.image = #imageLiteral(resourceName: "Image1")
                }
                
                switch self.items[indexPath.row].type {
                case .text:
                    cell.message.text = getMessageContent(indexPath: indexPath as NSIndexPath)
                    
                    cell.downloadImage.isHidden = true
                    cell.docImageView.isHidden = true
                    cell.docName.isHidden = true
                    cell.message.isHidden = false
                    cell.messageBackground.isHidden = true
                case .photo:
                    
                    let isFileExist = LocalImages.checkIsFileExist(timestamp: self.items[indexPath.row].timestamp, mimeType: mimeTypeImage)
                    
                    if isFileExist {
                        
                        cell.messageBackground.alpha = 1.0
                        cell.downloadImage.isHidden = true
                    }
                    else {
                        
                        cell.messageBackground.alpha = 0.7
                        cell.docImageView.image = #imageLiteral(resourceName: "file_download")
                        cell.docName.text = "Download"
                        cell.downloadImage.isHidden = false
                    }
                    
                    //                    if let imgUrl = self.items[indexPath.row].content as? String {
                    //
                    //                        cell.messageBackground.sd_setImage(with: URL(string: imgUrl), placeholderImage: #imageLiteral(resourceName: "loading"))
                    //                    }
                    //                    else {
                    //
                    //                        cell.messageBackground.image = UIImage.init(named: "loading")
                    //                    }
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
                    
                    cell.downloadImage.isHidden = true
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
        
        if tableView.tag == 1 {
            
            var array = [[String : Any]]()
            
            if isSearching {
                
                array = filterRecipientList
            }
            else {
                
                array = recipientList
            }
            
            if let dict = array[indexPath.row] as? [String : Any] {
                
                let name = dict["artist_name"] as? String
                
                let text = inputTextView.text!
                
                let split = text.split(separator: " ")
                
                let firstCharacter = text.first
                
                if split.count > 1 {
                    
                    let myStringWithoutLastWord = text.components(separatedBy: " ").dropLast().joined(separator: " ")
                    
                    inputTextView.text = "\(myStringWithoutLastWord) @\(name ?? "")"
                }
                else if firstCharacter == "@" {
                    
                    inputTextView.text = "@\(name ?? "") "
                }
                else {
                    
                    inputTextView.text = "\(text)\(name ?? "") "
                }
                
                recipientTableHeightConstraint.constant = 0
                isRecipientListShown = false
                isSearching = false
            }
        }
        else {
            
            isRecipientListShown = false
            recipientTableHeightConstraint.constant = 0
            
            if !isKeyboardAppeared {
                
                if self.items[indexPath.row].type == .photo {
                    
                    let isFileExist = LocalImages.checkIsFileExist(timestamp: self.items[indexPath.row].timestamp, mimeType: mimeTypeImage)
                    
                    if isFileExist {
                        
                        redirectView(indexPath: indexPath, mimeType: mimeTypeImage)
                    }
                    else {
                        
                        saveImageInPhotos(string: items[indexPath.row].content as! String)
                        
                        LocalImages.saveImage(url: URL(string: items[indexPath.row].content as! String)!, timestamp: items[indexPath.row].timestamp)
                        
                        chatTableView.reloadRows(at: [indexPath], with: .automatic)
//                        chatTableView.reloadData()
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
                        
                        alert = UIAlertController(title: "", message: Utils.shared.downloadingDocument, preferredStyle: UIAlertControllerStyle.alert)
                        self.present(alert, animated: true, completion: nil)
                        
                        LocalImages.saveDocuments(url: URL(string: contentString)!, timestamp: items[indexPath.row].timestamp, mimeType: mimeType, completion: { (isSaved) in
                            
                            self.alert.dismiss(animated: true, completion: nil)
                        })
                        
                        chatTableView.reloadRows(at: [indexPath], with: .automatic)
//                        chatTableView.reloadData()
                    }
                }
            }
            else {
                
                self.inputTextView.resignFirstResponder()
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
        
        self.navigationController?.pushViewController(viewController, animated: true)
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
            
            messageDate = Utils.shared.yesterday
        }
        else if calendar.isDateInToday(date) {
            
            messageDate = Utils.shared.today
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
            textView.text = Utils.shared.textViewPlaceholderText
            textView.textColor = textViewPlaceholderColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let firstCharacter = textView.text.first
        
        filterRecipientList.removeAll()
        
        let lastOneCharacter = textView.text.suffix(1)
        let lastTwoCharacter = textView.text.suffix(2)
        
        let str = inputTextView.text!
        let split = str.split(separator: "@")
        
        if lastTwoCharacter == " " || lastOneCharacter == " " || lastOneCharacter == "" {
            
            isRecipientListShown = false
            recipientTableHeightConstraint.constant = 0
        }
        else if lastTwoCharacter == " @" || lastTwoCharacter == "@" || lastTwoCharacter == "\n@" {
            
            isSearching = false
            
            isRecipientListShown = true
            recipientTableHeightConstraint.constant = 150
            recipientTableView.reloadData()
        }
        else if isRecipientListShown {
            
            if split.count > 1 || firstCharacter == "@" {
                
                isSearching = true
                
                let lastWord = split[split.count-1]
                
                let lastWordLowerCased = lastWord.lowercased()
                
                filterRecipientList = recipientList.filter({
                    
                    ($0["artist_name"] as! String).lowercased().contains(lastWordLowerCased)
                })
            }
            else {
                
                isSearching = false
            }
            
            if filterRecipientList.count > 0 {
                
                isRecipientListShown = true
                recipientTableHeightConstraint.constant = 150
                recipientTableView.reloadData()
            }
            else {
                
                isRecipientListShown = false
                recipientTableHeightConstraint.constant = 0
            }
        }
        else {
            
            isRecipientListShown = false
            recipientTableHeightConstraint.constant = 0
        }
        
        setHeightForContainerView()
    }
    
    func setHeightForContainerView() {
        
        if containerViewHeightConstraint.constant > CGFloat(containerViewInitialHeight) {
            
            containerViewHeightConstraint.constant = CGFloat(containerViewInitialHeight)
        }
        
        var totalNewLine = 0
        for (_, char) in inputTextView.text!.enumerated() {
            if char == "\n" {
                
                totalNewLine += 1
            }
        }
        
        var height = 0
        switch totalNewLine {
        case 0:
            height = 0
        case 1:
            height = 10
        case 2:
            height = 20
        case 3:
            height = 30
        case 4:
            height = 45
        default:
            height = 45
        }
        
        containerViewHeightConstraint.constant = containerViewHeightConstraint.constant + CGFloat(height)
    }
    
    //MARK: getToken method
    func getToken() {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("collaborations").child(currentProjectId).child(currentCollaborationId).observeSingleEvent(of: .value, with: { (snap) in
            
            if snap.exists() {
                
                self.recipientList.removeAll()
                for task in snap.children {
                    
                    guard let taskSnapshot = task as? DataSnapshot else { return }
                    
                    guard let userIdKey = taskSnapshot.key as? String else { return }
                    
                    let currentUserID = Auth.auth().currentUser?.uid
                    
                    if currentUserID != userIdKey {
                        
                        ref.child(userIdKey).child("profile").observeSingleEvent(of: .value, with: { (innerSnap) in
                            
                            if innerSnap.exists() {
                                
                                var receivedData = innerSnap.value as! [String: Any]
                                
                                receivedData["userId"] = userIdKey
                                self.recipientList.append(receivedData)
                                
                                //                                self.setImageOnNavigationBar()
                            }
                        })
                    }
                }
            }
        })
    }
    
    // Check Internet connection
    /*if(Reachability.isConnectedToNetwork()){
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
     parameter_collaboration_id: currentCollaborationId,
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
     let recipientArray = json["users"] as! [[String : Any]]
     
     let currentUserID = Auth.auth().currentUser?.uid
     
     for i in 0..<recipientArray.count {
     
     if let dict = recipientArray[i] as? [String : Any] {
     
     let userId = dict["user_id"] as! String
     
     if currentUserID != userId {
     
     self.recipientList.append(recipientArray[i])
     }
     }
     }
     }
     case .failure(let error):
     print(error)
     }
     }
     }*/
    
    //MARK: saveImageInPhotos method
    func saveImageInPhotos(string: String) {
        
        let data = try? Data(contentsOf: URL(string: string)!)
        
        if let imageData = data {
            
            let image = UIImage(data: imageData)
            
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: Utils.shared.msgError, message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: Utils.shared.okText, style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "", message: Utils.shared.savedPhoto, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: Utils.shared.okText, style: .default))
            present(ac, animated: true)
        }
    }
    
    func getImageForRecipient(userId: String) -> String {
        
        var imgUrl = ""
        
        for i in recipientList {
            
            let recipientUserId = i["userId"] as! String
            
            if userId == recipientUserId {
                
                if let myimg = i["myimg"] as? String {
                    
                    imgUrl = myimg
                    
                    break
                }
            }
        }
        
        return imgUrl
    }
    
    func setImageOnNavigationBar() {
        
        if recipientListForHeader.count == 1 {
            
            headerImageView2.isHidden = true
            collaboratorCountLbl.isHidden = true
        }
        else if recipientListForHeader.count == 2 {
            
            headerImageView2.isHidden = false
            collaboratorCountLbl.isHidden = true
        }
        else {
            
            headerImageView2.isHidden = false
            collaboratorCountLbl.isHidden = false
        }
        
        if !recipientListForHeader.isEmpty {
            
            collaboratorCountLbl.text = "+\(recipientListForHeader.count - 2)"
        }
        
        var imgUrl1 = "", imgUrl2 = ""
        
        for i in recipientListForHeader {
            
            if let myimg = i["myimg"] as? String {
                
                if imgUrl1.isEmpty {
                    
                    imgUrl1 = myimg
                }
                else {
                    
                    imgUrl2 = myimg
                }
            }
        }
        
        headerImageView1.sd_setImage(with: URL(string: imgUrl1), placeholderImage: #imageLiteral(resourceName: "Image1"))
        headerImageView2.sd_setImage(with: URL(string: imgUrl2), placeholderImage: #imageLiteral(resourceName: "Image1"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ChatViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        alert = UIAlertController(title: "", message: Utils.shared.uploading, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        
        self.composeMessage(type: .docs, content: url, mimeType: url.pathExtension)
    }
}
