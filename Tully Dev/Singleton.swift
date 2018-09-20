//
//  Singleton.swift
//  Tully Dev
//
//  Created by Prashant  on 17/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation
class Singleton: NSObject {
    static var shared = Singleton()
    var projectID = String()
}
