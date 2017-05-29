 //
 //  GroupsavingViewController.swift
 //  Savio
 //
 //  Created by Maheshwari on 22/06/16.
 //  Copyright © 2016 Prashant. All rights reserved.
 //
 
 import UIKit
 import AddressBook
 import AddressBookUI
 
 class GroupsavingViewController: UIViewController,SavingPlanTitleTableViewCellDelegate,SavingPlanCostTableViewCellDelegate,SavingPlanDatePickerCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ABPeoplePickerNavigationControllerDelegate,SAContactViewDelegate,UITableViewDelegate,UITableViewDataSource,SACreateGroupSavingPlanDelegate {
    
    @IBOutlet weak var topBackgroundImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    @IBOutlet weak var contentViewHt: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tblViewHt: NSLayoutConstraint!
    @IBOutlet weak var scrlView: UIScrollView!
    
    var cost : Int = 0
    var imageDataDict : Dictionary<String,AnyObject> = [:]
    var dateDiff : Int = 0
    var dateString = kDate
    var popOverSelectedStr = ""
    var datePickerDate : String = ""
    var itemTitle : String = ""
    var itemDetailsDataDict : Dictionary<String,AnyObject> = [:]
    var participantsArr: Array<Dictionary<String,AnyObject>> = []
    var userInfoDict  : Dictionary<String,AnyObject> = [:]
    var objAnimView = ImageViewAnimation()
    var isClearPressed = false
    var addressBook: ABPeoplePickerNavigationController?
    var isFromWishList = false
    var isImageclicked = false
    var imagePicker = UIImagePickerController()
    var isContactAdded = false
    var groupArrayCount = 0
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "GothamRounded-Medium", size: 16)!]
        self.title = "Plan setup"
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        tblView!.register(UINib(nibName: "SavingPlanTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanTitleIdentifier")
        tblView!.register(UINib(nibName: "SavingPlanCostTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanCostIdentifier")
        tblView!.register(UINib(nibName: "SavingPlanDatePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanDatePickerIdentifier")
        tblView!.register(UINib(nibName: "SavingPlanDatePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "SavingPlanDatePickerIdentifier")
        tblView!.register(UINib(nibName: "InviteFriendsButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "InviteFriendsButtonCellIdentifier")
        tblView!.register(UINib(nibName: "GroupParticipantNameTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupParticipantNameTableViewCellIdentifier")
        tblView!.register(UINib(nibName: "NextButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "NextButtonCellIdentifier")
        tblView!.register(UINib(nibName: "ClearButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ClearButtonIdentifier")
        
        _ = API()
        userInfoDict = userDefaults.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
//        userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        
        let array =  userDefaults.object(forKey: "InviteGroupArray") as? Array<Dictionary<String,AnyObject>>
        if (array != nil) {
            userDefaults.removeObject(forKey: "InviteGroupArray")
            userDefaults.synchronize()
        }
        
        topBackgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        topBackgroundImageView.layer.masksToBounds = true
        
    }
    
    func setUpView(){
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-back.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(GroupsavingViewController.backButtonClicked), for: .touchUpInside)
        
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
        btnName.addTarget(self, action: #selector(GroupsavingViewController.heartBtnClicked), for: .touchUpInside)
        
        if let str = userDefaults.object(forKey: "wishlistArray") as? Data {
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>
            btnName.setTitle(String(format:"%d",wishListArray!.count), for: UIControlState())
            //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
            if(wishListArray!.count > 0) {
                
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
        
        //Get image for the saving plan
        if let urlString = itemDetailsDataDict[kImageURL] as? String {
            let url = URL(string:urlString)
            
            let request: URLRequest = URLRequest(url: url!)
            if(urlString != "") {
                
                //Add spinner to UIImageView until image loads
                let spinner =  UIActivityIndicatorView()
                spinner.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: topBackgroundImageView.frame.size.height/2)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
                topBackgroundImageView.addSubview(spinner)
                spinner.startAnimating()
                
                //load the image from URL
                
                let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                    print("Response: \(String(describing: response))")
                    
                    if((data?.count)! > 0) {
                        let image = UIImage(data: data!)
                        
                        DispatchQueue.main.async(execute: {
                            //Remove the spinner after image load
                            spinner.stopAnimating()
                            spinner.isHidden = true
                            self.cameraButton.isHidden = true
                            self.topBackgroundImageView.image = image
                        })
                    }
                    else {
                        //Remove the spinner after image load
                        spinner.stopAnimating()
                        spinner.isHidden = true
                    }
                })
                
                task.resume()
            }
            else {
                imageDataDict =  userDefaults.object(forKey: "colorDataDict") as! Dictionary<String,AnyObject>
                cameraButton.isHidden = false
                
            }
            isFromWishList = true
            itemTitle = itemDetailsDataDict[kTitle] as! String
            cost = Int(itemDetailsDataDict[kAmount] as! NSNumber)
            groupArrayCount = Int(itemDetailsDataDict["totalMembers"] as! NSNumber)
        }
        else {
            imageDataDict =  userDefaults.object(forKey: "colorDataDict") as! Dictionary<String,AnyObject>
            self.cameraButton.isHidden = false
            isFromWishList = false
        }
        let ht : CGFloat = 100
        scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: tblView.frame.origin.y + tblView.frame.size.height + ht)
        contentViewHt.constant = contentViewHt.constant + 35
        tblViewHt.constant = tblViewHt.constant + 35
        
    }
    
    //Navigation bar button action methods
    func backButtonClicked()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func heartBtnClicked(){
        if let str = userDefaults.object(forKey: "wishlistArray") as? Data {
            
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>
            
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        objAnimView.removeFromSuperview()
    }
    
    func clearAll() {
        self.setUpView()
        self.dateDiff = 0
        self.cost = 0
        userDefaults.removeObject(forKey: "InviteGroupArray")
        userDefaults.synchronize()
        self.itemTitle = ""
        self.isClearPressed = true
        self.popOverSelectedStr = ""
        if(participantsArr.count > 0) {
            participantsArr.removeAll()
        }
        if(self.itemDetailsDataDict.keys.count > 0) {
            self.itemDetailsDataDict.removeAll()
        }
        self.topBackgroundImageView.image = UIImage(named:"groupsave-setup-bg.png")
        self.tblViewHt.constant = 500
        self.scrlView.contentOffset = CGPoint(x: 0, y: 20)
        self.scrlView.contentSize = CGSize(width: 0, height: self.tblView.frame.origin.y + self.tblViewHt.constant)
        self.tblView.reloadData()
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        //Open camera or gallery as per users selection
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
    
    //MARK: - Addressbook integration
    func requestForAccess(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch ABAddressBookGetAuthorizationStatus(){
        case .authorized:
            completionHandler(true)
            /* Access the address book */
        case .notDetermined:
            var error: Unmanaged<CFError>?
            let addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
            ABAddressBookRequestAccessWithCompletion(addressBook,
                                                     {(granted: Bool, error: CFError!) in
                                                        completionHandler(granted)
            })
        default:
            completionHandler(false)
        }
    }
    
    func showAddressBook(){
        requestForAccess { (accessGranted) in
            if accessGranted {
                self.addressBook = ABPeoplePickerNavigationController()
                self.addressBook?.peoplePickerDelegate = self
                self.present(self.addressBook!, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Can't access contacts", message: "Please allow Savio access to Contacts in Settings to invite your friends", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func peoplePickerNavigationControllerDidCancel(_ peoplePicker: ABPeoplePickerNavigationController) {
        addressBook?.dismiss(animated: true, completion: nil)
    }
    
    func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, shouldContinueAfterSelectingPerson person: ABRecord) -> Bool {
        return true
    }
    
    func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        var contactDict: Dictionary<String,AnyObject> = [:]
        //Get person's last name
        
        if  (ABRecordCopyValue(person, kABPersonLastNameProperty) != nil){
            
            if  (ABRecordCopyValue(person, kABPersonFirstNameProperty) != nil){
                if let firstName: ABMultiValue = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue(){
                    contactDict["name"] = firstName as! String as AnyObject
                }
            }
            else {
                contactDict["name"] = "" as AnyObject
            }
            
            if let lastName: ABMultiValue = ABRecordCopyValue(person, kABPersonLastNameProperty).takeRetainedValue(){
                contactDict["lastName"] = lastName as! String as AnyObject
            }
        }
        else { //Get person's first name
            if  (ABRecordCopyValue(person, kABPersonFirstNameProperty) != nil){
                if let firstName: ABMultiValue = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue(){
                    contactDict["name"] = firstName as! String as AnyObject
                }
            }
            else {
                contactDict["name"] = "" as AnyObject
            }
            contactDict["lastName"] = "" as AnyObject
            
        }
        
        //Get Phone Number
        
        var phoneNumber:String?;
        let unmanagedPhones:Unmanaged? = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if(unmanagedPhones != nil) {
            let index = 0 as CFIndex
            let phoneNumbers = unmanagedPhones?.takeRetainedValue();
            
            if(ABMultiValueGetCount(phoneNumbers) > 0) {
                
                phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbers, index).takeRetainedValue() as? String;
                contactDict["mobileNum"] = phoneNumber as AnyObject
                print(contactDict)

            } else {
                phoneNumber = "Phone Number is empty!";
            }
        }
        
        //Get person's email id
        if (ABRecordCopyValue(person, kABPersonEmailProperty) != nil)  {
            let emails: ABMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
            if ABMultiValueGetCount(emails) > 0 {
                let index = 0 as CFIndex
                let emailAddress = ABMultiValueCopyValueAtIndex(emails, index).takeRetainedValue() as! String
                contactDict["email"] = emailAddress as AnyObject
            } else {
                print("No email address")
            }
        }
        
        var pic: UIImage?
        let picTemp1 = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)
        if picTemp1 == nil {
            pic = nil
        }
        else {
            let picTemp2: NSObject? = Unmanaged<NSObject>.fromOpaque(picTemp1!.toOpaque()).takeRetainedValue()
            if picTemp2 != nil {
                pic = UIImage(data: picTemp2! as! Data)!
                contactDict["imageData"] = pic
            }
        }
        
        let contactView = ContactViewController()
        contactView.delegate = self
        contactView.contactDict = contactDict
        self.navigationController?.pushViewController(contactView, animated: true)
    }
    
    //Add contact delegate methods
    func addedContact(_ contactDict: Dictionary<String, AnyObject>) {
        isContactAdded = true
        participantsArr.append(contactDict)
        userDefaults.set(participantsArr, forKey:"InviteGroupArray")
        userDefaults.synchronize()
        contentViewHt.constant = contentViewHt.constant + 40
        tblViewHt.constant = tblViewHt.constant + 40
        scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: tblView.frame.origin.y + tblView.frame.size.height + 40)
        tblView.reloadData()
        print(participantsArr)
    }
    
    func skipContact(){
        isContactAdded = true
    }
    
    // MARK: - UITableViewDelegate methods
    //return the number of sections in table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        if itemDetailsDataDict[kTitle] != nil {
            return 4
        } else {
            return 7
        }
    }
    
    //return the number of rows in each section in table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 4) {
            return participantsArr.count
        }
        else {
            return 1
        }
    }
    
    //create custom cell from their respective Identifiers.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if(indexPath.section == 0)  {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "SavingPlanTitleIdentifier", for: indexPath) as! SavingPlanTitleTableViewCell
            cell1.tblView = tblView
            cell1.view = self.scrlView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            cell1.savingPlanTitleDelegate = self
            if(itemDetailsDataDict[kTitle] != nil) {
                cell1.titleTextField.text = itemDetailsDataDict[kTitle] as? String
                cell1.titleTextField.isUserInteractionEnabled = false
                itemTitle = itemDetailsDataDict[kTitle] as! String
            }
            if(isClearPressed) {
                cell1.titleTextField.text = itemTitle
            }
            cell1.titleTextField.textColor = UIColor(red: 161/256, green: 214/256, blue: 248/256, alpha: 1.0)
            return cell1
        }
            
        else if(indexPath.section == 1){
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "SavingPlanCostIdentifier", for: indexPath) as! SavingPlanCostTableViewCell
            cell1.tblView = tblView
            cell1.delegate = self
            cell1.view = self.scrlView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            
            if(itemDetailsDataDict[kAmount] != nil)
            {
                if(itemDetailsDataDict[kAmount] is String)
                {
                    let amountString = "£" + String(describing: itemDetailsDataDict[kAmount])
                    
                    cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                    cell1.slider.value = (itemDetailsDataDict[kAmount] as! NSString).floatValue
                    cost = Int(cell1.slider.value)
                }
                else
                {
                    let amountString = "£" + String(format: "%d", (itemDetailsDataDict[kAmount] as! NSNumber).int32Value)
                    cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                    cell1.slider.value = (itemDetailsDataDict[kAmount] as! NSNumber).floatValue
                    cost = Int(cell1.slider.value)
                }
                cell1.costTextField.isUserInteractionEnabled = false
                cell1.slider.isUserInteractionEnabled = false
                cell1.minusButton.isUserInteractionEnabled = false
                cell1.plusButton.isUserInteractionEnabled = false
                cost = Int(cell1.slider.value)
            }
            else if( isContactAdded == true) {
                let amountString = "£" + String(format: "%d", cost)
                cell1.costTextField.attributedText = cell1.createAttributedString(amountString)
                cell1.slider.value =  Float(cost)
                cost = Int(cell1.slider.value)
            }
            else {
//                cell1.costTextField.attributedText = cell1.createAttributedString("£0")
//                cell1.slider.value = 0
//                cost = 0
            }
            if(isClearPressed || cost == 0)
            {
                isClearPressed = false
                cell1.costTextField.attributedText = cell1.createAttributedString("£0")
                cell1.slider.value = 0
                cost = 0
            }
            return cell1
        }
        else if(indexPath.section == 2) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "SavingPlanDatePickerIdentifier", for: indexPath) as! SavingPlanDatePickerTableViewCell
            cell1.tblView = tblView
            cell1.savingPlanDatePickerDelegate = self
            cell1.view = self.scrlView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            
            if(datePickerDate == "") {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
                var dateComponents = DateComponents()
                let calender = Calendar.current
                dateComponents.month = 3
                let newDate = (calender as NSCalendar).date(byAdding: dateComponents, to: Date(), options:NSCalendar.Options(rawValue: 0))
                datePickerDate = dateFormatter.string(from: newDate!)
                cell1.datePickerTextField.text = datePickerDate
                let timeDifference : TimeInterval = newDate!.timeIntervalSince(Date())
                dateDiff = Int(timeDifference/3600)                
                }
                else{
                cell1.datePickerTextField.text = datePickerDate
                cell1.datePickerTextField.textColor = UIColor.white

                }
            
            
            
            
            
//            if(itemDetailsDataDict["planEndDate"] != nil) {
//                if(itemDetailsDataDict["planEndDate"] != nil) {
//                cell1.datePickerTextField.text = itemDetailsDataDict["planEndDate"] as? String
//                cell1.datePickerTextField.textColor = UIColor.whiteColor()
//                cell1.datePickerTextField.userInteractionEnabled = false
//                let date  = itemDetailsDataDict["planEndDate"] as? String
//                let dateFormatter = NSDateFormatter()
////                dateFormatter.dateFormat = "dd-MM-yyyy"
//                dateFormatter.dateFormat = "yyyy-MM-dd"
//                let timeDifference : NSTimeInterval = dateFormatter.dateFromString(date!)!.timeIntervalSinceDate(NSDate())
//                datePickerDate = (itemDetailsDataDict["planEndDate"] as? String)!
//                dateDiff = Int(timeDifference/3600)
//                
//            }
//            else{
//                let dateFormatter = NSDateFormatter()
//                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
//                let dateComponents = NSDateComponents()
//                let calender = NSCalendar.currentCalendar()
//                dateComponents.month = 3
//                let newDate = calender.dateByAddingComponents(dateComponents, toDate: NSDate(), options:NSCalendarOptions(rawValue: 0))
//                datePickerDate = dateFormatter.stringFromDate(newDate!)
//                cell1.datePickerTextField.text = datePickerDate
//                let timeDifference : NSTimeInterval = newDate!.timeIntervalSinceDate(NSDate())
//                dateDiff = Int(timeDifference/3600)
//            }
            if cost > 0 {
                cell1.datePickerTextField.textColor = UIColor.white
            }
//            if(isClearPressed) {
//                let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
//                let currentDate: NSDate = NSDate()
//                let components: NSDateComponents = NSDateComponents()
//                components.day = +7
//                let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
//                let dateFormatter = NSDateFormatter()
//                dateFormatter.dateFormat = "EEE dd/MM/yyyy"
//                cell1.datePickerTextField.text = dateFormatter.stringFromDate(minDate)
//                
//            }
            return cell1
        }
        else if(indexPath.section == 3) {
            if(itemDetailsDataDict[kTitle] == nil) {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "InviteFriendsButtonCellIdentifier", for: indexPath) as! InviteFriendsButtonTableViewCell
                if(participantsArr.count == 0) {
                    cell1.layer.cornerRadius = 5
                    cell1.layer.masksToBounds = true
                }
                else {
                    cell1.layer.cornerRadius = 0
                    let maskPath: UIBezierPath = UIBezierPath(roundedRect: cell1.bounds, byRoundingCorners: ([.topLeft,.topRight]), cornerRadii: CGSize(width: 5.0, height: 5.0))
                    let maskLayer: CAShapeLayer = CAShapeLayer()
                    maskLayer.frame = cell1.bounds
                    maskLayer.path = maskPath.cgPath
                    cell1.layer.mask = maskLayer
                }
                if(itemDetailsDataDict[kTitle] != nil) {
                    cell1.inviteButton.isUserInteractionEnabled = false
                }
                cell1.inviteButton.addTarget(self, action: #selector(GroupsavingViewController.inviteButtonPressed), for: .touchUpInside)
                if(participantsArr.count > 0) {
                    cell1.bottomBorderLabel.isHidden = false
                }
                else {
                    cell1.bottomBorderLabel.isHidden = true
                }
                return cell1
            }
            else {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "NextButtonCellIdentifier", for: indexPath) as! NextButtonTableViewCell
                cell1.tblView = tblView
                
                cell1.nextButton.addTarget(self, action: #selector(GroupsavingViewController.nextButtonPressed(_:)), for: UIControlEvents.touchUpInside)
                return cell1
            }
            
        }
        else if(indexPath.section == 5) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "NextButtonCellIdentifier", for: indexPath) as! NextButtonTableViewCell
            cell1.tblView = tblView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if(itemDetailsDataDict[kTitle] != nil) {
                cell1.nextButton.setTitle("Join group", for: UIControlState())
                cell1.nextButton.addTarget(self, action: #selector(GroupsavingViewController.nextButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            }
            else {
                cell1.nextButton.addTarget(self, action: #selector(GroupsavingViewController.nextButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            }
            return cell1
        }
        else if(indexPath.section ==  6) {
            
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "ClearButtonIdentifier", for: indexPath) as! ClearButtonTableViewCell
            cell1.tblView = tblView
            cell1.layer.cornerRadius = 5
            cell1.layer.masksToBounds = true
            if(itemDetailsDataDict[kTitle] != nil) {
                cell1.clearButton.isUserInteractionEnabled = false
            }
            cell1.clearButton.addTarget(self, action: #selector(GroupsavingViewController.clearButtonPressed), for: UIControlEvents.touchUpInside)
            return cell1
        }
            
        else {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "GroupParticipantNameTableViewCellIdentifier", for: indexPath) as! GroupParticipantNameTableViewCell
            if(indexPath.row  == (participantsArr.count - 1)) {
                let maskPath: UIBezierPath = UIBezierPath(roundedRect: cell1.bounds, byRoundingCorners: ([.bottomLeft,.bottomRight]), cornerRadii: CGSize(width: 5.0, height: 5.0))
                
//                let maskPath1: UIBezierPath = UIBezierPath(roundedRect: cell1.bounds, byRoundingCorners: ([.TopLeft,.TopRight]), cornerRadii: CGSizeMake(1.0, 1.0))
//                
//                let combinedPath : CGMutablePathRef = CGPathCreateMutableCopy(maskPath.CGPath)!
//                CGPathAddPath(combinedPath, nil, maskPath1.CGPath)
                
                let maskLayer: CAShapeLayer = CAShapeLayer()
                maskLayer.frame = cell1.bounds
                maskLayer.path = maskPath.cgPath
                cell1.layer.mask = maskLayer
            }
            else {
                let maskPath: UIBezierPath = UIBezierPath(roundedRect: cell1.bounds, byRoundingCorners: ([.bottomLeft,.bottomRight,.topLeft,.topRight]), cornerRadii: CGSize(width: 0, height: 0))
                let maskLayer: CAShapeLayer = CAShapeLayer()
                maskLayer.frame = cell1.bounds
                maskLayer.backgroundColor = UIColor(red:90/255,green:90/255,blue:100/255,alpha:1).cgColor
                maskLayer.path = maskPath.cgPath
                
                cell1.layer.mask = maskLayer
            }
            
            if(participantsArr.count != 0) {
                let dict = participantsArr[indexPath.row]
                let nameStr = String(format: "%@ %@", dict["first_name"] as! String, dict["second_name"] as! String)
                cell1.ParticipantsNameLabel.text = nameStr//dict["first_name"] as? String
                if (dict["email_id"] as? String != "") {
                    cell1.phoneOrEmailLabel.text = dict["email_id"] as? String
                }
                else {
                    cell1.phoneOrEmailLabel.text = dict["mobile_number"] as? String
                }
                cell1.deleteContactButton.addTarget(self, action:  #selector(GroupsavingViewController.deleteContactButtonPressed(_:)), for: .touchUpInside)
                cell1.deleteContactButton.tag = indexPath.row
                
            }
            return cell1
        }
        
    }
    
    func deleteContactButtonPressed(_ sender:UIButton)
    {
        let alert = UIAlertController(title: "Are you sure?", message: "You want to delete this person from list", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default)
        { action -> Void in
            // detect contact, which was deleted
            let deletedContact = self.participantsArr[sender.tag]
            let deletedContactEmail = deletedContact["email_id"] as? String
            let deletedContactPhone = deletedContact["mobile_number"] as? String
            
            // filter out deleted contacts from "InviteGroupArray"
            var newParticipantsArr =  Array<Dictionary<String,AnyObject>>()
            if let contactsArray =  userDefaults.object(forKey: "InviteGroupArray") as? Array<Dictionary<String,AnyObject>>  {
                for contact in contactsArray {
                    if let deletedContactEmail = deletedContactEmail, deletedContactEmail == contact["email_id"] as? String {
                        continue
                    }
                    if let deletedContactPhone = deletedContactPhone, deletedContactPhone == contact["mobile_number"] as? String {
                        continue
                    }
                    newParticipantsArr.append(contact)
                }
                userDefaults.set(newParticipantsArr, forKey:"InviteGroupArray")
                userDefaults.synchronize()
            }
            
            self.participantsArr.remove(at: sender.tag)
            self.contentViewHt.constant = self.contentViewHt.constant - 40
            self.tblViewHt.constant = self.tblViewHt.constant - 40
            self.scrlView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: self.tblView.frame.origin.y + self.tblView.frame.size.height - 40)
            self.tblView.reloadData()
            
            })
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func inviteButtonPressed()
    {
        if(participantsArr.count == 7) {
            self.displayAlert("You can't add more than 7 contacts into group saving plan", title: "Alert")
        }
        else {
            self.showAddressBook()
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
        if(section == 4) {
            if(participantsArr.count > 0) {
                return 0
            }
            else {
                return 3
            }
        }
        else {
            return 3
        }
    }
    
    //This is UITableViewDelegate method used to set the height of rows per section.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if(indexPath.section == 0) {
            return 44
        }
        else if(indexPath.section == 1) {
            return 90
        }
        else if(indexPath.section == 2) {
            return 70
        }
        else if(indexPath.section == 3) {
            return 119
        }
        else if(indexPath.section ==   4) {
            if(participantsArr.count == 0) {
                return 0
            }
            else {
                return 35
            }
        }
        else if(indexPath.section ==   5) {
            return 65
        }
        else {
            return 40
        }
        
    }
    
    //Create Dictionary to send to the CreatePartySavingPlan API.
    func getParameters() -> Dictionary<String,AnyObject>
    {
        var parameterDict : Dictionary<String,AnyObject> = [:]
        
        if(itemDetailsDataDict["id"] != nil) {
            parameterDict["wishList_ID"] = itemDetailsDataDict["id"] as! NSNumber
        }
        
        if(itemDetailsDataDict["savingId"] != nil) {
            parameterDict["sav_id"] = itemDetailsDataDict["savingId"] as! NSNumber
        }
        
        if(itemDetailsDataDict["sharedPtySavingPlanId"] != nil) {
            parameterDict["sharedPtySavingPlanId"] = itemDetailsDataDict["sharedPtySavingPlanId"] as! NSNumber
        }
        
        if(itemDetailsDataDict[kTitle] != nil) {
            parameterDict[kTitle] = itemDetailsDataDict[kTitle]
            parameterDict["isUpdate"] = "Yes" as AnyObject
        }
        else {
            parameterDict[kTitle] = itemTitle as AnyObject
            parameterDict["isUpdate"] = "No" as AnyObject
        }
        
        if(itemDetailsDataDict[kAmount] != nil) {
            parameterDict[kAmount]  = String(format: "%d", cost) as AnyObject
        }
        else {
            parameterDict[kAmount] = String(format:"%d",cost) as AnyObject
        }
        
        if(itemDetailsDataDict[kImageURL] != nil && (itemDetailsDataDict[kImageURL] as! String).characters.count != 0) {
            
            let imageData:Data = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
            let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            parameterDict[kImageURL] = base64String as AnyObject
        }
        else {
            if(cameraButton.isHidden == true) {
                let imageData:Data = UIImageJPEGRepresentation(topBackgroundImageView.image!, 1.0)!
                let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                parameterDict[kImageURL] = base64String as AnyObject
            }
            else {
                parameterDict[kImageURL] = "" as AnyObject
            }
        }
        
        let dateParameter = DateFormatter()
        dateParameter.dateFormat = "dd-MM-yyyy"
        if(itemDetailsDataDict["planEndDate"] != nil) {
            parameterDict[kPLANENDDATE] = itemDetailsDataDict["planEndDate"]
        }
        else {
            if(datePickerDate != "") {
                var pathComponents : NSArray!
                pathComponents = (datePickerDate).components(separatedBy: " ") as [String] as NSArray
                var dateStr = pathComponents.lastObject as! String
                dateStr = dateStr.replacingOccurrences(of: "/", with: "-")
                var pathComponents2 : NSArray!
                pathComponents2 = [dateStr.components(separatedBy: "-").joined(separator: " ")] as [String] as NSArray
                parameterDict[kPLANENDDATE] = String(format: "%@-%@-%@",pathComponents2[2] as! String,pathComponents2[1] as! String,pathComponents2[0] as! String) as AnyObject;
                
                /*
                 let invalidCharSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ").inverted
                 
                 let filtered = replacementString.components(separatedBy: invalidCharSet).joined(separator: " ")
                 */
            }
        }
        
        parameterDict["INIVITED_DATE"] = dateParameter.string(from: Date()) as AnyObject
        parameterDict["pty_id"] = userInfoDict[kPartyID]
        if(itemDetailsDataDict["savingId"] != nil) {
            parameterDict["sav_id"] = itemDetailsDataDict["savingId"]
        }
        else {
            if((imageDataDict["sav-id"]) != nil) {
                parameterDict["sav_id"] = imageDataDict["sav-id"]
            }
            else if(imageDataDict["savPlanID"] != nil) {
                parameterDict["sav_id"] = imageDataDict["savPlanID"]
            }
            else {
                parameterDict["sav_id"] = itemDetailsDataDict["sav-id"]
            }
        }
        parameterDict["dateDiff"] = String(format:"%d",dateDiff) as AnyObject
        parameterDict["participantsArr"] = participantsArr as AnyObject
        parameterDict["payDate"] = itemDetailsDataDict["payDate"]
        return parameterDict
    }
    
    func getTextFieldText(_ text: String) {
        itemTitle = text
    }
    
    func txtFieldCellText(_ txtFldCell: SavingPlanCostTableViewCell) {
        cost = Int(txtFldCell.slider.value)
        tblView.reloadData()
    }
    
    func datePickerText(_ date: Int,dateStr:String) {
        dateDiff = date
        datePickerDate = dateStr
    }
    
    
    func nextButtonPressed(_ sender:UIButton) {
        self.objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        self.objAnimView.frame = self.view.frame
        self.objAnimView.animate()
        self.navigationController!.view.addSubview(self.objAnimView)
        
        if(isFromWishList) {
            if(itemTitle != "" && cost != 0 && datePickerDate != "") {
                let objGroupSavingPlanView = SACreateGroupSavingPlanViewController(nibName: "SACreateGroupSavingPlanViewController",bundle: nil)
                objGroupSavingPlanView.parameterDict = self.getParameters()
                objGroupSavingPlanView.delegate = self
                objGroupSavingPlanView.groupMemberCount = groupArrayCount
                self.navigationController?.pushViewController(objGroupSavingPlanView, animated: true)
                objAnimView.removeFromSuperview()
            }
            else {
                self.objAnimView.removeFromSuperview()
                if(itemTitle == "") {
                    self.displayAlert("Please enter title for your saving plan", title: "Missing information")
                }
                else if(cost == 0 ) {
                    self.displayAlert("Please enter amount for your saving plan", title: "Missing information")
                }
//                else if(dateDiff == 0) {
//                    self.displayAlert("Please select date for your saving plan", title: "Missing information")
//                }
                else  {
                    self.displayAlert("Please enter all details", title: "Missing information")
                }
            }
        }
        else {
            if(itemTitle != "" && self.getParameters()[kAmount] != nil && cost != 0 && dateDiff != 0 && datePickerDate != ""  && participantsArr.count > 0) {
                let objGroupSavingPlanView = SACreateGroupSavingPlanViewController(nibName: "SACreateGroupSavingPlanViewController",bundle: nil)
                objGroupSavingPlanView.parameterDict = self.getParameters()
                objGroupSavingPlanView.delegate = self
                self.navigationController?.pushViewController(objGroupSavingPlanView, animated: true)
                objAnimView.removeFromSuperview()
                
            }
            else {
                self.objAnimView.removeFromSuperview()
                self.objAnimView.removeFromSuperview()
                var message = ""
                
                if(itemTitle == "") {
                    message = "Please enter title."
                }
                else if(cost == 0) {
                    message = "Please enter amount."
                }
                else if(dateDiff == 0 ) {
                    message = "Please select date."
                }
                else if(participantsArr.count == 0) {
                    message = "Please add atleast one contact."
                }
                self.displayAlert(message, title: "Missing information")
            }
        }
    }
    
    
    func displayAlert(_ message:String, title:String)
    {
        //Show of UIAlertView
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    
    func clearButtonPressed() {
         let alert = UIAlertController(title: "Are you sure?", message: "This will clear the information entered and start again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default)
        { action -> Void in
            
            self.dateDiff = 0
            self.datePickerDate = ""
            self.cost = 0
            self.itemTitle = ""
            self.isClearPressed = true
            self.popOverSelectedStr = ""
            if(self.itemDetailsDataDict.keys.count > 0) {
                self.itemDetailsDataDict.removeAll()
            }
            userDefaults.removeObject(forKey: "InviteGroupArray")
            userDefaults.synchronize()
            if(self.participantsArr.count > 0) {
                self.participantsArr.removeAll()
            }
            
            self.topBackgroundImageView.image = UIImage(named:"groupsave-setup-bg.png")
            self.setUpView()

            self.tblViewHt.constant = 500
            self.scrlView.contentOffset = CGPoint(x: 0, y: 20)
            self.scrlView.contentSize = CGSize(width: 0, height: self.tblView.frame.origin.y + self.tblViewHt.constant)
            
            self.tblView.reloadData()
            })
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker .dismiss(animated: true, completion: nil)
        topBackgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        topBackgroundImageView.layer.masksToBounds = true
        topBackgroundImageView?.image = (info[UIImagePickerControllerEditedImage] as? UIImage)
        cameraButton.isHidden = true
        isImageclicked = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker .dismiss(animated: true, completion: nil)
    }
 }

 

 
 
 
