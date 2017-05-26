//
//  SARegistrationScreenSecondViewController.swift
//  Savio
//
//  Created by Maheshwari on 11/08/16.
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


protocol RegistrationViewErrorDelegate {
    func getValues(_ firstName:String,lastName:String,dateOfBirth:String)
    
}

class SARegistrationScreenSecondViewController: UIViewController,UITextFieldDelegate,PostCodeVerificationDelegate,ImportantInformationViewDelegate,OTPSentDelegate,URLSessionDelegate {
    
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
    @IBOutlet weak var addressLineOneTopSpace: NSLayoutConstraint!
    @IBOutlet weak var contentViewHt: NSLayoutConstraint!
    @IBOutlet weak var addressLineErrorLabelTopSpace: NSLayoutConstraint!
    @IBOutlet weak var countyTextFieldTopspace: NSLayoutConstraint!
    @IBOutlet weak var addressLineOneErrorLabelTopSpace: NSLayoutConstraint!
    @IBOutlet weak var addressDropDownButton: UIButton!
    @IBOutlet weak var townTextFieldTopSpace: NSLayoutConstraint!
    
    let dropDown = DropDown()
    var arrayAddress = [String]()
    var activeTextField = UITextField()
    var userInfoDict : Dictionary<String,AnyObject> = [:]
    var objAnimView = ImageViewAnimation()
    var objimpInfo = ImportantInformationView()
    var termAndConditionText:String?

    
    var registrationViewErrorDelegate: RegistrationViewErrorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.callTermAndConditionAPI(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //set the height on contentview and content size of UIScrollview
        contentViewHt.constant = backButton.frame.origin.y + backButton.frame.size.height + 40
        registerScrollViewSecond.contentSize = CGSize(width: 0, height: contentViewHt.constant + 20)
    }
    func setUpView()
    {
        //set the height on contentview and content size of UIScrollview
        contentViewHt.constant = backButton.frame.origin.y + backButton.frame.size.height + 40
        registerScrollViewSecond.contentSize = CGSize(width: 0, height: contentViewHt.constant + 20)
        
        //Customization of find address text field
        findAddressTextField?.layer.cornerRadius = 2.0
        findAddressTextField?.layer.masksToBounds = true
        findAddressTextField?.layer.borderWidth=1.0
        let placeholder1 = NSAttributedString(string:"Postcode" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        findAddressTextField?.attributedPlaceholder = placeholder1;
        findAddressTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
        //Customization of select address text field
        selectAddressTextField?.layer.cornerRadius = 2.0
        selectAddressTextField?.layer.masksToBounds = true
        selectAddressTextField?.layer.borderWidth=1.0
        let placeholder2 = NSAttributedString(string:"Select address" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        selectAddressTextField?.attributedPlaceholder = placeholder2;
        selectAddressTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
        //Customization of address line one text field
        addressLineOneTextField?.layer.cornerRadius = 2.0
        addressLineOneTextField?.layer.masksToBounds = true
        addressLineOneTextField?.layer.borderWidth=1.0
        let placeholder3 = NSAttributedString(string:"Address Line 1" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        addressLineOneTextField?.attributedPlaceholder = placeholder3;
        addressLineOneTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
        //Customization of address line two text field
        addressLineTwoTextField?.layer.cornerRadius = 2.0
        addressLineTwoTextField?.layer.masksToBounds = true
        addressLineTwoTextField?.layer.borderWidth=1.0
        let placeholder4 = NSAttributedString(string:"Address Line 2" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        addressLineTwoTextField?.attributedPlaceholder = placeholder4;
        addressLineTwoTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
        //Customization of address line three text field
        addressLineThreeTextField?.layer.cornerRadius = 2.0
        addressLineThreeTextField?.layer.masksToBounds = true
        addressLineThreeTextField?.layer.borderWidth=1.0
        let placeholder5 = NSAttributedString(string:"Address Line 3" , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        addressLineThreeTextField?.attributedPlaceholder = placeholder5;
        addressLineThreeTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
        //Customization of town text field
        townTextField?.layer.cornerRadius = 2.0
        townTextField?.layer.masksToBounds = true
        townTextField?.layer.borderWidth=1.0
        let placeholder6 = NSAttributedString(string:kTown , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        townTextField?.attributedPlaceholder = placeholder6;
        townTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
        //Customization of county text field
        countyTextField?.layer.cornerRadius = 2.0
        countyTextField?.layer.masksToBounds = true
        countyTextField?.layer.borderWidth=1.0
        let placeholder7 = NSAttributedString(string:kCounty , attributes: [NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
        countyTextField?.attributedPlaceholder = placeholder7;
        countyTextField?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        
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
        
        //Validations for find address text field
        if findAddressTextField.text == "" {
            errorFlag = true
            findAddressErrorLabel.text = "Don’t forget your postcode"
            findAddressTextField.layer.borderColor = UIColor.red.cgColor
            findAddressTextField.textColor = UIColor.red
        }
        
        //Validations for address line one text field
        if addressLineOneTextField.text == ""
        {
            errorFlag = true
            addressLineOneErrolLabel.text = "Don’t forget your house number"
            addressLineOneTopSpace.constant = 21
            addressLineOneErrorLabelTopSpace.constant = 5
            selectAddressTextField.isHidden = true
            addressDropDownButton.isHidden = true
            addressLineOneTextField.layer.borderColor = UIColor.red.cgColor
            addressLineTwoTextField.layer.borderColor = UIColor.red.cgColor
            addressLineThreeTextField.layer.borderColor = UIColor.red.cgColor
        }
        
        //Validations for town text field
        if townTextField.text == ""
        {
            errorFlag = true
            townErrorLabel.text = "Don’t forget your town"
            townTextFieldTopSpace.constant = 21
            townTextField.layer.borderColor = UIColor.red.cgColor
        }
        
        //Validations for county text field
        if countyTextField.text == ""
        {
            errorFlag = true
            countyErrorLabel.text = "Don’t forget your county"
            countyTextFieldTopspace.constant = 21
            countyTextField.layer.borderColor = UIColor.red.cgColor
        }
        
        contentViewHt.constant = backButton.frame.origin.y + backButton.frame.size.height + 40
        registerScrollViewSecond.contentSize = CGSize(width: 0, height: contentViewHt.constant + 20)
        
        return errorFlag
    }
    
    
    //UITextfield delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        activeTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        activeTextField = textField
        activeTextField.textColor = UIColor.black
        if(textField == selectAddressTextField)
        {
            self.showOrDismiss()
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        activeTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
    }
    
    @IBAction func findAddressButtonPressed(_ sender: AnyObject) {
        activeTextField.resignFirstResponder()
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        if(arrayAddress.count > 0)
        {
            self.dropDown.deselectRowAtIndexPath(0)
            arrayAddress.removeAll()
            dropDown.dataSource.removeAll()
        }
        findAddressErrorLabel.text = ""
        let objGetAddressAPI: API = API()
        objGetAddressAPI.delegate = self
        let trimmedString = findAddressTextField.text!.replacingOccurrences(of: " ", with: "")
        
        if trimmedString.characters.count == 0 {
            let alert = UIAlertView(title: "Sorry!", message: "Please enter your postcode to find your address and try again", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            return
        }
        self.view.addSubview(objAnimView)
        objGetAddressAPI.verifyPostCode(trimmedString)
        
    }
    
    //Importanat information view delegate method
    func acceptPolicy(_ obj:ImportantInformationView){
        let objAPI = API()
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        objAPI.delegate = self
        print("userInfoDict=\(userInfoDict)")
        objAPI.registerTheUserWithTitle(userInfoDict,apiName: "Customers")
        
    }
    
    
    @IBAction func registerButtonPressed(_ sender: AnyObject) {
        
        //Check the text field validations to go further for registration
        if(self.checkTextFieldValidation() == false)
        {
            userInfoDict["address_1"] = addressLineOneTextField.text as AnyObject
            userInfoDict["address_2"] = addressLineTwoTextField.text as AnyObject
            userInfoDict["address_3"] = addressLineThreeTextField.text as AnyObject
            userInfoDict["town"] = townTextField.text as AnyObject
            userInfoDict["county"] = countyTextField.text as AnyObject
            userInfoDict["post_code"] = findAddressTextField.text as AnyObject
            let udidDict : Dictionary<String,AnyObject>
           
            if let apnsDeviceToken = userDefaults.value(forKey: "APNSTOKEN") as? NSString
            {
                udidDict = ["DEVICE_ID":Device.udid as AnyObject, "PNS_DEVICE_ID": apnsDeviceToken]
                 print(udidDict)
            } else {
                udidDict = ["DEVICE_ID":Device.udid as AnyObject, "PNS_DEVICE_ID": "" as AnyObject]
                 print(udidDict)
            }
            let udidArray: Array<Dictionary<String,AnyObject>> = [udidDict]
            userInfoDict["deviceRegistration"] =  udidArray as AnyObject
            userInfoDict["party_role"] =  4 as AnyObject
            
            objimpInfo = Bundle.main.loadNibNamed("ImportantInformationView", owner: self, options: nil)![0] as! ImportantInformationView
            objimpInfo.lblHeader.text = "Terms and Conditions"//"Why do we need this information?"
            
//            termAndConditionText = termAndConditionText?.stringByReplacingOccurrencesOfString("\"", withString: "&quot")
//            print(termAndConditionText!)
            if termAndConditionText?.characters.count > 0{
            
            let theAttributedString = try! NSAttributedString(data: termAndConditionText!.data(using: String.Encoding.utf8, allowLossyConversion: true)!,
                                                              options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                              documentAttributes: nil)

            objimpInfo.termsAndConditionTextView.attributedText = theAttributedString
            objimpInfo.frame = self.view.frame
            objimpInfo.delegate = self
            objimpInfo.isFromRegistration = true
            self.view.addSubview(objimpInfo)
            }
            else{
                objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
                objAnimView.frame = self.view.frame
                objAnimView.animate()
                self.view.addSubview(objAnimView)
                self.callTermAndConditionAPI(true)
            }
        }
        else
        {
            self.checkTextFieldValidation()
        }
        contentViewHt.constant = backButton.frame.origin.y + backButton.frame.size.height + 40
        registerScrollViewSecond.contentSize = CGSize(width: 0, height: contentViewHt.constant + 20)
    }
    
    func callTermAndConditionAPI(_ flag:Bool) {
        let objAPI = API()
        let cookie = "e4913375-0c5e-4839-97eb-e9dde4a5c7ff"
        let partyID = "956"
        
        let utf8str = String(format: "%@:%@",partyID,cookie).data(using: String.Encoding.utf8)
        let base64Encoded = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let urlconfig = URLSessionConfiguration.default
        //Check if network is present
        if(objAPI.isConnectedToNetwork())
        {
            urlconfig.timeoutIntervalForRequest = 30
            urlconfig.timeoutIntervalForResource = 30
            let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = NSMutableURLRequest(url: URL(string: String(format:"%@/Content/9",baseURL))!)
//            request.addValue(String(format: "Basic %@",base64Encoded!), forHTTPHeaderField: "Authorization")
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data
                {
//                    print(response?.description)
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        print(dict)
                        DispatchQueue.main.async
                        {
                            if dict["errorCode"] as! String == "200"{
                                if flag == false {
//                                    self.successResponseFortermAndConditionAPI(dict["content"] as! Dictionary)
                                    self.successResponseFortermAndConditionAPI(self.checkNullDataFromDict(dict["content"] as! Dictionary))
                                }
                                else {
                                    let respoDict = self.checkNullDataFromDict(dict["content"]! as! Dictionary<String,AnyObject>)
                                     self.termAndConditionText = respoDict["content"] as! String
                                    self.objAnimView.removeFromSuperview()
                                    self.objimpInfo = Bundle.main.loadNibNamed("ImportantInformationView", owner: self, options: nil)![0] as! ImportantInformationView
                                    self.objimpInfo.lblHeader.text = "Terms and Conditions"
                                    let theAttributedString = try! NSAttributedString(data: self.termAndConditionText!.data(using: String.Encoding.utf8, allowLossyConversion: true)!,
                                                                                      options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                                                      documentAttributes: nil)
                                    
                                    self.objimpInfo.termsAndConditionTextView.attributedText = theAttributedString
                                    self.objimpInfo.frame = self.view.frame
                                    self.objimpInfo.delegate = self
                                    self.objimpInfo.isFromRegistration = true
                                    self.view.addSubview(self.objimpInfo)
                                }
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                        }
                    }
                }
                else  if let error = error  {
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
        print(objResponse["content"]!)
        termAndConditionText = objResponse["content"] as! String
    }

    func errorResponseFortermAndConditionAPI(_ error:String){
        
    }
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(SARegistrationScreenSecondViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SARegistrationScreenSecondViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    var lastOffset: CGPoint = CGPoint.zero
    //Keyboard notification function
    @objc func keyboardWasShown(_ notification: Notification){
        //do stuff
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue.size
        let visibleAreaHeight = UIScreen.main.bounds.height - 30 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
        lastOffset = (registerScrollViewSecond?.contentOffset)!
        let yOfTextField = activeTextField.frame.origin.y
        if (yOfTextField - (lastOffset.y)) > visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            registerScrollViewSecond?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(_ notification: Notification){
        //do stuff
        activeTextField.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        registerScrollViewSecond?.setContentOffset(lastOffset, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectAddressArrowPressed(_ sender: AnyObject) {
        self.showOrDismiss()
    }
    
    func sortTwoString(_ value1: String, value2: String) -> Bool {
        // One string is alphabetically first.
        // ... True means value1 precedes value2.
        return value1 < value2;
    }
    
    func showOrDismiss(){
        if dropDown.isHidden {
            dropDown.show()
        } else {
            dropDown.hide()
        }
    }
    
    //Set up drop down for address list
    func setUpDropDown(){
        arrayAddress.sort { sortTwoString($0, value2: $1) }
        dropDown.dataSource = arrayAddress
        self.dropDown.selectionBackgroundColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        // dropdown selection action
        dropDown.selectionAction = { [unowned self] (index, item) in
            let str = item
            print(str)
            let fullNameArr = str.characters.split{$0 == ","}.map(String.init)
            self.addressLineOneTextField.text = fullNameArr[0]
            self.addressLineTwoTextField.text = fullNameArr[1]
            self.addressLineThreeTextField.text = fullNameArr[fullNameArr.count-3]
            self.townTextField.text = fullNameArr[fullNameArr.count-2]
            self.countyTextField.text = fullNameArr[fullNameArr.count-1]
            
            self.addressLineOneTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
            self.addressLineTwoTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
            self.addressLineThreeTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
            self.townTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
            self.countyTextField.layer.borderColor =  UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
            self.townTextFieldTopSpace.constant = 5
            self.countyTextFieldTopspace.constant = 5
        }
        //added bottom offset for dropdown
        dropDown.anchorView = selectAddressTextField
        dropDown.bottomOffset = CGPoint(x: 0, y:selectAddressTextField!.bounds.height)
        dropDown.backgroundColor = UIColor.white
        
    }
    
    //Post code verification delegate methods
    func success(_ addressArray: Array<String>) {
        objAnimView.removeFromSuperview()
        arrayAddress = addressArray
        addressLineOneTopSpace.constant = 40
        selectAddressTextField.isHidden = false
        addressDropDownButton.isHidden = false
        addressLineOneErrolLabel.text = ""
        contentViewHt.constant = backButton.frame.origin.y + backButton.frame.size.height + 40
        registerScrollViewSecond.contentSize = CGSize(width: 0, height: contentViewHt.constant + 20)
        self.setUpDropDown()
        selectAddressTextField.becomeFirstResponder()
    }
    
    func error(_ error: String) {
        objAnimView.removeFromSuperview()
        if(error == "Network not available")
        {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else if(error == "That postcode doesn't look right")
        {
            findAddressErrorLabel.text = error
        }
        else
        {
            let alert = UIAlertView(title: "Sorry!", message: "We can't look up your postcode, please enter your address below.", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            
        }
    }
    //Registration delegate methods
    func successResponseForRegistrationAPI(_ objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        let errorCode = (objResponse["errorCode"] as! NSString).integerValue
        if errorCode == 200 {
            checkString = "Register"
            let objAPI = API()
//            NSuserDefaultsUserDefaults().setObject(self.checkNullDataFromDict(objResponse["party"]! as! Dictionary<String,AnyObject>), forKey: "userInfo")
//            NSuserDefaultsUserDefaults().synchronize()
            objAPI.storeValueInKeychainForKey(kUserInfo, value: self.checkNullDataFromDict(objResponse["party"]! as! Dictionary<String,AnyObject>) as AnyObject)
//            if let passcode = objAPI.getValueFromKeychainOfKey("myPasscode") as? String
//            {
//                objAPI.deleteKeychainValue("myPasscode")
//            }
            
            if (userDefaults.object(forKey: "myPasscode") as? String) != nil
            {
                userDefaults.removeObject(forKey: "myPasscode")
                userDefaults.synchronize()
            }
            
            objAPI.otpSentDelegate = self
            objAPI.getOTPForNumber(userInfoDict[kPhoneNumber] as! String, country_code: "44")
        }
        else if errorCode == 201 {
             objAnimView.removeFromSuperview()
            let alert = UIAlertController(title: "Welcome back! You need to create you a new Passcode so you can login easily.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Create Passcode", style: UIAlertActionStyle.cancel, handler: { action -> Void in
                checkString = "ForgotPasscode"
                let objAPI = API()
//                NSuserDefaultsUserDefaults().setObject(objResponse["party"]!, forKey: "userInfo")
//                NSuserDefaultsUserDefaults().synchronize()
                objAPI.storeValueInKeychainForKey(kUserInfo, value: self.checkNullDataFromDict(objResponse["party"]! as! Dictionary<String,AnyObject>) as AnyObject)
                checkString = "ForgotPasscode"
                let objCreatePINView = CreatePINViewController(nibName: "CreatePINViewController",bundle: nil)
                self.navigationController?.pushViewController(objCreatePINView, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if errorCode == 202 {
             objAnimView.removeFromSuperview()
            _ = objResponse["party"] as! Dictionary<String,AnyObject>
//           let firstName = dict["first_name"] as! String
//           let lastName = dict["second_name"] as! String
//           let dateOfBirth = dict["date_of_birth"] as! String
//            let msg = objResponse["message"] as! String
            let msg = self.messageForUser(objResponse)
            
            let alert = UIAlertController(title: "Welcome back!  Some of your details match our records but not all of them.", message: msg, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            { action -> Void in
//                self.registrationViewErrorDelegate?.getValues(firstName, lastName: lastName, dateOfBirth: dateOfBirth)
                self.navigationController?.popViewController(animated: true)
                })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func messageForUser(_ response: Dictionary<String,AnyObject>)->String{
        var returnMsg = ""
        let msgFromServer = response["message"] as! String
        
        if msgFromServer == "Enter your firstname as earlier" {
            returnMsg = "Please check your first name and try again."
        }
        else if msgFromServer == "Enter your lastname as earlier" {
            returnMsg = "Please check your last name and try again."
        }
        else if msgFromServer == "Enter your firstname lastname as earlier" {
            returnMsg = "Please check your first name and last name and try again."
        }
        else if msgFromServer == "Enter your date of birth as earlier" {
            returnMsg = "Please check your date of birth and try again."
        }
        else if msgFromServer == "Enter your phone number as earlier" {
            returnMsg = "Please check your phone number and try again."
        }
        else{
             returnMsg = msgFromServer
        }
        return returnMsg
    }
    
    func errorResponseForRegistrationAPI(_ error: String) {
        objAnimView.removeFromSuperview()
        if(error == kNonetworkfound)
        {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else {
        let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
    }
    
    //OTP Verification Delegate Method
    func successResponseForOTPSentAPI(_ objResponse:Dictionary<String,AnyObject>)
    {
        objAnimView.removeFromSuperview()
        let fiveDigitVerificationViewController = FiveDigitVerificationViewController(nibName:"FiveDigitVerificationViewController",bundle: nil)
        fiveDigitVerificationViewController.isComingFromRegistration = true
        self.navigationController?.pushViewController(fiveDigitVerificationViewController, animated: true)
    }
    func errorResponseForOTPSentAPI(_ error:String){
        objAnimView.removeFromSuperview()
        let fiveDigitVerificationViewController = FiveDigitVerificationViewController(nibName:"FiveDigitVerificationViewController",bundle: nil)
        fiveDigitVerificationViewController.isComingFromRegistration = true
        self.navigationController?.pushViewController(fiveDigitVerificationViewController, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let arr = self.view.subviews
        for obj in arr
        {
            if(obj == objimpInfo)
            {
                objimpInfo.removeFromSuperview()
            }
        }
    }
    
    //function checking any key is null and return not null values in dictionary
    func checkNullDataFromDict(_ dict:Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject> {
        var replaceDict: Dictionary<String,AnyObject> = dict
        let blank = ""
        //check each key's value
        for key:String in Array(dict.keys) {
            let ob = dict[key]! as? AnyObject
            //if value is Null or nil replace its value with blank
            if (ob is NSNull)  || ob == nil {
                replaceDict[key] = blank as AnyObject
            }
            else if (ob is Dictionary<String,AnyObject>) {
                replaceDict[key] = self.checkNullDataFromDict(ob as! Dictionary<String,AnyObject>) as AnyObject
            }
            else if (ob is Array<Dictionary<String,AnyObject>>) {
                var newArr: Array<Dictionary<String,AnyObject>> = []
                for arrObj:Dictionary<String,AnyObject> in ob as! Array {
                    newArr.append(self.checkNullDataFromDict(arrObj as Dictionary<String,AnyObject>))
                }
                replaceDict[key] = newArr as AnyObject
            }
        }
        return replaceDict
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)


    }
}
