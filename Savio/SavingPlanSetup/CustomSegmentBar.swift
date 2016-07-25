//
//  CustomSegmentBar.swift
//  CustomToggleButton
//
//  Created by Mangesh on 09/06/16.
//  Copyright © 2016 Mangesh  Tekale. All rights reserved.
//

import UIKit
import Foundation

class CustomSegmentBar: UIView {
    
    var leftButton: UIButton?
    var rightButton: UIButton?
    var activeButton: UIButton?
    var midOfToggleView: CGFloat?
    let sideOffset : CGFloat = 2.0
    let topOffset: CGFloat = 4.0
    let leftTitle = "Month"
    let rightTitle = "Week"
    
    let fontSize: CGFloat = 10.0
      var colorDataDict : Dictionary<String,AnyObject> =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
    var segmentSelected = { (idx: Int)  in
     
    }
    
    override func drawRect(rect: CGRect) {
        
        self.midOfToggleView = self.frame.width / 2
        let widthActBtn = (self.frame.width - 2 * self.sideOffset ) / 2
        let heightActBtn = self.frame.height - (self.sideOffset  + self.topOffset)

        self.leftButton = UIButton()
        self.leftButton?.backgroundColor = self.setUpColor()
        self.leftButton?.frame = CGRectMake(self.sideOffset, self.topOffset, widthActBtn, heightActBtn)
        self.leftButton?.setTitle(leftTitle, forState: UIControlState.Normal)
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.leftButton!.bounds, byRoundingCorners: ([.TopLeft, .BottomLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.leftButton!.bounds
        maskLayer.path = maskPath.CGPath
        self.leftButton?.layer.mask = maskLayer
        
        self.leftButton?.addTarget(self, action:Selector("toggleButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.leftButton?.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 10)
        self.leftButton?.tag = 1
        self.addSubview(self.leftButton!)
        
        self.rightButton = UIButton()
        self.rightButton?.backgroundColor = self.setUpColor()
        self.rightButton?.frame = CGRectMake(self.midOfToggleView!, self.topOffset, widthActBtn, heightActBtn)
        self.rightButton?.setTitle(rightTitle, forState: UIControlState.Normal)
        let maskPath2: UIBezierPath = UIBezierPath(roundedRect: self.rightButton!.bounds, byRoundingCorners: ([.TopRight, .BottomRight]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer2: CAShapeLayer = CAShapeLayer()
        maskLayer2.frame = self.rightButton!.bounds
        maskLayer2.path = maskPath2.CGPath
        self.rightButton?.layer.mask = maskLayer2
        
        self.rightButton?.addTarget(self, action:Selector("toggleButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.rightButton?.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 10)
        self.rightButton?.tag = 0
        self.addSubview(self.rightButton!)
        
        self.activeButton = UIButton()
        self.activeButton?.backgroundColor = UIColor(red: (53/255),green : (56/255),blue:(68/255),alpha:1)
        self.activeButton?.setTitle(leftTitle, forState: UIControlState.Normal)
        self.activeButton?.frame = CGRectMake(self.sideOffset, self.sideOffset , widthActBtn , heightActBtn)
        let maskPath3: UIBezierPath = UIBezierPath(roundedRect: self.activeButton!.bounds, byRoundingCorners: ([.TopLeft, .BottomLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer3: CAShapeLayer = CAShapeLayer()
        maskLayer3.frame = self.activeButton!.bounds
        maskLayer3.path = maskPath3.CGPath
        self.activeButton?.layer.mask = maskLayer3

        self.activeButton?.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 10)
//        self.activeButton?.addTarget(self, action:#selector(toggleButton), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(self.activeButton!)
    }
    
    func toggleButton(sender: UIButton)  {
        
        segmentSelected(sender.tag)
        if activeButton?.frame.origin.x == midOfToggleView {
           // UIView.animateWithDuration(0.5, animations: {
                let widthActBtn = (self.frame.width - 2 * self.sideOffset ) / 2
                let heightActBtn = self.frame.height - (self.sideOffset  + self.topOffset)
                self.activeButton?.frame = CGRectMake(self.sideOffset, self.sideOffset , widthActBtn , heightActBtn)
            let maskPath3: UIBezierPath = UIBezierPath(roundedRect: self.activeButton!.bounds, byRoundingCorners: ([.TopLeft, .BottomLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
            let maskLayer3: CAShapeLayer = CAShapeLayer()
            maskLayer3.frame = self.activeButton!.bounds
            maskLayer3.path = maskPath3.CGPath
            self.activeButton?.layer.mask = maskLayer3
                self.activeButton?.setTitle(self.leftTitle, forState: UIControlState.Normal)

          //  })
            
        } else {
           // UIView.animateWithDuration(0.5, animations: {
                let widthActBtn = (self.frame.width - 2 * self.sideOffset ) / 2
                let heightActBtn = self.frame.height - (self.sideOffset  + self.topOffset)
                self.activeButton?.frame = CGRectMake(self.midOfToggleView!, self.sideOffset , widthActBtn , heightActBtn)
            let maskPath3: UIBezierPath = UIBezierPath(roundedRect: self.activeButton!.bounds, byRoundingCorners: ([.TopRight, .BottomRight]), cornerRadii: CGSizeMake(3.0, 3.0))
            let maskLayer3: CAShapeLayer = CAShapeLayer()
            maskLayer3.frame = self.activeButton!.bounds
            maskLayer3.path = maskPath3.CGPath
            self.activeButton?.layer.mask = maskLayer3
                self.activeButton?.setTitle(self.rightTitle, forState: UIControlState.Normal)

          //  })

        }
    }
    
    func setUpColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        
        if(colorDataDict["title"] as! String == "Group Save")
        {
            red = 161/255
            green = 214/255
            blue = 248/255
            
        }
        else if(colorDataDict["title"] as! String == "Wedding")
        {
            red = 189/255
            green = 184/255
            blue = 235/255
        }
        else if(colorDataDict["title"] as! String == "Baby")
        {
            red = 122/255
            green = 223/255
            blue = 172/255
        }
        else if(colorDataDict["title"] as! String == "Holiday")
        {
            red = 109/255
            green = 214/255
            blue = 200/255
        }
        else if(colorDataDict["title"] as! String == "Ride")
        {
            red = 242/255
            green = 104/255
            blue = 107/255
        }
        else if(colorDataDict["title"] as! String == "Home")
        {
            red = 244/255
            green = 161/255
            blue = 111/255
        }
        else if(colorDataDict["title"] as! String == "Gadget")
        {
            red = 205/255
            green = 220/255
            blue = 57/255
        }
        else
        {
            red = 244/255
            green = 176/255
            blue = 58/255
        }
        return UIColor(red:red as CGFloat, green: green as CGFloat, blue: blue as CGFloat, alpha: 1)
    }
}