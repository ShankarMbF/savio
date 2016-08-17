//
//  VTButton.swift
//  BlazeTrail
//
//  Created by Mangesh on 01/09/15.
//  Copyright (c) 2015 Mangesh  Tekale. All rights reserved.
//

import UIKit
let btnStyleA1 = "A1"
let btnStyleA2 = "A2" // Background Color Dark Blue and white circle border 1
let btnStyleA3 = "A3" // Background Color white and dark blue circle border 1 


class VTButton: UIButton {
    
    /*
    var color: UIColor  {
        get {
            return self.color
        }
        set(color) {
            let image = self.imageView?.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            self.tintColor = color
            self.setImage(image, forState: UIControlState.Normal)
        }
    }

    var styleLayer: String {
        get {
            return self.styleLayer
        }
        set(style) {
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue()) { () -> Void in
                VTView.styleView(self, style: style)
            }
        }
    }
    
    
    var style: String {
        get {
            return self.style
        }
        set(style) {
            switch style {
            case btnStyleA1:
                self.setTitleColor(ColorCodes.colorForCode(colorBlueBgDark), forState: UIControlState.Normal)
                self.setTitleColor(ColorCodes.colorForCode(colorBlueBgLight), forState: UIControlState.Highlighted)
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
                self.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
                self.titleLabel?.font = FontCodes.fontForCode(code: fontHelveticaNeue_Bold, size: 18)

            case btnStyleA2:
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                self.setTitleColor(ColorCodes.colorForCode(colorBlueBgLight), forState: UIControlState.Highlighted)
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
                self.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
                self.titleLabel?.font = FontCodes.fontForCode(code: fontHelveticaNeue_Bold, size: 18)
                self.backgroundColor = ColorCodes.colorForCode(colorBlueBgDark)
                
            case btnStyleA3:
                self.setTitleColor(ColorCodes.colorForCode(colorBlueBgDark), forState: UIControlState.Normal)
                self.setTitleColor(ColorCodes.colorForCode(colorBlueBgLight), forState: UIControlState.Highlighted)
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
                self.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
                self.titleLabel?.font = FontCodes.fontForCode(code: fontHelveticaNeue_Bold, size: 18)
                self.backgroundColor = UIColor.whiteColor()

            default:
                self.setTitleColor(ColorCodes.colorForCode(colorBlueBgDark), forState: UIControlState.Normal)
                self.setTitleColor(ColorCodes.colorForCode(colorBlueBgLight), forState: UIControlState.Highlighted)
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
                self.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
            }
        }
 
    }
 */
}
