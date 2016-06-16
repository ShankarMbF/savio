//
//  CommonClass.swift
//
//
//  Created by Maheshwari on 17/05/16.
//  Copyright © 2016 Maheshwari. All rights reserved.
//

import UIKit
import SystemConfiguration
import Foundation


let baseURL = "http://54.191.188.214:8080/SavioAPI/V1"
//let APIKey = "Ppia3IHl0frDIgr711SlZWUBlpWdNfDs"
let APIKey = "bcdfb7ce5e6854dcfe65ce5dd0d568c7"
let custom_message = "Your Savio phone verification code is {{code}}"
var checkString = ""
var changePhoneNumber : Bool = false
var phoneNumber = ""
var isFromForgotPasscode : Bool = false

protocol PostCodeVerificationDelegate {
    
    func success(addressArray:Array<String>)
    func error(error:String)
    
    func successResponseForRegistrationAPI(objResponse:Dictionary<String,AnyObject>)
    func errorResponseForRegistrationAPI(error:String)
}
protocol OTPSentDelegate{
    
    func successResponseForOTPSentAPI(objResponse:Dictionary<String,AnyObject>)
    func errorResponseForOTPSentAPI(error:String)
}

protocol OTPVerificationDelegate{
    
    func successResponseForOTPVerificationAPI(objResponse:Dictionary<String,AnyObject>)
    func errorResponseForOTPVerificationAPI(error:String)
}

protocol LogInDelegate{
    
    func successResponseForLogInAPI(objResponse:Dictionary<String,AnyObject>)
    func errorResponseForOTPLogInAPI(error:String)
}

protocol ResetPasscodeDelegate{
    
    func successResponseForResetPasscodeAPI(objResponse:Dictionary<String,AnyObject>)
    func errorResponseForOTPResetPasscodeAPI(error:String)
}
protocol ShareExtensionDelegate{
    
    func successResponseForResetPasscodeAPI(objResponse:Dictionary<String,AnyObject>)
    func errorResponseForOTPResetPasscodeAPI(error:String)
}

protocol GetWishlistDelegate{
    
    func successResponseForGetWishlistAPI(objResponse:Dictionary<String,AnyObject>)
    func errorResponseForGetWishlistAPI(error:String)
}

protocol GetOfferlistDelegate{
    
    func successResponseForGetOfferlistAPI(objResponse:Dictionary<String,AnyObject>)
    func errorResponseForGetOfferlistAPI(error:String)
}

protocol PartySavingPlanDelegate{
    
    func successResponseForPartySavingPlanAPI(objResponse:Dictionary<String,AnyObject>)
    func errorResponseForPartySavingPlanAPI(error:String)
}
class API: UIView {
    let session = NSURLSession.sharedSession()
    var delegate: PostCodeVerificationDelegate?
    var otpSentDelegate : OTPSentDelegate?
    var otpVerificationDelegate : OTPVerificationDelegate?
    var logInDelegate : LogInDelegate?
    var resetPasscodeDelegate : ResetPasscodeDelegate?
    var shareExtensionDelegate : ShareExtensionDelegate?
    var getWishlistDelegate : GetWishlistDelegate?
    var getofferlistDelegate : GetOfferlistDelegate?
    var partySavingPlanDelegate : PartySavingPlanDelegate?
    
