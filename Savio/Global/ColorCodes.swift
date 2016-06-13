//
//  ColorCodes.swift
//  BlazeTrail
//
//  Created by Mangesh on 31/08/15.
//  Copyright (c) 2015 Mangesh  Tekale. All rights reserved.
//

import Foundation
import UIKit

var colorBlueBgDark = "BlueBgDark"
var colorBlueBgLight = "BlueBgLight"

class ColorCodes: NSObject {
    
class func colorForCode( colorCode: String) -> UIColor {
    
    var color : UIColor! = UIColor.whiteColor()
        switch colorCode {
            case colorBlueBgDark: color  = ColorCodes.getColor(r: 64, g: 116, b: 142, a: 1)
            case colorBlueBgLight: color  = ColorCodes.getColor(r: 123, g: 166, b: 187, a: 1)
            default:  color = UIColor.blackColor()
        }
        return color
    }

    class func getColor(r r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
                return UIColor(red: r/256.0, green: g/256.0, blue: b/256.0, alpha: a);
    }

}
