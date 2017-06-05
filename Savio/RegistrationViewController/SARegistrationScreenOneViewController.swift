//
//  SARegistrationScreenOneViewController.swift
//  Savio
//
//  Created by Maheshwari on 10/08/16.
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


class SARegistrationScreenOneViewController: UIViewController,UITextFieldDelegate,UIScrollViewDelegate,URLSessionDelegate{
    
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
    
    var errorFlag = true
    let dropDown = DropDown()
    let datePickerView = UIDatePicker()
    var activeTextField = UITextField()
    var fName = ""
    var lName = ""
    var dob = ""
    var lastOffset: CGPoint = CGPoint.zero
    var impText: String?
     var objAnimView = ImageViewAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        self.callImportantAPI(false)
//      objApi.deleteKeychainValue("saveCardArray")
//      objApi.deleteKeychainValue("savingPlanDict")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        errorFlag = false
        self.setUpView()
    }
    
    func setUpView()
    {
        //Customization of title text field
        titleTextField?.layer.cornerRadius = 2.0
        titleTextField?.layer.masksToBounds = true
        titleTextField?.layer.borderWidth=1.0
        let placeholder = NSAttributedString(string:"Title" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        titleTextField?.attributedPlaceholder = placeholder;
        titleTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
        //Setting drop down list for titleTextField
        dropDown.anchorView = titleTextField
        dropDown.backgroundColor = UIColor.white
        self.dropDown.textColor = UIColor.black
        self.dropDown.selectionBackgroundColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        dropDown.dataSource = [
            "Mr",
            "Ms"]
        //added bottom offset for dropdown
        dropDown.bottomOffset = CGPoint(x: 0, y:titleTextField!.bounds.height)
        //Selection action of dropdown
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.titleTextField?.text = item
            self.titleTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        }
        
         //Customization of name text field
        nameTextField?.layer.cornerRadius = 2.0
        nameTextField?.layer.masksToBounds = true
        nameTextField?.layer.borderWidth=1.0
        let placeholder1 = NSAttributedString(string:"Name" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        nameTextField?.attributedPlaceholder = placeholder1;
        nameTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
         //Customization of surname text field
        surnameTextField?.layer.cornerRadius = 2.0
        surnameTextField?.layer.masksToBounds = true
        surnameTextField?.layer.borderWidth=1.0
        let placeholder2 = NSAttributedString(string:kSurname , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        surnameTextField?.attributedPlaceholder = placeholder2;
        surnameTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
         //Customization of DOB text field
        dateOfBirthTextField?.layer.cornerRadius = 2.0
        dateOfBirthTextField?.layer.masksToBounds = true
        dateOfBirthTextField?.layer.borderWidth=1.0
        let placeholder3 = NSAttributedString(string:"Date of birth" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        dateOfBirthTextField?.attributedPlaceholder = placeholder3;
        dateOfBirthTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
        //add custom tool bar for UIDatePickerView
        let customToolBar = UIToolbar(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action:#selector(SARegistrationScreenOneViewController.doneBarButtonPressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SARegistrationScreenOneViewController.cancelBarButtonPressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil);
        customToolBar.items = [cancelButton,flexibleSpace,acceptButton]
        
        //Set datepickerview as input view and customtoolbar as inputAccessoryViewto DOB textfield
        dateOfBirthTextField.inputView = datePickerView
        dateOfBirthTextField.inputAccessoryView = customToolBar
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        //get 18 years previous date
        let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let currentDate: Date = Date()
        var components: DateComponents = DateComponents()
        components.year = -18
        let minDate: Date = (gregorian as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
        datePickerView.maximumDate = minDate
        
        //Customization of mobile number text field
        mobileNumberTextField?.layer.cornerRadius = 2.0
        mobileNumberTextField?.layer.masksToBounds = true
        mobileNumberTextField?.layer.borderWidth=1.0
        let placeholder4 = NSAttributedString(string:kMobileNumber , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        mobileNumberTextField?.attributedPlaceholder = placeholder4;
        mobileNumberTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        //Add custom tool bar as input accessory view to mobile number textfield
        let customToolBar2 = UIToolbar(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 44))
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action:#selector(SARegistrationScreenOneViewController.doneBarButtonPressed))
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil);
        customToolBar2.items = [flexibleSpace1,doneButton]
        mobileNumberTextField.inputAccessoryView = customToolBar2
        
         //Customization of email text field
        emailTextField?.layer.cornerRadius = 2.0
        emailTextField?.layer.masksToBounds = true
        emailTextField?.layer.borderWidth=1.0
        let placeholder5 = NSAttributedString(string:kEmail , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        emailTextField?.attributedPlaceholder = placeholder5;
        emailTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
        //Customization of next button
        nextButton?.layer.cornerRadius = 2.0
        nextButtonBgView.layer.cornerRadius = 2.0
        
        topspacefieldForEmailTextField.constant = 5
        topSpaceForSurnameTextField.constant = 5
        topSpaceForDateOfBirthTextField.constant = 5
        topSpaceForMobileNumberTextField.constant = 5
        
        titleOrNameErrorLabel.text = ""
        mobileNumberErrorLabel.text = ""
        emailErrorLabel.text = ""
        surnameErrorLabel.text = ""
        dateOfBirthErrorLabel.text = ""
    }
    
    //Check all text fields validations
    func checkTextFieldValidation()->Bool{
        
        //Validations for title and name text field
        if(titleTextField.text?.characters.count == 0 && nameTextField.text?.characters.count == 0) {
            titleOrNameErrorLabel.text = kTitleAndNameMissingError
            titleTextField.layer.borderColor = UIColor.red.cgColor
            nameTextField.layer.borderColor = UIColor.red.cgColor
            nameTextField.textColor = UIColor.red
            errorFlag = true
        }
        else if (self.checkTextFieldContentOnlyNumber(nameTextField.text!) == true) {
            titleOrNameErrorLabel.text = "Name should contain alphabets only"
            if titleTextField.text?.characters.count==0 {
                titleOrNameErrorLabel.text = "Please select a title and name should contain alphabets only"
            }
            errorFlag = true
            nameTextField.layer.borderColor = UIColor.red.cgColor
            nameTextField.textColor = UIColor.red
        }
        else if (self.checkTextFieldContentSpecialChar(nameTextField.text!)) {
            titleOrNameErrorLabel.text = "Name should not contain special characters"
            if(titleTextField.text?.characters.count == 0)
            {
                titleOrNameErrorLabel.text = "Please select a title and name should not contain special characters"
            }
            registerOneScrollView.contentSize = CGSize(width: 0, height: registerOneScrollView.contentSize.height + 20)
            errorFlag = true
            nameTextField.layer.borderColor = UIColor.red.cgColor
            nameTextField.textColor = UIColor.red
        }
        else if nameTextField.text?.characters.count > 50 {
            titleOrNameErrorLabel.text = kLongName
            errorFlag = true
            if(titleTextField.text?.characters.count == 0)
            {
                titleOrNameErrorLabel.text = "Please select a title and such a long name we can’t save it"
            }
            nameTextField.layer.borderColor = UIColor.red.cgColor
            nameTextField.textColor = UIColor.red
        }
        else if titleTextField.text == "" {
            titleOrNameErrorLabel.text = kTitleEmpty
            errorFlag = true
            titleTextField.textColor = UIColor.red
        }
        else if nameTextField.text == "" {
            titleOrNameErrorLabel.text = kEmptyName
            errorFlag = true
            nameTextField.layer.borderColor = UIColor.red.cgColor
            nameTextField.textColor = UIColor.red
        }
        else {
            titleOrNameErrorLabel.text = ""
        }
        
        //Validations for surname text field
        if surnameTextField.text=="" {
            surnameErrorLabel.text = "We need to know your surname"
            topSpaceForSurnameTextField.constant = 21
            errorFlag = true
            surnameTextField.layer.borderColor = UIColor.red.cgColor
            surnameTextField.textColor = UIColor.red
        }
        else if(surnameTextField.text?.characters.count>50) {
            surnameErrorLabel.text = "Wow, that’s such a long surname we can’t save it"
            topSpaceForSurnameTextField.constant = 21
            errorFlag = true
            surnameTextField.layer.borderColor = UIColor.red.cgColor
            surnameTextField.textColor = UIColor.red
        }
        else if(self.checkTextFieldContentOnlyNumber(surnameTextField.text!) == true) {
            surnameErrorLabel.text = "Surname should contain alphabets only"
            topSpaceForSurnameTextField.constant = 21
            errorFlag = true
            surnameTextField.layer.borderColor = UIColor.red.cgColor
            surnameTextField.textColor = UIColor.red
        }
        else if checkTextFieldContentSpecialChar(surnameTextField.text!) {
            surnameErrorLabel.text = "Surname should not contain special characters"
            if(UIScreen.main.bounds.width == 320)
            {
                topSpaceForSurnameTextField.constant = 40
                surnameErrorLabelHt.constant = 40
            }
            else {
                 topSpaceForSurnameTextField.constant = 21
                surnameErrorLabelHt.constant = 21
            }
           
            errorFlag = true
            surnameTextField.layer.borderColor = UIColor.red.cgColor
            surnameTextField.textColor = UIColor.red
        }
        else {
            surnameErrorLabel.text = ""
            topSpaceForSurnameTextField.constant = 5
        }
        
        //Validations for date of birth text field
        if(dateOfBirthTextField.text == "")  {
            topSpaceForDateOfBirthTextField.constant = 21
            dateOfBirthErrorLabel.text = "We need to know your date of birth"
            errorFlag = true
            dateOfBirthTextField.layer.borderColor = UIColor.red.cgColor
            dateOfBirthTextField.textColor = UIColor.red
        }
        else  {
            topSpaceForDateOfBirthTextField.constant = 5
            dateOfBirthErrorLabel.text = ""
        }
        
        //Validations for mobile text field
        if mobileNumberTextField.text == "" {
            mobileNumberErrorLabel.text = "Don't forget your mobile number"
            topSpaceForMobileNumberTextField.constant = 21
            errorFlag = true
            mobileNumberTextField.layer.borderColor = UIColor.red.cgColor
            mobileNumberTextField.textColor = UIColor.red
        }
        else if(self.checkTextFieldContentCharacters(mobileNumberTextField.text!) == true || self.phoneNumberValidation(mobileNumberTextField.text!)==false) {
            mobileNumberErrorLabel.text = "That mobile number doesn’t look right"
            topSpaceForMobileNumberTextField.constant = 21
            errorFlag = true
            mobileNumberTextField.layer.borderColor = UIColor.red.cgColor
            mobileNumberTextField.textColor = UIColor.red
        }
        else if(mobileNumberTextField.text?.characters.count < 10) {
            mobileNumberErrorLabel.text = "That mobile number should be greater than 10 digits"
            if(UIScreen.main.bounds.width == 320)
            {
            topSpaceForMobileNumberTextField.constant = 40
            mobileNumberErrorLabelHt.constant = 40
            }
            else
            {
                topSpaceForMobileNumberTextField.constant = 21
                   mobileNumberErrorLabelHt.constant = 21
            }
            errorFlag = true
            mobileNumberTextField.layer.borderColor = UIColor.red.cgColor
            mobileNumberTextField.textColor = UIColor.red
            registerOneScrollView.contentSize = CGSize(width: 0, height: registerOneScrollView.contentSize.height + 20)
        }
        else if(mobileNumberTextField.text?.characters.count > 16) {
            mobileNumberErrorLabel.text = "That mobile number should be of 15 digits"
            topSpaceForMobileNumberTextField.constant = 21
            errorFlag = true
            mobileNumberTextField.layer.borderColor = UIColor.red.cgColor
            mobileNumberTextField.textColor = UIColor.red
        }
        else {
            topSpaceForMobileNumberTextField.constant = 5
            mobileNumberErrorLabel.text = ""
        }
        
        //Validations for email text field
        
        if emailTextField.text=="" {
            
            topspacefieldForEmailTextField.constant = 21
            emailErrorLabel.text = "Don't forget your email address"
            errorFlag = true
            emailTextField.textColor = UIColor.red
            emailTextField.layer.borderColor = UIColor.red.cgColor
        }
        else  if emailTextField.text?.characters.count>0 && (self.isValidEmail(emailTextField.text!)==false) {
            topspacefieldForEmailTextField.constant = 21
            emailErrorLabel.text = "That email address doesn’t look right"
            errorFlag = true
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailTextField.textColor = UIColor.red
            
        }
        else {
            topspacefieldForEmailTextField.constant = 5
            emailErrorLabel.text = ""
        }
        
        return errorFlag
        
    }
    //Register keyboard notification
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(SARegistrationScreenOneViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SARegistrationScreenOneViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        lastOffset = (registerOneScrollView?.contentOffset)!
        let yOfTextField = activeTextField.frame.origin.y
        if (yOfTextField - (lastOffset.y)) > visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            registerOneScrollView?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(_ notification: Notification){
        //do stuff
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        registerOneScrollView?.setContentOffset(lastOffset, animated: true)
    }
    
//    func validateForAlreadyRegisteredUser()-> Bool
//    {
//        var success = true
//        var message = ""
//        if(fName.characters.count == 0) {
//            return true
//        }
//        if(fName.lowercaseString != nameTextField.text?.lowercaseString) {
//            success = false
//            message = message + "name"
//        }
//        if(lName.lowercaseString != surnameTextField.text?.lowercaseString) {
//            success = false
//            let fieldString = message.characters.count > 0 ? ",Surname" : "Surname"
//             message = message + fieldString
//        }
//        if(dob != dateOfBirthTextField.text) {
//            success = false
//            let fieldString = message.characters.count > 0 ? ",date of birth" : "date of birth"
//            message = message + fieldString
//        }
//        
//        if(success == false)  {
//            message = "Enter your " + message + " as earlier"
//            let alert = UIAlertView(title: "Warning", message: message, delegate: nil, cancelButtonTitle: "Ok")
//            alert.show()
//        }
//        return success
//    }
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        //check validation of textfield
        
        if(checkTextFieldValidation() == false)
        {

            errorFlag = true
            var userInfoDict : Dictionary<String,AnyObject> = [:]
            userInfoDict[kTitle] = titleTextField.text as AnyObject
            userInfoDict["first_name"] = nameTextField.text?.capitalized as AnyObject
            userInfoDict["second_name"] = surnameTextField.text?.capitalized as AnyObject
            userInfoDict["date_of_birth"] = dateOfBirthTextField.text as AnyObject
            userInfoDict[kPhoneNumber] =  String(format:"+44%@",mobileNumberTextField.text!) as AnyObject
            userInfoDict["email"] = emailTextField.text as AnyObject
            print(userInfoDict)
            
            if(titleTextField.text == "Mr")
            {
                userInfoDict["party_gender"] = "male" as AnyObject
            }
            else
            {
                userInfoDict["party_gender"] = "female" as AnyObject
            }
            
            let registrationSecondView = SARegistrationScreenSecondViewController()
            registrationSecondView.userInfoDict = userInfoDict
            self.navigationController?.pushViewController(registrationSecondView, animated: true)
        
        }
        else {
            errorFlag = false
        }
    }

    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        //Go back to previous view controller
        
        var isAvailble: Bool = false
        var vw = UIViewController()
        vw = SAWelcomeViewController()
        for var obj in (self.navigationController?.viewControllers)!{
            if obj.isKind(of: SAWelcomeViewController.self) {
                isAvailble = true
                vw = obj as! SAWelcomeViewController
                break
            }
        }
        
        if isAvailble {
            self.navigationController?.popToViewController(vw, animated: false)
        }
        else{
            self.navigationController?.pushViewController(vw, animated: false)
        }
    }
    
    @IBAction func whyDoWeThisInfoButtonPressed(_ sender: AnyObject) {
        if impText?.characters.count > 0 {
            let objimpInfo = Bundle.main.loadNibNamed("ImportantInformationView", owner: self, options: nil)![0] as! ImportantInformationView
            objimpInfo.lblHeader.text = "Why do we need this information?"
            let theAttributedString = try! NSAttributedString(data: impText!.data(using: String.Encoding.utf8, allowLossyConversion: true)!,
                                                              options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                              documentAttributes: nil)
            
            objimpInfo.termsAndConditionTextView.attributedText = theAttributedString
            objimpInfo.frame = self.view.frame
            objimpInfo.isFromRegistration = false
            self.view.addSubview(objimpInfo)
        }
        else{
            objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            objAnimView.animate()
            self.view.addSubview(objAnimView)
            self.callImportantAPI(true)
        }
    }
    
    
    //Textfield delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        activeTextField = textField
        activeTextField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        activeTextField.textColor = UIColor.black
        self.registerForKeyboardNotifications()
        if(textField == titleTextField)
        {
            self.showOrDismiss()
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField.resignFirstResponder()
        activeTextField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        self.removeKeyboardNotification()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        self.removeKeyboardNotification()
        return true
    }
    
    func checkTextFieldTextLength(_ txtField: UITextField,range: NSRange, replacementString string: String, len: Int) -> Bool {
        let currentCharacterCount = txtField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if (newLength > len) {
            return false;
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(activeTextField == mobileNumberTextField){
            return  self.checkTextFieldTextLength(textField, range: range, replacementString: string, len: 15)
        }
        return true;
    }

    //Dropdown methods
    func showOrDismiss(){
        if dropDown.isHidden {
            dropDown.show()
        } else {
            dropDown.hide()
        }
    }
    
    
    //ToolBar button action methods
    func cancelBarButtonPressed()
    {
        dateOfBirthTextField.resignFirstResponder()
        self.removeKeyboardNotification()
    }
    
    func doneBarButtonPressed()
    {
        if(activeTextField == dateOfBirthTextField) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let pickrDate = dateFormatter.string(from: datePickerView.date)
            dateOfBirthTextField.text = pickrDate
        }
        activeTextField.resignFirstResponder()
        self.removeKeyboardNotification()
    }
    
    @IBAction func clickeOnDropDownArrow(_ sender:UIButton){
        self.showOrDismiss()
    }
    
    @IBAction func showOrHideDropDownButtonPressed(_ sender: AnyObject) {
        self.showOrDismiss()
    }
    
    //Function checking textfield content only number or not
    func checkTextFieldContentOnlyNumber(_ str:String)->Bool{
        let set = CharacterSet.decimalDigits
//        if (str.rangeOfCharacterFromSet(set) != nil) {
//            return true
//        }
//        else {
//            return false
//        }
        return (str.rangeOfCharacter(from: set) != nil)

    }
    
    func checkTextFieldContentCharacters(_ str:String)->Bool{
        let set = CharacterSet.letters
//        if (str.rangeOfCharacterFromSet(set) != nil) {
//            return true
//        }
//        else {
//            return false
//        }
        
        return (str.rangeOfCharacter(from: set) != nil)

    }
    
    func phoneNumberValidation(_ value: String) -> Bool {
        let charcter  = CharacterSet(charactersIn: "+0123456789").inverted
        var filtered: String!
        
        let inputString: NSArray = value.components(separatedBy: charcter) as [String] as NSArray
        filtered = (inputString.componentsJoined(by: "") as NSString) as String!
        return  value == filtered
    }
    
    
    func checkTextFieldContentSpecialChar(_ str:String)->Bool{
        let characterSet:CharacterSet = CharacterSet(charactersIn: "~!@#$%^&*()_-+={}|\\;:'\",.<>*/")
        if (str.rangeOfCharacter(from: characterSet) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    //Function invoke for validate the email
    func isValidEmail(_ testStr:String) -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        var result = emailTest.evaluate(with: testStr)
        if result {
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let matches = testStr.range(of: regex, options: .regularExpression)
            if let _ = matches {
                result = true
            }
            else {
                result = false
            }
        }
        return result
    }
    
//    func getValues(firstName: String, lastName: String, dateOfBirth: String) {
//        errorFlag = false
//        fName = firstName
//        lName = lastName
//        dob = dateOfBirth
//    }
    
    func callImportantAPI(_ flag:Bool) {
        let objAPI = API()
        
        let cookie = "e4913375-0c5e-4839-97eb-e9dde4a5c7ff"
        let partyID = "956"
        
        let utf8str = String(format: "%@:%@",partyID,cookie).data(using: String.Encoding.utf8)
        _ = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let urlconfig = URLSessionConfiguration.default
        //Check if network is present
        if(objAPI.isConnectedToNetwork())
        {
            urlconfig.timeoutIntervalForRequest = 30
            urlconfig.timeoutIntervalForResource = 30
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = NSMutableURLRequest(url: URL(string: String(format:"%@/Content/10",baseURL))!)
//            request.addValue(String(format: "Basic %@",base64Encoded!), forHTTPHeaderField: "Authorization")
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
//                    print(response?.description)
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
//                        print(dict)
                        DispatchQueue.main.async
                        {
                            if flag == false{
                                if dict["errorCode"] as! String == "200"{
                                    self.successResponseFortermAndConditionAPI(dict["content"] as! Dictionary)
                                }
                            }
                            else{
                                self.objAnimView.removeFromSuperview()
                                self.impText = dict["content"]!["content"] as? String
                                let objimpInfo = Bundle.main.loadNibNamed("ImportantInformationView", owner: self, options: nil)![0] as! ImportantInformationView
                                objimpInfo.lblHeader.text = "Why do we need this information?"
                                let theAttributedString = try! NSAttributedString(data: self.impText!.data(using: String.Encoding.utf8, allowLossyConversion: true)!,
                                                                                  options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                                                  documentAttributes: nil)
                                
                                objimpInfo.termsAndConditionTextView.attributedText = theAttributedString
                                objimpInfo.frame = self.view.frame
                                objimpInfo.isFromRegistration = false
                                self.view.addSubview(objimpInfo)
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                        }
                    }
                }
                else  if error != nil  {
                    DispatchQueue.main.async{
                    }
                    
                }
                
            }) 
            dataTask.resume()
        }
        else {
        }
     }
    
    func successResponseFortermAndConditionAPI(_ objResponse:Dictionary<String,AnyObject>){
        impText = objResponse["content"] as? String
    }
    
    func errorResponseFortermAndConditionAPI(_ error:String){
        AlertContoller(UITitle: kConnectionProblemTitle, UIMessage: kTimeOutNetworkMessage)
    }

}
