//
//  SASavingPlanViewController.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
import Stripe

class SASavingPlanViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate,SavingPlanCostTableViewCellDelegate,SavingPlanDatePickerCellDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PartySavingPlanDelegate,SAOfferListViewDelegate,SavingPlanTitleTableViewCellDelegate,SegmentBarChangeDelegate,GetUsersPlanDelegate,UpdateSavingPlanDelegate,STPAddCardViewControllerDelegate,AddSavingCardDelegate {
    
    @IBOutlet weak var topBackgroundImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    @IBOutlet weak var tblViewHt: NSLayoutConstraint!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var upperView: UIView!
    
    var tokenstripeID : String = ""
    var cost : Int = 0
    var dateDiff : Int = 0
    var dateString = kDate
    var popOverSelectedStr = ""
    var datePickerDate : String = ""
    var itemTitle : String = ""
    var imageDataDict : Dictionary<String,AnyObject> = [:]
    var itemDetailsDataDict : Dictionary<String,AnyObject> = [:]
    var offerCount = 0
    var offerArr: Array<Dictionary<String,AnyObject>> = []
    var updateOfferArr: Array<Dictionary<String,AnyObject>> = []
    var userInfoDict  = Dictionary<String,AnyObject>()
    var  objAnimView = ImageViewAnimation()
    var isPopoverValueChanged = false
    var isClearPressed = false
    var isUpdatePlan = false
    var isImageClicked = false
    var isDateChanged = false
    var isOfferDetailPressed = false
    var isChangeSegment = false
    var offerDetailHeight : CGFloat = 0.0
    var offerDetailTag = 0
    var prevOfferDetailTag = 0
    var imagePicker = UIImagePickerController()
    var isOfferShow: Bool = true
    var payTypeStr = ""
    var dateFromUpdatePlan = ""
    var isCostChanged = false
    
    var isComingGallary = false
    var recurringAmount : CGFloat = 0
    
