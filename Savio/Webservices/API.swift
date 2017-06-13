
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

//===========UAT===========
//let baseURL = "http://54.229.66.32:80/SavioAPI/V1"

//============DEV===============
let baseURL = "http://52.209.205.151:8080/SavioAPI/V1"

var APIKey          = ""
var checkString     = ""
var phoneNumber     = ""
var isFromForgotPasscode    : Bool = false
var changePhoneNumber       : Bool = false

let custom_message  = "Your Savio phone verification code is {{code}}"

var kConnectionProblemTitle : String!   = "Connection problem"
var kNonetworkfound         : String!   = "No network found"
var kPhoneNumber            : String!   = "phone_number"
var kUserInfo               : String!   = "userInfo"
let kAUTHYAPIKEYSANDBOX     : String    = "AUTHY_API_KEY_SANDBOX"       //Use for sandbox
let kAUTHYAPIKEYLIVE        : String    = "AUTHY_API_KEY_LIVE"          //Use for Live
let kSTRIPEPUBLISHABLEKEY   : String    = "STRIPE_PUBLISHABLE_KEY"      //Use Strip publish key


protocol PostCodeVerificationDelegate
{
    
    func success(_ addressArray:Array<String>)
    func error(_ error:String)
    
    func successResponseForRegistrationAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForRegistrationAPI(_ error:String)
}

protocol TermAndConditionDelegate
{
    
    func successResponseFortermAndConditionAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseFortermAndConditionAPI(_ error:String)
}

protocol OTPSentDelegate
{
    
    func successResponseForOTPSentAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForOTPSentAPI(_ error:String)
}

protocol OTPVerificationDelegate
{
    
    func successResponseForOTPVerificationAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForOTPVerificationAPI(_ error:String)
}

protocol LogInDelegate
{
    
    func successResponseForLogInAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForOTPLogInAPI(_ error:String)
}

protocol ResetPasscodeDelegate
{
    
    func successResponseForResetPasscodeAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForOTPResetPasscodeAPI(_ error:String)
}
protocol ShareExtensionDelegate
{
    
    func successResponseForShareExtensionAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForShareExtensionAPI(_ error:String)
}

protocol GetWishlistDelegate
{
    
    func successResponseForGetWishlistAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForGetWishlistAPI(_ error:String)
}

protocol GetOfferlistDelegate
{
    
    func successResponseForGetOfferlistAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForGetOfferlistAPI(_ error:String)
}

protocol PartySavingPlanDelegate
{
    
    func successResponseForPartySavingPlanAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForPartySavingPlanAPI(_ error:String)
}

protocol CategoriesSavingPlan
{
    
    func successResponseForCategoriesSavingPlanAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForCategoriesSavingPlanAPI(_ error:String)
}

protocol DeleteWishListDelegate
{
    
    func successResponseForDeleteWishListAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForDeleteWishListAPI(_ error:String)
}

protocol GetUsersPlanDelegate
{
    
    func successResponseForGetUsersPlanAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForGetUsersPlanAPI(_ error:String)
}

protocol UpdateSavingPlanDelegate
{
    func successResponseForUpdateSavingPlanAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForUpdateSavingPlanAPI(_ error:String)
}

protocol GetUserInfoDelegate
{
    
    func successResponseForGetUserInfoAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForGetUserInfoAPI(_ error:String)
}

protocol UpdateUserInfoDelegate
{
    
    func successResponseForUpdateUserInfoAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForUpdateUserInfoAPI(_ error:String)
}

protocol CancelSavingPlanDelegate
{
    
    func successResponseForCancelSavingPlanAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForCancelSavingPlanAPI(_ error:String)
}

protocol InviteMembersDelegate
{
    
    func successResponseForInviteMembersAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForInviteMembersAPI(_ error:String)
}

protocol GetListOfUsersPlanDelegate
{
    
    func successResponseForGetListOfUsersPlanAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForGetListOfUsersPlanAPI(_ error:String)
}

protocol AddSavingCardDelegate
{
    
    func successResponseForAddSavingCardDelegateAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForAddSavingCardDelegateAPI(_ error:String)
}

protocol AddNewSavingCardDelegate
{
    
    func successResponseForAddNewSavingCardDelegateAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForAddNewSavingCardDelegateAPI(_ error:String)
}

protocol GetListOfUsersCardsDelegate
{
    
    func successResponseForGetListOfUsersCards(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForGetListOfUsersCards(_ error:String)
}

protocol SetDefaultCardDelegate
{
    
    func successResponseForSetDefaultCard(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForSetDefaultCard(_ error:String)
}

protocol ImpulseSavingDelegate
{
    
    func successResponseImpulseSavingDelegateAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForImpulseSavingDelegateAPI(_ error:String)
}

protocol RemoveCardDelegate
{
    
    func successResponseForRemoveCardAPI(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseForRemoveCardAPI(_ error:String)
}

protocol GetAffiliatedTrackID
{
    
    func successResponseAffiliated(_ objResponse:Dictionary<String,AnyObject>)
    func errorResponseAffiliated(_ error:String)
}


class API: UIView,URLSessionDelegate {
    
    // Maintain
    let urlconfig = URLSessionConfiguration.default
    
