//
//  CreatePINViewController.swift
//  Savio
//
//  Created by Maheshwari on 20/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class CreatePINViewController: UIViewController,UITextFieldDelegate,PostCodeVerificationDelegate,ResetPasscodeDelegate{
    
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet weak var enterFiveDigitCodeLabel: UILabel!
    @IBOutlet weak var reEnterFourDigitPIN: UITextField!
    @IBOutlet weak var enterFourDigitPIN: UITextField!
    @IBOutlet weak var confirmPIN: UIButton!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    var objAPI = API()
    var objAnimView = ImageViewAnimation()
    var userInfoDict  = Dictionary<String,AnyObject>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //Add borderWidth and borderColor to UITextFields
        enterFourDigitPIN.layer.borderWidth = 1
        enterFourDigitPIN.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        enterFourDigitPIN.attributedPlaceholder = NSAttributedString(string:"4 digit passcode",
                                                                     attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1),NSFontAttributeName :UIFont(name: "GothamRounded-Light", size: 15)!])
        //Set input accessory view to the UITextfield
        enterFourDigitPIN.inputAccessoryView = toolBar
        
        reEnterFourDigitPIN.layer.borderWidth = 1
        reEnterFourDigitPIN.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        reEnterFourDigitPIN.attributedPlaceholder = NSAttributedString(string:"Re-enter 4 digit passcode",
                                                                       attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1),NSFontAttributeName :UIFont(name: "GothamRounded-Light", size: 15)!])
        //Set input accessory view to the UITextfield
        reEnterFourDigitPIN.inputAccessoryView = toolBar
        
        //Add shadowcolor to confirmPIN
        confirmPIN.layer.shadowColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        confirmPIN.layer.shadowOffset = CGSizeMake(0, 4)
        confirmPIN.layer.shadowOpacity = 1
        confirmPIN.layer.cornerRadius = 5
        
        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Set the scrollview content size.
        backgroundScrollView.contentSize = CGSizeMake(0, 500)
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
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
    
    //UITextFieldDelegateMethods
    func textFieldDidBeginEditing(textField: UITextField){
        
        //Change the border color of UITextfields
        enterFourDigitPIN.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        reEnterFourDigitPIN.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        enterFourDigitPIN.textColor = UIColor.blackColor()
        reEnterFourDigitPIN.textColor = UIColor.blackColor()
        
        enterFiveDigitCodeLabel.hidden = true;
        //Change the content offset of scrollview so UITextfield will not be hidden by keyboard
        
        if(UIScreen.mainScreen().bounds.size.height == 480 || UIScreen.mainScreen().bounds.size.height == 568)
        {
            if(textField == enterFourDigitPIN)
            {
                backgroundScrollView.contentOffset = CGPointMake(0, 90)
            }
            else if(textField == reEnterFourDigitPIN)
            {
                backgroundScrollView.contentOffset = CGPointMake(0, 105)
            }
        }
    }
    
    @IBAction func toolBarDoneButtonPressed(sender: AnyObject) {
        enterFourDigitPIN.resignFirstResponder()
        reEnterFourDigitPIN.resignFirstResponder()
        backgroundScrollView.contentOffset = CGPointMake(0, 0)
    }
    @IBAction func onclickBackButton(sender: AnyObject) {
        isFromForgotPasscode = true
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickConfirmButton(sender: UIButton) {
        enterFourDigitPIN.resignFirstResponder()
        reEnterFourDigitPIN.resignFirstResponder()
        //Confirm button click
        
        if(sender.currentTitle == "Got It")
        {
            let objEnterYourPinViewController = SAEnterYourPINViewController(nibName: "SAEnterYourPINViewController",bundle: nil)
            self.navigationController?.pushViewController(objEnterYourPinViewController, animated: true)
        }
        else{
            
            if(enterFourDigitPIN.text == "" || reEnterFourDigitPIN.text == "")
            {
                //Show error when field is empty
                enterFiveDigitCodeLabel.hidden = false;
                enterFourDigitPIN.layer.borderColor = UIColor.redColor().CGColor
                reEnterFourDigitPIN.layer.borderColor = UIColor.redColor().CGColor
                
            }
            else if(enterFourDigitPIN.text  != reEnterFourDigitPIN.text)
            {
                //Show error when fields are not same
                
                enterFiveDigitCodeLabel.hidden = false;
                enterFiveDigitCodeLabel.text = "Passcode do not match"
                
                
                enterFourDigitPIN.textColor = UIColor.redColor()
                reEnterFourDigitPIN.textColor = UIColor.redColor()
            }
            else
            {
                if(enterFourDigitPIN.text?.characters.count < 4 || reEnterFourDigitPIN.text?.characters.count < 4)
                {
                    enterFiveDigitCodeLabel.hidden = false;
                    enterFiveDigitCodeLabel.text = "Passcode should be of 4 digits"
                }
                else
                {
                    
                    //Add animation of logo
                    objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
                    objAnimView.frame = self.view.frame
                    enterFourDigitPIN.resignFirstResponder()
                    
                    objAnimView.animate()
                    self.view.addSubview(objAnimView)
                    
                    userInfoDict["pass_code"] = enterFourDigitPIN.text?.MD5()
                    
                    var newUserInfoDict = Dictionary<String,AnyObject>()
                    newUserInfoDict["party"] = userInfoDict
                    print(newUserInfoDict)
                    //objAPI.storeValueInKeychainForKey("myUserInfo", value: userInfoDict)
                    var updatePasscodeDict = Dictionary<String,AnyObject>()
                    updatePasscodeDict["mobile_Number"] = userInfoDict["phone_number"]
                    updatePasscodeDict["pin"] = enterFourDigitPIN.text?.MD5()
                    
                   
                    if(checkString == "ForgotPasscode")
                    {
                         print(updatePasscodeDict)
                        objAPI.resetPasscodeDelegate = self
                        objAPI.resetPasscodeOfUserID(updatePasscodeDict)
                    }
                    else{
                         print(userInfoDict)
                        objAPI.delegate = self
                        objAPI.registerTheUserWithTitle(userInfoDict,apiName: "Customers")
                    }
                }
                
            }
            
        }
    }
    
    //
    func success(addressArray:Array<String>){
    }
    
    func error(error:String){
        
    }
    
    
    func successResponseForResetPasscodeAPI(objResponse:Dictionary<String,AnyObject>)
    {
        objAnimView.removeFromSuperview()
        print(objResponse)
        NSUserDefaults.standardUserDefaults().setObject(enterFourDigitPIN.text, forKey: "pin")
        NSUserDefaults.standardUserDefaults().synchronize()
        if(objResponse["message"] as! String == "Your PIN is updated Sucessfully")
        {
            objAPI.storeValueInKeychainForKey("myPasscode", value: reEnterFourDigitPIN.text!.MD5())
 
            headerLabel.text = "Your passcode has been reset"
            enterFourDigitPIN.hidden = true
            reEnterFourDigitPIN.hidden = true
            backButton.hidden = true
            confirmPIN .setTitle("Got It", forState: UIControlState.Normal)
                backgroundScrollView.contentOffset = CGPointMake(0, 0)
            
        }
        
    }
    func errorResponseForOTPResetPasscodeAPI(error:String){
        objAnimView.removeFromSuperview()
        print("error")
    }
    
    func successResponseForRegistrationAPI(objResponse:Dictionary<String,AnyObject>){
        print(objResponse)
        objAnimView.removeFromSuperview()
        //Store the passcode in Keychain
        objAPI.storeValueInKeychainForKey("myPasscode", value: reEnterFourDigitPIN.text!.MD5())
        objAPI.storeValueInKeychainForKey("userInfo", value: objResponse["party"]!)
        if(changePhoneNumber == true)
        {
            let objEnterYourPhoneNumberViewController = SAEnterPhoneNumberViewController(nibName:"SAEnterPhoneNumberViewController",bundle: nil)
            self.navigationController?.pushViewController(objEnterYourPhoneNumberViewController, animated: true)
        }
        else
        {
            //Navigate user to HurrayViewController to start Saving plan
            let objHurrrayView = HurreyViewController(nibName:"HurreyViewController",bundle: nil)
            self.navigationController?.pushViewController(objHurrrayView, animated: true)
        }
        
        
        
    }
    func errorResponseForRegistrationAPI(error:String){
        objAnimView.removeFromSuperview()
    }
    
    
}
