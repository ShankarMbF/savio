//
//  SASavingPlanViewController.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASavingPlanViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate,SavingPlanCostTableViewCellDelegate,SavingPlanDatePickerCellDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PartySavingPlanDelegate,SAOfferListViewDelegate,SavingPlanTitleTableViewCellDelegate,SegmentBarChangeDelegate,GetUsersPlanDelegate,UpdateSavingPlanDelegate {
    @IBOutlet weak var topBackgroundImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    @IBOutlet weak var tblViewHt: NSLayoutConstraint!
    @IBOutlet weak var scrlView: UIScrollView!
    
    var cost : Int = 0
    var dateDiff : Int = 0
    var dateString = "date"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offerArr.removeAll()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "GothamRounded-Medium", size: 16)!]
        if(isUpdatePlan)
        {
            self.title = "Update Saving plan"
        }
        else
        {
            self.title = "Savings plan setup"
        }
        
        let font = UIFont(name: "GothamRounded-Book", size: 15)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font!]
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
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
        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        
        topBackgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        topBackgroundImageView.layer.masksToBounds = true
        
        self.setUpView()
        if(self.isUpdatePlan)
        {
            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            objAPI.getUsersSavingPlan("i")
            objAPI.getSavingPlanDelegate = self
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var ht : CGFloat = 0.0
        if(isPopoverValueChanged)
        {
            ht = 40 + CGFloat(offerArr.count * 65)
        }
        else
        {
            ht = CGFloat(offerArr.count * 65)
        }
        
        if(isUpdatePlan)
        {
            scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblView.frame.size.height)
        }
        else
        {
            scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblView.frame.size.height)
        }
    }
    
    func setUpView(){
        //set Navigation left button
        if (isUpdatePlan) {
            let leftBtnName = UIButton()
            leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
            leftBtnName.frame = CGRectMake(0, 0, 30, 30)
            leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
            let leftBarButton = UIBarButtonItem()
            leftBarButton.customView = leftBtnName
            self.navigationItem.leftBarButtonItem = leftBarButton
            
        } else  {
            
            let leftBtnName = UIButton()
            leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
            leftBtnName.frame = CGRectMake(0, 0, 30, 30)
            leftBtnName.addTarget(self, action: Selector("backButtonClicked"), forControlEvents: .TouchUpInside)
            
            let leftBarButton = UIBarButtonItem()
            leftBarButton.customView = leftBtnName
            self.navigationItem.leftBarButtonItem = leftBarButton
        }
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as! NSData
            let wishListArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>
            btnName.setTitle(String(format:"%d",wishListArray!.count), forState: UIControlState.Normal)
            if(wishListArray?.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else{
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
            }
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        //Set up image
        if(itemDetailsDataDict["imageURL"] != nil && !(itemDetailsDataDict["imageURL"] is NSNull))
        {
            let url = NSURL(string:itemDetailsDataDict["imageURL"] as! String)
            if(url != "")
            {
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
                            spinner.stopAnimating()
                            spinner.hidden = true
                            self.topBackgroundImageView.image = image
                        })
                    }
                    else{
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
            itemTitle = (itemDetailsDataDict["title"] as? String)!
            cost = Int(itemDetailsDataDict["amount"] as! NSNumber)
            isPopoverValueChanged = true
        }
        else
        {
            imageDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
            topBackgroundImageView.image = self.setTopImageAsPer(imageDataDict)
            self.cameraButton.hidden = false
        }
        
        if(isUpdatePlan)
        {
            if(isClearPressed)
            {
                let spinner =  UIActivityIndicatorView()
                spinner.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, (self.topBackgroundImageView.frame.size.height/2)+20)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
                self.topBackgroundImageView.addSubview(spinner)
                spinner.startAnimating()
                
                if !(itemDetailsDataDict["image"] is NSNull) {
                    if  let url = NSURL(string:itemDetailsDataDict["image"] as! String)
                    {
                        
                        let request: NSURLRequest = NSURLRequest(URL: url)
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                            if(data?.length > 0)
                            {
                                let image = UIImage(data: data!)
                                dispatch_async(dispatch_get_main_queue(), {
                                    spinner.stopAnimating()
                                    spinner.hidden = true
                                    self.topBackgroundImageView.image = image
                                })
                            }
                            else
                            {
                                spinner.stopAnimating()
                                spinner.hidden = true
                            }
                        })
                    }
                }
                else {
                    spinner.stopAnimating()
                    spinner.hidden = true
                }
                
            }
            
        }
        
    }
    
    //set top image as per selected category
    func setTopImageAsPer(dict:Dictionary<String,AnyObject>) -> UIImage{
        
        if(imageDataDict["title"] as! String == "Group Save") {
            return UIImage(named: "groupsave-setup-bg.png")!
        }
        else if(imageDataDict["title"] as! String == "Wedding") {
            return UIImage(named: "wdding-setup-bg.png")!
        }
        else if(imageDataDict["title"] as! String == "Baby") {
            return UIImage(named: "baby-setup-bg.png")!
        }
        else if(imageDataDict["title"] as! String == "Holiday") {
            return UIImage(named: "holiday-setup-bg.png")!
        }
        else if(imageDataDict["title"] as! String == "Ride") {
            return UIImage(named: "ride-setup-bg.png")!
        }
        else if(imageDataDict["title"] as! String == "Home") {
            return UIImage(named: "home-setup-bg.png")!
        }
        else if(imageDataDict["title"] as! String == "Gadget") {
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
            let dataSave = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as! NSData
            let wishListArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>
            if wishListArray!.count>0{
                
                let objSAWishListViewController = SAWishListViewController()
                objSAWishListViewController.wishListArray = wishListArray!
                self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
            }
            else{
                let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else{
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func backButtonClicked()
    {
        if isOfferShow == false && offerArr.count > 0 {
            let obj = SAOfferListViewController()
            isOfferDetailPressed = false
            obj.delegate = self
            
            if(isUpdatePlan)
            {
                obj.savID = 63//itemDetailsDataDict["sav_id"] as! NSNumber
            }
            else
            {
                if let  str = imageDataDict["savPlanID"] as? NSNumber{
                    obj.savID = imageDataDict["savPlanID"] as! NSNumber
                }
                else
                {
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
    
    //MARK: UITableviewDelegate methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(isUpdatePlan)
        {
            return offerArr.count+8
        }
        else
        {
            return offerArr.count+7
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        if(indexPath.section == 0) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanTitleIdentifier", forIndexPath: indexPath) as! SavingPlanTitleTableViewCell
            cell1.tblView = tblView
            cell1.view = self.scrlView
            cell1.savingPlanTitleDelegate = self
            if(itemDetailsDataDict["title"] != nil)
            {
                cell1.titleTextField.text = itemTitle
            }
            if(isClearPressed)
            {
                if(isUpdatePlan)
                {
                    cell1.titleTextField.text = itemDetailsDataDict["title"] as? String
                }
                else
                {
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
            if(itemDetailsDataDict["amount"] != nil || isPopoverValueChanged || isOfferShow ) {
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
                        if(itemDetailsDataDict["amount"] is String) {
                            let amountString = "£" + String(itemDetailsDataDict["amount"])
                            cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                            cell1.slider.value = Float(itemDetailsDataDict["amount"] as! String)!
                        }
                        else {
                            let amountString = "£" + String(format: "%d", (itemDetailsDataDict["amount"] as! NSNumber).intValue)
                            cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                            cell1.slider.value = (itemDetailsDataDict["amount"] as! NSNumber).floatValue
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
                let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                let currentDate: NSDate = NSDate()
                let components: NSDateComponents = NSDateComponents()
                components.day = +7
                let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
                let dateComponents = NSDateComponents()
                dateComponents.month = 1
                let calender = NSCalendar.currentCalendar()
                let newDate = calender.dateByAddingComponents(dateComponents, toDate: NSDate(), options:NSCalendarOptions(rawValue: 0))
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                cell1.datePickerTextField.text = dateFormatter.stringFromDate(newDate!)
            }
            else
            {
                cell1.datePickerTextField.text = datePickerDate
                cell1.datePickerTextField.textColor = UIColor.whiteColor()
            }
            
            if(isClearPressed) {
                if(isUpdatePlan) {
                    if(itemDetailsDataDict["planEndDate"] != nil) {
                        cell1.datePickerTextField.text = itemDetailsDataDict["planEndDate"] as? String
                        cell1.datePickerTextField.textColor = UIColor.whiteColor()
                        datePickerDate = (itemDetailsDataDict["planEndDate"] as? String)!
                    }
                }
                else {
                    let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                    let currentDate: NSDate = NSDate()
                    let components: NSDateComponents = NSDateComponents()
                    
                    components.day = +7
                    let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
                    let dateFormatter = NSDateFormatter()
                    
                    dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                    
                    cell1.datePickerTextField.text = dateFormatter.stringFromDate(minDate)
                }
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
                        if(payType == "Week") {
                            let button = UIButton()
                            button.tag = 0
                            cell1.segmentBar.toggleButton(button)
                            payTypeStr = "day"
                            popOverSelectedStr =  itemDetailsDataDict["payDate"] as! String
                            dateFromUpdatePlan = popOverSelectedStr
                        }
                        else {
                            dateFromUpdatePlan = popOverSelectedStr
                            payTypeStr = "date"
                        }
                    }
                }
                
                if(popOverSelectedStr != "") {
                    if(dateString == "day") {
                        cell1.dayDateTextField.text = self.popOverSelectedStr
                    }
                    else{
                        cell1.dayDateTextField.attributedText = self.createXLabelText(Int(self.popOverSelectedStr)!, text: self.popOverSelectedStr)
                    }
                }
                else {
                    cell1.dayDateTextField.text = ""
                }
            }
            
            if(isClearPressed)  {
                if(isUpdatePlan) {
                    if let payType = itemDetailsDataDict["payType"] as? NSString {
                        if(payType == "Week") {
                            let button = UIButton()
                            button.tag = 0
                            cell1.segmentBar.toggleButton(button)
                        }
                    }
                    if let payDate = itemDetailsDataDict["payDate"] as? String {
                        if(dateString == "day") {
                            cell1.dayDateTextField.text = payDate
                        }
                        else{
                            cell1.dayDateTextField.attributedText = self.createXLabelText(Int(payDate)!, text: payDate)
                        }

                    }
                }
                else {
                    cell1.dayDateTextField.text = ""
                }
            }
            
            return cell1
        }
        else if(indexPath.section == 4) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanCalculationIdentifier", forIndexPath: indexPath) as! CalculationTableViewCell
            cell1.tblView = tblView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if(isPopoverValueChanged) {
                if(dateString == "day") {
                    if((dateDiff/168) == 1) {
                        cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per week for %d week",round(CGFloat(cost))/CGFloat((dateDiff/168)),(dateDiff/168))
                    }
                    else if ((dateDiff/168) == 0) {
                        
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per week for 1 week",cost)
                    }
                    else {
                        cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per week for %d weeks",round(CGFloat(cost))/CGFloat((dateDiff/168)),(dateDiff/168))
                    }
                    
                }
                else {
                    if((dateDiff/168)/4 == 1) {
                        cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per month for %d month",round((CGFloat(cost))/(CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                    }
                    else if ((dateDiff/168)/4 == 0) {
                        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                        let components: NSDateComponents = NSDateComponents()
                        components.month = +1
                        let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))!
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let timeDifference : NSTimeInterval = minDate.timeIntervalSinceDate(NSDate())
                        
                        dateDiff = Int(timeDifference/3600)
                        
                        cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per month for %d month",round((CGFloat(cost))/(CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                    }
                    else {
                        cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per month for %d months",round((CGFloat(cost))/(CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                    }
                }
            }
            
            if(isUpdatePlan) {
                if(isDateChanged) {
                    if(dateString == "day") {
                        if((dateDiff/168) == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per week for %d week",round(CGFloat(cost)/CGFloat((dateDiff/168))),(dateDiff/168))
                        }
                        else if ((dateDiff/168) == 0) {
                            cell1.calculationLabel.text = "You will need to save £0 per week for 0 week"
                        }
                        else {
                            cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per week for %d weeks",round(CGFloat(cost)/CGFloat((dateDiff/168))),(dateDiff/168))
                        }
                    }
                    else {
                        if((dateDiff/168)/4 == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per month for %d month",round((CGFloat(cost)/(CGFloat((dateDiff/168)/4)))),(dateDiff/168)/4)
                        }
                        else if ((dateDiff/168)/4 == 0) {
                            cell1.calculationLabel.text = "You will need to save £0 per month for 0 month"
                        }
                        else{
                            cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per month for %d months",round((CGFloat(cost)/(CGFloat((dateDiff/168)/4)))),(dateDiff/168)/4)
                        }
                    }
                }
                    
                else
                {
                    if let payType = itemDetailsDataDict["payType"] as? NSString
                    {
                        let date  = itemDetailsDataDict["planEndDate"] as? String
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let timeDifference : NSTimeInterval = dateFormatter.dateFromString(date!)!.timeIntervalSinceDate(NSDate())
                        dateDiff = Int(timeDifference/3600)
                        if(payType == "Month") {
                            if((dateDiff/168) == 1) {
                                cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per month for %d month",round(CGFloat(cost)/(CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                            }
                            else {
                                cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per month for %d month",round(CGFloat(cost)/(CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                            }
                            
                        }
                        else {
                            if((dateDiff/168)/4 == 1) {
                                cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per week for %d week",round(CGFloat(cost)/CGFloat((dateDiff/168))),(dateDiff/168))
                            }
                            else {
                                cell1.calculationLabel.text = String(format: "You will need to save £%0.2f per week for %d weeks",round(CGFloat(cost)/CGFloat((dateDiff/168))),(dateDiff/168))
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
            cell1.nextButton.addTarget(self, action: Selector("nextButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else if(indexPath.section == offerArr.count+6) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("ClearButtonIdentifier", forIndexPath: indexPath) as! ClearButtonTableViewCell
            cell1.tblView = tblView
            cell1.clearButton.addTarget(self, action: Selector("clearButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else if(indexPath.section == offerArr.count+7) {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("CancelSavingPlanIdentifier", forIndexPath: indexPath) as! CancelButtonTableViewCell
            cell1.cancelSavingPlanButton.addTarget(self, action: Selector("cancelSavingButtonPressed:"), forControlEvents: .TouchUpInside)
            return cell1
        }
        else {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("OfferTableViewCellIdentifier", forIndexPath: indexPath) as! OfferTableViewCell
            
            cell1.tblView = tblView
            cell1.closeButton.tag = indexPath.section
            cell1.closeButton.addTarget(self, action: Selector("closeOfferButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
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
                cell1.offerDetailsButton.addTarget(self, action: Selector("offerDetailsButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
                
                if(isClearPressed) {
                    cell1.detailOfferLabel.hidden = true
                }
                else {
                    if(isOfferDetailPressed == true) {
                        if(indexPath.section == offerDetailTag) {
                            offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: "GothamRounded-Light", size: 13)!, width: cell1.detailOfferLabel.frame.width)
                            cell1.detailOfferLabelHeight.constant = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: "GothamRounded-Light", size: 13)!, width: cell1.detailOfferLabel.frame.width)
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
        offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: "GothamRounded-Light", size: 13)!, width: UIScreen.mainScreen().bounds.width - 70)
        isChangeSegment = true
        if(isOfferDetailPressed == true) {
            if(prevOfferDetailTag != sender.tag) {
                let oldDict = offerArr[prevOfferDetailTag - 5]
                let oldOfferDetailHeight = self.heightForView((oldDict["offDesc"] as? String)!, font: UIFont(name: "GothamRounded-Light", size: 13)!, width: UIScreen.mainScreen().bounds.width - 70)
                
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
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view : UIView = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    
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
            else{
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
        
        scrlView.contentSize = CGSizeMake(0, tblViewHt.constant+300)
        tblView.reloadData()
    }
    
    func segmentBarChanged(str: String) {
        
        if(isUpdatePlan) {
            if(str == "date")  {
                dateString = "date"
            }
            else {
                dateString = "day"
            }
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
            if(str == "date") {
                dateString = "date"
            }
            else {
                dateString = "day"
            }
        }
        isChangeSegment = true
        isPopoverValueChanged = true
    }
    
    func datePickerText(date: Int,dateStr:String) {
        dateDiff = date
        datePickerDate = dateStr
        isDateChanged = true
    }
    
    func cancelSavingButtonPressed(sender:UIButton)
    {
        let obj  = SACancelSavingViewController()
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    func clearButtonPressed()
    {
        let alert = UIAlertController(title: "Aru you sure?", message: "Do you want to clear all data", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default)
            { action -> Void in
                
                if(self.isUpdatePlan == false) {
                    self.setUpView()
                    self.dateDiff = 0
                    self.cost = 0
                    self.isPopoverValueChanged = false
                    
                    self.itemTitle = ""
                    
                    self.isClearPressed = true
                    self.popOverSelectedStr = ""
                    
                    if(self.itemDetailsDataDict.keys.count > 0) {
                        self.itemDetailsDataDict.removeAll()
                    }
                    
                    self.tblViewHt.constant = self.tblViewHt.constant - CGFloat(self.offerArr.count * 80)
                    if self.offerArr.count>0 {
                        self.offerArr.removeAll()
                    }
                    self.isCostChanged = false
                    self.scrlView.contentOffset = CGPointMake(0, 20)
                    self.scrlView.contentSize = CGSizeMake(0, self.tblView.frame.origin.y + self.tblViewHt.constant)
                    self.tblView.reloadData()
                }
                else {
                    self.isDateChanged = false
                    self.isOfferDetailPressed = false
                    self.isCostChanged = false
                    self.isClearPressed = true
                    self.setUpView()
                    
                    let count = self.offerArr.count - self.updateOfferArr.count as Int
                    if(count > 0) {
                        self.tblViewHt.constant = self.tblViewHt.constant - CGFloat(count * 120)
                        self.offerArr.removeAll()
                        self.offerArr = self.updateOfferArr
                    }
                    self.scrlView.contentOffset = CGPointMake(0, 20)
                    self.scrlView.contentSize = CGSizeMake(0, self.tblView.frame.origin.y + self.tblViewHt.constant)
                    self.tblView.reloadData()
                    
                }
                
            })
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //create Dictionary for creating saving plan
    func getParameters() -> Dictionary<String,AnyObject>
    {
        var parameterDict : Dictionary<String,AnyObject> = [:]
        if(itemDetailsDataDict["TITLE"] != nil) {
            parameterDict["TITLE"] = itemDetailsDataDict["title"]
        }
        else {
            parameterDict["TITLE"] = itemTitle
        }
        
        if(itemDetailsDataDict["amount"] != nil) {
            if(itemDetailsDataDict["amount"] is String) {
                parameterDict["AMOUNT"] = itemDetailsDataDict["amount"]
            }
            else  {
                parameterDict["AMOUNT"]  = String(format: " %d", (itemDetailsDataDict["amount"] as! NSNumber).intValue)
            }
        }
        else{
            
            parameterDict["AMOUNT"] = String(format:"%d",cost)
        }
        if let image = itemDetailsDataDict["imageURL"] as? String {
            if(image != "") {
                if (topBackgroundImageView.image != nil) {
                    let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                    let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                    let newDict = ["imageName.jpg":base64String]
                    parameterDict["IMAGE"] = newDict
                }
                else {
                    let newDict = ["imageName.jpg":""]
                    parameterDict["IMAGE"] = newDict
                }
            }
        }
        else if let image = itemDetailsDataDict["image"] as? String {
            if(image != "") {
                if (topBackgroundImageView.image != nil) {
                    let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                    let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                    let newDict = ["imageName.jpg":base64String]
                    
                    parameterDict["IMAGE"] = newDict
                }
                else {
                    let newDict = ["imageName.jpg":""]
                    parameterDict["IMAGE"] = newDict
                }
            }
        }
        else  if(isImageClicked) {
            let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
            let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            let newDict = ["imageName.jpg":base64String]
            
            parameterDict["IMAGE"] = newDict
        }
        else {
            let newDict = ["imageName.jpg":""]
            parameterDict["IMAGE"] = newDict
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
            
            parameterDict["PLAN_END_DATE"] = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String);
        }
        
        parameterDict["WISHLIST_ID"] = itemDetailsDataDict["id"]
        
        parameterDict["PARTY_ID"] = userInfoDict["partyId"]
        
        if(dateString == "date") {
            parameterDict["PAY_TYPE"] = "Month"
        }
        else {
            parameterDict["PAY_TYPE"] = "Week"
        }
        parameterDict["PAY_DATE"] = popOverSelectedStr
        
        if((imageDataDict["savPlanID"]) != nil) {
            parameterDict["SAV_PLAN_ID"] = imageDataDict["savPlanID"]
        }
        else {
            parameterDict["SAV_PLAN_ID"] = itemDetailsDataDict["sav-id"]
        }
        
        var newOfferArray : Array<NSNumber> = []
        var emptyarray : Array<NSNumber> = []
        
        if offerArr.count>0 {
            
            for i in 0 ..< offerArr.count
            {
                let dict = offerArr[i]
                newOfferArray.append(dict["offId"] as! NSNumber)
            }
            parameterDict["OFFERS"] = newOfferArray
        }
        else {
            parameterDict["OFFERS"] = newOfferArray
        }
        
        parameterDict["PARTY_SAVINGPLAN_TYPE"] = "Individual"
        parameterDict["STATUS"] = "Active"
        return parameterDict
        
    }
    
    func nextButtonPressed(sender:UIButton)
    {
        var dict : Dictionary<String,String> = [:]
        dict["title"] = itemTitle
        dict["cost"] = String(format:"%d",cost)
        dict["dateDiff"] = String(format:"%d",dateDiff)
        dict["datePickerDate"] = datePickerDate
        
        if isOfferShow == false {
            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.navigationController?.view.addSubview(self.objAnimView)
            if(itemTitle != "" && self.getParameters()["AMOUNT"] != nil && cost != 0 && dateDiff != 0 && datePickerDate != ""  && popOverSelectedStr != "") {
                let objAPI = API()
                if(itemDetailsDataDict["title"] == nil) {
                    objAPI.partySavingPlanDelegate = self
                    objAPI .createPartySavingPlan(self.getParameters(),isFromWishList: "notFromWishList")
                }
                else if(isUpdatePlan) {
                    objAPI.updateSavingPlanDelegate = self
                    var newDict : Dictionary<String,AnyObject> = [:]
                    let dateParameter = NSDateFormatter()
                    dateParameter.dateFormat = "yyyy-MM-dd"
                    var pathComponents : NSArray!
                    pathComponents = (datePickerDate).componentsSeparatedByString(" ")
                    var dateStr = pathComponents.lastObject as! String
                    dateStr = dateStr.stringByReplacingOccurrencesOfString("/", withString: "-")
                    var pathComponents2 : NSArray!
                    pathComponents2 = dateStr.componentsSeparatedByString("-")
                    if((pathComponents2[0] as! String).characters.count == 4) {
                        newDict["PLAN_END_DATE"] = String(format: "%@-%@-%@",pathComponents2[0] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String);
                    }
                    else {
                        newDict["PLAN_END_DATE"] = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String);
                    }
                    newDict["WISHLIST_ID"] = ""
                    newDict["SAV_PLAN_ID"] = self.getParameters()["SAV_PLAN_ID"]
                    newDict["PAY_TYPE"] = self.getParameters()["PAY_TYPE"]
                    if(newDict["PAY_TYPE"] as! String == "Month") {
                        dateString = "date"
                    }
                    else {
                        dateString = "day"
                    }
                    newDict["PAY_DATE"] = self.getParameters()["PAY_DATE"]
                    newDict["TITLE"] = itemTitle
                    newDict["AMOUNT"] = cost
                    if(topBackgroundImageView.image != nil && topBackgroundImageView.image != self.setTopImageAsPer(imageDataDict)) {
                        let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                        let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                        
                        let dict = ["imageName.jpg":base64String]
                        newDict["IMAGE"] = dict
                    }
                    else {
                        let dict = ["imageName.jpg":""]
                        newDict["IMAGE"] = dict
                    }
                    newDict["PARTY_SAVINGPLAN_TYPE"] = self.getParameters()["PARTY_SAVINGPLAN_TYPE"]
                    
                    newDict["PARTY_ID"] = self.getParameters()["PARTY_ID"]
                    newDict["OFFERS"] = self.getParameters()["OFFERS"]
                    newDict["PARTY_SAVINGPLAN_ID"] = itemDetailsDataDict["partySavingPlanID"]
                    newDict["STATUS"] = "Active"
                    objAPI.updateSavingPlan(newDict)
                }
                else  {
                    
                    objAPI.partySavingPlanDelegate = self
                    var newDict : Dictionary<String,AnyObject> = [:]
                    newDict["TITLE"] = self.getParameters()["TITLE"]
                    newDict["WISHLIST_ID"] = self.getParameters()["WISHLIST_ID"]
                    newDict["PAY_TYPE"] = self.getParameters()["PAY_TYPE"]
                    newDict["PAY_DATE"] = self.getParameters()["PAY_DATE"]
                    newDict["OFFERS"] = self.getParameters()["OFFERS"]
                    newDict["PARTY_ID"] = userInfoDict["partyId"]
                    newDict["SAV_PLAN_ID"] = "0"
                    if (topBackgroundImageView.image != nil) {
                        
                        let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                        let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                        let dict = ["imageName.jpg":base64String]
                        
                        newDict["IMAGE"] = dict
                    }
                    else {
                        let dict = ["imageName.jpg":""]
                        newDict["IMAGE"] = dict
                    }
                    newDict["AMOUNT"] = self.getParameters()["AMOUNT"]
                    newDict["PLAN_END_DATE"] = self.getParameters()["PLAN_END_DATE"]
                    newDict["PARTY_SAVINGPLAN_TYPE"] = self.getParameters()["PARTY_SAVINGPLAN_TYPE"]
                    newDict["STATUS"] = "Active"
                    objAPI .createPartySavingPlan(newDict,isFromWishList: "FromWishList")
                }
                
            }
            else {
                var array : Array<String> = []
                self.objAnimView.removeFromSuperview()
                if(itemTitle == "")  {
                    array.append("  Please enter title.")
                }
                if(cost == 0)  {
                    array.append("  Please enter amount.")
                }
                if(dateDiff == 0 ) {
                    array.append("  Please select date.")
                }
                if(datePickerDate == "") {
                    array.append("  Please select monthly/weekly payment date.")
                }
                if(popOverSelectedStr == "") {
                    array.append("  Please select payment date/day.")
                }
                
                self.displayAlert(String(format:"%@",array.joinWithSeparator("\n")))
            }
        }
        else {
            let obj = SAOfferListViewController()
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
                    obj.savID = imageDataDict["savPlanID"] as! NSNumber
                }
                else {
                    obj.savID = Int(imageDataDict["savPlanID"] as! String)!
                }
            }
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    func displayAlert(message:String)
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 10
        paragraphStyle.alignment = NSTextAlignment.Left
        
        let messageText = NSMutableAttributedString(
            string: message,
            attributes: [
                NSParagraphStyleAttributeName: paragraphStyle,
                NSForegroundColorAttributeName : UIColor.blackColor()
            ]
        )
        let alert = UIAlertView(title: "Alert", message: "", delegate: nil, cancelButtonTitle: "Ok")
        let label = UILabel()
        label.sizeToFit()
        label.attributedText = messageText
        label.numberOfLines = 0
        label.textAlignment = .Left
        alert.setValue(label, forKey: "accessoryView")
        alert.show()
    }
    
    func closeOfferButtonPressed(sender:UIButton)
    {
        let indx = sender.tag - 5
        
        if(isUpdatePlan) {
            if(isOfferDetailPressed) {
                if(indx != offerDetailTag - 5) {
                    let dict = offerArr[offerDetailTag - 5]
                    
                    offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: "GothamRounded-Light", size: 13)!, width: UIScreen.mainScreen().bounds.width - 70)
                    tblViewHt.constant =  tblView.frame.size.height - 120 - offerDetailHeight
                }
                else {
                    let dict = offerArr[sender.tag - 5]
                    
                    offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: "GothamRounded-Light", size: 13)!, width: UIScreen.mainScreen().bounds.width - 70)
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
        scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblViewHt.constant )
        tblView.reloadData()
    }
    
    
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
        let fontNormal:UIFont? = UIFont(name: "GothamRounded-Medium", size:10)
        let normalscript = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:fontNormal!,NSBaselineOffsetAttributeName:0])
        let fontSuper:UIFont? = UIFont(name: "GothamRounded-Medium", size:5)
        
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
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker .dismissViewControllerAnimated(true, completion: nil)
        topBackgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        topBackgroundImageView.layer.masksToBounds = true
        topBackgroundImageView?.image = (info[UIImagePickerControllerEditedImage] as? UIImage)
        cameraButton.hidden = true
        isImageClicked = true
        if(isUpdatePlan)
        {
            let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
            let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: GetUsersSavingplanDelegate methods
    
    func successResponseForGetUsersPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        
        if let message = objResponse["message"] as? String {
            if(message == "Success") {
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
                itemTitle = itemDetailsDataDict["title"] as! String
                self.title = "Update Saving plan"
                cost = Int(itemDetailsDataDict["amount"] as! NSNumber)
                var pathComponents2 : NSArray!
                pathComponents2 = (itemDetailsDataDict["planEndDate"] as! String).componentsSeparatedByString("-")
                datePickerDate = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String);
                popOverSelectedStr = itemDetailsDataDict["payDate"] as! String
                if !(itemDetailsDataDict["image"] is NSNull) {
                    if  let url = NSURL(string:itemDetailsDataDict["image"] as! String) {
                        let request: NSURLRequest = NSURLRequest(URL: url)
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                            if(data?.length > 0) {
                                let image = UIImage(data: data!)
                                dispatch_async(dispatch_get_main_queue(), {
                                    spinner.stopAnimating()
                                    spinner.hidden = true
                                    self.topBackgroundImageView.image = image
                                    
                                })
                            }
                            else {
                                spinner.stopAnimating()
                                spinner.hidden = true
                            }
                        })
                        
                        
                    }
                }
                else {
                    spinner.stopAnimating()
                    spinner.hidden = true
                }
                
                if (!(objResponse["offerList"] is NSNull) && objResponse["offerList"] != nil ){
                    offerArr = objResponse["offerList"] as! Array<Dictionary<String,AnyObject>>
                }
                updateOfferArr = offerArr
                tblViewHt.constant = tblView.frame.size.height + CGFloat(offerArr.count * 90) + 120
                tblView.reloadData()
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
        objAnimView.removeFromSuperview()
    }
    
    func errorResponseForGetUsersPlanAPI(error: String) {
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView.removeFromSuperview()
    }
    
    //MARK: PartySavingplan methods
    
    func successResponseForPartySavingPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String {
            if(message  == "Multiple representations of the same entity") {
                let alert = UIAlertView(title: "Alert", message: "You have already created one saving plan.", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else if(message == "Party Saving Plan is succesfully added") {
                
                var dict :  Dictionary<String,AnyObject> = [:]
                dict["title"] = self.getParameters()["TITLE"]
                dict["amount"] = self.getParameters()["AMOUNT"]
                dict["PAY_DATE"] = self.getParameters()["PAY_DATE"]
                let newDict = self.getParameters()["IMAGE"]
                dict["imageURL"] = newDict
                dict["id"] = itemDetailsDataDict["id"]
                dict["day"] = dateString
                let dateParameter = NSDateFormatter()
                dateParameter.dateFormat = "yyyy-MM-dd"
                var pathComponents : NSArray!
                pathComponents = (datePickerDate).componentsSeparatedByString(" ")
                var dateStr = pathComponents.lastObject as! String
                dateStr = dateStr.stringByReplacingOccurrencesOfString("/", withString: "-")
                var pathComponents2 : NSArray!
                pathComponents2 = dateStr.componentsSeparatedByString("-")
                dict["PLAN_END_DATE"] = String(format: "%@-%@-%@",pathComponents2[0] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String);
                if(dateString == "day")
                {
                    dict["emi"] = String(format:"%d",cost/(dateDiff/168))
                    dict["payType"] = "Weekly"
                }
                else{
                    dict["emi"] = String(format:"%d",cost/((dateDiff/168)/4))
                    dict["payType"] = "Monthly"
                }
                
                if offerArr.count>0{
                    dict["offers"] = offerArr
                }
                dict["planType"] = "individual"
                NSUserDefaults.standardUserDefaults().setValue(1, forKey: "individualPlan")
                NSUserDefaults.standardUserDefaults().synchronize()
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
                let objSummaryView = SASavingSummaryViewController()
                objSummaryView.itemDataDict =  dict
                self.navigationController?.pushViewController(objSummaryView, animated: true)
            }
            else {
                let alert = UIAlertView(title: "Alert", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else if let message = objResponse["irnternalMessage"] as? String {
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
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    //MARK: update saving plan methods
    func successResponseForUpdateSavingPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        if let message = objResponse["message"] as? String
        {
            var dict :  Dictionary<String,AnyObject> = [:]
            dict["title"] = itemTitle
            dict["amount"] = String(format:"%d",cost)
            dict["PAY_DATE"] = self.getParameters()["PAY_DATE"]
            let newDict = self.getParameters()["IMAGE"]
            dict["imageURL"] = newDict
            dict["id"] = self.getParameters()["partySavingPlanID"]
            dict["day"] = dateString
            let dateParameter = NSDateFormatter()
            dateParameter.dateFormat = "yyyy-MM-dd"
            var pathComponents : NSArray!
            pathComponents = (datePickerDate).componentsSeparatedByString(" ")
            var dateStr = pathComponents.lastObject as! String
            dateStr = dateStr.stringByReplacingOccurrencesOfString("/", withString: "-")
            var pathComponents2 : NSArray!
            pathComponents2 = dateStr.componentsSeparatedByString("-")
            dict["PLAN_END_DATE"] = String(format: "%@-%@-%@",pathComponents2[0] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String);
            if(dateString == "day") {
                dict["emi"] = String(format:"%d",cost/(dateDiff/168))
                dict["payType"] = "Weekly"
            }
            else {
                dict["emi"] = String(format:"%d",cost/((dateDiff/168)/4))
                dict["payType"] = "Monthly"
            }
            
            if offerArr.count>0 {
                dict["offers"] = offerArr
            }
            dict["planType"] = "individual"
            
            let objSummaryView = SASavingSummaryViewController()
            objSummaryView.itemDataDict =  dict
            objSummaryView.isUpdatePlan = true
            self.navigationController?.pushViewController(objSummaryView, animated: true)
        }
        objAnimView.removeFromSuperview()
    }
    
    func errorResponseForUpdateSavingPlanAPI(error: String) {
        objAnimView.removeFromSuperview()
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        
    }
    
    //MARK: Offer delegate methods
    func addedOffers(offerForSaveArr:Dictionary<String,AnyObject>) {
        offerArr.append(offerForSaveArr)
        if(isUpdatePlan) {
            tblViewHt.constant = tblView.frame.size.height + 120
        }
        else {
            tblViewHt.constant = tblView.frame.size.height + 80
        }
        tblView.reloadData()
        isOfferShow = false
    }
    
    func skipOffers(){
        isOfferShow = false
        
    }
    
}
