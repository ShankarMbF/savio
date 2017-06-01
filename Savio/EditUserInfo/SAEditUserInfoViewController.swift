//
//  SAEditUserInfoViewController.swift
//  Savio
//
//  Created by Vishal  on 11/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAEditUserInfoViewController: UIViewController, UINavigationControllerDelegate
{
    
    @IBOutlet weak var scrlView     : UIScrollView!
    @IBOutlet weak var spinner      : UIActivityIndicatorView!
    @IBOutlet weak var contentView  : UIView!
    @IBOutlet weak var tblViewHt    : NSLayoutConstraint!
    @IBOutlet weak var tblView      : UITableView!
    @IBOutlet weak var contentViewHt: NSLayoutConstraint!
    @IBOutlet weak var addProfilePictureButton: UIButton!
    
    var firstName       = ""
    var lastName        = ""
    var dateOfBirth     = ""
    var phoneNumber     = ""
    var editUser        = true
    var isImageClicked  = false
    
    var arrAddress              = [String]()
    var image1                  = UIImage(named: "img1")
    var getUserInfoDelegate     = GetUserInfoDelegate.self
    var imagePicker             = UIImagePickerController()
    var arrRegistration         = [Dictionary <String, AnyObject>]()        //  Array for hold json file data to create UI
    var arrRegistrationFields   = [UITableViewCell]()                       //  Array of textfield cell
    var queue                   = OperationQueue()
    
    var dictForTextFieldValue   : Dictionary<String, AnyObject> = [:]       //  dictionary for saving user data and error messages
    var objAnimView             : ImageViewAnimation?                       //  Instance of ImageViewAnimation to showing loding aniation on API call
    var wishListArray           : Array<Dictionary<String,AnyObject>> = []
    var userInfoDict            : Dictionary<String,AnyObject> = [:]
    var userBeforeEditInfoDict  : Dictionary<String,AnyObject> = [:]
    var isInfoUpdated           : Bool = false
    var isPressAlertYes         : Bool = false
    //    var isPressAlertYes: Bool = false
    
    
    let kFirstName  : String = "first_name"
    let kSecondName : String = "second_name"
    let kAddress1   : String = "address_1"
    let kAddress2   : String = "address_2"
    let kAddress3   : String = "address_3"
    let kTown       : String = "town"
    let kCounty     : String = "county"
    let kPostCode   : String = "post_code"
    let kName       : String = "name"
    let kTextField1 : String = "textField1"
    
    //    let kTitleAndNameMissingError : String = "We need to know your title and name"
    
    
    //MARK:- ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        addProfilePictureButton.setTitle("Add\n profile\n picture", for: UIControlState())
        addProfilePictureButton.titleLabel?.lineBreakMode =  NSLineBreakMode.byWordWrapping
        addProfilePictureButton.titleLabel?.textAlignment = .center
        addProfilePictureButton.titleLabel?.numberOfLines = 0
        addProfilePictureButton.layer.cornerRadius = addProfilePictureButton.frame.size.height/2
        self.setUPNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isInfoUpdated == false {
            objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            objAnimView!.frame = self.view.frame
            objAnimView!.animate()
            self.view.addSubview(objAnimView!)
            
            let objAPI = API()
            objAPI.getUserInfoDelegate = self
            objAPI.getUserInfo()
        }
        
    }
    
    //MARK:- User Defined Methods
    
    func setUPNavigation()
    {
        self.navigationController?.isNavigationBarHidden    = false
        self.navigationController?.navigationBar.barStyle   = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor  = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SAEditUserInfoViewController.menuButtonClicked), for: .touchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "Personal settings"
        //set Navigation right button nav-heart
        
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.addTarget(self, action: #selector(SAEditUserInfoViewController.heartBtnClicked), for: .touchUpInside)
        
        let dataSave = userDefaults.object(forKey: "wishlistArray") as? Data
        
        if (dataSave != nil)
        {
            wishListArray = (NSKeyedUnarchiver.unarchiveObject(with: dataSave!) as? Array<Dictionary<String,AnyObject>>)!
            
            if(wishListArray.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), for: UIControlState())
                btnName.setTitleColor(UIColor.black, for: UIControlState())
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
            }
            
            btnName.setTitle(String(format:"%d",wishListArray.count), for: UIControlState())
            
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
    }
    
    func getJSONForUI(){
        //create file url
        let fileUrl: URL = Bundle.main.url(forResource: "Registration", withExtension: "json")!
        //getting file data
        let jsonData: Data = try! Data(contentsOf: fileUrl)
        //parsing json file to setup UI
        let json = (try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments))
        self.arrRegistration = json as! Array
    }
    
    func createCells(){
        // if any old cell belong in array then remove all
        if arrRegistrationFields.count > 0{
            arrRegistrationFields.removeAll()
        }
        for i in 0 ..< arrRegistration.count {
            // dictionary to identifying cell and its properies
            let dict = arrRegistration[i] as Dictionary<String,AnyObject>
            //get tableviewCell as per the classtype
            
            //Setup all error message lable tableViewCell
            if dict[kClassType]!.isEqual(to: "ErrorTableViewCell"){
                
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = Bundle.main.loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! ErrorTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                let tfTitleDict = metadataDict[kLable]as! Dictionary<String,AnyObject>
                
                //Set Error messages to error lable
                cell.lblError?.text = tfTitleDict[kTitle] as? String
                let isErrorShow = tfTitleDict[kIsErrorShow] as! String
                //identifying to which error message show for textfield
                
                if isErrorShow == "Yes"{
                    arrRegistrationFields.append(cell as UITableViewCell)
                }
            }
            
            //SetUp Titel and Name textfield tableView cell and its validation messages
            if dict[kClassType]!.isEqual(to: "TitleTableViewCell"){
                
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = Bundle.main.loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! TitleTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.delegate   = self as? TitleTableViewCellDelegate
                cell.tblView    = tblView
                cell.dict       = dict as NSDictionary
                
                let tfTitleDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                cell.tfTitle?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor;
                cell.tfName?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor;
                
                cell.tfTitle!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                if(editUser)
                {
                    cell.tfTitle!.isUserInteractionEnabled = false
                    cell.tfTitle?.text = userInfoDict[kTitle] as? String
                    
                }
                if (dictForTextFieldValue[kTitle] != nil){
                    cell.tfTitle?.text = dictForTextFieldValue[kTitle] as? String
                }
                let tfNameDict = metadataDict["textField2"]as! Dictionary<String,AnyObject>
                cell.tfName!.attributedPlaceholder = NSAttributedString(string:(tfNameDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if(editUser)
                {
                    cell.tfName?.text = userInfoDict[kFirstName] as? String
                }
                if (dictForTextFieldValue[kName] != nil){
                    cell.tfName?.text = dictForTextFieldValue[kName] as? String
                }
                
                if (dictForTextFieldValue[kErrorTitle] != nil) {
                    if dictForTextFieldValue[kErrorTitle]!.isEqual(to: kTitleAndNameMissingError){
                        cell.tfName?.layer.borderColor = UIColor.red.cgColor
                        cell.tfTitle?.layer.borderColor = UIColor.red.cgColor
                    }
                    else if dictForTextFieldValue[kErrorTitle]!.isEqual(to: kTitleEmpty){
                        cell.tfTitle?.layer.borderColor = UIColor.red.cgColor
                    }
                    else if dictForTextFieldValue[kErrorTitle]!.isEqual(to: kEmptyName){
                        cell.tfName?.layer.borderColor = UIColor.red.cgColor
                    }
                    else if (dictForTextFieldValue[kErrorTitle]!.isEqual(to: kLongName) || dictForTextFieldValue[kErrorTitle]!.isEqual(to: "Surname should contain character only") ){
                        cell.tfName?.textColor = UIColor.red
                    }
                }
                arrRegistrationFields.append(cell as UITableViewCell)
                
            }
            if dict[kClassType]!.isEqual(to: "TxtFieldTableViewCell"){
                
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = Bundle.main.loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! TxtFieldTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.delegate = self as? TxtFieldTableViewCellDelegate
                cell.tblView = tblView
                cell.tf?.textColor = UIColor.black
                
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor;
                
                
                let tfTitleDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorTxt"] != nil && cell.tf?.placeholder == kSurname) {
                    let str = dictForTextFieldValue["errorTxt"]
                    if (str!.isEqual(to: "We need to know your surname")){
                        cell.tf?.layer.borderColor = UIColor.red.cgColor
                    }
                }
                
                if (dictForTextFieldValue["errorSurname"] != nil && cell.tf?.placeholder == kSurname) {
                    let str = dictForTextFieldValue["errorSurname"]
                    if (str!.isEqual(to: kLongName)){
                        cell.tf?.textColor = UIColor.red
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).cgColor;
                    }
                }
                
                if (dictForTextFieldValue["errorFirstAddress"] != nil && cell.tf?.placeholder == kFirstAddressLine) {
                    let str = dictForTextFieldValue["errorFirstAddress"]
                    if (str!.isEqual(to: "Don’t forget your house number")){
                        cell.tf?.layer.borderColor = UIColor.red.cgColor
                    }
                }
                if (dictForTextFieldValue["errorTown"] != nil && cell.tf?.placeholder == kTown) {
                    let str = dictForTextFieldValue["errorTown"]
                    if (str!.isEqual(to: "Don’t forget your town")){
                        cell.tf?.layer.borderColor = UIColor.red.cgColor
                    }
                }
                if (dictForTextFieldValue["errorCounty"] != nil && cell.tf?.placeholder == kCounty) {
                    let str = dictForTextFieldValue["errorCounty"]
                    if (str!.isEqual(to: "Don’t forget your county")){
                        cell.tf?.layer.borderColor = UIColor.red.cgColor
                    }
                }
                if (dictForTextFieldValue["errorMobile"] != nil && cell.tf?.placeholder == kMobileNumber) {
                    let str = dictForTextFieldValue["errorMobile"]
                    if (str!.isEqual(to: "Don't forget your mobile number")){
                        cell.tf?.layer.borderColor = UIColor.red.cgColor
                    }
                }
                if (dictForTextFieldValue[kErrorMobileValidation] != nil && cell.tf?.placeholder == kMobileNumber) {
                    let str = dictForTextFieldValue[kErrorMobileValidation]
                    if (str!.isEqual(to: "That mobile number doesn’t look right")){
                        cell.tf?.textColor = UIColor.red
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).cgColor;
                    }
                }
                if (dictForTextFieldValue["errorEmail"] != nil && cell.tf?.placeholder == kEmail) {
                    let str = dictForTextFieldValue["errorEmail"]
                    if (str!.isEqual(to: "Don't forget your email address")){
                        cell.tf?.layer.borderColor = UIColor.red.cgColor
                    }
                }
                if (dictForTextFieldValue["errorEmailValid"] != nil && cell.tf?.placeholder == kEmail) {
                    let str = dictForTextFieldValue["errorEmailValid"]
                    if (str!.isEqual(to: "That email address doesn’t look right")){
                        cell.tf?.textColor = UIColor.red
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).cgColor;
                    }
                }
                
                if(editUser)
                {
                    if(cell.tf?.placeholder == kSurname)
                    {
                        cell.tf?.text = userInfoDict[kSecondName] as? String
                    }
                    else if(cell.tf?.placeholder == kFirstAddressLine)
                    {
                        cell.tf?.text = userInfoDict[kAddress1] as? String
                    }
                    else if(cell.tf?.placeholder == "Town")
                    {
                        cell.tf?.text = userInfoDict[kTown] as? String
                    }
                    else if(cell.tf?.placeholder == "County")
                    {
                        cell.tf?.text = userInfoDict[kCounty] as? String
                    }
                    else if(cell.tf?.placeholder == kSecondAddressLine)
                    {
                        cell.tf?.text = userInfoDict[kAddress2] as? String
                    }
                    else if(cell.tf?.placeholder == kThirdAddressLine)
                    {
                        cell.tf?.text = userInfoDict[kAddress3] as? String
                    }
                }
                
                arrRegistrationFields.append(cell as UITableViewCell)
            }
            
            if dict[kClassType]!.isEqual(to: "PickerTextfildTableViewCell"){
                
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = Bundle.main.loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! PickerTextfildTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.delegate = self as? PickerTxtFieldTableViewCellDelegate
                cell.tblView = tblView
                let tfTitleDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                cell.tfDatePicker!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if(editUser)
                {
                    cell.tfDatePicker.isUserInteractionEnabled = false
                    cell.tfDatePicker.text = userInfoDict["date_of_birth"] as? String
                }
                cell.tfDatePicker?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor;
                if (dictForTextFieldValue[(cell.tfDatePicker?.placeholder)!] != nil){
                    cell.tfDatePicker?.text = dictForTextFieldValue[(cell.tfDatePicker?.placeholder)!] as? String
                }
                arrRegistrationFields.append(cell as UITableViewCell)
            }
            
            if dict[kClassType]!.isEqual(to: "FindAddressTableViewCell"){
                
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = Bundle.main.loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! FindAddressTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.delegate = self as? FindAddressCellDelegate
                cell.tblView = tblView
                
                cell.tfPostCode?.text = userInfoDict[kPostCode] as? String
                cell.tfPostCode?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor;
                let tfPostcodeDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                cell.tfPostCode!.attributedPlaceholder = NSAttributedString(string:(tfPostcodeDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tfPostCode?.placeholder)!] != nil){
                    cell.tfPostCode?.text = dictForTextFieldValue[(cell.tfPostCode?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorPostcode"] != nil) {
                    if dictForTextFieldValue["errorPostcode"]!.isEqual(to: "Don’t forget your postcode"){
                        cell.tfPostCode?.layer.borderColor = UIColor.red.cgColor
                    }
                }
                
                if (dictForTextFieldValue["errorPostcodeValid"] != nil) {
                    if dictForTextFieldValue["errorPostcodeValid"]!.isEqual(to: "That postcode doesn't look right"){
                        cell.tfPostCode?.textColor = UIColor.red
                    }
                }
                
                let btnPostcodeDict = metadataDict["button"]as! Dictionary<String,AnyObject>
                cell.btnPostCode?.setTitle(btnPostcodeDict["placeholder"] as? String, for: UIControlState())
                arrRegistrationFields.append(cell as UITableViewCell)
            }
            
            if dict[kClassType]!.isEqual(to: "ButtonTableViewCell"){
                _ = dict[kMetaData] as! Dictionary<String,AnyObject>
                let cell = Bundle.main.loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! ButtonTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.delegate = self as? ButtonCellDelegate
                cell.tblView = tblView
                cell.btn?.setTitle("Save", for: UIControlState())
                arrRegistrationFields.append(cell as UITableViewCell)
            }
            
            if dict[kClassType]!.isEqual(to: "NumericTextTableViewCell"){
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = Bundle.main.loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! NumericTextTableViewCell
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.delegate       = self as? NumericTxtTableViewCellDelegate
                cell.tblView        = tblView
                cell.tf?.textColor  = UIColor.black
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor;
                cell.tf!.isUserInteractionEnabled = false
                cell.tf?.text = userInfoDict[kPhoneNumber] as? String
                let tfTitleDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorMobile"] != nil && cell.tf?.placeholder == kMobileNumber) {
                    let str = dictForTextFieldValue["errorMobile"]
                    if (str!.isEqual(to: "Don't forget your mobile number")){
                        cell.tf?.layer.borderColor = UIColor.red.cgColor
                    }
                }
                if (dictForTextFieldValue[kErrorMobileValidation] != nil && cell.tf?.placeholder == kMobileNumber) {
                    let str = dictForTextFieldValue[kErrorMobileValidation]
                    if (str!.isEqual(to: "That mobile number doesn’t look right")){
                        cell.tf?.textColor = UIColor.red
                        cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor;
                    }
                }
                arrRegistrationFields.append(cell as UITableViewCell)
            }
            
            if dict[kClassType]!.isEqual(to: "EmailTxtTableViewCell"){
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = Bundle.main.loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! EmailTxtTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.delegate = self as? EmailTxtTableViewCellDelegate
                cell.tblView = tblView
                cell.tf?.textColor = UIColor.black
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor;
                cell.tf?.text = userInfoDict[kEmail] as? String
                cell.tf?.isUserInteractionEnabled = false
                
                let tfTitleDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorEmail"] != nil && cell.tf?.placeholder == kEmail) {
                    let str = dictForTextFieldValue["errorEmail"]
                    if (str!.isEqual(to: "Don't forget your email address")){
                        cell.tf?.layer.borderColor = UIColor.red.cgColor
                    }
                }
                if (dictForTextFieldValue["errorEmailValid"] != nil && cell.tf?.placeholder == kEmail) {
                    let str = dictForTextFieldValue["errorEmailValid"]
                    if (str!.isEqual(to: "That email address doesn’t look right")){
                        cell.tf?.textColor = UIColor.red
                        cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor;
                    }
                }
                arrRegistrationFields.append(cell as UITableViewCell)
                
            }
            
            if dict[kClassType]!.isEqual(to: "DropDownTxtFieldTableViewCell"){
                
                let metadataDict = dict[kMetaData] as! Dictionary<String,AnyObject>
                let cell = Bundle.main.loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! DropDownTxtFieldTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.delegate = self as? DropDownTxtFieldTableViewCellDelegate
                cell.tblView = tblView
                cell.dict = dict as NSDictionary
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor;
                let tfTitleDict = metadataDict[kTextField1] as! Dictionary<String,AnyObject>
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                    arrRegistrationFields.append(cell as UITableViewCell)
                }
                let arrDropDown = arrAddress
                cell.arr = arrDropDown
                
                if arrDropDown.count > 0
                {
                    arrRegistrationFields.append(cell as UITableViewCell)
                }
            }
        }
        
        tblViewHt.constant =  CGFloat(35 * (arrRegistrationFields.count + 5))
        let height: CGFloat = 35 * (CGFloat(arrRegistrationFields.count) + 5 ) + 130
        scrlView.contentSize = CGSize(width: self.view.frame.size.width, height: height)
        
        tblView.reloadData()
    }
    
    
    func resignAllTextfield(){
        for i in 0 ..< arrRegistrationFields.count {
            if arrRegistrationFields[i].isKind(of: TitleTableViewCell.self){
                let cell = arrRegistrationFields[i] as! TitleTableViewCell
                cell.endEditing(true)
                
                cell.tfName?.resignFirstResponder()
            }
            if arrRegistrationFields[i].isKind(of: TxtFieldTableViewCell.self){
                let cell = arrRegistrationFields[i] as! TxtFieldTableViewCell
                cell.endEditing(true)
                
                cell.tf?.resignFirstResponder()
                //                if cell.tf?.placeholder == "Surname"{
                //                    dict[kSecondName] = cell.tf?.text
                //                }
                //                if cell.tf?.placeholder == "First Address Line"{
                //                    dict[kAddress1] = cell.tf?.text
                //                }
                //                if cell.tf?.placeholder == "Second Address Line"{
                //                    dict[kAddress2] = cell.tf?.text
                //                }
                //                if cell.tf?.placeholder == "Third Address Line"{
                //                    dict[kAddress3] = cell.tf?.text
                //                }
                //                if cell.tf?.placeholder == "Town"{
                //                    dict[kTown] = cell.tf?.text
                //                }
                //                if cell.tf?.placeholder == "Mobile number"{
                //                    dict["phone_number"] = cell.tf?.text
                //                }
                //                if cell.tf?.placeholder == "County"{
                //                    dict[kCounty] = cell.tf?.text
                //                }
                //                if cell.tf?.placeholder == kEmail{
                //                    dict[kEmail] = cell.tf?.text
                //                }
            }
        }
    }
    
    func menuButtonClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    
    func heartBtnClicked(){
        
        if wishListArray.count > 0
        {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: kWishlistempty, message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func checkTextFieldContentSpecialChar(_ str:String)->Bool{
        let characterSet:CharacterSet = CharacterSet(charactersIn: "~!@#$%^&*()_-+={}|\\;:'\",.<>/*")
        if (str.rangeOfCharacter(from: characterSet) != nil) {
            return true
        }
        else {
            return false
        }
    }

    //MARK:- User Defined Methods for ButtonCellDelegate
    
    //Function checking textfield content only number or not
    
    func checkTextFieldContentOnlyNumber(_ str:String) -> Bool{
        let set = CharacterSet.decimalDigits
        return (str.rangeOfCharacter(from: set) != nil)
    }
    
    func checkTextFieldContentCharacters(_ str:String) -> Bool{
        let set = CharacterSet.letters
        return (str.rangeOfCharacter(from: set) != nil)
    }
    
//    Function invoke for validate the email
    
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
    
//     Function checking phoneNumberValidation
    
    func phoneNumberValidation(_ value: String) -> Bool {
        let charcter  = CharacterSet(charactersIn: "+0123456789").inverted
        var filtered:NSString!
        let inputString : NSArray = value.components(separatedBy: charcter) as [String] as NSArray
        
        filtered = inputString.componentsJoined(by: "") as NSString
        return  value == String(filtered)
    }

    
    func checkTextFiledValidation() -> Bool{
        var returnFlag = false
        self.getJSONForUI()
        var idx = 0
        for i in 0 ..< arrRegistrationFields.count {
            var errorFLag = false
            var errorMsg = ""
            var dict = Dictionary<String, AnyObject>()
            if arrRegistrationFields[i].isKind(of: TitleTableViewCell.self){
                let cell = arrRegistrationFields[i] as! TitleTableViewCell
                let str = cell.tfName?.text
                if let str = str {
                    if (self.checkTextFieldContentOnlyNumber(str) == true){
                        errorMsg = "Name should contain alphabets only"
                        if cell.tfTitle?.text?.characters.count==0 {
                            errorMsg = "Please select a title and name should contain alphabets only"
                        }
                        errorFLag = true
                        dictForTextFieldValue[kErrorTitle] = errorMsg as AnyObject
                    }
                    else if checkTextFieldContentSpecialChar(str){
                        errorMsg = "Name should not contain special characters"
                        if cell.tfTitle?.text?.characters.count==0 {
                            errorMsg = "Please select a title and name should not contain special characters"
                        }
                        errorFLag = true
                        dictForTextFieldValue[kErrorTitle] = errorMsg as AnyObject
                    }
                    else if (str.characters.count) > 50{
                        errorMsg = kLongName
                        errorFLag = true
                        dictForTextFieldValue[kErrorTitle] = errorMsg as AnyObject
                    }
                    else if(cell.tfTitle?.text?.characters.count == 0 && cell.tfName?.text?.characters.count == 0){
                        errorMsg = kTitleAndNameMissingError
                        errorFLag = true
                        cell.tfTitle?.layer.borderColor = UIColor.red.cgColor
                        cell.tfName?.layer.borderColor = UIColor.red.cgColor
                        dictForTextFieldValue[kErrorTitle] = errorMsg as AnyObject
                    }
                    else if cell.tfTitle?.text == ""{
                        errorMsg = kTitleEmpty
                        errorFLag = true
                        dictForTextFieldValue[kErrorTitle] = errorMsg as AnyObject
                    }
                    else if str == ""{
                        errorMsg = kEmptyName
                        errorFLag = true
                        dictForTextFieldValue[kErrorTitle] = errorMsg as AnyObject
                    }
                    else {
                        dictForTextFieldValue.removeValue(forKey: kErrorTitle)
                    }
                }
                
                dict = arrRegistration[1] as Dictionary<String,AnyObject>
                idx = 1
            }
            
            if arrRegistrationFields[i].isKind(of: TxtFieldTableViewCell.self){
                let cell = arrRegistrationFields[i] as! TxtFieldTableViewCell
                if cell.tf?.placeholder == kSurname{
                    let str = cell.tf?.text
                    
                    if let str = str{
                        
                        if str == ""{
                            errorFLag   = true
                            errorMsg    = "We need to know your surname"
                            dictForTextFieldValue["errorTxt"] = errorMsg as AnyObject
                        }
                        else {
                            dictForTextFieldValue.removeValue(forKey: "errorTxt")
                        }
                        if((str.characters.count) > 50){
                            errorMsg    = kLongName
                            errorFLag   = true
                            dictForTextFieldValue["errorSurname"] = errorMsg as AnyObject
                        }
                        else if(self.checkTextFieldContentOnlyNumber(str) == true){
                            errorMsg = "Surname should contain alphabets only"
                            errorFLag = true
                            dictForTextFieldValue["errorSurname"] = errorMsg as AnyObject
                        }
                        else if checkTextFieldContentSpecialChar(str){
                            errorMsg = "Surname should not contain special characters"
                            errorFLag = true
                            dictForTextFieldValue["errorSurname"] = errorMsg as AnyObject
                        }
                        else {
                            dictForTextFieldValue.removeValue(forKey: "errorSurname")
                        }
                        
                    }
                    
                    dict = arrRegistration[3] as Dictionary<String,AnyObject>
                    idx = 3
                }
                
                if cell.tf?.placeholder == kFirstAddressLine{
                    let str = cell.tf?.text
                    if str == "" {
                        errorFLag = true
                        errorMsg = "Don’t forget your house number"
                        dictForTextFieldValue["errorFirstAddress"] = errorMsg as AnyObject
                    }
                    else {
                        dictForTextFieldValue.removeValue(forKey: "errorFirstAddress")
                    }
                    dict = arrRegistration[10]as Dictionary<String,AnyObject>
                    idx = 10
                }
                
                if cell.tf?.placeholder == kTown {
                    let str = cell.tf?.text
                    if str == ""{
                        errorFLag = true
                        errorMsg = "Don’t forget your town"
                        dictForTextFieldValue["errorTown"] = errorMsg as AnyObject
                    }
                    else {
                        dictForTextFieldValue.removeValue(forKey: "errorTown")
                    }
                    dict = arrRegistration[14]as Dictionary<String,AnyObject>
                    idx = 14
                }
                
                if cell.tf?.placeholder == kCounty{
                    let str = cell.tf?.text
                    if str == ""{
                        errorFLag = true
                        errorMsg = "Don’t forget your county"
                        dictForTextFieldValue["errorCounty"] = errorMsg as AnyObject
                    }
                    else {
                        dictForTextFieldValue.removeValue(forKey: "errorCounty")
                    }
                    dict = arrRegistration[16]as Dictionary<String,AnyObject>
                    idx = 16
                }
                
                if cell.tf?.placeholder == kMobileNumber{
                    let str = cell.tf?.text
                    if str == "" {
                        errorFLag = true
                        errorMsg = "Don't forget your mobile number"
                        dictForTextFieldValue[kErrorMobileValidation] = errorMsg as AnyObject
                    }
                    else  if(self.checkTextFieldContentCharacters(str!) == true || self.phoneNumberValidation(str!)==false){
                        errorFLag = true
                        errorMsg = "That mobile number doesn’t look right"
                        dictForTextFieldValue[kErrorMobileValidation] = errorMsg as AnyObject
                    }
                    else if((str?.characters.count)! < 10)
                    {
                        errorFLag = true
                        errorMsg = "That mobile number should be greater than 10 digits"
                        dictForTextFieldValue[kErrorMobileValidation] = errorMsg as AnyObject
                    }
                    else if((str?.characters.count)! > 16)
                    {
                        errorFLag = true
                        errorMsg = "That mobile number should be of 15 digits"
                        dictForTextFieldValue[kErrorMobileValidation] = errorMsg as AnyObject
                    }
                    else {
                        dictForTextFieldValue.removeValue(forKey: kErrorMobileValidation)
                    }
                    dict = arrRegistration[19]as Dictionary<String,AnyObject>
                    idx = 19
                }
                
                if cell.tf?.placeholder == kEmail{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don't forget your email address"
                        dictForTextFieldValue["errorEmail"] = errorMsg as AnyObject
                    }
                    else {
                        dictForTextFieldValue.removeValue(forKey: "errorEmail")
                    }
                    if ((str?.characters.count)! > 0) && (self.isValidEmail(str!)==false){
                        errorFLag = true
                        errorMsg = "That email address doesn’t look right"
                        dictForTextFieldValue["errorEmailValid"] = errorMsg as AnyObject
                    }
                    else {
                        dictForTextFieldValue.removeValue(forKey: "errorEmailValid")
                    }
                    dict = arrRegistration[21] as Dictionary<String,AnyObject>
                    idx = 21
                }
                
            }
            
            if arrRegistrationFields[i].isKind(of: FindAddressTableViewCell.self){
                let cell = arrRegistrationFields[i] as! FindAddressTableViewCell
                let str = cell.tfPostCode?.text
                if str == "" {
                    errorFLag = true
                    errorMsg = "Don’t forget your postcode"
                    dictForTextFieldValue["errorPostcode"] = errorMsg as AnyObject
                    dictForTextFieldValue.removeValue(forKey: "errorPostcodeValid")
                    dictForTextFieldValue.removeValue(forKey: "Postcode")
                }
                else {
                    dictForTextFieldValue.removeValue(forKey: "errorPostcode")
                    dictForTextFieldValue.removeValue(forKey: "errorPostcodeValid")
                }
                dict = arrRegistration[7] as Dictionary<String,AnyObject>
                idx = 7
            }
            
            if arrRegistrationFields[i].isKind(of: NumericTextTableViewCell.self){
                let cell = arrRegistrationFields[i] as! NumericTextTableViewCell
                let str = cell.tf?.text
                
                if str == "" {
                    errorFLag = true
                    errorMsg = "Don't forget your mobile number"
                    dictForTextFieldValue[kErrorMobileValidation] = errorMsg as AnyObject
                }
                else  if(self.checkTextFieldContentCharacters(str!) == true || self.phoneNumberValidation(str!)==false){
                    errorFLag = true
                    errorMsg = "That mobile number doesn’t look right"
                    dictForTextFieldValue[kErrorMobileValidation] = errorMsg as AnyObject
                }
                else if((str?.characters.count)! < 10)
                {
                    errorFLag = true
                    errorMsg = "That mobile number should be greater than 10 digits"
                    dictForTextFieldValue[kErrorMobileValidation] = errorMsg as AnyObject
                }
                else if((str?.characters.count)! > 16)
                {
                    errorFLag = true
                    errorMsg = "That mobile number should be of 15 digits"
                    dictForTextFieldValue[kErrorMobileValidation] = errorMsg as AnyObject
                }
                else {
                    dictForTextFieldValue.removeValue(forKey: kErrorMobileValidation)
                }
                
                dict = arrRegistration[19] as Dictionary<String,AnyObject>
                idx = 19
                
            }
            if arrRegistrationFields[i].isKind(of: EmailTxtTableViewCell.self){
                let cell = arrRegistrationFields[i] as! EmailTxtTableViewCell
                let str = cell.tf?.text
                if str == "" {
                    errorFLag = true
                    errorMsg = "Don't forget your email address"
                    dictForTextFieldValue["errorEmail"] = errorMsg as AnyObject
                }
                else {
                    dictForTextFieldValue.removeValue(forKey: "errorEmail")
                }
                
                if ((str?.characters.count)! > 0) && (self.isValidEmail(str!)==false){
                    errorFLag = true
                    errorMsg = "That email address doesn’t look right"
                    dictForTextFieldValue["errorEmailValid"] = errorMsg as AnyObject
                }
                else {
                    dictForTextFieldValue.removeValue(forKey: "errorEmailValid")
                }
                dict = arrRegistration[21] as Dictionary<String,AnyObject>
                idx = 21
            }
            
            
            if arrRegistrationFields[i].isKind(of: PickerTextfildTableViewCell.self){
                let cell = arrRegistrationFields[i] as! PickerTextfildTableViewCell
                let str = cell.tfDatePicker?.text
                if str == "" {
                    errorFLag = true
                    errorMsg = "We need to know your date of birth"
                    dictForTextFieldValue["errorDOB"] = errorMsg as AnyObject
                }
                else {
                    dictForTextFieldValue.removeValue(forKey: "errorDOB")
                }
                dict = arrRegistration[5] as Dictionary<String,AnyObject>
                idx = 5
            }
            
            if(errorFLag == true){
                returnFlag = true
                var metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                
                let lableDict = NSMutableDictionary(dictionary: metadataDict[kLable] as! Dictionary<String,AnyObject>)
                lableDict.setValue("Yes", forKey: kIsErrorShow)
                
                if (errorMsg.characters.count > 0){
                    lableDict.setValue(errorMsg, forKey: kTitle)
                }
                metadataDict[kLable] = lableDict
                dict[kMetaData] = metadataDict as AnyObject
                arrRegistration[idx] = dict
            }
            
        }
        self.createCells()
        return returnFlag
    }
    
    func callEditUserInfoAPI()  {
        
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView!.frame = self.view.frame
        objAnimView?.animate()
        self.navigationController!.view.addSubview(objAnimView!)
        
        let objAPI = API()
        let dict = userDefaults.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        //        let dict = objAPI.getValueFromKeychainOfKey("userInfo")
        userInfoDict["ptyid"] = dict[kPartyID]
        if(isImageClicked) {
            let imageData:Data = UIImageJPEGRepresentation(image1!, 1.0)!
            let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let newDict = ["imageName.jpg":base64String]
            userInfoDict["imageurl"] = newDict as AnyObject
        }
        else {
            let newDict = ["imageName.jpg":""]
            userInfoDict["imageurl"] = newDict as AnyObject
        }
        
        let fName = userInfoDict[kFirstName] as! String
        let lName = userInfoDict[kSecondName] as! String
        
        var param = userInfoDict as Dictionary<String,AnyObject>
        param[kTown] = userInfoDict[kTown]
        param[kFirstName] = fName.capitalized as AnyObject
        param[kSecondName] = lName.capitalized as AnyObject
        param.removeValue(forKey: kTown)
        param["ptystatus"] = "ENABLE" as AnyObject
        
        param.removeValue(forKey: "date_of_birth")
        param.removeValue(forKey: "pass_code")
        param.removeValue(forKey: kEmail)
        param.removeValue(forKey: "confirm_pin")
        param.removeValue(forKey: kImageURL)
        param.removeValue(forKey: kPartyID)
        param.removeValue(forKey: "deviceRegistration")
        
        if (param[kFirstAddressLine] as? String) != nil {
            param.removeValue(forKey: kFirstAddressLine)
        }
        if (param[kSecondAddressLine] as? String) != nil {
            param.removeValue(forKey: kSecondAddressLine)
        }
        if (param[kThirdAddressLine] as? String) != nil {
            param.removeValue(forKey: kThirdAddressLine)
        }
        if (param["stripeCustomerId"] as? String) != nil {
            param.removeValue(forKey: "stripeCustomerId")
        }
        
        if (param[kCounty] as? String) != nil {
            param.removeValue(forKey: kCounty)
        }
        if (param["stripeStatusCode"] as? String) != nil {
            param.removeValue(forKey: "stripeStatusCode")
        }
        
        param.removeValue(forKey: kPhoneNumber)
        param.removeValue(forKey: "pin")
        param.removeValue(forKey: kSurname)
        param.removeValue(forKey: "party_role")
        param.removeValue(forKey: "partyRole")
        param.removeValue(forKey: "partyStatus")
        param.removeValue(forKey: "partyGender")
        objAPI.updateUserInfoDelegate = self as? UpdateUserInfoDelegate
        print(param)
        objAPI.updateUserInfo(param)
    }
    
    
    func getAllValuesFromTxtFild() -> Dictionary<String,AnyObject>{
        var dict = Dictionary<String, AnyObject>()
        
        for i in 0 ..< arrRegistrationFields.count {
            if arrRegistrationFields[i].isKind(of: TitleTableViewCell.self){
                let cell = arrRegistrationFields[i] as! TitleTableViewCell
                dict[kTitle] = cell.tfTitle?.text as AnyObject
                dict[kFirstName] = cell.tfName?.text as AnyObject
                
            }
            
            if arrRegistrationFields[i].isKind(of: TxtFieldTableViewCell.self){
                let cell = arrRegistrationFields[i] as! TxtFieldTableViewCell
                if cell.tf?.placeholder == kSurname{
                    dict[kSecondName] = cell.tf?.text as AnyObject
                }
                if cell.tf?.placeholder == kFirstAddressLine{
                    dict[kAddress1] = cell.tf?.text as AnyObject
                }
                if cell.tf?.placeholder == kSecondAddressLine{
                    dict[kAddress2] = cell.tf?.text as AnyObject
                }
                if cell.tf?.placeholder == kThirdAddressLine{
                    dict[kAddress3] = cell.tf?.text as AnyObject
                }
                if cell.tf?.placeholder == kTown{
                    dict[kTown] = cell.tf?.text as AnyObject
                }
                if cell.tf?.placeholder == kMobileNumber{
                    dict[kPhoneNumber] = cell.tf?.text as AnyObject
                }
                if cell.tf?.placeholder == kCounty{
                    dict[kCounty] = cell.tf?.text as AnyObject
                }
                if cell.tf?.placeholder == kEmail{
                    dict[kEmail] = cell.tf?.text as AnyObject
                }
            }
            
            if arrRegistrationFields[i].isKind(of: FindAddressTableViewCell.self){
                let cell = arrRegistrationFields[i] as! FindAddressTableViewCell
                dict[kPostCode] = cell.tfPostCode?.text as AnyObject
            }
            if arrRegistrationFields[i].isKind(of: NumericTextTableViewCell.self){
                let cell = arrRegistrationFields[i] as! NumericTextTableViewCell
                dict[kPhoneNumber] = cell.tf?.text as AnyObject
            }
            if arrRegistrationFields[i].isKind(of: EmailTxtTableViewCell.self){
                let cell = arrRegistrationFields[i] as! EmailTxtTableViewCell
                dict[kEmail] = cell.tf?.text as AnyObject
            }
            if arrRegistrationFields[i].isKind(of: PickerTextfildTableViewCell.self){
                let cell = arrRegistrationFields[i] as! PickerTextfildTableViewCell
                dict["date_of_birth"] = cell.tfDatePicker?.text as AnyObject
            }
            let udidDict : Dictionary<String,AnyObject> = ["DEVICE_ID":Device.udid as AnyObject]
            let udidArray: Array<Dictionary<String,AnyObject>> = [udidDict]
            dict["deviceRegistration"] =  udidArray as AnyObject
        }
        return dict
    }

    func switchKey<T, U>(_ myDict: inout [T:U], fromKey: T, toKey: T) {
        if let entry = myDict.removeValue(forKey: fromKey) {
            myDict[toKey] = entry
        }
    }
    
    
    //Go to Payment screen
    
    /*
     ["partyRole": 4, kTitle: Mr, "date_of_birth": 23/11/1998, kCounty:  London, kTown: <null>, "house_number": <null>, kSecondName: Labale, "partyStatus": ENABLE, kEmail: pavan@vsplc.com, "confirm_pin": <null>, "partyGender": <null>, kPostCode: se16at, kAddress2:  26 Arch Street, kFirstName: Pavan, "imageURL": <null>, "deviceRegistration": <__NSSingleObjectArrayI 0x60800020f8a0>(
     {
     COOKIE = "4ec3414a-19c1-439e-8136-90c852e613bc";
     "DEVICE_ID" = "631CB809-9288-4A30-BACC-632C604960B6";
     "DEV_ID" = 56;
     "PNS_DEVICE_ID" = "";
     "PTY_AUTH_PIN" = "<null>";
     STATUS = ENABLE;
     }
     )
     , kAddress3:  , "pass_code": 81dc9bdb52d04dc20036dbd8313ed055, kAddress1: Flat 11, "partyId": 1025, "phone_number": +441591591591, "stripeCustomerId": cus_9c8sDkhTRTzuPS, "stripeStatusCode": 01, "pin": 81dc9bdb52d04dc20036dbd8313ed055]*/
    
    @IBAction func addProfilePictureButtonPressed(_ sender: AnyObject) {
        
        self.resignAllTextfield()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertControllerStyle.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default)
        { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                
                self.imagePicker.delegate   = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.allowsEditing = true
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        })
        alertController.addAction(UIAlertAction(title: "Choose Photo", style: UIAlertActionStyle.default)
        { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                self.imagePicker.delegate   = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.imagePicker.allowsEditing = true
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkNullDataFromDict(_ dict:Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject> {
        var replaceDict: Dictionary<String,AnyObject> = dict
        let blank = ""
        //check each key's value
        for key in Array(dict.keys) {
            let ob = dict[key]! as? AnyObject
            //if value is Null or nil replace its value with blank
            if (ob is NSNull)  || (ob == nil) {
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
    
    
//   MARK:- User Defined Methods for UpdateUserInfoDelegate
    
    func changeMainDict() {
        userBeforeEditInfoDict[kTitle]      = userInfoDict[kTitle] as! String as AnyObject
        userBeforeEditInfoDict[kFirstName]  = userInfoDict[kFirstName] as! String as AnyObject
        userBeforeEditInfoDict[kSecondName] = userInfoDict[kSecondName] as! String as AnyObject
        userBeforeEditInfoDict[kAddress1]   = userInfoDict[kAddress1] as! String as AnyObject
        userBeforeEditInfoDict[kAddress2]   = userInfoDict[kAddress2] as! String as AnyObject
        userBeforeEditInfoDict[kAddress3]   = userInfoDict[kAddress3] as! String as AnyObject
        userBeforeEditInfoDict[kTown]       = userInfoDict[kTown] as! String as AnyObject
        userBeforeEditInfoDict[kCounty]     = userInfoDict[kCounty] as! String as AnyObject
        self.isInfoUpdated = false
    }
    
    func navigateToPayment() {
        isInfoUpdated = false
        let objSavedCardView = SASaveCardViewController()
        objSavedCardView.isFromEditUserInfo = true
        self.navigationController?.pushViewController(objSavedCardView, animated: true)
    }
    
    
    @IBAction func paymentButtonPressed(_ sender: UIButton) {
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        self.showAlt()
        
    }
    
    func showAlt() {
        
        let individualFlag = userDefaults.value(forKey: kIndividualPlan) as! NSNumber
        let groupFlag = userDefaults.value(forKey: kGroupPlan) as! NSNumber
        let groupMemberFlag = userDefaults.value(forKey: kGroupMemberPlan) as! NSNumber
        
        if(individualFlag == 1 || groupFlag == 1 || groupMemberFlag == 1)
        {
            let flagForUpdat: Bool = self.checkAnyInfoUpdatedFromPrevious()
            if (self.isInfoUpdated == true || flagForUpdat == true){
                
                let uiAlert = UIAlertController(title: "Alert", message: "Would you like to save the changes to your personal settings?", preferredStyle: UIAlertControllerStyle.alert)
                self.present(uiAlert, animated: true, completion: nil)
                
                uiAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                    print("Click of default button")
                    if let urlString = self.userInfoDict[kImageURL] as? String
                    {
                        if(urlString == "")
                        {
                            self.addProfilePictureButton.setImage(nil, for: UIControlState())
                            self.addProfilePictureButton.setTitle("Add\n profile\n picture", for: UIControlState())
                            self.addProfilePictureButton.titleLabel?.lineBreakMode =  NSLineBreakMode.byWordWrapping
                            self.addProfilePictureButton.titleLabel?.textAlignment = .center
                            self.addProfilePictureButton.titleLabel?.numberOfLines = 0
                        }
                    }
                    self.navigateToPayment()
                }))
                
                uiAlert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { action in
                    print("Click of cancel button")
                    self.isPressAlertYes = true
                    self.callEditUserInfoAPI()
                }))
            }
            else{
                self.navigateToPayment()
            }
            
        }else {
            let alert = UIAlertView(title: "Alert", message: "Please create saving plan first", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
    }
    
    func checkAnyInfoUpdatedFromPrevious()-> Bool {
        var updateFlag: Bool = false

        guard userBeforeEditInfoDict.count != 0 else {
            return updateFlag
        }
        
        let titleSTr = userBeforeEditInfoDict[kTitle] as! String
        let firstName = userBeforeEditInfoDict[kFirstName] as! String
        let lastName = userBeforeEditInfoDict[kSecondName] as! String
        let address1 = userBeforeEditInfoDict[kAddress1] as! String
        let address2 = userBeforeEditInfoDict[kAddress2] as! String
        let address3 = userBeforeEditInfoDict[kAddress3] as! String
        let town = userBeforeEditInfoDict[kTown] as! String
        let country = userBeforeEditInfoDict[kCounty] as! String
        
        
        if titleSTr != (userInfoDict[kTitle] as! String){
            updateFlag = true
        }
        
        if firstName != (userInfoDict[kFirstName] as! String){
            updateFlag = true
        }
        
        if lastName != (userInfoDict[kSecondName] as! String){
            updateFlag = true
        }
        
        if address1 != (userInfoDict[kAddress1] as! String){
            updateFlag = true
        }
        
        if address2 != (userInfoDict[kAddress2] as! String){
            updateFlag = true
        }
        
        if address3 != (userInfoDict[kAddress3] as! String){
            updateFlag = true
        }
        
        if town != (userInfoDict[kTown] as! String){
            updateFlag = true
        }
        
        if country != (userInfoDict[kCounty] as! String){
            updateFlag = true
        }
        return updateFlag
    }
    
}


// MARK:- GetUserInfoDelegate

extension SAEditUserInfoViewController: GetUserInfoDelegate {
    func successResponseForGetUserInfoAPI(_ objResponse: Dictionary<String, AnyObject>) {
        if let message = objResponse["message"] as? String {
            if(message == "Party Found")  {
                
                userInfoDict =  self.checkNullDataFromDict(objResponse["party"] as! Dictionary<String,AnyObject>)
                dictForTextFieldValue = self.checkNullDataFromDict(objResponse["party"] as! Dictionary<String,AnyObject>)
                
                //Get Registration UI Json data
                userBeforeEditInfoDict =  self.checkNullDataFromDict(objResponse["party"] as! Dictionary<String,AnyObject>)
                
                print(userBeforeEditInfoDict)
                let urlString = userInfoDict[kImageURL] as? String
                if urlString != ""
                {
                    let url = URL(string:urlString!)
                    let request: URLRequest = URLRequest(url: url!)
                    if(urlString != "")
                    {
                        
                        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                            print("Response: \(String(describing: response))")
                            if((data?.count)! > 0)
                            {
                                let image = UIImage(data: data!)
                                DispatchQueue.main.async(execute: {
                                    self.addProfilePictureButton.setImage(image, for: UIControlState())
                                    self.addProfilePictureButton.layer.cornerRadius = self.addProfilePictureButton.frame.size.height/2.0
                                    self.addProfilePictureButton.clipsToBounds = true
                                    self.spinner.stopAnimating()
                                    self.spinner.isHidden = true
                                })
                            }
                            else {
                                self.spinner.stopAnimating()
                                self.spinner.isHidden = true
                            }
                        })
                        
                        task.resume()
                        
                    }
                    else{
                        self.spinner.stopAnimating()
                        self.spinner.isHidden = true
                    }
                }
                else
                {
                    self.spinner.stopAnimating()
                    self.spinner.isHidden = true
                }
                
                self.getJSONForUI()
                //Setup Registration UI
                self.createCells()
                
            }
            else {
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        objAnimView!.removeFromSuperview()
    }
    
    func errorResponseForGetUserInfoAPI(_ error: String) {
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        objAnimView!.removeFromSuperview()
    }
}

//    MARK:- UITableviewDelegate and UITableViewDataSource

extension SAEditUserInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrRegistrationFields.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        return arrRegistrationFields[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.row == arrRegistrationFields.count - 1){
            return 55.0
        }
        
        return 35
    }
}