    //Checking Reachability function
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func verifyPostCode(postcode:String){
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            
            let urlString = String(format:"https://api.getaddress.io/v2/uk/%@?api-key=McuJM5nIIEqqGRVCRUBztQ4159",postcode)
            
            let url = NSURL(string: urlString)
            let request = NSURLRequest(URL: url!)
            
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        if let addressArray = dict["Addresses"] as? Array<String>
                        {
                            //if dictionary contains address array return it for the further development
                            dispatch_async(dispatch_get_main_queue()){
                                self.delegate?.success(addressArray)
                            }
                        }
                        else
                        {
                            //else return an error
                            dispatch_async(dispatch_get_main_queue()){
                                //print(dict)
                                self.delegate?.error("That postcode doesn't look right")
                            }
                        }
                    }
                }
                
            }
            dataTask.resume()
        }
        else{
            //Give error no network found
            delegate?.error("Network not available")
        }
    }
    
    
    func registerTheUserWithTitle(dictParam:Dictionary<String,AnyObject>,apiName:String)
    {
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/%@",baseURL,apiName))!)
            request.HTTPMethod = "POST"
            
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(dictParam, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    // print(json)
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        //print("\(dict)")
                        dispatch_async(dispatch_get_main_queue()){
                            self.delegate?.successResponseForRegistrationAPI(dict)
                        }
                    }
                    else
                    {
                        print(response?.description)
                        dispatch_async(dispatch_get_main_queue()){
                            self.delegate?.errorResponseForRegistrationAPI("Error")
                        }
                    }
                }
                
            }
            dataTask.resume()
        }
        else{
            //Give error no network found
            delegate?.error("No network found")
        }
        
    }
    
    
    
    func getOTPForNumber(phoneNumber:String,country_code:String) {
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            let request = NSMutableURLRequest(URL: NSURL(string:"http://sandbox-api.authy.com/protected/json/phones/verification/start")!)
            
            request.HTTPMethod = "POST"
            
            let params = ["api_key":APIKey,"via":"sms","phone_number":phoneNumber,"country_code":country_code] as Dictionary<String, String>
            
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            //print(request)
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        // print(dict)
                        if(dict["success"] as! Bool == true)
                        {
                            dispatch_async(dispatch_get_main_queue()){
                                //send successResponse
                                self.otpSentDelegate?.successResponseForOTPSentAPI(dict)
                            }
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue()){
                                //send successResponse
                                self.otpSentDelegate?.errorResponseForOTPSentAPI(dict["message"] as! String)
                            }
                            
                        }
                        
                    }
                    else
                    {
                        //send error
                        dispatch_async(dispatch_get_main_queue()){
                            self.otpSentDelegate?.errorResponseForOTPSentAPI((error?.localizedDescription)!)
                        }
                    }
                }
                else
                {
                    //send error
                    dispatch_async(dispatch_get_main_queue()){
                        self.otpSentDelegate?.errorResponseForOTPSentAPI((error?.localizedDescription)!)
                    }
                }
                
            }
            dataTask.resume()
            
        }
        else{
            //Give error no network found
            self.otpSentDelegate?.errorResponseForOTPSentAPI("No network found")
        }
    }
    
    func verifyOTP(phoneNumber:String,country_code:String,OTP:String)
    {
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            //Start a session
            let dataTask = session.dataTaskWithURL(NSURL(string: String(format: "http://sandbox-api.authy.com/protected/json/phones/verification/check?api_key=%@&via=sms&phone_number=%@&country_code=%@&verification_code=%@",APIKey,phoneNumber,country_code,OTP))!) { data, response, error in
                if let data = data
                {
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        //print(dict)
                        if(dict["message"] as! String  == "Verification code is correct.")
                        {
                            dispatch_async(dispatch_get_main_queue()){
                                self.otpVerificationDelegate?.successResponseForOTPVerificationAPI(dict)
                            }
                        }
                        else if(dict["message"] as! String == "Verification code is incorrect."){
                            dispatch_async(dispatch_get_main_queue()){
                                self.otpVerificationDelegate?.errorResponseForOTPVerificationAPI("Verification code is incorrect.")
                            }
                        }
                        else
                        {
                            //send error
                            dispatch_async(dispatch_get_main_queue()){
                                self.otpVerificationDelegate?.errorResponseForOTPVerificationAPI("Verification code is incorrect.")
                            }
                        }
                        
                    }
                    else
                    {
                        //send error
                        dispatch_async(dispatch_get_main_queue()){
                            self.otpVerificationDelegate?.errorResponseForOTPVerificationAPI((error?.localizedDescription)!)
                        }
                    }
                }
                else
                {
                    //send error
                    dispatch_async(dispatch_get_main_queue()){
                        self.otpVerificationDelegate?.errorResponseForOTPVerificationAPI((error?.localizedDescription)!)
                    }
                }
                
            }
            dataTask.resume()
        }
        else{
            //Give error no network found
            self.otpSentDelegate?.errorResponseForOTPSentAPI("No network found")
        }
    }
    
    
    //LogIn function
    func logInWithUserID(dictParam:Dictionary<String,AnyObject>)
    {
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/Customers/Login",baseURL))!)
            request.HTTPMethod = "POST"
            
            
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(dictParam, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    //print(json)
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        print("\(dict)")
                        if(dict["errorCode"] as! NSString == "200")
                        {
                            dispatch_async(dispatch_get_main_queue()){
                                self.logInDelegate?.successResponseForLogInAPI(dict)
                                
                            }
                        }
                        else{
                            dispatch_async(dispatch_get_main_queue()){
                                self.logInDelegate?.errorResponseForOTPLogInAPI("Password is incorrect")
                            }
                        }
                    }
                    else
                    {
                        print(response?.description)
                        dispatch_async(dispatch_get_main_queue()){
                            self.logInDelegate?.errorResponseForOTPLogInAPI((response?.description)!)
                        }
                        
                    }
                }
                
            }
            dataTask.resume()
        }
        else{
            //Give error no network found
            logInDelegate?.errorResponseForOTPLogInAPI("No network found")
        }
    }
    
    
    //ResetPasscode function
    func resetPasscodeOfUserID(dictParam:Dictionary<String,AnyObject>)
    {
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/Customers/ForgotPIN",baseURL))!)
            request.HTTPMethod = "POST"
            
            
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(dictParam, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    print(json)
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        print("\(dict)")
                        dispatch_async(dispatch_get_main_queue()){
                            self.resetPasscodeDelegate?.successResponseForResetPasscodeAPI(dict)
                        }
                    }
                    else
                    {
                        print(response?.description)
                        dispatch_async(dispatch_get_main_queue()){
                            self.resetPasscodeDelegate?.errorResponseForOTPResetPasscodeAPI((response?.description)!)
                        }
                    }
                }
            }
            dataTask.resume()
        }
        else{
            //Give error no network found
            self.resetPasscodeDelegate?.errorResponseForOTPResetPasscodeAPI("No network found")
        }
        
    }
    
    
    //KeychainItemWrapper methods
    func storeValueInKeychainForKey(key:String,value:AnyObject){
        //Save the value of password into keychain
        KeychainItemWrapper.save(key, data: value)
        
        let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.com.mbf.savio")!
        let data = NSKeyedArchiver.archivedDataWithRootObject(value)
        defaults.setObject(data, forKey: key)
    }
    
    func getValueFromKeychainOfKey(key:String)-> AnyObject{
        //get the value of password from keychain
        return KeychainItemWrapper.load(key)
        //        if (KeychainItemWrapper.load(key) as! String).isEmpty{
        //            return ""
        //        }
        //        else{
        //
        //
        //        }
        
    }
    
    func deleteKeychainValue(key:String) {
        KeychainItemWrapper.delete(key)
    }
    
    
    func sendWishList(dict:Dictionary<String,AnyObject>)
    {
        let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.com.mbf.savio")!
        let data = defaults.valueForKey("userInfo") as! NSData
        let userInfoDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Dictionary<String,AnyObject>
        let cookie = userInfoDict["cookie"] as! String
        let partyID = userInfoDict["partyId"] as! NSNumber
        
        let utf8str = String(format: "%@:%@",partyID,cookie).dataUsingEncoding(NSUTF8StringEncoding)
        let base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        print(dict)
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            
            let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/WishList/WL",baseURL))!)
            request.HTTPMethod = "POST"
            
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(dict, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(String(format: "Basic %@",base64Encoded!), forHTTPHeaderField: "Authorization")
            
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    print(json)
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        if let val = dict["errorCode"] {
                            if(dict["errorCode"] as! String == "204")
                            {
                                dispatch_async(dispatch_get_main_queue()){
                                    self.shareExtensionDelegate?.errorResponseForOTPResetPasscodeAPI("Please login to Savio first.")
                                }
                            }
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue()){
                                self.shareExtensionDelegate?.successResponseForResetPasscodeAPI(dict)
                            }
                        }
                    }
                    else
                    {
                        print(response?.description)
                        dispatch_async(dispatch_get_main_queue()){
                            self.shareExtensionDelegate?.errorResponseForOTPResetPasscodeAPI((response?.description)!)
                        }
                    }
                }
            }
            dataTask.resume()
        }
        else{
            self.shareExtensionDelegate?.errorResponseForOTPResetPasscodeAPI("No network found")
        }
        
    }
    
    
    func createPartySavingPlan(dict:Dictionary<String,AnyObject>,isFromWishList:String)
    {
        let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.com.mbf.savio")!
        let data = defaults.valueForKey("userInfo") as! NSData
        let userInfoDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Dictionary<String,AnyObject>
        let cookie = userInfoDict["cookie"] as! String
        let partyID = userInfoDict["partyId"] as! NSNumber
        
        let utf8str = String(format: "%@:%@",partyID,cookie).dataUsingEncoding(NSUTF8StringEncoding)
        let base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        // print(dict)
        
        
        if(isFromWishList == "FromWishList")
        {
            if(self.isConnectedToNetwork())
            {
                let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/WishList",baseURL))!)
                request.HTTPMethod = "PUT"
                
                
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(dict, options: [])
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue(String(format: "Basic %@",base64Encoded!), forHTTPHeaderField: "Authorization")
                
                let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    if let data = data
                    {
                        let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                        // print(json)
                        if let dict = json as? Dictionary<String,AnyObject>
                        {
                            dispatch_async(dispatch_get_main_queue()){
                                self.partySavingPlanDelegate?.successResponseForPartySavingPlanAPI(dict)
                            }
                        }
                        else
                        {
                            print(response?.description)
                            dispatch_async(dispatch_get_main_queue()){
                                self.partySavingPlanDelegate?.errorResponseForPartySavingPlanAPI((response?.description)!)
                            }
                        }
                    }
                }
                dataTask.resume()
            }
            else{
                self.shareExtensionDelegate?.errorResponseForOTPResetPasscodeAPI("No network found")
            }
            
        }
        else
        {
            if(self.isConnectedToNetwork())
            {
                let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/WishList/",baseURL))!)
                request.HTTPMethod = "POST"
                
                
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(dict, options: [])
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue(String(format: "Basic %@",base64Encoded!), forHTTPHeaderField: "Authorization")
                
                let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    if let data = data
                    {
                        let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                        print(json)
                        if let dict = json as? Dictionary<String,AnyObject>
                        {
                            dispatch_async(dispatch_get_main_queue()){
                                self.partySavingPlanDelegate?.successResponseForPartySavingPlanAPI(dict)
                            }
                        }
                        else
                        {
                            print(response?.description)
                            dispatch_async(dispatch_get_main_queue()){
                                self.partySavingPlanDelegate?.errorResponseForPartySavingPlanAPI((response?.description)!)
                            }
                        }
                    }
                }
                dataTask.resume()
            }
            else{
                self.shareExtensionDelegate?.errorResponseForOTPResetPasscodeAPI("No network found")
            }
            
            
        }
        //Check if network is present
    }
    
    func getWishListForUser(userId : String)
    {
        let userInfoDict = self.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        
        let cookie = userInfoDict["cookie"] as! String
        let partyID = userInfoDict["partyId"] as! NSNumber
        
        let utf8str = String(format: "%@:%@",partyID,cookie).dataUsingEncoding(NSUTF8StringEncoding)
        let base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        if(self.isConnectedToNetwork())
        {
            
            let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/WishList?party_ID=%@",baseURL,partyID))!)
            request.addValue(String(format: "Basic %@",base64Encoded!), forHTTPHeaderField: "Authorization")
            print(request)
            
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    print(json)
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        dispatch_async(dispatch_get_main_queue())
                        {
                            self.getWishlistDelegate?.successResponseForGetWishlistAPI(dict)
                        }
                    }
                    else
                    {
                        print(response?.description)
                        dispatch_async(dispatch_get_main_queue()){
                            self.getWishlistDelegate?.errorResponseForGetWishlistAPI((response?.description)!)
                        }
                        
                        
                    }
                }
                
            }
            dataTask.resume()
        }
        else{
            self.getWishlistDelegate?.errorResponseForGetWishlistAPI("No network found")
        }
        
    }
    
    func getOfferListForSavingId(input : String)
    {
        let userInfoDict = self.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        
        let cookie = userInfoDict["cookie"] as! String
        let partyID = userInfoDict["partyId"] as! NSNumber
        
        let utf8str = String(format: "%@:%@",partyID,cookie).dataUsingEncoding(NSUTF8StringEncoding)
        let base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        if(self.isConnectedToNetwork())
        {
            
            let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/Offers/SavingID?input=%@",baseURL,input))!)
            request.addValue(String(format: "Basic %@",base64Encoded!), forHTTPHeaderField: "Authorization")
            print(request)
            
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    print(json)
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        print(dict)
                        dispatch_async(dispatch_get_main_queue())
                        {
                            self.getofferlistDelegate?.successResponseForGetOfferlistAPI(dict)
                        }
                    }
                    else
                    {
                        print(response?.description)
                        dispatch_async(dispatch_get_main_queue()){
                            self.getofferlistDelegate?.errorResponseForGetOfferlistAPI("Error")
                        }
                    }
                }
                
            }
            dataTask.resume()
        }
        else{
            self.getWishlistDelegate?.errorResponseForGetWishlistAPI("No network found")
        }
        
    }
    
}
