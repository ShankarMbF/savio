//
//  SASavingSummaryViewController.swift
//  Savio
//
//  Created by Prashant on 08/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASavingSummaryViewController: UIViewController {
    
    
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
    var indexId : Int = 0
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    
    var itemDataDict : Dictionary<String,AnyObject> = [:]
    
    var offersArray : Array<Dictionary<String,AnyObject>> = []
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
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
        let alert = UIAlertView(title: "Alert", message: "Your saving plan is created successfully", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func setUpView(){
        //print(itemDataDict)
        
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        btnContinue?.backgroundColor = self.setUpColor()
        btnContinue!.layer.shadowColor = self.setUpShadowColor().CGColor
        btnContinue!.layer.shadowOffset = CGSizeMake(0, 2)
        btnContinue!.layer.shadowOpacity = 1
        btnContinue!.layer.cornerRadius = 5
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: #selector(SASavingSummaryViewController.menuButtonClicked), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "Create a saving plan"
        //set Navigation right button nav-heart
        
        let btnName = UIButton()
        //        btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: #selector(SASavingSummaryViewController.heartBtnClicked), forControlEvents: .TouchUpInside)
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") != nil)
        {
             wishListArray = (NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? Array<Dictionary<String,AnyObject>>)!
            
            for i in 0 ..< wishListArray.count
            {
             let dict = wishListArray[i] as Dictionary<String,AnyObject>
                if(String(format: "%d",((dict["id"] as? NSNumber)?.doubleValue)!) == String(format: "%d",((itemDataDict["id"] as? NSNumber)?.doubleValue)!))
                {
                     indexId = i
                }
            
            }
            
            wishListArray.removeAtIndex(indexId)
            
            NSUserDefaults.standardUserDefaults().setObject(wishListArray, forKey: "wishlistArray")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
            
            btnName.setTitle(String(format:"%d",wishListArray.count), forState: UIControlState.Normal)
           btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
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
        htOfferView.constant = 0
        let arrOff = itemDataDict ["offers"] as! Array<Dictionary<String,AnyObject>>
        let offerCount = 0
        for var i=0; i<offerCount; i++ {
            
            lblOffer?.hidden = false
            // Load the TestView view.
            let testView = NSBundle.mainBundle().loadNibNamed("SummaryPage", owner: self, options: nil)[0] as! UIView
            // Set its frame and data to pageview
            testView.frame = CGRectMake(0, (CGFloat(i) * testView.frame.size.height) + 30, testView.frame.size.width - 60, testView.frame.size.height)
            vwOffer?.addSubview(testView)
            testView.layer.borderColor = UIColor.blackColor().CGColor
            testView.layer.borderWidth = 1.0
            testView.backgroundColor = UIColor.lightGrayColor()
            
            htOfferView.constant = (CGFloat(i) * testView.frame.size.height) + 30
            htContentView.constant = (vwOffer?.frame.origin.y)! + htOfferView.constant + 200
            topSpaceForContinue.constant = 80
            scrlVw?.contentSize = CGSizeMake(0, (vwScrContent?.frame.size.height)!)
            
            
            let objDict = arrOff[i]    //: Dictionary<String,AnyObject> = [:]
     
            
            let lblTitle = testView.viewWithTag(1)! as! UILabel
            lblTitle.text = objDict["offCompanyName"] as? String
            lblTitle.hidden = false
            
            let lblDetail = testView.viewWithTag(2)! as! UILabel
            lblDetail.text = objDict["offTitle"] as? String
        
            let lblOfferDetail = testView.viewWithTag(3)! as! UILabel
            lblOfferDetail.text = objDict["offDesc"] as? String
   
            
            let urlStr = objDict["offImage"] as! String
            let url = NSURL(string: urlStr)
            let bgImageView = testView.viewWithTag(4) as! UIImageView
            let request: NSURLRequest = NSURLRequest(URL: url!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                let image = UIImage(data: data!)
                
                //                self.imageCache[unwrappedImage] = image
                dispatch_async(dispatch_get_main_queue(), {
                    bgImageView.image = image
                })
            })
        }
        
        lblTitle.text = itemDataDict["title"] as? String
        lblPrice.text = itemDataDict["amount"] as? String
        
        if (itemDataDict["imageURL"] != nil) {

        let data :NSData = NSData(base64EncodedString: itemDataDict["imageURL"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
        topBgImageView.image = UIImage(data: data)
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
      
        lblDate.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        
        paymentLastDate.text = itemDataDict["payDate"] as? String
        
        
        if(itemDataDict["day"] as? String == "date")
        {
            lblMonth.text =  String(format: "Monthly £%@", itemDataDict["emi"] as! String)
//            let cal = NSCalendar(calendarIdentifier: NSGregorianCalendar)
//            let next7Days = cal!.dateByAddingUnit(NSCalendarUnit.Month, value: 30, toDate:dateFormatter.dateFromString((itemDataDict["payDate"] as? String)!)! , options: NSCalendarOptions(rawValue: 0))
            
            lblNextDebit.text = itemDataDict["payDate"] as? String
            
//            dateComponents.month = 1
//            let next7Days = cal!.dateByAddingComponents(dateComponents, toDate: dateFormatter.dateFromString((itemDataDict["payDate"] as? String)!)!, options: NSCalendarOptions(rawValue: 0))
//            
//            lblNextDebit.text = dateFormatter.stringFromDate(next7Days!)
        }
        else{
            lblMonth.text = String(format: "Weekly £%@", itemDataDict["emi"] as! String)
//            let cal = NSCalendar(calendarIdentifier: NSGregorianCalendar)
//            let next7Days = cal!.dateByAddingUnit(NSCalendarUnit.NSWeekCalendarUnit, value: 7, toDate:dateFormatter.dateFromString((itemDataDict["payDate"] as? String)!)! , options: NSCalendarOptions(rawValue: 0))
            
            lblNextDebit.text = itemDataDict["payDate"] as? String
            
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

    
    
    func setUpShadowColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        
        if(colorDataDict["header"] as! String == "Group Save")
        {
            red = 114/255
            green = 177/255
            blue = 237/255
            
        }
        else if(colorDataDict["header"] as! String == "Wedding")
        {
            red = 153/255
            green = 153/255
            blue = 255/255
        }
        else if(colorDataDict["header"] as! String == "Baby")
        {
            red = 133/255
            green = 222/255
            blue = 175/255
        }
        else if(colorDataDict["header"] as! String == "Holiday")
        {
            red = 0/255
            green = 153/255
            blue = 153/255
        }
        else if(colorDataDict["header"] as! String == "Ride")
        {
            red = 244/255
            green = 87/255
            blue = 95/255
        }
        else if(colorDataDict["header"] as! String == "Home")
        {
            red = 251/255
            green = 151/255
            blue = 80/255
        }
        else if(colorDataDict["header"] as! String == "Gadget")
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
        
        if(colorDataDict["header"] as! String == "Group Save")
        {
            red = 161/255
            green = 214/255
            blue = 248/255
            
        }
        else if(colorDataDict["header"] as! String == "Wedding")
        {
            red = 189/255
            green = 184/255
            blue = 235/255
        }
        else if(colorDataDict["header"] as! String == "Baby")
        {
            red = 122/255
            green = 223/255
            blue = 172/255
        }
        else if(colorDataDict["header"] as! String == "Holiday")
        {
            red = 109/255
            green = 214/255
            blue = 200/255
        }
        else if(colorDataDict["header"] as! String == "Ride")
        {
            red = 242/255
            green = 104/255
            blue = 107/255
        }
        else if(colorDataDict["header"] as! String == "Home")
        {
            red = 244/255
            green = 161/255
            blue = 111/255
        }
        else if(colorDataDict["header"] as! String == "Gadget")
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
