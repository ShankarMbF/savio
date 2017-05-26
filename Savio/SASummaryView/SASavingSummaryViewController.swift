//
//  SASavingSummaryViewController.swift
//  Savio
//
//  Created by Prashant on 08/06/16.
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


class SASavingSummaryViewController: UIViewController {
    //Set up IBoutlets
    // BackgroundView of Continue button
    @IBOutlet weak var continueButtonBackgroundView: UIView!
    // Set up top space dynamicaly
    @IBOutlet weak var topSpaceContonueView: NSLayoutConstraint!
    @IBOutlet weak var vwUpper : UIView?  // View to show Plan's image and description
    @IBOutlet weak var vwCongrats : UIView?
    @IBOutlet weak var vwScrContent : UIView?
    @IBOutlet weak var vwSummary : UIView?     // View for showing summary of plan
    @IBOutlet weak var vwOffer : UIView?       // View for showing offer's list
    @IBOutlet weak var vwOfferSubView : UIView?
    @IBOutlet weak var scrlVw : UIScrollView?    //IBOutlet for scrollview
    @IBOutlet weak var lblOffer : UILabel?       // IBOutlet for Lable on offer list
    @IBOutlet weak var btnContinue : UIButton?    //IBOutlet for continue button
    
    @IBOutlet weak var lblNextDebit: UILabel!
    @IBOutlet weak var htOfferView: NSLayoutConstraint!    // IBOutlet to assign height of offerView
    @IBOutlet weak var htContentView: NSLayoutConstraint!  // IBoutlet to assign height for contentview as per present subViews
    @IBOutlet weak var topSpaceForContinue: NSLayoutConstraint! // IBOutlet for assigning top space of continue button
    
    @IBOutlet weak var topBgImageView: UIImageView!    //IBOutlet for showing Plan image
    
    @IBOutlet weak var lblTitle: UILabel!               //IBOutlet for seeting plan titel
    
    @IBOutlet weak var paymentLastDate: UILabel!        //IBOutlet for showing Last EMI date
    
    @IBOutlet weak var superContainerView: UIView!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    
    //-----------Setup IBOutlet to showing Invite user Name and contacts--------
    @IBOutlet weak var lblName1: UILabel?
    @IBOutlet weak var lblContact1: UILabel?
    
    @IBOutlet weak var lblName2: UILabel?
    @IBOutlet weak var lblContact2: UILabel?
    
    @IBOutlet weak var lblName3: UILabel?
    @IBOutlet weak var lblContact3: UILabel?
    
    @IBOutlet weak var lblName4: UILabel?
    @IBOutlet weak var lblContact4: UILabel?
    
    @IBOutlet weak var lblName5: UILabel?
    @IBOutlet weak var lblContact5: UILabel?
    
    @IBOutlet weak var lblName6: UILabel?
    @IBOutlet weak var lblContact6: UILabel?
    
    @IBOutlet weak var lblName7: UILabel?
    @IBOutlet weak var lblContact7: UILabel?
    
    //-----------------------------------------------------------------------------
    
    @IBOutlet weak var htDescriptionContentView: NSLayoutConstraint! // Set up hieght of plan's summary as per present subview
    
    var indexId : Int = 0  // Variable for showing wishlist count
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    
    var itemDataDict : Dictionary<String,AnyObject> = [:]
    
    var offersArray : Array<Dictionary<String,AnyObject>> = []
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
    @IBOutlet weak var summaryViewHt: NSLayoutConstraint!  // Setup height of summary as per count of invited user
    var isUpdatePlan = false
    @IBOutlet weak var groupViewHt: NSLayoutConstraint!   // Height assign for Invited user's view
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView() // Setup summary UI
        
        //Customize View's titel
//        self.navigationController?.viewControllers = [self];
        self.navigationController?.isNavigationBarHidden = true
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        self.navigationController?.navigationBar.translucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function invoke on tapping continue button
    @IBAction func btnContinueClicked(_ sender: AnyObject) {
        // Navigate app as per plan type
        print("click event")
        //Navigate to showing individual/group progress screen
        NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAProgressViewController")
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAProgressViewController")
        
    }
    
    //Function invoking for set up UI as per the individual or group plan
    func setUpView(){
        userDefaults.removeObject(forKey: "offerList")
        userDefaults.synchronize()
        
        //--------------set Navigation left button------------
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SASavingSummaryViewController.menuButtonClicked), for: .touchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        //----------------------------------------------------
        self.title = "Your plan" // Setting title of summary View
        
