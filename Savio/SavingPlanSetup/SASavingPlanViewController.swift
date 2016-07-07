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
    var userInfoDict  = Dictionary<String,AnyObject>()
    var  objAnimView = ImageViewAnimation()
    var isPopoverValueChanged = false
    var isClearPressed = false
    var isUpdatePlan = false
    
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var scrlView: UIScrollView!
    var isOfferShow: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offerArr.removeAll()
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
        
        self.setUpView()
        if(self.isUpdatePlan)
        {
            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            
            objAPI.getUsersSavingPlan()
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
        
        scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblView.frame.size.height + ht)
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
        
        if(itemDetailsDataDict["imageURL"] != nil)
        {
            let data :NSData = NSData(base64EncodedString: itemDetailsDataDict["imageURL"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
            
            topBackgroundImageView.image = UIImage(data: data)
            cameraButton.hidden = true
            itemTitle = (itemDetailsDataDict["title"] as? String)!
            cost = Int(itemDetailsDataDict["amount"] as! NSNumber)
            
        }
        else
        {
            imageDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
            if(imageDataDict["title"] as! String == "Group Save")
            {
                topBackgroundImageView.image = UIImage(named: "groupsave-setup-bg.png")
            }
            else if(imageDataDict["title"] as! String == "Wedding")
            {
                topBackgroundImageView.image = UIImage(named: "wdding-setup-bg.png")
            }
            else if(imageDataDict["title"] as! String == "Baby")
            {
                topBackgroundImageView.image = UIImage(named: "baby-setup-bg.png")
            }
            else if(imageDataDict["title"] as! String == "Holiday")
            {
                topBackgroundImageView.image = UIImage(named: "holiday-setup-bg.png")
            }
            else if(imageDataDict["title"] as! String == "Ride")
            {
                topBackgroundImageView.image = UIImage(named: "ride-setup-bg.png")
            }
            else if(imageDataDict["title"] as! String == "Home")
            {
                topBackgroundImageView.image = UIImage(named: "home-setup-bg.png")
            }
            else if(imageDataDict["title"] as! String == "Gadget")
            {
                topBackgroundImageView.image = UIImage(named: "gadget-setup-bg.png")
            }
            else
            {
                topBackgroundImageView.image = UIImage(named: "generic-setup-bg.png")
            }
            self.cameraButton.hidden = false
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
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    
    func setUpColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        imageDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        print(imageDataDict)
        if(imageDataDict["title"] as! String == "Group Save")
        {
            red = 161/255
            green = 214/255
            blue = 248/255
            
        }
        else if(imageDataDict["title"] as! String == "Wedding")
        {
            red = 189/255
            green = 184/255
            blue = 235/255
        }
        else if(imageDataDict["title"] as! String == "Baby")
        {
            red = 122/255
            green = 223/255
            blue = 172/255
        }
        else if(imageDataDict["title"] as! String == "Holiday")
        {
            red = 109/255
            green = 214/255
            blue = 200/255
        }
        else if(imageDataDict["title"] as! String == "Ride")
        {
            red = 242/255
            green = 104/255
            blue = 107/255
        }
        else if(imageDataDict["title"] as! String == "Home")
        {
            red = 244/255
            green = 161/255
            blue = 111/255
        }
        else if(imageDataDict["title"] as! String == "Gadget")
        {
            red = 205/255
            green = 220/255
            blue = 57/255
        }
        else
        {
            red = 244/255
            green = 176/255
            blue = 58/255
        }
        return UIColor(red:red as CGFloat, green: green as CGFloat, blue: blue as CGFloat, alpha: 1)
    }
    

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
        
        if(indexPath.section == 0)
        {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanTitleIdentifier", forIndexPath: indexPath) as! SavingPlanTitleTableViewCell
            cell1.tblView = tblView
            cell1.view = self.view
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
            
            cell1.titleTextField.textColor = self.setUpColor()
            return cell1
            
        }
        else if(indexPath.section == 1){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanCostIdentifier", forIndexPath: indexPath) as! SavingPlanCostTableViewCell
            cell1.tblView = tblView
            cell1.delegate = self
            cell1.view = self.view
            if(itemDetailsDataDict["amount"] != nil)
            {
                
                cell1.costTextField.text = String(format: " %d",cost)
                cell1.costTextField.textColor = UIColor.whiteColor()
                cell1.slider.value = (cell1.costTextField.text! as NSString).floatValue
                cost = Int(cell1.slider.value)
            }
            if(isClearPressed)
            {
                if(isUpdatePlan)
                {
                    if(itemDetailsDataDict["amount"] is String)
                    {
                        cell1.costTextField.text = itemDetailsDataDict["amount"] as? String
                    }
                    else
                    {
                        cell1.costTextField.text = String(format: "%d", (itemDetailsDataDict["amount"] as! NSNumber).intValue)
                    }
                    cell1.costTextField.textColor = UIColor.whiteColor()
                    cell1.slider.value = (cell1.costTextField.text! as NSString).floatValue
                    cost = Int(cell1.slider.value)
                    
                }
                else
                {
                    cell1.costTextField.text = "0"
                    cell1.costTextField.textColor = UIColor.whiteColor()
                    cell1.slider.value = 0
                    cost = 0
                }
                
            }
            return cell1
        }
        else if(indexPath.section == 2){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanDatePickerIdentifier", forIndexPath: indexPath) as! SavingPlanDatePickerTableViewCell
            cell1.tblView = tblView
            cell1.savingPlanDatePickerDelegate = self
            cell1.view = self.view
            
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
            
            
            
            if(isClearPressed)
            {
                if(isUpdatePlan)
                {
                    if(itemDetailsDataDict["planEndDate"] != nil)
                    {
                        cell1.datePickerTextField.text = itemDetailsDataDict["planEndDate"] as? String
                        cell1.datePickerTextField.textColor = UIColor.whiteColor()
                        datePickerDate = (itemDetailsDataDict["planEndDate"] as? String)!
                    }
                }
                else{
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
        else if(indexPath.section == 3){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanSetDateIdentifier", forIndexPath: indexPath) as! SetDayTableViewCell
            cell1.tblView = tblView
            cell1.view = self.view
            cell1.segmentDelegate = self
            
            
            if(isUpdatePlan)
            {
                if let payType = itemDetailsDataDict["payType"] as? NSString
                {
                    if(payType == "Week")
                    {
                        let button = UIButton()
                        button.tag = 0
                        cell1.segmentBar.toggleButton(button)
                    }
                    
                }
                
            }
            
            if(popOverSelectedStr != "")
            {
                cell1.dayDateTextField.text = popOverSelectedStr
            }
            
            if(isClearPressed)
            {
                if(isUpdatePlan)
                {
                    if(isUpdatePlan)
                    {
                        if let payType = itemDetailsDataDict["payType"] as? NSString
                        {
                            if(payType == "Week")
                            {
                                let button = UIButton()
                                button.tag = 0
                                cell1.segmentBar.toggleButton(button)
                            }
                            
                        }
                        if let payDate = itemDetailsDataDict["payDate"] as? String
                        {
                            cell1.dayDateTextField.text = payDate
                            
                        }
                        
                    }
                    
                }
                else
                {
                    cell1.dayDateTextField.text = ""
                }
            }
            
            return cell1
        }
        else if(indexPath.section == 4){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanCalculationIdentifier", forIndexPath: indexPath) as! CalculationTableViewCell
            cell1.tblView = tblView
            if(isPopoverValueChanged)
            {
                if(dateString == "day")
                {
                    if((dateDiff/168) == 1)
                    {
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per week for %d week",cost/(dateDiff/168),(dateDiff/168))
                    }
                    else if ((dateDiff/168) == 0)
                    {
                        cell1.calculationLabel.text = "You will need to save £0 per week for 0 week"
                    }
                    else
                    {
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per week for %d weeks",cost/(dateDiff/168),(dateDiff/168))
                    }
                    
                }
                else{
                    if((dateDiff/168)/4 == 1)
                    {
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per month for %d month",(cost/((dateDiff/168)/4)),(dateDiff/168)/4)
                    }
                    else if ((dateDiff/168)/4 == 0)
                    {
                        cell1.calculationLabel.text = "You will need to save £0 per month for 0 month"
                    }
                    else{
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per month for %d months",(cost/((dateDiff/168)/4)),(dateDiff/168)/4)
                    }
                }
            }
            
            if(isUpdatePlan)
            {
                if let payType = itemDetailsDataDict["payType"] as? NSString
                {
                    let date  = itemDetailsDataDict["planEndDate"] as? String
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let timeDifference : NSTimeInterval = dateFormatter.dateFromString(date!)!.timeIntervalSinceDate(NSDate())
                    
                    dateDiff = Int(timeDifference/3600)
                    
                    
                    if(payType == "Month")
                    {
                        if((dateDiff/168) == 1)
                        {
                            cell1.calculationLabel.text = String(format: "You will need to save £%d per month for %d month",(cost/((dateDiff/168)/4)),(dateDiff/168)/4)
                        }
                        else
                        {
                            cell1.calculationLabel.text = String(format: "You will need to save £%d per month for %d month",(cost/((dateDiff/168)/4)),(dateDiff/168)/4)
                        }
                        
                    }
                    else
                    {
                        if((dateDiff/168)/4 == 1)
                        {
                            cell1.calculationLabel.text = String(format: "You will need to save £%d per week for %d week",cost/(dateDiff/168),(dateDiff/168))
                        }
                        else
                        {
                            cell1.calculationLabel.text = String(format: "You will need to save £%d per week for %d weeks",cost/(dateDiff/168),(dateDiff/168))
                        }
                        
                        
                    }
                    
                }
                
                
            }
            return cell1
        }
        else if(indexPath.section == offerArr.count+5)
        {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("NextButtonCellIdentifier", forIndexPath: indexPath) as! NextButtonTableViewCell
            cell1.tblView = tblView
            cell1.nextButton.addTarget(self, action: Selector("nextButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else if(indexPath.section == offerArr.count+6)
        {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("ClearButtonIdentifier", forIndexPath: indexPath) as! ClearButtonTableViewCell
            cell1.tblView = tblView
            cell1.clearButton.addTarget(self, action: Selector("clearButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else if(indexPath.section == offerArr.count+7)
        {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("CancelSavingPlanIdentifier", forIndexPath: indexPath) as! CancelButtonTableViewCell
            cell1.cancelSavingPlanButton.addTarget(self, action: Selector("cancelSavingButtonPressed:"), forControlEvents: .TouchUpInside)
            return cell1
        }
        else{
            let cell1 = tableView.dequeueReusableCellWithIdentifier("OfferTableViewCellIdentifier", forIndexPath: indexPath) as! OfferTableViewCell
            cell1.tblView = tblView
            cell1.closeButton.tag = indexPath.section
            cell1.closeButton.addTarget(self, action: Selector("closeOfferButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            let dict = offerArr[indexPath.row]
            cell1.offerTitleLabel.text = dict["offCompanyName"] as? String
            cell1.offerDetailLabel.text = dict["offTitle"] as? String
            cell1.descriptionLabel.text = dict["offSummary"] as? String
            
            /*
             let urlStr = dict["offImage"] as! String
             let url = NSURL(string: urlStr)
             
             let request: NSURLRequest = NSURLRequest(URL: url!)
             NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
             let image = UIImage(data: data!)
             
             //                self.imageCache[unwrappedImage] = image
             dispatch_async(dispatch_get_main_queue(), {
             cell1.offerImageView?.image = image
             })
             })
             */
            
            return cell1
        }
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
        else if(indexPath.section == 4)
        {
            if(isPopoverValueChanged == true)
            {
                return 40
            }
            else{
                return 0
            }
        }
        else if(indexPath.section == offerArr.count+5)
        {
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
            return 60
        }
        
    }
    
    
    
    func getTextFieldText(text: String) {
        itemTitle = text
    }
    func getDateTextField(str: String) {
        popOverSelectedStr = str
        isPopoverValueChanged = true
        
        tblViewHt.constant = tblView.frame.size.height + CGFloat(offerArr.count * 65) + 40
        
        tblView.reloadData()
    }
    
    func segmentBarChanged(str: String) {
        if(str == "date")
        {
            dateString = "date"
        }
        else
        {
            dateString = "day"
        }
        isPopoverValueChanged = true
    }
    func datePickerText(date: Int,dateStr:String) {
        print(date)
        dateDiff = date
        datePickerDate = dateStr
    }
    
    func cancelSavingButtonPressed(sender:UIButton)
    {
        let alert = UIAlertView(title: "Alert", message: "Work in progress", delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    func clearButtonPressed()
    {
        
        let alert = UIAlertController(title: "Aru you sure?", message: "Do you want to clear all data", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default)
        { action -> Void in
            
            if(self.isUpdatePlan == false)
            {
                self.setUpView()
                self.dateDiff = 0
                self.cost = 0
                self.isPopoverValueChanged = false
                
                self.itemTitle = ""
                
                self.isClearPressed = true
                self.popOverSelectedStr = ""
                
                if(self.itemDetailsDataDict.keys.count > 0)
                {
                    self.itemDetailsDataDict.removeAll()
                }
                
                if self.offerArr.count>0{
                    self.offerArr.removeAll()
                }
                self.tblViewHt.constant = 400
                self.scrlView.contentOffset = CGPointMake(0, 20)
                self.scrlView.contentSize = CGSizeMake(0, self.tblView.frame.origin.y + self.tblViewHt.constant)
                self.tblView.reloadData()
                
            }
            else
            {
                self.setUpView()
                self.isClearPressed = true
                self.tblViewHt.constant = 560
                self.scrlView.contentOffset = CGPointMake(0, 20)
                self.scrlView.contentSize = CGSizeMake(0, self.tblView.frame.origin.y + self.tblViewHt.constant)
                self.tblView.reloadData()
                
            }
            
            })
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        
    }
    
    func getParameters() -> Dictionary<String,AnyObject>
    {
        var parameterDict : Dictionary<String,AnyObject> = [:]
        
        
        if(itemDetailsDataDict["title"] != nil)
        {
            parameterDict["title"] = itemDetailsDataDict["title"]
        }
        else{
            
            parameterDict["title"] = itemTitle
        }
        
        if(itemDetailsDataDict["amount"] != nil)
        {
            if(itemDetailsDataDict["amount"] is String)
            {
                parameterDict["amount"] = itemDetailsDataDict["amount"]
            }
            else
            {
                parameterDict["amount"]  = String(format: " %d", (itemDetailsDataDict["amount"] as! NSNumber).intValue)
            }
        }
        else{
            
            parameterDict["amount"] = String(format:"%d",cost)
        }
        if(itemDetailsDataDict["imageURL"] != nil)
        {
            parameterDict["imageURL"] = itemDetailsDataDict["imageURL"]
        }
        else{
            if(cameraButton.hidden == true)
            {
                let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                parameterDict["imageURL"] = base64String
            }
            else{
                parameterDict["imageURL"] = ""
            }
        }
        
        if(datePickerDate != "")
        {
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
        
        parameterDict["wishList_ID"] = itemDetailsDataDict["id"]
        
        parameterDict["pty_id"] = userInfoDict["partyId"]
        
        if(dateString == "date")
        {
            parameterDict["payType"] = "Month"
        }
        else
        {
            parameterDict["payType"] = "Week"
        }
        
        
        parameterDict["payDate"] = popOverSelectedStr
        
        if((imageDataDict["savPlanID"]) != nil)
        {
            parameterDict["sav_id"] = imageDataDict["savPlanID"]
        }
        else
        {
            parameterDict["sav_id"] = itemDetailsDataDict["sav-id"]
        }
        
        var newOfferArray : Array<NSNumber> = []
        var emptyarray : Array<NSNumber> = []
        
        if offerArr.count>0{
            
            for i in 0 ..< offerArr.count
            {
                let dict = offerArr[i]
                newOfferArray.append(dict["offId"] as! NSNumber)
            }
            parameterDict["offer_List"] = newOfferArray
        }
        else
        {
            parameterDict["offer_List"] = newOfferArray
        }
        
        parameterDict["INIVITED_USER_LIST"] = emptyarray
        parameterDict["INIVITED_DATE"] = ""
        
        
        return parameterDict
        
    }
    
    func nextButtonPressed(sender:UIButton)
    {
        if isOfferShow == false {
            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            
            
            if(itemTitle != "" && self.getParameters()["amount"] != nil && cost != 0 && dateDiff != 0 && datePickerDate != ""  && isPopoverValueChanged == true)
            {
                let objAPI = API()
                
                if(itemDetailsDataDict["title"] == nil)
                {
                    objAPI.partySavingPlanDelegate = self
                    print(self.getParameters())
                    objAPI .createPartySavingPlan(self.getParameters(),isFromWishList: "notFromWishList")
                    
                }
                else if(isUpdatePlan)
                {
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
                    
                    newDict["PLAN_END_DATE"] = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String);
                    newDict["wishList_ID"] = ""
                    newDict["sav_id"] = self.getParameters()["sav_id"]
                    newDict["payType"] = self.getParameters()["payType"]
                    if(newDict["payType"] as! String == "Month")
                    {
                        dateString = "date"
                    }
                    else
                    {
                        dateString = "day"
                    }
                    newDict["payDate"] = self.getParameters()["payDate"]
                    newDict["title"] = itemTitle
                    newDict["amount"] = cost
                    if(self.getParameters()["imageURL"] != nil)
                    {
                        newDict["imageURL"] = self.getParameters()["imageURL"]
                    }
                    else
                    {
                        
                        newDict["imageURL"] = ""
                    }
                    
                    newDict["user_ID"] = self.getParameters()["pty_id"]
                    newDict["offer_List"] = self.getParameters()["offer_List"]
                    newDict["partySavingPlanID"] = itemDetailsDataDict["partySavingPlanID"]
                    
                    
                    objAPI.updateSavingPlan(newDict)
                    
                }
                else
                {
                    
                    objAPI.partySavingPlanDelegate = self
                    var newDict : Dictionary<String,AnyObject> = [:]
                    newDict["wishList_ID"] = self.getParameters()["wishList_ID"]
                    newDict["sav_id"] = self.getParameters()["sav_id"]
                    newDict["payType"] = self.getParameters()["payType"]
                    newDict["payDate"] = self.getParameters()["payDate"]
                    newDict["user_ID"] = self.getParameters()["pty_id"]
                    newDict["offer_List"] = self.getParameters()["offer_List"]
                    
                    objAPI .createPartySavingPlan(newDict,isFromWishList: "FromWishList")
                    
                    
                }
                
            }
            else
            {
                self.objAnimView.removeFromSuperview()
                
                if(itemTitle == "")
                {
                    self.displayAlert("Please enter title for your saving plan")
                }
                else if(cost == 0)
                {
                    self.displayAlert("Please enter amount for your saving plan")
                }
                else if(dateDiff == 0 )
                {
                    self.displayAlert("Please select date for your saving plan")
                }
                else if(datePickerDate == "")
                {
                    self.displayAlert("Please select monthly/weekly payment date")
                }
                else
                {
                    self.displayAlert("Please enter all details")
                }
            }
        }
        else {
            
            let obj = SAOfferListViewController()
            obj.delegate = self
            if(isUpdatePlan)
            {
                
                obj.savID = itemDetailsDataDict["sav_id"] as! NSNumber
                
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
    }
    
    func displayAlert(message:String)
    {
        let alert = UIAlertView(title: "Warning", message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    func closeOfferButtonPressed(sender:UIButton)
    {
        offerArr.removeAtIndex(0)
        tblViewHt.constant =  tblView.frame.size.height + CGFloat(offerArr.count * 65)
        tblView.reloadData()
    }
    
    
    
    func txtFieldCellText(txtFldCell: SavingPlanCostTableViewCell) {
        cost = Int(txtFldCell.slider.value)
        
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker .dismissViewControllerAnimated(true, completion: nil)
        topBackgroundImageView.contentMode = UIViewContentMode.ScaleAspectFit
        topBackgroundImageView?.image = (info[UIImagePickerControllerEditedImage] as? UIImage)
        cameraButton.hidden = true
        
        if(isUpdatePlan)
        {
            let imageData:NSData = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
            let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            //itemDetailsDataDict["imageURL"] = base64String
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: GetUsersSavingplanDelegate methods
    
    func successResponseForGetUsersPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        
        if let message = objResponse["message"] as? String
        {
            if(message == "SUCCESS")
            {
                itemDetailsDataDict = objResponse["getPartySavingPlan"] as! Dictionary<String,AnyObject>
                isPopoverValueChanged = true
                tblViewHt.constant = tblView.frame.size.height + CGFloat(offerArr.count * 65) + 120
                cameraButton.backgroundColor = UIColor.blackColor()
                cameraButton.alpha = 0.5
                cameraButton.layer.cornerRadius = cameraButton.frame.size.width/2
                
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
                
                let data :NSData = NSData(base64EncodedString: itemDetailsDataDict["imageURL"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                topBackgroundImageView.image = UIImage(data: data)
                
                offerArr = objResponse["offerList"] as! Array<Dictionary<String,AnyObject>>
                tblView.reloadData()
                
            }
            else
            {
                
                let alert = UIAlertView(title: "Alert", message: "Please create saving plan first", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
                
                isUpdatePlan = false
                tblView.reloadData()
            }
        }
        else if let message = objResponse["error"] as? String
        {
            
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
        
        print(objResponse)
        objAnimView.removeFromSuperview()
        
        if let message = objResponse["message"] as? String
        {
            if(message  == "Multiple representations of the same entity")
            {
                let alert = UIAlertView(title: "Alert", message: "You have already created one saving plan.", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else if(message == "Party Saving Plan is succesfully added")
            {
                var dict :  Dictionary<String,AnyObject> = [:]
                dict["title"] = self.getParameters()["title"]
                dict["amount"] = self.getParameters()["amount"]
                dict["payDate"] = self.getParameters()["payDate"]
                dict["imageURL"] = self.getParameters()["imageURL"]
                
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
                    dict["payType"] = self.getParameters()["Weekly"]
                }
                else{
                    dict["emi"] = String(format:"%d",cost/((dateDiff/168)/4))
                    dict["payType"] = self.getParameters()["Monthly"]
                }
                
                if offerArr.count>0{
                    dict["offers"] = offerArr
                }
                
                let objSummaryView = SASavingSummaryViewController()
                objSummaryView.itemDataDict =  dict
                self.navigationController?.pushViewController(objSummaryView, animated: true)
            }
            else
            {
                let alert = UIAlertView(title: "Alert", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else if let message = objResponse["internalMessage"] as? String
        {
            let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else if let message = objResponse["error"] as? String
        {
            let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
        
        
    }
    
    func errorResponseForPartySavingPlanAPI(error: String) {
        print(error)
        objAnimView.removeFromSuperview()
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    //MARK: update saving plan methods
    
    func successResponseForUpdateSavingPlanAPI(objResponse: Dictionary<String, AnyObject>) {
       // print(objResponse)
        
        if let message = objResponse["message"] as? String
        {
            var dict :  Dictionary<String,AnyObject> = [:]
            dict["title"] = itemTitle
            dict["amount"] = String(format:"%d",cost)
            dict["payDate"] = self.getParameters()["payDate"]
            dict["imageURL"] = self.getParameters()["imageURL"]
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
            
            if(dateString == "day")
            {
                dict["emi"] = String(format:"%d",cost/(dateDiff/168))
                dict["payType"] = self.getParameters()["Weekly"]
            }
            else{
                dict["emi"] = String(format:"%d",cost/((dateDiff/168)/4))
                dict["payType"] = self.getParameters()["Monthly"]
                
            }
            
            if offerArr.count>0{
                dict["offers"] = offerArr
            }
            //print(dict)
            
            let objSummaryView = SASavingSummaryViewController()
            objSummaryView.itemDataDict =  dict
            objSummaryView.isUpdatePlan = true
            self.navigationController?.pushViewController(objSummaryView, animated: true)
        }
        
        
        objAnimView.removeFromSuperview()
    }
    
    func errorResponseForUpdateSavingPlanAPI(error: String) {
        print(error)
        objAnimView.removeFromSuperview()
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        
    }
    //MARK: Offer delegate methods
    func addedOffers(offerForSaveArr:Dictionary<String,AnyObject>){
        offerArr.append(offerForSaveArr)
        tblViewHt.constant = tblView.frame.size.height + CGFloat(offerArr.count * 65)
        tblView.reloadData()
        isOfferShow = false
    }
    
    func skipOffers(){
        isOfferShow = false
    }
    
}
