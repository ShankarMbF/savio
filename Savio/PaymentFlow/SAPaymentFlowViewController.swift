//
//  SAPaymentFlowViewController.swift
//  Savio
//
//  Created by Maheshwari on 13/09/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
import PassKit

class SAPaymentFlowViewController: UIViewController {
    
    @IBOutlet weak var cardHoldersNameTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var expiryMonthYearTextField: UITextField!
    @IBOutlet weak var saveButtonBgView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var cardNumberErrorLabel: UILabel!
    @IBOutlet weak var cardErrorLabelHt: NSLayoutConstraint!
    @IBOutlet weak var cardNumberTextFieldTopSpace: NSLayoutConstraint!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var contentview: UIView!
    
    var picker = MonthYearPickerView()
    var lastOffset: CGPoint = CGPointZero
    var activeTextField = UITextField()
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var errorFlag = true
    var request = PKPaymentRequest()
    var stripeCard = STPCard()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView(){
        cardNumberTextFieldTopSpace.constant = 5
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        //Customization of card holders name text field
        cardHoldersNameTextField?.layer.cornerRadius = 2.0
        cardHoldersNameTextField?.layer.masksToBounds = true
        cardHoldersNameTextField?.layer.borderWidth=1.0
        let placeholder = NSAttributedString(string:"Name on Card" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        cardHoldersNameTextField?.attributedPlaceholder = placeholder;
        cardHoldersNameTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //Customization of card number text field
        cardNumberTextField?.layer.cornerRadius = 2.0
        cardNumberTextField?.layer.masksToBounds = true
        cardNumberTextField?.layer.borderWidth=1.0
        let placeholder1 = NSAttributedString(string:"Card Number" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        cardNumberTextField?.attributedPlaceholder = placeholder1;
        cardNumberTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        
        //Customization of expiry month year text field
        expiryMonthYearTextField?.layer.cornerRadius = 2.0
        expiryMonthYearTextField?.layer.masksToBounds = true
        expiryMonthYearTextField?.layer.borderWidth=1.0
        let placeholder2 = NSAttributedString(string:"MM/YY" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        expiryMonthYearTextField?.attributedPlaceholder = placeholder2;
        expiryMonthYearTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //add custom tool bar for UIDatePickerView
        let customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelBarButtonPressed"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar.items = [cancelButton,flexibleSpace,acceptButton]
        
        //Set datepickerview as input view and customtoolbar as inputAccessoryView to expiry date textfield
        expiryMonthYearTextField.inputView = picker
        expiryMonthYearTextField.inputAccessoryView = customToolBar
        
        
        //Customization of cvv text field
        cvvTextField?.layer.cornerRadius = 2.0
        cvvTextField?.layer.masksToBounds = true
        cvvTextField?.layer.borderWidth=1.0
        let placeholder3 = NSAttributedString(string:"CVV" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        cvvTextField?.attributedPlaceholder = placeholder3;
        cvvTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //Add custom tool bar as input accessory view to card number textfield and cvv textfield
        let customToolBar2 = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar2.items = [flexibleSpace1,doneButton]
        cardNumberTextField.inputAccessoryView = customToolBar2
        cvvTextField.inputAccessoryView = customToolBar2
        
        //Customization of save button background view and save button
        saveButtonBgView.layer.cornerRadius = 2.0
        saveButton.layer.cornerRadius = 2.0
    }
    
    func doneBarButtonPressed()
    {
        if(activeTextField == expiryMonthYearTextField)
        {
            self.expiryMonthYearTextField.text = String(format: "%02d/%d", picker.month, picker.year)
        }
        activeTextField.resignFirstResponder()
    }
    
    func cancelBarButtonPressed()
    {
        expiryMonthYearTextField.resignFirstResponder()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if(checkTextFieldValidation() == false)
        {
            self.errorFlag = true
            stripeCard.cvc = cvvTextField.text
            stripeCard.number = cardNumberTextField.text
            stripeCard.expYear = UInt(picker.year)
            stripeCard.expMonth = UInt(picker.month)
            
            STPAPIClient.sharedClient().createTokenWithCard(stripeCard, completion: { (token: STPToken?, error: NSError?) -> Void in
                print(token)
                print(error?.localizedDescription)
                if((error) != nil)
                {
                    self.cardNumberErrorLabel.text = "Enter valid card details"
                    self.cardNumberTextFieldTopSpace.constant = 35
                    self.errorFlag = true
                    if(error?.localizedDescription == "Your card\'s number is invalid")
                    {
                        self.cardNumberTextField.layer.borderColor = UIColor.redColor().CGColor
                        self.cardNumberTextField.textColor = UIColor.redColor()
                    } else if(error?.localizedDescription == "Your card\'s expiration year is invalid") {
                        self.expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
                        self.expiryMonthYearTextField.textColor = UIColor.redColor()
                    }
                    else if(error?.localizedDescription == "Your card\'s expiration month is invalid") {
                        self.expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
                        self.expiryMonthYearTextField.textColor = UIColor.redColor()
                    }
                    else if(error?.localizedDescription == "Your card\'s security code is invalid") {
                        self.cvvTextField.layer.borderColor = UIColor.redColor().CGColor
                        self.cvvTextField.textColor = UIColor.redColor()
                    }
                }
                else {
                    let objSummaryView = SASavingSummaryViewController()
                    self.navigationController?.pushViewController(objSummaryView, animated: true)
                }
            })
        }
        else {
            errorFlag = false
        }
    }
    
    func checkTextFieldValidation()->Bool
    {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
        //Validations for card holders name text field
        if(cardHoldersNameTextField.text?.characters.count == 0 && cardHoldersNameTextField.text?.characters.count == 0) {
            nameErrorLabel.text = "Enter name on card"
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
            errorFlag = true
        }
        else if (self.checkTextFieldContentOnlyNumber(cardHoldersNameTextField.text!) == true) {
            nameErrorLabel.text = "Name should contain alphabets only"
            errorFlag = true
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
        }
        else if (self.checkTextFieldContentSpecialChar(cardHoldersNameTextField.text!)) {
            nameErrorLabel.text = "Name should not contain special characters"
            errorFlag = true
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
        }
        else if cardHoldersNameTextField.text?.characters.count > 50 {
            nameErrorLabel.text = "Wow, that’s such a long name we can’t save it"
            errorFlag = true
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
        }
        else {
            nameErrorLabel.text = ""
        }
        
        //Validations for card number text field
        if cardNumberTextField.text == "" {
            cardNumberErrorLabel.text = "Enter valid card details"
            cardNumberTextFieldTopSpace.constant = 35
            errorFlag = true
            cardNumberTextField.layer.borderColor = UIColor.redColor().CGColor
            cardNumberTextField.textColor = UIColor.redColor()
        }
        else {
            cardNumberTextFieldTopSpace.constant = 5
            cardNumberErrorLabel.text = ""
        }
        
        //Validations for expiry date text field and cvv text field
        if(expiryMonthYearTextField.text == "" || cvvTextField.text == "")
        {
            cardNumberErrorLabel.text = "Enter valid card details"
            cardNumberTextFieldTopSpace.constant = 35
            errorFlag = true
            cvvTextField.layer.borderColor = UIColor.redColor().CGColor
            cvvTextField.textColor = UIColor.redColor()
            expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
            expiryMonthYearTextField.textColor = UIColor.redColor()
        }
            
        else if(expiryMonthYearTextField.text == String(format:"%d/%d",components.month,components.year))
        {
            cardNumberErrorLabel.text = "Enter valid card details"
            cardNumberTextFieldTopSpace.constant = 35
            errorFlag = true
            expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
            expiryMonthYearTextField.textColor = UIColor.redColor()
        }
        else {
            cardNumberErrorLabel.text = ""
        }
        
        return errorFlag
    }
    
    func checkTextFieldContentOnlyNumber(str:String)->Bool{
        let set = NSCharacterSet.decimalDigitCharacterSet()
        if (str.rangeOfCharacterFromSet(set) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    func checkTextFieldContentCharacters(str:String)->Bool{
        let set = NSCharacterSet.letterCharacterSet()
        if (str.rangeOfCharacterFromSet(set) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    func phoneNumberValidation(value: String) -> Bool {
        let charcter  = NSCharacterSet(charactersInString: "0123456789").invertedSet
        var filtered:NSString!
        let inputString:NSArray = value.componentsSeparatedByCharactersInSet(charcter)
        filtered = inputString.componentsJoinedByString("")
        return  value == filtered
    }
    
    
    func checkTextFieldContentSpecialChar(str:String)->Bool{
        let characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "~!@#$%^&*()_-+={}|\\;:'\",.<>*/")
        if (str.rangeOfCharacterFromSet(characterSet) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    
    @IBAction func switchChanged(sender: UISwitch) {
        if(sender.on)
        {
            print("switch is on")
        } else {
            print("switch is off")
        }
    }
    
    //UITextField delegate method
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
        activeTextField.textColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        self.registerForKeyboardNotifications()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField.resignFirstResponder()
        activeTextField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        self.removeKeyboardNotification()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        self.removeKeyboardNotification()
        return true
    }
    
    //Register keyboard notification
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Keyboard notification function
    @objc func keyboardWasShown(notification: NSNotification){
        //do stuff
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let visibleAreaHeight = UIScreen.mainScreen().bounds.height - 30 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
        lastOffset = (scrlView?.contentOffset)!
        let yOfTextField = activeTextField.frame.height
        if (yOfTextField - (lastOffset.y)) > visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            scrlView?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //do stuff
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        scrlView?.setContentOffset(CGPointZero, animated: true)
    }
    
    
}

