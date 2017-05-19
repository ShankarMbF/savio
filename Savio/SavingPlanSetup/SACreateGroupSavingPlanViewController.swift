//
//  SACreateGroupSavingPlanViewController.swift
//  Savio
//
//  Created by Maheshwari on 22/06/16.
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


protocol SACreateGroupSavingPlanDelegate {
    
    func clearAll()
}

class SACreateGroupSavingPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SegmentBarChangeDelegate, SAOfferListViewDelegate, PartySavingPlanDelegate, InviteMembersDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, STPAddCardViewControllerDelegate,AddSavingCardDelegate {
    
    @IBOutlet weak var tblViewHt        : NSLayoutConstraint!
    @IBOutlet weak var tblView          : UITableView!
    @IBOutlet weak var addAPhotoLabel   : UILabel!
    @IBOutlet weak var cameraButton     : UIButton!
    @IBOutlet weak var topBgImageView   : UIImageView!
    @IBOutlet weak var scrlView         : UIScrollView!
    
    var tokenstripeID       : String = ""
    var participantsArr     : Array<Dictionary<String,AnyObject>> = []
    var cost                : Int = 0
    var parameterDict       : Dictionary<String,AnyObject> = [:]
    var dateDiff            : Int = 0
    var delegate            : SACreateGroupSavingPlanDelegate?
    var userInfoDict        : Dictionary<String,AnyObject> = [:]
    var offerArr            : Array<Dictionary<String,AnyObject>> = []
    var recurringAmount     : CGFloat = 0
    
    var nextButtonTrigger   = false
    var isClearPressed      = false
    var isDateChanged       = false
    var isOfferShow         = false
    var isImageClicked      = false
    
    var selectedStr         = ""
    var groupMemberCount    = 0
    var dateString          = kDate
    var objAnimView         = ImageViewAnimation()
    var imagePicker         = UIImagePickerController()
    
