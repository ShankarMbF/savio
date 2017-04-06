//
//  SAProgressViewController.swift
//  Savio
//
//  Created by Prashant on 21/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAProgressViewController: UIViewController,GetUsersPlanDelegate,GetWishlistDelegate {
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
    @IBOutlet weak var calculationLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var circularProgressOne: KDCircularProgress!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var makeImpulseSavingButton: UIButton!
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    
    var objAnimView = ImageViewAnimation()
    var totalAmount : Float = 0.0
    var paidAmount : Float = 0.0
    var planTitle = ""
    let spinner =  UIActivityIndicatorView()
    var savingPlanDetailsDict : Dictionary<String,AnyObject> =  [:]
    let btnName = UIButton()
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), forState: UIControlState.Normal)
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), forState: UIControlState.Normal)
        self.setUPNavigation()
        //Register UIApplication Will Enter Foreground Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SACreateSavingPlanViewController.callWishListAPI), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        //Create obj of ImageViewAnimation to show user while  uploading/downloading something
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        savingPlanTitleLabel.hidden = true
        savingPlanTitleLabel!.adjustsFontSizeToFitWidth = true
        
        self.view.addSubview(objAnimView)
        
        //Create API class object to get usersSaving Plan
        let objAPI = API()
        objAPI.getSavingPlanDelegate = self
        objAPI.getUsersSavingPlan("i")
        
    }
    
    //This method is used to set the contentSize of UIScrollView
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlView.contentSize = CGSizeMake(3 * UIScreen.mainScreen().bounds.size.width, 0)
    }
    
    //set up navigation view
    func setUPNavigation()
    {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: #selector(SAProgressViewController.menuButtonClicked), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "My Plan"
        
        //set Navigation right button nav-heart
        
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: #selector(SAProgressViewController.heartBtnClicked), forControlEvents: .TouchUpInside)
        
        self.callWishListAPI()
        
        //Check if NSUserDefaults.standardUserDefaults() has value for "wishlistArray"
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
                self.callWishListAPI()
                
            }
            
            btnName.setTitle(String(format:"%d",wishListArray.count), forState: UIControlState.Normal)
        }else{
            self.callWishListAPI()
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        makeImpulseSavingButton!.layer.cornerRadius = 5
    }
    
    
    //set up the UIView
    func setUpView(){
        self.callWishListAPI()
        planTitle = String(format: "My %@ plan",savingPlanDetailsDict["partySavingPlan"]![kTitle] as! String)
        //create attribute text to savingPlanTitleLabel
        let attrText = NSMutableAttributedString(string: planTitle)
        attrText.addAttribute(NSFontAttributeName,
                              value: UIFont(
                                name: kMediumFont,
                                size: 16.0)!,
                              range: NSRange(
                                location: 3,
                                length: (savingPlanDetailsDict["partySavingPlan"]![kTitle] as! String).characters.count))
        
        savingPlanTitleLabel.attributedText = attrText
        savingPlanTitleLabel.hidden = false
        
        //get the total amount of plan from the Dictionary
        if let amount = savingPlanDetailsDict["partySavingPlan"]![kAmount] as? NSNumber
        {
            totalAmount = amount.floatValue
        }
        //Set page control pages
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
        paidAmount = 0
        if let transactionArray = savingPlanDetailsDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
        {
            for i in 0 ..< transactionArray.count {
                let transactionDict = transactionArray[i]
                paidAmount = paidAmount + Float((transactionDict[kAmount] as? NSNumber)!)
            }
        }
        
        if paidAmount == totalAmount {
            let objAPI = API()
            var link = "http://www.getsavio.com/"
            if let key = savingPlanDetailsDict["partySavingPlan"]![kSAVSITEURL] as? String {
                link = key
                objAPI.storeValueInKeychainForKey("UrlAvailable", value: "isURLAvailable")
            }
            objAPI.storeValueInKeychainForKey(kSAVSITEURL, value:link )
        }
        
        let planEndDate = savingPlanDetailsDict["partySavingPlan"]!["planEndDate"] as! String
        for i in 0 ..< 3
        {
            //load the CircularProgress.xib to create progress view
            let circularProgress = NSBundle.mainBundle().loadNibNamed("CircularProgress", owner: self, options: nil)![0] as! UIView
            circularProgress.frame = CGRectMake(CGFloat(i) * UIScreen.mainScreen().bounds.size.width,0,  scrlView.frame.size.width, scrlView.frame.size.height)
            scrlView.addSubview(circularProgress)
            
            //customization of KDCircularProgress
            let circularView = circularProgress.viewWithTag(1) as! KDCircularProgress
            circularView.startAngle = -90
            circularView.roundedCorners = true
            circularView.angle = Double((paidAmount * 360)/totalAmount)
            
            let labelOne = circularProgress.viewWithTag(3) as! UILabel
            let labelTwo = circularProgress.viewWithTag(2) as! UILabel
            let imgView = circularProgress.viewWithTag(4) as! UIImageView
            let activityIndicator = circularProgress.viewWithTag(6) as! UIActivityIndicatorView
            activityIndicator.hidden = false
            //check if plan has image
            if (!(savingPlanDetailsDict["partySavingPlan"]!["image"] is NSNull) && i == 0){
                if let url = NSURL(string:savingPlanDetailsDict["partySavingPlan"]!["image"] as! String)
                {
                    //load image from url
                    let request: NSURLRequest = NSURLRequest(URL: url)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                        if(data?.length > 0){
                            let image = UIImage(data: data!)
                            dispatch_async(dispatch_get_main_queue(), {
                                //Remove the activityIndicator after image load
                                imgView.image = image
                                activityIndicator.stopAnimating()
                                activityIndicator.hidden = true
                            })
                        }
                        else
                        {
                            //Remove the activityIndicator after image load
                            activityIndicator.stopAnimating()
                            activityIndicator.hidden = true
                        }
                    })
                }
                else {
                    //Remove the activityIndicator if image is not present
                    activityIndicator.stopAnimating()
                    activityIndicator.hidden = true
                }
            }
            else {
                activityIndicator.stopAnimating()
                activityIndicator.hidden = true
            }
            
            if(i == 0)
            {
                labelOne.hidden = true
                labelTwo.hidden = true
                imgView.hidden = false
                imgView.layer.cornerRadius = imgView.frame.width/2
            }
            else if(i == 1) {
                //                paidAmount = 1053
                labelOne.hidden = false
                labelOne.attributedText = self.createXLabelTextForPercent(i, text: String(format: "%0.f",(paidAmount*100)/totalAmount))
                labelTwo.hidden = false
                labelTwo.numberOfLines = 0
                labelTwo.lineBreakMode = .ByWordWrapping
                labelTwo.attributedText = self.createXLabelText(0, text: String(format: "%0.f added",paidAmount))//String(format: "£%0.f added",paidAmount)
                imgView.hidden = true
                activityIndicator.hidden = true
            }
            else {
                labelOne.hidden = false
                labelOne.attributedText = self.createXLabelTextForLast(i, text: String(format: "%0.f",totalAmount - paidAmount))//String(format: "£%0.f",totalAmount - paidAmount)
                labelTwo.hidden = false
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let endDate = dateFormatter.dateFromString(planEndDate)
                let timeDifference : NSTimeInterval = endDate!.timeIntervalSinceDate(NSDate())
                var dateDiff = Int(timeDifference/3600)
                var str = ""
                if(savingPlanDetailsDict["partySavingPlan"]!["payType"] as! String == kMonth)
                {
                    if((dateDiff/168)/4 == 1)
                    {
                        str = String(format :"%d month to go",(dateDiff/168)/4)
                    }
                    else
                    {
                        str = String(format :"%d months to go",(dateDiff/168)/4)
                    }
                    
                }
                else
                {
                    if((dateDiff/168) == 1)
                    {
                        str = String(format :"%d week to go",dateDiff/168)
                    }
                    else
                    {
                        str = String(format :"%d weeks to go",dateDiff/168)
                    }
                }
                
                
                labelTwo.text = str//"0 days to go"
                imgView.hidden = true
                activityIndicator.hidden = true
            }
        }
        
        //customization of plan button as per the psd
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.planButton!.bounds, byRoundingCorners: ([.TopRight, .TopLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.planButton!.bounds
        maskLayer.path = maskPath.CGPath
        self.planButton?.layer.mask = maskLayer
    }
    
    private func createXLabelText (index: Int,text:String) -> NSMutableAttributedString {
        let fontNormal:UIFont? = UIFont(name: kMediumFont, size:10)
        let normalscript = NSMutableAttributedString(string: "£", attributes: [NSFontAttributeName:UIFont(name: kMediumFont, size:8)!,NSBaselineOffsetAttributeName:3])
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:15)
        
        
        let superscript = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:0])
        normalscript.appendAttributedString(superscript)
        let newLinAttr = NSMutableAttributedString(string: "\n")
        normalscript.appendAttributedString(newLinAttr)
        return normalscript
    }
    
    private func createXLabelTextForLast (index: Int,text:String) -> NSMutableAttributedString {
        let fontNormal:UIFont? = UIFont(name: kMediumFont, size:15)
        let normalscript = NSMutableAttributedString(string: "£", attributes: [NSFontAttributeName:UIFont(name: kMediumFont, size:17)!,NSBaselineOffsetAttributeName:15])
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:40)
        
        
        let superscript = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:0])
        normalscript.appendAttributedString(superscript)
        let newLinAttr = NSMutableAttributedString(string: "\n")
        normalscript.appendAttributedString(newLinAttr)
        return normalscript
    }
    
    private func createXLabelTextForPercent (index: Int,text:String) -> NSMutableAttributedString {
        let fontNormal:UIFont? = UIFont(name: kMediumFont, size:15)
        let normalscript = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:UIFont(name: kMediumFont, size:40)!,NSBaselineOffsetAttributeName:0])
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:17)
        
        
        let superscript = NSMutableAttributedString(string: "%", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:15])
        normalscript.appendAttributedString(superscript)
        let newLinAttr = NSMutableAttributedString(string: "\n")
        normalscript.appendAttributedString(newLinAttr)
        return normalscript
    }
    
    //Function invoke for call get wish list API
    func callWishListAPI()
    {
        let objAPI = API()
        //get keychain values
        let userDict = NSUserDefaults.standardUserDefaults().objectForKey(kUserInfo) as! Dictionary<String,AnyObject>
        objAPI.getWishlistDelegate = self
        
        //Call get method of wishlist API by providing partyID
        if(userDict[kPartyID] is String)
        {
            objAPI.getWishListForUser(userDict[kPartyID] as! String)
        }
        else
        {
            objAPI.getWishListForUser(String(format: "%d",((userDict[kPartyID] as? NSNumber)?.doubleValue)!))
        }
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
        if wishListArray.count>0{
            NSNotificationCenter.defaultCenter().postNotificationName(kSelectRowIdentifier, object: "SAWishListViewController")
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")        }
        else {
            let alert = UIAlertView(title: kWishlistempty, message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
        // Set the new page index to the page control.
        pageControl!.currentPage = Int(currentPage)
    }
    
    //UIPageView control method
    @IBAction func changePage(sender: AnyObject) {
        var newFrame = scrlView!.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl!.currentPage)
        //scroll the content view so that the area defined by newFrame will be visible inside the scroll view
        scrlView!.scrollRectToVisible(newFrame, animated: true)
    }
    
    //Goto stats tab
    @IBAction func clickOnStatButton(sender:UIButton){
        if let title = savingPlanDetailsDict["partySavingPlan"]![kTitle] as? String
        {
            let obj = SAStatViewController()
            obj.itemTitle = title
            obj.planType = "Individual"
            obj.cost =  String(format:"%@",savingPlanDetailsDict["partySavingPlan"]![kAmount] as! NSNumber)
            obj.endDate = savingPlanDetailsDict["partySavingPlan"]!["planEndDate"] as! String
            print(savingPlanDetailsDict)
            if let arr = savingPlanDetailsDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>> {
            }
            
            obj.savingPlanDict = savingPlanDetailsDict
            self.navigationController?.pushViewController(obj, animated: false)
        }
        else {
            let alert = UIAlertView(title: "No data found", message: "Please try again later", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    @IBAction func offersButtonPressed(sender: AnyObject) {
        var isAvailble: Bool = false
        var vw = UIViewController?()
        
        for var obj in (self.navigationController?.viewControllers)!{
            if obj.isKindOfClass(SAOfferListViewController) {
                isAvailble = true
                vw = obj as! SAOfferListViewController
                break
            }
        }
        
        if isAvailble {
            self.navigationController?.popToViewController(vw!, animated: false)
        }
        else{
            let obj = SAOfferListViewController()
            obj.savID = 63
            obj.isComingProgress = true
            //save the Generic plan in NSUserDefaults, so it will show its specific offers
            let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92]
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
            NSUserDefaults.standardUserDefaults().synchronize()
            obj.hideAddOfferButton = true
            self.navigationController?.pushViewController(obj, animated: false)
        }
    }
    
    @IBAction func spendButtonPressed(sender: AnyObject) {
        var isAvailble: Bool = false
        var vw = UIViewController?()
        
        for var obj in (self.navigationController?.viewControllers)!{
            if obj.isKindOfClass(SASpendViewController) {
                isAvailble = true
                vw = obj as! SASpendViewController
                break
            }
        }
        
        if isAvailble {
            self.navigationController?.popToViewController(vw!, animated: false)
        }
        else{
            
            let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
            self.navigationController?.pushViewController(objPlan, animated: false)
        }
    }
    
    @IBAction func impulseSavingButtonPressed(sender: UIButton) {
        let objImpulseSave = SAImpulseSavingViewController()
        objImpulseSave.maxPrice = totalAmount
        self.navigationController?.pushViewController(objImpulseSave, animated: true)
    }
    
    //get users plan delegate methods
    func successResponseForGetUsersPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if let message = objResponse["message"] as? String
        {
            if(message == "Success")
            {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kSAVSITEURL)
                NSUserDefaults.standardUserDefaults().removeObjectForKey("isURLAvailable")
                NSUserDefaults.standardUserDefaults().synchronize()
                savingPlanDetailsDict = objResponse
                self.setUpView()
            }
            else {
                pageControl.hidden = true
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else {
            pageControl.hidden = true
            let alert = UIAlertView(title: "Alert", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        objAnimView.removeFromSuperview()
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
    
    //MARK: GetWishlist Delegate method
    func successResponseForGetWishlistAPI(objResponse: Dictionary<String, AnyObject>) {
        if let error = objResponse["error"] as? String
        {
        }
        else
        {
            let wishListResponse = self.checkNullDataFromDict(objResponse)
            wishListArray = wishListResponse["wishListList"] as! Array<Dictionary<String,AnyObject>>
            if(wishListArray.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
                
            }
            let dataSave = NSKeyedArchiver.archivedDataWithRootObject(wishListArray)
            NSUserDefaults.standardUserDefaults().setObject(dataSave, forKey: "wishlistArray")
            NSUserDefaults.standardUserDefaults().synchronize()
            btnName.setTitle(String(format:"%d",wishListArray.count), forState: UIControlState.Normal)
        }
    }
    //function invoke when GetWishlist API request fail
    func errorResponseForGetWishlistAPI(error: String) {
        objAnimView.removeFromSuperview()
        if(error == kNonetworkfound)
        {
        }
        else {
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
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
    
    
}
