//
//  MySlider.swift
//  Tully Dev
//
//  Created by macbook on 7/17/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit

class MyLoopSlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect
    {
        let myrect = CGRect(x: 5, y: 15, width: UIScreen.main.bounds.width - 35, height: 1)
        return myrect
    }
    
}
