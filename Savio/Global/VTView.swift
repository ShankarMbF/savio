//
//  VTView.swift
//  BlazeTrail
//
//  Created by Mangesh on 01/09/15.
//  Copyright (c) 2015 Mangesh  Tekale. All rights reserved.
//

import UIKit
import CoreGraphics

let styleCircleWhiteBorder = "S1"
let styleCircleBlueBorder = "S2" // Dark Blue Colour for corner radius
let styleLeftSideWhiteRoundedCorners = "SLRW" //  (S)tyle (L)eft side (R)ounded corners (W)hite color
let styleRightSideWhiteRoundedCorners = "SRRW" //  (S)tyle (R)ight side (R)ounded corners (W)hite color


class VTView:  UIView {
    
    var style: String {
        
        get {
           return  self.style
        }
        
        set(style) {
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue()) { () -> Void in
                VTView.styleView(self, style: style)

            }
        }
    }
    
    class func styleView(view: UIView, style: String) {
        
        switch style {
            
        case styleCircleWhiteBorder:
            view.layer.cornerRadius = view.frame.width/2
            view.layer.borderColor = UIColor.whiteColor().CGColor
            view.layer.borderWidth = 1
            
        case styleCircleBlueBorder:
            view.layer.cornerRadius = view.frame.width/2
            view.layer.borderColor = ColorCodes.colorForCode(colorBlueBgDark).CGColor
            view.layer.borderWidth = 1
            
        case styleLeftSideWhiteRoundedCorners:
            let path  = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [UIRectCorner.BottomLeft, UIRectCorner.TopLeft], cornerRadii: CGSize(width: 5.0, height: 5.0))
            
            let mask = CAShapeLayer()
            
            mask.path = path.CGPath
            view.layer.mask = mask

        case styleRightSideWhiteRoundedCorners:
            let path  = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [UIRectCorner.BottomRight, UIRectCorner.TopRight], cornerRadii: CGSize(width: 5.0, height: 5.0))
            let mask = CAShapeLayer()
            mask.path = path.CGPath
            view.layer.mask = mask
            
            default: print("Default line reached")
            
        }
    }
}

class VTImageView: UIImageView {
    
    var style: String {
        get {
            return  self.style
        }
        set(style) {
            VTView.styleView(self, style: style)
        }
    }
    
}
