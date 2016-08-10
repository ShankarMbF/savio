//
//  SARegistrationScreenOneViewController.swift
//  Savio
//
//  Created by Maheshwari on 10/08/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SARegistrationScreenOneViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var registerOneScrollView: UIScrollView!
    @IBOutlet weak var titleOrNameErrorLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameErrorLabel: UILabel!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var dateOfBirthErrorLabel: UILabel!
    @IBOutlet weak var mobileNumberErrorLabel: UILabel!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var whyDoWeNeedInformationButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    let dropDown = DropDown()
    
    @IBOutlet weak var topSpaceForSurnameTextField: NSLayoutConstraint!
    
    @IBOutlet weak var topSpaceForMobileNumberTextField: NSLayoutConstraint!
    @IBOutlet weak var titleOrNameLabelHt: NSLayoutConstraint!
    @IBOutlet weak var surnameErrorLabelHt: NSLayoutConstraint!
    
    @IBOutlet weak var dateOfBirthErrolLabelHt: NSLayoutConstraint!
    
    @IBOutlet weak var mobileNumberErrorLabelHt: NSLayoutConstraint!
    
    @IBOutlet weak var emailLabelErrorHt: NSLayoutConstraint!
    
    @IBOutlet weak var topspacefieldForEmailTextField: NSLayoutConstraint!
    @IBOutlet weak var topSpaceForDateOfBirthTextField: NSLayoutConstraint!
    @IBOutlet weak var nextButtonBgView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setUpView()
    }
    
    func setUpView()
    {
        titleTextField?.layer.cornerRadius = 2.0
        titleTextField?.layer.masksToBounds = true
        titleTextField?.layer.borderWidth=1.0
        let placeholder = NSAttributedString(string:"Title" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        titleTextField?.attributedPlaceholder = placeholder;
        titleTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        dropDown.anchorView = titleTextField
        dropDown.backgroundColor = UIColor.whiteColor()
        dropDown.dataSource = [
            "Mr",
            "Miss",
            "Mrs"]
        
        dropDown.bottomOffset = CGPoint(x: 0, y:titleTextField!.bounds.height)
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.titleTextField?.text = item
            
        }
        
        
        nameTextField?.layer.cornerRadius = 2.0
        nameTextField?.layer.masksToBounds = true
        nameTextField?.layer.borderWidth=1.0
        let placeholder1 = NSAttributedString(string:"Name" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        nameTextField?.attributedPlaceholder = placeholder1;
        nameTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        surnameTextField?.layer.cornerRadius = 2.0
        surnameTextField?.layer.masksToBounds = true
        surnameTextField?.layer.borderWidth=1.0
        let placeholder2 = NSAttributedString(string:"Surname" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        surnameTextField?.attributedPlaceholder = placeholder2;
        surnameTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        dateOfBirthTextField?.layer.cornerRadius = 2.0
        dateOfBirthTextField?.layer.masksToBounds = true
        dateOfBirthTextField?.layer.borderWidth=1.0
        let placeholder3 = NSAttributedString(string:"Date of birth" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        dateOfBirthTextField?.attributedPlaceholder = placeholder3;
        dateOfBirthTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        mobileNumberTextField?.layer.cornerRadius = 2.0
        mobileNumberTextField?.layer.masksToBounds = true
        mobileNumberTextField?.layer.borderWidth=1.0
        let placeholder4 = NSAttributedString(string:"Mobile number" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        mobileNumberTextField?.attributedPlaceholder = placeholder4;
        mobileNumberTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        emailTextField?.layer.cornerRadius = 2.0
        emailTextField?.layer.masksToBounds = true
        emailTextField?.layer.borderWidth=1.0
        let placeholder5 = NSAttributedString(string:"Email" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        emailTextField?.attributedPlaceholder = placeholder5;
        emailTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        nextButton?.layer.cornerRadius = 2.0
        nextButtonBgView.layer.cornerRadius = 2.0
        
        topspacefieldForEmailTextField.constant = 5
        topSpaceForSurnameTextField.constant = 5
        topSpaceForDateOfBirthTextField.constant = 5
        topSpaceForMobileNumberTextField.constant = 5
        
        
    }
    
    func checkTextFieldValidation()->Bool{
        
        var errorFlag = false
        if (self.checkTextFieldContentOnlyNumber(nameTextField.text!) == true){
            titleOrNameErrorLabel.text = "Name should contain alphabets only"
            if nameTextField.text?.characters.count==0 {
                titleOrNameErrorLabel.text = "Please select a title and name should contain alphabets only"
                errorFlag = true
            }
        }
        else if (self.checkTextFieldContentSpecialChar(nameTextField.text!)){
            titleOrNameErrorLabel.text = "Name should not contain special characters"
            titleOrNameErrorLabel.text = "Please select a title and name should not contain special characters"
            errorFlag = true
        }
            
        else if nameTextField.text?.characters.count > 50{
            titleOrNameErrorLabel.text = "Wow, that’s such a long name we can’t save it"
            errorFlag = true
        }
            
        else if(nameTextField.text?.characters.count == 0 && nameTextField.text?.characters.count == 0){
            titleOrNameErrorLabel.text = "We need to know your title and name"
            nameTextField.layer.borderColor = UIColor.redColor().CGColor
            nameTextField.layer.borderColor = UIColor.redColor().CGColor
            errorFlag = true
            
        }
        else if nameTextField.text == ""{
            titleOrNameErrorLabel.text = "Please select a title"
            errorFlag = true
            
        }
        else if nameTextField.text == ""{
            titleOrNameErrorLabel.text = "We need to know what to call you"
            errorFlag = true
        }
        
        
        
        if surnameTextField.text=="" {
            
            surnameErrorLabel.text = "We need to know your surname"
            topSpaceForSurnameTextField.constant = 21
            errorFlag = true
        }
        else if(surnameTextField.text?.characters.count>50){
            surnameErrorLabel.text = "Wow, that’s such a long name we can’t save it"
            topSpaceForSurnameTextField.constant = 21
            errorFlag = true
        }
        else if(self.checkTextFieldContentOnlyNumber(surnameTextField.text!) == true){
            surnameErrorLabel.text = "Surname should contain alphabets only"
            topSpaceForSurnameTextField.constant = 21
            errorFlag = true
        }
        else if checkTextFieldContentSpecialChar(surnameTextField.text!){
            surnameErrorLabel.text = "Surname should not contain special characters"
            topSpaceForSurnameTextField.constant = 21
            errorFlag = true
        }
        
        
        
        if(dateOfBirthTextField.text == "")
        {
            topSpaceForDateOfBirthTextField.constant = 21
            dateOfBirthErrorLabel.text = "Please enter DOB"
            errorFlag = true
        }
        
        
        if mobileNumberTextField.text == ""{
            
            mobileNumberErrorLabel.text = "Don't forget your mobile number"
            topSpaceForMobileNumberTextField.constant = 21
            errorFlag = true
        }
            
        else  if(self.checkTextFieldContentCharacters(mobileNumberTextField.text!) == true || self.phoneNumberValidation(mobileNumberTextField.text!)==false){
            mobileNumberErrorLabel.text = "That mobile number doesn’t look right"
            topSpaceForMobileNumberTextField.constant = 21
            errorFlag = true
        }
        else if(mobileNumberTextField.text?.characters.count < 10)
        {
            mobileNumberErrorLabel.text = "That mobile number should be greater than 10 digits"
            topSpaceForMobileNumberTextField.constant = 21
            errorFlag = true
        }
        else if(mobileNumberTextField.text?.characters.count > 16)
        {
            mobileNumberErrorLabel.text = "That mobile number should be of 15 digits"
            topSpaceForMobileNumberTextField.constant = 21
            errorFlag = true
        }
        
        
        
        if emailTextField.text==""{
            
            topspacefieldForEmailTextField.constant = 21
            emailErrorLabel.text = "Don't forget your email address"
            errorFlag = true
        }
        else  if emailTextField.text?.characters.count>0 && (self.isValidEmail(emailTextField.text!)==false){
            topspacefieldForEmailTextField.constant = 21
            emailErrorLabel.text = "That email address doesn’t look right"
            errorFlag = true
            
        }
        
        return errorFlag
        
    }
    
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        
        if(self.checkTextFieldValidation())
        {
            print("go to next")
        }
        else
        {
            print("error")
        }
    }
    @IBAction func backButtonPressed(sender: AnyObject) {
    }
    @IBAction func whyDoWeThisInfoButtonPressed(sender: AnyObject) {
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if(textField == titleTextField)
        {
            self.showOrDismiss()
            return false
            
        }
        return true
    }
    
    func showOrDismiss(){
        if dropDown.hidden {
            dropDown.show()
        } else {
            dropDown.hide()
        }
    }
    
    @IBAction func clickeOnDropDownArrow(sender:UIButton){
        self.showOrDismiss()
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showOrHideDropDownButtonPressed(sender: AnyObject) {
        self.showOrDismiss()
    }
    
    //Function checking textfield content only number or not
    func checkTextFieldContentOnlyNumber(str:String)->Bool{
        let set = NSCharacterSet.decimalDigitCharacterSet()
        if (str.rangeOfCharacterFromSet(set) != nil) {
            return true
        }
        else{
            return false
        }
    }
    
    func checkTextFieldContentCharacters(str:String)->Bool{
        let set = NSCharacterSet.letterCharacterSet()
        if (str.rangeOfCharacterFromSet(set) != nil) {
            return true
        }
        else{
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
        else{
            return false
        }
    }
    
    //Function invoke for validate the email
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        var result = emailTest.evaluateWithObject(testStr)
        
        if result {
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let matches = testStr.rangeOfString(regex, options: .RegularExpressionSearch)
            if let _ = matches {
                result = true
            }
            else {
                result = false
            }
        }
        return result
    }
    
}