//    MARK:- TxtFieldTableViewCellDelegate

extension SAEditUserInfoViewController: TxtFieldTableViewCellDelegate {
    
    func txtFieldCellText(_ txtFldCell:TxtFieldTableViewCell){
        
        let textFieldCharCount = txtFldCell.tf?.text?.characters.count
        if (textFieldCharCount! > 0)
        {
            
            dictForTextFieldValue.updateValue((txtFldCell.tf?.text)! as AnyObject, forKey: (txtFldCell.tf?.placeholder)!)
            
            if(txtFldCell.tf?.placeholder == kSurname)
            {
                //userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: kSecondName)
                userInfoDict[kSecondName] = txtFldCell.tf?.text as AnyObject
            }
            else if(txtFldCell.tf?.placeholder == kFirstAddressLine)
            {
                userInfoDict.updateValue((txtFldCell.tf?.text)! as AnyObject, forKey: kAddress1)
            }
            else if(txtFldCell.tf?.placeholder == kTown)
            {
                userInfoDict.updateValue((txtFldCell.tf?.text)! as AnyObject, forKey: kTown)
            }
            else if(txtFldCell.tf?.placeholder == kCounty)
            {
                userInfoDict.updateValue((txtFldCell.tf?.text)! as AnyObject, forKey: kCounty)
            }
            else if(txtFldCell.tf?.placeholder == kSecondAddressLine)
            {
                userInfoDict.updateValue((txtFldCell.tf?.text)! as AnyObject, forKey: kAddress2)
            }
            else if(txtFldCell.tf?.placeholder == kThirdAddressLine)
            {
                userInfoDict.updateValue((txtFldCell.tf?.text)! as AnyObject, forKey: kAddress3)
            }
        }
        else {
            dictForTextFieldValue.removeValue(forKey: (txtFldCell.tf?.placeholder)!)
        }
    }
    
