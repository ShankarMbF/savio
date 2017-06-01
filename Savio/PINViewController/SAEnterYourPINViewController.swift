//
//  SAEnterYourPINViewController.swift
//  Savio
//
//  Created by Maheshwari  on 21/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SAEnterYourPINViewController: UIViewController,OTPSentDelegate,LogInDelegate,UIScrollViewDelegate {
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
    @IBOutlet weak var enterYourPasscodeLabel: UILabel!
    @IBOutlet weak var registerButtonBackgroundView: UIView!
    @IBOutlet weak var scrlView: UIScrollView!
    
    var lastOffset: CGPoint = CGPoint.zero
    var activeTextField = UITextField()
    var objAnimView = ImageViewAnimation()
    let objAPI = API()
    var userInfoDict = Dictionary<String,AnyObject>()
    var arrayTextFields: Array<UITextField>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customizeTextFields()
        
        // Do any additional setup after loading the view.
        //change the border color and placeholder color of UITextField
        
        //Add shadowcolor to UIButtons
        
        let myNumber = 505;
        let outputNum = (NSInteger)(ceil(Double( myNumber)/1000) * 1000);
        print(outputNum)
        
        registerButton.layer.cornerRadius = 5
        btnVwBg.layer.cornerRadius = 5
      
        loginButton.layer.cornerRadius = 5
        
        userInfoDict = userDefaults.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
