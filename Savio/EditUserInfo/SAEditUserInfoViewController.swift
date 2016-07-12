//
//  SAEditUserInfoViewController.swift
//  Savio
//
//  Created by Vishal  on 11/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAEditUserInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,TxtFieldTableViewCellDelegate,TitleTableViewCellDelegate,FindAddressCellDelegate,ButtonCellDelegate,PostCodeVerificationDelegate,DropDownTxtFieldTableViewCellDelegate,PickerTxtFieldTableViewCellDelegate,ImportantInformationViewDelegate,NumericTxtTableViewCellDelegate,EmailTxtTableViewCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GetUserInfoDelegate{
    
    @IBOutlet weak var scrlView: UIScrollView!
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addProfilePictureButton: UIButton!
    @IBOutlet weak var contentViewHt: NSLayoutConstraint!
    @IBOutlet weak var tblViewHt: NSLayoutConstraint!
    
    
    @IBOutlet weak var tblView: UITableView!
    var arrRegistration  = [Dictionary <String, AnyObject>]()     //Array for hold json file data to create UI
    var arrRegistrationFields = [UITableViewCell]()               //Array of textfield cell
    var dictForTextFieldValue : Dictionary<String, AnyObject> = [:] // dictionary for saving user data and error messages
    //    var strPostCode = String()
    var objAnimView : ImageViewAnimation?                     //Instance of ImageViewAnimation to showing loding aniation on API call
    var arrAddress = [String]()
    var firstName = ""
    var lastName = ""
    var dateOfBirth = ""
    var phoneNumber = ""
    var editUser = true
    var getUserInfoDelegate = GetUserInfoDelegate.self
    var imagePicker = UIImagePickerController()
    
    var userInfoDict : Dictionary<String,AnyObject> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addProfilePictureButton.setTitle("Add\n profile\n picture", forState: .Normal)
        addProfilePictureButton.titleLabel?.lineBreakMode =  NSLineBreakMode.ByWordWrapping
        addProfilePictureButton.titleLabel?.textAlignment = .Center
        addProfilePictureButton.titleLabel?.numberOfLines = 0
        addProfilePictureButton.layer.cornerRadius = addProfilePictureButton.frame.size.height/2
        
        
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView!.frame = self.view.frame
        objAnimView!.animate()
        
        self.view.addSubview(objAnimView!)
        
        let objAPI = API()
        objAPI.getUserInfoDelegate = self
        objAPI.getUserInfo()
        self.setUPNavigation()
        
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    func setUPNavigation()
    {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "Personal settings"
        //set Navigation right button nav-heart
        
        let btnName = UIButton()
        //btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as! NSData
            wishListArray = (NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>)!
            
            
            if(wishListArray.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else{
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
        for var i=0; i<arrRegistration.count; i++ {
            // dictionary to identifying cell and its properies
            let dict = arrRegistration[i] as Dictionary<String,AnyObject>
            //get tableviewCell as per the classtype
            let bundleArr : Array = NSBundle.mainBundle().loadNibNamed(dict["classType"] as! String, owner: nil, options: nil)
            
            //Setup all error message lable tableViewCell
            if dict["classType"]!.isEqualToString("ErrorTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! ErrorTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                let tfTitleDict = metadataDict["lable"]as! Dictionary<String,AnyObject>
                //Set Error messages to error lable
                cell.lblError?.text = tfTitleDict["title"] as? String
                let isErrorShow = tfTitleDict["isErrorShow"] as! String
                //identifying to which error message show for textfield
                
                if isErrorShow == "Yes"{
                    arrRegistrationFields.append(cell)
                }
            }
            
            //SetUp Titel and Name textfield tableView cell and its validation messages
            if dict["classType"]!.isEqualToString("TitleTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! TitleTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.dict = dict
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                //                cell.tfTitle?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                cell.tfTitle?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                cell.tfName?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                
                cell.tfTitle!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                if(editUser)
                {
                    cell.tfTitle!.userInteractionEnabled = false
                    cell.tfTitle?.text = userInfoDict["title"] as? String
                }
                if (dictForTextFieldValue["title"] != nil){
                    cell.tfTitle?.text = dictForTextFieldValue["title"] as? String
                }
                //                cell.tfTitle?.placeholder = tfTitleDict["placeholder"] as? String
                let tfNameDict = metadataDict["textField2"]as! Dictionary<String,AnyObject>
                cell.tfName!.attributedPlaceholder = NSAttributedString(string:(tfNameDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if(editUser)
                {
                    cell.tfName?.text = userInfoDict["first_name"] as? String
                }
                if (dictForTextFieldValue["name"] != nil){
                    cell.tfName?.text = dictForTextFieldValue["name"] as? String
                }
                
                if (dictForTextFieldValue["errorTitle"] != nil) {
                    if dictForTextFieldValue["errorTitle"]!.isEqualToString("We need to know your title and name"){
                        cell.tfName?.layer.borderColor = UIColor.redColor().CGColor
                        cell.tfTitle?.layer.borderColor = UIColor.redColor().CGColor
                    }
                    else if dictForTextFieldValue["errorTitle"]!.isEqualToString("Please select a title"){
                        cell.tfTitle?.layer.borderColor = UIColor.redColor().CGColor
                    }
                    else if dictForTextFieldValue["errorTitle"]!.isEqualToString("We need to know what to call you"){
                        cell.tfName?.layer.borderColor = UIColor.redColor().CGColor
                    }
                    else if (dictForTextFieldValue["errorTitle"]!.isEqualToString("Wow, that’s such a long name we can’t save it") || dictForTextFieldValue["errorTitle"]!.isEqualToString("Surname should contain character only") ){
                        cell.tfName?.textColor = UIColor.redColor()
                    }
                }
                //                cell.tfName?.placeholder = tfNameDict["placeholder"] as? String
                arrRegistrationFields.append(cell)
                
            }
            if dict["classType"]!.isEqualToString("TxtFieldTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! TxtFieldTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.tf?.textColor = UIColor.blackColor()
                
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                
                
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorTxt"] != nil && cell.tf?.placeholder == "Surname") {
                    let str = dictForTextFieldValue["errorTxt"]
                    if (str!.isEqualToString("We need to know your surname")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                
                if (dictForTextFieldValue["errorSurname"] != nil && cell.tf?.placeholder == "Surname") {
                    
                    let str = dictForTextFieldValue["errorSurname"]
                    if (str!.isEqualToString("Wow, that’s such a long name we can’t save it")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                        
                    }
                }
                
                
                
                if (dictForTextFieldValue["errorFirstAddress"] != nil && cell.tf?.placeholder == "First Address Line") {
                    
                    let str = dictForTextFieldValue["errorFirstAddress"]
                    
                    
                    
                    if (str!.isEqualToString("Don’t forget your house number")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                    
                }
                if (dictForTextFieldValue["errorTown"] != nil && cell.tf?.placeholder == "Town") {
                    
                    let str = dictForTextFieldValue["errorTown"]
                    if (str!.isEqualToString("Don’t forget your town")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorCounty"] != nil && cell.tf?.placeholder == "County") {
                    
                    let str = dictForTextFieldValue["errorCounty"]
                    if (str!.isEqualToString("Don’t forget your county")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorMobile"] != nil && cell.tf?.placeholder == "Mobile number") {
                    let str = dictForTextFieldValue["errorMobile"]
                    if (str!.isEqualToString("Don't forget your mobile number")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorMobileValidation"] != nil && cell.tf?.placeholder == "Mobile number") {
                    let str = dictForTextFieldValue["errorMobileValidation"]
                    if (str!.isEqualToString("That mobile number doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                        
                    }
                }
                if (dictForTextFieldValue["errorEmail"] != nil && cell.tf?.placeholder == "Email") {
                    let str = dictForTextFieldValue["errorEmail"]
                    if (str!.isEqualToString("Don't forget your email address")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorEmailValid"] != nil && cell.tf?.placeholder == "Email") {
                    let str = dictForTextFieldValue["errorEmailValid"]
                    if (str!.isEqualToString("That email address doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                        
                    }
                }
                
                if(editUser)
                {
                    if(cell.tf?.placeholder == "Surname")
                    {
                        cell.tf?.text = userInfoDict["second_name"] as? String
                    }
                    else if(cell.tf?.placeholder == "First Address Line")
                    {
                        cell.tf?.text = userInfoDict["address_1"] as? String
                    }
                    else if(cell.tf?.placeholder == "Town")
                    {
                        cell.tf?.text = userInfoDict["town"] as? String
                    }
                    else if(cell.tf?.placeholder == "County")
                    {
                        cell.tf?.text = userInfoDict["county"] as? String
                    }
                    else if(cell.tf?.placeholder == "Second Address Line")
                    {
                        cell.tf?.text = userInfoDict["address_2"] as? String
                    }
                    else if(cell.tf?.placeholder == "Third Address Line")
                    {
                        cell.tf?.text = userInfoDict["address_3"] as? String
                    }
                    
                    
                }
                
                arrRegistrationFields.append(cell)
            }
            
            if dict["classType"]!.isEqualToString("PickerTextfildTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! PickerTextfildTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                cell.tfDatePicker!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if(editUser)
                {
                    cell.tfDatePicker.userInteractionEnabled = false
                    cell.tfDatePicker.text = userInfoDict["date_of_birth"] as? String
                }
                //                cell.tfDatePicker?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                cell.tfDatePicker?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                if (dictForTextFieldValue[(cell.tfDatePicker?.placeholder)!] != nil){
                    cell.tfDatePicker?.text = dictForTextFieldValue[(cell.tfDatePicker?.placeholder)!] as? String
                    print("\(dictForTextFieldValue)")
                }
                arrRegistrationFields.append(cell)
                
                
            }
            
            if dict["classType"]!.isEqualToString("FindAddressTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! FindAddressTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                //                (red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
                //                cell.tfPostCode?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                cell.tfPostCode?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                let tfPostcodeDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                cell.tfPostCode!.attributedPlaceholder = NSAttributedString(string:(tfPostcodeDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if(editUser)
                {
                    cell.tfPostCode?.text = userInfoDict["post_code"] as? String
                }
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
                arrRegistrationFields.append(cell)
            }
            
            if dict["classType"]!.isEqualToString("ButtonTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! ButtonTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                let btnPostcodeDict = metadataDict["button"]as! Dictionary<String,AnyObject>
                cell.btn?.setTitle("Save", forState: UIControlState.Normal)
                arrRegistrationFields.append(cell)
            }
            
            if dict["classType"]!.isEqualToString("NumericTextTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! NumericTextTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.tf?.textColor = UIColor.blackColor()
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                
                if(editUser)
                {
                    cell.tf!.userInteractionEnabled = false
                    cell.tf?.text = userInfoDict["phone_number"] as? String
                }
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorMobile"] != nil && cell.tf?.placeholder == "Mobile number") {
                    let str = dictForTextFieldValue["errorMobile"]
                    if (str!.isEqualToString("Don't forget your mobile number")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorMobileValidation"] != nil && cell.tf?.placeholder == "Mobile number") {
                    let str = dictForTextFieldValue["errorMobileValidation"]
                    if (str!.isEqualToString("That mobile number doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                    }
                }
                arrRegistrationFields.append(cell)
            }
            
            if dict["classType"]!.isEqualToString("EmailTxtTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! EmailTxtTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.tf?.textColor = UIColor.blackColor()
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                if(editUser)
                {
                    cell.tf?.text = userInfoDict["email"] as? String
                    cell.tf?.userInteractionEnabled = false
                }
                
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                }
                
                if (dictForTextFieldValue["errorEmail"] != nil && cell.tf?.placeholder == "Email") {
                    let str = dictForTextFieldValue["errorEmail"]
                    if (str!.isEqualToString("Don't forget your email address")){
                        cell.tf?.layer.borderColor = UIColor.redColor().CGColor
                    }
                }
                if (dictForTextFieldValue["errorEmailValid"] != nil && cell.tf?.placeholder == "Email") {
                    let str = dictForTextFieldValue["errorEmailValid"]
                    if (str!.isEqualToString("That email address doesn’t look right")){
                        cell.tf?.textColor = UIColor.redColor()
                        cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                    }
                }
                arrRegistrationFields.append(cell)
                
            }
            
            if dict["classType"]!.isEqualToString("DropDownTxtFieldTableViewCell"){
                let metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let cell = bundleArr[0] as! DropDownTxtFieldTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.delegate = self
                cell.tblView = tblView
                cell.dict = dict
                //                (red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
                //                cell.tf?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
                cell.tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
                let tfTitleDict = metadataDict["textField1"]as! Dictionary<String,AnyObject>
                cell.tf!.attributedPlaceholder = NSAttributedString(string:(tfTitleDict["placeholder"] as? String)!, attributes:[NSForegroundColorAttributeName:UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)])
                
                
                if (dictForTextFieldValue[(cell.tf?.placeholder)!] != nil){
                    //                    if (arrAddress.count>0){
                    cell.tf?.text = dictForTextFieldValue[(cell.tf?.placeholder)!] as? String
                    arrRegistrationFields.append(cell)
                }
                //                let arrDropDown = tfTitleDict["dropDownArray"] as! Array<String>
                let arrDropDown = arrAddress
                
                print("\(arrDropDown)")
                cell.arr = arrDropDown
                print("\(cell.arr)")
                if arrDropDown.count>0{
                    arrRegistrationFields.append(cell)
                }
            }
        }
        
        scrlView.contentSize = CGSizeMake(0, CGFloat(35 * (arrRegistrationFields.count+5)))
        
        tblView.reloadData()
    }
    
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        
        if wishListArray.count>0{
            
            let objSAWishListViewController = SAWishListViewController()
            objSAWishListViewController.wishListArray = wishListArray
            self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
        }
        else{
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "OK")
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
        
        addProfilePictureButton.setImage((info[UIImagePickerControllerEditedImage] as? UIImage), forState: .Normal)
        addProfilePictureButton.layer.cornerRadius = addProfilePictureButton.frame.size.height/2.0
        addProfilePictureButton.setTitle("", forState: .Normal)
        addProfilePictureButton.clipsToBounds = true
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func selectedDate(txtFldCell:PickerTextfildTableViewCell){
        
        dictForTextFieldValue.updateValue((txtFldCell.tfDatePicker?.text)!, forKey: (txtFldCell.tfDatePicker?.placeholder)!)
    }
    
    
    func txtFieldCellText(txtFldCell:TxtFieldTableViewCell){
        if txtFldCell.tf?.text?.characters.count>0{
            dictForTextFieldValue.updateValue((txtFldCell.tf?.text)!, forKey: (txtFldCell.tf?.placeholder)!)
            userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: (txtFldCell.tf?.placeholder)!)
        }
        else{
            dictForTextFieldValue.removeValueForKey((txtFldCell.tf?.placeholder)!)
        }
        print("\(dictForTextFieldValue)")
    }
    
    func titleCellText(titleCell:TitleTableViewCell){
        if titleCell.tfTitle?.text?.characters.count>0{
            dictForTextFieldValue.updateValue((titleCell.tfTitle?.text)!, forKey: "title")
        }
        if titleCell.tfName?.text?.characters.count>0{
            dictForTextFieldValue.updateValue((titleCell.tfName?.text)!, forKey: "name")
            userInfoDict.updateValue((titleCell.tfName?.text)!, forKey: "first-name")
        }
        print("\(dictForTextFieldValue)")
    }
    
    func getTextFOrPostCode(findAddrCell: FindAddressTableViewCell)
    {
        if findAddrCell.tfPostCode?.text?.characters.count>0{
            dictForTextFieldValue.updateValue((findAddrCell.tfPostCode?.text)!, forKey: (findAddrCell.tfPostCode?.placeholder)!)
            userInfoDict.updateValue((findAddrCell.tfPostCode?.text)!, forKey: "postcode")
        }
    }
    
    func getAddressButtonClicked(findAddrCell: FindAddressTableViewCell){
        //        var strPostCode = String()
        
        let strPostCode = (findAddrCell.tfPostCode?.text)!
        dictForTextFieldValue.updateValue((findAddrCell.tfPostCode?.text)!, forKey: (findAddrCell.tfPostCode?.placeholder)!)
        
        let strCode = strPostCode
        print("\(strPostCode)")
        if strCode.characters.count == 0 {
            var dict = arrRegistration[6] as Dictionary<String,AnyObject>
            var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
            let lableDict = metadataDict["lable"]!.mutableCopy()
            lableDict.setValue("Yes", forKey: "isErrorShow")
            lableDict.setValue("Don’t forget your postcode", forKey: "title")
            dictForTextFieldValue["errorPostcode"] = "Don’t forget your postcode"
            
            metadataDict["lable"] = lableDict
            dict["metaData"] = metadataDict
            arrRegistration[6] = dict
            self.createCells()
        }
        else if checkTextFieldContentSpecialChar(strPostCode){
            var dict = arrRegistration[6] as Dictionary<String,AnyObject>
            var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
            let lableDict = metadataDict["lable"]!.mutableCopy()
            lableDict.setValue("Yes", forKey: "isErrorShow")
            lableDict.setValue("That postcode doesn't look right", forKey: "title")
            metadataDict["lable"] = lableDict
            dict["metaData"] = metadataDict
            dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right"
            arrRegistration[6] = dict
            self.createCells()
        }
        else{
            //            NW1W 9BE
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
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
        print(fullNameArr)
        //        var addressStr = ""
        //        for var i=0; i<fullNameArr.count-3; i++ {
        //            addressStr = addressStr+" \(fullNameArr[i])"
        //        }
        
        dictForTextFieldValue.updateValue(fullNameArr[0], forKey: "First Address Line")
        dictForTextFieldValue.updateValue(fullNameArr[1], forKey: "Second Address Line")
        dictForTextFieldValue.updateValue(fullNameArr[2], forKey: "Third Address Line")
        
        //        dictForTextFieldValue.updateValue(addressStr, forKey: "First Address Line")
        dictForTextFieldValue.updateValue(fullNameArr[fullNameArr.count-2], forKey: "Town")
        dictForTextFieldValue.updateValue(fullNameArr[fullNameArr.count-1], forKey: "County")
        
        
        userInfoDict.updateValue(fullNameArr[0], forKey: "address_1")
        userInfoDict.updateValue(fullNameArr[1], forKey: "address_2")
        userInfoDict.updateValue(fullNameArr[2], forKey: "address_3")
        
        //        dictForTextFieldValue.updateValue(addressStr, forKey: "First Address Line")
        userInfoDict.updateValue(fullNameArr[fullNameArr.count-2], forKey: "town")
        userInfoDict.updateValue(fullNameArr[fullNameArr.count-1], forKey: "county")
        
        print(dictForTextFieldValue)
        
        //        dictForTextFieldValue.updateValue((dropDownTextCell.tf?.text)!, forKey: (dropDownTextCell.tf?.placeholder)!)
        //        dictForTextFieldValue.updateValue((dropDownTextCell.tf?.text)!, forKey: (dropDownTextCell.tf?.placeholder)!)
        self.createCells()
    }
    
    
    func numericCellText(txtFldCell: NumericTextTableViewCell) {
        dictForTextFieldValue.updateValue((txtFldCell.tf?.text)!, forKey: (txtFldCell.tf?.placeholder)!)
        userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: "mobile-number")
    }
    
    func emailCellText(txtFldCell:EmailTxtTableViewCell){
        dictForTextFieldValue.updateValue((txtFldCell.tf?.text)!, forKey: (txtFldCell.tf?.placeholder)!)
        userInfoDict.updateValue((txtFldCell.tf?.text)!, forKey: "email")
    }
    
    func buttonClicked(sender:UIButton){
        
        if (checkTextFiledValidation() == false && dictForTextFieldValue["errorPostcodeValid"]==nil){
            //call term and condition screen
            var dict = self.getAllValuesFromTxtFild()
            if(firstName.characters.count>0 && lastName.characters.count>0 && dateOfBirth.characters.count>0)
            {
                for i in 0 ..< arrRegistrationFields.count {
                    //            var  dict : NSMutableDictionary = NSMutableDictionary()
                    if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                        let cell = arrRegistrationFields[i] as! TitleTableViewCell
                        dict["title"] = cell.tfTitle?.text
                        dict["first_name"] = cell.tfName?.text
                    }
                    
                    if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                    }
                }
                
                //Webservice call
                
                
            }
            else{
                print(userInfoDict)
                let alert = UIAlertView(title: "Alert", message: "Work in Progress", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else{
            if dictForTextFieldValue["errorPostcodeValid"] != nil{
                var dict = arrRegistration[6] as Dictionary<String,AnyObject>
                var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let lableDict = metadataDict["lable"]!.mutableCopy()
                lableDict.setValue("Yes", forKey: "isErrorShow")
                lableDict.setValue("That postcode doesn't look right", forKey: "title")
                metadataDict["lable"] = lableDict
                dict["metaData"] = metadataDict
                dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right"
                arrRegistration[6] = dict
                self.createCells()
            }
        }
    }
    
    
    func getAllValuesFromTxtFild()-> Dictionary<String,AnyObject>{
        var dict = Dictionary<String, AnyObject>()
        
        for i in 0 ..< arrRegistrationFields.count {
            //            var  dict : NSMutableDictionary = NSMutableDictionary()
            if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                let cell = arrRegistrationFields[i] as! TitleTableViewCell
                dict["title"] = cell.tfTitle?.text
                dict["first_name"] = cell.tfName?.text
            }
            
            if arrRegistrationFields[i].isKindOfClass(TxtFieldTableViewCell){
                let cell = arrRegistrationFields[i] as! TxtFieldTableViewCell
                //                if cell.tf?.placeholder == "Surname"{
                //                    dict["second_name"] = cell.tf?.text
                //                }
                if cell.tf?.placeholder == "Surname"{
                    dict["second_name"] = cell.tf?.text
                }
                if cell.tf?.placeholder == "First Address Line"{
                    dict["address_1"] = cell.tf?.text
                }
                if cell.tf?.placeholder == "Second Address Line"{
                    dict["address_2"] = cell.tf?.text
                }
                if cell.tf?.placeholder == "Third Address Line"{
                    dict["address_3"] = cell.tf?.text
                }
                
                if cell.tf?.placeholder == "Town"{
                    dict["town"] = cell.tf?.text
                }
                
                if cell.tf?.placeholder == "Mobile number"{
                    dict["phone_number"] = cell.tf?.text
                }
                if cell.tf?.placeholder == "County"{
                    dict["county"] = cell.tf?.text
                }
                
                if cell.tf?.placeholder == "Email"{
                    dict["email"] = cell.tf?.text
                }
            }
            
            if arrRegistrationFields[i].isKindOfClass(FindAddressTableViewCell){
                let cell = arrRegistrationFields[i] as! FindAddressTableViewCell
                dict["post_code"] = cell.tfPostCode?.text
                //                dict["post_code"] = "se19dy"
            }
            
            if arrRegistrationFields[i].isKindOfClass(NumericTextTableViewCell){
                let cell = arrRegistrationFields[i] as! NumericTextTableViewCell
                dict["phone_number"] = cell.tf?.text
                //                dict["post_code"] = "se19dy"
            }
            
            if arrRegistrationFields[i].isKindOfClass(EmailTxtTableViewCell){
                let cell = arrRegistrationFields[i] as! EmailTxtTableViewCell
                dict["email"] = cell.tf?.text
                //                dict["post_code"] = "se19dy"
            }
            
            if arrRegistrationFields[i].isKindOfClass(PickerTextfildTableViewCell){
                let cell = arrRegistrationFields[i] as! PickerTextfildTableViewCell
                dict["date_of_birth"] = cell.tfDatePicker?.text
            }
            //            let udidDict : Dictionary<String,String> = ["DEVICE_ID":NSUUID().UUIDString]
            //            dict["deviceRegistration"] = udidDict
            //            dict["device_ID"] = NSUUID().UUIDString
            
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
        else{
            return false
        }
    }
    
    func acceptPolicy(obj:ImportantInformationView){
        var dict = self.getAllValuesFromTxtFild()
        let objAPI = API()
        print("DictPara:\(dict)")
        // objAPI.storeValueInKeychainForKey("myUserInfo", value: dict)
        
        if(changePhoneNumber == false)
        {
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            objAnimView!.frame = self.view.frame
            objAnimView?.animate()
            self.view.addSubview(objAnimView!)
            objAPI.delegate = self
            objAPI.registerTheUserWithTitle(dict,apiName: "Customers")
            return
        }
        else{
            if(objAPI.getValueFromKeychainOfKey("myMobile") as! String == dict["phone_number"] as! String)
            {
                objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
                objAnimView!.frame = self.view.frame
                objAnimView?.animate()
                self.view.addSubview(objAnimView!)
                objAPI.delegate = self
                objAPI.registerTheUserWithTitle(dict,apiName: "Customers")
            }
            else
            {
                let alert = UIAlertController(title: "Looks like you have an earlier enrolled mobile number", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
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
    
    func checkTextFiledValidation()->Bool{
        var returnFlag = false
        self.getJSONForUI()
        var idx = 0
        for var i=0; i<arrRegistrationFields.count; i++ {
            var errorFLag = false
            var errorMsg = ""
            var dict = Dictionary<String, AnyObject>()
            //            var  dict : NSMutableDictionary = NSMutableDictionary()
            if arrRegistrationFields[i].isKindOfClass(TitleTableViewCell){
                let cell = arrRegistrationFields[i] as! TitleTableViewCell
                let str = cell.tfName?.text
                
                if (self.checkTextFieldContentOnlyNumber(str!) == true){
                    errorMsg = "Name should contain alphabets only"
                    if cell.tfTitle?.text?.characters.count==0 {
                        errorMsg = "Please select a title and name should contain alphabets only"
                    }
                    errorFLag = true
                    dictForTextFieldValue["errorTitle"] = errorMsg
                }
                    
                else if checkTextFieldContentSpecialChar(str!){
                    errorMsg = "Name should not contain special characters"
                    if cell.tfTitle?.text?.characters.count==0 {
                        errorMsg = "Please select a title and name should not contain special characters"
                    }
                    errorFLag = true
                    dictForTextFieldValue["errorTitle"] = errorMsg
                }
                    
                else if str?.characters.count > 50{
                    errorMsg = "Wow, that’s such a long name we can’t save it"
                    errorFLag = true
                    dictForTextFieldValue["errorTitle"] = errorMsg
                }
                    
                else if(cell.tfTitle?.text?.characters.count == 0 && cell.tfName?.text?.characters.count == 0){
                    errorMsg = "We need to know your title and name"
                    errorFLag = true
                    cell.tfTitle?.layer.borderColor = UIColor.redColor().CGColor
                    cell.tfName?.layer.borderColor = UIColor.redColor().CGColor
                    dictForTextFieldValue["errorTitle"] = errorMsg
                }
                else if cell.tfTitle?.text == ""{
                    errorMsg = "Please select a title"
                    errorFLag = true
                    dictForTextFieldValue["errorTitle"] = errorMsg
                    
                }
                else if str==""{
                    errorMsg = "We need to know what to call you"
                    errorFLag = true
                    dictForTextFieldValue["errorTitle"] = errorMsg
                    
                }
                else{
                    dictForTextFieldValue.removeValueForKey("errorTitle")
                    
                }
                
                dict = arrRegistration[0] as Dictionary<String,AnyObject>
                idx = 0
            }
            
            if arrRegistrationFields[i].isKindOfClass(TxtFieldTableViewCell){
                let cell = arrRegistrationFields[i] as! TxtFieldTableViewCell
                if cell.tf?.placeholder == "Surname"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "We need to know your surname"
                        dictForTextFieldValue["errorTxt"] = errorMsg
                        
                    }
                    else{
                        dictForTextFieldValue.removeValueForKey("errorTxt")
                    }
                    
                    if(str?.characters.count>50){
                        errorMsg = "Wow, that’s such a long name we can’t save it"
                        errorFLag = true
                        dictForTextFieldValue["errorSurname"] = errorMsg
                        //                        dictForTextFieldValue["errorTxt"] = errorMsg
                    }
                    else if(self.checkTextFieldContentOnlyNumber(str!) == true){
                        errorMsg = "Surname should contain alphabets only"
                        errorFLag = true
                        dictForTextFieldValue["errorSurname"] = errorMsg
                        //                        dictForTextFieldValue["errorTxt"] = errorMsg
                    }
                    else if checkTextFieldContentSpecialChar(str!){
                        errorMsg = "Surname should not contain special characters"
                        errorFLag = true
                        dictForTextFieldValue["errorSurname"] = errorMsg
                    }
                    else{
                        dictForTextFieldValue.removeValueForKey("errorSurname")
                    }
                    
                    dict = arrRegistration[2]as Dictionary<String,AnyObject>
                    idx = 2
                }
                
                if cell.tf?.placeholder == "First Address Line"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don’t forget your house number"
                        dictForTextFieldValue["errorFirstAddress"] = errorMsg
                        //                        dictForTextFieldValue["errorTxt"] = errorMsg
                    }
                    else{
                        dictForTextFieldValue.removeValueForKey("errorFirstAddress")
                    }
                    
                    dict = arrRegistration[9]as Dictionary<String,AnyObject>
                    idx = 9
                }
                
                if cell.tf?.placeholder == "Town"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don’t forget your town"
                        dictForTextFieldValue["errorTown"] = errorMsg
                        //                        dictForTextFieldValue["errorTxt"] = errorMsg
                    }
                    else{
                        dictForTextFieldValue.removeValueForKey("errorTown")
                    }
                    
                    dict = arrRegistration[13]as Dictionary<String,AnyObject>
                    idx = 13
                }
                
                if cell.tf?.placeholder == "County"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don’t forget your county"
                        dictForTextFieldValue["errorCounty"] = errorMsg
                        //                        dictForTextFieldValue["errorTxt"] = errorMsg
                    }
                    else{
                        dictForTextFieldValue.removeValueForKey("errorCounty")
                    }
                    
                    dict = arrRegistration[15]as Dictionary<String,AnyObject>
                    idx = 15
                }
                
                if cell.tf?.placeholder == "Mobile number"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don't forget your mobile number"
                        dictForTextFieldValue["errorMobileValidation"] = errorMsg
                        //                        dictForTextFieldValue["errorTxt"] = errorMsg
                        
                    }
                        
                        //                    else{
                        //                        dictForTextFieldValue.removeValueForKey("errorMobile")
                        //                    }
                        
                    else  if(self.checkTextFieldContentCharacters(str!) == true || self.phoneNumberValidation(str!)==false){
                        errorFLag = true
                        errorMsg = "That mobile number doesn’t look right"
                        dictForTextFieldValue["errorMobileValidation"] = errorMsg
                    }
                    else if(str?.characters.count < 10)
                    {
                        errorFLag = true
                        errorMsg = "That mobile number should be greater than 10 digits"
                        dictForTextFieldValue["errorMobileValidation"] = errorMsg
                    }
                    else if(str?.characters.count > 16)
                    {
                        errorFLag = true
                        errorMsg = "That mobile number should be of 15 digits"
                        dictForTextFieldValue["errorMobileValidation"] = errorMsg
                    }
                    else{
                        dictForTextFieldValue.removeValueForKey("errorMobileValidation")
                    }
                    
                    dict = arrRegistration[18]as Dictionary<String,AnyObject>
                    idx = 18
                }
                
                if cell.tf?.placeholder == "Email"{
                    let str = cell.tf?.text
                    if str==""{
                        errorFLag = true
                        errorMsg = "Don't forget your email address"
                        //                        dictForTextFieldValue["errorTxt"] = errorMsg
                        dictForTextFieldValue["errorEmail"] = errorMsg
                    }
                        
                    else{
                        dictForTextFieldValue.removeValueForKey("errorEmail")
                        
                    }
                    
                    if str?.characters.count>0 && (self.isValidEmail(str!)==false){
                        errorFLag = true
                        errorMsg = "That email address doesn’t look right"
                        //                        dictForTextFieldValue["errorTxt"] = errorMsg
                        dictForTextFieldValue["errorEmailValid"] = errorMsg
                    }
                    else{
                        dictForTextFieldValue.removeValueForKey("errorEmailValid")
                    }
                    dict = arrRegistration[20]as Dictionary<String,AnyObject>
                    idx = 20
                }
                
                
                if errorMsg.characters.count > 0
                {
                    
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
                else{
                    dictForTextFieldValue.removeValueForKey("errorPostcode")
                    dictForTextFieldValue.removeValueForKey("errorPostcodeValid")
                    
                }
                dict = arrRegistration[6]as Dictionary<String,AnyObject>
                idx = 6
            }
            
            if arrRegistrationFields[i].isKindOfClass(NumericTextTableViewCell){
                let cell = arrRegistrationFields[i] as! NumericTextTableViewCell
                let str = cell.tf?.text
                
                if str==""{
                    errorFLag = true
                    errorMsg = "Don't forget your mobile number"
                    dictForTextFieldValue["errorMobileValidation"] = errorMsg
                    //                        dictForTextFieldValue["errorTxt"] = errorMsg
                    
                }
                    
                    //                    else{
                    //                        dictForTextFieldValue.removeValueForKey("errorMobile")
                    //                    }
                    
                else  if(self.checkTextFieldContentCharacters(str!) == true || self.phoneNumberValidation(str!)==false){
                    errorFLag = true
                    errorMsg = "That mobile number doesn’t look right"
                    dictForTextFieldValue["errorMobileValidation"] = errorMsg
                }
                else if(str?.characters.count < 10)
                {
                    errorFLag = true
                    errorMsg = "That mobile number should be greater than 10 digits"
                    dictForTextFieldValue["errorMobileValidation"] = errorMsg
                }
                else if(str?.characters.count > 16)
                {
                    errorFLag = true
                    errorMsg = "That mobile number should be of 15 digits"
                    dictForTextFieldValue["errorMobileValidation"] = errorMsg
                }
                else{
                    dictForTextFieldValue.removeValueForKey("errorMobileValidation")
                }
                
                dict = arrRegistration[18]as Dictionary<String,AnyObject>
                idx = 18
                
            }
            if arrRegistrationFields[i].isKindOfClass(EmailTxtTableViewCell){
                let cell = arrRegistrationFields[i] as! EmailTxtTableViewCell
                let str = cell.tf?.text
                if str==""{
                    errorFLag = true
                    errorMsg = "Don't forget your email address"
                    //                        dictForTextFieldValue["errorTxt"] = errorMsg
                    dictForTextFieldValue["errorEmail"] = errorMsg
                }
                    
                else{
                    dictForTextFieldValue.removeValueForKey("errorEmail")
                }
                
                if str?.characters.count>0 && (self.isValidEmail(str!)==false){
                    errorFLag = true
                    errorMsg = "That email address doesn’t look right"
                    //                        dictForTextFieldValue["errorTxt"] = errorMsg
                    dictForTextFieldValue["errorEmailValid"] = errorMsg
                }
                else{
                    dictForTextFieldValue.removeValueForKey("errorEmailValid")
                }
                dict = arrRegistration[20]as Dictionary<String,AnyObject>
                idx = 20
            }
            
            
            if arrRegistrationFields[i].isKindOfClass(PickerTextfildTableViewCell){
                let cell = arrRegistrationFields[i] as! PickerTextfildTableViewCell
                let str = cell.tfDatePicker?.text
                if str==""{
                    errorFLag = true
                    errorMsg = "We need to know your date of birth"
                    dictForTextFieldValue["errorDOB"] = errorMsg
                    
                }
                else{
                    dictForTextFieldValue.removeValueForKey("errorDOB")
                }
                dict = arrRegistration[4]as Dictionary<String,AnyObject>
                idx = 4
            }
            
            print("\(idx)")
            
            if(errorFLag == true){
                returnFlag = true
                var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
                let lableDict = metadataDict["lable"]!.mutableCopy()
                
                lableDict.setValue("Yes", forKey: "isErrorShow")
                if errorMsg.characters.count>0{
                    lableDict.setValue(errorMsg, forKey: "title")
                }
                metadataDict["lable"] = lableDict
                dict["metaData"] = metadataDict
                arrRegistration[idx] = dict
                //                    print("\(dict)")
                
            }
        }
        self.createCells()
        return returnFlag
    }
    
    
    
    func phoneNumberValidation(value: String) -> Bool {
        //        var flag: Bool = false
        //        if(self.checkTextFieldContentOnlyNumber(value) == true){
        //            return
        //        }
        
        
        let charcter  = NSCharacterSet(charactersInString: "0123456789").invertedSet
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
        //        arrAddress = addressArray
        //        print("\(arrAddress)")
        
        var dict = arrRegistration[8] as Dictionary<String,AnyObject>
        var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
        let lableDict = metadataDict["textField1"]!.mutableCopy()
        lableDict.setValue(addressArray, forKey: "dropDownArray")
        metadataDict["textField1"] = lableDict
        dict["metaData"] = metadataDict
        arrRegistration[8] = dict
        arrAddress = addressArray
        print("\(arrAddress)")
        dictForTextFieldValue.removeValueForKey("errorPostcodeValid")
        self.createCells()
    }
    func error(error:String){
        objAnimView?.removeFromSuperview()
        print("\(error)")
        if(error == "That postcode doesn't look right"){
            var dict = arrRegistration[6] as Dictionary<String,AnyObject>
            var metadataDict = dict["metaData"]as! Dictionary<String,AnyObject>
            let lableDict = metadataDict["lable"]!.mutableCopy()
            lableDict.setValue("Yes", forKey: "isErrorShow")
            lableDict.setValue(error, forKey: "title")
            metadataDict["lable"] = lableDict
            dict["metaData"] = metadataDict
            dictForTextFieldValue["errorPostcodeValid"] = "That postcode doesn't look right"
            arrRegistration[6] = dict
            self.createCells()
        }
        else{
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
    
    // MARK: - GetUserInfoDelegate
    func successResponseForGetUserInfoAPI(objResponse: Dictionary<String, AnyObject>) {
     print(objResponse)
        if let message = objResponse["message"] as? String
        {
            if(message == "Party Found")
            {
                userInfoDict = objResponse["party"] as! Dictionary<String,AnyObject>
                //Get Registration UI Json data
                self.getJSONForUI()
                //Setup Registration UI
                self.createCells()
            }
            else{
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        objAnimView!.removeFromSuperview()
    }
    
    func errorResponseForGetUserInfoAPI(error: String) {
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView!.removeFromSuperview()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