    var setDateforCell      = "SetDayTableViewCell"
    var planSetDateId       = "SavingPlanSetDateIdentifier"
    
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        self.title = "Plan setup"
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        tblView!.register(UINib(nibName: setDateforCell, bundle: nil), forCellReuseIdentifier: planSetDateId)
        tblView!.register(UINib(nibName: "CreateSavingPlanTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateSavingPlanTableViewCellIdentifier")
        tblView!.register(UINib(nibName: "GroupCalculationTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupCalculationCellIdentifier")
        tblView!.register(UINib(nibName: "ClearButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ClearButtonIdentifier")
        tblView!.register(UINib(nibName: "OfferTableViewCell", bundle: nil), forCellReuseIdentifier: "OfferTableViewCellIdentifier")
        dateDiff =  Int(parameterDict["dateDiff"] as! String)!
        participantsArr = parameterDict["participantsArr"] as! Array
        cost =  Int(parameterDict[kAmount] as! String)!
        let objAPI = API()
        userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        //        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        let dict = ["first_name":userInfoDict["first_name"]!,"email_id":userInfoDict["email"]!,"mobile_number":userInfoDict[kPhoneNumber]!] as Dictionary<String,AnyObject>
        participantsArr.append(dict)
        topBgImageView.contentMode = UIViewContentMode.scaleAspectFill
        topBgImageView.layer.masksToBounds = true
        dateString = kDate
        isDateChanged = true
        self.setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setUpView(){
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-back.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SACreateGroupSavingPlanViewController.backButtonClicked), for: .touchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.addTarget(self, action: #selector(SACreateGroupSavingPlanViewController.heartBtnClicked), for: .touchUpInside)
        
        if let str = UserDefaults.standard.object(forKey: "wishlistArray") as? Data  {
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>
            btnName.setTitle(String(format:"%d",wishListArray!.count), for: UIControlState())
            if(wishListArray?.count > 0) {
                
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), for: UIControlState())
                btnName.setTitleColor(UIColor.black, for: UIControlState())
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
            }
            
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        if (parameterDict[kImageURL] as! String != "" &&  parameterDict["isUpdate"]!.isEqual(to: "Yes")) {
            if let urlString = parameterDict[kImageURL] as? String {
                let data :Data = Data(base64Encoded: urlString, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
                topBgImageView.image = UIImage(data: data)
                cameraButton.isHidden = true
            }
        }
        else if let image = parameterDict[kImageURL] as? String {
            if(image == "") {
                self.cameraButton.isHidden = false
                topBgImageView.image = UIImage(named: "groupsave-setup-bg.png")
            }
            else {
                let data :Data = Data(base64Encoded: parameterDict[kImageURL] as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
                topBgImageView.image = UIImage(data: data)
                cameraButton.isHidden = true
            }
        }
        else {
            self.cameraButton.isHidden = false
            topBgImageView.image = UIImage(named: "groupsave-setup-bg.png")
        }
        
        if parameterDict["isUpdate"]!.isEqual(to: "Yes") {
            isDateChanged = true
        }
    }
    
    //Navigation bar button methods
    func backButtonClicked()
    {
        if isOfferShow == true && offerArr.count > 0 {
            let obj = SAOfferListViewController()
            obj.isComingProgress = false
            obj.delegate = self
            obj.addedOfferArr = offerArr
            if let savId = parameterDict["sav_id"] as? String {
                obj.savID = Int(savId) as! NSNumber
            }
            else if let savId = parameterDict["sav_id"] as? NSNumber {
                obj.savID = savId
            }
            self.navigationController?.pushViewController(obj, animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func heartBtnClicked(){
        if let str = UserDefaults.standard.object(forKey: "wishlistArray") as? Data  {
            let dataSave = UserDefaults.standard.object(forKey: "wishlistArray") as! Data
            let wishListArray = NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>
            //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
            if wishListArray!.count>0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")
            }
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
    //TableViewDelegate methods
    //return the number of sections in table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        if parameterDict["isUpdate"]!.isEqual(to: "Yes") {
            return offerArr.count + 3
        }
        else {
            return offerArr.count + 4
        }
    }
    
    //return the number of rows in each section in table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //create custom cell from their respective Identifiers.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if(indexPath.section == 0) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: planSetDateId, for: indexPath) as! SetDayTableViewCell
            cell1.tblView = tblView
            cell1.view = self.scrlView
            cell1.segmentDelegate = self
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if parameterDict["isUpdate"]!.isEqual(to: "Yes") {
                if let payType = parameterDict["payType"] as? NSString {
                    if(payType as String == kWeek) {
                        let button = UIButton()
                        button.tag = 0
                        cell1.segmentBar.toggleButton(button)
                    }
                }
                else{
                    if dateString == "" {
                        dateString = kDate
                    }
                    cell1.dayDateLabel.text = dateString
                    
                }
                if let payDate = parameterDict["payDate"] as? String {
                    cell1.dayDateTextField.text = payDate
                }
                else{
                    //if date not available
                    if selectedStr == "" {
                        let str = "1"
                        selectedStr = str
                    }
                    cell1.dayDateTextField.attributedText =  self.createXLabelText(1, text: selectedStr)
                }
            }
            else {
                
                if(selectedStr != "") {
                    if(dateString == kDay) {
                        cell1.dayDateTextField.text = self.selectedStr
                    }
                    else {
                        cell1.dayDateTextField.attributedText = self.createXLabelText(Int(self.selectedStr)!, text: self.selectedStr)
                    }
                }
                else {
                    //                    cell1.dayDateTextField.text = ""
                    let str = "1"
                    selectedStr = str
                    cell1.dayDateTextField.attributedText =  self.createXLabelText(1, text: str)
                }
                
                
                
                if(isClearPressed) {
                    cell1.dayDateTextField.text = ""
                }
                
            }
            return cell1
        }
        else if(indexPath.section == 1) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "GroupCalculationCellIdentifier", for: indexPath) as! GroupCalculationTableViewCell
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if(isDateChanged) {
                if parameterDict["isUpdate"]!.isEqual(to: "Yes")
                {
                    cell1.percentageCalculationLabel.text = String(format: "The plan is split equally between everyone. You have %.2f%% of the plan which is £%d of the total goal of £%d",round(CGFloat(100)/CGFloat(groupMemberCount)),cost/(groupMemberCount),cost)
                    
                    if(dateString == kDay) {
                        if((dateDiff/168) == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per week for %d week",round(CGFloat(cost)/CGFloat(groupMemberCount))/CGFloat(dateDiff/168),(dateDiff/168))
                            recurringAmount = round(CGFloat(cost)/CGFloat(groupMemberCount))
                        }
                        else if ((dateDiff/168) == 0) {
                            //                            cell1.calculationLabel.text = "You will need to top up £0 per week for 0 week"
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per week for %d week",round(CGFloat(cost)/CGFloat(participantsArr.count)),(dateDiff/168))
                            recurringAmount = round(CGFloat(cost)/CGFloat(participantsArr.count))
                        }
                        else {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per week for %d weeks",round(CGFloat(cost)/CGFloat((groupMemberCount))/CGFloat(dateDiff/168)),(dateDiff/168))
                            recurringAmount = round(CGFloat(cost)/CGFloat((groupMemberCount))/CGFloat(dateDiff/168))
                        }
                    }
                    else {
                        if((dateDiff/168)/4 == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per month for %d month",round((CGFloat(cost)/CGFloat(groupMemberCount)/CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                            recurringAmount = round((CGFloat(cost)/CGFloat(groupMemberCount)/CGFloat((dateDiff/168)/4)))
                        }
                        else if ((dateDiff/168)/4 == 0) {
                            //                            cell1.calculationLabel.text = "You will need to top up £0 per month for 0 month"
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per month for %d months",round((CGFloat(cost)/CGFloat(participantsArr.count))),(dateDiff/168)/4)
                            recurringAmount = round((CGFloat(cost)/CGFloat(participantsArr.count)))
                        }
                        else {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per month for %d months",round((CGFloat(cost)/CGFloat((groupMemberCount ))/CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                            recurringAmount = round((CGFloat(cost)/CGFloat((groupMemberCount ))/CGFloat((dateDiff/168)/4)))
                        }
                    }
                    
                    
                }else {
                    
                    cell1.percentageCalculationLabel.text = String(format: "The plan is split equally between everyone. You have %.2f%% of the plan which is £%d of the total goal of £%d",round(CGFloat(100)/CGFloat(participantsArr.count)),cost/(participantsArr.count),cost)
                    if(dateString == kDay) {
                        if((dateDiff/168) == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per week for %d week",round(CGFloat(cost)/CGFloat(participantsArr.count))/CGFloat(dateDiff/168),(dateDiff/168))
                            recurringAmount = round(CGFloat(cost)/CGFloat(participantsArr.count))/CGFloat(dateDiff/168)
                        }
                        else if ((dateDiff/168) == 0) {
                            //                            cell1.calculationLabel.text = "You will need to top up £0 per week for 0 week"
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per week for %d week",round(CGFloat(cost)/CGFloat(participantsArr.count)),(dateDiff/168))
                            recurringAmount = round(CGFloat(cost)/CGFloat(participantsArr.count))
                        }
                        else {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per week for %d weeks",round(CGFloat(cost)/CGFloat((participantsArr.count))/CGFloat(dateDiff/168)),(dateDiff/168))
                            recurringAmount = round(CGFloat(cost)/CGFloat((participantsArr.count))/CGFloat(dateDiff/168))
                        }
                    }
                    else {
                        if((dateDiff/168)/4 == 1) {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per month for %d month",round((CGFloat(cost)/CGFloat(participantsArr.count)/CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                            recurringAmount = round((CGFloat(cost)/CGFloat(participantsArr.count)/CGFloat((dateDiff/168)/4)))
                        }
                        else if ((dateDiff/168)/4 == 0) {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per month for %d months",round((CGFloat(cost)/CGFloat(participantsArr.count))),(dateDiff/168)/4)
                            recurringAmount = round((CGFloat(cost)/CGFloat(participantsArr.count)))
                        }
                        else {
                            cell1.calculationLabel.text = String(format: "You will need to top up £%.2f per month for %d months",round((CGFloat(cost)/CGFloat((participantsArr.count ))/CGFloat((dateDiff/168)/4))),(dateDiff/168)/4)
                            recurringAmount = round((CGFloat(cost)/CGFloat((participantsArr.count ))/CGFloat((dateDiff/168)/4)))
                        }
                    
                    }
                    
                }
            }
            
            if(isClearPressed) {
                cell1.calculationLabel.text = ""
            }
            return cell1
        }
        else if(indexPath.section == offerArr.count+2) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "CreateSavingPlanTableViewCellIdentifier", for: indexPath) as! CreateSavingPlanTableViewCell
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if parameterDict["isUpdate"]!.isEqual(to: "Yes") {
                cell1.createSavingPlanButton.setTitle("Join group", for: UIControlState())
                cell1.createSavingPlanButton.addTarget(self, action: #selector(SACreateGroupSavingPlanViewController.joinGroupButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            }
            else {
                cell1.createSavingPlanButton.addTarget(self, action: #selector(SACreateGroupSavingPlanViewController.createSavingPlanButtonPressed), for: UIControlEvents.touchUpInside)
            }
            return cell1
        }
        else if(indexPath.section == offerArr.count+3) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "ClearButtonIdentifier", for: indexPath) as! ClearButtonTableViewCell
            cell1.tblView = tblView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            cell1.clearButton.addTarget(self, action: #selector(SACreateGroupSavingPlanViewController.clearButtonPressed), for: UIControlEvents.touchUpInside)
            return cell1
        }
        else {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "OfferTableViewCellIdentifier", for: indexPath) as! OfferTableViewCell
            cell1.tblView = tblView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            cell1.closeButton.tag = indexPath.section
            cell1.closeButton.addTarget(self, action: #selector(SACreateGroupSavingPlanViewController.closeOfferButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            let dict = offerArr[indexPath.section - 2]
            cell1.offerTitleLabel.text = dict["offCompanyName"] as? String
            cell1.offerDetailLabel.text = dict["offTitle"] as? String
            cell1.descriptionLabel.text = dict["offSummary"] as? String
            let urlStr = dict["offImage"] as! String
            let str = urlStr.replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: str)
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0) {
            return 64
        }
        else if(indexPath.section == offerArr.count+2) {
            return 65
        }
        else if(indexPath.section == offerArr.count+3) {
            return 40
        }
        else if(indexPath.section == 1) {
            if(isDateChanged) {
                return 100
            }
            else {
                return 0
            }
        }
        else {
            return 60
        }
    }
    
    
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
    
    func getDateTextField(_ str: String) {
        print(str)
        selectedStr = str
        isDateChanged = true
        isClearPressed = false
        tblView.reloadData()
    }
    
    func segmentBarChanged(_ str: String) {
        if(str == kDate) {
            dateString = kDate
        }
        else {
            dateString = kDay
        }
        isDateChanged = true
        tblView.reloadData()
    }
    
    func closeOfferButtonPressed(_ sender:UIButton)
    {
        let indx = sender.tag - 2
        offerArr.remove(at: indx)
        tblViewHt.constant =  tblView.frame.size.height - 65
        self.scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: self.tblView.frame.origin.y + self.tblView.frame.size.height)
        tblView.reloadData()
    }
    
