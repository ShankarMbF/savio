//
//  SAProgressViewController.swift
//  Savio
//
//  Created by Prashant on 21/06/16.
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


class SAProgressViewController: UIViewController,GetUsersPlanDelegate,GetWishlistDelegate {
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
    @IBOutlet weak var calculationLabel     : UILabel!
    @IBOutlet weak var percentageLabel      : UILabel!
    @IBOutlet weak var pageControl          : UIPageControl!
    @IBOutlet weak var scrlView             : UIScrollView!
    @IBOutlet weak var savingPlanTitleLabel : UILabel!
    @IBOutlet weak var circularProgressOne  : KDCircularProgress!
    
    @IBOutlet weak var makeImpulseSavingButton  : UIButton!
    @IBOutlet weak var statsButton              : UIButton!
    @IBOutlet weak var progressButton           : UIButton!
    @IBOutlet weak var offersButton             : UIButton!
    @IBOutlet weak var planButton               : UIButton!
    @IBOutlet weak var spendButton              : UIButton!
    
    var planTitle   = ""
    let spinner     = UIActivityIndicatorView()
    var objAnimView = ImageViewAnimation()
    let btnName     = UIButton()

    var savingPlanDetailsDict : Dictionary<String,AnyObject> =  [:]
    var totalAmount     : Float = 0.0
    var paidAmount      : Float = 0.0
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ProSetupView()
    }
    
    func ProSetupView() {
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), for: UIControlState())
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), for: UIControlState())
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), for: UIControlState())
        self.setUPNavigation()
        //Register UIApplication Will Enter Foreground Notification
        NotificationCenter.default.addObserver(self, selector:#selector(SACreateSavingPlanViewController.callWishListAPI), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        //Create obj of ImageViewAnimation to show user while  uploading/downloading something
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        savingPlanTitleLabel.isHidden = true
        savingPlanTitleLabel!.adjustsFontSizeToFitWidth = true
        
        self.view.addSubview(objAnimView)
        
        //Create API class object to get usersSaving Plan
        let objAPI = API()
        
        objAPI.getUsersSavingPlan("i")
        objAPI.getSavingPlanDelegate = self
        
    }
    
    //This method is used to set the contentSize of UIScrollView
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlView.contentSize = CGSize(width: 3 * UIScreen.main.bounds.size.width, height: 0)
    }
    
    //set up navigation view
    func setUPNavigation()
    {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SAProgressViewController.menuButtonClicked), for: .touchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "My Plan"
        
        //set Navigation right button nav-heart
        
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.addTarget(self, action: #selector(SAProgressViewController.heartBtnClicked), for: .touchUpInside)
        
        self.callWishListAPI()
        
        //Check if NSuserDefaultsUserDefaults() has value for "wishlistArray"
        if let str = userDefaults.object(forKey: "wishlistArray") as? Data
        {
            let dataSave = str
            wishListArray = (NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>)!
            if(wishListArray.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), for: UIControlState())
                btnName.setTitleColor(UIColor.black, for: UIControlState())
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
                self.callWishListAPI()
                
            }
            
            btnName.setTitle(String(format:"%d",wishListArray.count), for: UIControlState())
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
        let partySavingplan = savingPlanDetailsDict["partySavingPlan"]![kTitle] as! String
        planTitle = String(format: "My %@ plan",partySavingplan)
        
        userDefaults.set(partySavingplan, forKey:"PlanTitle")
        userDefaults.synchronize()
        
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
        savingPlanTitleLabel.isHidden = false
        
        let PlanID = savingPlanDetailsDict["partySavingPlan"]!["partySavingPlanID"]
        userDefaults.set(PlanID! , forKey:kPTYSAVINGPLANID)
        userDefaults.synchronize()
        
        print(savingPlanDetailsDict)
        //get the total amount of plan from the Dictionary
        if let amount = savingPlanDetailsDict["partySavingPlan"]![kAmount] as? NSNumber
        {
            totalAmount = amount.floatValue
        }
        //get the total paid amount of plan from the Dictionary
        //        if let totalPaidAmount = savingPlanDetailsDict["totalPaidAmount"] as? NSNumber
        //        {
        //            paidAmount = totalPaidAmount.floatValue
        //        }
        
        //Set page control pages
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
        paidAmount = 0
        userDefaults.set(totalAmount, forKey: "ImpMaxAmount")
        userDefaults.synchronize()
        
        if let transactionArray = savingPlanDetailsDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
        {
            for i in 0 ..< transactionArray.count {
                let transactionDict = transactionArray[i]
                paidAmount = paidAmount + Float((transactionDict[kAmount] as? NSNumber)!)
                //                let str = String(format: "£%.0f",paidAmount)
                //                cell?.savedAmountLabel.text = str//String(format: "£%d",paidAmount)
                //                cell?.saveProgress.angle = Double((paidAmount * 360)/Float(totalAmount))
                //                cell?.remainingAmountLabel.text = String(format: "£%.0f",(Float(totalAmount)/Float(participantsArr.count) ) - Float(paidAmount))
                //                cell?.remainingProgress.angle = Double(((totalAmount - Int(paidAmount)) * 360)/Int(totalAmount))
                
            }
            print("paidAmt = \(paidAmount)")
            let MaxAmount = totalAmount - paidAmount
            print("MaxAmount = \(MaxAmount)")
            userDefaults.set(MaxAmount, forKey: "ImpMaxAmount")
            userDefaults.synchronize()
        }
        
        if paidAmount == totalAmount {
            let objAPI = API()
            var link = "http://www.getsavio.com/"
            if let key = savingPlanDetailsDict["partySavingPlan"]![kSNSITEURL] as? String {
                link = key
                objAPI.storeValueInKeychainForKey("UrlAvailable", value: "isURLAvailable" as AnyObject)
            }
            objAPI.storeValueInKeychainForKey(kSNSITEURL, value:link as AnyObject )
        }
        
        let planEndDate = savingPlanDetailsDict["partySavingPlan"]!["planEndDate"] as! String
        
        
        for i in 0 ..< 3
        {
            //load the CircularProgress.xib to create progress view
            let circularProgress = Bundle.main.loadNibNamed("CircularProgress", owner: self, options: nil)![0] as! UIView
            circularProgress.frame = CGRect(x: CGFloat(i) * UIScreen.main.bounds.size.width,y: 0,  width: scrlView.frame.size.width, height: scrlView.frame.size.height)
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
            activityIndicator.isHidden = false
            //check if plan has image
            if (!(savingPlanDetailsDict["partySavingPlan"]!["image"] is NSNull) && i == 0){
                if let url = URL(string:savingPlanDetailsDict["partySavingPlan"]!["image"] as! String)
                {
                    //load image from url
                    let request: URLRequest = URLRequest(url: url)
                    
                    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                        print("Response: \(String(describing: response))")
                        if(data?.count > 0){
                            let image = UIImage(data: data!)
                            DispatchQueue.main.async(execute: {
                                //Remove the activityIndicator after image load
                                imgView.image = image
                                activityIndicator.stopAnimating()
                                activityIndicator.isHidden = true
                            })
                        }
                        else
                        {
                            //Remove the activityIndicator after image load
                            activityIndicator.stopAnimating()
                            activityIndicator.isHidden = true
                        }
                    })
                    
                    task.resume()
                }
                else {
                    //Remove the activityIndicator if image is not present
                    activityIndicator.stopAnimating()
                    activityIndicator.isHidden = true
                }
            }
            else {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
            }
            
            if(i == 0)
            {
                labelOne.isHidden = true
                labelTwo.isHidden = true
                imgView.isHidden = false
                imgView.layer.cornerRadius = imgView.frame.width/2
            }
            else if(i == 1) {
                //                paidAmount = 1053
                labelOne.isHidden = false
                labelOne.attributedText = self.createXLabelTextForPercent(i, text: String(format: "%0.f",(paidAmount*100)/totalAmount))
                labelTwo.isHidden = false
                labelTwo.numberOfLines = 0
                labelTwo.lineBreakMode = .byWordWrapping
                labelTwo.attributedText = self.createXLabelText(0, text: String(format: "%0.f added",paidAmount))//String(format: "£%0.f added",paidAmount)
                imgView.isHidden = true
                activityIndicator.isHidden = true
            }
            else {
                labelOne.isHidden = false
                labelOne.attributedText = self.createXLabelTextForLast(i, text: String(format: "%0.f",totalAmount - paidAmount))//String(format: "£%0.f",totalAmount - paidAmount)
                labelTwo.isHidden = false
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let endDate = dateFormatter.date(from: planEndDate)
                let timeDifference : TimeInterval = endDate!.timeIntervalSince(Date())
                let dateDiff = Int(timeDifference/3600)
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
                imgView.isHidden = true
                activityIndicator.isHidden = true
            }
        }
        
        //customization of plan button as per the psd
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.planButton!.bounds, byRoundingCorners: ([.topRight, .topLeft]), cornerRadii: CGSize(width: 3.0, height: 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.planButton!.bounds
        maskLayer.path = maskPath.cgPath
        self.planButton?.layer.mask = maskLayer
    }
    
    fileprivate func createXLabelText (_ index: Int,text:String) -> NSMutableAttributedString {
        let _:UIFont? = UIFont(name: kMediumFont, size:10)
        let normalscript = NSMutableAttributedString(string: "£", attributes: [NSFontAttributeName:UIFont(name: kMediumFont, size:8)!,NSBaselineOffsetAttributeName:3])
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:15)
        
        
        let superscript = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:0])
        normalscript.append(superscript)
        let newLinAttr = NSMutableAttributedString(string: "\n")
        normalscript.append(newLinAttr)
        return normalscript
    }
    
    fileprivate func createXLabelTextForLast (_ index: Int,text:String) -> NSMutableAttributedString {
        let _:UIFont? = UIFont(name: kMediumFont, size:15)
        let normalscript = NSMutableAttributedString(string: "£", attributes: [NSFontAttributeName:UIFont(name: kMediumFont, size:17)!,NSBaselineOffsetAttributeName:15])
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:40)
        
        
        let superscript = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:0])
        normalscript.append(superscript)
        let newLinAttr = NSMutableAttributedString(string: "\n")
        normalscript.append(newLinAttr)
        return normalscript
    }
    
    fileprivate func createXLabelTextForPercent (_ index: Int,text:String) -> NSMutableAttributedString {
        let _:UIFont? = UIFont(name: kMediumFont, size:15)
        let normalscript = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:UIFont(name: kMediumFont, size:40)!,NSBaselineOffsetAttributeName:0])
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:17)
        
        
        let superscript = NSMutableAttributedString(string: "%", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:15])
        normalscript.append(superscript)
        let newLinAttr = NSMutableAttributedString(string: "\n")
        normalscript.append(newLinAttr)
        return normalscript
    }
    
    //Function invoke for call get wish list API
    func callWishListAPI()
    {
        let objAPI = API()
        //get keychain values
        let userDict = userDefaults.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        //        let userDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    
    func heartBtnClicked(){
        //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
        if wishListArray.count>0{
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")        }
        else {
            let alert = UIAlertView(title: kWishlistempty, message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.main.bounds.size.width);
        // Set the new page index to the page control.
        pageControl!.currentPage = Int(currentPage)
    }
    
    //UIPageView control method
    @IBAction func changePage(_ sender: AnyObject) {
        var newFrame = scrlView!.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl!.currentPage)
        //scroll the content view so that the area defined by newFrame will be visible inside the scroll view
        scrlView!.scrollRectToVisible(newFrame, animated: true)
    }
    
    //Goto stats tab
    @IBAction func clickOnStatButton(_ sender:UIButton){
        if let title = savingPlanDetailsDict["partySavingPlan"]![kTitle] as? String
        {
            let obj = SAStatViewController()
            obj.itemTitle = title
            obj.planType = "Individual"
            obj.cost =  String(format:"%@",savingPlanDetailsDict["partySavingPlan"]![kAmount] as! NSNumber)
            obj.endDate = savingPlanDetailsDict["partySavingPlan"]!["planEndDate"] as! String
            print(savingPlanDetailsDict)
            let arr = savingPlanDetailsDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
            if arr != nil {
                
            }
            
            obj.savingPlanDict = savingPlanDetailsDict
            self.navigationController?.pushViewController(obj, animated: false)
        }
        else {
            let alert = UIAlertView(title: "No data found", message: "Please try again later", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    @IBAction func offersButtonPressed(_ sender: AnyObject) {
        var isAvailble: Bool = false
        var vw = UIViewController()
        
        for var obj in (self.navigationController?.viewControllers)!{
            if obj.isKind(of: SAOfferListViewController.self) {
                isAvailble = true
                vw = obj as! SAOfferListViewController
                break
            }
        }
        
        if isAvailble {
            self.navigationController?.popToViewController(vw, animated: false)
        }
        else{
            let obj = SAOfferListViewController()
            obj.savID = 63
            obj.isComingProgress = true
            //save the Generic plan in NSUserDefaults, so it will show its specific offers
            let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92] as [String : Any]
            userDefaults.set(dict, forKey:"colorDataDict")
            userDefaults.synchronize()
            obj.hideAddOfferButton = true
            self.navigationController?.pushViewController(obj, animated: false)
        }
    }
    
    @IBAction func spendButtonPressed(_ sender: AnyObject) {
        var isAvailble: Bool = false
        var vw = UIViewController()
        
        for var obj in (self.navigationController?.viewControllers)!{
            if obj.isKind(of: SASpendViewController.self) {
                isAvailble = true
                vw = obj as! SASpendViewController
                break
            }
        }
        
        if isAvailble {
            self.navigationController?.popToViewController(vw, animated: false)
        }
        else{
            
            let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
            self.navigationController?.pushViewController(objPlan, animated: false)
        }
    }
    
    @IBAction func impulseSavingButtonPressed(_ sender: UIButton) {
        let objImpulseSave = SAImpulseSavingViewController()
        objImpulseSave.maxPrice = totalAmount
        self.navigationController?.pushViewController(objImpulseSave, animated: true)
    }
    
    //get users plan delegate methods
    func successResponseForGetUsersPlanAPI(_ objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if let message = objResponse["message"] as? String
        {
            if(message == "Success")
            {
                userDefaults.removeObject(forKey: kSAVSITEURL)
                userDefaults.synchronize()
                savingPlanDetailsDict = objResponse//["partySavingPlan"] as! Dictionary<String,AnyObject>
                self.setUpView()
            }
            else {
                pageControl.isHidden = true
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else {
            pageControl.isHidden = true
            let alert = UIAlertView(title: "Alert", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        objAnimView.removeFromSuperview()
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
    
    //MARK: GetWishlist Delegate method
    func successResponseForGetWishlistAPI(_ objResponse: Dictionary<String, AnyObject>) {
        if (objResponse["error"] as? String) != nil
        {
            //            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            //            alert.show()
        }
        else
        {
            let wishListResponse = self.checkNullDataFromDict(objResponse)
            wishListArray = wishListResponse["wishListList"] as! Array<Dictionary<String,AnyObject>>
            if(wishListArray.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), for: UIControlState())
                btnName.setTitleColor(UIColor.black, for: UIControlState())
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
                
            }
            let dataSave = NSKeyedArchiver.archivedData(withRootObject: wishListArray)
            userDefaults.set(dataSave, forKey: "wishlistArray")
            userDefaults.synchronize()
            btnName.setTitle(String(format:"%d",wishListArray.count), for: UIControlState())
        }
        //        if let arr =  NSuserDefaultsUserDefaults().valueForKey("offerList") as? Array<Dictionary<String,AnyObject>>{
        //            if arr.count > 0{
        //                objAnimView.removeFromSuperview()
        //            }
        //        }
    }
    //function invoke when GetWishlist API request fail
    func errorResponseForGetWishlistAPI(_ error: String) {
        objAnimView.removeFromSuperview()
        if(error == kNonetworkfound)
        {
            //            let alert = UIAlertView(title: "Connection problem", message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            //            alert.show()
        }
        else {
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
    }
    
    //function checking any key is null and return not null values in dictionary
    func checkNullDataFromDict(_ dict:Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject> {
        var replaceDict: Dictionary<String,AnyObject> = dict
        let blank = ""
        //check each key's value
        for key:String in Array(dict.keys) {
            let ob = dict[key]! as? AnyObject
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
    
    
}
