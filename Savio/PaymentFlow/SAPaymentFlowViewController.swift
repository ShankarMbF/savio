//
//  SAPaymentFlowViewController.swift
//  Savio
//
//  Created by Maheshwari on 13/09/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit


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
    @IBOutlet weak var cvvTextFieldTopSpace: NSLayoutConstraint!
    @IBOutlet weak var expiryDateTextFieldTopSpace: NSLayoutConstraint!
    
    var picker = MonthYearPickerView()
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var errorFlag = true
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
        
        cvvTextFieldTopSpace.constant = 5
        expiryDateTextFieldTopSpace.constant = 5
        cardNumberTextFieldTopSpace.constant = 5
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        /*
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("backButtonPress"), forControlEvents: .TouchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        self.title = "Payment setup"
        //set Navigation right button nav-heart
        
      
        let btnName = UIButton()
        //        btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = str
            wishListArray = (NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>)!
            
            if(wishListArray.count > 0)
            {
                
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
                
            }
            btnName.setTitle(String(format:"%d",wishListArray.count), forState: UIControlState.Normal)
            
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
  */
        
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
        
        //Set datepickerview as input view and customtoolbar as inputAccessoryViewto DOB textfield
        expiryMonthYearTextField.inputView = picker
        expiryMonthYearTextField.inputAccessoryView = customToolBar
        
        
        //Customization of cvv text field
        cvvTextField?.layer.cornerRadius = 2.0
        cvvTextField?.layer.masksToBounds = true
        cvvTextField?.layer.borderWidth=1.0
        let placeholder3 = NSAttributedString(string:"CVV" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        cvvTextField?.attributedPlaceholder = placeholder3;
        cvvTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //Customization of save button background view and save button
        saveButtonBgView.layer.cornerRadius = 2.0
        saveButton.layer.cornerRadius = 2.0
    }
    
    func doneBarButtonPressed()
    {
    
        self.expiryMonthYearTextField.text = String(format: "%02d/%d", picker.month, picker.year)

        expiryMonthYearTextField.resignFirstResponder()
    }
    
    func cancelBarButtonPressed()
    {

        expiryMonthYearTextField.resignFirstResponder()
    }
    //MARK: Bar button action
    //function invoke when user tapping on back button
    func backButtonPress()  {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func heartBtnClicked(){
        //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
        if wishListArray.count>0{
            NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAWishListViewController")
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        self.checkTextFieldValidation()
    }
    
    func checkTextFieldValidation()
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
        else if(cardNumberTextField.text?.characters.count < 16 || cardNumberTextField.text?.characters.count > 16) {
            cardNumberErrorLabel.text = "Enter valid card details"
            if(UIScreen.mainScreen().bounds.width == 320)
            {
                cardNumberTextFieldTopSpace.constant = 35
                
            }
            else
            {
                cardNumberTextFieldTopSpace.constant = 5
            }
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
            expiryDateTextFieldTopSpace.constant = 5
            cvvTextFieldTopSpace.constant = 5
        }
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
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