    func txtFieldCellTextImmediate(_ txtFldCell:TxtFieldTableViewCell, text: String){
        if text.characters.count > 0
        {
            
            dictForTextFieldValue.updateValue(text as AnyObject, forKey: (txtFldCell.tf?.placeholder)!)
            
            if(txtFldCell.tf?.placeholder == kSurname)
            {
                userInfoDict.updateValue(text as AnyObject, forKey: kSecondName)
            }
            else if(txtFldCell.tf?.placeholder == kFirstAddressLine)
            {
                userInfoDict.updateValue(text as AnyObject, forKey: kAddress1)
            }
            else if(txtFldCell.tf?.placeholder == kTown)
            {
                userInfoDict.updateValue(text as AnyObject, forKey: kTown)
            }
            else if(txtFldCell.tf?.placeholder == kCounty)
            {
                userInfoDict.updateValue(text as AnyObject, forKey: kCounty)
            }
            else if(txtFldCell.tf?.placeholder == kSecondAddressLine)
            {
                userInfoDict.updateValue(text as AnyObject, forKey: kAddress2)
            }
            else if(txtFldCell.tf?.placeholder == kThirdAddressLine)
            {
                userInfoDict.updateValue(text as AnyObject, forKey: kAddress3)
            }
        }
        else {
            dictForTextFieldValue.removeValue(forKey: (txtFldCell.tf?.placeholder)!)
        }
    }
}