    func displayAlert(_ message:String)
    {
        //Show of UIAlertView
        let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    //Dictionary to join the Group plan.
    func getParametersForUpdate() -> Dictionary<String,AnyObject>
    {
        var newDict : Dictionary<String,AnyObject> = [:]
        if parameterDict["isUpdate"]!.isEqual(to: "No") {
            newDict[kINIVITEDUSERLIST] = participantsArr as AnyObject
        }
        newDict[kPLANENDDATE] = parameterDict[kPLANENDDATE]
        newDict[kTITLE] = parameterDict[kTitle]
        newDict[kAMOUNT] = parameterDict[kAmount]
        newDict[kPARTYID] = parameterDict["pty_id"]
        newDict["PARTY_SAVINGPLAN_ID"] = parameterDict["sharedPtySavingPlanId"]
        if (parameterDict[kImageURL] != nil) {
            if(parameterDict[kImageURL] as! String != "")  {
                let imageData:Data = UIImageJPEGRepresentation(topBgImageView.image!, 1.0)!
                let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                let dict = ["imageName.jpg":base64String]
                newDict[kIMAGE] = dict as AnyObject
            }
            else  {
                let dict = ["imageName.jpg":""]
                newDict[kIMAGE] = dict as AnyObject
            }
        }
        newDict[kSAVPLANID] = UserDefaults.standard.object(forKey: "savPlanID") as AnyObject
        newDict["WISHLIST_ID"] = parameterDict["wishList_ID"] as! NSNumber
        newDict[kPAYDATE] = selectedStr as AnyObject
        if(dateString == kDate) {
            newDict[kPAYTYPE] = kMonth as AnyObject
        }
        else {
            newDict[kPAYTYPE] = kWeek as AnyObject
        }
        newDict[kPARTYSAVINGPLANTYPE] = "Group" as AnyObject
        newDict["STATUS"] = "Active" as AnyObject
        var newOfferArray : Array<NSNumber> = []
        if offerArr.count>0 {
            for i in 0 ..< offerArr.count {
                let dict = offerArr[i]
                newOfferArray.append(dict["offId"] as! NSNumber)
            }
            newDict[kOFFERS] = newOfferArray as AnyObject
        }
        else {
            newDict[kOFFERS] = newOfferArray as AnyObject
        }
        
        newDict[kRECURRINGAMOUNT] = String(format: "%.f", recurringAmount) as AnyObject
        return newDict
    }
    
    //Dictionary to send to the CreatePartySavingPlan API.
    func getParameters() -> Dictionary<String,AnyObject>
    {
        var newDict : Dictionary<String,AnyObject> = [:]
        newDict[kPLANENDDATE] = parameterDict[kPLANENDDATE]
        newDict[kTITLE] = parameterDict[kTitle]
        newDict[kAMOUNT] = parameterDict[kAmount]
        newDict[kPARTYID] = parameterDict["pty_id"]
        newDict[kSAVPLANID] = parameterDict["sav_id"]
        if(parameterDict[kImageURL] as! String != "") {
            let dict = ["imageName.jpg":parameterDict[kImageURL] as! String]
            newDict[kIMAGE] = dict as AnyObject
        }
        else if(isImageClicked) {
            let imageData:Data = UIImageJPEGRepresentation(topBgImageView.image!, 1.0)!
            let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let dict = ["imageName.jpg":base64String]
            newDict[kIMAGE] = dict as AnyObject
        }
        else {
            let dict = ["imageName.jpg":""]
            newDict[kIMAGE] = dict as AnyObject
        }
        newDict[kPAYDATE] = selectedStr as String as AnyObject
        if(dateString == kDate) {
            newDict[kPAYTYPE] = kMonth as AnyObject
        }
        else {
            newDict[kPAYTYPE] = kWeek as AnyObject
        }
        var newOfferArray : Array<NSNumber> = []
        if offerArr.count>0 {
            for i in 0 ..< offerArr.count {
                let dict = offerArr[i]
                newOfferArray.append(dict["offId"] as! NSNumber)
            }
            newDict[kOFFERS] = newOfferArray as AnyObject
        }
        else {
            newDict[kOFFERS] = newOfferArray as AnyObject
        }
        newDict[kPARTYSAVINGPLANTYPE] = "Group" as AnyObject
        newDict["STATUS"] = "Active" as AnyObject
        newDict[kRECURRINGAMOUNT] = String(format: "%.f", recurringAmount) as AnyObject
        print(newDict)
        return newDict
    }
    
    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        //Open camera or gallery as per users choice
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default)
        { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            })
        alertController.addAction(UIAlertAction(title: "Choose Photo", style: UIAlertActionStyle.default)
        { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertView(title: "Warning", message: "No camera available", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func createSavingPlanButtonPressed()
    {
        if isOfferShow == true {
            
            if nextButtonTrigger == true {
                nextButtonTrigger = false
                return
            }
            
            self.objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.navigationController!.view.addSubview(self.objAnimView)
            if(selectedStr != "")  {
                
                nextButtonTrigger = true
                let objAPI = API()
                objAPI.partySavingPlanDelegate = self
                objAPI.createPartySavingPlan(self.getParameters(),isFromWishList: "notFromWishList")
            }
            else {
                self.objAnimView.removeFromSuperview()
                self.displayAlert("Please select date/day")
            }
        }
        else {
            let obj = SAOfferListViewController()
            obj.delegate = self
            obj.addedOfferArr = offerArr
            obj.isComingProgress = false
            if let savId = parameterDict["sav_id"] as? String {
                obj.savID = Int(savId) as! NSNumber
            }
            else if let savId = parameterDict["sav_id"] as? NSNumber {
                obj.savID = savId
            }
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    func clearButtonPressed()
    {
        let alert = UIAlertController(title: "Are you sure?", message: "This will clear the information entered and start again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default)
        { action -> Void in
            UserDefaults.standard.removeObject(forKey: "InviteGroupArray")
            UserDefaults.standard.synchronize()
            self.navigationController?.popViewController(animated: true)
            self.delegate?.clearAll()
            })
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func joinGroupButtonPressed(_ sender:UIButton)
    {
        if isOfferShow == true {
            
            if nextButtonTrigger == true {
                nextButtonTrigger = false
                return
            }
            
            self.objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.navigationController!.view.addSubview(self.objAnimView)
            if(isDateChanged) {
                let objAPI = API()
                objAPI.partySavingPlanDelegate = self
                
                nextButtonTrigger = true
                objAPI .createPartySavingPlan(self.getParametersForUpdate(),isFromWishList: "FromWishList")
            }
            else {
                self.objAnimView.removeFromSuperview()
                self.displayAlert("Please select date/day")
                nextButtonTrigger = false

            }
        }
        else {
            let obj = SAOfferListViewController()
            obj.delegate = self
            obj.isComingProgress = false
            obj.addedOfferArr = offerArr
            if let savId = parameterDict["sav_id"] as? String {
                obj.savID = Int(savId) as! NSNumber
            }
            else if let savId = parameterDict["sav_id"] as? NSNumber {
                obj.savID = savId
            }
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    func addedOffers(_ offerForSaveArr:Dictionary<String,AnyObject>){
        offerArr.append(offerForSaveArr)
        tblViewHt.constant = tblView.frame.size.height + 65
        self.scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: self.tblView.frame.origin.y + self.tblView.frame.size.height)
        tblView.reloadData()
        isOfferShow = true
    }
    
    func skipOffers(){
        isOfferShow = true
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
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict[kPartyID] as! NSNumber,"STRIPE_TOKEN":(token.stripeID as AnyObject),kPTYSAVINGPLANID:UserDefaults.standard.value(forKey: kPTYSAVINGPLANID) as! NSNumber]
        print(dict)
        objAPI.addSavingCardDelegate = self
        objAPI.addSavingCard(dict)
        
        //Use token for backend process
        self.dismiss(animated: true, completion: {
            completion(nil)
        })
        
        print("+++++++++++++++++++++++++++++++")
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        objAnimView.animate()
        self.view.addSubview(objAnimView)
    }
    
    
    
    //Delegate methods of create group saving plan
    func successResponseForPartySavingPlanAPI(_ objResponse:Dictionary<String,AnyObject>)
    {
        print(objResponse)
        if(parameterDict["isUpdate"]!.isEqual(to: "Yes")) {
            if let message = objResponse["message"] as? String {
                if(message == "Party Saving Plan is succesfully added") {
                    UserDefaults.standard.setValue(objResponse["partySavingPlanID"] as? NSNumber, forKey: kPTYSAVINGPLANID)
                    UserDefaults.standard.setValue(kGroupMemberPlan, forKey: "usersPlan")
                    UserDefaults.standard.synchronize()
                    let objAPI = API()
                    //                    if let _ =  objAPI.getValueFromKeychainOfKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
                    //                    {
                    //                        let objSavedCardView = SASaveCardViewController()
                    //                        objSavedCardView.isFromGroupMemberPlan = true
                    //                        self.navigationController?.pushViewController(objSavedCardView, animated: true)
                    //                    }
                    //                    else{
                    //                        let objPaymentView = SAPaymentFlowViewController()
                    //                        objPaymentView.isFromGroupMemberPlan = true
                    //                        self.navigationController?.pushViewController(objPaymentView, animated: true)
                    //                    }
                    
                    if let _ = UserDefaults.standard.object(forKey: "saveCardArray") {
                        let objSavedCardView = SASaveCardViewController()
                        objSavedCardView.isFromGroupMemberPlan = true
                        self.navigationController?.pushViewController(objSavedCardView, animated: true)
                    }
                    else{
                        /*let objPaymentView = SAPaymentFlowViewController()
                         objPaymentView.isFromGroupMemberPlan = true
                         self.navigationController?.pushViewController(objPaymentView, animated: true)*/
                        self.StripeSDK()
                    }
                }
                else {
                    let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                    alert.show()
                }
            }
            else if let userMessage = objResponse["userMessage"] as? String{
                let alert = UIAlertView(title: "Alert", message: userMessage, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else {
                let alert = UIAlertView(title: "Alert", message: objResponse["error"] as? String, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
                
            }
            objAnimView.removeFromSuperview()
        }
        else {
            if let message = objResponse["errorCode"] as? String {
                if(message == "200") {
                    participantsArr.removeLast()
                    var dict : Dictionary<String,AnyObject> = [:]
                    dict[kINIVITEDUSERLIST] = participantsArr as AnyObject
                    dict[kPARTYID] = parameterDict["pty_id"]
                    
                    UserDefaults.standard.setValue(objResponse["partySavingPlanID"] as? NSNumber, forKey: kPTYSAVINGPLANID)
                    UserDefaults.standard.setValue(kGroupPlan, forKey: "usersPlan")
                    UserDefaults.standard.synchronize()
                    
                    //                    print(dict)
                    
                    let objAPI = API()
                    objAPI.inviteMemberDelegate = self
                    objAPI.sendInviteMembersList(dict)
                    
                }
                else {
                    let alert = UIAlertView(title: "Warning", message: objResponse["userMessage"] as! String, delegate: nil, cancelButtonTitle: "Ok")
                    alert.show()
                    objAnimView.removeFromSuperview()
                }
            }
            else {
                let alert = UIAlertView(title: "Warning", message: objResponse["error"] as! String, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
                objAnimView.removeFromSuperview()
            }
        }
        
    }
    
    func errorResponseForPartySavingPlanAPI(_ error:String) {
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        objAnimView.removeFromSuperview()
    }
    
    //Delegate methods of Invite members API
    
    func successResponseForInviteMembersAPI(_ objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if let message = objResponse["message"] as? String  {
            if(message == "Invited user successfully") {
                UserDefaults.standard.removeObject(forKey: "InviteGroupArray")
                var newDict : Dictionary<String,AnyObject> = [:]
                newDict[kTitle] = self.getParameters()[kTITLE]
                
                let amt = self.getParameters()[kAMOUNT] as! String
                let amount = Int(Int(amt)! / (participantsArr.count+1))
                newDict[kAmount] = String(format:"%d",amount) as AnyObject//self.getParameters()[kAMOUNT]
                newDict[kPAYDATE] = self.getParameters()[kPAYDATE]
                
                let dict = self.getParameters()[kIMAGE]
                newDict[kImageURL] = dict
                newDict[kINIVITEDUSERLIST] = participantsArr as AnyObject
                newDict[kDay] = dateString as AnyObject
                
                let dateParameter = DateFormatter()
                dateParameter.dateFormat = "yyyy-MM-dd"
                newDict[kPLANENDDATE] = self.getParameters()[kPLANENDDATE]
                
                if(dateString == kDay) {
                    if (dateDiff/168) > 0 {
                        newDict[kEmi] = String(format:"%d",(cost/(participantsArr.count + 1))/(dateDiff/168)) as AnyObject
                    }
                    else{
                        newDict[kEmi] = String(format:"%d",(cost/(participantsArr.count + 1))) as AnyObject
                    }
                    newDict["payType"] = "Weekly" as AnyObject
                }
                else {
                    if ((dateDiff/168)/4) > 0 {
                        newDict[kEmi] = String(format:"%d",(cost/(participantsArr.count + 1))/((dateDiff/168)/4)) as AnyObject
                    }
                    else{
                        newDict[kEmi] = String(format:"%d",(cost/(participantsArr.count + 1))) as AnyObject
                    }
                    newDict["payType"] = "Monthly" as AnyObject
                }
                
                if offerArr.count>0 {
                    newDict["offers"] = offerArr as AnyObject
                }
                
                if(dateString == kDay) {
                    if (dateDiff/168) > 0{
                        newDict[kEmi] = String(format:"%d",(cost/(participantsArr.count + 1))/(dateDiff/168)) as AnyObject
                    }
                    else{
                        newDict[kEmi] = String(format:"%d",(cost/(participantsArr.count + 1))) as AnyObject
                    }
                }
                else {
                    if ((dateDiff/168)/4) > 0{
                        newDict[kEmi] = String(format:"%d",(cost/(participantsArr.count + 1))/((dateDiff/168)/4)) as AnyObject
                    }
                    else{
                        newDict[kEmi] = String(format:"%d",(cost/(participantsArr.count + 1))) as AnyObject
                    }
                }
                
                newDict[kEmi] = String(format:"%.f",recurringAmount) as AnyObject
                newDict["planType"] = "group" as AnyObject
                
                let objAPI = API()
                //                NSUserDefaults.standardUserDefaults().setObject(self.checkNullDataFromDict(newDict), forKey: "savingPlanDict")
                //                NSUserDefaults.standardUserDefaults().synchronize()
                objAPI.storeValueInKeychainForKey("savingPlanDict", value: self.checkNullDataFromDict(newDict) as AnyObject)
                
                //                if let saveCardArray =  objAPI.getValueFromKeychainOfKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
                //                {
                //                    let objSavedCardView = SASaveCardViewController()
                //                    objSavedCardView.isFromSavingPlan = true
                //                    self.navigationController?.pushViewController(objSavedCardView, animated: true)
                //
                //                }else {
                //                    let objPaymentView = SAPaymentFlowViewController()
                //                    self.navigationController?.pushViewController(objPaymentView, animated: true)
                //                }
                
                if let _ = UserDefaults.standard.object(forKey: "saveCardArray")
                {
                    let objSavedCardView = SASaveCardViewController()
                    objSavedCardView.isFromSavingPlan = true
                    self.navigationController?.pushViewController(objSavedCardView, animated: true)
                    
                }else {
                    self.StripeSDK()
                }
            }
        }
        objAnimView.removeFromSuperview()
    }
    
    func errorResponseForInviteMembersAPI(_ error: String) {
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: "Warning", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        objAnimView.removeFromSuperview()
    }
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker .dismiss(animated: true, completion: nil)
        topBgImageView.contentMode = UIViewContentMode.scaleAspectFill
        topBgImageView.layer.masksToBounds = true
        topBgImageView?.image = (info[UIImagePickerControllerEditedImage] as? UIImage)
        cameraButton.isHidden = true
        isImageClicked = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker .dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.removeObject(forKey: "InviteGroupArray")
        UserDefaults.standard.synchronize()
    }
    
    
    func successResponseForAddSavingCardDelegateAPI(_ objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String{
            if(message == "Successful")
            {
                if(objResponse["stripeCustomerStatusMessage"] as? String == "Customer Card detail Added Succeesfully")
                {
                    UserDefaults.standard.set(1, forKey: "saveCardArray")
                    UserDefaults.standard.synchronize()
                    objAnimView.removeFromSuperview()
                    let objSummaryView = SASavingSummaryViewController()
                    self.navigationController?.pushViewController(objSummaryView, animated: true)
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