        //--------set Navigation right button nav-heart----------------------
        let btnName = UIButton()
        //        btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.addTarget(self, action: #selector(SASavingSummaryViewController.heartBtnClicked), for: .touchUpInside)
        
        //--------Hide all Invited user view for individual plan---------
        lblName1?.isHidden = true
        lblName2?.isHidden = true
        lblName3?.isHidden = true
        lblName4?.isHidden = true
        lblName5?.isHidden = true
        lblName6?.isHidden = true
        lblName7?.isHidden = true
        
        lblContact1?.isHidden = true
        lblContact2?.isHidden = true
        lblContact3?.isHidden = true
        lblContact4?.isHidden = true
        lblContact5?.isHidden = true
        lblContact6?.isHidden = true
        lblContact7?.isHidden = true
        //-------------------------------------------------------------
        groupViewHt.constant = 0.0
        
        //-------Setup the continue button UI---------------
        colorDataDict =  userDefaults.object(forKey: "colorDataDict") as! Dictionary<String,AnyObject>
        btnContinue?.backgroundColor = self.setUpColor()
        continueButtonBackgroundView.backgroundColor = self.setUpShadowColor()
        continueButtonBackgroundView.layer.cornerRadius = 5
        btnContinue!.layer.cornerRadius = 5
        
