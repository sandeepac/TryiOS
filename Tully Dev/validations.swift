//
//  validations.swift
//  Tully Dev
//
//  Created by Kathan on 10/04/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation

class validations : NSObject{
    
    
    
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
}
