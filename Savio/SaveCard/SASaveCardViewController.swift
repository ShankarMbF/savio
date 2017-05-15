//
//  SASaveCardViewController.swift
//  Savio
//
//  Created by Maheshwari on 14/09/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
import Stripe

class SASaveCardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,STPAddCardViewControllerDelegate,GetListOfUsersCardsDelegate,SetDefaultCardDelegate,ImpulseSavingDelegate,RemoveCardDelegate,AddSavingCardDelegate,AddNewSavingCardDelegate {
    
    @IBOutlet weak var cardListView: UITableView!
    @IBOutlet weak var cardViewOne: UIView!
    @IBOutlet weak var cardViewTwo: UIView!
    @IBOutlet weak var cardLastFourDigitTextField: UITextField!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var newCardButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewDoneButton: UIButton!
    @IBOutlet weak var bottomViewNewCardbutton: UIButton!
    
    var isFromGroupMemberPlan = false
    var isFromImpulseSaving = false
    var isFromSavingPlan = false
    var isFromEditUserInfo = false
    var showAlert  = false
    var objAnimView = ImageViewAnimation()
    var savedCardArray : Array<Dictionary<String,AnyObject>> = []
    var cardListResponse : Dictionary<String,AnyObject> = [:]
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var removeCardTag : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setUpView()
//          Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(true)
       self.setUpView()
    }
    
    func setUpView()
    {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let btnName = UIButton()
        
        
        if(isFromEditUserInfo)
        {
            leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
            leftBtnName.addTarget(self, action: #selector(SASaveCardViewController.menuButtonClicked), for: .touchUpInside)
            
            btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
            btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
            btnName.setTitle("0", for: UIControlState())
            btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
            btnName.addTarget(self, action: #selector(SASaveCardViewController.heartBtnClicked), for: .touchUpInside)
            
            if let str = UserDefaults.standard.object(forKey: "wishlistArray") as? Data
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
                }
                
                btnName.setTitle(String(format:"%d",wishListArray.count), for: UIControlState())
            }
        }
        else{
            
            leftBtnName.setImage(UIImage(named: "nav-back.png"), for: UIControlState())
            leftBtnName.addTarget(self, action: #selector(SASaveCardViewController.backButtonClicked), for: .touchUpInside)
            
            btnName.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
            btnName.setTitle("Done", for: UIControlState())
            btnName.setTitleColor(UIColor(red: 0.95, green: 0.69, blue: 0.25, alpha: 1), for: UIControlState())
            btnName.titleLabel!.font = UIFont(name: kBookFont, size: 15)
            btnName.addTarget(self, action: #selector(SASaveCardViewController.doneBtnClicked), for: .touchUpInside)
        }
        
        if isFromSavingPlan == true || isFromGroupMemberPlan == true{
            self.navigationItem.hidesBackButton = true
        }
        else{
            let leftBarButton = UIBarButtonItem()
            leftBarButton.customView = leftBtnName
            self.navigationItem.leftBarButtonItem = leftBarButton
        }
        
        //set Navigation right button nav-heart
            let rightBarButton = UIBarButtonItem()
            rightBarButton.customView = btnName
            self.navigationItem.rightBarButtonItem = rightBarButton
       
        
        cardViewOne.layer.borderWidth = 1
        cardViewOne.layer.cornerRadius = 5
        cardViewOne.layer.borderColor = UIColor(red: 0.95, green: 0.69, blue: 0.25, alpha: 1).cgColor
        
        cardViewTwo.layer.borderWidth = 1
        cardViewTwo.layer.cornerRadius = 5
        cardViewTwo.layer.borderColor = UIColor(red: 0.97, green: 0.87, blue: 0.69, alpha: 1).cgColor
        
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(self.objAnimView)
        
        if var activeCard = UserDefaults.standard.value(forKey: "activeCard") as? Dictionary<String,AnyObject>
        {
            if var trimmedString = activeCard["cardNumber"] as? String
            {
                trimmedString = (activeCard["cardNumber"] as! NSString).substring(from: max(activeCard["cardNumber"]!.length-4,0))
                cardLastFourDigitTextField.text = trimmedString
            }
            else if let trimmedString =  activeCard["last4"] as? String{
                cardLastFourDigitTextField.text = trimmedString
            }
            
        }
        if(isFromEditUserInfo)
        {
            self.topView.isHidden = false
            self.newCardButton.isHidden  = true
            self.bottomView.isHidden = false
            
            if(showAlert == true)
            {
                let alert = UIAlertView(title: "Alert", message: "This card will be saved as default card", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        
        let objAPI = API()
        objAPI.getListOfUsersCardDelegate = self
        objAPI.getWishListOfUsersCards()
        
    }
    
    //NavigationBar button methods
    func backButtonClicked()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func doneBtnClicked()
    {
        if let dict = UserDefaults.standard.value(forKey: "activeCard") as? Dictionary<String,AnyObject>
        {
            objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            
            let objAPI = API()
            objAPI.setDefaultCardDelegate = self
            var newDict : Dictionary<String,AnyObject> = [:]
            newDict["STRIPE_CUST_ID"] = dict["customer"]
            newDict["CUST_DEFAULT_CARD"] = dict["id"]
            objAPI.setDefaultPaymentCard(newDict)
            
        } else{
            let alert = UIAlertView(title: "Alert", message: "Click on Add New Card tab below and enter your card details", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func heartBtnClicked(){
        
        if wishListArray.count>0{
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: kWishlistempty, message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func menuButtonClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    
    // MARK: - Tableview Delegate & Datasource
    func numberOfSections(in tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return savedCardArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //--------create custom cell from CardTableViewCell.xib------------
        let cell = Bundle.main.loadNibNamed("CardTableViewCell", owner: nil, options: nil)![0] as! CardTableViewCell
        let dict = self.checkNullDataFromDict(savedCardArray[indexPath.row])
        
        let trimmedString: String = (dict["last4"] as? String)!
        //(dict["cardNumber"] as! NSString).substringFromIndex(max(dict["cardNumber"]!.length-4,0))
        let attributedString = NSMutableAttributedString(string: String(format: "%@ Ending in %@",dict["brand"] as! String,trimmedString))
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                      value: UIColor.black,
                                      range: NSRange(
                                        location:0,
                                        length:(dict["brand"] as! String).characters.count))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: kMediumFont ,size: 15)!, range: NSRange(
            location:0,
            length:(dict["brand"] as! String).characters.count))
        
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                      value: UIColor.black,
                                      range: NSRange(
                                        location:((dict["brand"] as! String).characters.count),
                                        length:11))
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: kLightFont,size: 15)!, range: NSRange(
            location:((dict["brand"] as! String).characters.count),
            length:11))
        
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                      value: UIColor.black,
                                      range: NSRange(
                                        location:((dict["brand"] as! String).characters.count) + 11,
                                        length:trimmedString.characters.count))
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: kMediumFont,size: 15)!, range: NSRange(
            location:((dict["brand"] as! String).characters.count) + 11,
            length:trimmedString.characters.count))
        
        cell.cardHolderNameLabel.attributedText = attributedString
        cell.removeCardButton.tag = indexPath.row
        cell.removeCardButton.addTarget(self, action: #selector(SASaveCardViewController.removeCardFromList(_:)), for: .touchUpInside)
        if indexPath.row == 0 {
            
            cell.removeCardButton.isHidden = true
            cell.cardImageView.isHidden = true
//            Changing background color of selected row
//            cell.contentView.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell:CardTableViewCell? = cardListView!.cellForRow(at: indexPath)as? CardTableViewCell
        //Changing background color of selected row
        selectedCell!.contentView.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        
        let dict = self.checkNullDataFromDict(savedCardArray[indexPath.row])
        UserDefaults.standard.setValue(dict, forKey: "activeCard")
        UserDefaults.standard.synchronize()
        let trimmedString: String = (dict["last4"] as? String)!
        cardLastFourDigitTextField.text = trimmedString
        
    }
    
    func removeCardFromList(_ sender: UIButton) {
        removeCardTag = sender.tag
        let dict = self.checkNullDataFromDict(savedCardArray[removeCardTag])
        print("Remove card ends with \(dict["last4"] as! String)")
        let uiAlert = UIAlertController(title: "Alert", message: "Do you want remove card end with \(dict["last4"] as! String)?", preferredStyle: UIAlertControllerStyle.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            print("Click of No button")
            
        }))
        
        uiAlert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { action in
            print("Click of Yes button")
            self.objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.view.addSubview(self.objAnimView)

            var paramDict : Dictionary<String,AnyObject> = [:]
            paramDict["customerId"] = dict["customer"] as! String as AnyObject
            paramDict["cardId"] = dict["id"] as! String as AnyObject
        
            let objAPI = API()
            objAPI.removeCardDelegate = self
            objAPI.removeCarde(paramDict)
            
        }))
    }
    
    @IBAction func addNewCardButtonPressed(_ sender: UIButton) {
       
//         Strip SDK
  
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        // STPAddCardViewController must be shown inside a UINavigationController.
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        self.present(navigationController, animated: true, completion: nil)
        
        /*
        let objPaymentView = SAPaymentFlowViewController()
        objPaymentView.addNewCard = true
        objPaymentView.isFromGroupMemberPlan = self.isFromGroupMemberPlan
        if(isFromImpulseSaving == true)
        {
            objPaymentView.isFromImpulseSaving = true
        }
        else if(isFromEditUserInfo == true)
        {
            objPaymentView.isFromEditUserInfo = true
        }
        self.navigationController?.pushViewController(objPaymentView, animated: true)*/
    }
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        let objAPI = API()
        let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict[kPartyID] as! NSNumber,"STRIPE_TOKEN":(token.stripeID as AnyObject)]
        
        objAPI.addNewSavingCardDelegate = self
        objAPI.addNewSavingCard(dict)

        //Use token for backend process
        self.dismiss(animated: true, completion: {
            completion(nil)
        })
    }
    
    //Go to SAEditUserInfoViewController
    @IBAction func profileButtonPressed(_ sender: UIButton) {
//        let objEditUserInfo = SAEditUserInfoViewController(nibName: "SAEditUserInfoViewController", bundle: nil)
//        self.navigationController?.pushViewController(objEditUserInfo, animated: true)
        var vw = UIViewController()
        var flag = false
        
        for var obj in (self.navigationController?.viewControllers)!{
            if obj.isKind(of: SAEditUserInfoViewController.self) {
                vw = obj as! SAEditUserInfoViewController
                flag = true
                break
            }
        }
        if flag {
            self.navigationController?.popToViewController(vw, animated: true)
        }
        else{
            let objEditUserInfo = SAEditUserInfoViewController()
            self.navigationController?.pushViewController(objEditUserInfo, animated: true)
        }
    }
    
    //Call the API to set selected card as Default card
    @IBAction func bottomviewDoneButtonPressed(_ sender: UIButton) {
        if let dict = UserDefaults.standard.value(forKey: "activeCard") as? Dictionary<String,AnyObject>
        {
            objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            let objAPI = API()
            objAPI.setDefaultCardDelegate = self
            var newDict : Dictionary<String,AnyObject> = [:]
            newDict["STRIPE_CUST_ID"] = dict["customer"]
            newDict["CUST_DEFAULT_CARD"] = dict["id"]
            objAPI.setDefaultPaymentCard(newDict)
        } else{
            let alert = UIAlertView(title: "Alert", message: "Click on Add New Card tab below and enter your card details", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
    }
    @IBAction func paymentButtonPressed(_ sender: UIButton) {
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
    
     // MARK: - API Response
    //Success reponse of GetListOfUsersCardsDelegate
    func successResponseForGetListOfUsersCards(_ objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String{
            if(message == "Successfully Received")
            {
                cardListResponse = checkNullDataFromDict(objResponse)
                let dict = cardListResponse["exCollection"] as! Dictionary<String, AnyObject>
                savedCardArray = dict["data"]! as! Array<Dictionary<String,AnyObject>>
                let newDict = self.checkNullDataFromDict(savedCardArray[0])
                UserDefaults.standard.setValue(newDict, forKey: "activeCard")
                cardListView.reloadData()
                cardListView.selectRow(at: IndexPath(row:0,section: 0), animated: true, scrollPosition:UITableViewScrollPosition.top)
                let selectedCell:CardTableViewCell? = cardListView!.cellForRow(at: IndexPath(row:0,section: 0))as? CardTableViewCell
                //Changing background color of selected row
                selectedCell!.contentView.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
                let objAPI = API()
            }
        }
        print(UserDefaults.standard.value(forKey: "saveCardArray"))
    }
    
    //Error reponse of GetListOfUsersCardsDelegate
    func errorResponseForGetListOfUsersCards(_ error: String) {
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
    }
    
    //Success reponse of SetDefaultCardDelegate
    func successResponseForSetDefaultCard(_ objResponse: Dictionary<String, AnyObject>)
    {
        let individualFlag = UserDefaults.standard.value(forKey: kIndividualPlan) as! NSNumber
        let groupFlag = UserDefaults.standard.value(forKey: kGroupPlan) as! NSNumber
        let groupMemberFlag = UserDefaults.standard.value(forKey: kGroupMemberPlan) as! NSNumber
        if(isFromSavingPlan)
        {
            let objSummaryView = SASavingSummaryViewController()
            self.navigationController?.pushViewController(objSummaryView, animated: true)
        }
        else if isFromEditUserInfo == true {
             var vw = UIViewController()
            var isAvailble: Bool = false
            for var obj in (self.navigationController?.viewControllers)!{
                if obj.isKind(of: SAEditUserInfoViewController.self) {
                    isAvailble = true
                    vw = obj as! SAEditUserInfoViewController
                    break
                }
            }
            if isAvailble {
                self.navigationController?.popToViewController(vw, animated: false)
            }
            else{
                vw = SAEditUserInfoViewController()
                self.navigationController?.pushViewController(vw, animated: false)
            }
            self.navigationController?.popViewController(animated: true)
        }
        else if isFromGroupMemberPlan == true {
            //Navigate to showing group progress
            self.isFromGroupMemberPlan = false
            UserDefaults.standard.setValue(1, forKey: kGroupMemberPlan)
            UserDefaults.standard.synchronize()
            let objThankyYouView = SAThankYouViewController()
            self.navigationController?.pushViewController(objThankyYouView, animated: true)
        }
        else if (isFromImpulseSaving == true){
            let objAPI = API()
            objAPI.impulseSavingDelegate = self
            let dict = UserDefaults.standard.value(forKey: "activeCard") as? Dictionary<String,AnyObject>
            var newDict : Dictionary<String,AnyObject> = [:]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            newDict["STRIPE_CUSTOMER_ID"] = dict!["customer"]
            newDict["PAYMENT_DATE"] = dateFormatter.string(from: Date()) as AnyObject
            newDict[kAMOUNT] = UserDefaults.standard.value(forKey: "ImpulseAmount") as AnyObject
            newDict["PAYMENT_TYPE"] = "debit" as AnyObject
            newDict["AUTH_CODE"] = "test" as AnyObject
            newDict["Consumer"] = "APP" as AnyObject
            newDict[kPTYSAVINGPLANID] = UserDefaults.standard.value(forKey: kPTYSAVINGPLANID) as! NSNumber
            print(newDict)
            objAPI.impulseSavingDelegate = self
            objAPI.impulseSaving(newDict)
        }
        else {
            objAnimView.removeFromSuperview()
            //Navigate user to Progress screen
            if(individualFlag == 1)
            {
                UserDefaults.standard.setValue(1, forKey: kIndividualPlan)
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationIdentifier), object: nil)
                
                let objProgressView = SAProgressViewController()
                self.navigationController?.pushViewController(objProgressView, animated: true)
            }
            else if(groupMemberFlag == 1 || groupFlag == 1)
            {   UserDefaults.standard.setValue(1, forKey: kGroupPlan)
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationIdentifier), object: nil)
                
                let objProgressView = SAGroupProgressViewController()
                self.navigationController?.pushViewController(objProgressView, animated: true)
            }
            else if(groupMemberFlag == 1)
            {
                UserDefaults.standard.setValue(1, forKey: kGroupMemberPlan)
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationIdentifier), object: nil)
                
                let objProgressView = SAGroupProgressViewController()
                self.navigationController?.pushViewController(objProgressView, animated: true)
            }
        }
    }
    
     //Success reponse of SetDefaultCardDelegate
    func errorResponseForSetDefaultCard(_ error: String) {
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
    }
    
    //Success reponse of ImpulseSavingDelegate
    func successResponseImpulseSavingDelegateAPI(_ objResponse: Dictionary<String, AnyObject>) {
       /* 
         print(objResponse)
        if let _ = objResponse["message"] as? String
        {
            self.isFromImpulseSaving = false
            let objImpulseView = SAImpulseSavingViewController()
            objImpulseView.isFromPayment = true
            self.navigationController?.pushViewController(objImpulseView, animated: true)
        } 
         */
        
        print(objResponse)
        objAnimView.removeFromSuperview()
        if let errorCode = objResponse["errorCode"] as? NSString
        {
            if (errorCode == "200")
            {
                self.isFromImpulseSaving = false
                let objImpulseView = SAImpulseSavingViewController()
                objImpulseView.isFromPayment = true
                self.navigationController?.pushViewController(objImpulseView, animated: true)
            }
        }else {
            let alert = UIAlertView(title: "Sorry, transaction is not completed", message: "Please try again.", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //Success reponse of ImpulseSavingDelegate
    func errorResponseForImpulseSavingDelegateAPI(_ error: String) {
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
    }
    
    // Remove Card API delegate methods
    func successResponseForRemoveCardAPI(_ objResponse:Dictionary<String,AnyObject>){
        print(objResponse)
         objAnimView.removeFromSuperview()
            self.savedCardArray.remove(at: removeCardTag)
            self.cardListView.reloadData()
        
//        var arr = NSUserDefaults.standardUserDefaults().valueForKey(<#T##key: String##String#>)
//        objAnimView.removeFromSuperview()
        
        
//        if let saveCardArray = NSUserDefaults.standardUserDefaults().objectForKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
//        {
//            array = saveCardArray
//            var cardNumberArray : Array<String> = []
//            for i in 0 ..< array.count{
//                let newDict = array[i]
//                cardNumberArray.append(newDict["cardNumber"] as! String)
//            }
//            //                            if(cardNumberArray.contains(self.cardNumberTextField.text!) == false)
//            if(cardNumberArray.contains(cardNum) == false)
//            {
//                array.append(dict1)
//                NSUserDefaults.standardUserDefaults().setValue(dict1, forKey: "activeCard")
//                //                                        NSUserDefaults.standardUserDefaults().setObject(array, forKey: "saveCardArray")
//                NSUserDefaults.standardUserDefaults().synchronize()
//                objAPI.storeValueInKeychainForKey("saveCardArray", value: array)
//                
//                
//                let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict["partyId"] as! NSNumber,"STRIPE_TOKEN":(token?.tokenId)!]
//                objAPI.addNewSavingCardDelegate = self
//                objAPI.addNewSavingCard(dict)
//                self.addNewCard = false
//            }
//            else {
//                self.objAnimView.removeFromSuperview()
//                //show alert view controller if card is already added
//                let alertController = UIAlertController(title: "Warning", message: "You have already added this card", preferredStyle:UIAlertControllerStyle.Alert)
//                //alert view controll action method
//                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
//                { action -> Void in
//                    self.navigationController?.popViewControllerAnimated(true)
//                    })
//                self.presentViewController(alertController, animated: true, completion: nil)
//            }
//        }
        
        
    }
    
    func errorResponseForRemoveCardAPI(_ error:String){
        print(error)
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }

    
    // MARK: - API Response
    //Success response of AddSavingCardDelegate
    func successResponseForAddSavingCardDelegateAPI(_ objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String{
            if(message == "Successful")
            {
                if(objResponse["stripeCustomerStatusMessage"] as? String == "Customer Card detail Added Succeesfully")
                {
                    if(self.isFromGroupMemberPlan == true)
                    {
                        //Navigate to SAThankYouViewController
                        self.isFromGroupMemberPlan = false
                        UserDefaults.standard.setValue(1, forKey: kGroupMemberPlan)
                        UserDefaults.standard.synchronize()
                        let objThankyYouView = SAThankYouViewController()
                        self.navigationController?.pushViewController(objThankyYouView, animated: true)
                    }
                    else {
                        let objSummaryView = SASavingSummaryViewController()
                        self.navigationController?.pushViewController(objSummaryView, animated: true)
                    }
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
    
    //Success response of AddNewSavingCardDelegate
    func successResponseForAddNewSavingCardDelegateAPI(_ objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        
        if let message = objResponse["message"] as? String{
            if(message == "Successfull")
            {
                if(self.isFromGroupMemberPlan == true)
                {
                    //Navigate to showing group progress
                    self.isFromGroupMemberPlan = false
                    UserDefaults.standard.setValue(1, forKey: kGroupMemberPlan)
                    UserDefaults.standard.synchronize()
                    let objThankyYouView = SAThankYouViewController()
                    self.navigationController?.pushViewController(objThankyYouView, animated: true)
                    
                }else if(self.isFromImpulseSaving){
                    let objAPI = API()
                    objAPI.impulseSavingDelegate = self
                    
                    var newDict : Dictionary<String,AnyObject> = [:]
                    let userInfoDict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
                    //                    let userInfoDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
                    let cardDict = objResponse["card"] as? Dictionary<String,AnyObject>
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    newDict["STRIPE_CUSTOMER_ID"] = cardDict!["customer"]
                    newDict["PAYMENT_DATE"] = dateFormatter.string(from: Date()) as AnyObject
                    newDict[kAMOUNT] = UserDefaults.standard.value(forKey: "ImpulseAmount") as AnyObject
                    newDict["PAYMENT_TYPE"] = "debit" as AnyObject
                    newDict["AUTH_CODE"] = "test" as AnyObject
                    newDict["consumer"] = "APP" as AnyObject
                    newDict[kPTYSAVINGPLANID] = UserDefaults.standard.value(forKey: kPTYSAVINGPLANID) as! NSNumber
                    print(newDict)
                    objAPI.impulseSaving(newDict)
                }
                else if(isFromEditUserInfo)
                {
                    objAnimView.removeFromSuperview()
                    let objSavedCardView = SASaveCardViewController()
                    objSavedCardView.isFromEditUserInfo = true
                    objSavedCardView.isFromImpulseSaving = false
                    objSavedCardView.showAlert = true
                    self.navigationController?.pushViewController(objSavedCardView, animated: true)
                }
                else {
                    objAnimView.removeFromSuperview()
                    let objSummaryView = SASavingSummaryViewController()
                    self.navigationController?.pushViewController(objSummaryView, animated: true)
                }
            }
        }
    }
    
    //error response of AddNewSavingCardDelegate
    func errorResponseForAddNewSavingCardDelegateAPI(_ error: String) {
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
