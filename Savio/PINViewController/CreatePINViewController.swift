//
//  CreatePINViewController.swift
//  Savio
//
//  Created by Maheshwari on 20/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class CreatePINViewController: UIViewController,PostCodeVerificationDelegate,ResetPasscodeDelegate{
    
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    
    @IBOutlet weak var confirmPIN   : UIButton!
    @IBOutlet weak var backButton   : UIButton!

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

    @IBOutlet weak var lblConfirmPasscode       : UILabel!
    @IBOutlet weak var enterFourDigitCodeLabel  : UILabel!
    @IBOutlet weak var headerLabel              : UILabel!
    @IBOutlet weak var subHeaderLabel           : UILabel!
    
    var objAPI          = API()
    var objAnimView     = ImageViewAnimation()
    var activeTextField = UITextField()
    var userInfoDict    = Dictionary<String,AnyObject>()
    
    var lastOffset      : CGPoint = CGPoint.zero
    var arrayTextFields : Array<UITextField>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmPasscodeView.layer.cornerRadius = 3
        confirmPIN.layer.cornerRadius = 3
        self.customizeTextFields()
        userInfoDict = userDefaults.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
//      userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        self.registerForKeyboardNotifications()
        
//        add custom tool bar for UITextField
        let customToolBar = UIToolbar(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action:#selector(CreatePINViewController.doneBarButtonPressed(_:)))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreatePINViewController.cancelBarButtonPressed(_:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil);
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if activeTextField == nil {
            textFieldOne.becomeFirstResponder()
        } else {
            activeTextField.isUserInteractionEnabled = true
            activeTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Set the scrollview content size.
        backgroundScrollView.contentSize = CGSize(width: 0, height: 500)
    }
    
 /*
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeTextField = textField
        self.registerForKeyboardNotifications()
        self.setAllPinEntryFieldsToColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1))
        enterFourDigitCodeLabel.isHidden = true
    }
    */
    
    @IBAction func toolBarDoneButtonPressed(_ sender: AnyObject) {
        backgroundScrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    @IBAction func onclickBackButton(_ sender: AnyObject) {
        isFromForgotPasscode = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickConfirmButton(_ sender: UIButton) {
        
        self.bgViewTapped("AnyObj" as AnyObject)
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
                enterFourDigitCodeLabel.isHidden = false;
                self.setAllPinEntryFieldsToColor(UIColor.red)
                
                
            }
            else if(textFieldOne.text  != textFieldReOne.text || textFieldTwo.text  != textFieldReTwo.text || textFieldThree.text  != textFieldReThree.text || textFieldFour.text  != textFieldReFour.text)
            {
                //Show error when fields are not same
                
                enterFourDigitCodeLabel.isHidden = false;
                enterFourDigitCodeLabel.text = "Passcode do not match"
                self.setAllPinEntryFieldsToColor(UIColor.red)
                self.resetTextOnAllTextFields()
            }
            else
            {
                if((textFieldOne.text?.characters.count)! < 1 || (textFieldReOne.text?.characters.count)! < 1 || (textFieldTwo.text?.characters.count)! < 1 || (textFieldReTwo.text?.characters.count)! < 1 || (textFieldThree.text?.characters.count)! < 1 || (textFieldReThree.text?.characters.count)! < 1 || (textFieldFour.text?.characters.count)! < 1 || (textFieldReFour.text?.characters.count)! < 1)
                {
                    enterFourDigitCodeLabel.isHidden = false;
                    enterFourDigitCodeLabel.text = "Passcode should be of 4 digits"
                }
                else
                {
                    
                    //Add animation of logo
                    objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
                    objAnimView.frame = self.view.frame
                    
                    objAnimView.animate()
                    self.view.addSubview(objAnimView)
                    
                    let passcode = self.textFieldOne.text! + self.textFieldTwo.text! + self.textFieldThree.text! + self.textFieldFour.text!
                    userInfoDict["pass_code"] = passcode.MD5() as AnyObject
           
                    var newUserInfoDict = Dictionary<String,AnyObject>()
                    newUserInfoDict["party"] = userInfoDict as AnyObject
                    var updatePasscodeDict = Dictionary<String,AnyObject>()
                    updatePasscodeDict["mobile_Number"] = userInfoDict[kPhoneNumber]
                    updatePasscodeDict["pin"] = passcode.MD5() as AnyObject
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
    
    func success(_ addressArray:Array<String>){
        
    }
    
    func error(_ error:String){
        
    }
    
    
    func successResponseForResetPasscodeAPI(_ objResponse:Dictionary<String,AnyObject>)
    {
        objAnimView.removeFromSuperview()
        let passcode = self.textFieldOne.text! + self.textFieldTwo.text! + self.textFieldThree.text! + self.textFieldFour.text!
        
        userDefaults.set(passcode, forKey: "pin")
        userDefaults.synchronize()
        
        if let message = objResponse["message"] as? String
        {
            if(message == "Your PIN is updated Sucessfully")
            {
//                NSuserDefaultsUserDefaults().setObject(passcode.MD5(), forKey: "myPasscode")
//                NSuserDefaultsUserDefaults().synchronize()
                
                objAPI.storeValueInKeychainForKey("myPasscode", value: passcode.MD5() as AnyObject)
                headerLabel.text = "Your passcode has been reset"
                backButton.isHidden = true
                confirmPIN .setTitle("Got It", for: UIControlState())
                backgroundScrollView.contentOffset = CGPoint(x: 0, y: 0)
                self.lblConfirmPasscode.isHidden = true
                self.confirmPasscodeView.isHidden = true
                self.passcodeView.isHidden = true
            }
            else {
                let alert = UIAlertView(title: "Warning", message: message , delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else if let internalMessage = objResponse["internalMessage"] as? String
        {
            if(internalMessage == "Multiple representations of the same entity"){
                let alert = UIAlertController(title: "Important Information", message: "Enter mobile number initially register with", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                { action -> Void in
                    var vw = UIViewController()
                    for var obj in (self.navigationController?.viewControllers)!{
                        if obj.isKind(of: SARegistrationScreenOneViewController.self) {
                            vw = obj as! SARegistrationScreenOneViewController
                            self.navigationController?.popToViewController(vw, animated: true)
                            break
                        }
                    }
                })
                self.present(alert, animated: true, completion: nil)
                
            }else{
            let alert = UIAlertView(title: "Important Information", message: internalMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            }
        }
        
    }
    func errorResponseForOTPResetPasscodeAPI(_ error:String){
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else {
        let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
        
    }
    
    func successResponseForRegistrationAPI(_ objResponse:Dictionary<String,AnyObject>){
        objAnimView.removeFromSuperview()
        //Store the passcode in Keychain
        let passcode = self.textFieldOne.text! + self.textFieldTwo.text! + self.textFieldThree.text! + self.textFieldFour.text!
        
        if let message = objResponse["message"]
        {
            if(message as! String == "User sucessfully register")
            {
//                NSuserDefaultsUserDefaults().setObject(passcode.MD5(), forKey: "myPasscode")
//                NSuserDefaultsUserDefaults().setObject(objResponse["party"]!, forKey: "userInfo")
//                NSuserDefaultsUserDefaults().synchronize()
                
                objAPI.storeValueInKeychainForKey("myPasscode", value: passcode.MD5() as AnyObject)
                objAPI.storeValueInKeychainForKey(kUserInfo, value: objResponse["party"]!)
                //Navigate user to HurrayViewController to start Saving plan
                let objEnterYourPinViewController = SAEnterYourPINViewController(nibName: "SAEnterYourPINViewController",bundle: nil)
                self.navigationController?.pushViewController(objEnterYourPinViewController, animated: true)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: (message as! String), delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            
        }
    }
    
    func errorResponseForRegistrationAPI(_ error:String){
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else {
        let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
    }
    
    func addTargetAndRadiusForTf(_ textField: UITextField) {
        let borderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 3
        
        textField.layer.borderWidth = borderWidth
        textField.layer.cornerRadius = cornerRadius
        textField.layer.masksToBounds = true
        textField.addTarget(self, action: #selector(CreatePINViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        textField.keyboardType = UIKeyboardType.numberPad
        textField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
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
    
    func textFieldDidChange(_ textField: UITextField) {
        
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
            
            for _ in 0...tag {
                tag -= 1
                if tag >= 0 {
                    let tfPre = arrayTextFields[tag]
                    if (tfPre.text?.characters.count)! > 0 {
                        tfPre.becomeFirstResponder()
                        break
                    }
                }
            }
        }
    }
    
    func makePreviousKeyfiledFirstResponder(_ idx: Int) {
        
      
        
    }
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(CreatePINViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreatePINViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(_ notification: Notification) {
        //do stuff
        var yOfTextField : CGFloat = 0.0
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue.size
        let visibleAreaHeight = UIScreen.main.bounds.height - 30 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
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
    
    @objc func keyboardWillBeHidden(_ notification: Notification){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        backgroundScrollView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func doneBarButtonPressed(_ sender: AnyObject) {
        activeTextField.resignFirstResponder()
        self.removeKeyboardNotification()
    }
    
    func cancelBarButtonPressed(_ sender: AnyObject) {
        activeTextField.resignFirstResponder()
        self.removeKeyboardNotification()
    }
    @IBAction func bgViewTapped(_ sender: AnyObject) {
        textFieldReOne.resignFirstResponder()
        textFieldReTwo.resignFirstResponder()
        textFieldReThree.resignFirstResponder()
        textFieldReFour.resignFirstResponder()
        textFieldOne.resignFirstResponder()
        textFieldTwo.resignFirstResponder()
        textFieldThree.resignFirstResponder()
        textFieldFour.resignFirstResponder()
    }
    
    func setAllPinEntryFieldsToColor(_ color: UIColor) {
        textFieldOne.layer.borderColor = color.cgColor
        textFieldTwo.layer.borderColor = color.cgColor
        textFieldThree.layer.borderColor = color.cgColor
        textFieldFour.layer.borderColor = color.cgColor
        textFieldReOne.layer.borderColor = color.cgColor
        textFieldReTwo.layer.borderColor = color.cgColor
        textFieldReThree.layer.borderColor = color.cgColor
        textFieldReFour.layer.borderColor = color.cgColor
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

//MARK: - UITextField Methods

extension CreatePINViewController: UITextFieldDelegate {
    
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
