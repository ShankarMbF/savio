//
//  SAGroupProgressViewController.swift
//  Savio
//
//  Created by Maheshwari on 06/07/16.
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


class SAGroupProgressViewController: UIViewController,PiechartDelegate,GetUsersPlanDelegate,GetWishlistDelegate {
    
    @IBOutlet weak var groupMembersLabel: UILabel!
    @IBOutlet weak var topButtonView: UIView!
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var contentVwHt: NSLayoutConstraint!
    @IBOutlet weak var tblHt: NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var horizontalScrollView: UIScrollView!
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pagecontrol: UIPageControl!
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var participantsArr : Array<Dictionary<String,AnyObject>> = []
    var  pieChartSliceArray: Array<Piechart.Slice> = []
    var chartValues : Array<Dictionary<String,AnyObject>> = [];
    var savingPlanDetailsDict : Dictionary<String,AnyObject> =  [:]
    var statViewDetailsDict : Dictionary<String,AnyObject> =  [:]
    var piechart : Piechart?
    var planTitle = ""
    var totalAmount : Int = 0
    var paidAmount : Float = 0.0
    var ht:CGFloat = 0.0
    var timeSince = [0]
    var dateDiff = 0
    let spinner =  UIActivityIndicatorView()
    var objAnimView = ImageViewAnimation()
    var planEnddate = Date()
    let btnName = UIButton()
    let chartColors = [
        UIColor(red:237/255,green:182/255,blue:242/255,alpha:1),
        UIColor(red:181/255,green:235/255,blue:157/255,alpha:1),
        UIColor(red:247/255,green:184/255,blue:183/255,alpha:1),
        UIColor(red:118/255,green:229/255,blue:224/255,alpha:1),
        UIColor(red:238/255,green:234/255,blue:108/255,alpha:1),
        UIColor(red:170/255,green:234/255,blue:184/255,alpha:1),
        UIColor(red:193/255,green:198/255,blue:227/255,alpha:1),
        UIColor(red:246/255,green:197/255,blue:124/255,alpha:1),
        UIColor(red:234/255,green:235/255,blue:237/255,alpha:1)
    ];
    