        let objAPI = API()
//        if let _ = objAPI.getValueFromKeychainOfKey("savingPlanDict") as? Dictionary<String,AnyObject>
        if let _ = userDefaults.object(forKey: "savingPlanDict") as? Dictionary<String,AnyObject>
        {
            print(itemDataDict)
            itemDataDict = userDefaults.object(forKey: "savingPlanDict") as! Dictionary<String, AnyObject>
            print(itemDataDict)

            //-------Check is invited user available or not and showing list----------------------------
            if let arr =  itemDataDict[kINIVITEDUSERLIST] as? Array<Dictionary<String,AnyObject>>
            {
                //Invited user list present
                if arr.count > 0 {
                    
                    //----------------Set up height as per invited user count-----------------------
//                    let ht = (lblName1?.frame.origin.y)! + (CGFloat(arr.count) * 30) as CGFloat
                    let ht = (CGFloat(arr.count) * 30) + 10 //as CGFloat
                    //            let ht = (lblName1?.frame.origin.y)! + (ct * (lblName1?.frame.size.height)!) as CGFloat
                    groupViewHt.constant = ht
                    print(ht)
                    // --------------------------------------------------------------------
                    
                    //------Set Summary height as per invited user's view height----------
                    summaryViewHt.constant = summaryViewHt.constant + ht //(vwSummary?.frame.size.height)! + ht + 10
                    htContentView.constant = htContentView.constant + ht//(vwScrContent?.frame.size.height)! + ht + 10
                    print(summaryViewHt.constant)
                    print(htContentView.constant)
                    //------------------------------------------------------------------------
                    //-------------- Show invited user list--------------------------------------
                    for i in 0 ..< arr.count {
                        let dict = arr[i] as Dictionary<String, AnyObject>
                        var contactStr = ""
                        if dict["mobile_number"] != nil &&  dict["mobile_number"] as! String != "" {
                            contactStr = dict["mobile_number"] as! String
                        }
                        else {
                            contactStr = dict["email_id"] as! String
                        }
                        
                        switch i {
                        case 0:
                            lblName1?.isHidden = false
                            lblContact1?.isHidden = false
                            lblName1?.text = String(format: "%@ %@- ",dict["first_name"] as! String, dict["second_name"] as! String)
                            lblContact1?.text = contactStr
                            
                        case 1:
                            lblName2?.isHidden = false
                            lblContact2?.isHidden = false
                            lblName2?.text = String(format: "%@ %@- ",dict["first_name"] as! String, dict["second_name"] as! String)
                            lblContact2?.text = contactStr
                            
                        case 2:
                            lblName3?.isHidden = false
                            lblContact3?.isHidden = false
                            lblName3?.text = String(format: "%@ %@- ",dict["first_name"] as! String, dict["second_name"] as! String)
                            lblContact3?.text = contactStr
                            
                        case 3:
                            lblName4?.isHidden = false
                            lblContact4?.isHidden = false
                            lblName4?.text = String(format: "%@ %@- ",dict["first_name"] as! String, dict["second_name"] as! String)
                            lblContact4?.text = contactStr
                            
                        case 4:
                            lblName5?.isHidden = false
                            lblContact5?.isHidden = false
                            lblName5?.text = String(format: "%@ %@- ",dict["first_name"] as! String, dict["second_name"] as! String)
                            lblContact5?.text = contactStr
                            
                        case 5:
                            lblName6?.isHidden = false
                            lblContact6?.isHidden = false
                            lblName6?.text = String(format: "%@ %@- ",dict["first_name"] as! String, dict["second_name"] as! String)
                            lblContact6?.text = contactStr
                            
                        case 6:
                            lblName7?.isHidden = false
                            lblContact7?.isHidden = false
                            lblName7?.text = String(format: "%@ %@- ",dict["first_name"] as! String, dict["second_name"] as! String)
                            lblContact7?.text = contactStr
                            
                        default: print("Default Line Reached")
                        }
                    }
                    //------------------------------------------------------------------------------------
                    userDefaults.setValue(1, forKey: kGroupPlan)
                    userDefaults.synchronize()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationIdentifier), object: nil)
                }
            }else {
                userDefaults.setValue(1, forKey: kIndividualPlan)
                userDefaults.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationIdentifier), object: nil)
            }
            
            //-----------------End of showing Invited user list-------------------------------------------
            
            //--------showing wishlist count--------------------------------------------------------------
            if let str = userDefaults.object(forKey: "wishlistArray") as? Data
            {
                let dataSave = str
                wishListArray = (NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>)!
                
                for i in 0 ..< wishListArray.count
                {
                    let dict = wishListArray[i] as Dictionary<String,AnyObject>
                    if(dict["id"] as? NSNumber == itemDataDict["id"] as? NSNumber)
                    {
                        indexId = i
                        break
                    }
                }
                
                let dataNew = NSKeyedArchiver.archivedData(withRootObject: wishListArray)
                
                userDefaults.set(dataNew, forKey: "wishlistArray")
                userDefaults.synchronize()
                
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
            
            //-------------------------------------------------------------------------------------------------------------
            
            //Setup UI for showing plan image
            vwCongrats?.layer.borderColor = UIColor.white.cgColor
            vwCongrats?.layer.borderWidth = 2.0
            vwScrContent?.layer.cornerRadius = 1.0
            vwScrContent?.layer.masksToBounds = true
            
            //Setup border to summary view
            vwSummary?.layer.borderColor = UIColor.black.cgColor
            vwSummary?.layer.borderWidth = 1.5
            
            lblOffer?.isHidden = true
            //        topSpaceForContinue.constant = 30
            //        topSpaceContonueView.constant = 30
            self.view.bringSubview(toFront: btnContinue!)
            htOfferView.constant = 0
            
            
            //----------Setting up UI for showing offer list---------------------------------------
            if let arrOff = itemDataDict ["offers"] as? Array<Dictionary<String,AnyObject>>{
                //        let arrOff = itemDataDict ["offers"] as! Array<Dictionary<String,AnyObject>>
                var topMargin: CGFloat = 0.0   // variable for ste top margine for each offer
                for i in 0 ..< arrOff.count {
                    
                    lblOffer?.isHidden = false
                    // Load the SummaryPage view.
                    let summaryPageView = Bundle.main.loadNibNamed("SummaryPage", owner: self, options: nil)![0] as! UIView
                    // Set its frame and data to pageview
                    topMargin = CGFloat(i) * 60 + 35
                    //                summaryPageView.frame = CGRectMake(0, topMargin + 10, (vwOffer?.frame.size.width)!, 55)
                    
                    summaryPageView.layer.cornerRadius = 3.0
                    summaryPageView.layer.masksToBounds = true
                    vwOffer?.addSubview(summaryPageView)
                    //Setting height of offer list view
                    htOfferView.constant = topMargin + 60
                    
                    //-------Setting Autolayout constrains to offer view-------------------------
                    summaryPageView.translatesAutoresizingMaskIntoConstraints = false
                    
                    let topConst = NSLayoutConstraint.init(item: summaryPageView, attribute: .top, relatedBy: .equal, toItem: vwOffer!, attribute: .top, multiplier: 1, constant: topMargin)
                    
                    let leadingConst = NSLayoutConstraint.init(item: summaryPageView, attribute: .leading, relatedBy: .equal, toItem: vwOffer!, attribute: .leading, multiplier: 1, constant: 0)
                    let trailingConst = NSLayoutConstraint.init(item: summaryPageView, attribute: .trailing, relatedBy: .equal, toItem: vwOffer!, attribute: .trailing, multiplier: 1, constant: 0)
                    let htConst = NSLayoutConstraint.init(item: summaryPageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 55)
                    vwOffer?.addConstraints([topConst, leadingConst, trailingConst, htConst])
                    //-------------------------------------------------------------------------------
                    
                    //------Setting up values to offer view-------------------------------------------
                    let objDict = arrOff[i]
                    let lblTitle = summaryPageView.viewWithTag(1)! as! UILabel
                    lblTitle.text = objDict["offCompanyName"] as? String
                    lblTitle.isHidden = false
                    
                    let lblDetail = summaryPageView.viewWithTag(2)! as! UILabel
                    lblDetail.text = objDict["offTitle"] as? String
                    
                    let lblOfferDetail = summaryPageView.viewWithTag(3)! as! UILabel
                    lblOfferDetail.text = objDict["offDesc"] as? String
                    
                    if let urlStr = objDict["offImage"] as? String
                    {
                        let urlStr = urlStr
                        let url = URL(string: urlStr)
                        let bgImageView = summaryPageView.viewWithTag(4) as! UIImageView
                        let request: URLRequest = URLRequest(url: url!)
                        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { ( response: URLResponse?,data: Data?,error: NSError?) -> Void in
                            if (data != nil && data?.count > 0) {
                                let image = UIImage(data: data!)
                                DispatchQueue.main.async(execute: {
                                    
                                    bgImageView.image = image
                                })
                            }
                        } as! (URLResponse?, Data?, Error?) -> Void)
                    }
                    //--------------------------------------------------------------------------------
                }
                 htOfferView.constant = CGFloat(arrOff.count) * 60 + 35
            }
            //Setting up height of summary container view