    var isFromGroupMemberPlan = false
    
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        offerArr.removeAll()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        if(isUpdatePlan)
        {
            self.title = "Update plan"
        }
        else
        {
            self.title = "Plan setup"
        }
        popOverSelectedStr = "1"
        let font = UIFont(name: kBookFont, size: 15)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font!]
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        //Register the UITableViewCell from xib
        tblView!.registerNib(UINib(nibName: "SavingPlanTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanTitleIdentifier")
        tblView!.registerNib(UINib(nibName: "SavingPlanCostTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanCostIdentifier")
        tblView!.registerNib(UINib(nibName: "SavingPlanDatePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanDatePickerIdentifier")
        tblView!.registerNib(UINib(nibName: "SetDayTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanSetDateIdentifier")
        tblView!.registerNib(UINib(nibName: "CalculationTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanCalculationIdentifier")
        //OfferTableViewCell
        tblView!.registerNib(UINib(nibName: "OfferTableViewCell", bundle: nil), forCellReuseIdentifier: "OfferTableViewCellIdentifier")
        tblView!.registerNib(UINib(nibName: "NextButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "NextButtonCellIdentifier")
        tblView!.registerNib(UINib(nibName: "ClearButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ClearButtonIdentifier")
        //CancelSavingPlanIdentifier
        tblView!.registerNib(UINib(nibName: "CancelButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "CancelSavingPlanIdentifier")
        
        let objAPI = API()
        userInfoDict = NSUserDefaults.standardUserDefaults().objectForKey(kUserInfo) as! Dictionary<String,AnyObject>
        //        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        topBackgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        topBackgroundImageView.layer.masksToBounds = true
        
        self.setUpView()
        if(self.isUpdatePlan)
        {
            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            objAPI.getUsersSavingPlan("i")
            objAPI.getSavingPlanDelegate = self
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Set the contentsize of UIScrollView
        if  isComingGallary == false {
            
            self.scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblViewHt.constant )
        }
    }
    
    func setUpView(){
        //set Navigation left button
        let leftBtnName = UIButton()
        if (isUpdatePlan) {
            leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
            leftBtnName.frame = CGRectMake(0, 0, 30, 30)
            leftBtnName.addTarget(self, action: #selector(SASavingPlanViewController.menuButtonClicked), forControlEvents: .TouchUpInside)
        } else  {
            leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
            leftBtnName.frame = CGRectMake(0, 0, 30, 30)
            leftBtnName.addTarget(self, action: #selector(SASavingPlanViewController.backButtonClicked), forControlEvents: .TouchUpInside)
        }
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.addTarget(self, action: #selector(SASavingPlanViewController.heartBtnClicked), forControlEvents: .TouchUpInside)
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>
            btnName.setTitle(String(format:"%d",wishListArray!.count), forState: UIControlState.Normal)
            if(wishListArray?.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
            }
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        //Set up image
        if(itemDetailsDataDict[kImageURL] != nil && !(itemDetailsDataDict[kImageURL] is NSNull))
        {
            let url = NSURL(string:itemDetailsDataDict[kImageURL] as! String)
            if(url != "")
            {
                //Add spinner to UIImageView until image loads
                let spinner =  UIActivityIndicatorView()
                spinner.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, topBackgroundImageView.frame.size.height/2)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
                topBackgroundImageView.addSubview(spinner)
                spinner.startAnimating()
                let request: NSURLRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                    if(data?.length > 0)
                    {
                        let image = UIImage(data: data!)
                        dispatch_async(dispatch_get_main_queue(), {
                            //Remove the spinner after image load
                            spinner.stopAnimating()
                            spinner.hidden = true
                            self.topBackgroundImageView.image = image
                        })
                    }
                    else {
                        //Remove the spinner if image is not present
                        spinner.stopAnimating()
                        spinner.hidden = true
                        self.topBackgroundImageView.image = UIImage(named: "generic-setup-bg.png")
                    }
                })
            }
            else
            {
                self.topBackgroundImageView.image = UIImage(named: "generic-setup-bg.png")
            }
            
            cameraButton.hidden = true
            itemTitle = (itemDetailsDataDict[kTitle] as? String)!
            cost = Int(itemDetailsDataDict[kAmount] as! NSNumber)
            isPopoverValueChanged = true
            isCostChanged = true
            
            imageDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
            topBackgroundImageView.image = self.setTopImageAsPer(imageDataDict)
            self.cameraButton.hidden = false
        }
        else
        {
            imageDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
            topBackgroundImageView.image = self.setTopImageAsPer(imageDataDict)
            self.cameraButton.hidden = false
        }
        
        print("tblHT=\(tblViewHt.constant)")
        if(isUpdatePlan)
        {
            tblViewHt.constant = tblView.frame.size.height + 10// + 250
            if(isClearPressed)
            {
                //Add spinner to UIImageView until image loads
                let spinner =  UIActivityIndicatorView()
                spinner.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, (self.topBackgroundImageView.frame.size.height/2)+20)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
                self.topBackgroundImageView.addSubview(spinner)
                spinner.startAnimating()
                
                if !(itemDetailsDataDict["image"] is NSNull) {
                    if  let url = NSURL(string:itemDetailsDataDict["image"] as! String)
                    {
                        //load the image from URL
                        let request: NSURLRequest = NSURLRequest(URL: url)
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                            if(data?.length > 0)
                            {
                                let image = UIImage(data: data!)
                                dispatch_async(dispatch_get_main_queue(), {
                                    //Remove the spinner after image load
                                    spinner.stopAnimating()
                                    spinner.hidden = true
                                    self.topBackgroundImageView.image = image
                                })
                            }
                            else
                            {
                                //Remove the spinner after image load
                                spinner.stopAnimating()
                                spinner.hidden = true
                            }
                        })
                    }
                }
                else {
                    //Remove the spinner if image is not there
                    spinner.stopAnimating()
                    spinner.hidden = true
                }
            }
        }
        else{
            tblViewHt.constant = tblView.frame.size.height  + 40
            
        }
        
        scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblViewHt.constant)
    }
    
    //set top image as per selected category
    func setTopImageAsPer(dict:Dictionary<String,AnyObject>) -> UIImage{
        
        if(imageDataDict["savPlanID"] as! Int == 85) {
            return UIImage(named: "groupsave-setup-bg.png")!
        }
        else if(imageDataDict["savPlanID"] as! Int == 86) {
            return UIImage(named: "wdding-setup-bg.png")!
        }
        else if(imageDataDict["savPlanID"] as! Int == 87) {
            return UIImage(named: "baby-setup-bg.png")!
        }
        else if(imageDataDict["savPlanID"] as! Int == 88) {
            return UIImage(named: "holiday-setup-bg.png")!
        }
        else if(imageDataDict["savPlanID"] as! Int == 89) {
            return UIImage(named: "ride-setup-bg.png")!
        }
        else if(imageDataDict["savPlanID"] as! Int == 90) {
            return UIImage(named: "home-setup-bg.png")!
        }
        else if(imageDataDict["savPlanID"] as! Int == 91) {
            return UIImage(named: "gadget-setup-bg.png")!
        }
        else {
            return UIImage(named: "generic-setup-bg.png")!
        }
        
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData  {
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>
            if wishListArray!.count>0{
                //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
                NSNotificationCenter.defaultCenter().postNotificationName(kSelectRowIdentifier, object: "SAWishListViewController")
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")            }
            else {
                let alert = UIAlertView(title: kWishlistempty, message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else {
            let alert = UIAlertView(title: kWishlistempty, message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func backButtonClicked()
    {
        if isOfferShow == false && offerArr.count > 0 {
            let obj = SAOfferListViewController()
            isOfferDetailPressed = false
            obj.delegate = self
            obj.isComingProgress = false
            obj.addedOfferArr = offerArr
            if(isUpdatePlan)
            {
                obj.savID = 63//itemDetailsDataDict["sav_id"] as! NSNumber
            }
            else {
                if let str = imageDataDict["savPlanID"] as? NSNumber{
                    obj.savID = str
                }
                else {
                    obj.savID = Int(imageDataDict["savPlanID"] as! String)!
                }
            }
            self.navigationController?.pushViewController(obj, animated: true)
            
        }
        else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    //action method of camera button
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        //show alert view controller to choose option from gallery and camera
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        //alert view controll action method
        alertController.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default)
        { action -> Void in
            
            //Check if camera is available
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.imagePicker.allowsEditing = true
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            else {
                //Give alert if camera is not available
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            })
        //alert view controll action method
        alertController.addAction(UIAlertAction(title: "Choose Photo", style: UIAlertActionStyle.Default)
        { action -> Void in
            //check if Photolibrary available
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.imagePicker.allowsEditing = true
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            else {
                //Give alert if camera is not available
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            
            })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: UITableviewDelegate and UITableviewDataSource methods
    //return the number of sections in table view.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return offerArr.count+7
        //        if(isUpdatePlan)
        //        {
        //            return offerArr.count+8
        //        }
        //        else
        //        {
        //            return offerArr.count+7
        //        }
    }
    
    //return the number of rows in each section in table view.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //create custom cell from their respective Identifiers.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if(indexPath.section == 0) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanTitleIdentifier", forIndexPath: indexPath) as! SavingPlanTitleTableViewCell
            cell1.tblView = tblView
            cell1.view = self.scrlView
            cell1.savingPlanTitleDelegate = self
            if(itemDetailsDataDict[kTitle] != nil)
            {
                cell1.titleTextField.text = itemTitle
                cell1.titleTextField.textColor = UIColor(red:244/255, green: 176/255, blue: 58/255, alpha: 1)
            }
            if(isClearPressed)
            {
                if(isUpdatePlan)
                {
                    cell1.titleTextField.text = itemDetailsDataDict[kTitle] as? String
                }
                else {
                    cell1.titleTextField.text = itemTitle
                }
            }
            return cell1
        }
        else if(indexPath.section == 1) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanCostIdentifier", forIndexPath: indexPath) as! SavingPlanCostTableViewCell
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            cell1.tblView = tblView
            cell1.delegate = self
            cell1.view = self.scrlView
            if(itemDetailsDataDict[kAmount] != nil || isPopoverValueChanged || isOfferShow ) {
                let amountString = "£" + String(format: "%d", cost)
                cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                cell1.slider.value =  Float(cost)
                cost = Int(cell1.slider.value)
            }
            else {
                cell1.costTextField.attributedText = cell1.createAttributedString("£0")
                cell1.slider.value = 0
                cost = 0
            }
            if(isClearPressed) {
                if(isUpdatePlan) {
                    if(isDateChanged) {
                        let amountString = "£" + String(format: "%d", cost)
                        cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                        cell1.slider.value = Float(cost)
                        cost = Int(cell1.slider.value)
                    }
                    else {
                        if(itemDetailsDataDict[kAmount] is String) {
                            let amountString = "£" + String(itemDetailsDataDict[kAmount])
                            cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                            cell1.slider.value = Float(itemDetailsDataDict[kAmount] as! String)!
                        }
                        else {
                            let amountString = "£" + String(format: "%d", (itemDetailsDataDict[kAmount] as! NSNumber).intValue)
                            cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                            cell1.slider.value = (itemDetailsDataDict[kAmount] as! NSNumber).floatValue
                        }
                        cost = Int(cell1.slider.value)
                    }
                }
                else  {
                    let amountString =  "£" + String(format:"%d",cost)
                    cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                    cell1.slider.value = Float(cost)
                }
            }
            return cell1
        }
        else if(indexPath.section == 2) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanDatePickerIdentifier", forIndexPath: indexPath) as! SavingPlanDatePickerTableViewCell
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            cell1.tblView = tblView
            cell1.savingPlanDatePickerDelegate = self
            cell1.view = self.scrlView
            
            if(datePickerDate == "")
            {
                //                let dateFormatter = NSDateFormatter()
                //                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                //                cell1.datePickerTextField.text = dateFormatter.stringFromDate(NSDate())
                
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                let dateComponents = NSDateComponents()
                let calender = NSCalendar.currentCalendar()
                dateComponents.month = 3
                let newDate = calender.dateByAddingComponents(dateComponents, toDate: NSDate(), options:NSCalendarOptions(rawValue: 0))
                datePickerDate = dateFormatter.stringFromDate(newDate!)
                cell1.datePickerTextField.text = datePickerDate
                let timeDifference : NSTimeInterval = newDate!.timeIntervalSinceDate(NSDate())
                dateDiff = Int(timeDifference/3600)
            }
            else
            {
                cell1.datePickerTextField.text = datePickerDate
                cell1.datePickerTextField.textColor = UIColor.whiteColor()
                print(datePickerDate)
            }
            
            if(isClearPressed) {
                
                //                let dateFormatter = NSDateFormatter()
                //                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                //                let dateComponents = NSDateComponents()
                //                let calender = NSCalendar.currentCalendar()
                //                dateComponents.month = 3
                //                let newDate = calender.dateByAddingComponents(dateComponents, toDate: NSDate(), options:NSCalendarOptions(rawValue: 0))
                //                datePickerDate = dateFormatter.stringFromDate(newDate!)
                //                cell1.datePickerTextField.text = datePickerDate
                //                let timeDifference : NSTimeInterval = newDate!.timeIntervalSinceDate(NSDate())
                //                dateDiff = Int(timeDifference/3600)
                
                
                //                if(isUpdatePlan) {
                //                    if(itemDetailsDataDict["planEndDate"] != nil) {
                //                        cell1.datePickerTextField.text = itemDetailsDataDict["planEndDate"] as? String
                //                        cell1.datePickerTextField.textColor = UIColor.whiteColor()
                //                        datePickerDate = (itemDetailsDataDict["planEndDate"] as? String)!
                //                    }
                //                }
                //                else {
                //
                //                    let dateFormatter = NSDateFormatter()
                //                    dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                //                    cell1.datePickerTextField.text = dateFormatter.stringFromDate(NSDate())
                //                }
            }
            if(dateString == kDate)
            {
                cell1.dateString = kDate
            }
            else {
                cell1.dateString = kDay
            }
            return cell1
        }
        else if(indexPath.section == 3) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanSetDateIdentifier", forIndexPath: indexPath) as! SetDayTableViewCell
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            cell1.tblView = tblView
            cell1.view = self.scrlView
            
            cell1.segmentDelegate = self
            
            if(isUpdatePlan) {
                if(isChangeSegment == false) {
                    if let payType = itemDetailsDataDict["payType"] as? NSString {
                        if(payType == kWeek) {
                            let button = UIButton()
                            button.tag = 0
                            cell1.segmentBar.toggleButton(button)
                            payTypeStr = kDay
                            popOverSelectedStr =  itemDetailsDataDict["payDate"] as! String
                            dateFromUpdatePlan = popOverSelectedStr
                        }
                        else {
                            dateFromUpdatePlan = popOverSelectedStr
                            payTypeStr = kDate
                        }
                    }
                }
                
                if(popOverSelectedStr != "") {
                    
                    if(dateString == kDay) {
                        cell1.dayDateTextField.text = self.popOverSelectedStr
                    }
                    else {
                        cell1.dayDateTextField.attributedText = self.createXLabelText(Int(self.popOverSelectedStr)!, text: self.popOverSelectedStr)
                    }
                }
                else {
                    cell1.dayDateTextField.text = ""
                }
            }
            else
            {
                if(popOverSelectedStr != "") {
                    if(dateString == kDay) {
                        cell1.dayDateTextField.text = self.popOverSelectedStr
                    }
                    else {
                        cell1.dayDateTextField.attributedText = self.createXLabelText(Int(self.popOverSelectedStr)!, text: self.popOverSelectedStr)
                    }
                }
                else {
                    //                    cell1.dayDateTextField.text = ""
                    var str = "1"
                    cell1.dayDateTextField.attributedText =  self.createXLabelText(1, text: str)
                }
            }
            //            if(isClearPressed)  {
            //                if(isUpdatePlan) {
            //                    if let payType = itemDetailsDataDict["payType"] as? NSString {
            //                        if(payType == "Week") {
            //                            let button = UIButton()
            //                            button.tag = 0
            //                            cell1.segmentBar.toggleButton(button)
            //                        }
            //                        else if(isChangeSegment) {
            //                            let button = UIButton()
            //                            button.tag = 1
            //                            cell1.segmentBar.toggleButton(button)
            //                        }
            //                    }
            //                    if let payDate = itemDetailsDataDict["payDate"] as? String {
            //                        if(isPopoverValueChanged)
            //                        {
            //                            if(popOverSelectedStr != "") {
            //                                if(dateString == "day") {
            //                                    cell1.dayDateTextField.text = popOverSelectedStr
            //                                }
            //                                else {
            //                                    cell1.dayDateTextField.attributedText = self.createXLabelText(Int(popOverSelectedStr)!, text: popOverSelectedStr)
            //                                }
            //                            }
            //                            else {
            //                                if(dateString == "day") {
            //                                    cell1.dayDateTextField.text = payDate
            //                                }
            //                                else {
            //                                    cell1.dayDateTextField.attributedText = self.createXLabelText(Int(payDate)!, text: payDate)
            //                                }
            //                            }
            //                        }
            //                        else {
            //                            if(dateString == "day") {
            //                                cell1.dayDateTextField.text = payDate
            //                            }
            //                            else {
            //                                cell1.dayDateTextField.attributedText = self.createXLabelText(Int(payDate)!, text: payDate)
            //                            }
            //                        }
            //                    }
            //                }
            //                else {
            //                    if(isPopoverValueChanged) {
            //                        if(popOverSelectedStr != "") {
            //                            if(dateString == "day") {
            //                                cell1.dayDateTextField.text = popOverSelectedStr
            //                            }
            //                            else {
            //                                cell1.dayDateTextField.attributedText = self.createXLabelText(Int(popOverSelectedStr)!, text: popOverSelectedStr)
            //                            }
            //                        }
            //                        else {
            //                            cell1.dayDateTextField.text = ""
            //                        }
            //                    }
            //                    else {
            //                        cell1.dayDateTextField.text = ""
            //                    }
            //                }
            //            }
            return cell1
        }
        else if(indexPath.section == 4) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanCalculationIdentifier", forIndexPath: indexPath) as! CalculationTableViewCell
            cell1.tblView = tblView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if(isPopoverValueChanged) {
                if(dateString == kDay) {
                    if((dateDiff/168) == 1) {
                        cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per week for %d week",round(CGFloat(cost))/CGFloat((dateDiff/168)),(dateDiff/168))
                        recurringAmount = round(CGFloat(cost))/CGFloat((dateDiff/168))
                    }
                    else if ((dateDiff/168) == 0) {
                        
                        cell1.calculationLabel.text = String(format: "You will need to top up £%d per week for 1 week",cost)
                        recurringAmount = CGFloat(cost)
                    }
                    else {
                        cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per week for %d weeks",round(CGFloat(cost))/CGFloat((dateDiff/168)),(dateDiff/168))
                        recurringAmount = round(CGFloat(cost))/CGFloat((dateDiff/168))
                    }
                }
                else {
                    if((dateDiff/168)/4 == 1) {
                        cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per month for %d month",round((CGFloat(cost))/(CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                        recurringAmount = round((CGFloat(cost))/(CGFloat((dateDiff/168)/4)))
                    }
                    else if ((dateDiff/168)/4 == 0) {
                        
                        cell1.calculationLabel.text = String(format: "You will need to top up £%d per month for 1 month",cost)
                        recurringAmount = CGFloat(cost)
                    }
                    else {
                        cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per month for %d months",round((CGFloat(cost))/(CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                        recurringAmount = round((CGFloat(cost))/(CGFloat((dateDiff/168)/4)))
                    }
                }
            }
            
            if(isUpdatePlan) {
                if(isDateChanged) {
                    if(dateString == kDay) {
                        if((dateDiff/168) == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per week for %d week",round(CGFloat(cost)/CGFloat((dateDiff/168))),(dateDiff/168))
                            recurringAmount = round(CGFloat(cost)/CGFloat((dateDiff/168)))
                        }
                        else if ((dateDiff/168) == 0) {
                            cell1.calculationLabel.text = "You will need to top up £0 per week for 0 week"
                            recurringAmount = 0
                        }
                        else {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per week for %d weeks",round(CGFloat(cost)/CGFloat((dateDiff/168))),(dateDiff/168))
                            recurringAmount = round(CGFloat(cost)/CGFloat((dateDiff/168)))
                        }
                    }
                    else {
                        if((dateDiff/168)/4 == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per month for %d month",round((CGFloat(cost)/(CGFloat((dateDiff/168)/4)))),(dateDiff/168)/4)
                            recurringAmount = round((CGFloat(cost)/(CGFloat((dateDiff/168)/4))))
                        }
                        else if ((dateDiff/168)/4 == 0) {
                            cell1.calculationLabel.text = "You will need to top up £0 per month for 0 month"
                            recurringAmount = 0
                        }
                        else {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per month for %d months",round((CGFloat(cost)/(CGFloat((dateDiff/168)/4)))),(dateDiff/168)/4)
                            recurringAmount = round((CGFloat(cost)/(CGFloat((dateDiff/168)/4))))
                        }
                    }
                }
                else
                {
                    
                    if let payType = itemDetailsDataDict["payType"] as? NSString
                    {
                        //                        if isChangeSegment{
                        //                            print("change")
                        //
                        ////                            let dateFormatter = NSDateFormatter()
                        ////                            dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                        ////                            let pickrDate = dateFormatter.stringFromDate(datePickerView.date)
                        ////                            datePickerTextField.text = pickrDate
                        ////                            datePickerTextField.textColor = UIColor.whiteColor()
                        ////
                        ////                            let timeDifference : NSTimeInterval = datePickerView.date.timeIntervalSinceDate(NSDate())
                        //
                        //                        }
                        let date  = itemDetailsDataDict["planEndDate"] as? String
                        
                        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                        let currentDate: NSDate = NSDate()
                        let components: NSDateComponents = NSDateComponents()
                        //                        components.day = +7
                        let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        //                            dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                        
                        let dt = dateFormatter.dateFromString(date!)!
                        //                        let timeDifference : NSTimeInterval = dateFormatter.dateFromString(date!)!.timeIntervalSinceDate(minDate)
                        let timeDifference : NSTimeInterval = dt.timeIntervalSinceDate(NSDate())
                        dateDiff = Int(timeDifference/3600)
                        if(payType == kMonth) {
                            if((dateDiff/168) == 1) {
                                cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per month for %d month",round(CGFloat(cost)/(CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                                recurringAmount = round(CGFloat(cost)/(CGFloat((dateDiff/168)/4)))
                            }
                            else {
                                cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per month for %d month",round(CGFloat(cost)/(CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                                recurringAmount = round(CGFloat(cost)/(CGFloat((dateDiff/168)/4)))
                            }
                            
                        }
                        else {
                            if((dateDiff/168)/4 == 1) {
                                cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per week for %d week",round(CGFloat(cost)/CGFloat((dateDiff/168))),(dateDiff/168))
                                recurringAmount = round(CGFloat(cost)/CGFloat((dateDiff/168)))
                            }
                            else {
                                cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per week for %d weeks",round(CGFloat(cost)/CGFloat((dateDiff/168))),(dateDiff/168))
                                recurringAmount = round(CGFloat(cost)/CGFloat((dateDiff/168)))
                            }
                        }
                        
                        if isChangeSegment {
                            if dateString == kDay{
                                if((dateDiff/168) == 1) {
                                    cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per week for %d week",round(CGFloat(cost)/CGFloat((dateDiff/168))),(dateDiff/168))
                                    recurringAmount = round(CGFloat(cost)/CGFloat((dateDiff/168)))
                                }
                                else if ((dateDiff/168) == 0) {
                                    cell1.calculationLabel.text = "You will need to top up £0 per week for 0 week"
                                    recurringAmount = 0
                                }
                                else {
                                    cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per week for %d weeks",round(CGFloat(cost)/CGFloat((dateDiff/168))),(dateDiff/168))
                                    recurringAmount = round(CGFloat(cost)/CGFloat((dateDiff/168)))
                                }
                            }else{
                                if((dateDiff/168)/4 == 1) {
                                    cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per month for %d month",round((CGFloat(cost))/(CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                                    recurringAmount = round((CGFloat(cost))/(CGFloat((dateDiff/168)/4)))
                                }
                                else if ((dateDiff/168)/4 == 0) {
                                    
                                    cell1.calculationLabel.text = String(format: "You will need to top up £%d per month for 1 month",cost)
                                    recurringAmount = CGFloat(cost)
                                }
                                else {
                                    cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per month for %d months",round((CGFloat(cost))/(CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                                    recurringAmount = round((CGFloat(cost))/(CGFloat((dateDiff/168)/4)))
                                }
                            }
                            
                        }
                    }
                }
            }
            return cell1
        }
        else if(indexPath.section == offerArr.count+5) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("NextButtonCellIdentifier", forIndexPath: indexPath) as! NextButtonTableViewCell
            cell1.tblView = tblView
            
            cell1.nextButton.addTarget(self, action: #selector(SASavingPlanViewController.nextButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else if(indexPath.section == offerArr.count+6) {
            if isUpdatePlan{
                let cell1 = tableView.dequeueReusableCellWithIdentifier("CancelSavingPlanIdentifier", forIndexPath: indexPath) as! CancelButtonTableViewCell
                cell1.cancelSavingPlanButton.addTarget(self, action: #selector(SASavingPlanViewController.cancelSavingButtonPressed(_:)), forControlEvents: .TouchUpInside)
                return cell1
            }
            else{
                
                
                let cell1 = tableView.dequeueReusableCellWithIdentifier("ClearButtonIdentifier", forIndexPath: indexPath) as! ClearButtonTableViewCell
                cell1.tblView = tblView
                cell1.clearButton.addTarget(self, action: #selector(SASavingPlanViewController.clearButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
                return cell1
                
            }
        }
        else if(indexPath.section == offerArr.count+7) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("CancelSavingPlanIdentifier", forIndexPath: indexPath) as! CancelButtonTableViewCell
            cell1.cancelSavingPlanButton.addTarget(self, action: #selector(SASavingPlanViewController.cancelSavingButtonPressed(_:)), forControlEvents: .TouchUpInside)
            return cell1
        }
        else {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("OfferTableViewCellIdentifier", forIndexPath: indexPath) as! OfferTableViewCell
            
            cell1.tblView = tblView
            cell1.closeButton.tag = indexPath.section
            cell1.closeButton.addTarget(self, action: #selector(SASavingPlanViewController.closeOfferButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            let ind = indexPath.section - 5
            let dict = offerArr[ind]
            cell1.offerTitleLabel.text = dict["offCompanyName"] as? String
            cell1.offerDetailLabel.text = dict["offTitle"] as? String
            cell1.descriptionLabel.text = dict["offSummary"] as? String
            
            if(isUpdatePlan) {
                cell1.offerDetailsButton.hidden = false
                cell1.offerDetailsButton.tag = indexPath.section
                cell1.offerDetailsButton.setTitle("Offer details", forState: .Normal)
                cell1.offerDetailsButton.titleEdgeInsets = UIEdgeInsetsMake(0, (cell1.offerDetailsButton.imageView?.frame.size.width)!, 0, -(((cell1.offerDetailsButton.imageView?.frame.size.width)!-30)))
                cell1.offerDetailsButton.setImage(UIImage(named:"detail-arrow-down.png"), forState: .Normal)
                cell1.offerDetailsButton.imageEdgeInsets = UIEdgeInsetsMake(0, (cell1.offerDetailsButton.titleLabel?.frame.size.width)!, 0, -(((cell1.offerDetailsButton.titleLabel?.frame.size.width)!+30)))
                cell1.offerDetailsButton.addTarget(self, action: #selector(SASavingPlanViewController.offerDetailsButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                if(isClearPressed) {
                    cell1.detailOfferLabel.hidden = true
                }
                else {
                    if(isOfferDetailPressed == true) {
                        if(indexPath.section == offerDetailTag) {
                            offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: kLightFont, size: 13)!, width: cell1.detailOfferLabel.frame.width)
                            cell1.detailOfferLabelHeight.constant = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: kLightFont, size: 13)!, width: cell1.detailOfferLabel.frame.width)
                            cell1.detailOfferLabel.hidden = false
                            cell1.detailOfferLabel.text = dict["offDesc"] as? String
                            cell1.offerDetailsButton.setImage(UIImage(named:"detail-arrow-up.png"), forState: .Normal)
                            cell1.offerDetailsButton.imageEdgeInsets = UIEdgeInsetsMake(0, (cell1.offerDetailsButton.titleLabel?.frame.size.width)!, 0,-(((cell1.offerDetailsButton.titleLabel?.frame.size.width)!+30)))
                            
                        }
                        else {
                            cell1.detailOfferLabel.hidden = true
                        }
                    }
                    else {
                        cell1.detailOfferLabel.hidden = true
                    }
                }
            }
            let urlStr = dict["offImage"] as! String
            let url = NSURL(string: urlStr)
            let request: NSURLRequest = NSURLRequest(URL: url!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if (data != nil && data?.length > 0) {
                    let image = UIImage(data: data!)
                    dispatch_async(dispatch_get_main_queue(), {
                        cell1.offerImageView?.image = image
                    })
                }
            })
            
            return cell1
        }
    }
    
    
    //Calculate height of offer description text
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    //action method of offer details button
    func offerDetailsButtonPressed(sender:UIButton)
    {
        let dict = offerArr[sender.tag - 5]
        offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: kLightFont, size: 13)!, width: UIScreen.mainScreen().bounds.width - 70)
        isChangeSegment = true
        if(isOfferDetailPressed == true) {
            if(prevOfferDetailTag != sender.tag) {
                let oldDict = offerArr[prevOfferDetailTag - 5]
                let oldOfferDetailHeight = self.heightForView((oldDict["offDesc"] as? String)!, font: UIFont(name:kLightFont, size: 13)!, width: UIScreen.mainScreen().bounds.width - 70)
                
                tblViewHt.constant = tblView.frame.size.height - oldOfferDetailHeight +  offerDetailHeight
                offerDetailTag = sender.tag
                prevOfferDetailTag = offerDetailTag
            }
            else {
                isOfferDetailPressed = false
                tblViewHt.constant = tblView.frame.size.height - (90 + offerDetailHeight)
                scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width,scrlView.contentSize.height - (90 + offerDetailHeight))
            }
        }
        else {
            isOfferDetailPressed = true
            offerDetailTag = sender.tag
            prevOfferDetailTag = offerDetailTag
            tblViewHt.constant = tblView.frame.size.height +  90 + offerDetailHeight
            scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width,scrlView.contentSize.height + 90 + offerDetailHeight)
        }
        self.tblView.reloadData()
    }
    
    //This is UITableViewDelegate method used to set the view for UITableView header.
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view : UIView = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    //This is UITableViewDelegate method used to set the height of header.
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    
    //This is UITableViewDelegate method used to set the height of rows per section.
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.section == 0)
        {
            return 44
        }
        else if(indexPath.section == 1){
            return 90
        }
        else if(indexPath.section == 2){
            return 70
        }
        else if(indexPath.section == 3){
            return 65
        }
        else if(indexPath.section == 4) {
            if(isPopoverValueChanged == true) {
                return 40
            }
            else {
                return 0
            }
        }
        else if(indexPath.section == offerArr.count+5) {
            return 65
        }
        else if(indexPath.section == offerArr.count+6){
            return 44
        }
        else if(indexPath.section == offerArr.count+7){
            if(isUpdatePlan)
            {
                return 65
            }
            else {
                return 0
            }
        }
        else {
            if(isUpdatePlan) {
                if(isOfferDetailPressed){
                    if(offerDetailTag == indexPath.section) {
                        return CGFloat(120 + offerDetailHeight)
                    }
                    else {
                        return 90
                    }
                    
                }
                else {
                    return 90
                }
            }
            else {
                return 72
            }
        }
    }
    
    //Get title text field delegate methods
    func getTextFieldText(text: String) {
        itemTitle = text
    }
    
    //This is SegmentBarChangeDelegate method used to get the selected date/day for saving plans recurring payment.
    func getDateTextField(str: String) {
        popOverSelectedStr = str
        if(isUpdatePlan) {
            if(isPopoverValueChanged == false) {
                tblViewHt.constant = tblView.frame.size.height  + 44
            }
            dateFromUpdatePlan = ""
        }
        else {
            if(isPopoverValueChanged == false)
            {
                tblViewHt.constant = tblView.frame.size.height  + 44
            }
        }
        isPopoverValueChanged = true
        scrlView.contentSize = CGSizeMake(0, tblView.frame.origin.y+tblViewHt.constant)
        tblView.reloadData()
    }
    
    //This is SegmentBarChangeDelegate method used to get the selected date/day for saving plans recurring payment.
    func segmentBarChanged(str: String) {
        if(isUpdatePlan) {
            if(str == kDate)  {
                dateString = kDate
            }
            else {
                dateString = kDay
            }
            isChangeSegment = true
            isPopoverValueChanged = true
            
            if(str == payTypeStr)  {
                popOverSelectedStr = dateFromUpdatePlan
                tblView.reloadData()
            }
            else {
                popOverSelectedStr = ""
                tblView.reloadData()
            }
            isClearPressed  = false
            
            
        }
        else {
            popOverSelectedStr = datePickerDate
            if(str == kDate) {
                dateString = kDate
            }
            else {
                dateString = kDay
            }
        }
        isChangeSegment = true
        isPopoverValueChanged = true
        
    }
    
    //This is SavingPlanDatePickerCellDelegate method used to get the selected end date for user’s plan.
    func datePickerText(date: Int,dateStr:String) {
        dateDiff = date
        datePickerDate = dateStr
        isDateChanged = true
        tblView.reloadData()
    }
    
    //This method navigates user to the cancelling saving plan.
    func cancelSavingButtonPressed(sender:UIButton)
    {
        let obj  = SACancelSavingViewController()
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    //Clear all the data entered
    func clearButtonPressed()
    {
        let alert = UIAlertController(title: "Are you sure?", message: "This will clear the information entered and start again.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default)
        { action -> Void in
            
            if(self.isUpdatePlan == false) {
                self.setUpView()
                //                self.dateDiff = 0
                self.cost = 0
                self.isPopoverValueChanged = false
                self.itemTitle = ""
                self.isClearPressed = true
                self.dateString = kDate
                self.popOverSelectedStr = "1"
                self.isCostChanged = false
                self.datePickerDate = ""
                if(self.itemDetailsDataDict.keys.count > 0) {
                    self.itemDetailsDataDict.removeAll()
                }
                
                self.tblViewHt.constant = 450.0//self.tblViewHt.constant - CGFloat(self.offerArr.count * 80)
                if self.offerArr.count>0 {
                    self.offerArr.removeAll()
                }
                self.tblView.reloadData()
                self.scrlView.contentOffset = CGPointMake(0, 20)
                //                let ht = self.upperView.frame.size.height + self.tblView.frame.size.height
                //                self.scrlView.contentSize = CGSizeMake(0, ht)
                self.scrlView.contentSize = CGSizeMake(0, self.tblView.frame.origin.y + self.tblViewHt.constant)
            }
            else {
                self.isDateChanged = false
                self.isOfferDetailPressed = false
                self.isCostChanged = false
                self.isClearPressed = true
                self.isPopoverValueChanged = false
                self.setUpView()
                
                let count = self.offerArr.count - self.updateOfferArr.count as Int
                if(count > 0) {
                    self.tblViewHt.constant = self.tblViewHt.constant - CGFloat(count * 120)
                    self.offerArr.removeAll()
                    self.offerArr = self.updateOfferArr
                }
                self.tblView.reloadData()
                self.scrlView.contentOffset = CGPointMake(0, 20)
                //                self.scrlView.contentSize = CGSizeMake(0, self.tblView.frame.origin.y + self.tblViewHt.constant)
            }
            
            //            let ht = self.upperView.frame.size.height + self.tblView.frame.size.height
            //            self.scrlView.contentSize = CGSizeMake(0, ht)
            //            self.scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, self.tblView.frame.origin.y + self.tblView.frame.size.height)
            
            
            })
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Create Dictionary for creating saving plan
    func getParameters() -> Dictionary<String,AnyObject>
    {
        var parameterDict : Dictionary<String,AnyObject> = [:]
        if(itemDetailsDataDict[kTITLE] != nil) {
            parameterDict[kTITLE] = itemDetailsDataDict[kTitle]
        }
        else {
            parameterDict[kTITLE] = itemTitle
        }
        
        if(itemDetailsDataDict[kAmount] != nil) {
            if(itemDetailsDataDict[kAmount] is String) {
                parameterDict[kAMOUNT] = itemDetailsDataDict[kAmount]
            }
            else  {
                parameterDict[kAMOUNT]  = String(format: "%d", (itemDetailsDataDict[kAmount] as! NSNumber).intValue)
            }
        }
        else {
            
            parameterDict[kAMOUNT] = String(format:"%d",cost)
        }
        
        if let image = itemDetailsDataDict[kImageURL] as? String {
            if(image != "") {
                if (topBackgroundImageView.image != nil) {
                    let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                    let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                    let newDict = ["imageName.jpg":base64String]
                    parameterDict[kIMAGE] = newDict
                }
                else {
                    let newDict = ["imageName.jpg":""]
                    parameterDict[kIMAGE] = newDict
                }
            }
        }
        else if let image = itemDetailsDataDict["image"] as? String {
            if(image != "") {
                if (topBackgroundImageView.image != nil) {
                    let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                    let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                    let newDict = ["imageName.jpg":base64String]
                    
                    parameterDict[kIMAGE] = newDict
                }
                else {
                    let newDict = ["imageName.jpg":""]
                    parameterDict[kIMAGE] = newDict
                }
            }
        }
        else  if(isImageClicked) {
            let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
            let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            let newDict = ["imageName.jpg":base64String]
            
            parameterDict[kIMAGE] = newDict
        }
        else {
            let newDict = ["imageName.jpg":""]
            parameterDict[kIMAGE] = newDict
        }
        
        if(datePickerDate != "") {
            let dateParameter = NSDateFormatter()
            dateParameter.dateFormat = "yyyy-MM-dd"
            var pathComponents : NSArray!
            
            pathComponents = (datePickerDate).componentsSeparatedByString(" ")
            var dateStr = pathComponents.lastObject as! String
            
            dateStr = dateStr.stringByReplacingOccurrencesOfString("/", withString: "-")
            
            var pathComponents2 : NSArray!
            pathComponents2 = dateStr.componentsSeparatedByString("-")
            
            parameterDict[kPLANENDDATE] = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String);
        }
        
        parameterDict["WISHLIST_ID"] = itemDetailsDataDict["id"]
        parameterDict[kPARTYID] = userInfoDict[kPartyID]
        if(dateString == kDate) {
            parameterDict[kPAYTYPE] = kMonth
        }
        else {
            parameterDict[kPAYTYPE] = kWeek
        }
        parameterDict[kPAYDATE] = popOverSelectedStr
        
        if((imageDataDict["savPlanID"]) != nil) {
            parameterDict[kSAVPLANID] = imageDataDict["savPlanID"]
        }
        else {
            parameterDict[kSAVPLANID] = itemDetailsDataDict["sav-id"]
        }
        
        var newOfferArray : Array<NSNumber> = []
        var emptyarray : Array<NSNumber> = []
        
        if offerArr.count>0 {
            
            for i in 0 ..< offerArr.count
            {
                let dict = offerArr[i]
                newOfferArray.append(dict["offId"] as! NSNumber)
            }
            parameterDict[kOFFERS] = newOfferArray
        }
        else {
            parameterDict[kOFFERS] = newOfferArray
        }
        
        parameterDict[kPARTYSAVINGPLANTYPE] = "Individual"
        parameterDict["STATUS"] = "Active"
        print("recurring = \(recurringAmount)")
        parameterDict[kRECURRINGAMOUNT] = String(format: "%.f", recurringAmount)
        return parameterDict
        
    }
    
    
    
    //This method is used to send the users saving plan details to the server.
    func nextButtonPressed(sender:UIButton)
    {
        var dict : Dictionary<String,String> = [:]
        dict[kTitle] = itemTitle
        dict["cost"] = String(format:"%d",cost)
        dict["dateDiff"] = String(format:"%d",dateDiff)
        dict["datePickerDate"] = datePickerDate
        
        //Check if offers are already added or not
        if isOfferShow == false {
            //if yes create the saving plan
            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            self.objAnimView.frame = (self.navigationController?.view.frame)! //self.view.frame
            self.objAnimView.animate()
            self.navigationController?.view.addSubview(self.objAnimView)
            if(itemTitle != "" && self.getParameters()[kAMOUNT] != nil && cost != 0 && dateDiff != 0 && datePickerDate != ""  && popOverSelectedStr != "") {
                let objAPI = API()
                if(itemDetailsDataDict[kTitle] == nil) {
                    objAPI.partySavingPlanDelegate = self
                    /*
                     Stripe SDK
                     
                     */
                    
                    print("!!!!!!!!!!!!!!!!!!Stripe SDK!!!!!!!!!!!!!!!!!!!!!")
                    
                    objAPI.createPartySavingPlan(self.getParameters(),isFromWishList: "notFromWishList")
                }
                else if(isUpdatePlan) {
                    //Update the current plan
                    objAPI.updateSavingPlanDelegate = self
                    var newDict : Dictionary<String,AnyObject> = [:]
                    let dateParameter = NSDateFormatter()
                    dateParameter.dateFormat = "dd-MM-yyyy"
                    var pathComponents : NSArray!
                    pathComponents = (datePickerDate).componentsSeparatedByString(" ")
                    var dateStr = pathComponents.lastObject as! String
                    dateStr = dateStr.stringByReplacingOccurrencesOfString("/", withString: "-")
                    var pathComponents2 : NSArray!
                    pathComponents2 = dateStr.componentsSeparatedByString("-")
                    if((pathComponents2[0] as! String).characters.count == 4) {
                        newDict[kPLANENDDATE] = String(format: "%@-%@-%@",pathComponents2[0] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String);
                    }
                    else {
                        newDict[kPLANENDDATE] = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String);
                    }
                    newDict["WISHLIST_ID"] = ""
                    newDict[kSAVPLANID] = self.getParameters()[kSAVPLANID]
                    newDict[kPAYTYPE] = self.getParameters()[kPAYTYPE]
                    if(newDict[kPAYTYPE] as! String == kMonth) {
                        dateString = kDate
                    }
                    else {
                        dateString = kDay
                    }
                    newDict[kPAYDATE] = self.getParameters()[kPAYDATE]
                    newDict[kTITLE] = itemTitle
                    newDict[kAMOUNT] = cost
                    if(topBackgroundImageView.image != nil && topBackgroundImageView.image != self.setTopImageAsPer(imageDataDict)) {
                        let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                        let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                        
                        let dict = ["imageName.jpg":base64String]
                        newDict[kIMAGE] = dict
                    }
                    else {
                        let dict = ["imageName.jpg":""]
                        newDict[kIMAGE] = dict
                    }
                    newDict[kPARTYSAVINGPLANTYPE] = self.getParameters()[kPARTYSAVINGPLANTYPE]
                    
                    newDict[kPARTYID] = self.getParameters()[kPARTYID]
                    newDict[kOFFERS] = self.getParameters()[kOFFERS]
                    newDict["PARTY_SAVINGPLAN_ID"] = itemDetailsDataDict["partySavingPlanID"]
                    newDict["STATUS"] = "Active"
                    print(recurringAmount)
                    newDict[kRECURRINGAMOUNT] = String(format: "%.f", recurringAmount)
                    print(newDict)
                    objAPI.updateSavingPlan(newDict)
                }
                else  {
                    //Create saving plan from wishlist
                    objAPI.partySavingPlanDelegate = self
                    var newDict : Dictionary<String,AnyObject> = [:]
                    newDict[kTITLE] = self.getParameters()[kTITLE]
                    newDict["WISHLIST_ID"] = self.getParameters()["WISHLIST_ID"]
                    newDict[kPAYTYPE] = self.getParameters()[kPAYTYPE]
                    newDict[kPAYDATE] = self.getParameters()[kPAYDATE]
                    newDict[kOFFERS] = self.getParameters()[kOFFERS]
                    newDict[kPARTYID] = userInfoDict[kPartyID]
                    newDict[kSAVPLANID] = "0"
                    print(itemDetailsDataDict)
                    if itemDetailsDataDict["wishsiteURL"] is NSNull {
                        newDict[kSAVSITEURL] = ""
                    }
                    else{
                        newDict[kSAVSITEURL] = itemDetailsDataDict["wishsiteURL"]
                    }
                    
                    if (topBackgroundImageView.image != nil) {
                        let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                        let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                        let dict = ["imageName.jpg":base64String]
                        newDict[kIMAGE] = dict
                    }
                    else {
                        let dict = ["imageName.jpg":""]
                        newDict[kIMAGE] = dict
                    }
                    newDict[kAMOUNT] = self.getParameters()[kAMOUNT]
                    newDict[kPLANENDDATE] = self.getParameters()[kPLANENDDATE]
                    newDict[kPARTYSAVINGPLANTYPE] = self.getParameters()[kPARTYSAVINGPLANTYPE]
                    newDict["STATUS"] = "Active"
                    print(recurringAmount)
                    newDict[kRECURRINGAMOUNT] = String(format: "%.f", recurringAmount)
                    print(newDict)
                    objAPI .createPartySavingPlan(newDict,isFromWishList: "FromWishList")
                }
            }
            else {
                //Handle the warnigs of required fields
                var message = ""
                self.objAnimView.removeFromSuperview()
                if(itemTitle == "")  {
                    message = "Please enter title."
                }
                else if(cost == 0)  {
                    message = "Please enter amount."
                }
                else if(dateDiff == 0 ) {
                    message = "Please select date."
                }
                else if(datePickerDate == "") {
                    message = "Please choose the plan duration end date."
                }
                else if(popOverSelectedStr == "") {
                    message = "Please select payment date/day."
                }
                
                self.displayAlert(message)
            }
        }
        else {
            //Else go to SAOfferListViewController
            let obj = SAOfferListViewController()
            obj.isComingProgress = false
            obj.addedOfferArr = offerArr
            if(isOfferDetailPressed) {
                isOfferDetailPressed = false
                tblViewHt.constant = tblView.frame.size.height - (90 + offerDetailHeight)
                scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width,scrlView.contentSize.height - (90 + offerDetailHeight))
            }
            obj.delegate = self
            
            if(isUpdatePlan) {
                obj.savID = 85//itemDetailsDataDict["sav_id"] as! NSNumber
            }
            else {
                if let  str = imageDataDict["savPlanID"] as? NSNumber {
                    obj.savID = str
                }
                else {
                    obj.savID = Int(imageDataDict["savPlanID"] as! String)!
                }
            }
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    // Stripe SDK Intagration
    func StripeSDK() {
        
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        // STPAddCardViewController must be shown inside a UINavigationController.
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func addCardViewControllerDidCancel(addCardViewController: STPAddCardViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addCardViewController(addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: STPErrorBlock) {
        
        tokenstripeID = token.stripeID
        let objAPI = API()
        let userInfoDict = NSUserDefaults.standardUserDefaults().objectForKey(kUserInfo) as! Dictionary<String,AnyObject>
        let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict[kPartyID] as! NSNumber,"STRIPE_TOKEN":(token.stripeID),kPTYSAVINGPLANID:NSUserDefaults.standardUserDefaults().valueForKey(kPTYSAVINGPLANID) as! NSNumber]
        print(dict)
        objAPI.addSavingCardDelegate = self
        objAPI.addSavingCard(dict)
    
        //Use token for backend process
        self.dismissViewControllerAnimated(true, completion: {
            completion(nil)
        })
        
        NSUserDefaults.standardUserDefaults().setObject(1, forKey: "saveCardArray")
        
        print("+++++++++++++++++++++++++++++++")
    }
    
    
    //This method is used to show the customized alert message to user
    func displayAlert(message:String)
    {
        //Show of UIAlertView
        let alert = UIAlertView(title: "Missing information", message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    //Delete the offer from added offers
    func closeOfferButtonPressed(sender:UIButton)
    {
        let indx = sender.tag - 5
        
        if(isUpdatePlan) {
            if(isOfferDetailPressed) {
                if(indx != offerDetailTag - 5) {
                    let dict = offerArr[offerDetailTag - 5]
                    
                    offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: kLightFont, size: 13)!, width: UIScreen.mainScreen().bounds.width - 70)
                    tblViewHt.constant =  tblView.frame.size.height - 120 - offerDetailHeight
                }
                else {
                    let dict = offerArr[sender.tag - 5]
                    
                    offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: kLightFont, size: 13)!, width: UIScreen.mainScreen().bounds.width - 70)
                    tblViewHt.constant =  tblView.frame.size.height - 120 - offerDetailHeight
                }
            }
            else {
                tblViewHt.constant =  tblView.frame.size.height - 90
            }
            isOfferDetailPressed = false
        }
        else {
            tblViewHt.constant =  tblView.frame.size.height - 80
        }
        offerArr.removeAtIndex(indx)
        
        tblView.reloadData()
        scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblViewHt.constant )
        
        tblView.reloadData()
        scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblViewHt.constant )
    }
    
    //This method is used to get the selected/entered amount by user.
    func txtFieldCellText(txtFldCell: SavingPlanCostTableViewCell) {
        cost = Int(txtFldCell.slider.value)
        if(isUpdatePlan) {
            isDateChanged = true
        }
        else {
            isPopoverValueChanged = true
        }
        if(isCostChanged == false)
        {
            tblViewHt.constant = tblView.frame.size.height  + 40
            scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblViewHt.constant)
            
            isCostChanged = true
        }
        tblView.reloadData()
    }
    
    //Add superscript to date text
    private func createXLabelText (index: Int,text:String) -> NSMutableAttributedString {
        let fontNormal:UIFont? = UIFont(name: kMediumFont, size:10)
        let normalscript = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:fontNormal!,NSBaselineOffsetAttributeName:0])
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:5)
        
        switch index {
        case 1:
            let superscript = NSMutableAttributedString(string: "st", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        case 2:
            let superscript = NSMutableAttributedString(string: "nd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        case 3:
            let superscript = NSMutableAttributedString(string: "rd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        case 21:
            let superscript = NSMutableAttributedString(string: "st", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        case 22:
            let superscript = NSMutableAttributedString(string: "nd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        case 23:
            let superscript = NSMutableAttributedString(string: "rd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        default:
            let superscript = NSMutableAttributedString(string: "th", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.appendAttributedString(superscript)
            break
            
        }
        return normalscript
    }
    
    //function checking any key is null and return not null values in dictionary
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
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker .dismissViewControllerAnimated(true, completion: nil)
        //set the selected/captured image to the UIImageview.
        topBackgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        topBackgroundImageView.layer.masksToBounds = true
        topBackgroundImageView?.image = (info[UIImagePickerControllerEditedImage] as? UIImage)
        cameraButton.hidden = true
        isImageClicked = true
        isComingGallary = true
        //        let ht = self.upperView.frame.size.height + self.tblView.frame.size.height + 50
        //        self.scrlView.contentSize = CGSizeMake(0, ht)
    }
    
    //Cancel the image picker action
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: GetUsersSavingplanDelegate methods
    func successResponseForGetUsersPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        var isImgLoad = false
        if let message = objResponse["message"] as? String {
            if(message == "Success") {
                //Create a dictionary to send SASavingSummaryViewController
                
                //Add spinner to the topBackgroundImageView until the image loads
                let spinner =  UIActivityIndicatorView()
                spinner.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, (self.topBackgroundImageView.frame.size.height/2)+20)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
                self.topBackgroundImageView.addSubview(spinner)
                spinner.startAnimating()
                itemDetailsDataDict = objResponse["partySavingPlan"] as! Dictionary<String,AnyObject>
                isPopoverValueChanged = true
                cameraButton.backgroundColor = UIColor.blackColor()
                cameraButton.alpha = 0.5
                cameraButton.layer.cornerRadius = cameraButton.frame.size.width/2
                offerArr = objResponse["offerList"] as! Array<Dictionary<String,AnyObject>>
                cameraButton.setImage(UIImage(named: ""), forState: UIControlState.Normal)
                let underlineAttributedString = NSAttributedString(string: "edit", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,NSForegroundColorAttributeName:UIColor.whiteColor()])
                cameraButton.setAttributedTitle(underlineAttributedString, forState: UIControlState.Normal)
                itemTitle = itemDetailsDataDict[kTitle] as! String
                self.title = "Update plan"
                cost = Int(itemDetailsDataDict[kAmount] as! NSNumber)
                var pathComponents2 : NSArray!
                pathComponents2 = (itemDetailsDataDict["planEndDate"] as! String).componentsSeparatedByString("-")
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.dateFromString(itemDetailsDataDict["planEndDate"] as! String)
                
                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                let goodDate = dateFormatter.stringFromDate(date!)
                print(goodDate)
                
                datePickerDate = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String);
                datePickerDate = goodDate
                popOverSelectedStr = itemDetailsDataDict["payDate"] as! String
                if (!(objResponse["offerList"] is NSNull) && objResponse["offerList"] != nil ){
                    offerArr = objResponse["offerList"] as! Array<Dictionary<String,AnyObject>>
                }
                print(offerArr)
                updateOfferArr = offerArr
                tblView.reloadData()
                
                tblViewHt.constant +=  100 + CGFloat(offerArr.count * 90)//tblView.frame.origin.y + tblView.frame.size.height + CGFloat(offerArr.count * 90)
                //                let ht =  tblView.frame.size.height//tblViewHt.constant//+ 100
                //                let ht = upperView.frame.size.height + tblView.frame.size.height + 100
                //                self.scrlView.contentSize = CGSizeMake(0, ht )
                
                
                
                if !(itemDetailsDataDict["image"] is NSNull) {
                    isImgLoad = true
                    if  let url = NSURL(string:itemDetailsDataDict["image"] as! String) {
                        let request: NSURLRequest = NSURLRequest(URL: url)
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                            if(data?.length > 0) {
                                let image = UIImage(data: data!)
                                dispatch_async(dispatch_get_main_queue(), {
                                    //Remove the spinner after image load
                                    self.topBackgroundImageView.image = image
                                    spinner.stopAnimating()
                                    spinner.hidden = true
                                    self.objAnimView.removeFromSuperview()
                                })
                            }
                            else {
                                //Remove the spinner after image load
                                dispatch_async(dispatch_get_main_queue(), {
                                    spinner.stopAnimating()
                                    spinner.hidden = true
                                    self.objAnimView.removeFromSuperview()
                                })
                            }
                        })
                    }
                }
                else {
                    //Remove the spinner after image load
                    spinner.stopAnimating()
                    spinner.hidden = true
                }
                
                //                if (!(objResponse["offerList"] is NSNull) && objResponse["offerList"] != nil ){
                //                    offerArr = objResponse["offerList"] as! Array<Dictionary<String,AnyObject>>
                //                }
                //                updateOfferArr = offerArr
                //                tblViewHt.constant = tblView.frame.origin.y + tblView.frame.size.height + CGFloat(offerArr.count * 80)
                //                let ht = upperView.frame.size.height + tblViewHt.constant//+ 100
                //                self.scrlView.contentSize = CGSizeMake(0, ht )
            }
            else {
                let alert = UIAlertView(title: "Alert", message:message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
                isUpdatePlan = false
                tblView.reloadData()
            }
        }
        else if let message = objResponse["error"] as? String {
            let alert = UIAlertView(title: "Alert", message: message , delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            isUpdatePlan = false
            tblView.reloadData()
        }
        if isImgLoad == false {
            objAnimView.removeFromSuperview()
        }
    }
    
    func errorResponseForGetUsersPlanAPI(error: String) {
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        objAnimView.removeFromSuperview()
    }
    
    //MARK: PartySavingplan methods
    func successResponseForPartySavingPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        print(objResponse)
        if let message = objResponse["message"] as? String {
            if(message  == "Multiple representations of the same entity") {
                let alert = UIAlertView(title: "Alert", message: "You have already created one saving plan.", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else if(message == "Party Saving Plan is succesfully added") {
                //Create a dictionary to send SASavingSummaryViewController
                var dict :  Dictionary<String,AnyObject> = [:]
                dict[kTitle] = self.getParameters()[kTITLE]
                dict[kAmount] = self.getParameters()[kAMOUNT]
                dict[kPAYDATE] = self.getParameters()[kPAYDATE]
                let newDict = self.getParameters()[kIMAGE]
                dict[kImageURL] = newDict
                dict["id"] = itemDetailsDataDict["id"]
                dict[kDay] = dateString
                let dateParameter = NSDateFormatter()
                dateParameter.dateFormat = "yyyy-MM-dd"
                var pathComponents : NSArray!
                pathComponents = (datePickerDate).componentsSeparatedByString(" ")
                var dateStr = pathComponents.lastObject as! String
                dateStr = dateStr.stringByReplacingOccurrencesOfString("/", withString: "-")
                var pathComponents2 : NSArray!
                pathComponents2 = dateStr.componentsSeparatedByString("-")
                dict[kPLANENDDATE] = String(format: "%@-%@-%@",pathComponents2[0] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String);
                if(dateString == kDay)
                {
                    if(dateDiff > 0 && dateDiff/168 > 0)
                    {
                        //                        if dateDiff/168 > 0 {
                        //                            dict["emi"] = String(format:"%d",cost/(dateDiff/168))
                        //                        }
                        //                        else{
                        //                            dict["emi"] = String(format:"%d",cost)
                        //                        }
                        dict[kEmi] = String(format:"%d",cost/(dateDiff/168))
                    }
                    else {
                        dict[kEmi] = String(format:"%d",cost)
                    }
                    dict["payType"] = "Weekly"
                }
                else {
                    if(dateDiff > 0 && (dateDiff/168)/4 > 0)
                    {
                        //                        let div = (dateDiff/168)/4
                        //                        if div > 0 {
                        //                        dict["emi"] = String(format:"%d",cost/((dateDiff/168)/4))
                        //                        }
                        //                        else{
                        //                            dict["emi"] = String(format:"%d",cost)
                        //                        }
                        dict[kEmi] = String(format:"%d",cost/((dateDiff/168)/4))
                        
                    }
                    else {
                        dict[kEmi] = String(format:"%d",cost)
                    }
                    dict["payType"] = "Monthly"
                }
                
                if offerArr.count>0{
                    dict["offers"] = offerArr
                }
                dict["planType"] = "individual"
                let objAPI = API()
                //                NSUserDefaults.standardUserDefaults().setObject(self.checkNullDataFromDict(dict), forKey: "savingPlanDict")
                objAPI.storeValueInKeychainForKey("savingPlanDict", value: self.checkNullDataFromDict(dict))
                
                NSUserDefaults.standardUserDefaults().setValue(objResponse["partySavingPlanID"] as? NSNumber, forKey: kPTYSAVINGPLANID)
                NSUserDefaults.standardUserDefaults().setValue(kIndividualPlan, forKey: "usersPlan")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //                if let saveCardArray = objAPI.getValueFromKeychainOfKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
                
                if let saveCardArray = NSUserDefaults.standardUserDefaults().objectForKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
                {
                    let objSavedCardView = SASaveCardViewController()
                    objSavedCardView.isFromSavingPlan = true
                    self.navigationController?.pushViewController(objSavedCardView, animated: true)
                    
                }else {
                    //                    let objPaymentView = SAPaymentFlowViewController()
                    //                    self.navigationController?.pushViewController(objPaymentView, animated: true)
                    self.StripeSDK()
                    print("----------------------------")
                }
            }
            else {
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else if let message = objResponse["internalMessage"] as? String {
            let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else if let message = objResponse["error"] as? String {
            let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func errorResponseForPartySavingPlanAPI(error: String) {
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //MARK: update saving plan methods
    func successResponseForUpdateSavingPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if (objResponse["message"] as? String) != nil
        {
            //Create a dictionary to send SASavingSummaryViewController
            var dict :  Dictionary<String,AnyObject> = [:]
            dict[kTitle] = itemTitle
            dict[kAmount] = String(format:"%d",cost)
            dict[kPAYDATE] = self.getParameters()[kPAYDATE]
            let newDict = self.getParameters()[kIMAGE]
            dict[kImageURL] = newDict
            dict["id"] = self.getParameters()["partySavingPlanID"]
            dict[kDay] = dateString
            let dateParameter = NSDateFormatter()
            dateParameter.dateFormat = "yyyy-MM-dd"
            var pathComponents : NSArray!
            pathComponents = (datePickerDate).componentsSeparatedByString(" ")
            var dateStr = pathComponents.lastObject as! String
            dateStr = dateStr.stringByReplacingOccurrencesOfString("/", withString: "-")
            var pathComponents2 : NSArray!
            pathComponents2 = dateStr.componentsSeparatedByString("-")
            dict[kPLANENDDATE] = String(format: "%@-%@-%@",pathComponents2[0] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String);
            if(dateString == kDay) {
                if dateDiff/168 > 0 {
                    dict[kEmi] = String(format:"%d",cost/(dateDiff/168))
                }
                else{
                    dict[kEmi] = String(format:"%d",cost)
                }
                dict["payType"] = "Weekly"
            }
            else {
                
                if ((dateDiff/168)/4) > 0{
                    dict[kEmi] = String(format:"%d",cost/((dateDiff/168)/4))
                }
                else{
                    dict[kEmi] = String(format:"%d",cost)
                }
                dict["payType"] = "Monthly"
            }
            
            if offerArr.count>0 {
                dict["offers"] = offerArr
            }
            dict["planType"] = "individual"
            
            let objAPI = API()
            //            NSUserDefaults.standardUserDefaults().setObject(self.checkNullDataFromDict(dict), forKey: "savingPlanDict")
            //            NSUserDefaults.standardUserDefaults().synchronize()
            objAPI.storeValueInKeychainForKey("savingPlanDict", value: self.checkNullDataFromDict(dict))
            let objSummaryView = SASavingSummaryViewController()
            objSummaryView.itemDataDict =  dict
            objSummaryView.isUpdatePlan = true
            self.navigationController?.pushViewController(objSummaryView, animated: true)
        }
        objAnimView.removeFromSuperview()
    }
    
    func errorResponseForUpdateSavingPlanAPI(error: String) {
        objAnimView.removeFromSuperview()
        self.isPopoverValueChanged = false
        self.isCostChanged = false
        if error == "Network not available" {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //MARK: Offer delegate methods
    func addedOffers(offerForSaveArr:Dictionary<String,AnyObject>) {
        print(offerForSaveArr)
        offerArr.append(offerForSaveArr)
        if(isUpdatePlan) {
            //            tblViewHt.constant = tblView.frame.size.height + 50
            tblViewHt.constant = tblViewHt.constant + 80
            isOfferShow = false
            isComingGallary = false
            //            let ht = upperView.frame.size.height + tblViewHt.constant + 100// tblView.frame.size.height + 100
            //            self.scrlView.contentSize = CGSizeMake(0, ht )
        }
        else {
            tblViewHt.constant = tblView.frame.size.height + 80
            isOfferShow = false
            isComingGallary = false
            let ht = upperView.frame.size.height + tblView.frame.size.height + 100
            self.scrlView.contentSize = CGSizeMake(0, ht )
        }        
        tblView.reloadData()
        
    }
    
    func skipOffers(){
        isOfferShow = false
        
    }
    
    
    // MARK: - API Response
    //Success response of AddSavingCardDelegate
    func successResponseForAddSavingCardDelegateAPI(objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String{
            if(message == "Successful")
            {
                if(objResponse["stripeCustomerStatusMessage"] as? String == "Customer Card detail Added Succeesfully")
                {
                    NSUserDefaults.standardUserDefaults().setObject(1, forKey: "saveCardArray")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    objAnimView.removeFromSuperview()
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
                        objAnimView.removeFromSuperview()
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
    
    
    
}
