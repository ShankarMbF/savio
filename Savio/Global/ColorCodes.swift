//
//  ColorCodes.swift
//  BlazeTrail
//
//  Created by Mangesh on 31/08/15.
//  Copyright (c) 2015 Mangesh  Tekale. All rights reserved.
//

import Foundation
import UIKit


var kLightFont: String! = "GothamRounded-Light"
var kBookFont: String! = "GothamRounded-Book"
var kMediumFont: String! = "GothamRounded-Medium"

var kWishlistempty: String! = "Wish list empty."
var kEmptyWishListMessage: String! = "You don’t have anything in your wish list yet. Get out there and set some goals!"
var kNoNetworkMessage: String! = "Savio needs the internet to work. Check your data connection and try again."
var kMobileNumber: String! = "Mobile Number"
var kTitle: String! = "title"
var kFirstAddressLine: String! = "First Address Line"
var kSurname: String! = "Surname"
var kSecondAddressLine: String! = "Second Address Line"
var kThirdAddressLine: String! = "Third Address Line"
var kTown:String! = "Town"
var kCounty: String! = "County"
var kEmail: String! = "Email"
var kMetaData:String! = "metaData"
let kClassType: String! = "classType"
let kErrorMobileValidation : String = "errorMobileValidation"
let kLable : String! = "lable"
let kIsErrorShow : String! = "isErrorShow"
let kErrorTitle : String! = "errorTitle"
let kTitleEmpty : String! = "Please select a title"
let kTitleAndNameMissingError : String! = "We need to know your title and name"
let kEmptyName : String! = "We need to know what to call you"
let kLongName : String! = "Wow, that’s such a long name we can’t save it"
let kPartyID : String! = "partyId"
let kAmount : String! = "amount"

let kSelectRowIdentifier : String = "SelectRowIdentifier"
let kNotificationIdentifier : String = "NotificationIdentifier"

let kIndividualPlan : String = "individualPlan"
let kGroupPlan : String = "groupPlan"
let kGroupMemberPlan : String = "groupMemberPlan"
let kUsersPlan : String = "UsersPlan"
let kSAVPLANID : String = "SAV_PLAN_ID"
let kTITLE : String = "TITLE"
let kPARTYID : String = "PARTY_ID"
let kOFFERS : String = "OFFERS"
let kPAYDATE : String = "PAY_DATE"
let kPAYTYPE : String = "PAY_TYPE"
let kAMOUNT : String = "AMOUNT"
let kPLANENDDATE : String = "PLAN_END_DATE"
let kIMAGE: String = "IMAGE"
let kPARTYSAVINGPLANTYPE : String = "PARTY_SAVINGPLAN_TYPE"
let kRECURRINGAMOUNT : String = "RECURRING_AMOUNT"
let kSAVSITEURL : String = "SAV_SITE_URL"
let kImageURL : String = "imageURL"
let kEmi: String = "emi"
let kINIVITEDUSERLIST :String = "INIVITED_USER_LIST"
let kPTYSAVINGPLANID :String = "PTY_SAVINGPLAN_ID"
let kDate: String = "date"
let kDay: String = "day"
let kWeek : String = "Week"
let kMonth : String = "Month"

//Structure defined for Color
struct Color {
    static var groupPlan = 85
    static var weddingPlan = 86
    static var babyPlan = 87
    static var holidayPlan = 88
    static var ridePlan = 89
    static var homePlan = 90
    static var gadgetPlan = 91
    static var genericPlan = 92
}

//Structure defined for ShadowColor
struct ShadowColor {
    static var groupPlan = 85
    static var weddingPlan = 86
    static var babyPlan = 87
    static var holidayPlan = 88
    static var ridePlan = 89
    static var homePlan = 90
    static var gadgetPlan = 91
    static var genericPlan = 92
}

class ColorCodes: NSObject {
    
    //This function will return the specific color code for selected theme
    class func colorForCode( colorCode: Int) -> UIColor {
        
        var color : UIColor! = UIColor.whiteColor()
        switch colorCode {
        case Color.groupPlan: color  = ColorCodes.getColor(r: 161, g: 214, b: 248, a: 1)
        case Color.weddingPlan: color  = ColorCodes.getColor(r: 189, g: 184, b: 235, a: 1)
        case Color.babyPlan: color  = ColorCodes.getColor(r: 122, g: 223, b: 172, a: 1)
        case Color.holidayPlan: color  = ColorCodes.getColor(r: 109, g: 214, b: 200, a: 1)
        case Color.ridePlan: color  = ColorCodes.getColor(r: 242, g: 104, b: 107, a: 1)
        case Color.homePlan: color  = ColorCodes.getColor(r: 244, g: 161, b: 111, a: 1)
        case Color.gadgetPlan: color  = ColorCodes.getColor(r: 205, g: 220, b: 57, a: 1)
        case Color.genericPlan: color  = ColorCodes.getColor(r: 244, g: 176, b: 58, a: 1)
            
        default:  color = UIColor.blackColor()
        }
        return color
    }

    //This function will return the specific shadow color code for selected theme
    class func colorForShadow( colorCode: Int) -> UIColor {
        
        var color : UIColor! = UIColor.whiteColor()
        switch colorCode {
            
        case ShadowColor.groupPlan: color  = ColorCodes.getColor(r: 122, g: 182, b: 240, a: 1)
        case ShadowColor.weddingPlan: color  = ColorCodes.getColor(r: 138, g: 132, b: 186, a: 1)
        case ShadowColor.babyPlan: color  = ColorCodes.getColor(r: 135, g: 199, b: 165, a: 1)
        case ShadowColor.holidayPlan: color  = ColorCodes.getColor(r: 86, g: 153, b: 146, a: 1)
        case ShadowColor.ridePlan: color  = ColorCodes.getColor(r: 202, g: 60, b: 65, a: 1)
        case ShadowColor.homePlan: color  = ColorCodes.getColor(r: 231, g: 149, b: 64, a: 1)
        case ShadowColor.gadgetPlan: color  = ColorCodes.getColor(r: 166, g: 180, b: 60, a: 1)
        case ShadowColor.genericPlan: color  = ColorCodes.getColor(r: 244, g: 148, b: 54, a: 1)
            
        default:  color = UIColor.blackColor()
        }
        return color
    }

    //This function is used to set the RGB contents.
    class func getColor(r r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        return UIColor(red: r/256.0, green: g/256.0, blue: b/256.0, alpha: a);
    }

}