//            htDescriptionContentView.constant = summaryViewHt.constant//continueButtonBackgroundView.frame.origin.y + continueButtonBackgroundView.frame.size.height + htOfferView.constant + (groupViewHt.constant - 10)
            
//            htContentView.constant = (vwUpper?.frame.size.height)! + htDescriptionContentView.constant  //htContentView.constant + htOfferView.constant
            
            //Setting scrollview content size as per contentView
//            scrlVw?.contentSize = CGSizeMake(0, htContentView.constant - 30)
            
            htDescriptionContentView.constant = summaryViewHt.constant + htOfferView.constant + 200
            
            htContentView.constant =  (vwUpper?.frame.size.height)! + htDescriptionContentView.constant + 50
//             htContentView.constant = continueButtonBackgroundView.frame.origin.y + continueButtonBackgroundView.frame.size.height + 200 //htContentView.constant + htDescriptionContentView.constant
            scrlVw?.contentSize = CGSize(width: 0, height: htContentView.constant )
            
            //SHOWING PLAN TITLE
            lblTitle.text = itemDataDict[kTitle] as? String
            //Showing plan amount
            if let amount = itemDataDict[kAmount] as? String
            {
                lblPrice.text =  String(format:"£%@",amount)
            }
            else
            {
                lblPrice.text =  String(format:"£%d",(itemDataDict[kAmount] as? NSNumber)!)
            }
            
            //Showing plan image
            if (itemDataDict[kImageURL] != nil) {
                
                let newDict =  itemDataDict[kImageURL]
                
                if newDict!["imageName.jpg"] != nil {
                    
                    if let data :Data = Data(base64Encoded: (newDict!["imageName.jpg"] as? String)!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)! {
                        topBgImageView.contentMode = UIViewContentMode.scaleAspectFill
                        topBgImageView.layer.masksToBounds = true
                        
                        topBgImageView.image = UIImage(data: data)
                    }
                }
            }
            
            let str = itemDataDict["planType"] as! String
            if (str == "group") {
                let dateFormatter = DateFormatter()

                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: (itemDataDict[kPLANENDDATE] as? String)!)
                
                dateFormatter.dateFormat = "dd-MM-yyyy"
                lblDate.text = dateFormatter.string(from: date!)
                
            }else{
                
                lblDate.text = itemDataDict[kPLANENDDATE] as? String
            }