    let topLabelColors = [
        UIColor(red:231/255,green:177/255,blue:235/255,alpha:1),
        UIColor(red:156/255,green:208/255,blue:133/255,alpha:1),
        UIColor(red:244/255,green:177/255,blue:176/255,alpha:1),
        UIColor(red:87/255,green:221/255,blue:215/255,alpha:1),
        UIColor(red:237/255,green:185/255,blue:82/255,alpha:1),
        UIColor(red:159/255,green:223/255,blue:181/255,alpha:1),
        UIColor(red:180/255,green:178/255,blue:209/255,alpha:1),
        UIColor(red:245/255,green:189/255,blue:104/255,alpha:1)
    ];
    var  prevIndxArr: Array<Int> = []

    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), for: UIControlState())
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), for: UIControlState())
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), for: UIControlState())
        savingPlanTitleLabel.isHidden = true
        self.setUPNavigation()
        //Register UIApplication Will Enter Foreground Notification
        NotificationCenter.default.addObserver(self, selector:#selector(SACreateSavingPlanViewController.callWishListAPI), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        //Create obj of ImageViewAnimation to show user while  uploading/downloading something
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        
        //Create object of API class to call the GETSavingPlanDelegate methods.
        let objAPI = API()
        
        let groupFlag = userDefaults.value(forKey: kGroupPlan) as! NSNumber
        let groupMemberFlag = userDefaults.value(forKey: kGroupMemberPlan) as! NSNumber
        if let usersPlan = userDefaults.value(forKey: kUsersPlan) as? String
        {
            if(groupFlag == 1 && usersPlan == "G")
            {
                objAPI.getSavingPlanDelegate = self
                objAPI.getUsersSavingPlan("g")
            }
            else if(groupMemberFlag == 1  && usersPlan == "GM")
            {
                objAPI.getSavingPlanDelegate = self
                objAPI.getUsersSavingPlan("gm")
            }

        }
        else {
        if(groupFlag == 1 )
        {
            objAPI.getSavingPlanDelegate = self
            objAPI.getUsersSavingPlan("g")
        }
        else if(groupMemberFlag == 1)
        {
            objAPI.getSavingPlanDelegate = self
            objAPI.getUsersSavingPlan("gm")
        }
        }
        self.view.bringSubview(toFront: topButtonView)
    }
 
    func setUPNavigation()
    {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false

        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SAGroupProgressViewController.menuButtonClicked), for: .touchUpInside)
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
        btnName.addTarget(self, action: #selector(SAGroupProgressViewController.heartBtnClicked), for: .touchUpInside)
        
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
        }
        else{
//            self.callWishListAPI()
        }
        self.callWishListAPI()
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    //set the UI for Group progress view
    func setUpView(){
        savingPlanTitleLabel.isHidden = false
        //create attribute text to savingPlanTitleLabel
        print(savingPlanDetailsDict)
        planTitle = String(format: "Our %@ plan",savingPlanDetailsDict[kTitle] as! String)
        let attrText = NSMutableAttributedString(string: planTitle)
        attrText.addAttribute(NSFontAttributeName,
                              value: UIFont(
                                name: kMediumFont,
                                size: 16.0)!,
                              range: NSRange(
                                location: 4,
                                length: (savingPlanDetailsDict[kTitle] as! String).characters.count))
        
        savingPlanTitleLabel.attributedText = attrText
        //get the total amount of plan from the Dictionary
        if let amount = savingPlanDetailsDict[kAmount] as? NSNumber
        {
            totalAmount = amount.intValue
        }
        
        let PlanID = savingPlanDetailsDict["partySavingPlanID"]
        userDefaults.set(PlanID , forKey:kPTYSAVINGPLANID)
        userDefaults.synchronize()
        
        //get the total paid amount of plan from the Dictionary
        if let totalPaidAmount = savingPlanDetailsDict["totalPaidAmount"] as? NSNumber
        {
            paidAmount = totalPaidAmount.floatValue
        }
        
        
        _ = participantsArr[0]
        
        //Check if savingPlanTransactionList is present
//        if let transactionArray = userDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
//        {
//            for i in 0 ..< transactionArray.count {
//                let transactionDict = transactionArray[i]
//                paidAmount = paidAmount + Float((transactionDict["amount"] as? NSNumber)!)
//            }
//        }
        
        horizontalScrollView.contentSize = CGSize(width: 3 * UIScreen.main.bounds.size.width, height: 0)
        //Set page control pages
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
        groupMembersLabel.text = String(format:"Group members (%d)",participantsArr.count)
        var endValue = 0
        for i in 0 ..< participantsArr.count
        {
            var errorValue : CGFloat = 1
            let participantDict = participantsArr[i] as Dictionary<String,AnyObject>
            print("participant = \(participantDict)")
            if let transactionArray = participantDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
            {
                errorValue = 0
                for i in 0 ..< transactionArray.count {
                    let transactionDict = transactionArray[i]
                    errorValue = errorValue + CGFloat((transactionDict[kAmount] as? NSNumber)!)
                     paidAmount = paidAmount + Float((transactionDict[kAmount] as? NSNumber)!)
                }
            }
            
            var error = Piechart.Slice()
            error.value = errorValue
            error.color = chartColors[i]
            error.text = "Success"
            pieChartSliceArray.append(error)
            endValue = endValue + Int(errorValue)
        }
        
        if let transactionArray = statViewDetailsDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
        {
            paidAmount = 0
            for i in 0 ..< transactionArray.count {
                let transactionDict = transactionArray[i]
                paidAmount = paidAmount + Float((transactionDict[kAmount] as? NSNumber)!)
            }
        }
        
        print("paidAmt = \(paidAmount)")
        let indiviualAmount = totalAmount / participantsArr.count
        let MaxAmount = indiviualAmount - Int(paidAmount)
        print("MaxAmount = \(MaxAmount)")
        userDefaults.set(MaxAmount, forKey: "ImpMaxAmount")
        userDefaults.synchronize()

        if(pieChartSliceArray.count <= 8)
        {
            var error = Piechart.Slice()
            error.value = CGFloat(totalAmount - endValue)//360.0 - CGFloat(pieChartSliceArray.count)
//            error.value = 360.0 - CGFloat(pieChartSliceArray.count)
            error.color = UIColor(red:234/255,green:235/255,blue:237/255,alpha:1)
            error.text = "Error"
            pieChartSliceArray.append(error)
            
        }
        
        if Int(paidAmount) == totalAmount {
            let objAPI = API()
            var link = "http://www.getsavio.com/"
            if let key = savingPlanDetailsDict[kSNSITEURL]! as? String {
                link = key
            }
            objAPI.storeValueInKeychainForKey(kSAVSITEURL, value:link as AnyObject )
        }
       
        
        for i in 0 ..< 3
        {
             //load the CircularProgress.xib to create progress view
            let circularProgress = Bundle.main.loadNibNamed("GroupCircularProgressView", owner: self, options: nil)![0] as! UIView
            circularProgress.frame = CGRect(x: CGFloat(i) * UIScreen.main.bounds.size.width,y: 0,  width: horizontalScrollView.frame.size.width, height: horizontalScrollView.frame.size.height)
 
            //customization of KDCircularProgress
            let circularView = circularProgress.viewWithTag(1) as! KDCircularProgress
            circularView.startAngle = -90 //Set the start angle of circularView
            circularView.roundedCorners = true
            circularView.lerpColorMode = true
            circularView.angle = Double((paidAmount * 360)/Float(totalAmount))
            
            let labelOne = circularProgress.viewWithTag(4) as! UILabel
            let labelTwo = circularProgress.viewWithTag(5) as! UILabel
            let labelThree = circularProgress.viewWithTag(6) as! UILabel
            let labelFour = circularProgress.viewWithTag(7) as! UILabel
            let labelFive = circularProgress.viewWithTag(8) as! UILabel
            let labelSix = circularProgress.viewWithTag(9) as! UILabel

            if(i == 0)
            {
                labelOne.isHidden = true
                labelTwo.isHidden = true
                labelThree.isHidden = true
                labelFour.isHidden = true
                labelFive.isHidden = true
                circularView.isHidden = true
                
                //calculate the time difference between plan end date and todays date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                planEnddate = dateFormatter.date(from: savingPlanDetailsDict["planEndDate"] as! String)!
                
                //set the pie chart to show individual progress of each user
                piechart = Piechart()
                let imgView = UIImageView()
                piechart!.frame = CGRect(x: 0,y: 0, width: horizontalScrollView.frame.width, height: horizontalScrollView.frame.height)
                
                if(UIScreen.main.bounds.width == 320)
                {
                    piechart?.radius.outer = horizontalScrollView.frame.width - 185
                    piechart?.radius.inner = horizontalScrollView.frame.width - 210
                    imgView.frame = CGRect(x: 70,y: 83,width: 182,height: 182)
                    
                }
                else if(UIScreen.main.bounds.width == 375) {
                    piechart?.radius.outer = horizontalScrollView.frame.width - 227
                    piechart?.radius.inner = horizontalScrollView.frame.width - 255
                    imgView.frame = CGRect(x: 85,y: 72,width: 205,height: 205)
                }
                else if(UIScreen.main.bounds.width == 414) {
                    piechart?.radius.outer = horizontalScrollView.frame.width - 250
                    piechart?.radius.inner = horizontalScrollView.frame.width - 275
                    imgView.frame = CGRect(x: 87,y: 53,width: 240,height: 240)
                }
                
                spinner.center = CGPoint(x: imgView.frame.size.width/2, y: imgView.frame.size.height/2)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                imgView.addSubview(spinner)
                spinner.startAnimating()
          
                piechart!.delegate = self
                piechart?.backgroundColor = UIColor.clear
                piechart!.slices = pieChartSliceArray
                circularProgress.addSubview(piechart!)
                
                imgView.layer.cornerRadius = imgView.frame.size.height / 2
                imgView.clipsToBounds = true
                imgView.contentMode = UIViewContentMode.scaleAspectFill
                imgView.image = UIImage(named: "SavioPlaceholder")
              
               //Check if plan has image
                if let url = URL(string:(savingPlanDetailsDict["image"] as? String)!)
                {
                    //load image from URL
                    let request: URLRequest = URLRequest(url: url)
                    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                        print("Response: \(String(describing: response))")
                        if(data != nil && data!.count>0)
                        {
                            let image = UIImage(data: data!)
                            DispatchQueue.main.async(execute: {
                                //Remove the spinner after image loads
                                imgView.image = image
                                self.spinner.stopAnimating()
                                self.spinner.isHidden = true
                            })
                        }
                        else {
                            //Remove the spinner if image is not present
                            self.spinner.stopAnimating()
                            self.spinner.isHidden = true
                        }

                    })
                    
                    task.resume()
                    
                }
                piechart!.addSubview(imgView)
            }
            else if(i == 1) {
                labelOne.isHidden = true
                labelTwo.isHidden = true
                labelThree.isHidden = true
                labelFive.isHidden = false
                labelFour.isHidden = false
                labelSix.isHidden = false
                labelFour.text = String(format: "£ %0.2f saved",paidAmount)
                circularView.isHidden = false
                
//                let userDict = participantsArr[0]
//                
//                //Check if savingPlanTransactionList is present
//                if let transactionArray = userDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
//                {
//                    for i in 0 ..< transactionArray.count {
//                        let transactionDict = transactionArray[i]
//                        paidAmount = paidAmount + Float((transactionDict["amount"] as? NSNumber)!)
//                    }
//                }
                
                let text = String(format: "%d",Int(paidAmount * 100)/totalAmount)
             
                let attributes: Dictionary = [NSFontAttributeName:UIFont(name: kMediumFont, size: 45)!]
                let attString:NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: attributes)
                let fontSuper:UIFont? = UIFont(name: kMediumFont, size:25)
                let superscript = NSMutableAttributedString(string: "%", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:15])
                attString.append(superscript)
                labelSix.attributedText = attString
                
                //calculate the time difference between todays date and plan end date