//    MARK:- TitleTableViewCellDelegate

extension SAEditUserInfoViewController: TitleTableViewCellDelegate {
    
    func titleCellText(_ titleCell:TitleTableViewCell){
        if (titleCell.tfTitle?.text?.characters.count)!>0{
            dictForTextFieldValue.updateValue((titleCell.tfTitle?.text)! as AnyObject, forKey: kTitle)
        }
        if (titleCell.tfName?.text?.characters.count)!>0{
            dictForTextFieldValue.updateValue((titleCell.prevName as AnyObject), forKey: kName)
            userInfoDict.updateValue((titleCell.prevName as AnyObject), forKey: kFirstName)
        }
    }
}

//    MARK:- FindAddressCellDelegate

extension SAEditUserInfoViewController: FindAddressCellDelegate {
    
    func getTextFOrPostCode(_ findAddrCell: FindAddressTableViewCell)
    {
        if (findAddrCell.tfPostCode?.text?.characters.count)!>0{
            dictForTextFieldValue.updateValue((findAddrCell.tfPostCode?.text)! as AnyObject, forKey: (findAddrCell.tfPostCode?.placeholder)!)
            userInfoDict.updateValue((findAddrCell.tfPostCode?.text)! as AnyObject, forKey: kPostCode)
        }
    }
    
