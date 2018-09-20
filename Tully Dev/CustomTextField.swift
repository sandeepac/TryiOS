//
//  CustomTextField.swift
//  Tully Dev
//
//  Created by macbook on 6/2/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit

enum MenuState
{
    case select
    case copy
    case cut
    case paste
    //case all
    case none
}

/*
class CustomTextField: UITextView
{
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool
    {
        /*
         if action == #selector(copy(_:)) || action == #selector(paste(_:)) || action == #selector(selectAll(_:)) || action == #selector(cut(_:)) || action == Selector(("_lookup:")) || action == Selector(("_share:"))
         {
         return false
         }
         return super.canPerformAction(action, withSender: sender)
         return false
         */
        
        if action == #selector(select(_:)) || action == #selector(copy(_:)) || action == #selector(selectAll(_:)) || action == #selector(paste(_:))
        {
            return true
        }
        return false
    }
}
*/

class CustomTextField: UITextView
{
    
    var currentState : MenuState = .select
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool
    {
        switch self.currentState {
        case .select:
            if action == #selector(select(_:)) || action == #selector(selectAll(_:))
            {
                return true
            }
        case .copy:
            if action == #selector(copy(_:)) || action == #selector(select(_:)) || action == #selector(cut(_:)) || action == #selector(selectAll(_:))
            {
                return true
            }
        case .cut:
            if action == #selector(copy(_:)) || action == #selector(select(_:)) || action == #selector(cut(_:)) || action == #selector(selectAll(_:))
            {
                return true
            }
        case .paste:
            if action == #selector(paste(_:)) || action == #selector(select(_:)) || action == #selector(selectAll(_:))
            {
                return true
            }
//        case .all:
//            if  action == #selector(select(_:)) || action == #selector(selectAll(_:)) || action == #selector(cut(_:)) || action == #selector(copy(_:)) || action == #selector(paste(_:))
//            {
//                return true
//            }
        case .none:
            return false
        }
        return false
    }
    
    override func select(_ sender: Any?) {
        super.select(sender)
       // self.currentState = .copy
        if(Reachability.isConnectedToNetwork())
        {
            self.currentState = .none
        }
    }
    
    override func selectAll(_ sender: Any?) {
        super.selectAll(sender)
        self.currentState = .copy
    }
    
    override func copy(_ sender: Any?) {
        super.copy(sender)
        UIPasteboard.general.string = MyVariables.lyticsTextCopy
        self.currentState = .paste
    }
    
    override func cut(_ sender: Any?) {
        super.cut(sender)
        self.currentState = .paste
    }
    
    override func paste(_ sender: Any?) {
        super.paste(sender)
        self.currentState = .paste
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        self.currentState = .paste
        return true
    }
   
}


