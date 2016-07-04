//
//  SACreateGroupSavingPlanViewController.swift
//  Savio
//
//  Created by Maheshwari on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit


protocol SACreateGroupSavingPlanDelegate {
    
    func clearAll()
}

class SACreateGroupSavingPlanViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SegmentBarChangeDelegate,SAOfferListViewDelegate,PartySavingPlanDelegate {
    
    @IBOutlet weak var tblViewHt: NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var addAPhotoLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var topBgImageView: UIImageView!
    @IBOutlet weak var scrlView: UIScrollView!
    var participantsArr : Array<Dictionary<String,AnyObject>> = []
    var selectedStr = ""
    var cost : Int = 0
    var parameterDict : Dictionary<String,AnyObject> = [:]
    var dateDiff : Int = 0
    var dateString = "date"
    var isClearPressed = false
    var isDateChanged =  false
    var isOfferShow = false
    var objAnimView = ImageViewAnimation()
    var delegate : SACreateGroupSavingPlanDelegate?
    
    var userInfoDict  : Dictionary<String,AnyObject> = [:]
    var offerArr: Array<Dictionary<String,AnyObject>> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Savings plan setup"
        let font = UIFont(name: "GothamRounded-Book", size: 15)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font!]
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        tblView!.registerNib(UINib(nibName: "SetDayTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanSetDateIdentifier")
        tblView!.registerNib(UINib(nibName: "CreateSavingPlanTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateSavingPlanTableViewCellIdentifier")
        tblView!.registerNib(UINib(nibName: "GroupCalculationTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupCalculationCellIdentifier")
        tblView!.registerNib(UINib(nibName: "ClearButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ClearButtonIdentifier")
        tblView!.registerNib(UINib(nibName: "OfferTableViewCell", bundle: nil), forCellReuseIdentifier: "OfferTableViewCellIdentifier")
        
        dateDiff =  Int(parameterDict["dateDiff"] as! String)!
        
        participantsArr = parameterDict["participantsArr"] as! Array
        cost =  Int(parameterDict["amount"] as! String)!
        let objAPI = API()
        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        print(userInfoDict)
        let dict = ["first_name":userInfoDict["first_name"]!,"email_id":userInfoDict["email"]!,"mobile_number":userInfoDict["phone_number"]!] as Dictionary<String,AnyObject>
        participantsArr.append(dict)
        
        self.setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setUpView(){
        //set Navigation left button
        
        
        
        
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("backButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
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
            let dataSave = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
            let wishListArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataSave!) as? Array<Dictionary<String,AnyObject>>
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
        
        if (parameterDict["imageURL"] != nil ||  parameterDict["isUpdate"]!.isEqualToString("Yes"))
        {

            let data :NSData = NSData(base64EncodedString: parameterDict["imageURL"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
            
            topBgImageView.image = UIImage(data: data)
            cameraButton.hidden = true
            //addAPhotoLabel.hidden = true
        }
        else
        {
            self.cameraButton.hidden = false
           // addAPhotoLabel.hidden = false
        }
        
        if parameterDict["isUpdate"]!.isEqualToString("Yes") {
            isDateChanged = true
        }
        
        
    }
    
    func backButtonClicked()
    {
        self.navigationController?.popViewControllerAnimated(true)
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if parameterDict["isUpdate"]!.isEqualToString("Yes") {
            return offerArr.count + 3
        }
        else{
            return offerArr.count + 4
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        if(indexPath.section == 0)
        {
            
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanSetDateIdentifier", forIndexPath: indexPath) as! SetDayTableViewCell
            cell1.tblView = tblView
            cell1.view = self.view
            cell1.segmentDelegate = self
            
            if parameterDict["isUpdate"]!.isEqualToString("Yes") {
                if let payType = parameterDict["payType"] as? NSString
                {
                    if(payType == "Week")
                    {
                        let button = UIButton()
                        button.tag = 0
                        cell1.segmentBar.toggleButton(button)
                    }
                    
                }
                if let payDate = parameterDict["payDate"] as? String
                {
                    cell1.dayDateTextField.text = payDate
                }
            }
            else
            {
                if(selectedStr != "")
                {
                    cell1.dayDateTextField.text = selectedStr
                }
                
                if(isClearPressed)
                {
                    cell1.dayDateTextField.text = ""
                }
                
            }
            
            
            
            return cell1
        }
            
        else if(indexPath.section == 1){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("GroupCalculationCellIdentifier", forIndexPath: indexPath) as! GroupCalculationTableViewCell
            
            if(isDateChanged)
            {
                cell1.percentageCalculationLabel.text = String(format: "You are saving for %d%% which is £%d of the total goal of £%d",100/(participantsArr.count),cost/(participantsArr.count + 1),cost)
                if(dateString == "day")
                {
                    if((dateDiff/168) == 1)
                    {
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per week for %d week",(cost/(participantsArr.count))/(dateDiff/168),(dateDiff/168))
                    }
                    else if ((dateDiff/168) == 0)
                    {
                        cell1.calculationLabel.text = "You will need to save £0 per week for 0 week"
                    }
                    else
                    {
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per week for %d weeks",(cost/(participantsArr.count))/(dateDiff/168),(dateDiff/168))
                    }
                    
                }
                else{
                    if((dateDiff/168)/4 == 1)
                    {
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per month for %d month",((cost/participantsArr.count)/((dateDiff/168)/4)),(dateDiff/168)/4)
                    }
                    else if ((dateDiff/168)/4 == 0)
                    {
                        cell1.calculationLabel.text = "You will need to save £0 per month for 0 month"
                    }
                    else{
                        cell1.calculationLabel.text = String(format: "You will need to save £%d per month for %d months",((cost/(participantsArr.count ))/((dateDiff/168)/4)),(dateDiff/168)/4)
                    }
                }
                
            }
            
            if(isClearPressed)
            {
                cell1.calculationLabel.text = ""
            }
            return cell1
            
        }
            
        else if(indexPath.section == offerArr.count+2){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("CreateSavingPlanTableViewCellIdentifier", forIndexPath: indexPath) as! CreateSavingPlanTableViewCell
            if parameterDict["isUpdate"]!.isEqualToString("Yes") {
                cell1.createSavingPlanButton.setTitle("Join group", forState: UIControlState.Normal)
                cell1.createSavingPlanButton.addTarget(self, action: Selector("joinGroupButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            }
            else{
                cell1.createSavingPlanButton.addTarget(self, action: Selector("createSavingPlanButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
            }

            return cell1
        }
        else if(indexPath.section == offerArr.count+3){
            
            let cell1 = tableView.dequeueReusableCellWithIdentifier("ClearButtonIdentifier", forIndexPath: indexPath) as! ClearButtonTableViewCell
            cell1.tblView = tblView
            cell1.clearButton.addTarget(self, action: Selector("clearButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
            
        }
        else
        {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("OfferTableViewCellIdentifier", forIndexPath: indexPath) as! OfferTableViewCell
            cell1.tblView = tblView
            cell1.closeButton.tag = indexPath.section
            cell1.closeButton.addTarget(self, action: Selector("closeOfferButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            let dict = offerArr[indexPath.row]
            cell1.offerTitleLabel.text = dict["offCompanyName"] as? String
            cell1.offerDetailLabel.text = dict["offTitle"] as? String
            cell1.descriptionLabel.text = dict["offSummary"] as? String
            
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
            return 64
        }
        else if(indexPath.section == offerArr.count+2){
            return 65
        }
        else if(indexPath.section == offerArr.count+3){
            return 40
        }
            
        else if(indexPath.section == 1)
        {
 
            if(isDateChanged)
            {
                return 100
            }
            else
            {
                return 0
            }
            
        }
        else
        {
            return 60
        }
    }
    
    func getDateTextField(str: String) {
        selectedStr = str
        isDateChanged = true
        isClearPressed = false
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
        isDateChanged = true
    }
    
    func closeOfferButtonPressed(sender:UIButton)
    {
        offerArr.removeAtIndex(0)
        tblViewHt.constant =  tblView.frame.size.height + CGFloat(offerArr.count * 65)
        tblView.reloadData()
    }
    func displayAlert(message:String)
    {
        let alert = UIAlertView(title: "Warning", message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    func getParametersForUpdate() -> Dictionary<String,AnyObject>
    {
        var newDict : Dictionary<String,AnyObject> = [:]
        if parameterDict["isUpdate"]!.isEqualToString("No") {
            newDict["INIVITED_USER_LIST"] = participantsArr
        }
//        newDict["INIVITED_DATE"] = parameterDict["INIVITED_DATE"]
        newDict["PLAN_END_DATE"] = parameterDict["PLAN_END_DATE"]
        newDict["title"] = parameterDict["title"]
        newDict["amount"] = parameterDict["amount"]
        newDict["payDate"] = parameterDict["payDate"]
        newDict["pty_id"] = parameterDict["pty_id"]
        newDict["partySavingPlanID"] = parameterDict["sav_id"]
        newDict["imageURL"] = parameterDict["imageURL"]
        newDict["payType"] = parameterDict["payType"]
        newDict["wishList_ID"] = parameterDict["id"]
        
        parameterDict["payDate"] = selectedStr
        if(dateString == "date")
        {
            newDict["payType"] = "Month"
        }
        else
        {
            newDict["payType"] = "Week"
        }
        
        var newOfferArray : Array<NSNumber> = []
        if offerArr.count>0{
            
            for i in 0 ..< offerArr.count
            {
                let dict = offerArr[i]
                newOfferArray.append(dict["offId"] as! NSNumber)
            }
            newDict["offer_List"] = newOfferArray
        }
        else
        {
            newDict["offer_List"] = newOfferArray
        }
        return newDict
        
    }

    
    
    func getParameters() -> Dictionary<String,AnyObject>
    {
        var newDict : Dictionary<String,AnyObject> = [:]
         if parameterDict["isUpdate"]!.isEqualToString("No") {
        newDict["INIVITED_USER_LIST"] = participantsArr
        }
        newDict["INIVITED_DATE"] = parameterDict["INIVITED_DATE"]
        newDict["PLAN_END_DATE"] = parameterDict["PLAN_END_DATE"]
        newDict["title"] = parameterDict["title"]
        newDict["amount"] = parameterDict["amount"]
        newDict["payDate"] = parameterDict["payDate"]
        newDict["pty_id"] = parameterDict["pty_id"]
        newDict["sav_id"] = parameterDict["sav_id"]
        newDict["imageURL"] = parameterDict["imageURL"]
        newDict["payType"] = "Direct debit"
        
        parameterDict["payDate"] = selectedStr
        if(dateString == "date")
        {
            newDict["payType"] = "Month"
        }
        else
        {
            newDict["payType"] = "Week"
        }
        
        var newOfferArray : Array<NSNumber> = []
        if offerArr.count>0{
            
            for i in 0 ..< offerArr.count
            {
                let dict = offerArr[i]
                newOfferArray.append(dict["offId"] as! NSNumber)
            }
            newDict["offer_List"] = newOfferArray
        }
        else
        {
            newDict["offer_List"] = newOfferArray
        }
        return newDict
        
    }
    func createSavingPlanButtonPressed()
    {
        
        if isOfferShow == true {
            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            
            //            print(self.getParameters())
            if(isDateChanged)
            {
                let objAPI = API()
                objAPI.partySavingPlanDelegate = self
               // print(getParameters())
                objAPI .createPartySavingPlan(self.getParameters(),isFromWishList: "notFromWishList")
                
            }
            else
            {
                self.objAnimView.removeFromSuperview()
                self.displayAlert("Please select date/day")
            }
        }
        else {
            
            let obj = SAOfferListViewController()
            obj.delegate = self
            obj.savID = parameterDict["sav_id"] as! NSNumber
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    func clearButtonPressed()
    {
        let alert = UIAlertController(title: "Aru you sure?", message: "Do you want to clear all data", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default)
        { action -> Void in

            NSUserDefaults.standardUserDefaults().removeObjectForKey("InviteGroupArray")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.navigationController?.popViewControllerAnimated(true)
            self.delegate?.clearAll()
            
            })
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func joinGroupButtonPressed(sender:UIButton)
    {
        let alert = UIAlertView(title: "Alert", message: "You have been added to group saving plan", delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        
        
//        if isOfferShow == true {
//            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
//            self.objAnimView.frame = self.view.frame
//            self.objAnimView.animate()
//            self.view.addSubview(self.objAnimView)
//            
//            //            print(self.getParameters())
//            if(isDateChanged)
//            {
//                let objAPI = API()
//                objAPI.partySavingPlanDelegate = self
//                                print(getParametersForUpdate())
//                objAPI .createPartySavingPlan(self.getParametersForUpdate(),isFromWishList: "FromWishList")
//                
//            }
//            else
//            {
//                self.objAnimView.removeFromSuperview()
//                self.displayAlert("Please select date/day")
//            }
//        }
//        else {
//            
//            let obj = SAOfferListViewController()
//            obj.delegate = self
//            obj.savID = parameterDict["sav_id"] as! NSNumber
//            self.navigationController?.pushViewController(obj, animated: true)
//        }
    }
    
    func addedOffers(offerForSaveArr:Dictionary<String,AnyObject>){
        offerArr.append(offerForSaveArr)
        tblViewHt.constant = tblView.frame.size.height + CGFloat(offerArr.count * 65)
        tblView.reloadData()
        isOfferShow = true
    }
    
    func skipOffers(){
        tblViewHt.constant = tblView.frame.size.height - CGFloat(offerArr.count * 65)
        isOfferShow = true
    }
    
    func successResponseForPartySavingPlanAPI(objResponse:Dictionary<String,AnyObject>)
    {
       // print(objResponse)
        if let message = objResponse["message"] as? String
        {
            if(message == "Party Saving Plan is succesfully added")
            {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("InviteGroupArray")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let objSummaryview = SASavingSummaryViewController()
                var newDict = self.getParameters()
                if(dateString == "day")
                {
                    newDict["emi"] = String(format:"%d",(cost/(participantsArr.count))/(dateDiff/168))
                }
                else{
                    newDict["emi"] = String(format:"%d",(cost/(participantsArr.count))/((dateDiff/168)/4))
                }
                objSummaryview.itemDataDict = newDict
                self.navigationController?.pushViewController(objSummaryview, animated: true)
            }
            else
            {
                let alert = UIAlertView(title: "Warning", message: objResponse["error"] as! String, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            
            
        }
        objAnimView.removeFromSuperview()
        
    }
    
    func errorResponseForPartySavingPlanAPI(error:String){
        print(error)
        
        let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        
        objAnimView.removeFromSuperview()
    }
    
}
