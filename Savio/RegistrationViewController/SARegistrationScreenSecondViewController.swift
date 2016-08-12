//
//  SARegistrationScreenSecondViewController.swift
//  Savio
//
//  Created by Maheshwari on 11/08/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SARegistrationScreenSecondViewController: UIViewController,UITextFieldDelegate,PostCodeVerificationDelegate {
    
    @IBOutlet weak var registerScrollViewSecond: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var findAddressErrorLabel: UILabel!
    @IBOutlet weak var findAddressTextField: UITextField!
    @IBOutlet weak var findAddressButton: UIButton!
    @IBOutlet weak var selectAddressTextField: UITextField!
    @IBOutlet weak var addressLineOneErrolLabel: UILabel!
    @IBOutlet weak var addressLineOneTextField: UITextField!
    @IBOutlet weak var addressLineTwoTextField: UITextField!
    @IBOutlet weak var addressLineThreeTextField: UITextField!
    @IBOutlet weak var townErrorLabel: UILabel!
    @IBOutlet weak var townTextField: UITextField!
    @IBOutlet weak var countyErrorLabel: UILabel!
    @IBOutlet weak var countyTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var registerButtonBgView: UIView!
    let dropDown = DropDown()
    var arrayAddress = [String]()
    @IBOutlet weak var addressLineOneTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var contentViewHt: NSLayoutConstraint!
    @IBOutlet weak var addressLineErrorLabelTopSpace: NSLayoutConstraint!
    @IBOutlet weak var countyTextFieldTopspace: NSLayoutConstraint!
    @IBOutlet weak var addressLineOneErrorLabelTopSpace: NSLayoutConstraint!
    var activeTextField = UITextField()
    var userInfoDict : Dictionary<String,AnyObject> = [:]
    var objAnimView = ImageViewAnimation()
    
    @IBOutlet weak var addressDropDownButton: UIButton!
    
    @IBOutlet weak var townTextFieldTopSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()
        
        dropDown.anchorView = selectAddressTextField
        dropDown.backgroundColor = UIColor.whiteColor()
        dropDown.bottomOffset = CGPoint(x: 0, y:selectAddressTextField!.bounds.height)
        dropDown.selectionAction = { [unowned self] (index, item) in
            let str = item
            let fullNameArr = str.characters.split{$0 == ","}.map(String.init)
            
            self.addressLineOneTextField.text = fullNameArr[0]
            self.addressLineTwoTextField.text = fullNameArr[1]
            self.addressLineThreeTextField.text = fullNameArr[2]
            self.townTextField.text = fullNameArr[fullNameArr.count-2]
            self.countyTextField.text = fullNameArr[fullNameArr.count-1]
            
            self.addressLineOneTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
            self.addressLineTwoTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
            self.addressLineThreeTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
            self.townTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
            self.countyTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
            self.townTextFieldTopSpace.constant = 5
            self.countyTextFieldTopspace.constant = 5
            
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentViewHt.constant = backButton.frame.origin.y + backButton.frame.size.height + 40
        registerScrollViewSecond.contentSize = CGSizeMake(0, contentViewHt.constant + 20)
    }
    func setUpView()
    {

        contentViewHt.constant = backButton.frame.origin.y + backButton.frame.size.height + 40
        registerScrollViewSecond.contentSize = CGSizeMake(0, contentViewHt.constant + 20)
        
        findAddressTextField?.layer.cornerRadius = 2.0
        findAddressTextField?.layer.masksToBounds = true
        findAddressTextField?.layer.borderWidth=1.0
        let placeholder1 = NSAttributedString(string:"Postcode" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        findAddressTextField?.attributedPlaceholder = placeholder1;
        findAddressTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        
        selectAddressTextField?.layer.cornerRadius = 2.0
        selectAddressTextField?.layer.masksToBounds = true
        selectAddressTextField?.layer.borderWidth=1.0
        let placeholder2 = NSAttributedString(string:"Select address" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        selectAddressTextField?.attributedPlaceholder = placeholder2;
        selectAddressTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        
        addressLineOneTextField?.layer.cornerRadius = 2.0
        addressLineOneTextField?.layer.masksToBounds = true
        addressLineOneTextField?.layer.borderWidth=1.0
        let placeholder3 = NSAttributedString(string:"Address Line 1" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        addressLineOneTextField?.attributedPlaceholder = placeholder3;
        addressLineOneTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        addressLineTwoTextField?.layer.cornerRadius = 2.0
        addressLineTwoTextField?.layer.masksToBounds = true
        addressLineTwoTextField?.layer.borderWidth=1.0
        let placeholder4 = NSAttributedString(string:"Address Line 2" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        addressLineTwoTextField?.attributedPlaceholder = placeholder4;
        addressLineTwoTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        addressLineThreeTextField?.layer.cornerRadius = 2.0
        addressLineThreeTextField?.layer.masksToBounds = true
        addressLineThreeTextField?.layer.borderWidth=1.0
        let placeholder5 = NSAttributedString(string:"Address Line 3" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        addressLineThreeTextField?.attributedPlaceholder = placeholder5;
        addressLineThreeTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        townTextField?.layer.cornerRadius = 2.0
        townTextField?.layer.masksToBounds = true
        townTextField?.layer.borderWidth=1.0
        let placeholder6 = NSAttributedString(string:"Town" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        townTextField?.attributedPlaceholder = placeholder6;
        townTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        countyTextField?.layer.cornerRadius = 2.0
        countyTextField?.layer.masksToBounds = true
        countyTextField?.layer.borderWidth=1.0
        let placeholder7 = NSAttributedString(string:"County" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        countyTextField?.attributedPlaceholder = placeholder7;
        countyTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        
        findAddressButton.layer.cornerRadius = 2.0
        
        registerButtonBgView.layer.cornerRadius = 2.0
        registerButton.layer.cornerRadius = 2.0
        
        addressLineOneTopSpace.constant = 5
        townTextFieldTopSpace.constant = 5
        countyTextFieldTopspace.constant = 5
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func checkTextFieldValidation()->Bool{
        var errorFlag = false
        
        if findAddressTextField.text==""{
            errorFlag = true
            findAddressErrorLabel.text = "Don’t forget your postcode"
            findAddressTextField.layer.borderColor = UIColor.redColor().CGColor
            findAddressTextField.textColor = UIColor.redColor()
        }
        
        if addressLineOneTextField.text == ""
        {
            errorFlag = true
            addressLineOneErrolLabel.text = "Don’t forget your house number"
            addressLineOneTopSpace.constant = 21
            addressLineOneErrorLabelTopSpace.constant = 5
            selectAddressTextField.hidden = true
            addressLineOneTextField.layer.borderColor = UIColor.redColor().CGColor
            addressLineTwoTextField.layer.borderColor = UIColor.redColor().CGColor
            addressLineThreeTextField.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if townTextField.text == ""
        {
            errorFlag = true
            townErrorLabel.text = "Don’t forget your town"
            townTextFieldTopSpace.constant = 21
            townTextField.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if countyTextField.text == ""
        {
            errorFlag = true
            countyErrorLabel.text = "Don’t forget your county"
            countyTextFieldTopspace.constant = 21
            countyTextField.layer.borderColor = UIColor.redColor().CGColor
        }
        
        contentViewHt.constant = backButton.frame.origin.y + backButton.frame.size.height + 40
        registerScrollViewSecond.contentSize = CGSizeMake(0, contentViewHt.constant + 20)

        return errorFlag
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        activeTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        activeTextField = textField
        activeTextField.textColor = UIColor.blackColor()
        if(textField == selectAddressTextField)
        {
            self.showOrDismiss()
            return false
            
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        activeTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
    }
    
    
    func showOrDismiss(){
        if dropDown.hidden {
            dropDown.show()
        } else {
            dropDown.hide()
        }
    }
    
    @IBAction func findAddressButtonPressed(sender: AnyObject) {
        activeTextField.resignFirstResponder()
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        findAddressErrorLabel.text = ""
        let objGetAddressAPI: API = API()
        objGetAddressAPI.delegate = self
        let trimmedString = findAddressTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
        objGetAddressAPI.verifyPostCode(trimmedString)
    
    }
    
    @IBAction func registerButtonPressed(sender: AnyObject) {
        
        if(self.checkTextFieldValidation())
        {
            userInfoDict["address_1"] = addressLineOneTextField.text
             userInfoDict["address_2"] = addressLineOneTextField.text
             userInfoDict["address_3"] = addressLineOneTextField.text
             userInfoDict["town"] = addressLineOneTextField.text
             userInfoDict["county"] = addressLineOneTextField.text
             userInfoDict["post_code"] = findAddressTextField.text
             let udidDict : Dictionary<String,AnyObject>
            
            if let apnsDeviceToken = NSUserDefaults.standardUserDefaults().valueForKey("APNSTOKEN") as? NSString
            {
                udidDict = ["DEVICE_ID":Device.udid, "PNS_DEVICE_ID": apnsDeviceToken]
                
            } else {
                udidDict = ["DEVICE_ID":Device.udid, "PNS_DEVICE_ID": ""]
            }
            
            
            let udidArray: Array<Dictionary<String,AnyObject>> = [udidDict]
            userInfoDict["deviceRegistration"] =  udidArray
            userInfoDict["party_role"] =  4
            
            
                    print(userInfoDict)
        }

        contentViewHt.constant = backButton.frame.origin.y + backButton.frame.size.height + 40
        registerScrollViewSecond.contentSize = CGSizeMake(0, contentViewHt.constant + 20)
    }
    
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    var lastOffset: CGPoint = CGPointZero
    //Keyboard notification function
    @objc func keyboardWasShown(notification: NSNotification){
        //do stuff
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let visibleAreaHeight = UIScreen.mainScreen().bounds.height - 30 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
        lastOffset = (registerScrollViewSecond?.contentOffset)!
        let yOfTextField = activeTextField.frame.origin.y
        if (yOfTextField - (lastOffset.y)) > visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            registerScrollViewSecond?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //do stuff
        activeTextField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        registerScrollViewSecond?.setContentOffset(lastOffset, animated: true)
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func selectAddressArrowPressed(sender: AnyObject) {
        self.showOrDismiss()
    }
    func success(addressArray: Array<String>) {
        objAnimView.removeFromSuperview()
        dropDown.dataSource = addressArray
        arrayAddress = addressArray
        addressLineOneTopSpace.constant = 40
        selectAddressTextField.hidden = false
        addressDropDownButton.hidden = false
        addressLineOneErrolLabel.text = ""

        contentViewHt.constant = backButton.frame.origin.y + backButton.frame.size.height + 40
        registerScrollViewSecond.contentSize = CGSizeMake(0, contentViewHt.constant + 20)
    }
    
    func error(error: String) {
        objAnimView.removeFromSuperview()
        if(error == "Network not available")
        {
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            
        }
        else if(error == "That postcode doesn't look right")
        {
            findAddressErrorLabel.text = error
        }
        else
        {
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            
        }
    }
    
    func successResponseForRegistrationAPI(objResponse: Dictionary<String, AnyObject>) {
        
    }
    
    func errorResponseForRegistrationAPI(error: String) {
        
    }
}
