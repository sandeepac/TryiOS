//
//  MyHalfSlider.swift
//  Tully Dev
//
//  Created by macbook on 7/17/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit

class MyHalfSlider: UISlider {

    override func trackRect(forBounds bounds: CGRect) -> CGRect
    {
        let myrect = CGRect(x: 5, y: 15, width: (UIScreen.main.bounds.width/3), height: 10)
        return myrect
    }

}
