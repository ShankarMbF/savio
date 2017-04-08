//
//  SAEditUserInfoViewController.swift
//  Savio
//
//  Created by Vishal  on 11/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAEditUserInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,TxtFieldTableViewCellDelegate,TitleTableViewCellDelegate,FindAddressCellDelegate,ButtonCellDelegate,PostCodeVerificationDelegate,DropDownTxtFieldTableViewCellDelegate,PickerTxtFieldTableViewCellDelegate,ImportantInformationViewDelegate,NumericTxtTableViewCellDelegate,EmailTxtTableViewCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GetUserInfoDelegate,UpdateUserInfoDelegate{
    
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addProfilePictureButton: UIButton!
    @IBOutlet weak var contentViewHt: NSLayoutConstraint!
    @IBOutlet weak var tblViewHt: NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!
    
    var arrRegistration  = [Dictionary <String, AnyObject>]()     //Array for hold json file data to create UI
    var arrRegistrationFields = [UITableViewCell]()               //Array of textfield cell
    var dictForTextFieldValue : Dictionary<String, AnyObject> = [:] // dictionary for saving user data and error messages
    var objAnimView : ImageViewAnimation?                     //Instance of ImageViewAnimation to showing loding aniation on API call
    var arrAddress = [String]()
    var firstName = ""
    var lastName = ""
    var dateOfBirth = ""
    var phoneNumber = ""
    var editUser = true
    var isImageClicked = false
    var image1 = UIImage(named: "img1")
    var getUserInfoDelegate = GetUserInfoDelegate.self
    var imagePicker = UIImagePickerController()
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var userInfoDict : Dictionary<String,AnyObject> = [:]
    var userBeforeEditInfoDict : Dictionary<String,AnyObject> = [:]
    var isInfoUpdated: Bool = false
    var isPressAlertYes: Bool = false
//    var isPressAlertYes: Bool = false
    var queue = NSOperationQueue()
    
    let kFirstName : String = "first_name"
    let kSecondName : String = "second_name"
    let kAddress1 : String = "address_1"
    let kAddress2 : String = "address_2"
    let kAddress3 : String = "address_3"
    let kTown : String  = "town"
    let kCounty : String = "county"
    let kPostCode : String = "post_code"
    let kName : String = "name"
    let kTextField1 : String = "textField1"
    
