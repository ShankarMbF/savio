//
//  SASavingPlanViewController.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASavingPlanViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate,PopOverDelegate,SavingPlanCostTableViewCellDelegate,SavingPlanDatePickerCellDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PartySavingPlanDelegate {
    @IBOutlet weak var topBackgroundImageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    var cost : Int = 0
    var dateDiff : Int = 0
    var dateString = ""
    var popOverSelectedStr = ""
    var imageDataDict : Dictionary<String,AnyObject> = [:]
    
    var itemDetailsDataDict : Dictionary<String,AnyObject> = [:]
    
    var offerCount = 0
    var userInfoDict  = Dictionary<String,AnyObject>()
    var  objAnimView = ImageViewAnimation()
    var isPopoverValueChanged = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Savings plan setup"
        let font = UIFont(name: "GothamRounded-Book", size: 15)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font!]
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        savingPlanTitleLabel.layer.borderWidth = 1
        savingPlanTitleLabel.layer.borderColor = UIColor.whiteColor().CGColor
        
        tblView!.registerNib(UINib(nibName: "SavingPlanTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanTitleIdentifier")
        tblView!.registerNib(UINib(nibName: "SavingPlanCostTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanCostIdentifier")
        tblView!.registerNib(UINib(nibName: "SavingPlanDatePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanDatePickerIdentifier")
        tblView!.registerNib(UINib(nibName: "SetDayTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanSetDateIdentifier")
        tblView!.registerNib(UINib(nibName: "CalculationTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanCalculationIdentifier")
        //OfferTableViewCell
        tblView!.registerNib(UINib(nibName: "OfferTableViewCell", bundle: nil), forCellReuseIdentifier: "OfferTableViewCellIdentifier")
        tblView!.registerNib(UINib(nibName: "NextButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "NextButtonCellIdentifier")
        tblView!.registerNib(UINib(nibName: "ClearButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ClearButtonIdentifier")
        
        let objAPI = API()
        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        
        self.setUpView()
        
    }
    
    
    func setUpView(){
        
        print(itemDetailsDataDict)
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: #selector(SASavingPlanViewController.backButtonClicked), forControlEvents: .TouchUpInside)
        
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
        //  btnName.addTarget(self, action: #selector(SACreateSavingPlanViewController.heartBtnClicked), forControlEvents: .TouchUpInside)
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        if(itemDetailsDataDict["imageURL"] != nil)
        {
            let data :NSData = NSData(base64EncodedString: itemDetailsDataDict["imageURL"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
            
            topBackgroundImageView.image = UIImage(data: data)
            cameraButton.hidden = true
            
        }
        else
        {
            imageDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
            if(imageDataDict["header"] as! String == "Group Save")
            {
                topBackgroundImageView.image = UIImage(named: "groupsave-setup-bg.png")
            }
            else if(imageDataDict["header"] as! String == "Wedding")
            {
                topBackgroundImageView.image = UIImage(named: "wdding-setup-bg.png")
            }
            else if(imageDataDict["header"] as! String == "Baby")
            {
                topBackgroundImageView.image = UIImage(named: "baby-setup-bg.png")
            }
            else if(imageDataDict["header"] as! String == "Holiday")
            {
                topBackgroundImageView.image = UIImage(named: "holiday-setup-bg.png")
            }
            else if(imageDataDict["header"] as! String == "Ride")
            {
                topBackgroundImageView.image = UIImage(named: "ride-setup-bg.png")
            }
            else if(imageDataDict["header"] as! String == "Home")
            {
                topBackgroundImageView.image = UIImage(named: "home-setup-bg.png")
            }
            else if(imageDataDict["header"] as! String == "Gadget")
            {
                topBackgroundImageView.image = UIImage(named: "gadget-setup-bg.png")
            }
            else
            {
                topBackgroundImageView.image = UIImage(named: "generic-setup-bg.png")
            }
            
            
            
        }
        
        
    }
    
    
    
    func backButtonClicked()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default)
        { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                imagePicker.allowsEditing = false
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            })
        alertController.addAction(UIAlertAction(title: "Choose Photo", style: UIAlertActionStyle.Default)
        { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                imagePicker.allowsEditing = false
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            
            })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return offerCount+7
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
            if(itemDetailsDataDict["title"] != nil)
            {
                cell1.titleTextField.text = itemDetailsDataDict["title"] as? String
                
            }
            return cell1
        }
        else if(indexPath.section == 1){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanCostIdentifier", forIndexPath: indexPath) as! SavingPlanCostTableViewCell
            cell1.tblView = tblView
            cell1.delegate = self
            cell1.view = self.view
            if(itemDetailsDataDict["amount"] != nil)
            {
                if(itemDetailsDataDict["amount"] is String)
                {
                    cell1.costTextField.text = itemDetailsDataDict["amount"] as? String
                }
                else
                {
                    cell1.costTextField.text = String(format: " %d", (itemDetailsDataDict["amount"] as! NSNumber).intValue)
                }
                cell1.costTextField.textColor = UIColor.whiteColor()
                cell1.slider.value = (cell1.costTextField.text! as NSString).floatValue
                cost = Int(cell1.slider.value)
            }
            return cell1
        }
        else if(indexPath.section == 2){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanDatePickerIdentifier", forIndexPath: indexPath) as! SavingPlanDatePickerTableViewCell
            cell1.tblView = tblView
            cell1.savingPlanDatePickerDelegate = self
            cell1.view = self.view
            return cell1
        }
        else if(indexPath.section == 3){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanSetDateIdentifier", forIndexPath: indexPath) as! SetDayTableViewCell
            cell1.tblView = tblView
            cell1.setDayDateButton.tag = indexPath.section
            if(popOverSelectedStr != "")
            {
                cell1.setDayDateButton.setTitle(popOverSelectedStr, forState: UIControlState.Normal)
                cell1.setDayDateButton.titleLabel?.textAlignment = NSTextAlignment.Left
                cell1.setDayDateButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
            }
            cell1.setDayDateButton.addTarget(self, action: Selector("setDayDateButtonButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else if(indexPath.section == 4){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanCalculationIdentifier", forIndexPath: indexPath) as! CalculationTableViewCell
            cell1.tblView = tblView
            if(isPopoverValueChanged)
            {
                if(dateString == "day")
                {
                    cell1.calculationLabel.text = String(format: "You will need to save £%d per week for %d week(s)",cost/(dateDiff/168),(dateDiff/168))
                }
                else{
                    cell1.calculationLabel.text = String(format: "You will need to save £%d per month for %d month(s)",(cost/((dateDiff/168)/4)),(dateDiff/168)/4)
                }
            }
            return cell1
        }
        else if(indexPath.section == offerCount+5)
        {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("NextButtonCellIdentifier", forIndexPath: indexPath) as! NextButtonTableViewCell
            cell1.tblView = tblView
            cell1.nextButton.addTarget(self, action: #selector(SASavingPlanViewController.nextButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else if(indexPath.section == offerCount+6)
        {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("ClearButtonIdentifier", forIndexPath: indexPath) as! ClearButtonTableViewCell
            cell1.tblView = tblView
            cell1.clearButton.addTarget(self, action: Selector("clearButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else{
            let cell1 = tableView.dequeueReusableCellWithIdentifier("OfferTableViewCellIdentifier", forIndexPath: indexPath) as! OfferTableViewCell
            cell1.tblView = tblView
            cell1.closeButton.tag = indexPath.section
            cell1.closeButton.addTarget(self, action: #selector(SASavingPlanViewController.closeOfferButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
    }
    
    func datePickerText(date: Int) {
        print(date)
        dateDiff = date
    }
    
    func clearButtonPressed()
    {
        let cell1 = tblView.dequeueReusableCellWithIdentifier("SavingPlanTitleIdentifier") as! SavingPlanTitleTableViewCell
        cell1.titleTextField.text = ""
        
        let cell2 = tblView.dequeueReusableCellWithIdentifier("SavingPlanCostIdentifier") as! SavingPlanCostTableViewCell
        cell2.costTextField.text = " 0"
        
        let cell3 = tblView.dequeueReusableCellWithIdentifier("SavingPlanSetDateIdentifier") as! SavingPlanDatePickerTableViewCell
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE dd/MM/yyyy"
        cell3.datePickerTextField.text = dateFormatter.stringFromDate(NSDate())
    }
    
    func getParameters() -> Dictionary<String,AnyObject>
    {
        var parameterDict : Dictionary<String,AnyObject> = [:]
        
        
        if(itemDetailsDataDict["title"] != nil)
        {
            parameterDict["title"] = itemDetailsDataDict["title"]
        }
        else{
            let cell1 = tblView.dequeueReusableCellWithIdentifier("SavingPlanTitleIdentifier") as! SavingPlanTitleTableViewCell
            parameterDict["title"] = cell1.titleTextField.text
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
            let cell2 = tblView.dequeueReusableCellWithIdentifier("SavingPlanCostIdentifier") as! SavingPlanCostTableViewCell
            parameterDict["amount"] = cell2.costTextField.text
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
                parameterDict["imageURL"] = nil
            }
        }
        
        let cell3 = tblView.dequeueReusableCellWithIdentifier("SavingPlanDatePickerIdentifier") as! SavingPlanDatePickerTableViewCell
        let dateParameter = NSDateFormatter()
        dateParameter.dateFormat = "yyyy-mm-dd"
        var pathComponents : NSArray!
        
        pathComponents = (cell3.datePickerTextField.text)!.componentsSeparatedByString(" ")
        var dateStr = pathComponents.lastObject as! String
        
        dateStr = dateStr.stringByReplacingOccurrencesOfString("/", withString: "-")
        
        var pathComponents2 : NSArray!
        pathComponents2 = dateStr.componentsSeparatedByString("-")
        
        parameterDict["payDate"] = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String);
        
        parameterDict["wishList_ID"] = itemDetailsDataDict["id"]
        
        parameterDict["pty_id"] = userInfoDict["partyId"]
        
        parameterDict["payType"] = userInfoDict["cxvxc"]
        
        if((imageDataDict["sav-id"]) != nil)
        {
            parameterDict["sav_id"] = imageDataDict["sav-id"]
        }
        else
        {
            parameterDict["sav_id"] = itemDetailsDataDict["sav-id"]
        }
        
        return parameterDict
        
    }
    
    func nextButtonPressed(sender:UIButton)
    {
        if(self.getParameters()["title"] != nil && self.getParameters()["amount"] != nil && self.getParameters()["imageURL"] != nil)
        {
            objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            objAnimView.animate()
            self.view.addSubview(objAnimView)
            
            
            let objAPI = API()
            objAPI.partySavingPlanDelegate = self
            if(itemDetailsDataDict["title"] == nil)
            {
                objAPI .createPartySavingPlan(self.getParameters(),isFromWishList: "notFromWishList")
            }
            else
            {
                var newDict : Dictionary<String,AnyObject> = [:]
                newDict["wishList_ID"] = self.getParameters()["wishList_ID"]
                newDict["sav_id"] = self.getParameters()["sav_id"]
                newDict["payType"] = self.getParameters()["payType"]
                newDict["payDate"] = self.getParameters()["payDate"]
                newDict["user_ID"] = self.getParameters()["pty_id"]
                objAPI .createPartySavingPlan(newDict,isFromWishList: "FromWishList")
            }
            
        }
        else
        {
            let alert = UIAlertView(title: "Warning", message: "Please enter title,price and date", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func closeOfferButtonPressed(sender:UIButton)
    {
        offerCount = offerCount - 1
        tblView.reloadData()
    }
    func setDayDateButtonButtonPressed(sender:UIButton)
    {
        if(cost != 0 && dateDiff != 0)
        {
            let cell = sender.superview?.superview as? SetDayTableViewCell
            //let indexPath = tblView.indexPathForCell(cell)
            //tblView.scrollToRowAtIndexPath(indexPath!, atScrollPosition: .Top, animated: true)
            
            let objPopOverView = SAPopOverViewController(nibName: "SAPopOverViewController",bundle: nil)
            if(cell?.dayDateLabel.text == "day") {
                objPopOverView.setArrayString = "day"
                dateString = "day"
            }
            else {
                objPopOverView.setArrayString = "date"
                dateString = "date"
            }
            
            objPopOverView.popOverDelegate = self
            
            objPopOverView.modalPresentationStyle = UIModalPresentationStyle.Popover
            objPopOverView.popoverPresentationController?.delegate = self
            objPopOverView.popoverPresentationController?.sourceView = sender
            objPopOverView.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Up
            objPopOverView.preferredContentSize = CGSizeMake(60, 80)
            objPopOverView.popoverPresentationController?.sourceRect = CGRectMake(0, -70, 53, 90)
            self.presentViewController(objPopOverView, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertView(title: "Warning", message: "Please select cost and date first", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func popOverValueChanged(value: String) {
        
        isPopoverValueChanged = true
        if(dateString == "day")
        {
            print(dateDiff/168)
        }
        else{
            
            print((dateDiff/168)/4)
        }
        popOverSelectedStr = value
        tblView.reloadData()
        
    }
    
    
    func txtFieldCellText(txtFldCell: SavingPlanCostTableViewCell) {
        cost = Int(txtFldCell.slider.value)
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
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
        else if(indexPath.section == offerCount+5)
        {
            return 65
        }
        else if(indexPath.section == offerCount+6){
            return 44
        }
        else {
            return 60
        }
        
    }
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker .dismissViewControllerAnimated(true, completion: nil)
        topBackgroundImageView?.image = (info[UIImagePickerControllerOriginalImage] as? UIImage)
        cameraButton.hidden = true
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: PartySavingplan methods
    
    func successResponseForPartySavingPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        objAnimView.removeFromSuperview()
        let alert = UIAlertView(title: "Alert", message: "Your saving plan is created successfully", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        
        let objSummaryView = SASavingSummaryViewController()
        objSummaryView.itemDataDict =  self.getParameters()
        self.navigationController?.pushViewController(objSummaryView, animated: true)
        
        
    }
    
    func errorResponseForPartySavingPlanAPI(error: String) {
        print(error)
        objAnimView.removeFromSuperview()
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}
