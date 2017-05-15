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
    let leftTitle = kMonth
    let rightTitle = kWeek
    
    let fontSize: CGFloat = 10.0
    var colorDataDict : Dictionary<String,AnyObject> =  UserDefaults.standard.object(forKey: "colorDataDict") as! Dictionary<String,AnyObject>
    var segmentSelected = { (idx: Int)  in
        
    }
    
    //Draw the UIView
    override func draw(_ rect: CGRect) {
        
        //Set the frame for middleOfToggleView
        self.midOfToggleView = self.frame.width / 2
        let widthActBtn = (self.frame.width - 2 * self.sideOffset ) / 2
        let heightActBtn = self.frame.height - (self.sideOffset  + self.topOffset)
        
        //Set the frame for leftButton and customize it
        self.leftButton = UIButton()
        self.leftButton?.backgroundColor = UIColor(red: (53/255),green : (56/255),blue:(68/255),alpha:1)
        self.leftButton?.frame = CGRect(x: self.sideOffset, y: self.topOffset, width: widthActBtn, height: heightActBtn)
        self.leftButton?.setTitle(leftTitle, for: UIControlState())
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.leftButton!.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: 3.0, height: 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.leftButton!.bounds
        maskLayer.path = maskPath.cgPath
        self.leftButton?.layer.mask = maskLayer
        self.leftButton?.addTarget(self, action:#selector(CustomSegmentBar.toggleButton(_:)), for: UIControlEvents.touchUpInside)
        self.leftButton?.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 10)
        self.leftButton?.tag = 1
        self.addSubview(self.leftButton!)
        
        //Set the frame for rightButton and customize it
        self.rightButton = UIButton()
        self.rightButton?.backgroundColor = UIColor(red: (53/255),green : (56/255),blue:(68/255),alpha:1)
        self.rightButton?.frame = CGRect(x: self.midOfToggleView!, y: self.topOffset, width: widthActBtn, height: heightActBtn)
        self.rightButton?.setTitle(rightTitle, for: UIControlState())
        let maskPath2: UIBezierPath = UIBezierPath(roundedRect: self.rightButton!.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: 3.0, height: 3.0))
        let maskLayer2: CAShapeLayer = CAShapeLayer()
        maskLayer2.frame = self.rightButton!.bounds
        maskLayer2.path = maskPath2.cgPath
        self.rightButton?.layer.mask = maskLayer2
        self.rightButton?.addTarget(self, action:#selector(CustomSegmentBar.toggleButton(_:)), for: UIControlEvents.touchUpInside)
        self.rightButton?.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 10)
        self.rightButton?.tag = 0
        self.addSubview(self.rightButton!)
        
        self.activebutton()
    }
    
    func activebutton() {
        
        self.midOfToggleView = self.frame.width / 2
        let widthActBtn = (self.frame.width - 2 * self.sideOffset ) / 2
        let heightActBtn = self.frame.height - (self.sideOffset  + self.topOffset)
        
        //Set the frame for activebutton and customize it
        self.activeButton = UIButton()
        self.activeButton?.backgroundColor = self.setUpColor()
        self.activeButton?.setTitle(leftTitle, for: UIControlState())
        self.activeButton?.frame = CGRect(x: self.sideOffset, y: self.sideOffset , width: widthActBtn , height: heightActBtn)
        let maskPath3: UIBezierPath = UIBezierPath(roundedRect: self.activeButton!.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: 3.0, height: 3.0))
        let maskLayer3: CAShapeLayer = CAShapeLayer()
        maskLayer3.frame = self.activeButton!.bounds
        maskLayer3.path = maskPath3.cgPath
        self.activeButton?.layer.mask = maskLayer3
        self.activeButton?.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 10)
        self.addSubview(self.activeButton!)

    }
    
    
    //Toggle between leftButton anf rightButton
    func toggleButton(_ sender: UIButton)  {
        segmentSelected(sender.tag)
        
        if activeButton?.frame.origin.x == midOfToggleView {
            let widthActBtn = (self.frame.width - 2 * self.sideOffset ) / 2
            let heightActBtn = self.frame.height - (self.sideOffset  + self.topOffset)
            self.activeButton?.frame = CGRect(x: self.sideOffset, y: self.sideOffset , width: widthActBtn , height: heightActBtn)
            let maskPath3: UIBezierPath = UIBezierPath(roundedRect: self.activeButton!.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: 3.0, height: 3.0))
            let maskLayer3: CAShapeLayer = CAShapeLayer()
            maskLayer3.frame = self.activeButton!.bounds
            maskLayer3.path = maskPath3.cgPath
            self.activeButton?.layer.mask = maskLayer3
            self.activeButton?.setTitle(self.leftTitle, for: UIControlState())
            
        } else {
            let widthActBtn = (self.frame.width - 2 * self.sideOffset ) / 2
            let heightActBtn = self.frame.height - (self.sideOffset  + self.topOffset)
            self.activeButton?.frame = CGRect(x: self.midOfToggleView!, y: self.sideOffset , width: widthActBtn , height: heightActBtn)
            let maskPath3: UIBezierPath = UIBezierPath(roundedRect: self.activeButton!.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: 3.0, height: 3.0))
            let maskLayer3: CAShapeLayer = CAShapeLayer()
            maskLayer3.frame = self.activeButton!.bounds
            maskLayer3.path = maskPath3.cgPath
            self.activeButton?.layer.mask = maskLayer3
            self.activeButton?.setTitle(self.rightTitle, for: UIControlState())

        }
    }
    
    //Set the color of buttones as per the selected theme
    func setUpColor()-> UIColor
    {
        return ColorCodes.colorForCode(colorDataDict["savPlanID"] as! Int)
    }
}
