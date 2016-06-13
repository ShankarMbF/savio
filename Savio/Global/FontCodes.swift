//
//  FontCodes.swift
//  BlazeTrail
//
//  Created by Mangesh on 31/08/15.
//  Copyright (c) 2015 Mangesh  Tekale. All rights reserved.
//

import Foundation
import UIKit

var fontHelveticaNeue = "HelveticaNeue"
var fontHelveticaNeue_Bold = "HelveticaNeue-Bold"
var fontHelveticaNeue_LIght = "HelveticaNeue-Light"

class FontCodes: NSObject {
    class func fontForCode(code code: String, size: CGFloat)  -> UIFont {
        var font: UIFont?
        switch code {
        case fontHelveticaNeue_Bold:  font =  UIFont(name: "HelveticaNeue-Bold", size: size)
        case fontHelveticaNeue_LIght:  font =  UIFont(name: "HelveticaNeue-Light", size: size)
        case fontHelveticaNeue:  font =  UIFont(name: "HelveticaNeue", size: size)
        default: font = UIFont.systemFontOfSize(15)
        }
        return (font != nil) ? font! : UIFont.systemFontOfSize(15)
    }
}
