//
//  SASavingPlanViewController.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
import Stripe
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


class SASavingPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, SavingPlanCostTableViewCellDelegate, SavingPlanDatePickerCellDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PartySavingPlanDelegate, SAOfferListViewDelegate, SavingPlanTitleTableViewCellDelegate, SegmentBarChangeDelegate, GetUsersPlanDelegate, UpdateSavingPlanDelegate, STPAddCardViewControllerDelegate, AddSavingCardDelegate {
    
    @IBOutlet weak var topBackgroundImageView   : UIImageView!
    @IBOutlet weak var cameraButton             : UIButton!
    @IBOutlet weak var tblView                  : UITableView!
    @IBOutlet weak var savingPlanTitleLabel     : UILabel!
    @IBOutlet weak var tblViewHt                : NSLayoutConstraint!
    @IBOutlet weak var scrlView                 : UIScrollView!
    @IBOutlet weak var upperView                : UIView!
    @IBOutlet weak var segmentBar       : CustomSegmentBar!
    
    var segmentDelegate : SegmentBarChangeDelegate?
    
    var tokenstripeID       : String    = ""
    var datePickerDate      : String    = ""
    var itemTitle           : String    = ""
    var cost                : Int       = 0
    var dateDiff            : Int       = 0
    var recurringAmount     : CGFloat   = 0
    var offerDetailHeight   : CGFloat   = 0.0
    var isOfferShow         : Bool      = true
    var imageDataDict       : Dictionary<String,AnyObject> = [:]
    var itemDetailsDataDict : Dictionary<String,AnyObject> = [:]
    var offerArr            : Array<Dictionary<String,AnyObject>> = []
    var updateOfferArr      : Array<Dictionary<String,AnyObject>> = []
    
    var popOverSelectedStr  = ""
    var payTypeStr          = ""
    var dateFromUpdatePlan  = ""
    var offerDetailTag      = 0
    var prevOfferDetailTag  = 0
    var offerCount          = 0
    var imagePicker         = UIImagePickerController()
    var userInfoDict        = Dictionary<String,AnyObject>()
    var objAnimView         = ImageViewAnimation()
    var dateString          = kDate

    
    var isCostChanged           = false
    var nextButtonTrigger       = false
    var isComingGallary         = false
    var isPopoverValueChanged   = false
    var isClearPressed          = false
    var isUpdatePlan            = false
    var isImageClicked          = false
    var isDateChanged           = false
    var isOfferDetailPressed    = false
    var isChangeSegment         = false
    var isFromGroupMemberPlan   = false
    
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        offerArr.removeAll()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        if(isUpdatePlan)
        {
            self.title = "Update plan"
        }else
        {
            self.title = "Plan setup"
        }
        popOverSelectedStr = "1"
        