//            lblDate.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
            print(itemDataDict[kPLANENDDATE])
           
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            lblMonth.text =  String(format: "£%@", itemDataDict[kEmi] as! String)
            print(itemDataDict)
            //Calculation of last date of EMI
            if(itemDataDict[kDay] as? String == kDate)
            {
                // calculation as per selection month
                paymentLastDate.text =  "Monthly"
                var dateComponents = DateComponents()
                dateComponents.month = 1
                let calender = Calendar.current
                let newDate = (calender as NSCalendar).date(byAdding: dateComponents, to: Date(), options:NSCalendar.Options(rawValue: 0))
                
                var pathComponents2 : NSArray!
                pathComponents2 = dateFormatter.string(from: newDate!).components(separatedBy: "-") as [String] as NSArray
                print(pathComponents2)
                
                //            lblNextDebit.text = String(format:"%@-%@-%@",itemDataDict["payDate"] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String)
                lblNextDebit.text = String(format:"%@-%@-%@",itemDataDict[kPAYDATE] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String)
            }
            else {
                //calculation as per week
                 dateFormatter.dateFormat = "EEEE, d MMMM yyyy HH:mm:ss Z"
                 var daysToAdd : Double = 7
                
                let todayDateArr =  dateFormatter.string(from: Date()).components(separatedBy: " ")
                let todayDay = todayDateArr[0] 
                //                let str = "My String"
                let subStr = todayDay[todayDay.characters.index(todayDay.startIndex, offsetBy: 0)...todayDay.characters.index(todayDay.startIndex, offsetBy: 2)]
                let todayNum1 = self.nextDateFromDay(subStr)
                let nextNum2 = self.nextDateFromDay(itemDataDict[kPAYDATE] as! String)
                
                if todayNum1 < nextNum2 {
                    daysToAdd = nextNum2 - todayNum1
                }
                else if todayNum1 > nextNum2{
                    daysToAdd = (7.0 - todayNum1) + nextNum2
                }
                else{
                    daysToAdd = 7
                }

                paymentLastDate.text = "Weekly"
                
                let newDate = Date().addingTimeInterval(60*60*24 * daysToAdd)
                var pathComponents2 : NSArray!
                let str = self.daySuffix(from: newDate)
                print(str)
                pathComponents2 = dateFormatter.string(from: newDate).components(separatedBy: " ") as [String] as NSArray
                print(pathComponents2)
                print(itemDataDict["payDate"] ?? "payDate ")
//                            lblNextDebit.text = String(format:"%@-%@-%@",itemDataDict["payDate"] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String)
                print(itemDataDict["payDate"])
                let daystr = pathComponents2[0] as! String
                let strDay = daystr.replacingOccurrences(of: ",", with: "")
//                let finalDate = String(format:"%@ %@ %@ and then every %@",pathComponents2[0] as! String ,pathComponents2[1] as! String + str ,pathComponents2[2] as! String, pathComponents2[0] as! String)
                let finalDate = String(format:"%@ %@ %@ and then every %@",pathComponents2[0] as! String ,pathComponents2[1] as! String + str ,pathComponents2[2] as! String, strDay)
                lblNextDebit.text = finalDate
                lblNextDebit.font = UIFont.init(name: kBookFont, size: 15)
            }
        }
    }
    
    let dayArray : Array<String> = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    
    func nextDateFromDay(_ dateStr:String) -> Double {
        var remainingDay: Double = 0.0
        
        switch dateStr {
        case "Mon":
            remainingDay = 1.0
            break
        case "Tue":
            remainingDay =  2.0
            break
        case "Wed":
            remainingDay =  3.0
            break
        case "Thu":
            remainingDay =  4.0
            break
        case "Fri":
            remainingDay =  5.0
            break
        case "Sat":
            remainingDay =  6.0
            break
        case "Sun":
            remainingDay =  7.0
            break
        default:
            break
        }
        
        return remainingDay
    }
    
    
    func daySuffix(from date: Date) -> String {
        let calendar = Calendar.current
        let dayOfMonth = (calendar as NSCalendar).component(NSCalendar.Unit.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlVw?.contentSize = CGSize(width: 0, height: (superContainerView?.frame.size.height)!)
        //        scrlVw?.contentSize = CGSizeMake(0, htContentView.constant)
    }
    
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    
    //function invoking on tapping on heart button
    func heartBtnClicked(){
        if wishListArray.count>0{
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: kWishlistempty, message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //function invoking for set up button shadow color
    func setUpShadowColor()-> UIColor
    {
        return ColorCodes.colorForShadow(colorDataDict["savPlanID"] as! Int)
    }
    
    //function invoking for set up color as per the plan
    func setUpColor()-> UIColor
    {
        return ColorCodes.colorForCode(colorDataDict["savPlanID"] as! Int)
    }
    
}