//                timeSince = self.timeBetween(Date(), endDate: planEnddate)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let timeDifference : TimeInterval = planEnddate.timeIntervalSince(Date())
                dateDiff = Int(timeDifference/3600)
                if(savingPlanDetailsDict["payType"] as! String == kMonth)
                {
                    if((dateDiff/168)/4 == 1)
                    {
                        labelFive.text = String(format :"%d month to go",(dateDiff/168)/4)
                    }
                    else
                    {
                        labelFive.text = String(format :"%d months to go",(dateDiff/168)/4)
                    }
                    
                }
                else
                {
                    if((dateDiff/168) == 1)
                    {
                        labelFive.text = String(format :"%d week to go",dateDiff/168)
                    }
                    else
                    {
                        labelFive.text = String(format :"%d weeks to go",dateDiff/168)
                    }
                }
            }
            else
            {
                let userDict = participantsArr[0]
                //Check if savingPlanTransactionList array is present
                var myAmt: Float = 0
                if let transactionArray = userDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
                {
                    for i in 0 ..< transactionArray.count {
                        let transactionDict = transactionArray[i]
                        myAmt = myAmt + Float((transactionDict[kAmount] as? NSNumber)!)
                    }
                }
                labelOne.isHidden = false
                labelTwo.isHidden = false
                labelTwo.text = " You saved"
                labelThree.isHidden = false
                labelFour.isHidden = true
                labelFive.isHidden = true
                labelSix.isHidden = true
                let text = String(format: "%.f",myAmt)
                let attributes: Dictionary = [NSFontAttributeName:UIFont(name: kMediumFont, size: 45)!]
                let attString:NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: attributes)
                let fontSuper:UIFont? = UIFont(name: kMediumFont, size:25)
                let superscript = NSMutableAttributedString(string: "£ ", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:15])
                superscript.append(attString)
                labelThree.attributedText = superscript
                
                
                labelOne.text = String(format:"%d%% of your part",Int(myAmt * 100)/totalAmount)
                circularView.angle = Double((myAmt * 360)/Float(totalAmount))

                circularView.isHidden = false
            }
            horizontalScrollView.addSubview(circularProgress)
        }
        prevIndxArr.append(0)
        //customization of plan button as per the psd
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.planButton!.bounds, byRoundingCorners: ([.topRight, .topLeft]), cornerRadii: CGSize(width: 3.0, height: 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.planButton!.bounds
        maskLayer.path = maskPath.cgPath
        self.planButton?.layer.mask = maskLayer
        self.view.bringSubview(toFront: tblView)
        tblView.layer.zPosition = 1
        self.view.bringSubview(toFront: toolBarView)
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

    
    func timeBetween(_ startDate: Date, endDate: Date) -> [Int]
    {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day, .month, .year], from: startDate, to: endDate, options: [])
        return [components.day!, components.hour!, components.minute!]
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
    
    //Goto stats tab
    func statsButtonPressed(_ btn:UIButton)
    {
        let obj = SAStatViewController()
        if let itemTitle = savingPlanDetailsDict[kTitle] as? String
        {
        obj.itemTitle = itemTitle
        obj.planType = "Group"
        obj.cost =  String(format:"%@",savingPlanDetailsDict[kAmount] as! NSNumber)
        obj.endDate = savingPlanDetailsDict["planEndDate"] as! String
        }
        obj.savingPlanDict = statViewDetailsDict
        self.navigationController?.pushViewController(obj, animated: false)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.main.bounds.size.width);
        
        // Set the new page index to the page control.
        pageControl!.currentPage = Int(currentPage)
    }
    
    //UIPagecontrol method
    @IBAction func changePage(_ sender: AnyObject) {
        var newFrame = horizontalScrollView!.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl!.currentPage)
        horizontalScrollView!.scrollRectToVisible(newFrame, animated: true)
    }
    
    //Go to SAOffersViewController
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
    
    //Go to SASpendViewController
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
    
    //MARK: TableView Delegate and Datasource methods
    
    //This is UITableViewDataSource method used to return the number of sections in table view.
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int  {
        return 1;
    }
    
    //This is UITableViewDataSource method used to return the number of rows in each section in table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return participantsArr.count;
    }
    
    //This is UITableViewDataSource method used to create custom cell from GroupProgressTableViewCell.
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{
        let cellId = "CellId"
        var cell: GroupProgressTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellId) as? GroupProgressTableViewCell
        
        if cell == nil {
            var nibs: Array! =  Bundle.main.loadNibNamed("GroupProgressTableViewCell", owner: self, options: nil)
            cell = nibs[0] as? GroupProgressTableViewCell
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        cell?.saveProgress.progressColors = [chartColors[indexPath.row]]
        cell?.planView.backgroundColor = chartColors[indexPath.row]
        cell?.topVw.backgroundColor = chartColors[indexPath.row]
        cell?.makeImpulseSavingButton.addTarget(self, action: #selector(SAGroupProgressViewController.impulseSavingButtonPressed(_:)), for: .touchUpInside)
        
        let cellDict = participantsArr[indexPath.row]
        //Adjust the Constraint constant for ecpand and collapse of UITableViewCell
        if prevIndxArr.count > 0 {
            for i in 0 ..< prevIndxArr.count {
                
                if prevIndxArr[i] == indexPath.row {
                    cell?.topVwHt.constant = 22.0
                    cell?.topSpaceProfilePic.constant = 0
                    if indexPath.row == 0{
                        ht = 220.0
                    }else {
                        ht = 160.0
                    }
                    break
                }
                else {
                    cell?.topVwHt.constant = 50.0
                    cell?.topSpaceProfilePic.constant = -3
                }
            }
        }
        else {
            ht = 50.0
            cell?.topVwHt.constant = 50.0
            cell?.topSpaceProfilePic.constant = -3
        }
        
        cell?.topShadowView.backgroundColor = topLabelColors[indexPath.row]
        tblHt.constant = CGFloat(participantsArr.count * 50) + ht
        var diff : CGFloat = 0.0
        
        //Check if savingPlanTransactionList array is present
        if let transactionArray = cellDict["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
        {
            paidAmount = 0
            for i in 0 ..< transactionArray.count {
                let transactionDict = transactionArray[i]
                paidAmount = paidAmount + Float((transactionDict[kAmount] as? NSNumber)!)
                let str = String(format: "£%.0f",paidAmount)
                cell?.savedAmountLabel.text = str//String(format: "£%d",paidAmount)
                cell?.saveProgress.angle = Double((paidAmount * 360)/Float(totalAmount))

                cell?.remainingAmountLabel.text = String(format: "£%.0f",(Float(totalAmount)/Float(participantsArr.count) ) - Float(paidAmount))
                cell?.remainingProgress.angle = Double(((totalAmount - Int(paidAmount)) * 360)/Int(totalAmount))
               
            }
        }
            
        else  {
            cell?.savedAmountLabel.text = "£0"
            cell?.saveProgress.angle = 0
        
            if(savingPlanDetailsDict["payType"] as! String == kMonth)
            {
                diff = (CGFloat(dateDiff)/168)/4
                cell?.remainingAmountLabel.text = String(format: "£%0.0f",round(CGFloat(totalAmount/participantsArr.count)/diff * diff))
            }
            else
            {
                 diff = (CGFloat(dateDiff)/168)
                cell?.remainingAmountLabel.text = String(format: "£%0.0f",round(CGFloat(totalAmount/participantsArr.count)/diff * diff))
            }
            cell?.remainingProgress.angle = 360
        }
        
        //Check if user has Group/Individual plan
        if(cellDict["memberType"] as! String == "Owner")
        {
            cell?.nameLabel.text = String(format:"%@ (organiser)",(cellDict["partyName"] as? String)!)
            userDefaults.setValue(kGroupPlan, forKey: "usersPlan")
            userDefaults.synchronize()
        }
        else {
            cell?.nameLabel.text = cellDict["partyName"] as? String
            userDefaults.setValue(kGroupMemberPlan, forKey: "usersPlan")
            userDefaults.synchronize()
        }
        
 
        cell?.payTypeLabel.text = String(format: "per %@",savingPlanDetailsDict["payType"] as! String).lowercased()
        if(savingPlanDetailsDict["payType"] as! String == kMonth)
        {
                   cell?.cellTotalAmountLabel.text = String(format: "£%0.0f",round((Float(totalAmount)/Float(participantsArr.count))))
        }
        else {
                   cell?.cellTotalAmountLabel.text = String(format: "£%0.0f",round(CGFloat(totalAmount/participantsArr.count)/diff * diff))
        }
        
        let spinner =  UIActivityIndicatorView()
        spinner.center = CGPoint(x: (cell?.userProfile.frame.width)!/2, y: (cell?.userProfile.frame.height)!/2)
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        cell?.userProfile.addSubview(spinner)
        cell?.userProfile.layer.cornerRadius = (cell?.userProfile.frame.width)! / 2
        cell?.userProfile.clipsToBounds = true
        
        if let urlString = cellDict["partyImageUrl"] as? String
        {
            if(urlString != "")
            {
                let url = URL(string:urlString)
                let request: URLRequest = URLRequest(url: url!)
                
                spinner.startAnimating()
                
                let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                    print("Response: \(String(describing: response))")
                    if data?.count > 0
                    {
                        let image = UIImage(data: data!)
                        DispatchQueue.main.async(execute: {
                            cell?.userProfile.image = image
                            spinner.isHidden = true
                            spinner.stopAnimating()
                        })
                    }
                    else
                    {
                        DispatchQueue.main.async(execute: {
                            spinner.isHidden = true
                            spinner.stopAnimating()
                        })
                    }
                })
                
                task.resume()
            }
        }
        
        contentVwHt.constant = tblView.frame.origin.y + tblHt.constant
        return cell!
    }
    
    //Used to expand the individual progress  of selected user
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        ht = 0
        DispatchQueue.main.async{
            let selectedCell:GroupProgressTableViewCell? = tableView.cellForRow(at: indexPath)as? GroupProgressTableViewCell
            selectedCell?.topVwHt.constant = 22.0
            selectedCell?.topSpaceProfilePic.constant = 0
            var isVisible = false
            if self.prevIndxArr.count > 0{
                for i in 0 ..< self.prevIndxArr.count {
                    let obj = self.prevIndxArr[i] as Int
                    if obj == indexPath.row {
                        isVisible = true
                        selectedCell?.topVwHt.constant = 50.0
                        selectedCell?.topSpaceProfilePic.constant = -3
                        self.prevIndxArr.remove(at: i)
                        break
                    }
                }
                if(isVisible == false){
                    self.prevIndxArr.removeAll()
                    self.prevIndxArr.append(indexPath.row)
                }
            }
            else {
                selectedCell?.topVwHt.constant = 50.0
                selectedCell?.topSpaceProfilePic.constant = -3
                self.prevIndxArr.append(indexPath.row)
            }
            self.piechart!.click(indexPath.row)
            self.tblView.reloadData()
        }
    }
    
    //Used to collapse the individual progress  of selected user
    func tableView(_ tableView: UITableView, didDeselectRowAtIndexPath indexPath: IndexPath) {
        let selectedCell:GroupProgressTableViewCell? = tableView.cellForRow(at: indexPath)as? GroupProgressTableViewCell
        selectedCell?.topVwHt.constant = 50.0
        selectedCell?.topSpaceProfilePic.constant = -3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if prevIndxArr.count > 0 {
            for i in 0 ..< prevIndxArr.count {
                if prevIndxArr[i] == indexPath.row {
                    if indexPath.row == 0 {
                        return 220
                    }
                    else {
                        return 160.0
                    }
                }
            }
        }
        return 50.0
    }
    
    func impulseSavingButtonPressed(_ sender:UIButton)
    {
        let objImpulseSave = SAImpulseSavingViewController()
        objImpulseSave.maxPrice = Float(totalAmount) / Float(participantsArr.count)
        self.navigationController?.pushViewController(objImpulseSave, animated: true)
    }
    

    //PiechartDelegate methods
    func setSubtitle(_ total: CGFloat, slice: Piechart.Slice) -> String {
        return "\(Int(slice.value / total * 100))% \(slice.text)"
    }
    
    func setInfo(_ total: CGFloat, slice: Piechart.Slice) -> String {
        return "\(Int(slice.value))/\(Int(total))"
    }
    
    //Check if dictionary contains NULL values
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
    
     //get users plan delegate methods
    func successResponseForGetUsersPlanAPI(_ objResponse: Dictionary<String, AnyObject>) {
        var memberTypeArray : Array<String> = []
        if let message = objResponse["message"] as? String
        {
            if(message == "Success")
            {
                statViewDetailsDict = self.checkNullDataFromDict(objResponse)
                savingPlanDetailsDict = self.checkNullDataFromDict(objResponse["partySavingPlan"] as! Dictionary<String,AnyObject>)
                print(objResponse)
                userDefaults.removeObject(forKey: kSAVSITEURL)

//                  newDict["PTY_SAVINGPLAN_ID"] = NSuserDefaultsUserDefaults().valueForKey("PTY_SAVINGPLAN_ID") as! NSNumber
                
                 var ptyDict = objResponse["partySavingPlan"] as! Dictionary<String,AnyObject>
                userDefaults.set(ptyDict["partySavingPlanID"], forKey: kPTYSAVINGPLANID)
                userDefaults.synchronize()
                if objResponse["partySavingPlanMembers"] is NSNull
                {
                    print(".................... Party savings plan null .....................")
                }
                else
                {
                    participantsArr = objResponse["partySavingPlanMembers"] as! Array<Dictionary<String,AnyObject>>
                }
                var userDict : Dictionary<String,AnyObject> = [:]
                userDict["partyName"] = objResponse["partyName"]
                userDict["partyImageUrl"] = objResponse["partyImageUrl"]
                userDict["savingPlanTransactionList"] = objResponse["savingPlanTransactionList"]
                for i in 0 ..< participantsArr.count
                {
                    let memberTypeDict = participantsArr[i] as Dictionary<String,AnyObject>
                    memberTypeArray.append(memberTypeDict["memberType"] as! String)
                }
                
                if memberTypeArray.contains("Owner")
                {
                    userDict["memberType"] = "Member" as AnyObject
                }
                else {
                    userDict["memberType"] = "Owner" as AnyObject
                }
                participantsArr.append(userDict)
                participantsArr = participantsArr.reversed()
                self.setUpView()

                self.tblView.reloadData()
            }
            else
            {
                pageControl.isHidden = true
                groupMembersLabel.isHidden = true
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else
        {
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
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kTimeOutNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        objAnimView.removeFromSuperview()
    }
    
    //MARK: GetWishlist Delegate method
    func successResponseForGetWishlistAPI(_ objResponse: Dictionary<String, AnyObject>) {
        let error = objResponse["error"] as? String
        if error != nil
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
            btnName.setTitle(String(format:"%d",wishListArray.count), for: UIControlState())
            let dataSave = NSKeyedArchiver.archivedData(withRootObject: wishListArray)
            userDefaults.set(dataSave, forKey: "wishlistArray")
            userDefaults.synchronize()

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
            let alert = UIAlertView(title: "Connection problem", message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kTimeOutNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
}
