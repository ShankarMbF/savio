//
//  CreatePINViewController.swift
//  Savio
//
//  Created by Maheshwari on 20/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class CreatePINViewController: UIViewController, PostCodeVerificationDelegate, ResetPasscodeDelegate{
    
    @IBOutlet var toolBar: UIToolbar!
   
    @IBOutlet weak var confirmPIN: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var textFieldOne     : UITextField!
    @IBOutlet weak var textFieldTwo     : UITextField!
    @IBOutlet weak var textFieldThree   : UITextField!
    @IBOutlet weak var textFieldFour    : UITextField!
    @IBOutlet weak var textFieldReOne   : UITextField!
    @IBOutlet weak var textFieldReTwo   : UITextField!
    @IBOutlet weak var textFieldReThree : UITextField!
    @IBOutlet weak var textFieldReFour  : UITextField!
    
    @IBOutlet weak var confirmPasscodeView  : UIView!
    @IBOutlet weak var passcodeView         : UIView!
    @IBOutlet weak var backgroundScrollView : UIScrollView!
    
    @IBOutlet weak var enterFourDigitCodeLabel  : UILabel!
    @IBOutlet weak var headerLabel              : UILabel!
    @IBOutlet weak var subHeaderLabel           : UILabel!
    @IBOutlet weak var lblConfirmPasscode       : UILabel!
    
    var objAPI = API()
    var objAnimView = ImageViewAnimation()
    var activeTxtField  : UITextField?
    var activeTextField = UITextField()
    var userInfoDict  = Dictionary<String,AnyObject>()
    var lastOffset: CGPoint = CGPointZero
    var arrayTextFields: Array<UITextField>!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmPasscodeView.layer.cornerRadius = 3
        confirmPIN.layer.cornerRadius = 3
        self.customizeTextFields()
        userInfoDict = NSUserDefaults.standardUserDefaults().objectForKey(kUserInfo) as! Dictionary<String,AnyObject>
