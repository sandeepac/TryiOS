//
//  Utils.swift
//  Tully Dev
//
//  Created by iOS on 25/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//
import Foundation
import UIKit

class Utils: NSObject {
     static let shared = Utils()
    
    //MARK: Email Validation
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func set_CircleImage(imageView: UIImageView){
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
    }
    func set_CircleView(view: UIView){
        view.layer.masksToBounds = false
        view.layer.cornerRadius = view.frame.height/2
        view.clipsToBounds = true
    }
    //MARK: message
    let networkEmail = "Network Error"
    let msgNoNetConnection = "No internet connection."
    let msgEnterValidEmail = "Email is invalid"
    let msginviteSend = "Invitation Sent"
    let msgsigninAlert = "Please signin again."
    let msgNotValidTullyUser = "This is not a valid Tully user."
    let msgError = "Error"
    let msgExpiretime = "Select expire time"
    
    //MARK: ChatViewController
    let blankTextViewPopup = "Please enter some text"
    let okText = "OK"
    let choosePhoto = "Choose Photo"
    let document = "Document"
    let cancel = "Cancel"
    let uploading = "Uploading..."
    let downloadingDocument = "Downloading the file..."
    let savedPhoto = "Saved Photo"
    let today = "Today"
    let yesterday = "Yesterday"
    let textViewPlaceholderText = "Message"
    
    //MARK: SubscribeViewController
    let purchase_failed = "Purchase Failed"
    
    //MARK: InviteVC
    let not_null = "Not null"
    let can_not_send = "Can not send"
    let you_cannot_send_invitation_to_yourself = "You cannot send an invitation to yourself"
    let user_already_invited = "User already invited"
    
    //MARK: AcceptInviteVC
    let invited_you_to_collaborate = "invited you to collaborate"
    
    //MARK: CollaboratorsListVC
    let alert = "Alert"
    let are_you_sure_you_want_to_remove = "are you sure you want to remove "
    let owner = "Owner"
    let admin = "Admin"
    let textViewPlaceholder = "Enter lyrics Here"
    
    //MARK: HomeVC
    let you_cannot_delete_collaboration_project = "You cannot delete collaboration project"
    
    //MARK: CollabrationViewController
    let error = "Error"
    let not_found = "Not Found"
    let file_not_found = "File not found."
    let cant_get_file_path = "Can't get file path"
    let project_not_found = "Project Not Found"
    let cant_found_project = "Can't found project."
    let dont_have_access_to_use_your_microphone = "Don't have access to use your microphone."
    let cant_null = "Can't null"
    let please_write_something = "Please write something"
    let recording_failed = "Recording failed."
    let noRecording = "No recordings"
    let noRecordingfound = "No recordings found."
    let reciverCellIdentifier = "reciverCellIdentifier"
    let reciverNibName = "reciverCell"
    let audio_scrubber_color = "remaining_track_color"
    let note_img_name = "note-blue"
    let recording_imgNamed = "Recording_Selected_tab"
    let bluerecordingimgNamed = "recording-blue"
    let recordingGrrenimgNamed = "green-play"
    let recordingStartimg = "recording-start"
    let msgDontUseMicrophone = "Don't have access to use your microphone."
    let updatelyrics = "Update lyrics in project"
    
}