//    let kTitleAndNameMissingError : String = "We need to know your title and name"
    
    
    
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        addProfilePictureButton.setTitle("Add\n profile\n picture", forState: .Normal)
        addProfilePictureButton.titleLabel?.lineBreakMode =  NSLineBreakMode.ByWordWrapping
        addProfilePictureButton.titleLabel?.textAlignment = .Center
        addProfilePictureButton.titleLabel?.numberOfLines = 0
        addProfilePictureButton.layer.cornerRadius = addProfilePictureButton.frame.size.height/2
        self.setUPNavigation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isInfoUpdated == false {
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView!.frame = self.view.frame
        objAnimView!.animate()
        self.view.addSubview(objAnimView!)
        
        let objAPI = API()
        objAPI.getUserInfoDelegate = self
        objAPI.getUserInfo()
        }
    }
    
    func setUPNavigation()
    {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: #selector(SAEditUserInfoViewController.menuButtonClicked), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "Personal settings"
        //set Navigation right button nav-heart
        
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: #selector(SAEditUserInfoViewController.heartBtnClicked), forControlEvents: .TouchUpInside)
        
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
        
    }
    
    func getJSONForUI(){
        //create file url
        let fileUrl: NSURL = NSBundle.mainBundle().URLForResource("Registration", withExtension: "json")!
        //getting file data
        let jsonData: NSData = NSData(contentsOfURL: fileUrl)!
        //parsing json file to setup UI
        let json = (try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments))
        self.arrRegistration = json as! Array
    }
    
    func createCells(){
        // if any old cell belong in array then remove all
        if arrRegistrationFields.count>0{
            arrRegistrationFields.removeAll()
        }
        for i in 0 ..< arrRegistration.count {
            // dictionary to identifying cell and its properies
            let dict = arrRegistration[i] as Dictionary<String,AnyObject>
            //get tableviewCell as per the classtype
            
            //Setup all error message lable tableViewCell
            if dict[kClassType]!.isEqualToString("ErrorTableViewCell"){
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = NSBundle.mainBundle().loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! ErrorTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
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
            if dict[kClassType]!.isEqualToString("TitleTableViewCell"){
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = NSBundle.mainBundle().loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! TitleTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.dict = dict
                let tfTitleDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                cell.tfTitle?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                cell.tfName?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                
                cell.tfTitle!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                if(editUser)
                {
                    cell.tfTitle!.userInteractionEnabled = false
                    cell.tfTitle?.text = userInfoDict[kTitle] as? String
                    
                }
                if (dictForTextFieldValue[kTitle] != nil){
                    cell.tfTitle?.text = dictForTextFieldValue[kTitle] as? String
                }
                let tfNameDict = metadataDict["textField2"]as! Dictionary<String,AnyObject>
                cell.tfName!.attributedPlaceholder = NSAttributedString(string:(tfNameDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if(editUser)
                {
                    cell.tfName?.text = userInfoDict[kFirstName] as? String
                }
                if (dictForTextFieldValue[kName] != nil){
                    cell.tfName?.text = dictForTextFieldValue[kName] as? String
                }
                
                if (dictForTextFieldValue[kErrorTitle] != nil) {
                    if dictForTextFieldValue[kErrorTitle]!.isEqualToString(kTitleAndNameMissingError){
                        cell.tfName?.layer.borderColor = UIColor.redColor().CGColor
                        cell.tfTitle?.layer.borderColor = UIColor.redColor().CGColor
                    }
                    else if dictForTextFieldValue[kErrorTitle]!.isEqualToString(kTitleEmpty){
                        cell.tfTitle?.layer.borderColor = UIColor.redColor().CGColor
                    }
                    else if dictForTextFieldValue[kErrorTitle]!.isEqualToString(kEmptyName){
                        cell.tfName?.layer.borderColor = UIColor.redColor().CGColor
                    }
                    else if (dictForTextFieldValue[kErrorTitle]!.isEqualToString(kLongName) || dictForTextFieldValue[kErrorTitle]!.isEqualToString("Surname should contain character only") ){
                        cell.tfName?.textColor = UIColor.redColor()
                    }
                }
                arrRegistrationFields.append(cell as UITableViewCell)
                
            }
            if dict[kClassType]!.isEqualToString("TxtFieldTableViewCell"){
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = NSBundle.mainBundle().loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! TxtFieldTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.tf?.textColor = UIColor.blackColor()
                
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                
                
                let tfTitleDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorTxt"] != nil && cell.tf?.placeholder == kSurname) {
                    let str = dictForTextFieldValue["errorTxt"]
                    if (str!.isEqualToString("We need to know your surname")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                
                if (dictForTextFieldValue["errorSurname"] != nil && cell.tf?.placeholder == kSurname) {
                    let str = dictForTextFieldValue["errorSurname"]
                    if (str!.isEqualToString(kLongName)){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                    }
                }
                
                if (dictForTextFieldValue["errorFirstAddress"] != nil && cell.tf?.placeholder == kFirstAddressLine) {
                    let str = dictForTextFieldValue["errorFirstAddress"]
                    if (str!.isEqualToString("Don’t forget your house number")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorTown"] != nil && cell.tf?.placeholder == kTown) {
                    let str = dictForTextFieldValue["errorTown"]
                    if (str!.isEqualToString("Don’t forget your town")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorCounty"] != nil && cell.tf?.placeholder == kCounty) {
                    let str = dictForTextFieldValue["errorCounty"]
                    if (str!.isEqualToString("Don’t forget your county")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorMobile"] != nil && cell.tf?.placeholder == kMobileNumber) {
                    let str = dictForTextFieldValue["errorMobile"]
                    if (str!.isEqualToString("Don't forget your mobile number")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue[kErrorMobileValidation] != nil && cell.tf?.placeholder == kMobileNumber) {
                    let str = dictForTextFieldValue[kErrorMobileValidation]
                    if (str!.isEqualToString("That mobile number doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                    }
                }
                if (dictForTextFieldValue["errorEmail"] != nil && cell.tf?.placeholder == kEmail) {
                    let str = dictForTextFieldValue["errorEmail"]
                    if (str!.isEqualToString("Don't forget your email address")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorEmailValid"] != nil && cell.tf?.placeholder == kEmail) {
                    let str = dictForTextFieldValue["errorEmailValid"]
                    if (str!.isEqualToString("That email address doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
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
                    else if(cell.tf?.placeholder == kTown)
                    {
                        cell.tf?.text = userInfoDict[kTown] as? String
                    }
                    else if(cell.tf?.placeholder == kCounty)
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
            
            if dict[kClassType]!.isEqualToString("PickerTextfildTableViewCell"){
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = NSBundle.mainBundle().loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! PickerTextfildTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                let tfTitleDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                cell.tfDatePicker!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if(editUser)
                {
                    cell.tfDatePicker.userInteractionEnabled = false
                    cell.tfDatePicker.text = userInfoDict["date_of_birth"] as? String
                }
                cell.tfDatePicker?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                if (dictForTextFieldValue[(cell.tfDatePicker?.placeholder)!] != nil){
                    cell.tfDatePicker?.text = dictForTextFieldValue[(cell.tfDatePicker?.placeholder)!] as? String
                }
                arrRegistrationFields.append(cell as UITableViewCell)
            }
            
            if dict[kClassType]!.isEqualToString("FindAddressTableViewCell"){
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = NSBundle.mainBundle().loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! FindAddressTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.tfPostCode?.text = userInfoDict[kPostCode] as? String
                cell.tfPostCode?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                let tfPostcodeDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                cell.tfPostCode!.attributedPlaceholder = NSAttributedString(string:(tfPostcodeDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tfPostCode?.placeholder)!] != nil){
                    cell.tfPostCode?.text = dictForTextFieldValue[(cell.tfPostCode?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorPostcode"] != nil) {
                    if dictForTextFieldValue["errorPostcode"]!.isEqualToString("Don’t forget your postcode"){
                        cell.tfPostCode?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                
                if (dictForTextFieldValue["errorPostcodeValid"] != nil) {
                    if dictForTextFieldValue["errorPostcodeValid"]!.isEqualToString("That postcode doesn't look right"){
                        cell.tfPostCode?.textColor = UIColor.redColor()
                    }
                }
                
                let btnPostcodeDict = metadataDict["button"]as! Dictionary<String,AnyObject>
                cell.btnPostCode?.setTitle(btnPostcodeDict["placeholder"] as? String, forState: UIControlState.Normal)
                arrRegistrationFields.append(cell as UITableViewCell)
            }
            
            if dict[kClassType]!.isEqualToString("ButtonTableViewCell"){
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = NSBundle.mainBundle().loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! ButtonTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.btn?.setTitle("Save", forState: UIControlState.Normal)
                arrRegistrationFields.append(cell as UITableViewCell)
            }
            
            if dict[kClassType]!.isEqualToString("NumericTextTableViewCell"){
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = NSBundle.mainBundle().loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! NumericTextTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.tf?.textColor = UIColor.blackColor()
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                cell.tf!.userInteractionEnabled = false
                cell.tf?.text = userInfoDict[kPhoneNumber] as? String
                let tfTitleDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorMobile"] != nil && cell.tf?.placeholder == kMobileNumber) {
                    let str = dictForTextFieldValue["errorMobile"]
                    if (str!.isEqualToString("Don't forget your mobile number")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue[kErrorMobileValidation] != nil && cell.tf?.placeholder == kMobileNumber) {
                    let str = dictForTextFieldValue[kErrorMobileValidation]
                    if (str!.isEqualToString("That mobile number doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                    }
                }
                arrRegistrationFields.append(cell as UITableViewCell)
            }
            
            if dict[kClassType]!.isEqualToString("EmailTxtTableViewCell"){
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = NSBundle.mainBundle().loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! EmailTxtTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.tf?.textColor = UIColor.blackColor()
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                cell.tf?.text = userInfoDict[kEmail] as? String
                cell.tf?.userInteractionEnabled = false
                
                let tfTitleDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorEmail"] != nil && cell.tf?.placeholder == kEmail) {
                    let str = dictForTextFieldValue["errorEmail"]
                    if (str!.isEqualToString("Don't forget your email address")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorEmailValid"] != nil && cell.tf?.placeholder == kEmail) {
                    let str = dictForTextFieldValue["errorEmailValid"]
                    if (str!.isEqualToString("That email address doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                    }
                }
                arrRegistrationFields.append(cell as UITableViewCell)
                
            }
            
            if dict[kClassType]!.isEqualToString("DropDownTxtFieldTableViewCell"){
                let metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let cell = NSBundle.mainBundle().loadNibNamed(dict[kClassType] as! String, owner: nil, options: nil)![0] as! DropDownTxtFieldTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.dict = dict
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                let tfTitleDict = metadataDict[kTextField1]as! Dictionary<String,AnyObject>
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                    arrRegistrationFields.append(cell as UITableViewCell)
                }
                let arrDropDown = arrAddress
                cell.arr = arrDropDown
                if arrDropDown.count>0{
                    arrRegistrationFields.append(cell as UITableViewCell)
                }
            }
        }
        
        tblViewHt.constant =  CGFloat(35 * (arrRegistrationFields.count+5))
        let height: CGFloat = 35 * (CGFloat(arrRegistrationFields.count) + 5 ) + 130
        scrlView.contentSize = CGSizeMake(0, height)
        
        tblView.reloadData()
    }
    
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        
        if wishListArray.count>0{
            NSNotificationCenter.defaultCenter().postNotificationName(kSelectRowIdentifier, object: "SAWishListViewController")
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: kWishlistempty, message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //MARK: -UITableviewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrRegistrationFields.count;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        return arrRegistrationFields[indexPath.row]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(indexPath.row == arrRegistrationFields.count - 1){
            return 55.0
        }
        
        return 35
    }
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker .dismissViewControllerAnimated(true, completion: nil)
        isImageClicked = true
        
        image1 = info[UIImagePickerControllerEditedImage] as? UIImage
        
        addProfilePictureButton.setImage((info[UIImagePickerControllerEditedImage] as? UIImage), forState: .Normal)
        addProfilePictureButton.layer.cornerRadius = addProfilePictureButton.frame.size.height/2.0
        addProfilePictureButton.setTitle("", forState: .Normal)
        addProfilePictureButton.clipsToBounds = true
        isInfoUpdated = true
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func selectedDate(txtFldCell:PickerTextfildTableViewCell){
        dictForTextFieldValue.updateValue((txtFldCell.tfDatePicker?.text)!, forKey: (txtFldCell.tfDatePicker?.placeholder)!)
    }
    
    
    func switchKey<T, U>(inout myDict: [T:U], fromKey: T, toKey: T) {
        if let entry = myDict.removeValueForKey(fromKey) {
            myDict[toKey] = entry
        }
    }
    
    func txtFieldCellText(txtFldCell:TxtFieldTableViewCell){
        if txtFldCell.tf?.text?.characters.count>0{
            
            dictForTextFieldValue.updateValue((txtFldCell.tf?.text)!, forKey: (txtFldCell.tf?.placeholder)!)
            
            if(txtFldCell.tf?.placeholder == kSurname)
            {
//                 userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: kSecondName)
                userInfoDict[kSecondName] = txtFldCell.tf?.text
            }
            else if(txtFldCell.tf?.placeholder == kFirstAddressLine)
            {
                 userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: kAddress1)
            }
            else if(txtFldCell.tf?.placeholder == kTown)
            {
                 userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: kTown)
            }
            else if(txtFldCell.tf?.placeholder == kCounty)
            {
                 userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: kCounty)
            }
            else if(txtFldCell.tf?.placeholder == kSecondAddressLine)
            {
                 userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: kAddress2)
            }
            else if(txtFldCell.tf?.placeholder == kThirdAddressLine)
            {
                 userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: kAddress3)
            }
        }
        else {
            dictForTextFieldValue.removeValueForKey((txtFldCell.tf?.placeholder)!)
        }
    }
    
    func titleCellText(titleCell:TitleTableViewCell){
        if titleCell.tfTitle?.text?.characters.count>0{
            dictForTextFieldValue.updateValue((titleCell.tfTitle?.text)!, forKey: kTitle)
        }
        if titleCell.tfName?.text?.characters.count>0{
            dictForTextFieldValue.updateValue((titleCell.prevName), forKey: kName)
            userInfoDict.updateValue((titleCell.prevName), forKey: kFirstName)
        }
    }
    

    
    func getTextFOrPostCode(findAddrCell: FindAddressTableViewCell)
    {
        if findAddrCell.tfPostCode?.text?.characters.count>0{
            dictForTextFieldValue.updateValue((findAddrCell.tfPostCode?.text)!, forKey: (findAddrCell.tfPostCode?.placeholder)!)
            userInfoDict.updateValue((findAddrCell.tfPostCode?.text)!, forKey: kPostCode)
        }
    }
    
    func getAddressButtonClicked(findAddrCell: FindAddressTableViewCell){
        let strPostCode = (findAddrCell.tfPostCode?.text)!
        dictForTextFieldValue.updateValue((findAddrCell.tfPostCode?.text)!, forKey: (findAddrCell.tfPostCode?.placeholder)!)
        userInfoDict.updateValue((findAddrCell.tfPostCode?.text)!, forKey: kPostCode)
        
        let strCode = strPostCode
        if strCode.characters.count == 0 {
            var dict = arrRegistration[7] as Dictionary<String,AnyObject>
            var metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
            let lableDict = metadataDict[kLable]!.mutableCopy()
            lableDict.setValue("Yes", forKey: kIsErrorShow)
            lableDict.setValue("Don’t forget your postcode", forKey: kTitle)
            dictForTextFieldValue["errorPostcode"] = "Don’t forget your postcode"
            
            metadataDict[kLable] = lableDict
            dict[kMetaData] = metadataDict
            arrRegistration[7] = dict
            self.createCells()
        }
        else if checkTextFieldContentSpecialChar(strPostCode){
            var dict = arrRegistration[7] as Dictionary<String,AnyObject>
            var metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
            let lableDict = metadataDict[kLable]!.mutableCopy()
            lableDict.setValue("Yes", forKey: kIsErrorShow)
            lableDict.setValue("That postcode doesn't look right", forKey: kTitle)
            metadataDict[kLable] = lableDict
            dict[kMetaData] = metadataDict
            dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right"
            arrRegistration[7] = dict
            self.createCells()
        }
        else {
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            objAnimView!.frame = self.view.frame
            objAnimView?.animate()
            self.view.addSubview(objAnimView!)
            
            let objGetAddressAPI: API = API()
            objGetAddressAPI.delegate = self
            let trimmedString = strCode.stringByReplacingOccurrencesOfString(" ", withString: "")
            objGetAddressAPI.verifyPostCode(trimmedString)
        }
        
    }
    
    func dropDownTxtFieldCellText(dropDownTextCell:DropDownTxtFieldTableViewCell)
    {
        
        let str = dropDownTextCell.tf?.text
        let fullNameArr = str!.characters.split{$0 == ","}.map(String.init)
        
        dictForTextFieldValue.updateValue(fullNameArr[0], forKey: kFirstAddressLine)
        dictForTextFieldValue.updateValue(fullNameArr[1], forKey: kSecondAddressLine)
        dictForTextFieldValue.updateValue(fullNameArr[fullNameArr.count-3], forKey: kThirdAddressLine)
        dictForTextFieldValue.updateValue(fullNameArr[fullNameArr.count-2], forKey: kTown)
        dictForTextFieldValue.updateValue(fullNameArr[fullNameArr.count-1], forKey: kCounty)
        
        userInfoDict.updateValue(fullNameArr[0], forKey: kAddress1)
        userInfoDict.updateValue(fullNameArr[1], forKey: kAddress2)
        userInfoDict.updateValue(fullNameArr[fullNameArr.count-3], forKey: kAddress3)
        userInfoDict.updateValue(fullNameArr[fullNameArr.count-2], forKey: kTown)
        userInfoDict.updateValue(fullNameArr[fullNameArr.count-1], forKey: kCounty)
        print(userInfoDict)
        self.createCells()
    }
    
    
    func numericCellText(txtFldCell: NumericTextTableViewCell) {
        dictForTextFieldValue.updateValue((txtFldCell.tf?.text)!, forKey: (txtFldCell.tf?.placeholder)!)
        userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: "mobile-number")
    }
    
    func emailCellText(txtFldCell:EmailTxtTableViewCell){
        dictForTextFieldValue.updateValue((txtFldCell.tf?.text)!, forKey: (txtFldCell.tf?.placeholder)!)
        userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: kEmail)
    }
    func emailCellTextImmediate(txtFldCell:EmailTxtTableViewCell, text: String) {
        
    }
    
    func txtFieldCellTextImmediate(txtFldCell:TxtFieldTableViewCell, text: String){
        if text.characters.count>0{
            
            dictForTextFieldValue.updateValue(text, forKey: (txtFldCell.tf?.placeholder)!)
            
            if(txtFldCell.tf?.placeholder == kSurname)
            {
                userInfoDict.updateValue(text, forKey: kSecondName)
            }
            else if(txtFldCell.tf?.placeholder == kFirstAddressLine)
            {
                userInfoDict.updateValue(text, forKey: kAddress1)
            }
            else if(txtFldCell.tf?.placeholder == kTown)
            {
                userInfoDict.updateValue(text, forKey: kTown)
            }
            else if(txtFldCell.tf?.placeholder == kCounty)
            {
                userInfoDict.updateValue(text, forKey: kCounty)
            }
            else if(txtFldCell.tf?.placeholder == kSecondAddressLine)
            {
                userInfoDict.updateValue(text, forKey: kAddress2)
            }
            else if(txtFldCell.tf?.placeholder == kThirdAddressLine)
            {
                userInfoDict.updateValue(text, forKey: kAddress3)
            }
        }
        else {
            dictForTextFieldValue.removeValueForKey((txtFldCell.tf?.placeholder)!)
        }
    }
    
    
    func buttonOnCellClicked(sender:UIButton){
        
        if (dictForTextFieldValue["errorPostcodeValid"]==nil && checkTextFiledValidation() == false){
            //call term and condition screen
            var dict = self.getAllValuesFromTxtFild()
            if(firstName.characters.count>0 && lastName.characters.count>0 )
            {
                for i in 0 ..< arrRegistrationFields.count {
                    if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                        let cell = arrRegistrationFields[i] as! TitleTableViewCell
                        dict[kTitle] = cell.tfTitle?.text
                        dict[kFirstName] = cell.tfName?.text
                        if(cell.tfTitle!.text == "Mr") {
                            dict["party_gender"] = "male"
                        }
                        else  {
                            dict["party_gender"] = "female"
                        }
                    }
                    if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
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
                let lableDict = metadataDict[kLable]!.mutableCopy()
                lableDict.setValue("Yes", forKey: kIsErrorShow)
                lableDict.setValue("That postcode doesn't look right", forKey: kTitle)
                metadataDict[kLable] = lableDict
                dict[kMetaData] = metadataDict
                dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right"
                arrRegistration[7] = dict
                self.createCells()
            }
        }
    }
    
    func callEditUserInfoAPI()  {
        
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView!.frame = self.view.frame
        objAnimView?.animate()
        self.navigationController!.view.addSubview(objAnimView!)
        
        let objAPI = API()
        let dict = NSUserDefaults.standardUserDefaults().objectForKey(kUserInfo) as! Dictionary<String,AnyObject>
//        let dict = objAPI.getValueFromKeychainOfKey("userInfo")
        userInfoDict["ptyid"] = dict[kPartyID]
        if(isImageClicked) {
            let imageData:NSData = UIImageJPEGRepresentation(image1!, 1.0)!
            let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            let newDict = ["imageName.jpg":base64String]
            userInfoDict["imageurl"] = newDict
        }
        else {
            let newDict = ["imageName.jpg":""]
            userInfoDict["imageurl"] = newDict
        }
        
        let fName = userInfoDict[kFirstName] as! String
        let lName = userInfoDict[kSecondName] as! String
        var param = userInfoDict as Dictionary<String,AnyObject>
        param[kTown] = userInfoDict[kTown]
        param[kFirstName] = fName.capitalizedString
        param[kSecondName] = lName.capitalizedString
        
        param.removeValueForKey(kTown)
        param["ptystatus"] = "ENABLE"
        param.removeValueForKey("date_of_birth")
        param.removeValueForKey("pass_code")
        param.removeValueForKey(kEmail)
        param.removeValueForKey("confirm_pin")
        param.removeValueForKey(kImageURL)
        param.removeValueForKey(kPartyID)
        param.removeValueForKey("deviceRegistration")
        if let firstAddress = param[kFirstAddressLine] as? String {
            param.removeValueForKey(kFirstAddressLine)
        }
        if let secondAddress = param[kSecondAddressLine] as? String {
            param.removeValueForKey(kSecondAddressLine)
        }
        if let thirdAddress = param[kThirdAddressLine] as? String {
            param.removeValueForKey(kThirdAddressLine)
        }
        if let county = param["stripeCustomerId"] as? String {
            param.removeValueForKey("stripeCustomerId")
        }
        
        if let County = param[kCounty] as? String {
            param.removeValueForKey(kCounty)
        }
        if let stripeStatusCode = param["stripeStatusCode"] as? String {
            param.removeValueForKey("stripeStatusCode")
        }
        
        param.removeValueForKey(kPhoneNumber)
        param.removeValueForKey("pin")
        param.removeValueForKey(kSurname)
        param.removeValueForKey("party_role")
        param.removeValueForKey("partyRole")
        param.removeValueForKey("partyStatus")
        param.removeValueForKey("partyGender")
        objAPI.updateUserInfoDelegate = self
        print(param)
        objAPI.updateUserInfo(param)
    }
    
    func resignAllTextfield(){
        for i in 0 ..< arrRegistrationFields.count {
            if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                let cell = arrRegistrationFields[i] as! TitleTableViewCell
                cell.endEditing(true)

                cell.tfName?.resignFirstResponder()
            }
            if arrRegistrationFields[i].isKindOfClass(TxtFieldTableViewCell){
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
    
    
    
    
    func getAllValuesFromTxtFild()-> Dictionary<String,AnyObject>{
        var dict = Dictionary<String, AnyObject>()
        
        for i in 0 ..< arrRegistrationFields.count {
            if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                let cell = arrRegistrationFields[i] as! TitleTableViewCell
                dict[kTitle] = cell.tfTitle?.text
                dict[kFirstName] = cell.tfName?.text
                
            }
            
            if arrRegistrationFields[i].isKindOfClass(TxtFieldTableViewCell){
                let cell = arrRegistrationFields[i] as! TxtFieldTableViewCell
                if cell.tf?.placeholder == kSurname{
                    dict[kSecondName] = cell.tf?.text
                }
                if cell.tf?.placeholder == kFirstAddressLine{
                    dict[kAddress1] = cell.tf?.text
                }
                if cell.tf?.placeholder == kSecondAddressLine{
                    dict[kAddress2] = cell.tf?.text
                }
                if cell.tf?.placeholder == kThirdAddressLine{
                    dict[kAddress3] = cell.tf?.text
                }
                if cell.tf?.placeholder == kTown{
                    dict[kTown] = cell.tf?.text
                }
                if cell.tf?.placeholder == kMobileNumber{
                    dict[kPhoneNumber] = cell.tf?.text
                }
                if cell.tf?.placeholder == kCounty{
                    dict[kCounty] = cell.tf?.text
                }
                if cell.tf?.placeholder == kEmail{
                    dict[kEmail] = cell.tf?.text
                }
            }
            
            if arrRegistrationFields[i].isKindOfClass(FindAddressTableViewCell){
                let cell = arrRegistrationFields[i] as! FindAddressTableViewCell
                dict[kPostCode] = cell.tfPostCode?.text
            }
            if arrRegistrationFields[i].isKindOfClass(NumericTextTableViewCell){
                let cell = arrRegistrationFields[i] as! NumericTextTableViewCell
                dict[kPhoneNumber] = cell.tf?.text
            }
            if arrRegistrationFields[i].isKindOfClass(EmailTxtTableViewCell){
                let cell = arrRegistrationFields[i] as! EmailTxtTableViewCell
                dict[kEmail] = cell.tf?.text
            }
            if arrRegistrationFields[i].isKindOfClass(PickerTextfildTableViewCell){
                let cell = arrRegistrationFields[i] as! PickerTextfildTableViewCell
                dict["date_of_birth"] = cell.tfDatePicker?.text
            }
            let udidDict : Dictionary<String,AnyObject> = ["DEVICE_ID":Device.udid]
            let udidArray: Array<Dictionary<String,AnyObject>> = [udidDict]
            dict["deviceRegistration"] =  udidArray
        }
        return dict
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
    
    func acceptPolicy(obj:ImportantInformationView){
        var dict = self.getAllValuesFromTxtFild()
        let objAPI = API()
        if(changePhoneNumber == false)
        {
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            objAnimView!.frame = self.view.frame
            objAnimView?.animate()
            self.view.addSubview(objAnimView!)
            objAPI.delegate = self
            objAPI.registerTheUserWithTitle(dict,apiName: "Customers")
            return
        }
        else {
//            if(objAPI.getValueFromKeychainOfKey("myMobile") as! String == dict["phone_number"] as! String)
            if(NSUserDefaults.standardUserDefaults().objectForKey("myMobile") as! String == dict[kPhoneNumber] as! String)
            {
                objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
                objAnimView!.frame = self.view.frame
                objAnimView?.animate()
                self.view.addSubview(objAnimView!)
                objAPI.delegate = self
                objAPI.registerTheUserWithTitle(dict,apiName: "Customers")
            }
            else {
                let alert = UIAlertController(title: "Looks like you have an earlier enrolled mobile number", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    //Function checking textfield content only number or not
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
    
    func checkTextFiledValidation()->Bool{
        var returnFlag = false
        self.getJSONForUI()
        var idx = 0
        for i in 0 ..< arrRegistrationFields.count {
            var errorFLag = false
            var errorMsg = ""
            var dict = Dictionary<String, AnyObject>()
            if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                let cell = arrRegistrationFields[i] as! TitleTableViewCell
                let str = cell.tfName?.text
                
                if (self.checkTextFieldContentOnlyNumber(str!) == true){
                    errorMsg = "Name should contain alphabets only"
                    if cell.tfTitle?.text?.characters.count==0 {
                        errorMsg = "Please select a title and name should contain alphabets only"
                    }
                    errorFLag = true
                    dictForTextFieldValue[kErrorTitle] = errorMsg
                }
                else if checkTextFieldContentSpecialChar(str!){
                    errorMsg = "Name should not contain special characters"
                    if cell.tfTitle?.text?.characters.count==0 {
                        errorMsg = "Please select a title and name should not contain special characters"
                    }
                    errorFLag = true
                    dictForTextFieldValue[kErrorTitle] = errorMsg
                }
                else if str?.characters.count > 50{
                    errorMsg = kLongName
                    errorFLag = true
                    dictForTextFieldValue[kErrorTitle] = errorMsg
                }
                else if(cell.tfTitle?.text?.characters.count == 0 && cell.tfName?.text?.characters.count == 0){
                    errorMsg = kTitleAndNameMissingError
                    errorFLag = true
                    cell.tfTitle?.layer.borderColor = UIColor.redColor().CGColor
                    cell.tfName?.layer.borderColor = UIColor.redColor().CGColor
                    dictForTextFieldValue[kErrorTitle] = errorMsg
                }
                else if cell.tfTitle?.text == ""{
                    errorMsg = kTitleEmpty
                    errorFLag = true
                    dictForTextFieldValue[kErrorTitle] = errorMsg
                }
                else if str==""{
                    errorMsg = kEmptyName
                    errorFLag = true
                    dictForTextFieldValue[kErrorTitle] = errorMsg
                }
                else {
                    dictForTextFieldValue.removeValueForKey(kErrorTitle)
                }
                
                dict = arrRegistration[1] as Dictionary<String,AnyObject>
                idx = 1
            }
            
            if arrRegistrationFields[i].isKindOfClass(TxtFieldTableViewCell){
                let cell = arrRegistrationFields[i] as! TxtFieldTableViewCell
                if cell.tf?.placeholder == kSurname{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "We need to know your surname"
                        dictForTextFieldValue["errorTxt"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorTxt")
                    }
                    if(str?.characters.count>50){
                        errorMsg = kLongName
                        errorFLag = true
                        dictForTextFieldValue["errorSurname"] = errorMsg
                    }
                    else if(self.checkTextFieldContentOnlyNumber(str!) == true){
                        errorMsg = "Surname should contain alphabets only"
                        errorFLag = true
                        dictForTextFieldValue["errorSurname"] = errorMsg
                    }
                    else if checkTextFieldContentSpecialChar(str!){
                        errorMsg = "Surname should not contain special characters"
                        errorFLag = true
                        dictForTextFieldValue["errorSurname"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorSurname")
                    }
                    dict = arrRegistration[3]as Dictionary<String,AnyObject>
                    idx = 3
                }
                
                if cell.tf?.placeholder == kFirstAddressLine{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don’t forget your house number"
                        dictForTextFieldValue["errorFirstAddress"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorFirstAddress")
                    }
                    dict = arrRegistration[10]as Dictionary<String,AnyObject>
                    idx = 10
                }
                
                if cell.tf?.placeholder == kTown{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don’t forget your town"
                        dictForTextFieldValue["errorTown"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorTown")
                    }
                    dict = arrRegistration[14]as Dictionary<String,AnyObject>
                    idx = 14
                }
                
                if cell.tf?.placeholder == kCounty{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don’t forget your county"
                        dictForTextFieldValue["errorCounty"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorCounty")
                    }
                    dict = arrRegistration[16]as Dictionary<String,AnyObject>
                    idx = 16
                }
                
                if cell.tf?.placeholder == kMobileNumber{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don't forget your mobile number"
                        dictForTextFieldValue[kErrorMobileValidation] = errorMsg
                    }
                    else  if(self.checkTextFieldContentCharacters(str!) == true || self.phoneNumberValidation(str!)==false){
                        errorFLag = true
                        errorMsg = "That mobile number doesn’t look right"
                        dictForTextFieldValue[kErrorMobileValidation] = errorMsg
                    }
                    else if(str?.characters.count < 10)
                    {
                        errorFLag = true
                        errorMsg = "That mobile number should be greater than 10 digits"
                        dictForTextFieldValue[kErrorMobileValidation] = errorMsg
                    }
                    else if(str?.characters.count > 16)
                    {
                        errorFLag = true
                        errorMsg = "That mobile number should be of 15 digits"
                        dictForTextFieldValue[kErrorMobileValidation] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey(kErrorMobileValidation)
                    }
                    dict = arrRegistration[19]as Dictionary<String,AnyObject>
                    idx = 19
                }
                
                if cell.tf?.placeholder == kEmail{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don't forget your email address"
                        dictForTextFieldValue["errorEmail"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorEmail")
                    }
                    if str?.characters.count>0 && (self.isValidEmail(str!)==false){
                        errorFLag = true
                        errorMsg = "That email address doesn’t look right"
                        dictForTextFieldValue["errorEmailValid"] = errorMsg
                    }
                    else {
                        dictForTextFieldValue.removeValueForKey("errorEmailValid")
                    }
                    dict = arrRegistration[21]as Dictionary<String,AnyObject>
                    idx = 21
                }
                
            }
            
            if arrRegistrationFields[i].isKindOfClass(FindAddressTableViewCell){
                let cell = arrRegistrationFields[i] as! FindAddressTableViewCell
                let str = cell.tfPostCode?.text
                if str==""{
                    errorFLag = true
                    errorMsg = "Don’t forget your postcode"
                    dictForTextFieldValue["errorPostcode"] = errorMsg
                    dictForTextFieldValue.removeValueForKey("errorPostcodeValid")
                    dictForTextFieldValue.removeValueForKey("Postcode")
                }
                else {
                    dictForTextFieldValue.removeValueForKey("errorPostcode")
                    dictForTextFieldValue.removeValueForKey("errorPostcodeValid")
                }
                dict = arrRegistration[7]as Dictionary<String,AnyObject>
                idx = 7
            }
            
            if arrRegistrationFields[i].isKindOfClass(NumericTextTableViewCell){
                let cell = arrRegistrationFields[i] as! NumericTextTableViewCell
                let str = cell.tf?.text
                
                if str==""{
                    errorFLag = true
                    errorMsg = "Don't forget your mobile number"
                    dictForTextFieldValue[kErrorMobileValidation] = errorMsg
                }
                else  if(self.checkTextFieldContentCharacters(str!) == true || self.phoneNumberValidation(str!)==false){
                    errorFLag = true
                    errorMsg = "That mobile number doesn’t look right"
                    dictForTextFieldValue[kErrorMobileValidation] = errorMsg
                }
                else if(str?.characters.count < 10)
                {
                    errorFLag = true
                    errorMsg = "That mobile number should be greater than 10 digits"
                    dictForTextFieldValue[kErrorMobileValidation] = errorMsg
                }
                else if(str?.characters.count > 16)
                {
                    errorFLag = true
                    errorMsg = "That mobile number should be of 15 digits"
                    dictForTextFieldValue[kErrorMobileValidation] = errorMsg
                }
                else {
                    dictForTextFieldValue.removeValueForKey(kErrorMobileValidation)
                }
                
                dict = arrRegistration[19]as Dictionary<String,AnyObject>
                idx = 19
                
            }
            if arrRegistrationFields[i].isKindOfClass(EmailTxtTableViewCell){
                let cell = arrRegistrationFields[i] as! EmailTxtTableViewCell
                let str = cell.tf?.text
                if str==""{
                    errorFLag = true
                    errorMsg = "Don't forget your email address"
                    dictForTextFieldValue["errorEmail"] = errorMsg
                }
                else {
                    dictForTextFieldValue.removeValueForKey("errorEmail")
                }
                
                if str?.characters.count>0 && (self.isValidEmail(str!)==false){
                    errorFLag = true
                    errorMsg = "That email address doesn’t look right"
                    dictForTextFieldValue["errorEmailValid"] = errorMsg
                }
                else {
                    dictForTextFieldValue.removeValueForKey("errorEmailValid")
                }
                dict = arrRegistration[21]as Dictionary<String,AnyObject>
                idx = 21
            }
            
            
            if arrRegistrationFields[i].isKindOfClass(PickerTextfildTableViewCell){
                let cell = arrRegistrationFields[i] as! PickerTextfildTableViewCell
                let str = cell.tfDatePicker?.text
                if str==""{
                    errorFLag = true
                    errorMsg = "We need to know your date of birth"
                    dictForTextFieldValue["errorDOB"] = errorMsg
                }
                else {
                    dictForTextFieldValue.removeValueForKey("errorDOB")
                }
                dict = arrRegistration[5]as Dictionary<String,AnyObject>
                idx = 5
            }
            
            if(errorFLag == true){
                returnFlag = true
                var metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
                let lableDict = metadataDict[kLable]!.mutableCopy()
                
                lableDict.setValue("Yes", forKey: kIsErrorShow)
                if errorMsg.characters.count>0{
                    lableDict.setValue(errorMsg, forKey: kTitle)
                }
                metadataDict[kLable] = lableDict
                dict[kMetaData] = metadataDict
                arrRegistration[idx] = dict
            }
            
        }
        self.createCells()
        return returnFlag
    }
    
    
    
    func phoneNumberValidation(value: String) -> Bool {
        let charcter  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
        var filtered:NSString!
        let inputString:NSArray = value.componentsSeparatedByCharactersInSet(charcter)
        filtered = inputString.componentsJoinedByString("")
        return  value == filtered
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
    
    //PostCode Verification Delegate Method
    func success(addressArray:Array<String>){
        objAnimView?.removeFromSuperview()
        self.getJSONForUI()
        var dict = arrRegistration[8] as Dictionary<String,AnyObject>
        var metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
        let lableDict = metadataDict[kTextField1]!.mutableCopy()
        lableDict.setValue(addressArray, forKey: "dropDownArray")
        metadataDict[kTextField1] = lableDict
        dict[kMetaData] = metadataDict
        arrRegistration[8] = dict
        arrAddress = addressArray
        dictForTextFieldValue.removeValueForKey("errorPostcodeValid")
        self.createCells()
    }
    func error(error:String){
        objAnimView?.removeFromSuperview()
        if(error == "That postcode doesn't look right"){
            var dict = arrRegistration[7] as Dictionary<String,AnyObject>
            var metadataDict = dict[kMetaData]as! Dictionary<String,AnyObject>
            let lableDict = metadataDict[kLable]!.mutableCopy()
            lableDict.setValue("Yes", forKey: kIsErrorShow)
            lableDict.setValue(error, forKey: kTitle)
            metadataDict[kLable] = lableDict
            dict[kMetaData] = metadataDict
            dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right"
            arrRegistration[7] = dict
            self.createCells()
        }
        else {
            let alert = UIAlertController(title: error, message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func successResponseForRegistrationAPI(objResponse:Dictionary<String,AnyObject>){
        
    }
    func errorResponseForRegistrationAPI(error:String){
        
    }
    
    
    @IBAction func addProfilePictureButtonPressed(sender: AnyObject) {
        self.resignAllTextfield()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default)
        { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.imagePicker.allowsEditing = true
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            })
        alertController.addAction(UIAlertAction(title: "Choose Photo", style: UIAlertActionStyle.Default)
        { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.imagePicker.allowsEditing = true
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            
            })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
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
    
    
    func checkNullDataFromDict(dict:Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject> {
        var replaceDict: Dictionary<String,AnyObject> = dict
        let blank = ""
        //check each key's value
        for key:String in Array(dict.keys) {
            let ob = dict[key]! as? AnyObject
            //if value is Null or nil replace its value with blank
            if (ob is NSNull)  || ob == nil {
                replaceDict[key] = blank
            }
            else if (ob is Dictionary<String,AnyObject>) {
                replaceDict[key] = self.checkNullDataFromDict(ob as! Dictionary<String,AnyObject>)
            }
            else if (ob is Array<Dictionary<String,AnyObject>>) {
                var newArr: Array<Dictionary<String,AnyObject>> = []
                for arrObj:Dictionary<String,AnyObject> in ob as! Array {
                    newArr.append(self.checkNullDataFromDict(arrObj as Dictionary<String,AnyObject>))
                }
                replaceDict[key] = newArr
            }
        }
        return replaceDict
    }
    func changeMainDict() {
        userBeforeEditInfoDict[kTitle] = userInfoDict[kTitle] as! String
        userBeforeEditInfoDict[kFirstName] = userInfoDict[kFirstName] as! String
        userBeforeEditInfoDict[kSecondName] = userInfoDict[kSecondName] as! String
        userBeforeEditInfoDict[kAddress1] = userInfoDict[kAddress1] as! String
        userBeforeEditInfoDict[kAddress2] = userInfoDict[kAddress2] as! String
        userBeforeEditInfoDict[kAddress3] = userInfoDict[kAddress3] as! String
        userBeforeEditInfoDict[kTown] = userInfoDict[kTown] as! String
        userBeforeEditInfoDict[kCounty] = userInfoDict[kCounty] as! String
        self.isInfoUpdated = false
    }
    
    func checkAnyInfoUpdatedFromPrevious()-> Bool {
        var updateFlag: Bool = false
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
    
    @IBAction func paymentButtonPressed(sender: UIButton) {
        
        
        UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, forEvent:nil)
        self.showAlt()
        
    }
    
    
    func showAlt()  {
        let individualFlag = NSUserDefaults.standardUserDefaults().valueForKey(kIndividualPlan) as! NSNumber
        let groupFlag = NSUserDefaults.standardUserDefaults().valueForKey(kGroupPlan) as! NSNumber
        let groupMemberFlag = NSUserDefaults.standardUserDefaults().valueForKey(kGroupMemberPlan) as! NSNumber
        
        if(individualFlag == 1 || groupFlag == 1 || groupMemberFlag == 1)
        {
            let flagForUpdat: Bool = self.checkAnyInfoUpdatedFromPrevious()
            if (self.isInfoUpdated == true || flagForUpdat == true){
                
                let uiAlert = UIAlertController(title: "Alert", message: "Would you like to save the changes to your personal settings?", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(uiAlert, animated: true, completion: nil)
                
                uiAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { action in
                    print("Click of default button")
                    if let urlString = self.userInfoDict[kImageURL] as? String
                    {
                        if(urlString == "")
                        {
                            self.addProfilePictureButton.setImage(nil, forState: .Normal)
                            self.addProfilePictureButton.setTitle("Add\n profile\n picture", forState: .Normal)
                            self.addProfilePictureButton.titleLabel?.lineBreakMode =  NSLineBreakMode.ByWordWrapping
                            self.addProfilePictureButton.titleLabel?.textAlignment = .Center
                            self.addProfilePictureButton.titleLabel?.numberOfLines = 0
                        }
                    }
                    self.navigateToPayment()
                }))
                
                uiAlert.addAction(UIAlertAction(title: "Yes", style: .Cancel, handler: { action in
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
    
    
    func navigateToPayment() {
        isInfoUpdated = false
        let objSavedCardView = SASaveCardViewController()
        objSavedCardView.isFromEditUserInfo = true
        self.navigationController?.pushViewController(objSavedCardView, animated: true)
    }
    
    // MARK: - GetUserInfoDelegate
    func successResponseForGetUserInfoAPI(objResponse: Dictionary<String, AnyObject>) {
        if let message = objResponse["message"] as? String {
            if(message == "Party Found")  {
                
                userInfoDict =  self.checkNullDataFromDict(objResponse["party"] as! Dictionary<String,AnyObject>)
                dictForTextFieldValue = self.checkNullDataFromDict(objResponse["party"] as! Dictionary<String,AnyObject>)

                //Get Registration UI Json data
                userBeforeEditInfoDict =  self.checkNullDataFromDict(objResponse["party"] as! Dictionary<String,AnyObject>)

                               print(userBeforeEditInfoDict)
                if let urlString = userInfoDict[kImageURL] as? String
                {
                    let url = NSURL(string:urlString)
                    let request: NSURLRequest = NSURLRequest(URL: url!)
                    if(urlString != "")
                    {
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                            if(data?.length > 0)
                            {
                                let image = UIImage(data: data!)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.addProfilePictureButton.setImage(image, forState: .Normal)
                                    self.addProfilePictureButton.layer.cornerRadius = self.addProfilePictureButton.frame.size.height/2.0
                                    self.addProfilePictureButton.clipsToBounds = true
                                    self.spinner.stopAnimating()
                                    self.spinner.hidden = true
                                })
                            }
                            else {
                                self.spinner.stopAnimating()
                                self.spinner.hidden = true
                            }
                        })
                    }
                    else{
                        self.spinner.stopAnimating()
                        self.spinner.hidden = true
                    }
                }
                else
                {
                    self.spinner.stopAnimating()
                    self.spinner.hidden = true
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
    
    func errorResponseForGetUserInfoAPI(error: String) {
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
        objAnimView!.removeFromSuperview()
    }
    
    func successResponseForUpdateUserInfoAPI(objResponse: Dictionary<String, AnyObject>) {
        objAnimView?.removeFromSuperview()
        if let message = objResponse["message"] as? String
        {
            if(message == "UserData Updated Successfully")
            {
                //                let alert = UIAlertView(title: "Updated", message: "Personal details updated", delegate: nil, cancelButtonTitle: "Ok")
                //                alert.show()
                self.changeMainDict()
                self.createCells()
                
                let uiAlert = UIAlertController(title: "Updated", message: "Personal details updated", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(uiAlert, animated: true, completion: nil)
                
                uiAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
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
    
    func errorResponseForUpdateUserInfoAPI(error: String) {
        objAnimView?.removeFromSuperview()
        if error == "Network not available" {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{

        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
    }
}