        let font = UIFont(name: kBookFont, size: 15)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font!]
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        //Register the UITableViewCell from xib
        tblView!.register(UINib(nibName: "SavingPlanTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanTitleIdentifier")
        tblView!.register(UINib(nibName: "SavingPlanCostTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanCostIdentifier")
        tblView!.register(UINib(nibName: "SavingPlanDatePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanDatePickerIdentifier")
        tblView!.register(UINib(nibName: "SetDayTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanSetDateIdentifier")
        tblView!.register(UINib(nibName: "CalculationTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanCalculationIdentifier")
        
        //OfferTableViewCell
        tblView!.register(UINib(nibName: "OfferTableViewCell", bundle: nil), forCellReuseIdentifier: "OfferTableViewCellIdentifier")
        tblView!.register(UINib(nibName: "NextButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "NextButtonCellIdentifier")
        tblView!.register(UINib(nibName: "ClearButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ClearButtonIdentifier")
        
        //CancelSavingPlanIdentifier
        tblView!.register(UINib(nibName: "CancelButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "CancelSavingPlanIdentifier")
        
        let objAPI = API()
        userInfoDict = .object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        topBackgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        topBackgroundImageView.layer.masksToBounds = true
        
        self.setUpView()
        if(self.isUpdatePlan)
        {
            self.objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            objAPI.getSavingPlanDelegate = self
            objAPI.getUsersSavingPlan("i")
        }
    }
    
    
    //      Set the contentsize of UIScrollView
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        if  isComingGallary == false
        {
            self.scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: tblView.frame.origin.y + tblViewHt.constant )
        }
    }
    
    func setUpView(){
        //  set Navigation left button
        let leftBtnName = UIButton()
        if (isUpdatePlan)
        {
            leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
            leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            leftBtnName.addTarget(self, action: #selector(SASavingPlanViewController.menuButtonClicked), for: .touchUpInside)
        } else
        {
            leftBtnName.setImage(UIImage(named: "nav-back.png"), for: UIControlState())
            leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            leftBtnName.addTarget(self, action: #selector(SASavingPlanViewController.backButtonClicked), for: .touchUpInside)
        }
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
                
        //  set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.addTarget(self, action: #selector(SASavingPlanViewController.heartBtnClicked), for: .touchUpInside)
        if let str = .object(forKey: "wishlistArray") as? Data
        {
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>
            btnName.setTitle(String(format:"%d",wishListArray!.count), for: UIControlState())
            if(wishListArray?.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), for: UIControlState())
                btnName.setTitleColor(UIColor.black, for: UIControlState())
            }
            else
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
            }
        }

        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        //Set up image
        if(itemDetailsDataDict[kImageURL] != nil && !(itemDetailsDataDict[kImageURL] is NSNull))
        {
            let url = URL(string:itemDetailsDataDict[kImageURL] as! String)
            if(url != nil)
            {
                //Add spinner to UIImageView until image loads
                let spinner =  UIActivityIndicatorView()
                spinner.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: topBackgroundImageView.frame.size.height/2)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
                topBackgroundImageView.addSubview(spinner)
                spinner.startAnimating()
                let request: URLRequest = URLRequest(url: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { ( response: URLResponse?,data: Data?,error: NSError?) -> Void in
                    if(data?.count > 0)
                    {
                        let image = UIImage(data: data!)
                        DispatchQueue.main.async(execute: {
                            //Remove the spinner after image load
                            spinner.stopAnimating()
                            spinner.isHidden = true
                            self.topBackgroundImageView.image = image
                        })
                    }
                    else {
                        //Remove the spinner if image is not present
                        spinner.stopAnimating()
                        spinner.isHidden = true
                        self.topBackgroundImageView.image = UIImage(named: "generic-setup-bg.png")
                    }
                } as! (URLResponse?, Data?, Error?) -> Void)
            }
            else
            {
                self.topBackgroundImageView.image = UIImage(named: "generic-setup-bg.png")
            }
            
            cameraButton.isHidden = true
            itemTitle = (itemDetailsDataDict[kTitle] as? String)!
            cost = Int(itemDetailsDataDict[kAmount] as! NSNumber)
            isPopoverValueChanged = true
            isCostChanged = true
            
            imageDataDict =  .object(forKey: "colorDataDict") as! Dictionary<String,AnyObject>
            topBackgroundImageView.image = self.setTopImageAsPer(imageDataDict)
            self.cameraButton.isHidden = false
        }
        else
        {
            imageDataDict =  .object(forKey: "colorDataDict") as! Dictionary<String,AnyObject>
            topBackgroundImageView.image = self.setTopImageAsPer(imageDataDict)
            self.cameraButton.isHidden = false
        }
        
        print("tblHT=\(tblViewHt.constant)")
        if(isUpdatePlan)
        {
            tblViewHt.constant = tblView.frame.size.height + 10// + 250
            if(isClearPressed)
            {
                //Add spinner to UIImageView until image loads
                let spinner =  UIActivityIndicatorView()
                spinner.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: (self.topBackgroundImageView.frame.size.height/2)+20)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
                self.topBackgroundImageView.addSubview(spinner)
                spinner.startAnimating()
                
                if !(itemDetailsDataDict["image"] is NSNull) {
                    if  let url = URL(string:itemDetailsDataDict["image"] as! String)
                    {
                        //load the image from URL
                        let request: URLRequest = URLRequest(url: url)
                        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { ( response: URLResponse?,data: Data?,error: NSError?) -> Void in
                            if(data?.count > 0)
                            {
                                let image = UIImage(data: data!)
                                DispatchQueue.main.async(execute: {
                                    //Remove the spinner after image load
                                    spinner.stopAnimating()
                                    spinner.isHidden = true
                                    self.topBackgroundImageView.image = image
                                })
                            }
                            else
                            {
                                //Remove the spinner after image load
                                spinner.stopAnimating()
                                spinner.isHidden = true
                            }
                        } as! (URLResponse?, Data?, Error?) -> Void)
                    }
                }
                else {
                    //Remove the spinner if image is not there
                    spinner.stopAnimating()
                    spinner.isHidden = true
                }
            }
        }
        else{
            tblViewHt.constant = tblView.frame.size.height  + 40
            
        }
        
        scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: tblView.frame.origin.y + tblViewHt.constant)
    }
    
    //set top image as per selected category
    func setTopImageAsPer(_ dict:Dictionary<String,AnyObject>) -> UIImage{
        
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    
    func heartBtnClicked(){
        if let str = .object(forKey: "wishlistArray") as? Data  {
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>
            if wishListArray!.count>0{
                //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
                NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")            }
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
                    obj.savID = Int(imageDataDict["savPlanID"] as! String)! as NSNumber
                }
            }
            self.navigationController?.pushViewController(obj, animated: true)
            
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //action method of camera button
    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        //show alert view controller to choose option from gallery and camera
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertControllerStyle.actionSheet)
        //alert view controll action method
        alertController.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default)
        { action -> Void in
            
            //Check if camera is available
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.allowsEditing = true
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                //Give alert if camera is not available
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            })
        //alert view controll action method
        alertController.addAction(UIAlertAction(title: "Choose Photo", style: UIAlertActionStyle.default)
        { action -> Void in
            //check if Photolibrary available
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.imagePicker.allowsEditing = true
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                //Give alert if camera is not available
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            
            })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: UITableviewDelegate and UITableviewDataSource methods
    //return the number of sections in table view.
    func numberOfSections(in tableView: UITableView) -> Int {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //create custom cell from their respective Identifiers.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if(indexPath.section == 0) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "SavingPlanTitleIdentifier", for: indexPath) as! SavingPlanTitleTableViewCell
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
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "SavingPlanCostIdentifier", for: indexPath) as! SavingPlanCostTableViewCell
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
                            let amountString = "£" + String(describing: itemDetailsDataDict[kAmount])
                            cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                            cell1.slider.value = Float(itemDetailsDataDict[kAmount] as! String)!
                        }
                        else {
                            let amountString = "£" + String(format: "%d", (itemDetailsDataDict[kAmount] as! NSNumber).int32Value)
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
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "SavingPlanDatePickerIdentifier", for: indexPath) as! SavingPlanDatePickerTableViewCell
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
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                var dateComponents = DateComponents()
                let calender = Calendar.current
                dateComponents.month = 3
                let newDate = (calender as NSCalendar).date(byAdding: dateComponents, to: Date(), options:NSCalendar.Options(rawValue: 0))
                datePickerDate = dateFormatter.string(from: newDate!)
                cell1.datePickerTextField.text = datePickerDate
                let timeDifference : TimeInterval = newDate!.timeIntervalSince(Date())
                dateDiff = Int(timeDifference/3600)
            }
            else
            {
                cell1.datePickerTextField.text = datePickerDate
                cell1.datePickerTextField.textColor = UIColor.white
                print(datePickerDate)
            }
            
            if(isClearPressed) {
                print("Clear in Table Reload")
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
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "SavingPlanSetDateIdentifier", for: indexPath) as! SetDayTableViewCell
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            cell1.tblView = tblView
            cell1.view = self.scrlView
            
            cell1.segmentDelegate = self
            
            if(isUpdatePlan) {
                if(isChangeSegment == false) {
                    if let payType = itemDetailsDataDict["payType"] as? NSString {
                        if(payType as String == kWeek) {
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
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "SavingPlanCalculationIdentifier", for: indexPath) as! CalculationTableViewCell
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
                        recurringAmount = round(CGFloat(cost))
                    }
                    else {
                        cell1.calculationLabel.text = String(format: "You will need to top up £%0.2f per week for %d weeks",round((CGFloat(cost))/CGFloat(dateDiff/168)),(dateDiff/168))
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
                        
                        let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                        let currentDate: Date = Date()
                        let components: DateComponents = DateComponents()
                        //                        components.day = +7
                        let _: Date = (gregorian as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        //                            dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                        
                        let dt = dateFormatter.date(from: date!)!
                        //                        let timeDifference : NSTimeInterval = dateFormatter.dateFromString(date!)!.timeIntervalSinceDate(minDate)
                        let timeDifference : TimeInterval = dt.timeIntervalSince(Date())
                        dateDiff = Int(timeDifference/3600)
                        if(payType as String == kMonth) {
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
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "NextButtonCellIdentifier", for: indexPath) as! NextButtonTableViewCell
            cell1.tblView = tblView
            
            cell1.nextButton.addTarget(self, action: #selector(SASavingPlanViewController.nextButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            return cell1
        }
        else if(indexPath.section == offerArr.count+6) {
            if isUpdatePlan{
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "CancelSavingPlanIdentifier", for: indexPath) as! CancelButtonTableViewCell
                cell1.cancelSavingPlanButton.addTarget(self, action: #selector(SASavingPlanViewController.cancelSavingButtonPressed(_:)), for: .touchUpInside)
                return cell1
            }
            else{
                
                // **************** Clear Button Function Hit ***************** //
                
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "ClearButtonIdentifier", for: indexPath) as! ClearButtonTableViewCell
                cell1.tblView = tblView
                cell1.clearButton.addTarget(self, action: #selector(SASavingPlanViewController.clearButtonPressed), for: UIControlEvents.touchUpInside)
                
                return cell1
            }
        }
        else if(indexPath.section == offerArr.count+7) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "CancelSavingPlanIdentifier", for: indexPath) as! CancelButtonTableViewCell
            cell1.cancelSavingPlanButton.addTarget(self, action: #selector(SASavingPlanViewController.cancelSavingButtonPressed(_:)), for: .touchUpInside)
            return cell1
        }
        else {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "OfferTableViewCellIdentifier", for: indexPath) as! OfferTableViewCell
            
            cell1.tblView = tblView
            cell1.closeButton.tag = indexPath.section
            cell1.closeButton.addTarget(self, action: #selector(SASavingPlanViewController.closeOfferButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            let ind = indexPath.section - 5
            let dict = offerArr[ind]
            cell1.offerTitleLabel.text = dict["offCompanyName"] as? String
            cell1.offerDetailLabel.text = dict["offTitle"] as? String
            cell1.descriptionLabel.text = dict["offSummary"] as? String
            
            if(isUpdatePlan) {
                cell1.offerDetailsButton.isHidden = false
                cell1.offerDetailsButton.tag = indexPath.section
                cell1.offerDetailsButton.setTitle("Offer details", for: UIControlState())
                cell1.offerDetailsButton.titleEdgeInsets = UIEdgeInsetsMake(0, (cell1.offerDetailsButton.imageView?.frame.size.width)!, 0, -(((cell1.offerDetailsButton.imageView?.frame.size.width)!-30)))
                cell1.offerDetailsButton.setImage(UIImage(named:"detail-arrow-down.png"), for: UIControlState())
                cell1.offerDetailsButton.imageEdgeInsets = UIEdgeInsetsMake(0, (cell1.offerDetailsButton.titleLabel?.frame.size.width)!, 0, -(((cell1.offerDetailsButton.titleLabel?.frame.size.width)!+30)))
                cell1.offerDetailsButton.addTarget(self, action: #selector(SASavingPlanViewController.offerDetailsButtonPressed(_:)), for: UIControlEvents.touchUpInside)
                
                if(isClearPressed) {
                    cell1.detailOfferLabel.isHidden = true
                }
                else {
                    if(isOfferDetailPressed == true) {
                        if(indexPath.section == offerDetailTag) {
                            offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: kLightFont, size: 13)!, width: cell1.detailOfferLabel.frame.width)
                            cell1.detailOfferLabelHeight.constant = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: kLightFont, size: 13)!, width: cell1.detailOfferLabel.frame.width)
                            cell1.detailOfferLabel.isHidden = false
                            cell1.detailOfferLabel.text = dict["offDesc"] as? String
                            cell1.offerDetailsButton.setImage(UIImage(named:"detail-arrow-up.png"), for: UIControlState())
                            cell1.offerDetailsButton.imageEdgeInsets = UIEdgeInsetsMake(0, (cell1.offerDetailsButton.titleLabel?.frame.size.width)!, 0,-(((cell1.offerDetailsButton.titleLabel?.frame.size.width)!+30)))
                            
                        }
                        else {
                            cell1.detailOfferLabel.isHidden = true
                        }
                    }
                    else {
                        cell1.detailOfferLabel.isHidden = true
                    }
                }
            }
            let urlStr = dict["offImage"] as! String
            let url = URL(string: urlStr)
            let request: URLRequest = URLRequest(url: url!)
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { ( response: URLResponse?,data: Data?,error: NSError?) -> Void in
                if (data != nil && data?.count > 0) {
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async(execute: {
                        cell1.offerImageView?.image = image
                    })
                }
            } as! (URLResponse?, Data?, Error?) -> Void)
            
            return cell1
        }
    }
    
    
    //Calculate height of offer description text
    func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    //action method of offer details button
    func offerDetailsButtonPressed(_ sender:UIButton)
    {
        let dict = offerArr[sender.tag - 5]
        offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: kLightFont, size: 13)!, width: UIScreen.main.bounds.width - 70)
        isChangeSegment = true
        if(isOfferDetailPressed == true) {
            if(prevOfferDetailTag != sender.tag) {
                let oldDict = offerArr[prevOfferDetailTag - 5]
                let oldOfferDetailHeight = self.heightForView((oldDict["offDesc"] as? String)!, font: UIFont(name:kLightFont, size: 13)!, width: UIScreen.main.bounds.width - 70)
                
                tblViewHt.constant = tblView.frame.size.height - oldOfferDetailHeight +  offerDetailHeight
                offerDetailTag = sender.tag
                prevOfferDetailTag = offerDetailTag
            }
            else {
                isOfferDetailPressed = false
                tblViewHt.constant = tblView.frame.size.height - (90 + offerDetailHeight)
                scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width,height: scrlView.contentSize.height - (90 + offerDetailHeight))
            }
        }
        else {
            isOfferDetailPressed = true
            offerDetailTag = sender.tag
            prevOfferDetailTag = offerDetailTag
            tblViewHt.constant = tblView.frame.size.height +  90 + offerDetailHeight
            scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width,height: scrlView.contentSize.height + 90 + offerDetailHeight)
        }
        self.tblView.reloadData()
    }
    
    //This is UITableViewDelegate method used to set the view for UITableView header.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view : UIView = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    //This is UITableViewDelegate method used to set the height of header.
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    
    //This is UITableViewDelegate method used to set the height of rows per section.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
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
    func getTextFieldText(_ text: String) {
        itemTitle = text
    }
    
    //This is SegmentBarChangeDelegate method used to get the selected date/day for saving plans recurring payment.
    func getDateTextField(_ str: String) {
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
        scrlView.contentSize = CGSize(width: 0, height: tblView.frame.origin.y+tblViewHt.constant)
        tblView.reloadData()
    }
    
    //This is SegmentBarChangeDelegate method used to get the selected date/day for saving plans recurring payment.
    func segmentBarChanged(_ str: String) {
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
    func datePickerText(_ date: Int,dateStr:String) {
        dateDiff = date
        datePickerDate = dateStr
        isDateChanged = true
        tblView.reloadData()
    }
    
    //This method navigates user to the cancelling saving plan.
    func cancelSavingButtonPressed(_ sender:UIButton)
    {
        let obj  = SACancelSavingViewController()
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    //Clear all the data entered
    func clearButtonPressed()
    {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This will clear the information entered and start again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default)
        { action -> Void in
            
            if(self.isUpdatePlan == false) {
                
                self.setUpView()
                                self.dateDiff = 0
                self.cost = 0
                self.isPopoverValueChanged = false
                self.itemTitle = ""
                self.isClearPressed = true
                self.dateString = kDate
                self.segmentDelegate = self
                self.segmentBarChanged(kDate)
                
                let Identifire = self.tblView.dequeueReusableCell(withIdentifier: "SavingPlanSetDateIdentifier") as! SetDayTableViewCell
                Identifire.segmentBar.activebutton()

                self.isChangeSegment = false

                
                
            /*
                let Identifire = self.tblView.dequeueReusableCellWithIdentifier("SavingPlanSetDateIdentifier") as! SetDayTableViewCell
                let button = UIButton()
                button.tag = 1
                let rects : CGRect = CGRect(x: 0, y: 0, width: 105.0, height: 24.0)
                Identifire.drawRect(rects)
                Identifire.segmentBar.toggleButton(button)
            */

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
                self.scrlView.contentOffset = CGPoint(x: 0, y: 20)
                //                let ht = self.upperView.frame.size.height + self.tblView.frame.size.height
                //                self.scrlView.contentSize = CGSizeMake(0, ht)
                self.scrlView.contentSize = CGSize(width: 0, height: self.tblView.frame.origin.y + self.tblViewHt.constant)
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
                self.scrlView.contentOffset = CGPoint(x: 0, y: 20)
                //                self.scrlView.contentSize = CGSizeMake(0, self.tblView.frame.origin.y + self.tblViewHt.constant)
            }
            
            //            let ht = self.upperView.frame.size.height + self.tblView.frame.size.height
            //            self.scrlView.contentSize = CGSizeMake(0, ht)
            //            self.scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, self.tblView.frame.origin.y + self.tblView.frame.size.height)
            
            
            })
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Create Dictionary for creating saving plan
    func getParameters() -> Dictionary<String,AnyObject>
    {
        var parameterDict : Dictionary<String,AnyObject> = [:]
        if(itemDetailsDataDict[kTITLE] != nil) {
            parameterDict[kTITLE] = itemDetailsDataDict[kTitle]
        }
        else {
            parameterDict[kTITLE] = itemTitle as AnyObject
        }
        
        if(itemDetailsDataDict[kAmount] != nil) {
            if(itemDetailsDataDict[kAmount] is String) {
                parameterDict[kAMOUNT] = itemDetailsDataDict[kAmount]
            }
            else  {
                parameterDict[kAMOUNT]  = String(format: "%d", (itemDetailsDataDict[kAmount] as! NSNumber).int32Value) as AnyObject
            }
        }
        else {
            
            parameterDict[kAMOUNT] = String(format:"%d",cost) as AnyObject
        }
        
        if let image = itemDetailsDataDict[kImageURL] as? String {
            if(image != "") {
                if (topBackgroundImageView.image != nil) {
                    let imageData:Data = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                    let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                    let newDict = ["imageName.jpg":base64String]
                    parameterDict[kIMAGE] = newDict as AnyObject
                }
                else {
                    let newDict = ["imageName.jpg":""]
                    parameterDict[kIMAGE] = newDict as AnyObject
                }
            }
        }
        else if let image = itemDetailsDataDict["image"] as? String {
            if(image != "") {
                if (topBackgroundImageView.image != nil) {
                    let imageData:Data = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                    let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                    let newDict = ["imageName.jpg":base64String]
                    
                    parameterDict[kIMAGE] = newDict as AnyObject
                }
                else {
                    let newDict = ["imageName.jpg":""]
                    parameterDict[kIMAGE] = newDict as AnyObject
                }
            }
        }
        else  if(isImageClicked) {
            let imageData:Data = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
            let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let newDict = ["imageName.jpg":base64String]
            
            parameterDict[kIMAGE] = newDict as AnyObject
        }
        else {
            let newDict = ["imageName.jpg":""]
            parameterDict[kIMAGE] = newDict as AnyObject
        }
        
        if(datePickerDate != "") {
            let dateParameter = DateFormatter()
            dateParameter.dateFormat = "yyyy-MM-dd"
            var pathComponents : NSArray!
            
            pathComponents = (datePickerDate).components(separatedBy: " ") as [String] as NSArray
            var dateStr = pathComponents.lastObject as! String
            
            dateStr = dateStr.replacingOccurrences(of: "/", with: "-")
            
            var pathComponents2 : NSArray!
            pathComponents2 = dateStr.components(separatedBy: "-") as [String] as NSArray
            
            parameterDict[kPLANENDDATE] = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String) as AnyObject;
        }
        
        parameterDict["WISHLIST_ID"] = itemDetailsDataDict["id"]
        parameterDict[kPARTYID] = userInfoDict[kPartyID]
        if(dateString == kDate) {
            parameterDict[kPAYTYPE] = kMonth as AnyObject
        }
        else {
            parameterDict[kPAYTYPE] = kWeek as AnyObject
        }
        parameterDict[kPAYDATE] = popOverSelectedStr as AnyObject
        
        if((imageDataDict["savPlanID"]) != nil) {
            parameterDict[kSAVPLANID] = imageDataDict["savPlanID"]
        }
        else {
            parameterDict[kSAVPLANID] = itemDetailsDataDict["sav-id"]
        }
        
        var newOfferArray : Array<NSNumber> = []
        var _ : Array<NSNumber> = []
        
        if offerArr.count>0 {
            
            for i in 0 ..< offerArr.count
            {
                let dict = offerArr[i]
                newOfferArray.append(dict["offId"] as! NSNumber)
            }
            parameterDict[kOFFERS] = newOfferArray as AnyObject
        }
        else {
            parameterDict[kOFFERS] = newOfferArray as AnyObject
        }
        
        parameterDict[kPARTYSAVINGPLANTYPE] = "Individual" as AnyObject
        parameterDict["STATUS"] = "Active" as AnyObject
        print("recurring = \(recurringAmount)")
        parameterDict[kRECURRINGAMOUNT] = String(format: "%.f", recurringAmount) as AnyObject
        return parameterDict
        
    }
    
    
    
    //This method is used to send the users saving plan details to the server.
    func nextButtonPressed(_ sender:UIButton)
    {
        var dict : Dictionary<String,String> = [:]
        dict[kTitle] = itemTitle
        dict["cost"] = String(format:"%d",cost)
        dict["dateDiff"] = String(format:"%d",dateDiff)
        dict["datePickerDate"] = datePickerDate
        
        //Check if offers are already added or not
        if isOfferShow == false {
            //if yes create the saving plan
            
            if nextButtonTrigger == true {
                nextButtonTrigger = false
                return
            }
            
            self.objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            self.objAnimView.frame = (self.navigationController?.view.frame)! //self.view.frame
            self.objAnimView.animate()
            self.navigationController?.view.addSubview(self.objAnimView)
            if(itemTitle != "" && self.getParameters()[kAMOUNT] != nil && cost != 0 && dateDiff != 0 && datePickerDate != ""  && popOverSelectedStr != "") {
                let objAPI = API()
                if(itemDetailsDataDict[kTitle] == nil) {
                    objAPI.partySavingPlanDelegate = self
                    /* Stripe SDK */
                    
                    print("!!!!!!!!!!!!!!!!!!Stripe SDK!!!!!!!!!!!!!!!!!!!!!")
                    nextButtonTrigger = true
                    objAPI.createPartySavingPlan(self.getParameters(),isFromWishList: "notFromWishList")
                }
                else if(isUpdatePlan) {
                    //Update the current plan
                    objAPI.updateSavingPlanDelegate = self
                    var newDict : Dictionary<String,AnyObject> = [:]
                    let dateParameter = DateFormatter()
                    dateParameter.dateFormat = "dd-MM-yyyy"
                    var pathComponents : NSArray!
                    pathComponents = (datePickerDate).components(separatedBy: " ") as [String] as NSArray
                    var dateStr = pathComponents.lastObject as! String
                    dateStr = dateStr.replacingOccurrences(of: "/", with: "-")
                    var pathComponents2 : NSArray!
                    pathComponents2 = dateStr.components(separatedBy: "-") as [String] as NSArray
                    if((pathComponents2[0] as! String).characters.count == 4) {
                        newDict[kPLANENDDATE] = String(format: "%@-%@-%@",pathComponents2[0] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String) as AnyObject;
                    }
                    else {
                        newDict[kPLANENDDATE] = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String) as AnyObject;
                    }
                    newDict["WISHLIST_ID"] = "" as AnyObject
                    newDict[kSAVPLANID] = self.getParameters()[kSAVPLANID]
                    newDict[kPAYTYPE] = self.getParameters()[kPAYTYPE]
                    if(newDict[kPAYTYPE] as! String == kMonth) {
                        dateString = kDate
                    }
                    else {
                        dateString = kDay
                    }
                    newDict[kPAYDATE] = self.getParameters()[kPAYDATE]
                    newDict[kTITLE] = itemTitle as AnyObject
                    newDict[kAMOUNT] = cost as AnyObject
                    if(topBackgroundImageView.image != nil && topBackgroundImageView.image != self.setTopImageAsPer(imageDataDict)) {
                        let imageData:Data = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                        let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                        
                        let dict = ["imageName.jpg":base64String]
                        newDict[kIMAGE] = dict as AnyObject
                    }
                    else {
                        let dict = ["imageName.jpg":""]
                        newDict[kIMAGE] = dict as AnyObject
                    }
                    newDict[kPARTYSAVINGPLANTYPE] = self.getParameters()[kPARTYSAVINGPLANTYPE]
                    
                    newDict[kPARTYID] = self.getParameters()[kPARTYID]
                    newDict[kOFFERS] = self.getParameters()[kOFFERS]
                    newDict["PARTY_SAVINGPLAN_ID"] = itemDetailsDataDict["partySavingPlanID"]
                    newDict["STATUS"] = "Active" as AnyObject
                    print(recurringAmount)
                    newDict[kRECURRINGAMOUNT] = String(format: "%.f", recurringAmount) as AnyObject
//                    print(newDict)
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
                    newDict[kSAVPLANID] = "0" as AnyObject
//                    print(itemDetailsDataDict)
                    if itemDetailsDataDict["wishsiteURL"] is NSNull {
                        newDict[kSAVSITEURL] = "" as AnyObject
                    }
                    else{
                        newDict[kSAVSITEURL] = itemDetailsDataDict["wishsiteURL"]
                    }
                    
                    if (topBackgroundImageView.image != nil) {
                        let imageData:Data = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                        let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                        let dict = ["imageName.jpg":base64String]
                        newDict[kIMAGE] = dict as AnyObject
                    }
                    else {
                        let dict = ["imageName.jpg":""]
                        newDict[kIMAGE] = dict as AnyObject
                    }
                    newDict[kAMOUNT] = self.getParameters()[kAMOUNT]
                    newDict[kPLANENDDATE] = self.getParameters()[kPLANENDDATE]
                    newDict[kPARTYSAVINGPLANTYPE] = self.getParameters()[kPARTYSAVINGPLANTYPE]
                    newDict["STATUS"] = "Active" as AnyObject
                    print(recurringAmount)
                    newDict[kRECURRINGAMOUNT] = String(format: "%.f", recurringAmount) as AnyObject
//                    print(newDict)
                    
                    nextButtonTrigger = true
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
                scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width,height: scrlView.contentSize.height - (90 + offerDetailHeight))
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
                    obj.savID = Int(imageDataDict["savPlanID"] as! String)! as NSNumber
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
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
//        self.dismissViewControllerAnimated(true, completion: nil)
        print("cancel Button is not working...")
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        tokenstripeID = token.stripeID
        let objAPI = API()
        let userInfoDict = .object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict[kPartyID] as! NSNumber,"STRIPE_TOKEN":(token.stripeID as AnyObject),kPTYSAVINGPLANID:.value(forKey: kPTYSAVINGPLANID) as! NSNumber]
//        print(dict)
        objAPI.addSavingCardDelegate = self
        objAPI.addSavingCard(dict)
        
        //Use token for backend process
        self.dismiss(animated: true, completion: {
            completion(nil)
        })
        
        .set(1, forKey: "saveCardArray")
        .synchronize()
        
        print("+++++++++++++++++++++++++++++++")
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        
    }
    
    
    //This method is used to show the customized alert message to user
    func displayAlert(_ message:String)
    {
        //Show of UIAlertView
        let alert = UIAlertView(title: "Missing information", message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    //Delete the offer from added offers
    func closeOfferButtonPressed(_ sender:UIButton)
    {
        let indx = sender.tag - 5
        
        if(isUpdatePlan) {
            if(isOfferDetailPressed) {
                if(indx != offerDetailTag - 5) {
                    let dict = offerArr[offerDetailTag - 5]
                    
                    offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: kLightFont, size: 13)!, width: UIScreen.main.bounds.width - 70)
                    tblViewHt.constant =  tblView.frame.size.height - 120 - offerDetailHeight
                }
                else {
                    let dict = offerArr[sender.tag - 5]
                    
                    offerDetailHeight = self.heightForView((dict["offDesc"] as? String)!, font: UIFont(name: kLightFont, size: 13)!, width: UIScreen.main.bounds.width - 70)
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
        offerArr.remove(at: indx)
        
        tblView.reloadData()
        scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: tblView.frame.origin.y + tblViewHt.constant )
        
        tblView.reloadData()
        scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: tblView.frame.origin.y + tblViewHt.constant )
    }
    
    //This method is used to get the selected/entered amount by user.
    func txtFieldCellText(_ txtFldCell: SavingPlanCostTableViewCell) {
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
            scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: tblView.frame.origin.y + tblViewHt.constant)
            
            isCostChanged = true
        }
        tblView.reloadData()
    }
    
    //Add superscript to date text
    fileprivate func createXLabelText (_ index: Int,text:String) -> NSMutableAttributedString {
        let fontNormal:UIFont? = UIFont(name: kMediumFont, size:10)
        let normalscript = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:fontNormal!,NSBaselineOffsetAttributeName:0])
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:5)
        
        switch index {
        case 1:
            let superscript = NSMutableAttributedString(string: "st", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        case 2:
            let superscript = NSMutableAttributedString(string: "nd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        case 3:
            let superscript = NSMutableAttributedString(string: "rd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        case 21:
            let superscript = NSMutableAttributedString(string: "st", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        case 22:
            let superscript = NSMutableAttributedString(string: "nd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        case 23:
            let superscript = NSMutableAttributedString(string: "rd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        default:
            let superscript = NSMutableAttributedString(string: "th", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        }
        return normalscript
    }
    
    //function checking any key is null and return not null values in dictionary
    func checkNullDataFromDict(_ dict:Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject> {
        var replaceDict: Dictionary<String,AnyObject> = dict
        let blank = ""
        //check each key's value
        for key:String in Array(dict.keys) {
            let ob = dict[key]! as AnyObject
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
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker .dismiss(animated: true, completion: nil)
        //set the selected/captured image to the UIImageview.
        topBackgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        topBackgroundImageView.layer.masksToBounds = true
        topBackgroundImageView?.image = (info[UIImagePickerControllerEditedImage] as? UIImage)
        cameraButton.isHidden = true
        isImageClicked = true
        isComingGallary = true
        //        let ht = self.upperView.frame.size.height + self.tblView.frame.size.height + 50
        //        self.scrlView.contentSize = CGSizeMake(0, ht)
    }
    
    //Cancel the image picker action
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker .dismiss(animated: true, completion: nil)
    }
    
    //MARK: GetUsersSavingplanDelegate methods
    func successResponseForGetUsersPlanAPI(_ objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        var isImgLoad = false
        if let message = objResponse["message"] as? String {
            if(message == "Success") {
                //Create a dictionary to send SASavingSummaryViewController
                
                //Add spinner to the topBackgroundImageView until the image loads
                let spinner =  UIActivityIndicatorView()
                spinner.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: (self.topBackgroundImageView.frame.size.height/2)+20)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
                self.topBackgroundImageView.addSubview(spinner)
                spinner.startAnimating()
                itemDetailsDataDict = objResponse["partySavingPlan"] as! Dictionary<String,AnyObject>
                isPopoverValueChanged = true
                cameraButton.backgroundColor = UIColor.black
                cameraButton.alpha = 0.5
                cameraButton.layer.cornerRadius = cameraButton.frame.size.width/2
                offerArr = objResponse["offerList"] as! Array<Dictionary<String,AnyObject>>
                cameraButton.setImage(UIImage(named: ""), for: UIControlState())
                let underlineAttributedString = NSAttributedString(string: "edit", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,NSForegroundColorAttributeName:UIColor.white])
                cameraButton.setAttributedTitle(underlineAttributedString, for: UIControlState())
                itemTitle = itemDetailsDataDict[kTitle] as! String
                self.title = "Update plan"
                cost = Int(itemDetailsDataDict[kAmount] as! NSNumber)
                var pathComponents2 : NSArray!
                pathComponents2 = ([itemDetailsDataDict["planEndDate"] as! String]) as NSArray
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: itemDetailsDataDict["planEndDate"] as! String)
                
                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                let goodDate = dateFormatter.string(from: date!)
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
                    if  let url = URL(string:itemDetailsDataDict["image"] as! String) {
                        let request: URLRequest = URLRequest(url: url)
                        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { ( response: URLResponse?,data: Data?,error: NSError?) -> Void in
                            if(data?.count > 0) {
                                let image = UIImage(data: data!)
                                DispatchQueue.main.async(execute: {
                                    //Remove the spinner after image load
                                    self.topBackgroundImageView.image = image
                                    spinner.stopAnimating()
                                    spinner.isHidden = true
                                    self.objAnimView.removeFromSuperview()
                                })
                            }
                            else {
                                //Remove the spinner after image load
                                DispatchQueue.main.async(execute: {
                                    spinner.stopAnimating()
                                    spinner.isHidden = true
                                    self.objAnimView.removeFromSuperview()
                                })
                            }
                        } as! (URLResponse?, Data?, Error?) -> Void)
                    }
                }
                else {
                    //Remove the spinner after image load
                    spinner.stopAnimating()
                    spinner.isHidden = true
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
    
    func errorResponseForGetUsersPlanAPI(_ error: String) {
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
    func successResponseForPartySavingPlanAPI(_ objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        print(objResponse)
        if let message = objResponse["message"] as? String {
            if(message  == "Multiple representations of the same entity") {
                nextButtonTrigger = false

                let alert = UIAlertView(title: "Alert", message: "You have already created one saving plan.", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
                
            }
            else if(message == "Party Saving Plan is succesfully added") {
                //Create a dictionary to send SASavingSummaryViewController
                nextButtonTrigger = true
                var dict :  Dictionary<String,AnyObject> = [:]
                dict[kTitle] = self.getParameters()[kTITLE]
                dict[kAmount] = self.getParameters()[kAMOUNT]
                dict[kPAYDATE] = self.getParameters()[kPAYDATE]
                let newDict = self.getParameters()[kIMAGE]
                dict[kImageURL] = newDict
                dict["id"] = itemDetailsDataDict["id"]
                dict[kDay] = dateString as AnyObject
                let dateParameter = DateFormatter()
                dateParameter.dateFormat = "yyyy-MM-dd"
                var pathComponents : NSArray!
                pathComponents = (datePickerDate).components(separatedBy: " ") as [String] as NSArray
                var dateStr = pathComponents.lastObject as! String
                dateStr = dateStr.replacingOccurrences(of: "/", with: "-")
                var pathComponents2 : NSArray!
                pathComponents2 = dateStr.components(separatedBy: "-") as [String] as NSArray
                dict[kPLANENDDATE] = String(format: "%@-%@-%@",pathComponents2[0] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String) as AnyObject;
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
                        dict[kEmi] = String(format:"%d",cost/(dateDiff/168)) as AnyObject
                    }
                    else {
                        dict[kEmi] = String(format:"%d",cost) as AnyObject
                    }
                    dict["payType"] = "Weekly" as AnyObject
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
                        dict[kEmi] = String(format:"%d",cost/((dateDiff/168)/4)) as AnyObject
                        
                    }
                    else {
                        dict[kEmi] = String(format:"%d",cost) as AnyObject
                    }
                    dict["payType"] = "Monthly" as AnyObject
                }
                
                if offerArr.count>0{
                    dict["offers"] = offerArr as AnyObject
                }
                dict["planType"] = "individual" as AnyObject
                let objAPI = API()
                //                NSUserDefaults().setObject(self.checkNullDataFromDict(dict), forKey: "savingPlanDict")
                objAPI.storeValueInKeychainForKey("savingPlanDict", value: self.checkNullDataFromDict(dict) as AnyObject)
                
                .setValue(objResponse["partySavingPlanID"] as? NSNumber, forKey: kPTYSAVINGPLANID)
                .setValue(kIndividualPlan, forKey: "usersPlan")
                .synchronize()
                
                //                if let saveCardArray = objAPI.getValueFromKeychainOfKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
                
                if let saveCardArray = .object(forKey: "saveCardArray")
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
    
    func errorResponseForPartySavingPlanAPI(_ error: String) {
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
    func successResponseForUpdateSavingPlanAPI(_ objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if (objResponse["message"] as? String) != nil
        {
            //Create a dictionary to send SASavingSummaryViewController
            var dict :  Dictionary<String,AnyObject> = [:]
            dict[kTitle] = itemTitle as AnyObject
            dict[kAmount] = String(format:"%d",cost) as AnyObject
            dict[kPAYDATE] = self.getParameters()[kPAYDATE]
            let newDict = self.getParameters()[kIMAGE]
            dict[kImageURL] = newDict
            dict["id"] = self.getParameters()["partySavingPlanID"]
            dict[kDay] = dateString as AnyObject
            let dateParameter = DateFormatter()
            dateParameter.dateFormat = "yyyy-MM-dd"
            var pathComponents : NSArray!
            pathComponents = (datePickerDate).components(separatedBy: " ") as [String] as NSArray
            var dateStr = pathComponents.lastObject as! String
            dateStr = dateStr.replacingOccurrences(of: "/", with: "-")
            var pathComponents2 : NSArray!
            pathComponents2 = dateStr.components(separatedBy: "-") as [String] as NSArray
            dict[kPLANENDDATE] = String(format: "%@-%@-%@",pathComponents2[0] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String) as AnyObject;
            if(dateString == kDay) {
                if dateDiff/168 > 0 {
                    dict[kEmi] = String(format:"%d",cost/(dateDiff/168)) as AnyObject
                }
                else{
                    dict[kEmi] = String(format:"%d",cost) as AnyObject
                }
                dict["payType"] = "Weekly" as AnyObject
            }
            else {
                
                if ((dateDiff/168)/4) > 0{
                    dict[kEmi] = String(format:"%d",cost/((dateDiff/168)/4)) as AnyObject
                }
                else{
                    dict[kEmi] = String(format:"%d",cost) as AnyObject
                }
                dict["payType"] = "Monthly" as AnyObject
            }
            
            if offerArr.count>0 {
                dict["offers"] = offerArr as AnyObject
            }
            dict["planType"] = "individual" as AnyObject
            
            let objAPI = API()
            //            NSUserDefaults().setObject(self.checkNullDataFromDict(dict), forKey: "savingPlanDict")
            //            NSUserDefaults().synchronize()
            objAPI.storeValueInKeychainForKey("savingPlanDict", value: self.checkNullDataFromDict(dict) as AnyObject)
            let objSummaryView = SASavingSummaryViewController()
            objSummaryView.itemDataDict =  dict
            objSummaryView.isUpdatePlan = true
            self.navigationController?.pushViewController(objSummaryView, animated: true)
        }
        objAnimView.removeFromSuperview()
    }
    
    func errorResponseForUpdateSavingPlanAPI(_ error: String) {
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
    func addedOffers(_ offerForSaveArr:Dictionary<String,AnyObject>) {
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
            self.scrlView.contentSize = CGSize(width: 0, height: ht )
        }
        tblView.reloadData()
        
    }
    
    func skipOffers(){
        isOfferShow = false
        
    }
    
    
    // MARK: - API Response
    //Success response of AddSavingCardDelegate
    func successResponseForAddSavingCardDelegateAPI(_ objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String{
            if(message == "Successful")
            {
                if(objResponse["stripeCustomerStatusMessage"] as? String == "Customer Card detail Added Succeesfully")
                {
                    .set(1, forKey: "saveCardArray")
                    .synchronize()
                    objAnimView.removeFromSuperview()
                    if(self.isFromGroupMemberPlan == true)
                    {
                        //Navigate to SAThankYouViewController
                        self.isFromGroupMemberPlan = false
                        .setValue(1, forKey: kGroupMemberPlan)
                        .synchronize()
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
    func errorResponseForAddSavingCardDelegateAPI(_ error: String) {
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
