//
//  slider.swift
//  Savio
//
//  Created by Maheshwari on 07/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class slider: UISlider {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect:CGRect = CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width-140, height: 8)
        return rect
    }
}
