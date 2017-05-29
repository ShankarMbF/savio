//
//  SAWishListViewController.swift
//  Savio
//
//  Created by Prashant on 04/06/16.
//  Copyright 2016 Prashant. All rights reserved.
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


class SAWishListViewController: UIViewController,GetWishlistDelegate,DeleteWishListDelegate {
    
    @IBOutlet var wishListTable: UITableView?    //IBOutlet for tableview
    var objAnimView = ImageViewAnimation()       //object for loading indicator
    var wishListArray : Array<Dictionary<String,AnyObject>> = []   //Array for storing wishlist from webservice
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        // set up UI for wishlist
        self.setUpView()
        //calling get method of wishlist
        self.wishListAPI()
        
        //---------Setting navigation bar-------------------------
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        //----------------------------------------------------------------------
    }
    
    //Function invoke for design the UI
    func setUpView(){
        //Set view's title
        self.title = "My Wish List"
        //Register UIApplication Will Enter Foreground Notification
        NotificationCenter.default.addObserver(self, selector:#selector(SAWishListViewController.getWishListData(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        //--------------set Navigation left button-----------------
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SAWishListViewController.menuButtonClicked), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        //---------------------------------------------------------
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.addTarget(self, action: #selector(SAWishListViewController.heartBtnClicked), for: .touchUpInside)
        //check if wishlist product is empty or not
        if let str = userDefaults.object(forKey: "wishlistArray") as? Data
        {
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>
            btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), for: UIControlState())
            btnName.setTitle(String(format:"%d",wishListArray!.count), for: UIControlState())
            
            //Showing wishlist count on heart button
            if(wishListArray!.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), for: UIControlState())
                btnName.setTitleColor(UIColor.black, for: UIControlState())
            }
            else  {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
            }
        }
        else {
            let dataNew = NSKeyedArchiver.archivedData(withRootObject: wishListArray)
            userDefaults.set(dataNew, forKey: "wishlistArray")
            userDefaults.synchronize()
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        //-----------------------------------------------------------------------------------------
    }
    
    //Function invoke when application is come foreground state and UIApplicationWillEnterForegroundNotification broadcast
    func getWishListData(_ notification:Notification)
    {
        //call get method of wish list
        self.wishListAPI()
    }
    
    //function invoke for call get method of wishlist
    func wishListAPI(){
        //--------load the ImageViewAnimation.xib and showing loading animation--------------------
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        //----------------------------------------------------------------------------------------
        //------Create object of API class and request to server for get wishlist----------------
        let objAPI = API()
//        let userDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        let userDict = userDefaults.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        objAPI.getWishlistDelegate = self
        //provide the partyID as a parameter to API
        if(userDict[kPartyID] is String)
        {
            objAPI.getWishListForUser(userDict[kPartyID] as! String)
        }
        else
        {
            objAPI.getWishListForUser(String(format: "%d",((userDict[kPartyID] as? NSNumber)?.doubleValue)!))
        }
        //----------------------------------------------------------------------------------------
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Tableview Delegate & Datasource
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return wishListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{
        
        //--------create custom cell from WishListTableViewCell.xib------------
        let cell = Bundle.main.loadNibNamed("WishListTableViewCell", owner: nil, options: nil)![0] as! WishListTableViewCell
        //-----------------------------------------------------------------------
        //Get individual dictionary of wishlist product
        let cellDict = wishListArray[indexPath.row]
        //Set product title
        cell.lblTitle!.text = cellDict[kTitle] as? String;
        //set product amount
        if(cellDict[kAmount] is String){
            cell.lblPrice.text = cellDict[kAmount] as? String
        }
        else{
            cell.lblPrice.text = String(format: "%d", (cellDict[kAmount] as! NSNumber).int32Value)
        }
        //Check wishlist product is invited for group member or not
        if let sharedPartySavingPlan =  cellDict["sharedPtySavingPlanId"] as? NSNumber
        {
            //Not invited for group member
            if(sharedPartySavingPlan == 0)
            {
                if(userDefaults.object(forKey: kIndividualPlan) as? NSNumber == 0 && userDefaults.object(forKey: kGroupPlan) as? NSNumber == 0) {
                    cell.btnSavingPlan?.setTitle("Start plan", for: UIControlState())
                    cell.btnSavingPlan?.addTarget(self, action: #selector(SAWishListViewController.navigateToSetUpSavingPlan(_:)), for: UIControlEvents.touchUpInside)
                    cell.deleteButtonTopSpace.constant = 60
                }
                else{
                    cell.btnSavingPlan?.isHidden = true
                    cell.deleteButtonTopSpace.constant = 20
                }
            }
            else
            {
                //Invited for group member
                if(userDefaults.object(forKey: kGroupMemberPlan) as? NSNumber == 0){
                    cell.btnSavingPlan?.setTitle("Join Group", for: UIControlState())
                    cell.btnSavingPlan?.addTarget(self, action: #selector(SAWishListViewController.joinGroupSavingPlan(_:)), for: UIControlEvents.touchUpInside)
                    cell.deleteButtonTopSpace.constant = 60
                }
                else {
                    cell.btnSavingPlan?.isHidden = true
                    cell.deleteButtonTopSpace.constant = 20
                }
            }
        }
        else
        {
            //Not invited for group member
            if(userDefaults.object(forKey: kIndividualPlan) as? NSNumber == 0 && userDefaults.object(forKey: kGroupPlan) as? NSNumber == 0){
                cell.btnSavingPlan?.setTitle("Start plan", for: UIControlState())
                cell.btnSavingPlan?.addTarget(self, action: #selector(SAWishListViewController.navigateToSetUpSavingPlan(_:)), for: UIControlEvents.touchUpInside)
                cell.deleteButtonTopSpace.constant = 60
            }
            else{
                cell.btnSavingPlan?.isHidden = true
                cell.deleteButtonTopSpace.constant = 20
            }
        }
        //set up delete button
        cell.btnDelete?.addTarget(self, action: #selector(SAWishListViewController.deleteButtonPress(_:)), for: UIControlEvents.touchUpInside)
        
        //------------------Showing prodict image-------------------------------------------
        let spinner =  UIActivityIndicatorView()
        spinner.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: cell.imgView.frame.size.height/2)
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        cell.imgView.addSubview(spinner)
        spinner.startAnimating()
        
        if let urlString = cellDict[kImageURL] as? String
        {
            //get image URL from response dict
            let url = URL(string:urlString)
            let request: URLRequest = URLRequest(url: url!)
            if(urlString != "")
            {
                //request server to fetch image data

                let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                    print("Response: \(String(describing: response))")
                    //if imagedata getting then show image
                    if data?.count > 0{
                        let image = UIImage(data: data!)
                        DispatchQueue.main.async(execute: {
                            cell.imgView.image = image
                            spinner.isHidden = true
                            spinner.stopAnimating()
                        })
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            spinner.isHidden = true
                            spinner.stopAnimating()
                        })
                    }
                })
                
                task.resume()
            }
        }
        //----------------------------------------------------------------------------------
        cell.btnSavingPlan?.tag = indexPath.row
        cell.btnDelete?.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        let cellDict = wishListArray[indexPath.row]
        if let sharedPartySavingPlan =  cellDict["sharedPtySavingPlanId"] as? NSNumber
        {
            if(sharedPartySavingPlan == 0)
            {
                //If any plan is already created by login user then hide start saving button
                if(userDefaults.object(forKey: kIndividualPlan) as? NSNumber == 0 && userDefaults.object(forKey: kGroupPlan) as? NSNumber == 0){
                    return 310.0
                }
                else{
                    return 280.0
                }
            }
            else
            {
                //If already join other group then hide Join button
                if(userDefaults.object(forKey: kIndividualPlan) as? NSNumber == 0 && userDefaults.object(forKey: kGroupPlan) as? NSNumber == 0){
                    return 310.0
                }
                else{
                    return 280.0
                }
            }
        }
        else
        {
            if(userDefaults.object(forKey: kIndividualPlan) as? NSNumber == 0 && userDefaults.object(forKey: kGroupPlan) as? NSNumber == 0){
                return 310.0
                
            }
            else{
                return 280.0
            }
        }
    }
    
    //Function navigate when user tapping on start saving plan button and navigate to setup plan screen
    func navigateToSetUpSavingPlan(_ sender:UIButton) {
        let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92] as [String : Any]
        userDefaults.set(dict, forKey:"colorDataDict")
        userDefaults.synchronize()
        
        let objSavingPlanViewController = SASavingPlanViewController(nibName: "SASavingPlanViewController",bundle: nil)
        objSavingPlanViewController.itemDetailsDataDict = wishListArray[sender.tag]
        self.navigationController?.pushViewController(objSavingPlanViewController, animated: true)
    }
    
    //Function navigate when user tapping on join plan button and navigate to group setup plan screen
    func joinGroupSavingPlan(_ sender: UIButton)
    {
        let dict = ["savLogo1x":"group-save-category-icon","savLogo2x":"group-save-category-icon","savLogo3x":"group-save-category-icon","title":"Group Save","detail":"Set up savings goal between friends and family","savPlanID":85] as [String : Any]
        userDefaults.set(dict, forKey:"colorDataDict")
        userDefaults.synchronize()
        
        let objSavingPlanViewController = GroupsavingViewController(nibName: "GroupsavingViewController",bundle: nil)
        let groupDict = wishListArray[sender.tag] 
        objSavingPlanViewController.itemDetailsDataDict = wishListArray[sender.tag]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: groupDict["planEndDate"] as! String)
        let timeDifference : TimeInterval = date!.timeIntervalSince(Date())
        objSavingPlanViewController.dateDiff = Int(timeDifference/3600)
        dateFormatter.dateFormat = "EEE dd/MM/yyyy"
        let goodDate = dateFormatter.string(from: date!)
        
        objSavingPlanViewController.datePickerDate = goodDate //groupDict["planEndDate"] as! String
        self.navigationController?.pushViewController(objSavingPlanViewController, animated: true)
    }
    
    //Funtion invoke for delete product from wishlist
    func deleteButtonPress(_ sender:UIButton)  {
        //Give confirmation alert to user
        let alert = UIAlertController(title: "Are you sure", message: "You want to delete this item?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default)
        { action -> Void in
            //if yes then show loading animation
            self.objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            self.view.addSubview(self.objAnimView)
            
            //Create API object and call delete method of wishlist API
            let objAPI = API()
            //Provide product detail to be delete
            let dateDict = self.wishListArray[sender.tag] as Dictionary<String,AnyObject>
            let dict : Dictionary<String,AnyObject> = ["id":dateDict["id"] as! NSNumber]
            objAPI.deleteWishList = self
            objAPI.deleteWishList(dict)
            //Remove from array
            self.wishListArray.remove(at: sender.tag)
            self.wishListTable?.reloadData()
            let dataNew = NSKeyedArchiver.archivedData(withRootObject: self.wishListArray)
            
            userDefaults.set(dataNew, forKey: "wishlistArray")
            userDefaults.synchronize()
            })
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: DELETE Wishlist delegate
    func successResponseForDeleteWishListAPI(_ objResponse: Dictionary<String, AnyObject>) {
        
        objAnimView.removeFromSuperview()
        self.setUpView()
    }
    //If Delete Fail
    func errorResponseForDeleteWishListAPI(_ error: String) {
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
    }
    
    //MARK: Bar button action
    //Function invoke when menu button clicked from navigation bar
    func menuButtonClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    
    //Function invoke when hear button clicked from navigation bar
    func heartBtnClicked(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- GetWishlist API  delegate
    func successResponseForGetWishlistAPI(_ objResponse: Dictionary<String, AnyObject>) {
        if wishListArray.count > 0 {
            wishListArray.removeAll()
        }
        if let obj = objResponse["wishListList"] as? Array<Dictionary<String,AnyObject>>{
            NotificationCenter.default.removeObserver(self)
            self.wishListArray = obj
            self.objAnimView.removeFromSuperview()
            self.setUpView()
            self.wishListTable?.reloadData()
        }
    }
    //Fail response GetWishlist API
    func errorResponseForGetWishlistAPI(_ error: String) {
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
        objAnimView.removeFromSuperview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        objAnimView.removeFromSuperview()
    }
}
