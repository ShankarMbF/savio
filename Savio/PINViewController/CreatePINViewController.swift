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
    @IBOutlet weak var enterFourDigitCodeLabel: UILabel!
    @IBOutlet weak var confirmPIN: UIButton!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subHeaderLabel: UILabel!
    
    @IBOutlet weak var textFieldOne: UITextField!
    @IBOutlet weak var textFieldTwo: UITextField!
    @IBOutlet weak var textFieldThree: UITextField!
    @IBOutlet weak var textFieldFour: UITextField!

    @IBOutlet weak var textFieldReOne: UITextField!
    @IBOutlet weak var textFieldReTwo: UITextField!
    @IBOutlet weak var textFieldReThree: UITextField!
    @IBOutlet weak var textFieldReFour: UITextField!

    @IBOutlet weak var lblConfirmPasscode: UILabel!
    @IBOutlet weak var confirmPasscodeView: UIView!
    @IBOutlet weak var passcodeView: UIView!
    @IBOutlet weak var backButton: UIButton!
    var objAPI = API()
    var objAnimView = ImageViewAnimation()
    var userInfoDict  = Dictionary<String,AnyObject>()
    var keyboardRect = CGRectZero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmPasscodeView.layer.cornerRadius = 3
        confirmPIN.layer.cornerRadius = 3
        self.customizeTextFields()
        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        self.registerForKeyboardNotifications()
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
        if (newLength == 2) {
            
            return false;
        }
        
        return true;
    }
    
    //UITextFieldDelegateMethods
    func textFieldDidBeginEditing(textField: UITextField){
        self.setAllPinEntryFieldsToColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1))
        enterFourDigitCodeLabel.hidden = true

    }
    
    @IBAction func toolBarDoneButtonPressed(sender: AnyObject) {
        backgroundScrollView.contentOffset = CGPointMake(0, 0)
    }
    @IBAction func onclickBackButton(sender: AnyObject) {
        isFromForgotPasscode = true
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickConfirmButton(sender: UIButton) {

        self.bgViewTapped("AnyObj")
        //Confirm button click
        
        if(sender.currentTitle == "Got It")
        {
            self.removeKeyboardNotification()
            let objEnterYourPinViewController = SAEnterYourPINViewController(nibName: "SAEnterYourPINViewController",bundle: nil)
            self.navigationController?.pushViewController(objEnterYourPinViewController, animated: true)
        }
        else{
            
            if(textFieldOne.text  ==  "" || textFieldReOne.text   ==  "" || textFieldTwo.text  ==  "" || textFieldReTwo.text   ==  "" || textFieldThree.text    ==  "" || textFieldReThree.text  ==  "" || textFieldFour.text   ==  "" || textFieldReFour.text   ==  "" )
            {
                //Show error when field is empty
                enterFourDigitCodeLabel.hidden = false;
                self.setAllPinEntryFieldsToColor(UIColor.redColor())
                
                
            }
            else if(textFieldOne.text  != textFieldReOne.text || textFieldTwo.text  != textFieldReTwo.text || textFieldThree.text  != textFieldReThree.text || textFieldFour.text  != textFieldReFour.text)
            {
                //Show error when fields are not same
                
                enterFourDigitCodeLabel.hidden = false;
                enterFourDigitCodeLabel.text = "Passcode do not match"
                self.setAllPinEntryFieldsToColor(UIColor.redColor())
                self.resetTextOnAllTextFields()
            }
            else
            {
                if(textFieldOne.text?.characters.count < 1 || textFieldReOne.text?.characters.count < 1 || textFieldTwo.text?.characters.count < 1 || textFieldReTwo.text?.characters.count < 1 || textFieldThree.text?.characters.count < 1 || textFieldReThree.text?.characters.count < 1 || textFieldFour.text?.characters.count < 1 || textFieldReFour.text?.characters.count < 1)
                {
                    enterFourDigitCodeLabel.hidden = false;
                    enterFourDigitCodeLabel.text = "Passcode should be of 4 digits"
                }
                else
                {
                    
                    //Add animation of logo
                    objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
                    objAnimView.frame = self.view.frame
                    
                    objAnimView.animate()
                    self.view.addSubview(objAnimView)
                    
                    let passcode = self.textFieldOne.text! + self.textFieldTwo.text! + self.textFieldThree.text! + self.textFieldFour.text!
                    userInfoDict["pass_code"] = passcode.MD5()

                    
                    
                    var newUserInfoDict = Dictionary<String,AnyObject>()
                    newUserInfoDict["party"] = userInfoDict
                    print(newUserInfoDict)
                    //objAPI.storeValueInKeychainForKey("myUserInfo", value: userInfoDict)
                    var updatePasscodeDict = Dictionary<String,AnyObject>()
                    updatePasscodeDict["mobile_Number"] = userInfoDict["phone_number"]
                    updatePasscodeDict["pin"] = passcode.MD5()
                    
                   
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

    func success(addressArray:Array<String>){
    }
    
    func error(error:String){
        
    }
    
    
    
    func successResponseForResetPasscodeAPI(objResponse:Dictionary<String,AnyObject>)
    {
        objAnimView.removeFromSuperview()
        let passcode = self.textFieldOne.text! + self.textFieldTwo.text! + self.textFieldThree.text! + self.textFieldFour.text!

        NSUserDefaults.standardUserDefaults().setObject(passcode, forKey: "pin")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        if let message = objResponse["message"] as? String
        {
            if(message == "Your PIN is updated Sucessfully")
            {
            objAPI.storeValueInKeychainForKey("myPasscode", value: passcode.MD5())
 
            headerLabel.text = "Your passcode has been reset"
            backButton.hidden = true
            confirmPIN .setTitle("Got It", forState: UIControlState.Normal)
            backgroundScrollView.contentOffset = CGPointMake(0, 0)
            self.lblConfirmPasscode.hidden = true
            self.confirmPasscodeView.hidden = true
            self.passcodeView.hidden = true
            }
        }
        else if let internalMessage = objResponse["internalMessage"] as? String
        {
            let alert = UIAlertView(title: "Warning", message: internalMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
    }
    func errorResponseForOTPResetPasscodeAPI(error:String){
        objAnimView.removeFromSuperview()

            let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
    
    }
    
    func successResponseForRegistrationAPI(objResponse:Dictionary<String,AnyObject>){
        objAnimView.removeFromSuperview()
        //Store the passcode in Keychain
        let passcode = self.textFieldOne.text! + self.textFieldTwo.text! + self.textFieldThree.text! + self.textFieldFour.text!

        if let message = objResponse["message"]
        {
            if(message as! String == "User sucessfully register")
            {
        objAPI.storeValueInKeychainForKey("myPasscode", value: passcode.MD5())
        objAPI.storeValueInKeychainForKey("userInfo", value: objResponse["party"]!)
        if(changePhoneNumber == true)
        {
            let objEnterYourPhoneNumberViewController = SAEnterPhoneNumberViewController(nibName:"SAEnterPhoneNumberViewController",bundle: nil)
            self.navigationController?.pushViewController(objEnterYourPhoneNumberViewController, animated: true)
        }
        else
        {
            //Navigate user to HurrayViewController to start Saving plan
            let objEnterYourPinViewController = SAEnterYourPINViewController(nibName: "SAEnterYourPINViewController",bundle: nil)
            self.navigationController?.pushViewController(objEnterYourPinViewController, animated: true)
        }
            }
            else{
                let alert = UIAlertView(title: "Warning", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else
        {
            let alert = UIAlertView(title: "Warning", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }

    }
    
    func errorResponseForRegistrationAPI(error:String){
        objAnimView.removeFromSuperview()
        let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    func addTargetAndRadiusForTf(textField: UITextField) {
        let borderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 3

        textField.layer.borderWidth = borderWidth
        textField.layer.cornerRadius = cornerRadius
        textField.layer.masksToBounds = true
        textField.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        textField.keyboardType = UIKeyboardType.NumberPad
        textField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor

    }
    
    func customizeTextFields() {
        self.addTargetAndRadiusForTf(textFieldOne)
        self.addTargetAndRadiusForTf(textFieldTwo)
        self.addTargetAndRadiusForTf(textFieldThree)
        self.addTargetAndRadiusForTf(textFieldFour)
        self.addTargetAndRadiusForTf(textFieldReOne)
        self.addTargetAndRadiusForTf(textFieldReTwo)
        self.addTargetAndRadiusForTf(textFieldReThree)
        self.addTargetAndRadiusForTf(textFieldReFour)
    }    
    
    func textFieldDidChange(textField: UITextField) {
        
        let text = textField.text
        if text?.utf16.count==1{
            switch textField{
            case textFieldOne:
                textFieldTwo.becomeFirstResponder()
            case textFieldTwo:
                textFieldThree.becomeFirstResponder()
            case textFieldThree:
                textFieldFour.becomeFirstResponder()
            case textFieldFour:
                textFieldReOne.becomeFirstResponder()
            case textFieldReOne:
                textFieldReTwo.becomeFirstResponder()
            case textFieldReTwo:
                textFieldReThree.becomeFirstResponder()
            case textFieldReThree:
                textFieldReFour.becomeFirstResponder()
            case textFieldReFour:
                textFieldReFour.resignFirstResponder()
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
            case textFieldReFour:
                textFieldReThree.becomeFirstResponder()
            case textFieldReThree:
                textFieldReTwo.becomeFirstResponder()
            case textFieldReTwo:
                textFieldReOne.becomeFirstResponder()
            case textFieldReOne:
                textFieldFour.becomeFirstResponder()
            default:
                textFieldOne.becomeFirstResponder()
            }
        }
    }
    
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        self.backgroundScrollView.contentOffset = CGPoint(x: 0, y: 50)
        
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        self.backgroundScrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    @IBAction func bgViewTapped(sender: AnyObject) {
        textFieldReOne.resignFirstResponder()
        textFieldReTwo.resignFirstResponder()
        textFieldReThree.resignFirstResponder()
        textFieldReFour.resignFirstResponder()
        textFieldOne.resignFirstResponder()
        textFieldTwo.resignFirstResponder()
        textFieldThree.resignFirstResponder()
        textFieldFour.resignFirstResponder()
    }
    
    func setAllPinEntryFieldsToColor(color: UIColor) {
        textFieldOne.layer.borderColor = color.CGColor
        textFieldTwo.layer.borderColor = color.CGColor
        textFieldThree.layer.borderColor = color.CGColor
        textFieldFour.layer.borderColor = color.CGColor
        textFieldReOne.layer.borderColor = color.CGColor
        textFieldReTwo.layer.borderColor = color.CGColor
        textFieldReThree.layer.borderColor = color.CGColor
        textFieldReFour.layer.borderColor = color.CGColor
    }
    func resetTextOnAllTextFields() {
        textFieldOne.text = ""
        textFieldTwo.text = ""
        textFieldThree.text = ""
        textFieldFour.text = ""
        textFieldReOne.text = ""
        textFieldReTwo.text = ""
        textFieldReThree.text = ""
        textFieldReFour.text = ""
    }

}
