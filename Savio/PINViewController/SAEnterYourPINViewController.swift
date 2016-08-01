//
//  SAEnterYourPINViewController.swift
//  Savio
//
//  Created by Maheshwari  on 21/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAEnterYourPINViewController: UIViewController,UITextFieldDelegate,OTPSentDelegate,LogInDelegate {
    @IBOutlet weak var btnVwBg: UIView!
    @IBOutlet weak var pinTextFieldsContainerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet weak var passcodeDoesNotMatchLabel: UILabel!
    @IBOutlet weak var btnForgottPasscode: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblSentYouCode: UILabel!
    @IBOutlet weak var lblForgottonYourPasscode: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var forgotPasscodeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var textFieldOne: UITextField!
    @IBOutlet weak var textFieldTwo: UITextField!
    @IBOutlet weak var textFieldThree: UITextField!
    @IBOutlet weak var textFieldFour: UITextField!
    
    
    @IBOutlet weak var registerButtonBackgroundView: UIView!
    var objAnimView = ImageViewAnimation()
    
    let objAPI = API()
    
    var userInfoDict = Dictionary<String,AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customizeTextFields()
        
        // Do any additional setup after loading the view.
        //change the border color and placeholder color of UITextField
        
        //Add shadowcolor to UIButtons
        
        registerButton.layer.cornerRadius = 5
        btnVwBg.layer.cornerRadius = 5
        
        
        //        loginButton.layer.shadowColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        //        loginButton.layer.shadowOffset = CGSizeMake(0, 4)
        //        loginButton.layer.shadowOpacity = 1
        loginButton.layer.cornerRadius = 5
        
        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        
        
    }
    //UITextField delegate method
    
    func textFieldDidBeginEditing(textField: UITextField) {
        errorLabel.hidden = true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        errorLabel.hidden = true
        textField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if (newLength > 4) {
            return false;
        }
        return true;
    }
    
    
    @IBAction func clickOnRegisterButton(sender: AnyObject) {
        
        if(registerButton.titleLabel?.text == "Register")
        {
            let saRegisterViewController = SARegistrationViewController(nibName:"SARegistrationViewController",bundle: nil)
            self.navigationController?.pushViewController(saRegisterViewController, animated: true)
        }
        else
        {
            //Send the OTP to mobile number
            
            //Get the user details from Keychain
            //
            //            let objCreatePINView = CreatePINViewController(nibName: "CreatePINViewController",bundle: nil)
            //            self.navigationController?.pushViewController(objCreatePINView, animated: true)
            //
            
            objAPI.otpSentDelegate = self;
            objAPI.getOTPForNumber(userInfoDict["phone_number"]! as! String, country_code: "91")
            
            //Add animation of logo
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            
            objAnimView.animate()
            self.view.addSubview(objAnimView)
        }
        
    }
    
    @IBAction func clickedOnForgotPasscode(sender: AnyObject) {
        
        lblSentYouCode.hidden = false
        lblForgottonYourPasscode.hidden = false
        btnCancel.hidden = false
        registerButton .setTitle("Send me a code", forState: UIControlState.Normal)
        registerButtonBackgroundView.hidden = false
        registerButton.hidden = false
        forgotPasscodeButton.hidden = true
        loginButton.hidden = true
        btnVwBg.hidden = true
        checkString = "ForgotPasscode"
        errorLabel.hidden = true
        pinTextFieldsContainerView.hidden = true
        
        textFieldOne.resignFirstResponder()
        textFieldTwo.resignFirstResponder()
        textFieldThree.resignFirstResponder()
        textFieldFour.resignFirstResponder()
        textFieldOne.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        textFieldTwo.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        textFieldThree.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        textFieldFour.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
    }
    
    
    @IBAction func onClickCancelButton(sender: AnyObject) {
        
        lblSentYouCode.hidden = true
        lblForgottonYourPasscode.hidden = true
        btnCancel.hidden = true
        registerButton.hidden = true
        
        registerButton .setTitle("Register", forState: UIControlState.Normal)
        registerButtonBackgroundView.hidden = true
        forgotPasscodeButton.hidden = false
        loginButton.hidden = false
        btnVwBg.hidden = false
        pinTextFieldsContainerView.hidden = false
        
    }
    
    @IBAction func clickOnLoginButton(sender: AnyObject) {
        //LogInButton click
        if(textFieldOne.text == "" || textFieldTwo.text == ""  || textFieldThree.text == ""  || textFieldFour.text == ""  )
        {
            //Show error when field is empty
            
            errorLabel.hidden = false
            errorLabel.text = "Please enter passcode"
            
            if  textFieldOne.text == "" {
                textFieldOne.layer.borderColor = UIColor.redColor().CGColor
            }
            if  textFieldTwo.text == "" {
                textFieldTwo.layer.borderColor = UIColor.redColor().CGColor
            }
            if  textFieldThree.text == "" {
                textFieldThree.layer.borderColor = UIColor.redColor().CGColor
            }
            if  textFieldFour.text == "" {
                textFieldFour.layer.borderColor = UIColor.redColor().CGColor
            }
            
        }
            
            //        else if(enterPasscodeTextField.text?.characters.count < 4)
            //        {
            //            enterPasscodeTextField.layer.borderColor = UIColor.redColor().CGColor
            //            errorLabel.hidden = false
            //            errorLabel.text = "Passcode should be of 4 digits"
            //        }
        else
        {
            
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            
            
            objAPI.logInDelegate = self;
            objAnimView.animate()
            self.view.addSubview(objAnimView)
            
            var userDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
            print(userDict)
            var param = Dictionary<String,AnyObject>()
            param["userID"] = userDict["partyId"]
            let pinPassword = textFieldOne.text! + textFieldTwo.text! + textFieldThree.text! + textFieldFour.text!
            param["pin"] = pinPassword.MD5()
            
            param["ptystatus"] = "ENABLE"
            
            if let apnsDeviceToken = NSUserDefaults.standardUserDefaults().valueForKey("APNSTOKEN") as? NSString
            {
                param["PNS_DEVICE_ID"] =  apnsDeviceToken
                
            } else {
                param["PNS_DEVICE_ID"] =  ""
            }
            
            print(param)
            objAPI.logInWithUserID(param)
            
            /*
             if (NSUserDefaults.standardUserDefaults().valueForKey("pin") == nil){
             var userDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
             print(userDict)
             var param = Dictionary<String,AnyObject>()
             param["userID"] = userDict["partyId"]
             param["pin"] = enterPasscodeTextField.text?.MD5()
             print(param)
             objAPI.logInWithUserID(param)
             
             }
             
             if NSUserDefaults.standardUserDefaults().valueForKey("pin") as! String == enterPasscodeTextField.text
             {
             objAnimView.removeFromSuperview()
             
             let objHurrrayView = HurreyViewController(nibName:"HurreyViewController",bundle: nil)
             self.navigationController?.pushViewController(objHurrrayView, animated: true)
             }
             else{
             objAnimView.removeFromSuperview()
             errorLabel.hidden = false
             errorLabel.text = "Passcode do not match"
             }
             
             */
            
        }
    }
    
    func setAllPinEntryFieldsToColor(color: UIColor) {
        textFieldOne.layer.borderColor = color.CGColor
        textFieldTwo.layer.borderColor = color.CGColor
        textFieldThree.layer.borderColor = color.CGColor
        textFieldFour.layer.borderColor = color.CGColor
    }
    
    //LogIn Delegate Methods
    
    func successResponseForLogInAPI(objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        print(objResponse)
        let dict = objResponse["party"]
        let udidDict = dict!["deviceRegistration"] as! Array<Dictionary<String,AnyObject>>
        print(udidDict)
        let udidArray = udidDict[0]
        print(udidArray)
        userInfoDict["cookie"] = udidArray["COOKIE"] as! String
        objAPI.storeValueInKeychainForKey("userInfo", value: userInfoDict)
        print(userInfoDict)
        
        let groupPlan = objResponse["G"] as! NSNumber
        let individualPlan = objResponse["I"] as! NSNumber
        let groupMemberPlan = objResponse["GM"] as! NSNumber
        
        print(groupPlan)
        print(individualPlan)
        print(groupMemberPlan)
        
        NSUserDefaults.standardUserDefaults().setObject(groupPlan, forKey: "groupPlan")
        NSUserDefaults.standardUserDefaults().setObject(individualPlan, forKey: "individualPlan")
        NSUserDefaults.standardUserDefaults().setObject(groupMemberPlan, forKey: "groupMemberPlan")
        NSUserDefaults.standardUserDefaults().synchronize()
        //let objContainer = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
        self.setUpMenu(groupPlan, individual: individualPlan, member: groupMemberPlan)
        let objHurrrayView = HurreyViewController(nibName:"HurreyViewController",bundle: nil)
        self.navigationController?.pushViewController(objHurrrayView, animated: true)
    }
    
    func setUpMenu(group:NSNumber,individual:NSNumber,member:NSNumber)  {
        var className :String = ""
        
        if individual == 1 {
            className = "individualPlan"
        }
        else if group == 1 {
            className = "groupPlan"
        }
        else if member == 1 {
            className = "groupMemberPlan"
        }
        else{
            className = ""
        }
        NSUserDefaults.standardUserDefaults().setObject(className, forKey: "ShowProgress")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func errorResponseForOTPLogInAPI(error: String) {
        objAnimView.removeFromSuperview()
        print(error)
        if(error == "No network found")
        {
            let alert = UIAlertView(title: "Warning", message: "No network found", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else
        {
            errorLabel.hidden = false
            errorLabel.text = "Passcode is not correct"
            textFieldOne.text = ""
            textFieldTwo.text = ""
            textFieldThree.text = ""
            textFieldFour.text = ""
            self.setAllPinEntryFieldsToColor( UIColor.redColor())
        }
        
    }
    
    //OTP Verification Delegate Method
    func successResponseForOTPSentAPI(objResponse:Dictionary<String,AnyObject>)
    {
        objAnimView.removeFromSuperview()
        let fiveDigitVerificationViewController = FiveDigitVerificationViewController(nibName:"FiveDigitVerificationViewController",bundle: nil)
        self.navigationController?.pushViewController(fiveDigitVerificationViewController, animated: true)
    }
    func errorResponseForOTPSentAPI(error:String){
        objAnimView.removeFromSuperview()
        let fiveDigitVerificationViewController = FiveDigitVerificationViewController(nibName:"FiveDigitVerificationViewController",bundle: nil)
        self.navigationController?.pushViewController(fiveDigitVerificationViewController, animated: true)
        
    }
    
    
    
    func customizeTextFields() {
        self.setAllPinEntryFieldsToColor( UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1))
        
        let borderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 3
        
        textFieldOne.layer.borderWidth = borderWidth
        textFieldOne.layer.cornerRadius = cornerRadius
        //        textFieldOne.userInteractionEnabled = false
        
        
        textFieldTwo.layer.borderWidth = borderWidth
        textFieldTwo.layer.cornerRadius = cornerRadius
        textFieldTwo.layer.masksToBounds = true
        //        textFieldTwo.userInteractionEnabled = false
        
        textFieldThree.layer.borderWidth = borderWidth
        textFieldThree.layer.cornerRadius = cornerRadius
        textFieldThree.layer.masksToBounds = true
        //        textFieldThree.userInteractionEnabled = false
        
        
        textFieldFour.layer.borderWidth = borderWidth
        textFieldFour.layer.cornerRadius = cornerRadius
        textFieldFour.layer.masksToBounds = true
        //        textFieldFour.userInteractionEnabled = false
        
        textFieldFour.keyboardType = UIKeyboardType.NumberPad
        
        textFieldOne.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        textFieldTwo.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        textFieldThree.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        textFieldFour.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField){
        
        let text = textField.text
        
        //        var restrictedLength: Int = 1
        //        var temp: String = textField.text!
        //        if textField.text.length() > restrictedLength {
        //            textField.text = temp.substringToIndex(temp.startIndex.advancedBy(temp.length() - 1))
        //        }
        
        if text?.utf16.count==1{
            switch textField{
            case textFieldOne:
                textFieldTwo.becomeFirstResponder()
            case textFieldTwo:
                textFieldThree.becomeFirstResponder()
            case textFieldThree:
                textFieldFour.becomeFirstResponder()
            case textFieldFour:
                textFieldFour.resignFirstResponder()
            default:
                textFieldOne.becomeFirstResponder()
            }
        }else{
            switch textField{
            case textFieldFour:
                textFieldThree.becomeFirstResponder()
            case textFieldThree:
                textFieldTwo.becomeFirstResponder()
            case textFieldTwo:
                textFieldOne.becomeFirstResponder()
            case textFieldOne:
                textFieldOne.resignFirstResponder()
            default:
                textFieldOne.becomeFirstResponder()
            }
        }
    }
}