    var delegate                    : PostCodeVerificationDelegate?
    var otpSentDelegate             : OTPSentDelegate?
    var otpVerificationDelegate     : OTPVerificationDelegate?
    var logInDelegate               : LogInDelegate?
    var resetPasscodeDelegate       : ResetPasscodeDelegate?
    var shareExtensionDelegate      : ShareExtensionDelegate?
    var getWishlistDelegate         : GetWishlistDelegate?
    var getofferlistDelegate        : GetOfferlistDelegate?
    var partySavingPlanDelegate     : PartySavingPlanDelegate?
    var categorySavingPlanDelegate  : CategoriesSavingPlan?
    var deleteWishList              : DeleteWishListDelegate?
    var getSavingPlanDelegate       : GetUsersPlanDelegate?
    var updateSavingPlanDelegate    : UpdateSavingPlanDelegate?
    var getUserInfoDelegate         : GetUserInfoDelegate?
    var cancelSavingPlanDelegate    : CancelSavingPlanDelegate?
    var inviteMemberDelegate        : InviteMembersDelegate?
    var updateUserInfoDelegate      : UpdateUserInfoDelegate?
    var getListOfUsersPlanDelegate  : GetListOfUsersPlanDelegate?
    var addSavingCardDelegate       : AddSavingCardDelegate?
    var addNewSavingCardDelegate    : AddNewSavingCardDelegate?
    var getListOfUsersCardDelegate  : GetListOfUsersCardsDelegate?
    var setDefaultCardDelegate      : SetDefaultCardDelegate?
    var impulseSavingDelegate       : ImpulseSavingDelegate?
    var removeCardDelegate          : RemoveCardDelegate?
    var getAffiliateIdDelegate      : GetAffiliatedTrackID?
    
    
    //Checking Reachability function
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
            
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
        
    }
    
