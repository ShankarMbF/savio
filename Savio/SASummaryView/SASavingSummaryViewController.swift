//
//  SASavingSummaryViewController.swift
//  Savio
//
//  Created by Prashant on 08/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASavingSummaryViewController: UIViewController {
    
    @IBOutlet weak var continueButtonBackgroundView: UIView!
    @IBOutlet weak var topSpaceContonueView: NSLayoutConstraint!
    
    @IBOutlet weak var vwCongrats : UIView?
    @IBOutlet weak var vwScrContent : UIView?
    @IBOutlet weak var vwSummary : UIView?
    @IBOutlet weak var vwOffer : UIView?
    @IBOutlet weak var vwOfferSubView : UIView?
    @IBOutlet weak var scrlVw : UIScrollView?
    @IBOutlet weak var lblOffer : UILabel?
    @IBOutlet weak var btnContinue : UIButton?
    
    @IBOutlet weak var lblNextDebit: UILabel!
    @IBOutlet weak var htOfferView: NSLayoutConstraint!
    @IBOutlet weak var htContentView: NSLayoutConstraint!
    @IBOutlet weak var topSpaceForContinue: NSLayoutConstraint!
    
    @IBOutlet weak var topBgImageView: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var paymentLastDate: UILabel!
    
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
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
    
    
    //    @IBOutlet weak var lblName1: UILabel?
    //    @IBOutlet weak var lblContact1: UILabel?
    
    var indexId : Int = 0
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    
    var itemDataDict : Dictionary<String,AnyObject> = [:]
    
    var offersArray : Array<Dictionary<String,AnyObject>> = []
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
    @IBOutlet weak var summaryViewHt: NSLayoutConstraint!
    var isUpdatePlan = false
    
    @IBOutlet weak var groupViewHt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnContinueClicked(sender: AnyObject) {
        if(isUpdatePlan)
        {
            let alert = UIAlertView(title: "Alert", message: "Your saving plan is updated successfully", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else
        {
            let alert = UIAlertView(title: "Alert", message: "Your saving plan is created successfully", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func setUpView(){
        print(itemDataDict)
        NSUserDefaults.standardUserDefaults().removeObjectForKey("offerList")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        btnContinue?.backgroundColor = self.setUpColor()
        continueButtonBackgroundView.backgroundColor = self.setUpShadowColor()
        continueButtonBackgroundView.layer.cornerRadius = 5
        //        btnContinue!.layer.shadowColor = self.setUpShadowColor().CGColor
        //        btnContinue!.layer.shadowOffset = CGSizeMake(0, 2)
        //        btnContinue!.layer.shadowOpacity = 1
        btnContinue!.layer.cornerRadius = 5
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "Your saving plan"
        //set Navigation right button nav-heart
        
        let btnName = UIButton()
        //        btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        
        lblName1?.hidden = true
        lblName2?.hidden = true
        lblName3?.hidden = true
        lblName4?.hidden = true
        lblName5?.hidden = true
        lblName6?.hidden = true
        lblName7?.hidden = true
        
        lblContact1?.hidden = true
        lblContact2?.hidden = true
        lblContact3?.hidden = true
        lblContact4?.hidden = true
        lblContact5?.hidden = true
        lblContact6?.hidden = true
        lblContact7?.hidden = true
        
        groupViewHt.constant = 0.0
        if let arr =  itemDataDict["INIVITED_USER_LIST"] as? Array<Dictionary<String,AnyObject>>
        {
            
            //        let ct:CGFloat = 2
            if arr.count > 0 {
                let ht = (lblName1?.frame.origin.y)! + (CGFloat(arr.count) * (lblName1?.frame.size.height)!) as CGFloat
                //            let ht = (lblName1?.frame.origin.y)! + (ct * (lblName1?.frame.size.height)!) as CGFloat
                groupViewHt.constant = ht + 10
                summaryViewHt.constant = (vwSummary?.frame.size.height)! + ht + 10
                htContentView.constant = (vwScrContent?.frame.size.height)! + ht + 10
                
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
                        lblName1?.hidden = false
                        lblContact1?.hidden = false
                        lblName1?.text = String(format: "%@ - ",dict["first_name"] as! String)
                        lblContact1?.text = contactStr
                        
                    case 1:
                        lblName2?.hidden = false
                        lblContact2?.hidden = false
                        lblName2?.text = String(format: "%@ - ",dict["first_name"] as! String)
                        lblContact2?.text = contactStr
                        
                    case 2:
                        lblName3?.hidden = false
                        lblContact3?.hidden = false
                        lblName3?.text = String(format: "%@ - ",dict["first_name"] as! String)
                        lblContact3?.text = contactStr
                        
                    case 3:
                        lblName4?.hidden = false
                        lblContact4?.hidden = false
                        lblName4?.text = String(format: "%@ - ",dict["first_name"] as! String)
                        lblContact4?.text = contactStr
                        
                    case 4:
                        lblName5?.hidden = false
                        lblContact5?.hidden = false
                        lblName5?.text = String(format: "%@ - ",dict["first_name"] as! String)
                        lblContact5?.text = contactStr
                        
                    case 5:
                        lblName6?.hidden = false
                        lblContact6?.hidden = false
                        lblName6?.text = String(format: "%@ - ",dict["first_name"] as! String)
                        lblContact6?.text = contactStr
                        
                    case 6:
                        lblName7?.hidden = false
                        lblContact7?.hidden = false
                        lblName7?.text = String(format: "%@ - ",dict["first_name"] as! String)
                        lblContact7?.text = contactStr
                        
                    default: print("Default Line Reached")
                    }
                }
            }
        }
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as! NSData
            wishListArray = (NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>)!
            
            for i in 0 ..< wishListArray.count
            {
                let dict = wishListArray[i] as Dictionary<String,AnyObject>
                if(dict["id"] as? NSNumber == itemDataDict["id"] as? NSNumber)
                {
                    indexId = i
                    break
                }
            }
            
            let dataNew = NSKeyedArchiver.archivedDataWithRootObject(wishListArray)
            
            NSUserDefaults.standardUserDefaults().setObject(dataNew, forKey: "wishlistArray")
            NSUserDefaults.standardUserDefaults().synchronize()
            
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
        vwCongrats?.layer.borderColor = UIColor.whiteColor().CGColor
        vwCongrats?.layer.borderWidth = 2.0
        vwScrContent?.layer.cornerRadius = 1.0
        vwScrContent?.layer.masksToBounds = true
        var contentRect = CGRectZero;
        
        vwSummary?.layer.borderColor = UIColor.blackColor().CGColor
        vwSummary?.layer.borderWidth = 1.5
        
        lblOffer?.hidden = true
        topSpaceForContinue.constant = 30
        topSpaceContonueView.constant = 30
        self.view.bringSubviewToFront(btnContinue!)
        htOfferView.constant = 0
        if let arrOff = itemDataDict ["offers"] as? Array<Dictionary<String,AnyObject>>{
            //        let arrOff = itemDataDict ["offers"] as! Array<Dictionary<String,AnyObject>>
            let offerCount = 0
            for var i=0; i<arrOff.count; i++ {
                
                lblOffer?.hidden = false
                // Load the TestView view.
                let testView = NSBundle.mainBundle().loadNibNamed("SummaryPage", owner: self, options: nil)[0] as! UIView
                // Set its frame and data to pageview
                testView.frame = CGRectMake(0, (CGFloat(i) * testView.frame.size.height) + 30, testView.frame.size.width - 60, testView.frame.size.height)
                vwOffer?.addSubview(testView)
                testView.backgroundColor = UIColor.lightGrayColor()
                htOfferView.constant = (CGFloat(i) * testView.frame.size.height) + 30
                htContentView.constant = (vwOffer?.frame.origin.y)! + htOfferView.constant + 220
                topSpaceForContinue.constant = 80
                topSpaceContonueView.constant = 80
                self.view.bringSubviewToFront(btnContinue!)
                scrlVw?.contentSize = CGSizeMake(0, (vwScrContent?.frame.size.height)!)
                let objDict = arrOff[i]    //: Dictionary<String,AnyObject> = [:]
                let lblTitle = testView.viewWithTag(1)! as! UILabel
                lblTitle.text = objDict["offCompanyName"] as? String
                lblTitle.hidden = false
                
                let lblDetail = testView.viewWithTag(2)! as! UILabel
                lblDetail.text = objDict["offTitle"] as? String
                
                let lblOfferDetail = testView.viewWithTag(3)! as! UILabel
                lblOfferDetail.text = objDict["offDesc"] as? String
                
                
                if let urlStr = objDict["offImage"] as? String
                {
                    let urlStr = urlStr
                    let url = NSURL(string: urlStr)
                    let bgImageView = testView.viewWithTag(4) as! UIImageView
                    let request: NSURLRequest = NSURLRequest(URL: url!)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                        if (data != nil && data?.length > 0) {
                            let image = UIImage(data: data!)
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                bgImageView.image = image
                            })
                        }
                    })
                    
                }
            }
        }
        lblTitle.text = itemDataDict["title"] as? String
        if let amount = itemDataDict["amount"] as? String
        {
            lblPrice.text =  String(format:"£ %@",(itemDataDict["amount"] as? String)!)
        }
        else
        {
            lblPrice.text =  String(format:"£ %d",(itemDataDict["amount"] as? NSNumber)!)
        }
        
        
        if (itemDataDict["imageURL"] != nil) {
            
            let newDict =  itemDataDict["imageURL"]
            
            if newDict!["imageName.jpg"] != nil {
                
                if let data :NSData = NSData(base64EncodedString: (newDict!["imageName.jpg"] as? String)!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)! {
                    topBgImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    topBgImageView.layer.masksToBounds = true
                    
                    topBgImageView.image = UIImage(data: data)
                }
            }
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        
        //lblDate.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        
        lblDate.text = itemDataDict["PLAN_END_DATE"] as? String
        
        lblMonth.text =  String(format: "£%@", itemDataDict["emi"] as! String)
        
        if(itemDataDict["day"] as? String == "date")
        {
            paymentLastDate.text =  "Monthly"
            let dateComponents = NSDateComponents()
            dateComponents.month = 1
            let calender = NSCalendar.currentCalendar()
            let newDate = calender.dateByAddingComponents(dateComponents, toDate: NSDate(), options:NSCalendarOptions(rawValue: 0))
            
            var pathComponents2 : NSArray!
            pathComponents2 = dateFormatter.stringFromDate(newDate!).componentsSeparatedByString("-")
            
            //            lblNextDebit.text = String(format:"%@-%@-%@",itemDataDict["payDate"] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String)
            lblNextDebit.text = String(format:"%@-%@-%@",itemDataDict["PAY_DATE"] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String)
        }
        else{
            paymentLastDate.text = "Weekly"
            let daysToAdd : Double = 7
            let newDate = NSDate().dateByAddingTimeInterval(60*60*24 * daysToAdd)
            var pathComponents2 : NSArray!
            pathComponents2 = dateFormatter.stringFromDate(newDate).componentsSeparatedByString("-")
            
            //            lblNextDebit.text = String(format:"%@-%@-%@",itemDataDict["payDate"] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String)
            lblNextDebit.text = String(format:"%@-%@-%@",itemDataDict["PAY_DATE"] as! String,pathComponents2[1] as! String,pathComponents2[2] as! String)
            
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlVw?.contentSize = CGSizeMake(0, (vwScrContent?.frame.size.height)!)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    //MARK: Bar button action
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
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func setUpShadowColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        
        if(colorDataDict["title"] as! String == "Group Save")
        {
            red = 114/255
            green = 177/255
            blue = 237/255
        }
        else if(colorDataDict["title"] as! String == "Wedding")
        {
            red = 153/255
            green = 153/255
            blue = 255/255
        }
        else if(colorDataDict["title"] as! String == "Baby")
        {
            red = 133/255
            green = 222/255
            blue = 175/255
        }
        else if(colorDataDict["title"] as! String == "Holiday")
        {
            red = 0/255
            green = 153/255
            blue = 153/255
        }
        else if(colorDataDict["title"] as! String == "Ride")
        {
            red = 244/255
            green = 87/255
            blue = 95/255
        }
        else if(colorDataDict["title"] as! String == "Home")
        {
            red = 251/255
            green = 151/255
            blue = 80/255
        }
        else if(colorDataDict["title"] as! String == "Gadget")
        {
            red = 187/255
            green = 211/255
            blue = 54/255
        }
        else
        {
            red = 240/255
            green = 164/255
            blue = 57/255
        }
        return UIColor(red:red as CGFloat, green: green as CGFloat, blue: blue as CGFloat, alpha: 1)
    }
    
    func setUpColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        
        if(colorDataDict["title"] as! String == "Group Save")
        {
            red = 161/255
            green = 214/255
            blue = 248/255
        }
        else if(colorDataDict["title"] as! String == "Wedding")
        {
            red = 189/255
            green = 184/255
            blue = 235/255
        }
        else if(colorDataDict["title"] as! String == "Baby")
        {
            red = 122/255
            green = 223/255
            blue = 172/255
        }
        else if(colorDataDict["title"] as! String == "Holiday")
        {
            red = 109/255
            green = 214/255
            blue = 200/255
        }
        else if(colorDataDict["title"] as! String == "Ride")
        {
            red = 242/255
            green = 104/255
            blue = 107/255
        }
        else if(colorDataDict["title"] as! String == "Home")
        {
            red = 244/255
            green = 161/255
            blue = 111/255
        }
        else if(colorDataDict["title"] as! String == "Gadget")
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
}