//        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        self.registerForKeyboardNotifications()
        
        //add custom tool bar for UITextField
        let customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:#selector(CreatePINViewController.doneBarButtonPressed(_:)))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreatePINViewController.cancelBarButtonPressed(_:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar.items = [cancelButton,flexibleSpace,acceptButton]
        
        self.arrayTextFields = [textFieldOne,
            textFieldTwo,
            textFieldThree,
            textFieldFour,
            textFieldReOne,
            textFieldReTwo,
            textFieldReThree,
            textFieldReFour]
        
        for tf: UITextField in arrayTextFields {
            tf.inputAccessoryView = customToolBar
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if activeTxtField == nil {
            textFieldOne.becomeFirstResponder()
        } else {
            activeTxtField?.userInteractionEnabled = true
            activeTxtField?.becomeFirstResponder()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Set the scrollview content size.
        backgroundScrollView.contentSize = CGSizeMake(0, 500)
    }
    
/*
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
        activeTextField = textField
        self.registerForKeyboardNotifications()
        self.setAllPinEntryFieldsToColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1))
        enterFourDigitCodeLabel.hidden = true
    }
*/
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
        else {
            
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
                textFieldOne.userInteractionEnabled = true
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
                    objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
                    objAnimView.frame = self.view.frame
                    
                    objAnimView.animate()
                    self.view.addSubview(objAnimView)
                    
                    let passcode = self.textFieldOne.text! + self.textFieldTwo.text! + self.textFieldThree.text! + self.textFieldFour.text!
                    userInfoDict["pass_code"] = passcode.MD5()
           
                    var newUserInfoDict = Dictionary<String,AnyObject>()
                    newUserInfoDict["party"] = userInfoDict
                    var updatePasscodeDict = Dictionary<String,AnyObject>()
                    updatePasscodeDict["mobile_Number"] = userInfoDict[kPhoneNumber]
                    updatePasscodeDict["pin"] = passcode.MD5()
                    if(checkString == "ForgotPasscode")
                    {
                        objAPI.resetPasscodeDelegate = self
                        objAPI.resetPasscodeOfUserID(updatePasscodeDict)
                    }
                    else {
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
//                NSUserDefaults.standardUserDefaults().setObject(passcode.MD5(), forKey: "myPasscode")
//                NSUserDefaults.standardUserDefaults().synchronize()
                
                objAPI.storeValueInKeychainForKey("myPasscode", value: passcode.MD5())
                headerLabel.text = "Your passcode has been reset"
                backButton.hidden = true
                confirmPIN .setTitle("Got It", forState: UIControlState.Normal)
                backgroundScrollView.contentOffset = CGPointMake(0, 0)
                self.lblConfirmPasscode.hidden = true
                self.confirmPasscodeView.hidden = true
                self.passcodeView.hidden = true
            }
            else {
                let alert = UIAlertView(title: "Warning", message: message as! String, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else if let internalMessage = objResponse["internalMessage"] as? String
        {
            if(internalMessage == "Multiple representations of the same entity"){
                let alert = UIAlertController(title: "Important Information", message: "Enter mobile number initially register with", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
                { action -> Void in
                    var vw = UIViewController?()
                    for var obj in (self.navigationController?.viewControllers)!{
                        if obj.isKindOfClass(SARegistrationScreenOneViewController) {
                            vw = obj as! SARegistrationScreenOneViewController
                            self.navigationController?.popToViewController(vw!, animated: true)
                            break
                        }
                    }
                })
                self.presentViewController(alert, animated: true, completion: nil)
                
            }else{
            let alert = UIAlertView(title: "Important Information", message: internalMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            }
        }
        
    }
    func errorResponseForOTPResetPasscodeAPI(error:String){
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else {
        let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
        
    }
    
    func successResponseForRegistrationAPI(objResponse:Dictionary<String,AnyObject>){
        objAnimView.removeFromSuperview()
        //Store the passcode in Keychain
        let passcode = self.textFieldOne.text! + self.textFieldTwo.text! + self.textFieldThree.text! + self.textFieldFour.text!
        
        if let message = objResponse["message"]
        {
            if(message as! String == "User sucessfully register")
            {
//                NSUserDefaults.standardUserDefaults().setObject(passcode.MD5(), forKey: "myPasscode")
//                NSUserDefaults.standardUserDefaults().setObject(objResponse["party"]!, forKey: "userInfo")
//                NSUserDefaults.standardUserDefaults().synchronize()
                
                objAPI.storeValueInKeychainForKey("myPasscode", value: passcode.MD5())
                objAPI.storeValueInKeychainForKey(kUserInfo, value: objResponse["party"]!)
                //Navigate user to HurrayViewController to start Saving plan
                let objEnterYourPinViewController = SAEnterYourPINViewController(nibName: "SAEnterYourPINViewController",bundle: nil)
                self.navigationController?.pushViewController(objEnterYourPinViewController, animated: true)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: message as! String, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            
        }
    }
    
    func errorResponseForRegistrationAPI(error:String){
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else {
        let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
    }
    
    func addTargetAndRadiusForTf(textField: UITextField) {
        let borderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 3
        
        textField.layer.borderWidth = borderWidth
        textField.layer.cornerRadius = cornerRadius
        textField.layer.masksToBounds = true
        textField.addTarget(self, action: #selector(CreatePINViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
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
        var tag = textField.tag
        if text?.utf16.count==1{
            for tf: UITextField in arrayTextFields {
                if tf.tag == tag && tag != 7 {
                    let tfNext = arrayTextFields[tag + 1]
                    tfNext.becomeFirstResponder()
                    break
                }
                else if tag == 7 {
                    textField.resignFirstResponder()
                    break
                }
            }
        }else {
            
            for idx in 0...tag {
                tag -= 1
                if tag >= 0 {
                    let tfPre = arrayTextFields[tag]
                    if tfPre.text?.characters.count > 0 {
                        tfPre.becomeFirstResponder()
                        break
                    }
                }
            }
        }
    }
    
    func makePreviousKeyfiledFirstResponder(idx: Int) {
    
        
    }
    
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreatePINViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreatePINViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        //do stuff
        var yOfTextField : CGFloat = 0.0
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let visibleAreaHeight = UIScreen.mainScreen().bounds.height - 30 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
        lastOffset = (backgroundScrollView?.contentOffset)!
        if(activeTextField == textFieldOne || activeTextField == textFieldTwo || activeTextField == textFieldThree || activeTextField == textFieldFour)
        {
            yOfTextField = activeTextField.frame.height + passcodeView.frame.origin.y
        }
        else {
            yOfTextField = activeTextField.frame.height + confirmPasscodeView.frame.origin.y
        }
        if (yOfTextField - (lastOffset.y)) >= visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            backgroundScrollView?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        backgroundScrollView?.setContentOffset(CGPointZero, animated: true)
    }
    
    func doneBarButtonPressed(sender: AnyObject) {
        activeTextField.resignFirstResponder()
        self.removeKeyboardNotification()
    }
    
    func cancelBarButtonPressed(sender: AnyObject) {
        activeTextField.resignFirstResponder()
        self.removeKeyboardNotification()
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
        textFieldOne.layer.borderColor      = color.CGColor
        textFieldTwo.layer.borderColor      = color.CGColor
        textFieldThree.layer.borderColor    = color.CGColor
        textFieldFour.layer.borderColor     = color.CGColor
        textFieldReOne.layer.borderColor    = color.CGColor
        textFieldReTwo.layer.borderColor    = color.CGColor
        textFieldReThree.layer.borderColor  = color.CGColor
        textFieldReFour.layer.borderColor   = color.CGColor
    }
    func resetTextOnAllTextFields() {
        textFieldOne.text       = ""
        textFieldTwo.text       = ""
        textFieldThree.text     = ""
        textFieldFour.text      = ""
        textFieldReOne.text     = ""
        textFieldReTwo.text     = ""
        textFieldReThree.text   = ""
        textFieldReFour.text    = ""
    }
}


extension CreatePINViewController : UITextFieldDelegate {
    
    //UITextField delegate method
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTxtField = textField
        activeTextField = textField
        self.registerForKeyboardNotifications()
        self.setAllPinEntryFieldsToColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1))
        enterFourDigitCodeLabel.hidden = true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if let passcodeTextField = textField as? PasscodeTextField {
            let text = ((textField.text ?? "") as NSString).stringByReplacingCharactersInRange(range, withString: string)
            
            if text.characters.count > 0 || string == "" {
                if string == ""  {
                    if passcodeTextField.previousTextField != nil {
                        if passcodeTextField.text?.characters.count == 0 {
                            passcodeTextField.previousTextField?.text = ""
                        } else {
                            passcodeTextField.text = ""
                        }
                        passcodeTextField.userInteractionEnabled = false
                        passcodeTextField.previousTextField?.userInteractionEnabled = true
                        passcodeTextField.previousTextField?.becomeFirstResponder()
                        return false
                    } else {
                        passcodeTextField.text = ""
                        passcodeTextField.previousTextField?.userInteractionEnabled = true
                        passcodeTextField.resignFirstResponder()
                        return false
                    }
                } else {
                    if passcodeTextField.nextTextField != nil {
                        passcodeTextField.text = string
                        passcodeTextField.userInteractionEnabled = false
                        passcodeTextField.nextTextField?.userInteractionEnabled = true
                        passcodeTextField.nextTextField?.becomeFirstResponder()
                        return false
                    } else {
                        passcodeTextField.text = string
                        passcodeTextField.resignFirstResponder()
                        return false
                    }
                }
            }
        }
        return true
    }
}
