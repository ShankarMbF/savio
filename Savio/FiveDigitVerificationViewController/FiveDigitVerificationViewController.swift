//
//  FiveDigitVerificationViewController.swift
//  Savio
//
//  Created by Maheshwari on 20/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class FiveDigitVerificationViewController: UIViewController,UITextFieldDelegate,OTPSentDelegate,OTPVerificationDelegate {
    
    @IBOutlet weak var headerText: UILabel!
    
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var codeDoesNotMatchLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var resentCodeButton: UIButton!
    @IBOutlet weak var fiveDigitTextField: UITextField!
    @IBOutlet weak var yourCodeSentLabel: UILabel!
    let objAPI = API()
    var objAnimView = ImageViewAnimation()
    var userInfoDict : Dictionary<String,AnyObject> = [:]
    var isComingFromRegistration: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //change the border color of UITextField
        fiveDigitTextField.layer.cornerRadius = 2
        fiveDigitTextField.layer.masksToBounds = true
        fiveDigitTextField.layer.borderWidth = 1
        fiveDigitTextField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        //Set input accessory view to the UITextfield
        fiveDigitTextField.inputAccessoryView = toolbar
        
        gotItButton.layer.cornerRadius = 5
        //Get user details from Keychain
        userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
//        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
    }
    
    func removeKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        objAnimView.removeFromSuperview()
        
        if(isFromForgotPasscode == true)
        {
            isFromForgotPasscode = false
            yourCodeSentLabel.text = String(format:"Your code was sent to  %@",userInfoDict[kPhoneNumber]! as! String)
            
            fiveDigitTextField.isHidden = false
            resentCodeButton.isHidden = false
            backButton.isHidden = false
            yourCodeSentLabel.isHidden = true
        }
        else {
            yourCodeSentLabel.text = String(format:"Your code was sent to  %@",userInfoDict[kPhoneNumber]! as! String)
            fiveDigitTextField.isHidden = true
            resentCodeButton.isHidden = true
            backButton.isHidden = false
            yourCodeSentLabel.isHidden = false
            
        }
    }
    
    //UITextField delegate method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(UIScreen.main.bounds.size.height == 480)
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRect(x: view!.frame.origin.x, y: (view!.frame.origin.y-40), width: view!.frame.size.width, height: view!.frame.size.height)
            UIView.commitAnimations()
        }
        codeDoesNotMatchLabel.isHidden = true;
        fiveDigitTextField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        fiveDigitTextField.textColor = UIColor.black
    }
    
    @IBAction func clickOnBackButton(_ sender: AnyObject) {
        /*
         fiveDigitTextField.hidden = true
         resentCodeButton.hidden = true
         backButton.hidden = true
         yourCodeSentLabel.hidden = false
         headerText.text = "We've sent you a verification code"
         gotItButton.setTitle("Got It", forState: UIControlState.Normal)
         codeDoesNotMatchLabel.hidden = true
         */
        if isComingFromRegistration == true {
            for viewcontroller in self.navigationController!.viewControllers as Array {
                if viewcontroller.isKind(of: SARegistrationScreenOneViewController.self) { // change HomeVC to your viewcontroller in which you want to back.
                    self.navigationController?.popToViewController(viewcontroller , animated: true)
                    break
                }
            }
        }
        else{
            for viewcontroller in self.navigationController!.viewControllers as Array {
                if viewcontroller.isKind(of: SAEnterYourPINViewController.self) { // change HomeVC to your viewcontroller in which you want to back.
                    self.navigationController?.popToViewController(viewcontroller , animated: true)
                    break
                }
            }
        }
        
        //        let saRegisterViewController = SARegistrationScreenOneViewController(nibName:"SARegistrationScreenOneViewController",bundle: nil)
        //        self.navigationController?.pushViewController(saRegisterViewController, animated: true)
    }
    
    @IBAction func doneButtonToolBarPressed(_ sender: AnyObject) {
        if(UIScreen.main.bounds.size.height == 480)
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRect(x: view!.frame.origin.x, y: (view!.frame.origin.y+50), width: view!.frame.size.width, height: view!.frame.size.height)
            UIView.commitAnimations()
        }
        fiveDigitTextField.resignFirstResponder()
    }
    
    @IBAction func clickOnGotItButton(_ sender: AnyObject) {
        
        if(yourCodeSentLabel.isHidden == false)
        {
            fiveDigitTextField.isHidden = false
            resentCodeButton.isHidden = false
            backButton.isHidden = false
            yourCodeSentLabel.isHidden = true
            headerText.text = "Enter your verification code"
            gotItButton.setTitle("Confirm", for: UIControlState())
        }
        else  {
            if(fiveDigitTextField.text == "")
            {   //Show error when field is empty
                fiveDigitTextField.layer.borderColor = UIColor.red.cgColor
                codeDoesNotMatchLabel.text = "Please enter code"
                codeDoesNotMatchLabel.isHidden = false;
            }
            else {
                //Set the OTPVerificationDelegate
      
                //---------------Remove below comment while testing on live authy---------------//
             /*
                objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
                objAnimView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
                objAnimView.animate()
                self.view.addSubview(objAnimView)
 
                objAPI.otpVerificationDelegate = self
                objAPI.verifyOTP(userInfoDict["phone_number"]! as! String, country_code: "44", OTP: fiveDigitTextField.text!)
                codeDoesNotMatchLabel.hidden = true;
                fiveDigitTextField.resignFirstResponder()
*/
                //---------------Comment below code while testing on live authy---------------//
                let objCreatePINView = CreatePINViewController(nibName: "CreatePINViewController",bundle: nil)
                self.navigationController?.pushViewController(objCreatePINView, animated: true) 
 
            }
        }
    }
    
    @IBAction func clickOnResentCodeButton(_ sender: AnyObject) {
        //Set the OTPSentDelegate
        objAPI.otpSentDelegate = self
        codeDoesNotMatchLabel.isHidden = true
        fiveDigitTextField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor

        //Resend the OTP to the mobile number present in keychain
        objAPI.getOTPForNumber(userInfoDict[kPhoneNumber]! as! String, country_code: "44")
        fiveDigitTextField.resignFirstResponder()
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        objAnimView.animate()
        self.view.addSubview(objAnimView)
    }
    
    
    //OTP sent Delegate Method
    func successResponseForOTPSentAPI(_ objResponse:Dictionary<String,AnyObject>)
    {
        objAnimView.removeFromSuperview()
        fiveDigitTextField.isHidden = true
        resentCodeButton.isHidden = true
        backButton.isHidden = true
        yourCodeSentLabel.isHidden = false
        headerText.text = "We've sent you a verification code"
        gotItButton.setTitle("Got It", for: UIControlState())
        codeDoesNotMatchLabel.isHidden = true
        
    }
    func errorResponseForOTPSentAPI(_ error:String){
        
        objAnimView.removeFromSuperview()
        fiveDigitTextField.textColor = UIColor.red
        fiveDigitTextField.isHidden = true
        resentCodeButton.isHidden = true
        backButton.isHidden = true
        yourCodeSentLabel.isHidden = false
        headerText.text = error//"We've sent you a verification code"
        gotItButton.setTitle("Got It", for: UIControlState())
    }
    
    
    //OTP Verification Delegate Method
    func successResponseForOTPVerificationAPI(_ objResponse:Dictionary<String,AnyObject>)
    {
         objAnimView.removeFromSuperview()
        let objCreatePINView = CreatePINViewController(nibName: "CreatePINViewController",bundle: nil)
        self.navigationController?.pushViewController(objCreatePINView, animated: true)
    }
    func errorResponseForOTPVerificationAPI(_ error:String){
        objAnimView.removeFromSuperview()
        if(error == "Verification code is incorrect.")
        {
//            codeDoesNotMatchLabel.text = error
//            codeDoesNotMatchLabel.hidden = false;
            let alert = UIAlertView(title: "Incorrect verification code", message: "Please try again or request a new code.", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else
        {
            let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
}