    //MARK: Verification of postcode
    func verifyPostCode(_ postcode:String){
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            //Get Address API URL
            let urlString = String(format:"https://api.getaddress.io/v2/uk/%@?api-key=McuJM5nIIEqqGRVCRUBztQ4159",postcode)
            
            let url     = URL(string: urlString)
            let request = URLRequest(url: url!)
            
            //Set time out after requesting 30 second
            self.setTimeOutRequest(30)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                print("post Code Response: \(String(describing: response))")
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        if let addressArray = dict["Addresses"] as? Array<String>
                        {
                            //if dictionary contains address array return it for the further development
                            DispatchQueue.main.async{
                                self.delegate?.success(addressArray)
                            }
                        }
                        else
                        {
                            //else return an error
                            DispatchQueue.main.async{
                                self.delegate?.error("That postcode doesn't look right")
                            }
                        }
                    }
                }
                if let error = error
                {
                    DispatchQueue.main.async{
                        self.delegate?.error(error.localizedDescription)
                    }
                }
            })
            task.resume()
            
        }
        else {
            //Give error no network found
            delegate?.error("Network not available")
        }
    }
    
    //MARK: Registration
    
    func registerTheUserWithTitle(_ dictParam:Dictionary<String,AnyObject>,apiName:String)
    {
        //Check if network is present
        print(dictParam)
        if(self.isConnectedToNetwork())
        {
            //            let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/%@",baseURL,apiName))!)
            //            request.HTTPMethod = "POST"
            //            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(dictParam, options: [])
            //            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            //            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            self.setTimeOutRequest(60)
            
            let request = self.createRequest(URL(string: String(format:"%@/%@",baseURL,apiName))!, method: "POST", paramDict: dictParam,userInforDict: [:], isAuth: false)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                //If data is not nil
                if data != nil
                {
                    //Json serialization
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        //return success response to viewcontroller
                        DispatchQueue.main.async{
                            self.delegate?.successResponseForRegistrationAPI(dict)
                            print(dict)
                        }
                    }
                    else
                    {
                        //return error response to viewcontroller
                        DispatchQueue.main.async{
                            self.delegate?.errorResponseForRegistrationAPI((response?.description)!)
                            print(response?.description)
                        }
                    }
                }
                else if let error = error {
                    print(response?.description)
                    //return error to viewcontroller
                    DispatchQueue.main.async{
                        self.delegate?.errorResponseForRegistrationAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            //Give error no network found
            DispatchQueue.main.async{
                self.delegate?.errorResponseForRegistrationAPI(kNonetworkfound)
            }
        }
    }
    
    //MARK: OTP generate and verification
    func getOTPForNumber(_ phoneNumber:String,country_code:String) {
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            APIKey = valueForAPIKey(named: kAUTHYAPIKEYSANDBOX)
            //            let request = NSMutableURLRequest(URL: NSURL(string:"http://sandbox-api.authy.com/protected/json/phones/verification/start")!)
            //
            //            request.HTTPMethod = "POST"
            //            //collect requierd parameter in dictionary
            let params = ["api_key":APIKey,"via":"sms",kPhoneNumber:phoneNumber,"country_code":country_code,"locale":"en"] as Dictionary<String, String>
            
            self.setTimeOutRequest(30)
            let request = createRequest(URL(string:"http://sandbox-api.authy.com/protected/json/phones/verification/start")!, method: "POST", paramDict: params as Dictionary<String, AnyObject>,userInforDict: [:], isAuth: false)
            
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        if(dict["success"] as! Bool == true)
                        {
                            DispatchQueue.main.async{
                                //send successResponse
                                self.otpSentDelegate?.successResponseForOTPSentAPI(dict)
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async{
                                //send errorResponse
                                self.otpSentDelegate?.errorResponseForOTPSentAPI(dict["message"] as! String)
                            }
                        }
                    }
                    else
                    {
                        if let error = error
                        {
                            //send error occuring at request
                            DispatchQueue.main.async{
                                self.otpSentDelegate?.errorResponseForOTPSentAPI(error.localizedDescription)
                            }
                        }
                        else
                        {
                            //send error
                            DispatchQueue.main.async{
                                self.otpSentDelegate?.errorResponseForOTPSentAPI((error?.localizedDescription)!)
                            }
                        }
                    }
                }
                else
                {
                    //send error
                    DispatchQueue.main.async{
                        self.otpSentDelegate?.errorResponseForOTPSentAPI((error?.localizedDescription)!)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            //Give error no network found
            DispatchQueue.main.async{
                self.otpSentDelegate?.errorResponseForOTPSentAPI(kNonetworkfound)
            }
        }
    }
    
    //Function performing action to
    func verifyOTP(_ phoneNumber:String,country_code:String,OTP:String)
    {
        APIKey = valueForAPIKey(named: kAUTHYAPIKEYSANDBOX)
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(10)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let dataTask = session.dataTask(with: URL(string: String(format: "http://sandbox-api.authy.com/protected/json/phones/verification/check?api_key=%@&via=sms&phone_number=%@&country_code=%@&verification_code=%@",APIKey,phoneNumber,country_code,OTP))!, completionHandler: { data, response, error in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        if(dict["message"] as! String  == "Verification code is correct.")
                        {
                            DispatchQueue.main.async{
                                self.otpVerificationDelegate?.successResponseForOTPVerificationAPI(dict)
                            }
                        }
                        else if(dict["message"] as! String == "Verification code is incorrect."){
                            DispatchQueue.main.async{
                                self.otpVerificationDelegate?.errorResponseForOTPVerificationAPI("Verification code is incorrect.")
                            }
                        }
                        else {
                            //send error
                            DispatchQueue.main.async{
                                self.otpVerificationDelegate?.errorResponseForOTPVerificationAPI("Verification code is incorrect.")
                            }
                        }
                    }
                    else {
                        if let error = error
                        {
                            DispatchQueue.main.async{
                                self.otpVerificationDelegate?.errorResponseForOTPVerificationAPI(error.localizedDescription)
                            }
                        }
                        else {
                            DispatchQueue.main.async{
                                self.otpVerificationDelegate?.errorResponseForOTPVerificationAPI((error?.localizedDescription)!)
                            }
                        }
                    }
                }
                else
                {
                    //send error
                    DispatchQueue.main.async{
                        self.otpVerificationDelegate?.errorResponseForOTPVerificationAPI((error?.localizedDescription)!)
                    }
                }
                
            })
            dataTask.resume()
        }
        else {
            //Give error no network found
            self.otpVerificationDelegate?.errorResponseForOTPVerificationAPI(kNonetworkfound)
        }
    }
    
    //MARK: Login
    
    //LogIn function
    func logInWithUserID(_ dictParam:Dictionary<String,AnyObject>)
    {
        print(" logInWithUserID == \(dictParam)")
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            let request = createRequest(URL(string: String(format:"%@/Customers/Login",baseURL))!, method: "POST", paramDict: dictParam,userInforDict: [:], isAuth: false)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        print(dict)
                        if let code = dict["errorCode"] as? NSString
                        {
                            if(code == "200")
                            {
                                DispatchQueue.main.async{
                                    self.logInDelegate?.successResponseForLogInAPI(dict)
                                }
                            }
                            else if(code == "204")
                            {
                                DispatchQueue.main.async{
                                    self.logInDelegate?.errorResponseForOTPLogInAPI("Passcode is incorrect")
                                }
                            }
                            else
                            {
                                DispatchQueue.main.async{
                                    self.logInDelegate?.errorResponseForOTPLogInAPI(dict["internalMessage"] as! String)
                                }
                            }
                        }
                        else {
                            if let code = dict["error"] as? NSString
                            {
                                DispatchQueue.main.async{
                                    self.logInDelegate?.errorResponseForOTPLogInAPI(code as String)
                                }
                                
                                //                                if(code == "Internal Server Error")
                                //                                {
                                //                                    dispatch_async(dispatch_get_main_queue()){
                                //                                        self.logInDelegate?.errorResponseForOTPLogInAPI(code as String)
                                //                                    }
                                //                                }
                                //
                                //                                else
                                //                                {
                                //                                    dispatch_async(dispatch_get_main_queue()){
                                //                                        self.logInDelegate?.errorResponseForOTPLogInAPI("Passcode is incorrect")
                                //                                    }
                                //                                }
                            }
                        }
                    }
                    else {
                        print(response?.description)
                        DispatchQueue.main.async{
                            self.logInDelegate?.errorResponseForOTPLogInAPI((response?.description)!)
                        }
                    }
                }
                else if let error = error
                {
                    print(error.localizedDescription)
                    
                    DispatchQueue.main.async{
                        self.logInDelegate?.errorResponseForOTPLogInAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            //Give error no network found
            logInDelegate?.errorResponseForOTPLogInAPI(kNonetworkfound)
        }
    }
    
    
    //MARK: Reset passcode
    
    //ResetPasscode function
    func resetPasscodeOfUserID(_ dictParam:Dictionary<String,AnyObject>)
    {
        print(dictParam)
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            let request = createRequest(URL(string: String(format:"%@/Customers/ForgotPIN",baseURL))!, method: "POST", paramDict: dictParam,userInforDict: [:], isAuth: false)
            
            //            let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/Customers/ForgotPIN",baseURL))!)
            //            request.HTTPMethod = "POST"
            //
            //            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(dictParam, options: [])
            //            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            //            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        print(dict)
                        DispatchQueue.main.async{
                            self.resetPasscodeDelegate?.successResponseForResetPasscodeAPI(dict)
                        }
                    }
                    else  {
                        DispatchQueue.main.async{
                            self.resetPasscodeDelegate?.errorResponseForOTPResetPasscodeAPI((response?.description)!)
                        }
                    }
                }
                else if let error = error
                {
                    DispatchQueue.main.async{
                        self.resetPasscodeDelegate?.errorResponseForOTPResetPasscodeAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            //Give error no network found
            self.resetPasscodeDelegate?.errorResponseForOTPResetPasscodeAPI(kNonetworkfound)
        }
        
    }
    
    
    //KeychainItemWrapper methods
    func storeValueInKeychainForKey(_ key:String,value:AnyObject){
        //Save the value of password into keychain
        //        KeychainItemWrapper.save(key, data: value)
        
        //        let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.savio.web.share.extention")!
        
        
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        
        let defaults: UserDefaults = UserDefaults(suiteName: "group.savio.web.share.extention")!
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        defaults.set(data, forKey: key)
    }
    
    func getValueFromKeychainOfKey(_ key:String)-> AnyObject{
        //get the value of password from keychain
        return KeychainItemWrapper.load(key) as AnyObject
    }
    
    func deleteKeychainValue(_ key:String) {
        //Delete value from Keychain
        KeychainItemWrapper.delete(key)
    }
    
    
    //MARK: Create wishlist
    
    func sendWishList(_ dict:Dictionary<String,AnyObject>)
    {
        print(dict)
        let defaults: UserDefaults = UserDefaults(suiteName: "group.savio.web.share.extention")!
        let data = defaults.value(forKey: kUserInfo) as! Data
        let userInfoDict = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String,AnyObject>
        //        let cookie = userInfoDict["cookie"] as! String
        //        let partyID = userInfoDict["partyId"] as! NSNumber
        //
        //        let utf8str = String(format: "%@:%@",partyID,cookie).dataUsingEncoding(NSUTF8StringEncoding)
        //        let base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(180)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            //            let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/WishList",baseURL))!)
            //            request.HTTPMethod = "POST"
            //
            //            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(dict, options: [])
            //            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            //            request.addValue("application/json", forHTTPHeaderField: "Accept")
            //            request.addValue(String(format: "Basic %@",base64Encoded!), forHTTPHeaderField: "Authorization")
            let request = createRequest(URL(string: String(format:"%@/WishList",baseURL))!, method: "POST", paramDict: dict, userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    print(json!)
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        if(dict["errorCode"] as! String == "200")
                        {
                            DispatchQueue.main.async{
                                self.shareExtensionDelegate?.successResponseForShareExtensionAPI(dict)
                                print(dict)
                            }
                        }
                        else {
                            DispatchQueue.main.async{
                                self.shareExtensionDelegate?.errorResponseForShareExtensionAPI("Internal server error")
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.shareExtensionDelegate?.errorResponseForShareExtensionAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error
                {
                    DispatchQueue.main.async{
                        self.shareExtensionDelegate?.errorResponseForShareExtensionAPI(error.localizedDescription)
                    }
                }
                
            })
            dataTask.resume()
        }
        else {
            DispatchQueue.main.async{
                self.shareExtensionDelegate?.errorResponseForShareExtensionAPI(kNonetworkfound)
            }
        }
        
    }
    
    
    //MARK: Delete item from wishlist
    
    func deleteWishList(_ dict:Dictionary<String,AnyObject>)
    {
        let defaults: UserDefaults = UserDefaults(suiteName: "group.savio.web.share.extention")!
        let data = defaults.value(forKey: kUserInfo) as! Data
        let userInfoDict = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String,AnyObject>
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest(URL(string: String(format:"%@/WishList/%@",baseURL,dict["id"] as! NSNumber))!, method: "DELETE", paramDict: dict, userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async{
                            self.deleteWishList?.successResponseForDeleteWishListAPI(dict)
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.deleteWishList?.errorResponseForDeleteWishListAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error  {
                    DispatchQueue.main.async{
                        self.deleteWishList?.errorResponseForDeleteWishListAPI(error.localizedDescription)
                    }
                    
                }
                
            })
            
            dataTask.resume()
        }
        else {
            self.deleteWishList?.errorResponseForDeleteWishListAPI(kNonetworkfound)
        }
        
    }
    
    
    //MARK: Create saving plan
    
    func createPartySavingPlan(_ dict:Dictionary<String,AnyObject>,isFromWishList:String)
    {
        print(dict)
        let defaults: UserDefaults = UserDefaults(suiteName: "group.savio.web.share.extention")!
        let data = defaults.value(forKey: kUserInfo) as! Data
        let userInfoDict = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String,AnyObject>
        
        if(self.isConnectedToNetwork())
        {
            self.setTimeOutRequest(180)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            let request = createRequest(URL(string: String(format:"%@/SavingPlans",baseURL))!, method: "POST", paramDict: dict, userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        print(dict)
                        DispatchQueue.main.async{
                            
                            self.partySavingPlanDelegate?.successResponseForPartySavingPlanAPI(dict)
                            
                            if let CheckPlanType = dict["partySavingPlanType"]{
                                if CheckPlanType as! String == "Individual"{
                                    let CurrentDateForplan = self.getCurrentDate()
                                    UserDefaults.standard.set(CurrentDateForplan, forKey: "IndCurrentDateForPlan")
                                    UserDefaults.standard.synchronize()
                                }else if CheckPlanType as! String == "Group"
                                {
                                    let CurrentDateForplan = self.getCurrentDate()
                                    UserDefaults.standard.set(CurrentDateForplan, forKey: "GrpCurrentDateForPlan")
                                    UserDefaults.standard.synchronize()
                                }
                            }
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async{
                            self.partySavingPlanDelegate?.errorResponseForPartySavingPlanAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error  {
                    DispatchQueue.main.async{
                        self.partySavingPlanDelegate?.errorResponseForPartySavingPlanAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            self.partySavingPlanDelegate?.errorResponseForPartySavingPlanAPI(kNonetworkfound)
        }
        
    }
    
    
    //MARK: Get users wishlist
    
    func getWishListForUser(_ userId : String)
    {
        
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>

        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest(URL(string: String(format:"%@/WishList/partyid?input=%@",baseURL,userInfoDict["partyId"] as! NSNumber))!, method: "GET", paramDict: [:], userInforDict: userInfoDict, isAuth: true)
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async
                            {
                                self.getWishlistDelegate?.successResponseForGetWishlistAPI(dict)
                        }
                    }
                    else  {
                        DispatchQueue.main.async{
                            self.getWishlistDelegate?.errorResponseForGetWishlistAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error {
                    
                    DispatchQueue.main.async{
                        self.getWishlistDelegate?.errorResponseForGetWishlistAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            self.getWishlistDelegate?.errorResponseForGetWishlistAPI(kNonetworkfound)
        }
    }//17981.75
    
    
    //MARK: Get savings plan
    
    func getCategoriesForSavingPlan()
    {
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest(URL(string: String(format:"%@/referencedata/savingplan",baseURL))!, method: "GET", paramDict: [:], userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async
                            {
                                self.categorySavingPlanDelegate?.successResponseForCategoriesSavingPlanAPI(dict)
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.categorySavingPlanDelegate?.errorResponseForCategoriesSavingPlanAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error  {
                    DispatchQueue.main.async{
                        self.categorySavingPlanDelegate?.errorResponseForCategoriesSavingPlanAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            self.categorySavingPlanDelegate?.errorResponseForCategoriesSavingPlanAPI(kNonetworkfound)
        }
        
    }

//    MARK:- Offer list - getOfferListForSavingId
    
    func getOfferListForSavingId()
    {
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>

        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest(URL(string: String(format:"%@/referencedata/offers",baseURL))!, method: "GET", paramDict: [:], userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async
                            {
                                self.getofferlistDelegate?.successResponseForGetOfferlistAPI(dict)
                                print()
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.getofferlistDelegate?.errorResponseForGetOfferlistAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error  {
                    DispatchQueue.main.async{
                        self.getofferlistDelegate?.errorResponseForGetOfferlistAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            self.getofferlistDelegate?.errorResponseForGetOfferlistAPI(kNonetworkfound)
        }
        
    }
    
//    MARK:- Get users saving plan
    
    func getUsersSavingPlan(_ str:String)
    {
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest(URL(string: String(format:"%@/SavingPlans?input=%@&type=%@",baseURL,userInfoDict["partyId"] as! NSNumber,str))!, method: "GET", paramDict: [:], userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async
                            {
                                self.getSavingPlanDelegate?.successResponseForGetUsersPlanAPI(dict)
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.getSavingPlanDelegate?.errorResponseForGetUsersPlanAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error
                {
                    
                    DispatchQueue.main.async{
                        self.getSavingPlanDelegate?.errorResponseForGetUsersPlanAPI(error.localizedDescription)
                    }
                }
            })
            
            dataTask.resume()
        }
        else {
            self.getSavingPlanDelegate?.errorResponseForGetUsersPlanAPI(kNonetworkfound)
        }
        
    }
    
    //MARK: Update saving plan
    func updateSavingPlan(_ dict:Dictionary<String,AnyObject>)
    {
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(180)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest(URL(string: String(format:"%@/SavingPlans",baseURL))!, method: "PUT", paramDict: dict, userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async{
                            self.updateSavingPlanDelegate?.successResponseForUpdateSavingPlanAPI(dict)
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.updateSavingPlanDelegate?.errorResponseForUpdateSavingPlanAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error
                {
                    
                    DispatchQueue.main.async{
                        self.updateSavingPlanDelegate?.errorResponseForUpdateSavingPlanAPI(error.localizedDescription)
                    }
                }
                
            })
            dataTask.resume()
        }
        else {
            self.updateSavingPlanDelegate?.errorResponseForUpdateSavingPlanAPI("Network not available")
        }
        
    }
    
    //MARK:- Get User Info
    
    func getUserInfo()
    {
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        //        let userInfoDict = self.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        
        let cookie = userInfoDict["cookie"] as! String
        let partyID = userInfoDict["partyId"] as! NSNumber
        
        let utf8str = String(format: "%@:%@",partyID,cookie).data(using: String.Encoding.utf8)
        let base64Encoded = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            
            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = NSMutableURLRequest(url: URL(string: String(format:"%@/Customers/id/%@",baseURL,partyID))!)
            request.addValue(String(format: "Basic %@",base64Encoded!), forHTTPHeaderField: "Authorization")
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async
                            {
                                self.getUserInfoDelegate?.successResponseForGetUserInfoAPI(dict)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async{
                            self.getUserInfoDelegate?.errorResponseForGetUserInfoAPI("Error")
                        }
                    }
                }
                else  if let error = error
                {
                    
                    DispatchQueue.main.async{
                        self.getUserInfoDelegate?.errorResponseForGetUserInfoAPI(error.localizedDescription)
                    }
                    
                    
                }
                
                
            })
            dataTask.resume()
            
            
        }
        else {
            self.getUserInfoDelegate?.errorResponseForGetUserInfoAPI(kNonetworkfound)
        }
    }
    
    
    
//    MARK:- Update user Info
    
    func updateUserInfo(_ dict:Dictionary<String,AnyObject>)
    {
        print(dict)
        
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest(URL(string: String(format:"%@/Customers",baseURL))!, method: "PUT", paramDict: dict, userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async{
                            self.updateUserInfoDelegate?.successResponseForUpdateUserInfoAPI(dict)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async{
                            self.updateUserInfoDelegate?.errorResponseForUpdateUserInfoAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error
                {
                    
                    DispatchQueue.main.async{
                        self.updateUserInfoDelegate?.errorResponseForUpdateUserInfoAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            self.updateUserInfoDelegate?.errorResponseForUpdateUserInfoAPI("Network not available")
        }
        
    }
    
//    MARK:- Cancel saving plan
    func cancelSavingPlan()
    {
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest(URL(string: String(format:"%@/savings/%@",baseURL,userInfoDict["partyId"] as! NSNumber))!, method: "PUT", paramDict: [:], userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async
                            {
                                self.cancelSavingPlanDelegate?.successResponseForCancelSavingPlanAPI(dict)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async{
                            self.cancelSavingPlanDelegate?.errorResponseForCancelSavingPlanAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error
                {
                    
                    DispatchQueue.main.async{
                        self.cancelSavingPlanDelegate?.errorResponseForCancelSavingPlanAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            DispatchQueue.main.async{
                self.cancelSavingPlanDelegate?.errorResponseForCancelSavingPlanAPI("Network not available")
            }
        }
        
    }
    
    
//    MARK:-    Send Invite members
    
    func sendInviteMembersList(_ dict:Dictionary<String,AnyObject>)
    {
        let defaults: UserDefaults = UserDefaults(suiteName: "group.savio.web.share.extention")!
        let data = defaults.value(forKey: kUserInfo) as! Data
        let userInfoDict = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String,AnyObject>

        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(180)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            
            let request = createRequest(URL(string: String(format:"%@/InvitedUsers",baseURL))!, method: "POST", paramDict: dict, userInforDict: userInfoDict, isAuth: true)
            
            print("*******************************")
            print(dict)
            print(request)
            print("*******************************")
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        print(dict)
                        if let errorcode = dict["errorCode"] as? String
                        {
                            if(errorcode == "200")
                            {
                                DispatchQueue.main.async{
                                    self.inviteMemberDelegate?.successResponseForInviteMembersAPI(dict)
                                }
                            }
                        }
                        else if let errorcode = dict["error"] as? String
                        {
                            DispatchQueue.main.async{
                                self.inviteMemberDelegate?.errorResponseForInviteMembersAPI(errorcode)
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.inviteMemberDelegate?.errorResponseForInviteMembersAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error {
                    
                    DispatchQueue.main.async{
                        self.inviteMemberDelegate?.errorResponseForInviteMembersAPI(error.localizedDescription)
                    }
                }
                
            })
            dataTask.resume()
        }
        else {
            DispatchQueue.main.async{
                self.inviteMemberDelegate?.errorResponseForInviteMembersAPI(kNonetworkfound)
            }
        }
    }
    
//    MARK:-    Get list of users plan
    func getListOfUsersPlan()
    {
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>

        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            
            let request = createRequest(URL(string: String(format:"%@/SavingPlans/%@",baseURL,userInfoDict["partyId"] as! NSNumber))!, method: "GET", paramDict: [:], userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async
                            {
                                self.getListOfUsersPlanDelegate?.successResponseForGetListOfUsersPlanAPI(dict)
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.getListOfUsersPlanDelegate?.errorResponseForGetListOfUsersPlanAPI((response?.description)!)
                        }
                    }
                }
                else  if error != nil
                {
                    DispatchQueue.main.async{
                        self.getListOfUsersPlanDelegate?.errorResponseForGetListOfUsersPlanAPI((response?.description)!)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            self.getListOfUsersPlanDelegate?.errorResponseForGetListOfUsersPlanAPI(kNonetworkfound)
        }
        
    }
    
//    MARK:- Add saving card
    func addSavingCard(_ dictParam:Dictionary<String,AnyObject>)
    {
        print(dictParam)
        let defaults: UserDefaults = UserDefaults(suiteName: "group.savio.web.share.extention")!
        let data = defaults.value(forKey: kUserInfo) as! Data
        let userInfoDict = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String,AnyObject>
        
        if(self.isConnectedToNetwork())
        {
            
            self.setTimeOutRequest(60)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest( URL(string: String(format:"%@/cards",baseURL))!, method: "POST", paramDict: dictParam, userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        if let code = dict["errorCode"] as? NSString
                        {
                            if(code == "200")
                            {
                                DispatchQueue.main.async{
                                    self.addSavingCardDelegate?.successResponseForAddSavingCardDelegateAPI(dict)
                                    print(dict)
                                    print("$$$$$$$$$$$$$$$$$$$$$$")
                                }
                            }
                            else if(code == "204")
                            {
                                DispatchQueue.main.async{
                                    self.addSavingCardDelegate?.errorResponseForAddSavingCardDelegateAPI("Passcode is incorrect")
                                }
                            }
                            else
                            {
                                DispatchQueue.main.async{
                                    self.addSavingCardDelegate?.errorResponseForAddSavingCardDelegateAPI("Internal Server Error")
                                }
                            }
                        }
                        else {
                            if let code = dict["error"] as? NSString
                            {
                                if(code == "Internal Server Error")
                                {
                                    DispatchQueue.main.async{
                                        self.addSavingCardDelegate?.errorResponseForAddSavingCardDelegateAPI("Internal Server Error")
                                    }
                                }
                                    
                                else
                                {
                                    DispatchQueue.main.async{
                                        self.addSavingCardDelegate?.errorResponseForAddSavingCardDelegateAPI("Passcode is incorrect")
                                    }
                                }
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.addSavingCardDelegate?.errorResponseForAddSavingCardDelegateAPI((response?.description)!)
                        }
                    }
                }
                else if let error = error
                {
                    DispatchQueue.main.async{
                        self.addSavingCardDelegate?.errorResponseForAddSavingCardDelegateAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            //Give error no network found
            addSavingCardDelegate?.errorResponseForAddSavingCardDelegateAPI(kNonetworkfound)
        }
    }
    
    func addNewSavingCard(_ dictParam:Dictionary<String,AnyObject>)
    {
        print(dictParam)
        let defaults: UserDefaults = UserDefaults(suiteName: "group.savio.web.share.extention")!
        let data = defaults.value(forKey: kUserInfo) as! Data
        let userInfoDict = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String,AnyObject>
        
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(60)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest(URL(string: String(format:"%@/card",baseURL))!, method: "POST", paramDict: dictParam, userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        print(dict)
                        if let code = dict["errorCode"] as? NSString
                        {
                            if(code == "200")
                            {
                                DispatchQueue.main.async{
                                    self.addNewSavingCardDelegate?.successResponseForAddNewSavingCardDelegateAPI(dict)
                                }
                            }
                            else if(code == "204")
                            {
                                DispatchQueue.main.async{
                                    self.addNewSavingCardDelegate?.errorResponseForAddNewSavingCardDelegateAPI("Passcode is incorrect")
                                }
                            }
                            else
                            {
                                DispatchQueue.main.async{
                                    self.addNewSavingCardDelegate?.errorResponseForAddNewSavingCardDelegateAPI("Internal Server Error")
                                }
                            }
                        }
                        else {
                            if let code = dict["error"] as? NSString
                            {
                                if(code == "Internal Server Error")
                                {
                                    DispatchQueue.main.async{
                                        self.addNewSavingCardDelegate?.errorResponseForAddNewSavingCardDelegateAPI("Internal Server Error")
                                    }
                                }
                                    
                                else
                                {
                                    DispatchQueue.main.async{
                                        self.addNewSavingCardDelegate?.errorResponseForAddNewSavingCardDelegateAPI("Passcode is incorrect")
                                    }
                                }
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.addNewSavingCardDelegate?.errorResponseForAddNewSavingCardDelegateAPI((response?.description)!)
                        }
                    }
                }
                else if let error = error
                {
                    DispatchQueue.main.async{
                        self.addNewSavingCardDelegate?.errorResponseForAddNewSavingCardDelegateAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            //Give error no network found
            addNewSavingCardDelegate?.errorResponseForAddNewSavingCardDelegateAPI(kNonetworkfound)
        }
    }
    
//    MARK:-    Get users cards list
    
    func getWishListOfUsersCards()
    {
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(60)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            
            let request = createRequest(URL(string: String(format:"%@/card/%@",baseURL,userInfoDict["partyId"] as! NSNumber))!, method: "GET", paramDict: [:], userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async
                            {
                                self.getListOfUsersCardDelegate?.successResponseForGetListOfUsersCards(dict)
                        }
                    }
                    else  {
                        DispatchQueue.main.async{
                            self.getListOfUsersCardDelegate?.errorResponseForGetListOfUsersCards((response?.description)!)
                        }
                    }
                }
                else  if let error = error {
                    
                    DispatchQueue.main.async{
                        self.getListOfUsersCardDelegate?.errorResponseForGetListOfUsersCards(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            self.getListOfUsersCardDelegate?.errorResponseForGetListOfUsersCards(kNonetworkfound)
        }
    }
    
    //MARK : Set default card
    func setDefaultPaymentCard(_ dictParam:Dictionary<String,AnyObject>)
    {
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(60)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            
            let request = createRequest(URL(string: String(format:"%@/card",baseURL))!, method: "PUT", paramDict: dictParam, userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async
                            {
                                self.setDefaultCardDelegate?.successResponseForSetDefaultCard(dict)
                        }
                    }
                    else  {
                        DispatchQueue.main.async{
                            self.setDefaultCardDelegate?.errorResponseForSetDefaultCard((response?.description)!)
                        }
                    }
                }
                else  if let error = error {
                    
                    DispatchQueue.main.async{
                        self.setDefaultCardDelegate?.errorResponseForSetDefaultCard(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            self.setDefaultCardDelegate?.errorResponseForSetDefaultCard(kNonetworkfound)
        }
    }
    
//    MARK :-   ImpulseSaving
    func impulseSaving(_ dictParam:Dictionary<String,AnyObject>)
    {
        print(dictParam)
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            self.setTimeOutRequest(60)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest(URL(string: String(format:"%@/SavingPlanTransaction",baseURL))!, method: "POST", paramDict: dictParam, userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async
                            {
                                self.impulseSavingDelegate?.successResponseImpulseSavingDelegateAPI(dict)
                                print(dict)
                        }
                    }
                    else  {
                        DispatchQueue.main.async{
                            self.impulseSavingDelegate?.errorResponseForImpulseSavingDelegateAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error {
                    DispatchQueue.main.async{
                        self.impulseSavingDelegate?.errorResponseForImpulseSavingDelegateAPI(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
        else {
            self.impulseSavingDelegate?.errorResponseForImpulseSavingDelegateAPI(kNonetworkfound)
        }
    }
    
    
//    MARK:-    Delete item from wishlist
    func removeCarde(_ dict:Dictionary<String,AnyObject>)
    {
        let defaults: UserDefaults = UserDefaults(suiteName: "group.savio.web.share.extention")!
        let data = defaults.value(forKey: kUserInfo) as! Data
        let userInfoDict = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String,AnyObject>
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {

            self.setTimeOutRequest(30)
            
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = createRequest(URL(string: String(format:"%@/card",baseURL))!, method: "DELETE", paramDict: dict, userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async{
                            self.removeCardDelegate?.successResponseForRemoveCardAPI(dict)
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.removeCardDelegate?.errorResponseForRemoveCardAPI((response?.description)!)
                        }
                    }
                }
                else  if let error = error  {
                    DispatchQueue.main.async{
                        self.removeCardDelegate?.errorResponseForRemoveCardAPI(error.localizedDescription)
                    }
                }
            })
            
            dataTask.resume()
        }
        else {
            self.removeCardDelegate?.errorResponseForRemoveCardAPI(kNonetworkfound)
        }
    }
    
//  MARK:-    Get Affiliate ID

    func getAffiliateID(_ dict : Dictionary<String,AnyObject>) {
        print(dict)
        
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        print(userInfoDict)
        let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
        
        
        if(self.isConnectedToNetwork())
        {
            self.setTimeOutRequest(30)
            let request = createRequest(URL(string: String(format:"%@/Affiliates/url",baseURL))!, method: "POST", paramDict: dict, userInforDict: userInfoDict, isAuth: true)
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        DispatchQueue.main.async{
                            self.getAffiliateIdDelegate?.successResponseAffiliated(dict)
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            self.getAffiliateIdDelegate?.errorResponseAffiliated((response?.description)!)
                        }
                    }
                }
                else  if let error = error  {
                    DispatchQueue.main.async{
                        self.getAffiliateIdDelegate?.errorResponseAffiliated(error.localizedDescription)
                    }
                }
            })
            dataTask.resume()
        }
    }
    
//    MARK:-    Common Function
    
    func setTimeOutRequest(_ intrvl: TimeInterval) {
        urlconfig.timeoutIntervalForRequest = intrvl
        urlconfig.timeoutIntervalForResource = intrvl
    }
    
    func createRequest(_ requestURL:URL,method:String,paramDict:Dictionary<String,AnyObject>,userInforDict:Dictionary<String,AnyObject>,isAuth:Bool) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: requestURL)
        if method != "GET" {
            request.httpBody = try! JSONSerialization.data(withJSONObject: paramDict, options: [])
            request.httpMethod = method
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        if isAuth {
            let cookie = userInforDict["cookie"] as! String
            let partyID = userInforDict["partyId"] as! NSNumber
            print("Cookies === \(cookie) and party ID is \(partyID)")
            let utf8str = String(format: "%@:%@",partyID,cookie).data(using: String.Encoding.utf8)
            let base64Encoded = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            request.addValue(String(format: "Basic %@",base64Encoded!), forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    func valueForAPIKey(named keyname:String) -> String {
        //        let filePath = NSBundle.main().path(forResource: "ApiKeys", ofType: "plist")
        let filePath = Bundle.main.path(forResource: "KeyConfig", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let value = plist![keyname] as! String
        return value
    }
    
    func getCurrentDate() -> String{
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
        
        let year =  components.year
        let month = components.month
        let CurrentDateForplan = "\(String(describing: year))-\(String(describing: month))"
        
        return CurrentDateForplan
    }
}
