//
//  SAPaymentFlowViewController.swift
//  Savio
//
//  Created by Maheshwari on 13/09/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
import PassKit
import Stripe

class SAPaymentFlowViewController: UIViewController,AddNewSavingCardDelegate{
    
    @IBOutlet weak var cardNumView: NSLayoutConstraint!
    @IBOutlet weak var cardHoldersNameTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var expiryMonthYearTextField: UITextField!
    @IBOutlet weak var saveButtonBgView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var nametxtfieldTopSpace: NSLayoutConstraint!

    @IBOutlet weak var cardNumberErrorLabel: UILabel!
    @IBOutlet weak var cardErrorLabelHt: NSLayoutConstraint!
    @IBOutlet weak var cardNumberTextFieldTopSpace: NSLayoutConstraint!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var txtCardNum1: UITextField!
    @IBOutlet weak var txtCardNum2: UITextField!
    @IBOutlet weak var txtCardNum3: UITextField!
    @IBOutlet weak var txtCardNum4: UITextField!
    
    var objAnimView = ImageViewAnimation()
    var picker = MonthYearPickerView()
    var lastOffset: CGPoint = CGPointZero
    var activeTextField = UITextField()
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var errorFlag = false
    var request = PKPaymentRequest()
    var stripeCard = STPCard()
    var isFromGroupMemberPlan = false
    var isFromImpulseSaving = false
    var isFromEditUserInfo = false
    var doNotShowBackButton = true
    var addNewCard = false
    var arrayTextFields: Array<UITextField>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    
    func setUpView(){
        let objAPI = API()
//        if let _ = objAPI.getValueFromKeychainOfKey("savingPlanDict") as? Dictionary<String,AnyObject>
//        {
//            if let _ =  objAPI.getValueFromKeychainOfKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
//            {
//                
//                // self.navigationItem.setHidesBackButton(true, animated: false)
//                let leftBtnName = UIButton()
//                leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
//                leftBtnName.frame = CGRectMake(0, 0, 30, 30)
//                leftBtnName.addTarget(self, action: #selector(SAPaymentFlowViewController.backButtonPressd), forControlEvents: .TouchUpInside)
//                let leftBarButton = UIBarButtonItem()
//                leftBarButton.customView = leftBtnName
//                self.navigationItem.leftBarButtonItem = leftBarButton
//                
//                self.cancelButton.hidden = false
//                
//            }else {
//                self.navigationItem.setHidesBackButton(true, animated: false)
//            }
//        }
//        else {
//            // self.navigationItem.setHidesBackButton(true, animated: false)
//            let leftBtnName = UIButton()
//            leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
//            leftBtnName.frame = CGRectMake(0, 0, 30, 30)
//            leftBtnName.addTarget(self, action: #selector(SAPaymentFlowViewController.backButtonPressd), forControlEvents: .TouchUpInside)
//            let leftBarButton = UIBarButtonItem()
//            leftBarButton.customView = leftBtnName
//            self.navigationItem.leftBarButtonItem = leftBarButton
//            
//            self.cancelButton.hidden = false
//        }
//        
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("savingPlanDict") as? Dictionary<String,AnyObject>
        {
            if let _ =  NSUserDefaults.standardUserDefaults().objectForKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
            {
                
                // self.navigationItem.setHidesBackButton(true, animated: false)
                let leftBtnName = UIButton()
                leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
                leftBtnName.frame = CGRectMake(0, 0, 30, 30)
                leftBtnName.addTarget(self, action: #selector(SAPaymentFlowViewController.backButtonPressd), forControlEvents: .TouchUpInside)
                let leftBarButton = UIBarButtonItem()
                leftBarButton.customView = leftBtnName
                self.navigationItem.leftBarButtonItem = leftBarButton
                
                self.cancelButton.hidden = false
                
            }else {
                self.navigationItem.setHidesBackButton(true, animated: false)
            }
        }
        else {
            // self.navigationItem.setHidesBackButton(true, animated: false)
            let leftBtnName = UIButton()
            leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
            leftBtnName.frame = CGRectMake(0, 0, 30, 30)
            leftBtnName.addTarget(self, action: #selector(SAPaymentFlowViewController.backButtonPressd), forControlEvents: .TouchUpInside)
            let leftBarButton = UIBarButtonItem()
            leftBarButton.customView = leftBtnName
            self.navigationItem.leftBarButtonItem = leftBarButton
            
            self.cancelButton.hidden = false
        }
        

        cardNumberTextFieldTopSpace.constant = 5
        cardNumView.constant = 5
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        self.title = "Payment setup"
        
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
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:#selector(SAPaymentFlowViewController.doneBarButtonPressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SAPaymentFlowViewController.cancelBarButtonPressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar.items = [cancelButton,flexibleSpace,acceptButton]
        
        //Set datepickerview as input view and customtoolbar as inputAccessoryView to expiry date textfield
        expiryMonthYearTextField.inputView = picker
        expiryMonthYearTextField.inputAccessoryView = customToolBar
        
        //Set border to all card number textfield
        txtCardNum1?.layer.cornerRadius = 2.0
        txtCardNum1?.layer.masksToBounds = true
        txtCardNum1?.layer.borderWidth=1.0
        txtCardNum1?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        txtCardNum2?.layer.cornerRadius = 2.0
        txtCardNum2?.layer.masksToBounds = true
        txtCardNum2?.layer.borderWidth=1.0
        txtCardNum2?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        txtCardNum3?.layer.cornerRadius = 2.0
        txtCardNum3?.layer.masksToBounds = true
        txtCardNum3?.layer.borderWidth=1.0
        txtCardNum3?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        txtCardNum4?.layer.cornerRadius = 2.0
        txtCardNum4?.layer.masksToBounds = true
        txtCardNum4?.layer.borderWidth=1.0
        txtCardNum4?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        
        //Customization of cvv text field
        cvvTextField?.layer.cornerRadius = 2.0
        cvvTextField?.layer.masksToBounds = true
        cvvTextField?.layer.borderWidth=1.0
        let placeholder3 = NSAttributedString(string:"CVV" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        cvvTextField?.attributedPlaceholder = placeholder3;
        cvvTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //Add custom tool bar as input accessory view to card number textfield and cvv textfield
        let customToolBar2 = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:#selector(SAPaymentFlowViewController.doneBarButtonPressed))
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar2.items = [flexibleSpace1,doneButton]
        cardNumberTextField.inputAccessoryView = customToolBar2
        cvvTextField.inputAccessoryView = customToolBar2
        
        self.arrayTextFields = [txtCardNum1,
                                txtCardNum2,
                                txtCardNum3,
                                txtCardNum4]
        
        for tf: UITextField in arrayTextFields {
            tf.inputAccessoryView = customToolBar2
            
        }
        
        txtCardNum1.addTarget(self, action: #selector(SAPaymentFlowViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        txtCardNum2.addTarget(self, action: #selector(SAPaymentFlowViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        txtCardNum3.addTarget(self, action: #selector(SAPaymentFlowViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        txtCardNum4.addTarget(self, action: #selector(SAPaymentFlowViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

        //Customization of save button background view and save button
        saveButtonBgView.layer.cornerRadius = 2.0
        saveButton.layer.cornerRadius = 2.0
    }
    
    
    func backButtonPressd()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func doneBarButtonPressed()
    {
        if(activeTextField == expiryMonthYearTextField)
        {
            if(String(format: "%02d/%d", picker.month, picker.year) == "00/0")
            {
                let date = NSDate()
                let calendar = NSCalendar.currentCalendar()
                let components = calendar.components([.Day , .Month , .Year], fromDate: date)
                self.expiryMonthYearTextField.text = String(format: "%02d/%d", components.month, components.year%100)
                picker.year = components.year
                picker.month = components.month
            }
            else {
                self.expiryMonthYearTextField.text = String(format: "%02d/%d", picker.month, picker.year%100)
            }
        }
        activeTextField.resignFirstResponder()
    }
    
    func cancelBarButtonPressed()
    {
//        expiryMonthYearTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        
    
     /*   objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.navigationController?.view.addSubview(self.objAnimView)
        //Check validations of Textfields
        if(checkTextFieldValidation() == false)
        {
            let cardNum = txtCardNum1.text! + txtCardNum2.text! + txtCardNum3.text! + txtCardNum4.text!
            //Customize Stripe card
            stripeCard.cvc = cvvTextField.text
            //            stripeCard.number = cardNumberTextField.text
            stripeCard.number = cardNum
            stripeCard.expYear = UInt(picker.year)
            stripeCard.expMonth = UInt(picker.month)
            stripeCard.name = cardHoldersNameTextField.text
                        
            do {
                try stripeCard.validateCardReturningError()
                STPAPIClient.sharedClient().createTokenWithCard(stripeCard, completion: { (token: STPToken?, error: NSError?) -> Void in
                    print(token?.card?.type)
                    self.errorFlag = false
                    print(error?.localizedDescription)
                    if((error) != nil)
                    {
                        self.objAnimView.removeFromSuperview()
                        self.cardNumberErrorLabel.text = "The card number looks wrong"
                        self.cardNumberTextFieldTopSpace.constant = 35
                        self.cardNumView.constant = 35
                        if(error?.localizedDescription == "Your card\'s number is invalid")
                        {
                            self.setBarodrColor(UIColor.redColor())
                            //                        self.cardNumberTextField.layer.borderColor = UIColor.redColor().CGColor
                            //                        self.cardNumberTextField.textColor = UIColor.redColor()
                        } else if(error?.localizedDescription == "Your card\'s expiration year is invalid") {
                            self.expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
                            self.expiryMonthYearTextField.textColor = UIColor.redColor()
                            self.cardNumberErrorLabel.text = "Your card has expired"
                        }
                        else if(error?.localizedDescription == "Your card\'s expiration month is invalid") {
                            self.expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
                            self.expiryMonthYearTextField.textColor = UIColor.redColor()
                            self.cardNumberErrorLabel.text = "Your card has expired"
                        }
                        else if(error?.localizedDescription == "Your card\'s security code is invalid") {
                            self.cvvTextField.layer.borderColor = UIColor.redColor().CGColor
                            self.cvvTextField.textColor = UIColor.redColor()
                            self.cardNumberErrorLabel.text = "Your card's security code is invalid"
                        }
                        else if(error?.localizedDescription == "Missing required param: exp_month.") {
                            self.expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
                            self.expiryMonthYearTextField.textColor = UIColor.redColor()
                            self.cardNumberErrorLabel.text = "Your card's expiration month is invalid"
                        }
                    }
                    else {
                        if token?.card?.funding.rawValue == 0 {
                            print(token?.card?.cvc)
                            let objAPI = API()
                            let userInfoDict = NSUserDefaults.standardUserDefaults().objectForKey(kUserInfo) as! Dictionary<String,AnyObject>
//                            let userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
                            
                            var array : Array<Dictionary<String,AnyObject>> = []
                            //                    let dict1 : Dictionary<String,AnyObject> = ["cardHolderName":self.cardHoldersNameTextField.text!,"cardNumber":self.cardNumberTextField.text!,"cardExpMonth":self.picker.month,"cardExpDate":self.picker.year,"cvv":self.cvvTextField.text!]
                            let dict1 : Dictionary<String,AnyObject> = ["cardHolderName":self.cardHoldersNameTextField.text!,"cardNumber":cardNum,"cardExpMonth":self.picker.month,"cardExpDate":self.picker.year,"cvv":self.cvvTextField.text!]
                            //If user is adding new card call AddNewSavingCardDelegate
                            if(self.addNewCard == true)
                            {
//                                if let saveCardArray = objAPI.getValueFromKeychainOfKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
                            
                                if let saveCardArray = NSUserDefaults.standardUserDefaults().objectForKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
                                {
                                    array = saveCardArray
                                    var cardNumberArray : Array<String> = []
                                    for i in 0 ..< array.count{
                                        let newDict = array[i]
                                        cardNumberArray.append(newDict["cardNumber"] as! String)
                                    }
                                    //                            if(cardNumberArray.contains(self.cardNumberTextField.text!) == false)
                                    if(cardNumberArray.contains(cardNum) == false)
                                    {
                                        array.append(dict1)
                                        NSUserDefaults.standardUserDefaults().setValue(dict1, forKey: "activeCard")
//                                        NSUserDefaults.standardUserDefaults().setObject(array, forKey: "saveCardArray")
                                        NSUserDefaults.standardUserDefaults().synchronize()
                                        objAPI.storeValueInKeychainForKey("saveCardArray", value: array)
                                        
                                        
                                        let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict[kPartyID] as! NSNumber,"STRIPE_TOKEN":(token?.tokenId)!]
                                        objAPI.addNewSavingCardDelegate = self
                                        objAPI.addNewSavingCard(dict)
                                        self.addNewCard = false
                                    }
                                    else {
                                        self.objAnimView.removeFromSuperview()
                                        //show alert view controller if card is already added
                                        let alertController = UIAlertController(title: "Warning", message: "You have already added this card", preferredStyle:UIAlertControllerStyle.Alert)
                                        //alert view controll action method
                                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
                                        { action -> Void in
                                            self.navigationController?.popViewControllerAnimated(true)
                                            })
                                        self.presentViewController(alertController, animated: true, completion: nil)
                                    }
                                }
                                else {
                                    //      Call AddSavingCardDelegate
                                    let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict[kPartyID] as! NSNumber,"STRIPE_TOKEN":(token?.tokenId)!,kPTYSAVINGPLANID:NSUserDefaults.standardUserDefaults().valueForKey(kPTYSAVINGPLANID) as! NSNumber]
                                    objAPI.addSavingCardDelegate = self
                                    objAPI.addSavingCard(dict)
                                }
                            }
                            else {
                                array.append(dict1)
                                NSUserDefaults.standardUserDefaults().setValue(dict1, forKey: "activeCard")
//                                NSUserDefaults.standardUserDefaults().setObject(array, forKey: "saveCardArray")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                
                                objAPI.storeValueInKeychainForKey("saveCardArray", value: array)
                                
                                if(self.addNewCard == true)
                                {
                                    let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict[kPartyID] as! NSNumber,"STRIPE_TOKEN":(token?.tokenId)!]
                                    
                                    objAPI.addNewSavingCardDelegate = self
                                    objAPI.addNewSavingCard(dict)
                                    self.addNewCard = false
                                } else {
                                    let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict[kPartyID] as! NSNumber,"STRIPE_TOKEN":(token?.tokenId)!,kPTYSAVINGPLANID:NSUserDefaults.standardUserDefaults().valueForKey(kPTYSAVINGPLANID) as! NSNumber]
                                    print(dict)
                                    objAPI.addSavingCardDelegate = self
                                    objAPI.addSavingCard(dict)
                                }
                            }
                        }
                        else{
                            self.objAnimView.removeFromSuperview()
                            self.cardNumberErrorLabel.text = "Please use debit card only."
                            self.cardNumberTextFieldTopSpace.constant = 35
                            self.cardNumView.constant = 35
                        }
                    }
                })

            } catch let underlyingError as NSError?{
               print("Error info: \(underlyingError?.localizedDescription)")
                self.objAnimView.removeFromSuperview()
                self.cardNumberErrorLabel.text = underlyingError?.localizedDescription
                self.cardNumberTextFieldTopSpace.constant = 35
                self.cardNumView.constant = 35
            }
            
//            var underlyingError: NSError?
//            stripeCard.validateCardReturningError(&underlyingError)
//            if underlyingError != nil {
//               
//                return
//            }
            
        }
        else {
            errorFlag = false
            objAnimView.removeFromSuperview()
        }*/
    }
    
    func setBarodrColor(borderColor: UIColor) {
        txtCardNum1.layer.borderColor = borderColor.CGColor
        txtCardNum1.textColor = borderColor
        txtCardNum2.layer.borderColor = borderColor.CGColor
        txtCardNum2.textColor = borderColor
        txtCardNum3.layer.borderColor = borderColor.CGColor
        txtCardNum3.textColor = borderColor
        txtCardNum4.layer.borderColor = borderColor.CGColor
        txtCardNum4.textColor = borderColor
    }
    
    func checkTextFieldValidation()->Bool
    {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
        //Validations for card holders name text field
        if(cardHoldersNameTextField.text?.characters.count == 0 && cardHoldersNameTextField.text?.characters.count == 0) {
            nametxtfieldTopSpace.constant = 24
            nameErrorLabel.text = "Enter name on card"
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
            errorFlag = true
        }
        else if (self.checkTextFieldContentOnlyNumber(cardHoldersNameTextField.text!) == true) {
            nametxtfieldTopSpace.constant = 40
            nameErrorLabel.text = "Your cardholder name should only contain letters"
            errorFlag = true
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
        }
        else if (self.checkTextFieldContentSpecialChar(cardHoldersNameTextField.text!)) {
            nametxtfieldTopSpace.constant = 40
            nameErrorLabel.text = "Name should not contain special characters"
            errorFlag = true
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
        }
        else if cardHoldersNameTextField.text?.characters.count > 50 {
            nametxtfieldTopSpace.constant = 40
            nameErrorLabel.text = kLongName
            errorFlag = true
            cardHoldersNameTextField.layer.borderColor = UIColor.redColor().CGColor
            cardHoldersNameTextField.textColor = UIColor.redColor()
        }
        else {
            nameErrorLabel.text = ""
            nametxtfieldTopSpace.constant = 22
        }
        
        //Validations for card number text field
        
        let cardNumStr = txtCardNum1.text! + txtCardNum2.text! + txtCardNum3.text! + txtCardNum4.text!
        if cardNumStr == "" {
            cardNumberErrorLabel.text = "The card number looks wrong"
            cardNumberTextFieldTopSpace.constant = 35
            cardNumView.constant = 35
            errorFlag = true
            self.setBarodrColor(UIColor.redColor())
        }
        if cardNumStr.characters.count < 16 {
            cardNumberErrorLabel.text = "The card number looks wrong"
            cardNumberErrorLabel.hidden = false
            cardNumberTextFieldTopSpace.constant = 35
            cardNumView.constant = 35
            errorFlag = true
             self.setBarodrColor(UIColor.redColor())
        }else if self.expiryMonthYearTextField.text == "" {
            cardNumberErrorLabel.text = "Some card details are missing"
            cardNumberErrorLabel.hidden = false
            cardNumberTextFieldTopSpace.constant = 35
            cardNumView.constant = 35
            errorFlag = true
        }else if self.cvvTextField.text == "" {
            cardNumberErrorLabel.text = "Some card details are missing"
            cardNumberErrorLabel.hidden = false
            cardNumberTextFieldTopSpace.constant = 35
            cardNumView.constant = 35
            errorFlag = true
        }
//        else {
//            cardNumberTextFieldTopSpace.constant = 5
//            cardNumView.constant = 5
//            cardNumberErrorLabel.text = ""
//        }
        
        
   /*     if cardNumberTextField.text == "" {
            cardNumberErrorLabel.text = "Enter valid card details"
            cardNumberTextFieldTopSpace.constant = 35
            cardNumView.constant = 35
            errorFlag = true
            cardNumberTextField.layer.borderColor = UIColor.redColor().CGColor
            cardNumberTextField.textColor = UIColor.redColor()
        }
        if cardNumberTextField.text?.characters.count < 16 {
            cardNumberErrorLabel.text = "Enter valid card details"
            cardNumberErrorLabel.hidden = false
            cardNumberTextFieldTopSpace.constant = 35
            cardNumView.constant = 35
            errorFlag = true
            cardNumberTextField.layer.borderColor = UIColor.redColor().CGColor
            cardNumberTextField.textColor = UIColor.redColor()
        }
        else {
            cardNumberTextFieldTopSpace.constant = 5
            cardNumView.constant = 5
            cardNumberErrorLabel.text = ""
        }*/
        
        //Validations for expiry date text field and cvv text field
        else if(expiryMonthYearTextField.text == "" || cvvTextField.text == "")
        {
            cardNumberErrorLabel.text = "Enter valid expire month & year"
            cardNumberTextFieldTopSpace.constant = 35
            cardNumView.constant = 35
            errorFlag = true
            cvvTextField.layer.borderColor = UIColor.redColor().CGColor
            cvvTextField.textColor = UIColor.redColor()
            expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
            expiryMonthYearTextField.textColor = UIColor.redColor()
        }
            
        else if(expiryMonthYearTextField.text == String(format:"%d/%d",components.month,components.year))
        {
            cardNumberErrorLabel.text = "The card number looks wrong"
            cardNumberTextFieldTopSpace.constant = 35
            cardNumView.constant = 35
            errorFlag = true
            expiryMonthYearTextField.layer.borderColor = UIColor.redColor().CGColor
            expiryMonthYearTextField.textColor = UIColor.redColor()
        }
        else if(cvvTextField.text?.characters.count < 3)
        {
            cardNumberErrorLabel.text = "Enter valid CVV number"
            cardNumberTextFieldTopSpace.constant = 35
            cardNumView.constant = 35
            errorFlag = true
            cvvTextField.layer.borderColor = UIColor.redColor().CGColor
            cvvTextField.textColor = UIColor.redColor()
        }
        else {
//            cardNumberErrorLabel.text = ""
            cardNumberTextFieldTopSpace.constant = 5
            cardNumView.constant = 5
            cardNumberErrorLabel.text = ""
        }
        return errorFlag
    }
    
    func checkTextFieldContentOnlyNumber(str:String)->Bool{
        let set = NSCharacterSet.decimalDigitCharacterSet()
//        if (str.rangeOfCharacterFromSet(set) != nil) {
//            return true
//        }
//        else {
//            return false
//        }
        
        return (str.rangeOfCharacterFromSet(set) != nil)

    }
    
    func checkTextFieldContentCharacters(str:String)->Bool{
        let set = NSCharacterSet.letterCharacterSet()
//        if (str.rangeOfCharacterFromSet(set) != nil) {
//            return true
//        }
//        else {
//            return false
//        }
        return (str.rangeOfCharacterFromSet(set) != nil)

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
    
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //UITextField delegate method
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
        activeTextField.textColor = UIColor.blackColor()
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
    
    
    func textFieldDidChange(textField: UITextField) {
        
        let text = textField.text
        var tag = textField.tag
        if text?.characters.count == 4 {
            for tf: UITextField in arrayTextFields {
                if tf.tag == tag && tag != 3 && text?.characters.count >= 4{
                    let tfNext = arrayTextFields[tag + 1]
                    tfNext.becomeFirstResponder()
                    break
                }
                 if tag == 3 && text?.characters.count >= 4 {
                    textField.resignFirstResponder()
                    break
                }
            }
            
        }else if text?.characters.count == 0 {
            
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
        else {
            
        }
    }

    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        textField.textColor = UIColor.blackColor()
         textField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor

        if(textField == txtCardNum1 || textField == txtCardNum2 || textField == txtCardNum3 || textField == txtCardNum4) {
           
            let currentCharacterCount = textField.text?.characters.count ?? 0
            let newLength = currentCharacterCount + string.characters.count
            if (newLength > 4) {
                return false;
            }
        }
        if(textField == cardNumberTextField)
        {
            let newLength = text.utf16.count + string.utf16.count - range.length
            return newLength <= 16
        }
        else if(textField == cvvTextField){
            let newLength = text.utf16.count + string.utf16.count - range.length
            return newLength <= 3
        }
        else {
            return true
        }
        
    }
    //Register keyboard notification
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SAPaymentFlowViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SAPaymentFlowViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
        let yOfTextField = activeTextField.frame.height + 280
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        objAnimView.removeFromSuperview()
    }
    
    // MARK: - API Response
    //Success response of AddSavingCardDelegate
/*    func successResponseForAddSavingCardDelegateAPI(objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String{
            if(message == "Successful")
            {
                if(objResponse["stripeCustomerStatusMessage"] as? String == "Customer Card detail Added Succeesfully")
                {
                    if(self.isFromGroupMemberPlan == true)
                    {
                        //Navigate to SAThankYouViewController
                        self.isFromGroupMemberPlan = false
                        NSUserDefaults.standardUserDefaults().setValue(1, forKey: kGroupMemberPlan)
                        NSUserDefaults.standardUserDefaults().synchronize()
                        let objThankyYouView = SAThankYouViewController()
                        self.navigationController?.pushViewController(objThankyYouView, animated: true)
                    }
                    else {
                        let objSummaryView = SASavingSummaryViewController()
                        self.navigationController?.pushViewController(objSummaryView, animated: true)
                    }
                }
            }
        }
    }
    
    //Error response of AddSavingCardDelegate
    func errorResponseForAddSavingCardDelegateAPI(error: String) {
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    */
    //Success response of AddNewSavingCardDelegate
    func successResponseForAddNewSavingCardDelegateAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        
        if let message = objResponse["message"] as? String{
            if(message == "Successfull")
            {
                if(self.isFromGroupMemberPlan == true)
                {
                    //Navigate to showing group progress
                    self.isFromGroupMemberPlan = false
                    NSUserDefaults.standardUserDefaults().setValue(1, forKey: kGroupMemberPlan)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    let objThankyYouView = SAThankYouViewController()
                    self.navigationController?.pushViewController(objThankyYouView, animated: true)
                    
                }else if(self.isFromImpulseSaving){
                    let objAPI = API()
                    
                    var newDict : Dictionary<String,AnyObject> = [:]
                    let userInfoDict = NSUserDefaults.standardUserDefaults().objectForKey(kUserInfo) as! Dictionary<String,AnyObject>
//                    let userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
                    let cardDict = objResponse["card"] as? Dictionary<String,AnyObject>
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    newDict["STRIPE_CUSTOMER_ID"] = cardDict!["customer"]
                    newDict["PAYMENT_DATE"] = dateFormatter.stringFromDate(NSDate())
                    newDict[kAMOUNT] = NSUserDefaults.standardUserDefaults().valueForKey("ImpulseAmount")
                    newDict["PAYMENT_TYPE"] = "debit"
                    newDict["AUTH_CODE"] = "test"
                    newDict[kPTYSAVINGPLANID] = NSUserDefaults.standardUserDefaults().valueForKey(kPTYSAVINGPLANID) as! NSNumber
                    print(newDict)
                    objAPI.impulseSaving(newDict)
                }
                else if(isFromEditUserInfo)
                {
                    objAnimView.removeFromSuperview()
                    let objSavedCardView = SASaveCardViewController()
                    objSavedCardView.isFromEditUserInfo = true
                    objSavedCardView.isFromImpulseSaving = false
                    objSavedCardView.showAlert = true
                    self.navigationController?.pushViewController(objSavedCardView, animated: true)
                }
                else {
                    objAnimView.removeFromSuperview()
                    let objSummaryView = SASavingSummaryViewController()
                    self.navigationController?.pushViewController(objSummaryView, animated: true)
                }
            }
        }
    }
    
    //error response of AddNewSavingCardDelegate
    func errorResponseForAddNewSavingCardDelegateAPI(error: String) {
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
}