//        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        //add custom tool bar for UITextField
        let customToolBar = UIToolbar(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action:#selector(SAEnterYourPINViewController.doneBarButtonPressed(_:)))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SAEnterYourPINViewController.cancelBarButtonPressed(_:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil);
        customToolBar.items = [cancelButton,flexibleSpace,acceptButton]
        
        self.arrayTextFields = [textFieldOne,
                                textFieldTwo,
                                textFieldThree,
                                textFieldFour]
        
        for tf: UITextField in arrayTextFields {
            tf.inputAccessoryView = customToolBar
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        textFieldOne.text = ""
        textFieldTwo.text = ""
        textFieldThree.text = ""
        textFieldFour.text = ""
    }
    
    func doneBarButtonPressed(_ sender: AnyObject) {
        activeTextField.resignFirstResponder()
        self.removeKeyboardNotification()
    }
    
    func cancelBarButtonPressed(_ sender: AnyObject) {
        activeTextField.resignFirstResponder()
        self.removeKeyboardNotification()
    }
    
    //Register keyboard notification
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(SAEnterYourPINViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SAEnterYourPINViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Keyboard notification function
    @objc func keyboardWasShown(_ notification: Notification){
        //do stuff
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue.size
        let visibleAreaHeight = UIScreen.main.bounds.height - 30 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
        lastOffset = (scrlView?.contentOffset)!
        let yOfTextField = activeTextField.frame.height + pinTextFieldsContainerView.frame.origin.y
        if (yOfTextField - (lastOffset.y)) >= visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            scrlView?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(_ notification: Notification){
        //do stuff
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        scrlView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
/*
     
//    UITextField delegate method
    func textFieldDidBeginEditing(_ textField: UITextField) {
         activeTextField = textField
        self.registerForKeyboardNotifications()
        errorLabel.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        errorLabel.isHidden = true
        textField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        let currentCharacterCount = textField.text?.characters.count ?? 0
        let newLength = currentCharacterCount + string.characters.count
        if (newLength > 1) {
            return false;
        }
        return true;
    }
    
  */
    
    @IBAction func clickOnRegisterButton(_ sender: AnyObject) {
        if(registerButton.titleLabel?.text == "Register")
        {
//            let saRegisterViewController = SARegistrationViewController(nibName:"SARegistrationViewController",bundle: nil)
//            self.navigationController?.pushViewController(saRegisterViewController, animated: true)
        }
        else  {
            //Send the OTP to mobile number
            
            //Get the user details from Keychain
            //
            //            let objCreatePINView = CreatePINViewController(nibName: "CreatePINViewController",bundle: nil)
            //            self.navigationController?.pushViewController(objCreatePINView, animated: true)
            //
            
            objAPI.otpSentDelegate = self;
            objAPI.getOTPForNumber(userInfoDict[kPhoneNumber]! as! String, country_code: "44")
            
            //Add animation of logo
            objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            
            objAnimView.animate()
            self.view.addSubview(objAnimView)
        }
    }
    
    @IBAction func clickedOnForgotPasscode(_ sender: AnyObject) {
        
        lblSentYouCode.isHidden = false
        lblForgottonYourPasscode.isHidden = false
        btnCancel.isHidden = false
        registerButton .setTitle("Send me a code", for: UIControlState())
        registerButtonBackgroundView.isHidden = false
        registerButton.isHidden = false
        forgotPasscodeButton.isHidden = true
        loginButton.isHidden = true
        btnVwBg.isHidden = true
        checkString = "ForgotPasscode"
        errorLabel.isHidden = true
        pinTextFieldsContainerView.isHidden = true
        
        enterYourPasscodeLabel.isHidden = true
        textFieldOne.resignFirstResponder()
        textFieldTwo.resignFirstResponder()
        textFieldThree.resignFirstResponder()
        textFieldFour.resignFirstResponder()
        textFieldOne.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        textFieldTwo.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        textFieldThree.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        textFieldFour.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
    }
    
    
    @IBAction func onClickCancelButton(_ sender: AnyObject) {
        
        lblSentYouCode.isHidden = true
        lblForgottonYourPasscode.isHidden = true
        btnCancel.isHidden = true
        registerButton.isHidden = true
        
        registerButton .setTitle("Register", for: UIControlState())
        registerButtonBackgroundView.isHidden = true
        forgotPasscodeButton.isHidden = false
        loginButton.isHidden = false
        btnVwBg.isHidden = false
        pinTextFieldsContainerView.isHidden = false
        enterYourPasscodeLabel.isHidden = false
        
    }
   
    
    @IBAction func clickOnLoginButton(_ sender: AnyObject) {
        //LogInButton click
        if(textFieldOne.text == "" || textFieldTwo.text == ""  || textFieldThree.text == ""  || textFieldFour.text == ""  )
        {
            //Show error when field is empty
            
            errorLabel.isHidden = false
            errorLabel.text = "Please enter passcode"
            
            if  textFieldOne.text == "" {
                textFieldOne.layer.borderColor = UIColor.red.cgColor
            }
            if  textFieldTwo.text == "" {
                textFieldTwo.layer.borderColor = UIColor.red.cgColor
            }
            if  textFieldThree.text == "" {
                textFieldThree.layer.borderColor = UIColor.red.cgColor
            }
            if  textFieldFour.text == "" {
                textFieldFour.layer.borderColor = UIColor.red.cgColor
            }
        }
        else
        {
            objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            objAPI.logInDelegate = self;
            objAnimView.animate()
            self.view.addSubview(objAnimView)
            
            var userDict = userDefaults.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
//            var userDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
            var param = Dictionary<String,AnyObject>()
//            param[kUserInfo] = userDict[kPartyID]
            param["userID"] = userDict[kPartyID]
            let pinPassword = textFieldOne.text! + textFieldTwo.text! + textFieldThree.text! + textFieldFour.text!
            param["pin"] = pinPassword.MD5() as AnyObject
            
            if let apnsDeviceToken = userDefaults.value(forKey: "APNSTOKEN") as? NSString
            {
                param["PNS_DEVICE_ID"] =  apnsDeviceToken
                
            } else {
                param["PNS_DEVICE_ID"] =  "" as AnyObject
            }
            print(param)
            objAPI.logInWithUserID(param)
        }
    }
    
    func setAllPinEntryFieldsToColor(_ color: UIColor) {
        textFieldOne.layer.borderColor = color.cgColor
        textFieldTwo.layer.borderColor = color.cgColor
        textFieldThree.layer.borderColor = color.cgColor
        textFieldFour.layer.borderColor = color.cgColor
    }
    
    //LogIn Delegate Methods
    
    func successResponseForLogInAPI(_ objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)

        objAnimView.removeFromSuperview()
        let dict = objResponse["party"]
        let udidDict = dict!["deviceRegistration"] as! Array<Dictionary<String,AnyObject>>
        let udidArray = udidDict[0]
        userInfoDict["cookie"] = udidArray["COOKIE"] as! String as AnyObject
//        NSuserDefaultsUserDefaults().setObject(userInfoDict, forKey: "userInfo")
        objAPI.storeValueInKeychainForKey(kUserInfo, value: userInfoDict as AnyObject)
        
        let passcode = self.textFieldOne.text! + self.textFieldTwo.text! + self.textFieldThree.text! + self.textFieldFour.text!
//       NSuserDefaultsUserDefaults().setObject(passcode.MD5(), forKey: "myPasscode")
//        NSuserDefaultsUserDefaults().synchronize()
        objAPI.storeValueInKeychainForKey("myPasscode", value: passcode.MD5() as AnyObject)
        
        let groupPlan = objResponse["G"] as! NSNumber
        let individualPlan = objResponse["I"] as! NSNumber
        let groupMemberPlan = objResponse["GM"] as! NSNumber
     //Store the plan info in NSUserDefaults
        userDefaults.set(groupPlan, forKey: kGroupPlan)
        userDefaults.set(individualPlan, forKey: kIndividualPlan)
        userDefaults.set(groupMemberPlan, forKey: kGroupMemberPlan)
        userDefaults.synchronize()
        
        self.setUpMenu(groupPlan, individual: individualPlan, member: groupMemberPlan)
        
        if (groupPlan == 1 || individualPlan == 1 || groupMemberPlan == 1) {
                let objContainer = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
                self.navigationController?.pushViewController(objContainer, animated: true)
        
        }else {
            let objHurrrayView = HurreyViewController(nibName:"HurreyViewController",bundle: nil)
            self.navigationController?.pushViewController(objHurrrayView, animated: true)
        }
    }

    func errorResponseForOTPLogInAPI(_ error: String) {
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }

        else if(error == "Passcode is incorrect")
        {
            errorLabel.isHidden = false
            errorLabel.text = "Passcode is not correct"
            textFieldOne.isUserInteractionEnabled = true
            textFieldOne.text = ""
            textFieldTwo.text = ""
            textFieldThree.text = ""
            textFieldFour.text = ""
            self.setAllPinEntryFieldsToColor( UIColor.red)
        }
        else
        {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kTimeOutNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    
    func setUpMenu(_ group:NSNumber,individual:NSNumber,member:NSNumber)  {
        var className :String = ""
        
        if individual == 1 {
            className = kIndividualPlan
        }
        else if group == 1 {
            className = kGroupPlan
        }
        else if member == 1 {
            className = kGroupMemberPlan
        }
        else {
            className = ""
        }
        userDefaults.set(className, forKey: "ShowProgress")
        userDefaults.synchronize()
    }
    
    
    //OTP Verification Delegate Method
    func successResponseForOTPSentAPI(_ objResponse:Dictionary<String,AnyObject>)
    {
        objAnimView.removeFromSuperview()
        let fiveDigitVerificationViewController = FiveDigitVerificationViewController(nibName:"FiveDigitVerificationViewController",bundle: nil)
        fiveDigitVerificationViewController.isComingFromRegistration = false
        self.navigationController?.pushViewController(fiveDigitVerificationViewController, animated: true)
    }
    func errorResponseForOTPSentAPI(_ error:String){
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else if (error == "The request timed out")
        {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kTimeOutNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else
        {
        
        let fiveDigitVerificationViewController = FiveDigitVerificationViewController(nibName:"FiveDigitVerificationViewController",bundle: nil)
            fiveDigitVerificationViewController.isComingFromRegistration = false
        self.navigationController?.pushViewController(fiveDigitVerificationViewController, animated: true)
        }
        
    }
    
    
    func customizeTextFields() {
        self.setAllPinEntryFieldsToColor( UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1))
        
        let borderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 3
        
        textFieldOne.layer.borderWidth = borderWidth
        textFieldOne.layer.cornerRadius = cornerRadius
        textFieldOne.layer.masksToBounds = true
        
        
        textFieldTwo.layer.borderWidth = borderWidth
        textFieldTwo.layer.cornerRadius = cornerRadius
        textFieldTwo.layer.masksToBounds = true
        
        textFieldThree.layer.borderWidth = borderWidth
        textFieldThree.layer.cornerRadius = cornerRadius
        textFieldThree.layer.masksToBounds = true
        
        textFieldFour.layer.borderWidth = borderWidth
        textFieldFour.layer.cornerRadius = cornerRadius
        textFieldFour.layer.masksToBounds = true
        
        textFieldFour.keyboardType = UIKeyboardType.numberPad
        
        textFieldOne.addTarget(self, action: #selector(SAEnterYourPINViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        textFieldTwo.addTarget(self, action: #selector(SAEnterYourPINViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        textFieldThree.addTarget(self, action: #selector(SAEnterYourPINViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        textFieldFour.addTarget(self, action: #selector(SAEnterYourPINViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        let text = textField.text
        var tag = textField.tag
        if text?.utf16.count==1{
            for tf: UITextField in arrayTextFields {
                if tf.tag == tag && tag != 3 {
                    let tfNext = arrayTextFields[tag + 1]
                    tfNext.becomeFirstResponder()
                    break
                }
                else if tag == 3 {
                    textField.resignFirstResponder()
                    break
                }
            }
            
        }else {
            
            for _ in 0...tag {
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
    
    @IBAction func bgViewTapped(_ sender: AnyObject) {
        textFieldOne.resignFirstResponder()
        textFieldTwo.resignFirstResponder()
        textFieldThree.resignFirstResponder()
        textFieldFour.resignFirstResponder()
    }
    
}


//MARK: - UITextField Methods

extension SAEnterYourPINViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        self.registerForKeyboardNotifications()
        self.setAllPinEntryFieldsToColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let passcodeTextField = textField as? PasscodeTextField {
            let text = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
            
            if text.characters.count > 0 || string == "" {
                if string == ""  {
                    if passcodeTextField.previousTextField != nil {
                        if passcodeTextField.text?.characters.count == 0 {
                            passcodeTextField.previousTextField?.text = ""
                        } else {
                            passcodeTextField.text = ""
                        }
                        
                        passcodeTextField.isUserInteractionEnabled = false
                        passcodeTextField.previousTextField?.isUserInteractionEnabled = true
                        passcodeTextField.previousTextField?.becomeFirstResponder()
                        return false
                    } else {
                        passcodeTextField.text = ""
                    }
                } else {
                    if passcodeTextField.nextTextField != nil {
                        passcodeTextField.text = string
                        passcodeTextField.isUserInteractionEnabled = false
                        passcodeTextField.nextTextField?.isUserInteractionEnabled = true
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
