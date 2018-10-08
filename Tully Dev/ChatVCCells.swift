//
//  ChatVCCells.swift
//  Tully Dev
//
//  Created by Apple on 20/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation
import UIKit


class SenderCell: UITableViewCell {
    
    //MARK: IBOutlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var messageUser: UILabel!
    @IBOutlet weak var docImageView: UIImageView!
    @IBOutlet weak var docName: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var downloadImage: UIImageView!
    
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
        self.messageBackground.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.messageBackground.layer.cornerRadius = 5
        self.messageBackground.clipsToBounds = true
        self.profilePic.layer.cornerRadius = 15
        self.profilePic.clipsToBounds = true
        self.outerView.layer.cornerRadius = 5
        self.outerView.clipsToBounds = true
    }
}

class ReceiverCell: UITableViewCell {
    
    //MARK: IBOutlets
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    @IBOutlet weak var messageUser: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var docImageView: UIImageView!
    @IBOutlet weak var docName: UILabel!
    
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
        self.messageBackground.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.messageBackground.layer.cornerRadius = 5
        self.messageBackground.clipsToBounds = true
        self.outerView.layer.cornerRadius = 5
        self.outerView.clipsToBounds = true
    }
}

class ChatRecipientCell: UITableViewCell {
    
    //MARK: IBOutlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var recipientName: UILabel!
    
    func clearCellData()  {
        self.recipientName.text = nil
        self.profilePic.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.profilePic.layer.cornerRadius = 15
        self.profilePic.clipsToBounds = true
    }
}


//MARK: ENUM Declaration
enum MessageOwner {
    case sender
    case receiver
}

enum MessageType {
    case photo
    case text
    case docs
}

enum ShowExtraView {
    case contacts
    case profile
    case preview
    case map
}