    func getAddressButtonClicked(_ findAddrCell: FindAddressTableViewCell){
        let strPostCode = (findAddrCell.tfPostCode?.text) ?? ""
        dictForTextFieldValue.updateValue(((findAddrCell.tfPostCode?.text) ?? "") as AnyObject, forKey: (findAddrCell.tfPostCode?.placeholder) ?? "")
        userInfoDict.updateValue(((findAddrCell.tfPostCode?.text) ?? "") as AnyObject, forKey: kPostCode)

        let strCode = strPostCode
        if  strCode.characters.count == 0 {
            var dict = arrRegistration[7] as Dictionary<String, AnyObject>
            var metadataDict = dict[kMetaData] as! Dictionary<String,AnyObject>
            
            let lableDict = NSMutableDictionary(dictionary: metadataDict[kLable] as! Dictionary<String,AnyObject>)
            lableDict.setValue("Yes", forKey: kIsErrorShow)
            lableDict.setValue("Don’t forget your postcode", forKey: kTitle)
            dictForTextFieldValue["errorPostcode"] = "Don’t forget your postcode" as AnyObject

            metadataDict[kLable] = lableDict
            dict[kMetaData] = metadataDict as AnyObject
            arrRegistration[7] = dict
            self.createCells()
        }
        else if checkTextFieldContentSpecialChar(strPostCode){
            var dict = arrRegistration[7] as Dictionary<String,AnyObject>
            var metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
            
            let lableDict = NSMutableDictionary(dictionary: metadataDict[kLable] as! Dictionary<String,AnyObject>)

            lableDict.setValue("Yes", forKey: kIsErrorShow)
            lableDict.setValue("That postcode doesn't look right", forKey: kTitle)
            metadataDict[kLable] = lableDict
            dict[kMetaData] = metadataDict as AnyObject
            dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right" as AnyObject
            arrRegistration[7] = dict
            self.createCells()
        }
        else {
            objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            objAnimView!.frame = self.view.frame
            objAnimView?.animate()
            self.view.addSubview(objAnimView!)
            
            let objGetAddressAPI: API = API()
            objGetAddressAPI.delegate = self as? PostCodeVerificationDelegate
            let trimmedString = strCode.replacingOccurrences(of: " ", with: "")
            objGetAddressAPI.verifyPostCode(trimmedString)
        }
        
    }
}

