//
//  GroupsavingViewController.swift
//  Savio
//
//  Created by Maheshwari on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class GroupsavingViewController: UIViewController,SavingPlanTitleTableViewCellDelegate,SavingPlanCostTableViewCellDelegate,SavingPlanDatePickerCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var topBackgroundImageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    
    @IBOutlet weak var tblViewHt: NSLayoutConstraint!
    var cost : Int = 0
    var imageDataDict : Dictionary<String,AnyObject> = [:]
    var dateDiff : Int = 0
    var dateString = "date"
    var popOverSelectedStr = ""
    var datePickerDate : String = ""
    var itemTitle : String = ""
    var itemDetailsDataDict : Dictionary<String,AnyObject> = [:]
    var participantsArr: Array<String> = []
    var userInfoDict  = Dictionary<String,AnyObject>()
    var  objAnimView = ImageViewAnimation()
    var isClearPressed = false
    
    @IBOutlet weak var scrlView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.title = "Savings plan setup"
        let font = UIFont(name: "GothamRounded-Book", size: 15)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font!]
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        tblView!.registerNib(UINib(nibName: "SavingPlanTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanTitleIdentifier")
        tblView!.registerNib(UINib(nibName: "SavingPlanCostTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanCostIdentifier")
        tblView!.registerNib(UINib(nibName: "SavingPlanDatePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanDatePickerIdentifier")
        tblView!.registerNib(UINib(nibName: "SavingPlanDatePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanDatePickerIdentifier")
        tblView!.registerNib(UINib(nibName: "InviteFriendsButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "InviteFriendsButtonCellIdentifier")
        tblView!.registerNib(UINib(nibName: "GroupParticipantNameTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupParticipantNameTableViewCellIdentifier")
        tblView!.registerNib(UINib(nibName: "NextButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "NextButtonCellIdentifier")
        tblView!.registerNib(UINib(nibName: "ClearButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ClearButtonIdentifier")
        
        let objAPI = API()
        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        
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
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") != nil)
        {
            let wishListArray = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? Array<Dictionary<String,AnyObject>>
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
            savingPlanTitleLabel.hidden = true
            
        }
        else
        {
            imageDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
            self.cameraButton.hidden = false
             savingPlanTitleLabel.hidden = false
        }
        
        
        
    }
    
    
    
    func heartBtnClicked(){
        if  (NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") != nil) {
            
            let wishListArray = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? Array<Dictionary<String,AnyObject>>
            
            if wishListArray!.count>0{
                
                let objSAWishListViewController = SAWishListViewController()
                objSAWishListViewController.wishListArray = wishListArray!
                self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
            }
            else{
                let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        else{
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var ht : CGFloat = 0.0
        if(participantsArr.count == 0)
        {
            ht = 40 + CGFloat(participantsArr.count * 65)
        }
        else
        {
            ht = CGFloat(participantsArr.count * 65)
        }
        
        
        scrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, tblView.frame.origin.y + tblView.frame.size.height + ht)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
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
    // MARK: - UITableViewDelegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return  participantsArr.count + 6
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
                cell1.titleTextField.text = itemDetailsDataDict["title"] as? String
                
            }
            
            if(isClearPressed)
            {
                cell1.titleTextField.text = itemTitle
            }
            cell1.titleTextField.textColor = UIColor(red: 161/256, green: 214/256, blue: 248/256, alpha: 1.0)
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
            if(isClearPressed)
            {
                cell1.costTextField.text = "0"
                cell1.costTextField.textColor = UIColor.whiteColor()
                cell1.slider.value = 0
                cost = 0
            }
            return cell1
        }
        else if(indexPath.section == 2){
            let cell1 = tableView.dequeueReusableCellWithIdentifier("SavingPlanDatePickerIdentifier", forIndexPath: indexPath) as! SavingPlanDatePickerTableViewCell
            cell1.tblView = tblView
            cell1.savingPlanDatePickerDelegate = self
            cell1.view = self.view
            if(isClearPressed)
            {
                let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                let currentDate: NSDate = NSDate()
                let components: NSDateComponents = NSDateComponents()
                
                components.day = +7
                let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
                let dateFormatter = NSDateFormatter()
                
                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                
                cell1.datePickerTextField.text = dateFormatter.stringFromDate(minDate)
                
            }
            return cell1
        }
        else if(indexPath.section == 3)
        {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("InviteFriendsButtonCellIdentifier", forIndexPath: indexPath) as! InviteFriendsButtonTableViewCell
            cell1.inviteButton.addTarget(self, action: Selector("inviteButtonPressed"), forControlEvents: .TouchUpInside)
            return cell1
        }
        else if(indexPath.section == participantsArr.count + 4)
        {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("NextButtonCellIdentifier", forIndexPath: indexPath) as! NextButtonTableViewCell
            cell1.tblView = tblView
            cell1.nextButton.addTarget(self, action: Selector("nextButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
        else if(indexPath.section ==  participantsArr.count + 5)
        {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("ClearButtonIdentifier", forIndexPath: indexPath) as! ClearButtonTableViewCell
            cell1.tblView = tblView
            cell1.clearButton.addTarget(self, action: Selector("clearButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
            return cell1
        }
            
        else{
            let cell1 = tableView.dequeueReusableCellWithIdentifier("GroupParticipantNameTableViewCellIdentifier", forIndexPath: indexPath) as! GroupParticipantNameTableViewCell
            
            return cell1
        }
    }
    
    func inviteButtonPressed()
    {
        let alert = UIAlertView(title: "Work in progress", message: "", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
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
            
        else if(indexPath.section == 3)
        {
            return 118
        }
        else if(indexPath.section ==   participantsArr.count + 4)
        {
            return 65
        }
        else if(indexPath.section ==   participantsArr.count + 5)
        {
            return 40
        }
        else
        {
            if(participantsArr.count == 0)
            {
                return 0
            }
            else
            {
                return 24
            }
        }
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
                parameterDict["imageURL"] = nil
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
            
            parameterDict["payDate"] = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String);
        }
        
        parameterDict["wishList_ID"] = itemDetailsDataDict["id"]
        
        parameterDict["pty_id"] = userInfoDict["partyId"]
        
        parameterDict["payType"] = userInfoDict["cxvxc"]
        
        if((imageDataDict["sav-id"]) != nil)
        {
            parameterDict["sav_id"] = imageDataDict["savPlanID"]
        }
        else
        {
            parameterDict["sav_id"] = itemDetailsDataDict["sav-id"]
        }
        
        parameterDict["dateDiff"] = String(format:"%d",dateDiff)
        
        return parameterDict
        
    }
    
    
    func getTextFieldText(text: String) {
        itemTitle = text
        
    }
    
    
    func txtFieldCellText(txtFldCell: SavingPlanCostTableViewCell) {
        cost = Int(txtFldCell.slider.value)
    }
    func datePickerText(date: Int,dateStr:String) {
        print(date)
        dateDiff = date
        datePickerDate = dateStr
    }
    
    
    func nextButtonPressed(sender:UIButton)
    {
        if(self.getParameters()["title"] != nil && self.getParameters()["amount"] != nil && cost != 0 && dateDiff != 0 && datePickerDate != "" && self.getParameters()["imageURL"] != nil)
        {
        let objGroupSavingPlanView = SACreateGroupSavingPlanViewController(nibName: "SACreateGroupSavingPlanViewController",bundle: nil)
        objGroupSavingPlanView.parameterDict = self.getParameters()
        self.navigationController?.pushViewController(objGroupSavingPlanView, animated: true)
        }
        else
        {
            self.objAnimView.removeFromSuperview()
            
            if(self.getParameters()["title"] == nil  && cost != 0 && dateDiff != 0 &&  self.getParameters()["imageURL"] != nil)
            {
                self.displayAlert("Please enter title for your saving plan")
            }
            else if(cost == 0 && dateDiff != 0  && self.getParameters()["imageURL"] != nil)
            {
                self.displayAlert("Please enter amount for your saving plan")
            }
            else if( cost != 0 && dateDiff != 0   && self.getParameters()["imageURL"] != nil)
            {
                self.displayAlert("Please select date for your saving plan")
            }
            else if(cost != 0 && dateDiff == 0 && self.getParameters()["imageURL"] == nil)
            {
                self.displayAlert("Please select image for your saving plan")
            }
            else
            {
                self.displayAlert("Please enter all details")
            }

        }
    }
    
    
    func displayAlert(message:String)
    {
        let alert = UIAlertView(title: "Warning", message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    func clearButtonPressed()
    {
        
        let alert = UIAlertController(title: "Aru you sure?", message: "Do you want to clear all data", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default)
        { action -> Void in
            
            self.setUpView()
            self.dateDiff = 0
            self.cost = 0
            
            
            self.itemTitle = ""
            
            self.isClearPressed = true
            self.popOverSelectedStr = ""
            
            if(self.itemDetailsDataDict.keys.count > 0)
            {
                self.itemDetailsDataDict.removeAll()
            }
            
            self.topBackgroundImageView.image = UIImage(named:"groupsave-setup-bg.png")
            self.tblViewHt.constant = 500
            self.scrlView.contentOffset = CGPointMake(0, 20)
            self.scrlView.contentSize = CGSizeMake(0, self.tblView.frame.origin.y + self.tblViewHt.constant)
            self.tblView.reloadData()
            
            
            })
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        
    }
    
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker .dismissViewControllerAnimated(true, completion: nil)
        topBackgroundImageView.contentMode = UIViewContentMode.ScaleAspectFit
        topBackgroundImageView?.image = (info[UIImagePickerControllerOriginalImage] as? UIImage)
        savingPlanTitleLabel.hidden = true
        cameraButton.hidden = true
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
}