//    MARK:- ButtonCellDelegate

extension SAEditUserInfoViewController : ButtonCellDelegate
{
    func buttonOnCellClicked(_ sender:UIButton){
        
        if (dictForTextFieldValue["errorPostcodeValid"]==nil && self.checkTextFiledValidation() == false){
            //call term and condition screen
            var dict = self.getAllValuesFromTxtFild()
            if(firstName.characters.count > 0 ) && (lastName.characters.count > 0 )
            {
                for i in 0 ..< arrRegistrationFields.count {
                    if arrRegistrationFields[i].isKind(of: TitleTableViewCell.self){
                        let cell = arrRegistrationFields[i] as! TitleTableViewCell
                        dict[kTitle] = cell.tfTitle?.text as AnyObject
                        dict[kFirstName] = cell.tfName?.text as AnyObject
                        if(cell.tfTitle!.text == "Mr") {
                            dict["party_gender"] = "male" as AnyObject
                        }
                        else  {
                            dict["party_gender"] = "female" as AnyObject
                        }
                    }
                    if arrRegistrationFields[i].isKind(of: TitleTableViewCell.self){
                    }
                }
            }
            else {
                
                self.callEditUserInfoAPI()
            }
        }
        else {
            if dictForTextFieldValue["errorPostcodeValid"] != nil{
                
                var dict = arrRegistration[7] as Dictionary<String,AnyObject>
                var metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                
                let lableDict = NSMutableDictionary(dictionary: metadataDict[kLable] as! Dictionary<String,AnyObject>)
                lableDict.setValue("Yes", forKey: kIsErrorShow)
                lableDict.setValue("That postcode doesn't look right", forKey: kTitle)
                
                metadataDict[kLable] = lableDict
                dict[kMetaData] = metadataDict as AnyObject
                dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right" as AnyObject
                arrRegistration[7] = dict
                self.createCells()
            }
        }
    }
}

//    MARK:- PostCodeVerificationDelegate

extension SAEditUserInfoViewController : PostCodeVerificationDelegate {

    //PostCode Verification Delegate Method
    func success(_ addressArray:Array<String>){
        
        objAnimView?.removeFromSuperview()
        self.getJSONForUI()
        var dict = arrRegistration[8] as Dictionary<String,AnyObject>
        var metadataDict = dict[kMetaData] as! Dictionary<String,AnyObject>
        
        let lableDict = NSMutableDictionary(dictionary: metadataDict[kTextField1] as! Dictionary<String,AnyObject>)
        lableDict.setValue(addressArray, forKey: "dropDownArray")
        metadataDict[kTextField1] = lableDict
        
        dict[kMetaData] = metadataDict as AnyObject
        arrRegistration[8] = dict
        arrAddress = addressArray
        dictForTextFieldValue.removeValue(forKey: "errorPostcodeValid")
        
        self.createCells()
        
    }
    
    func error(_ error:String){
        objAnimView?.removeFromSuperview()
        if(error == "That postcode doesn't look right"){
            var dict            = arrRegistration[7] as Dictionary<String,AnyObject>
            var metadataDict    = dict[kMetaData] as! Dictionary<String,AnyObject>
            
            let lableDict = NSMutableDictionary(dictionary: metadataDict[kLable] as! Dictionary<String,AnyObject>)
            lableDict.setValue("Yes", forKey: kIsErrorShow)
            lableDict.setValue(error, forKey: kTitle)
            
            metadataDict[kLable] = lableDict
            dict[kMetaData] = metadataDict as AnyObject
            dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right" as AnyObject
            arrRegistration[7] = dict
            
            self.createCells()
        }
        else {
            let alert = UIAlertController(title: error, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func successResponseForRegistrationAPI(_ objResponse:Dictionary<String,AnyObject>){
        
    }
    func errorResponseForRegistrationAPI(_ error:String){
        
    }

}

//    MARK:- DropDownTxtFieldTableViewCellDelegate

extension SAEditUserInfoViewController : DropDownTxtFieldTableViewCellDelegate
{

    func dropDownTxtFieldCellText(_ dropDownTextCell:DropDownTxtFieldTableViewCell)
    {
        let str = dropDownTextCell.tf?.text
        let fullNameArr = str!.characters.split{$0 == ","}.map(String.init)
        
        dictForTextFieldValue.updateValue(fullNameArr[0] as AnyObject, forKey: kFirstAddressLine)
        dictForTextFieldValue.updateValue(fullNameArr[1] as AnyObject, forKey: kSecondAddressLine)
        dictForTextFieldValue.updateValue(fullNameArr[fullNameArr.count-3] as AnyObject, forKey: kThirdAddressLine)
        dictForTextFieldValue.updateValue(fullNameArr[fullNameArr.count-2] as AnyObject, forKey: kTown)
        dictForTextFieldValue.updateValue(fullNameArr[fullNameArr.count-1] as AnyObject, forKey: kCounty)
        
        userInfoDict.updateValue(fullNameArr[0] as AnyObject, forKey: kAddress1)
        userInfoDict.updateValue(fullNameArr[1] as AnyObject, forKey: kAddress2)
        userInfoDict.updateValue(fullNameArr[fullNameArr.count-3] as AnyObject, forKey: kAddress3)
        userInfoDict.updateValue(fullNameArr[fullNameArr.count-2] as AnyObject, forKey: kTown)
        userInfoDict.updateValue(fullNameArr[fullNameArr.count-1] as AnyObject, forKey: kCounty)
        print(userInfoDict)
        self.createCells()
    }

}

//      MARK:-    PickerTxtFieldTableViewCellDelegate

extension SAEditUserInfoViewController : PickerTxtFieldTableViewCellDelegate {

    func selectedDate(_ txtFldCell:PickerTextfildTableViewCell){
        dictForTextFieldValue.updateValue((txtFldCell.tfDatePicker?.text)! as AnyObject, forKey: (txtFldCell.tfDatePicker?.placeholder)!)
    }

}

//      MARK:-    ImportantInformationViewDelegate

extension SAEditUserInfoViewController : ImportantInformationViewDelegate {
    
    func acceptPolicy(_ obj:ImportantInformationView){
        var dict = self.getAllValuesFromTxtFild()
        let objAPI = API()
        if(changePhoneNumber == false)
        {
            objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            objAnimView!.frame = self.view.frame
            objAnimView?.animate()
            self.view.addSubview(objAnimView!)
            objAPI.delegate = self
            objAPI.registerTheUserWithTitle(dict,apiName: "Customers")
            return
        }
        else {
            //            if(objAPI.getValueFromKeychainOfKey("myMobile") as! String == dict["phone_number"] as! String)
            if(userDefaults.object(forKey: "myMobile") as! String == dict[kPhoneNumber] as! String)
            {
                objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
                objAnimView!.frame = self.view.frame
                objAnimView?.animate()
                self.view.addSubview(objAnimView!)
                objAPI.delegate = self
                objAPI.registerTheUserWithTitle(dict,apiName: "Customers")
            }
            else {
                let alert = UIAlertController(title: "Looks like you have an earlier enrolled mobile number", message: "", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}

//      MARK:-      NumericTxtTableViewCellDelegate

extension SAEditUserInfoViewController : NumericTxtTableViewCellDelegate {

    func numericCellText(_ txtFldCell: NumericTextTableViewCell) {
        dictForTextFieldValue.updateValue((txtFldCell.tf?.text)! as AnyObject, forKey: (txtFldCell.tf?.placeholder)!)
        userInfoDict.updateValue((txtFldCell.tf?.text)! as AnyObject, forKey: "mobile-number")
    }

}

//      MARK:-      EmailTxtTableViewCellDelegate

extension SAEditUserInfoViewController : EmailTxtTableViewCellDelegate {

    func emailCellText(_ txtFldCell:EmailTxtTableViewCell){
        dictForTextFieldValue.updateValue((txtFldCell.tf?.text)! as AnyObject, forKey: (txtFldCell.tf?.placeholder)!)
        userInfoDict.updateValue((txtFldCell.tf?.text)! as AnyObject, forKey: kEmail)
    }
    
    func emailCellTextImmediate(_ txtFldCell:EmailTxtTableViewCell, text: String) {
        
    }

}

//      MARK:-  UIImagePickerControllerDelegate

extension SAEditUserInfoViewController : UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker .dismiss(animated: true, completion: nil)
        isImageClicked = true
        
        image1 = info[UIImagePickerControllerEditedImage] as? UIImage
        
        addProfilePictureButton.setImage((info[UIImagePickerControllerEditedImage] as? UIImage), for: UIControlState())
        addProfilePictureButton.layer.cornerRadius = addProfilePictureButton.frame.size.height/2.0
        addProfilePictureButton.setTitle("", for: UIControlState())
        addProfilePictureButton.clipsToBounds = true
        isInfoUpdated = true
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker .dismiss(animated: true, completion: nil)
    }

}

//      MARK:-  UpdateUserInfoDelegate

extension SAEditUserInfoViewController :  UpdateUserInfoDelegate {

    func successResponseForUpdateUserInfoAPI(_ objResponse: Dictionary<String, AnyObject>) {
        objAnimView?.removeFromSuperview()
        if let message = objResponse["message"] as? String
        {
            if(message == "UserData Updated Successfully")
            {
                //                let alert = UIAlertView(title: "Updated", message: "Personal details updated", delegate: nil, cancelButtonTitle: "Ok")
                //                alert.show()
                self.changeMainDict()
                self.createCells()
                
                let uiAlert = UIAlertController(title: "Updated", message: "Personal details updated", preferredStyle: UIAlertControllerStyle.alert)
                self.present(uiAlert, animated: true, completion: nil)
                
                uiAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    print("Click of default button")
                    if self.isPressAlertYes{
                        self.navigateToPayment()
                        self.isPressAlertYes = false
                    }
                }))
                
            }
            else {
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else if let message = objResponse["message"] as? String {
            let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else if let message = objResponse["internalMessage"] as? String {
            let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func errorResponseForUpdateUserInfoAPI(_ error: String) {
        objAnimView?.removeFromSuperview()
        if error == "Network not available" {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: "Timeout", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }

}
