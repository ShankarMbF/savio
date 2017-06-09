//
//  SACreateSavingPlanViewController.swift
//  Savio
//
//  Created by Prashant on 01/06/16.
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


class SACreateSavingPlanViewController: UIViewController {
    
    //-------------Setup IBOutlets------------------------------------------------------------
    
    @IBOutlet weak var tblView  : UITableView?                  // IBOutlet for tableview
    @IBOutlet weak var scrlView : UIScrollView?                 // IBOutlet for scrollview
    
    @IBOutlet weak var pageControl  : UIPageControl?            // IBOutlet for page control
    @IBOutlet weak var btnWishList  : UIButton?                 // Iboutlet for wishlist button
    @IBOutlet weak var lblLine      : UILabel?
    
    @IBOutlet weak var suggestedTop : NSLayoutConstraint!       // IBOutlet for set top space from scrollview
    @IBOutlet weak var suggestedY   : NSLayoutConstraint!       // IBOutlet for set Y position of lable as per whishlist present
    @IBOutlet weak var suggestedHt  : NSLayoutConstraint!       // IBOutlet for set height of view as per wishlist available or not
    
    @IBOutlet weak var btnVwBg      : UIView!                   // IBOutlet for button background view
    @IBOutlet weak var contentView  : UIView!                   // IBOutlet for scrollview container view

    @IBOutlet weak var verticalScrlView : UIScrollView!         // IBoutlet for wishlist scrollview
    
    //-----------------------------------------------------------------------------------------
    
    
    var objAnimView = ImageViewAnimation() //Object of custom loding indicator
    var heartBtn    : UIButton = UIButton()    //Heart button on navigation bar
    var colors      : [Dictionary<String,AnyObject>]        = []
    var tblArr      : Array<Dictionary<String,AnyObject>>   = []
    
    //Set default placeholder for all saving plan icon image
    var placeHolderImgArr: Array<String> = ["group-save-category-icon","wedding-category-icon","baby-category-icon","holiday-category-icon","ride-category-icon","home-category-icon","gadget-category-icon","generic-category-icon"]
    
    var valueArray : Array<Dictionary<String,AnyObject>> = [
        ["savLogo1x":"group-save-category-icon" as AnyObject,"savLogo2x":"group-save-category-icon" as AnyObject,"savLogo3x":"group-save-category-icon" as AnyObject,"title":"Group goal" as AnyObject,"savDescription":"Set up a goal between friends and family" as AnyObject,"sav-id":"85" as AnyObject],
        ["savLogo1x":"wedding-category-icon" as AnyObject,"savLogo2x":"wedding-category-icon" as AnyObject,"savLogo3x":"wedding-category-icon" as AnyObject,"title":"Wedding" as AnyObject,"savDescription":"Get great deals on everything from flowers to videos" as AnyObject,"sav-id":"86" as AnyObject],
        ["savLogo1x":"baby-category-icon" as AnyObject,"savLogo2x":"baby-category-icon" as AnyObject,"savLogo3x":"baby-category-icon" as AnyObject,"title":"Baby" as AnyObject,"savDescription":"Get everything ready for the new arrival" as AnyObject,"sav-id":"87" as AnyObject],
        ["savLogo1x":"holiday-category-icon" as AnyObject ,"savLogo2x":"holiday-category-icon" as AnyObject,"savLogo3x":"holiday-category-icon" as AnyObject,"title":"Holiday" as AnyObject,"savDescription":"Get your money together to pay for big trip or mini break." as AnyObject,"sav-id":"88" as AnyObject],
        ["savLogo1x":"ride-category-icon" as AnyObject,"savLogo2x":"ride-category-icon" as AnyObject,"savLogo3x":"ride-category-icon" as AnyObject,"title":"Ride" as AnyObject,"savDescription":"There's always room for another bike." as AnyObject,"sav-id":"89" as AnyObject],
        ["savLogo1x":"home-category-icon" as AnyObject,"savLogo2x":"home-category-icon" as AnyObject,"savLogo3x":"home-category-icon" as AnyObject,"title":"Home" as AnyObject,"savDescription":"Time to make that project a reality." as AnyObject,"sav-id":"90" as AnyObject],
        ["savLogo1x":"gadget-category-icon" as AnyObject,"savLogo2x":"gadget-category-icon" as AnyObject,"savLogo3x":"gadget-category-icon" as AnyObject,"title":"Gadget" as AnyObject,"savDescription":"The one thing you really need, from smartphones to sewing machines." as AnyObject,"sav-id":"91" as AnyObject],
        ["savLogo1x":"generic-category-icon" as AnyObject,"savLogo2x":"generic-category-icon" as AnyObject,"savLogo3x":"generic-category-icon" as AnyObject,"title":"Generic plan" as AnyObject,"savDescription":"Not sure yet or just setting some money aside." as AnyObject,"sav-id":"92" as AnyObject]
    ]
    
    let pageArr: Array<String> = ["Page5", "Page1", "Page2", "Page3", "Page4"] //Set up list of page on page controller
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //----------------------------------------Setting navigation Bar-------------------------------------------
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        //------------------------------------------------------------------------------------------------------------
        
        //Register UIApplication Will Enter Foreground Notification
        NotificationCenter.default.addObserver(self, selector:#selector(SACreateSavingPlanViewController.getWishListData(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        tblView?.register(SavingCategoryTableViewCell.self, forCellReuseIdentifier: "SavingCategoryTableViewCell")
        tblView?.separatorInset = UIEdgeInsets.zero
        
        //Setting up UI
        self.setUpView()
        
        //Setting up animation loader
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        
        //--------Call get saving plans and get wishlist API----------
        let objAPI = API()
        objAPI.categorySavingPlanDelegate = self
        objAPI.getCategoriesForSavingPlan()
        self.callWishListAPI()
        //------------------------------------------------------------
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpView()
    }
    
    //Function invoke for call get offer list API
    func callGetOfferListAPI() {
        
        let objAPI = API()
        objAPI.getofferlistDelegate = self
        objAPI.getOfferListForSavingId()
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
    
    //Function invoke when UIApplicationWillEnterForegroundNotification brodcast
    func getWishListData(_ notification:Notification)
    {
        self.callWishListAPI()
    }
    

    //Called to notify the view controller that its view has just laid out its subviews.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        verticalScrlView.contentSize = CGSize(width: UIScreen.main.bounds.width,  height: scrlView!.frame.size.height + tblView!.frame.size.height + suggestedHt.constant)
    }
    
    //Function invoke for Set up the UI
    func setUpView(){
        btnWishList!.layer.cornerRadius = 5
        btnVwBg.layer.cornerRadius = 5
        
        //--------set Navigation left button--------------------
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SACreateSavingPlanViewController.menuButtonClicked), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        //-------------------------------------------------------
        
        self.title = "Create a plan"
        
        //---------------set Navigation right button nav-heart-------------------
        heartBtn.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        heartBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        heartBtn.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        let heartCount:String = String(format: "%d",colors.count)
        heartBtn.setTitle(heartCount, for: UIControlState())
        heartBtn.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        heartBtn.addTarget(self, action: #selector(SACreateSavingPlanViewController.heartBtnClicked), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = heartBtn
        self.navigationItem.rightBarButtonItem = rightBarButton
        //------------------------------------------------------------------------
        
        self.configureScrollView()
    }
    
    //Set up scrollview as per the wishlist availability
    func configureScrollView() {
        //--------Remove all subview from scrollview-----------
        if self.scrlView!.subviews.count > 0 {
            for subview in self.scrlView!.subviews{
                subview.removeFromSuperview()
            }
        }
        //------------------------------------------------------
        
        // Enable paging.
        scrlView!.isPagingEnabled = true
        // Set the following flag values.
        scrlView!.showsHorizontalScrollIndicator = false
        scrlView!.showsVerticalScrollIndicator = false
        scrlView!.scrollsToTop = false
        
        // Set the scrollview content size.
        if(colors.count >= 5)
        {
            scrlView!.contentSize = CGSize(width: UIScreen.main.bounds.size.width * 5, height: 0)
        }
        else
        {
            scrlView!.contentSize = CGSize(width: UIScreen.main.bounds.size.width * CGFloat(colors.count), height: 0)
        }
        // Load the PageView view from the SavingPageView.xib file and configure it properly.
        if colors.count > 0{
            
            let dataSave = NSKeyedArchiver.archivedData(withRootObject: colors)
            userDefaults.set(dataSave, forKey: "wishlistArray")
            userDefaults.synchronize()
            
            if(colors.count >= 5)
            {
                for i in 0 ..< 5 {
                    heartBtn.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), for: UIControlState())
                    heartBtn.setTitleColor(UIColor.black, for: UIControlState())
//                    let dataSave = NSKeyedArchiver.archivedDataWithRootObject(colors)
                    
//                    NSuserDefaultsUserDefaults().setObject(dataSave, forKey: "wishlistArray")
//                    NSuserDefaultsUserDefaults().synchronize()
                    
                    // Load the TestView view.
                    let testView = Bundle.main.loadNibNamed("SavingPageView", owner: self, options: nil)![0] as! UIView
                    
                    // Set its frame and data to pageview
                    testView.frame = CGRect(x: CGFloat(i) * UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: scrlView!.frame.size.height)
                    let vw = testView.viewWithTag(2)! as UIView
                    vw.layer.borderWidth = 1
                    vw.layer.borderColor = UIColor.white.cgColor
                    
                    // Get individual product from wishlist
                    let objDict = colors[i] as Dictionary<String,AnyObject>
                    
                    let lblNoWishList = testView.viewWithTag(5)! as! UILabel
                    lblNoWishList.isHidden = true
                    
                    //----------show product title--------------------
                    let lblTitle = testView.viewWithTag(3)! as! UILabel
                    lblTitle.text = objDict[kTitle] as? String
                    lblTitle.isHidden = false
                    //-----------------------------------------------
                    
                    //-----------Show product cost-------------------
                    let lblCost = testView.viewWithTag(4)! as! UILabel
                    if(objDict[kAmount] is String)
                    {
                        lblCost.text = objDict[kAmount] as? String
                    }
                    else
                    {
                        lblCost.text = String(format: "%d", (objDict[kAmount] as! NSNumber).int32Value)
                    }
                    //----------------------------------------------------
                    
                    //------------------Showing image of wishlist product---------------
                    let bgImageView = testView.viewWithTag(1) as! UIImageView
                    if let urlString = objDict[kImageURL] as? String
                    {
                        if(urlString != "")
                        {
                            //Get product URL
                            let url = URL(string:urlString)
                            let request: URLRequest = URLRequest(url: url!)
                            
                            // fetch image data from url
                            
                            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                                print("Response: \(String(describing: response))")
                                if(data != nil && data?.count > 0)
                                {
                                    //showing image if data available
                                    let image = UIImage(data: data!)
                                    DispatchQueue.main.async(execute: {
                                        bgImageView.image = image
                                    })
                                }
                            })
                            task.resume()
                        }
                    }
                    
                    //---------------------------------------------------------------------
                    let imgEuro = testView.viewWithTag(6)! as! UIImageView
                    imgEuro.isHidden = false
                    
                    suggestedHt.constant = 113.0
                    suggestedTop.constant = 16.0
                    btnWishList?.isHidden = false
                    pageControl?.isHidden = false
                    btnVwBg.isHidden = false
                    
                    //---------show at most 5 latest products to scrollview---------
                    if(colors.count >= 5)
                    {
                        pageControl?.numberOfPages = 5
                    } else
                    {
                        pageControl?.numberOfPages = colors.count
                    }
                    lblLine?.isHidden = false
                    
                    // Add the test view as a subview to the scrollview.
                    scrlView!.addSubview(testView)
                    //-------------------------------------------------------------
                }
            }
            else {
                for i in 0 ..< colors.count {
                    heartBtn.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), for: UIControlState())
                    heartBtn.setTitleColor(UIColor.black, for: UIControlState())
//                    let dataSave = NSKeyedArchiver.archivedDataWithRootObject(colors)
                    
//                    NSuserDefaultsUserDefaults().setObject(dataSave, forKey: "wishlistArray")
//                    NSuserDefaultsUserDefaults().synchronize()
                    
                    // Load the TestView view.
                    let testView = Bundle.main.loadNibNamed("SavingPageView", owner: self, options: nil)![0] as! UIView
                    // Set its frame and data to pageview
                    testView.frame = CGRect(x: CGFloat(i) * UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: scrlView!.frame.size.height)
                    let vw = testView.viewWithTag(2)! as UIView
                    vw.layer.borderWidth = 1
                    vw.layer.borderColor = UIColor.white.cgColor
                    
                    let objDict = colors[i] as Dictionary<String,AnyObject>
                    
                    let lblNoWishList = testView.viewWithTag(5)! as! UILabel
                    lblNoWishList.isHidden = true
                    
                    let lblTitle = testView.viewWithTag(3)! as! UILabel
                    lblTitle.text = objDict[kTitle] as? String
                    lblTitle.isHidden = false
                    
                    let lblCost = testView.viewWithTag(4)! as! UILabel
                    
                    if(objDict[kAmount] is String)
                    {
                        lblCost.text = objDict[kAmount] as? String
                    } else
                    {
                        lblCost.text = String(format: "%d", (objDict[kAmount] as! NSNumber).int32Value)
                    }
                    
                    
                    let bgImageView = testView.viewWithTag(1) as! UIImageView
                    if let urlString = objDict[kImageURL] as? String
                    {
                        
                        if(urlString != "")
                        {
                            let url = URL(string:urlString)
                            let request: URLRequest = URLRequest(url: url!)
                            
                            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                                print("Response: \(String(describing: response))")
                                
                                if(data != nil && data?.count > 0)
                                {
                                    let image = UIImage(data: data!)
                                    
                                    DispatchQueue.main.async(execute: {
                                        bgImageView.image = image
                                    })
                                }
                            })
                            
                            task.resume()
                        }
                    }
                    
                    let imgEuro = testView.viewWithTag(6)! as! UIImageView
                    imgEuro.isHidden = false
                    
                    suggestedHt.constant = 113.0
                    suggestedTop.constant = 16.0
                    btnWishList?.isHidden = false
                    pageControl?.isHidden = false
                    btnVwBg.isHidden = false
                    if(colors.count >= 5)
                    {
                        pageControl?.numberOfPages = 5
                    }
                    else {
                        pageControl?.numberOfPages = colors.count
                    }
                    
                    lblLine?.isHidden = false
                    
                    // Add the test view as a subview to the scrollview.
                    scrlView!.addSubview(testView)
                }
            }
        }
        else {
            
            //--------------If whishlist is empty setup UI--------------------------------------------
            userDefaults.set(colors, forKey: "wishlistArray")
            userDefaults.synchronize()
            
            scrlView!.contentSize = CGSize(width: UIScreen.main.bounds.size.width , height: 0)
            let testView = Bundle.main.loadNibNamed("SavingPageView", owner: self, options: nil)![0] as! UIView
            
            // Set its frame and data to pageview
            testView.frame = CGRect(x: scrlView!.bounds.origin.x, y: 0, width: scrlView!.frame.size.width, height: scrlView!.frame.size.height)
            let vw = testView.viewWithTag(2)! as UIView
            vw.layer.borderWidth = 1
            vw.layer.borderColor = UIColor.white.cgColor
            let lblNoWishList = testView.viewWithTag(5)! as! UILabel
            lblNoWishList.isHidden = false
            let lblTitle = testView.viewWithTag(3)! as! UILabel
            lblTitle.isHidden = true
            
            let lblCost = testView.viewWithTag(4)! as! UILabel
            lblCost.isHidden = true
            
            let imgEuro = testView.viewWithTag(6)! as! UIImageView
            imgEuro.isHidden = true
            
            //-----Set topspace and height of view if empty wishlist-----
            suggestedHt.constant = 50.0
            suggestedTop.constant = -52.0
            //--------------------------------------------------------
            btnVwBg.isHidden = true
            btnWishList?.isHidden = true
            pageControl?.isHidden = true
            lblLine?.isHidden = true
            // Add the SavingPageView as a subview to the scrollview.
            scrlView!.addSubview(testView)
            //---------------------------------------------------------------------------------------
        }
    }
    
    
    //Function invoking for configure the page control for animated pages
    func configurePageControl() {
        // Set the total pages to the page control.
        pageControl!.numberOfPages = 5
        // Set the initial page.
        pageControl!.currentPage = 0
    }
    
    // MARK: UIScrollViewDelegate method implementation
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.main.bounds.size.width);
        // Set the new page index to the page control.
        pageControl!.currentPage = Int(currentPage)
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        //Brodcast notification for toggle menu
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    
    func heartBtnClicked(){
        if colors.count>0{
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")
        }
        else {
            AlertContoller(UITitle: kWishlistempty, UIMessage: kEmptyWishListMessage)
        }
    }
    
    // MARK: IBAction method implementation
    @IBAction func changePage(_ sender: AnyObject) {
        // Calculate the frame that should scroll to based on the page control current page.
        var newFrame = scrlView!.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl!.currentPage)
        scrlView!.scrollRectToVisible(newFrame, animated: true)
    }
    
    @IBAction func clickedOnWishListButton(_ sender:UIButton){
        NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")
    }
    
    

    
    //Function invoke for calculating height of lable as per given text, font and width
    func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    
    
    
    //function checking any key is null and return not null values in dictionary
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
    
   
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//  MARK:- TableView Delegate and Datasource method

extension SACreateSavingPlanViewController : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tblArr.count - 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = Bundle.main.loadNibNamed("SavingCategoryTableViewCell", owner: nil, options: nil)![0] as! SavingCategoryTableViewCell
        let cellDict = tblArr[indexPath.row]
        cell.layoutMargins = UIEdgeInsets.zero
        cell.lblHeader!.text = cellDict[kTitle] as? String;
        cell.suggestedHt.constant = self.heightForView((cellDict["savDescription"] as? String)!, font: UIFont(name: kLightFont, size: 11)!, width: (cell.lblDetail?.frame.size.width)!)
        cell.lblDetail?.text = cellDict["savDescription"] as? String
        cell.imgView?.image = UIImage(named: placeHolderImgArr[indexPath.row])  //placeHolderImgArr[indexPath.row]
        
        cell.imgView?.image = UIImage(named: placeHolderImgArr[indexPath.row])
        if (cellDict["savLogo1x"] != nil){
            
            let request: URLRequest = URLRequest(url: URL(string:cellDict["savLogo1x"] as! String)!)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                print("Response: \(String(describing: response))")
                if(data != nil)
                {
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async(execute: {
                        if image != nil {
                            cell.imgView?.image = image
                        }
                    })
                }
            })
            task.resume()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == tblArr.count - 1) {
            return 200.0
        }
        return 79.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Check If any plan is created by login user
        if(userDefaults.object(forKey: kIndividualPlan) as? NSNumber == 1 || userDefaults.object(forKey: kGroupPlan) as? NSNumber == 1)
        {
            //if plan already created then restrict user to create all plan
            AlertContoller(UITitle: "You already have an active plan", UIMessage: "Sorry, can only have one personal plan and be a member of one group plan at a time.")
        }
        else
        {
            //If plan is not created then allow user to create plan
            userDefaults.set(self.checkNullDataFromDict(tblArr[indexPath.row]), forKey:"colorDataDict")
            userDefaults.synchronize()
            if(indexPath.row == 0)
            {
                let objGroupSavingPlanViewController = GroupsavingViewController(nibName: "GroupsavingViewController",bundle: nil)
                self.navigationController?.pushViewController(objGroupSavingPlanViewController, animated: true)
            }
            else
            {
                userDefaults.set( self.checkNullDataFromDict(tblArr[indexPath.row]), forKey:"colorDataDict")
                userDefaults.synchronize()
                if(indexPath.row == 0)
                {
                    let objGroupSavingPlanViewController = GroupsavingViewController(nibName: "GroupsavingViewController",bundle: nil)
                    self.navigationController?.pushViewController(objGroupSavingPlanViewController, animated: true)
                }
                else
                {
                    let objSavingPlanViewController = SASavingPlanViewController(nibName: "SASavingPlanViewController",bundle: nil)
                    self.navigationController?.pushViewController(objSavingPlanViewController, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if( tblView!.responds(to: #selector(setter: UITableViewCell.separatorInset))){
            tblView!.separatorInset = UIEdgeInsets.zero
        }
        if( tblView!.responds(to: #selector(setter: UIView.layoutMargins))){
            tblView!.layoutMargins = UIEdgeInsets.zero
        }
        if(cell.responds(to: #selector(setter: UIView.layoutMargins))){
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
}

//  MARK:- Delegate method for GetWishlist
//  FIXME:  Check the wishlist Offer Array


extension SACreateSavingPlanViewController : GetWishlistDelegate {

    func successResponseForGetWishlistAPI(_ objResponse: Dictionary<String, AnyObject>) {
        if let error = objResponse["error"] as? String
        {
            AlertContoller(UITitle: nil, UIMessage: error)
        }
        else
        {
            let wishListResponse = self.checkNullDataFromDict(objResponse)
            colors = wishListResponse["wishListList"] as! Array<Dictionary<String,AnyObject>>
            print(wishListResponse)
            self.setUpView()
        }
        if let arr =  userDefaults.value(forKey: "offerList") as? Array<Dictionary<String,AnyObject>>{
            if arr.count > 0{
                objAnimView.removeFromSuperview()
            }
        }
    }
    
    //function invoke when GetWishlist API request fail
    func errorResponseForGetWishlistAPI(_ error: String) {
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            AlertContoller(UITitle: kConnectionProblemTitle, UIMessage: kNoNetworkMessage)
        } else {
            AlertContoller(UITitle: kConnectionProblemTitle, UIMessage: kTimeOutNetworkMessage)
        }
    }

}


//  MARK:-  Delegate method for GetOfferlistAPI

extension SACreateSavingPlanViewController : GetOfferlistDelegate {

    func successResponseForGetOfferlistAPI(_ objResponse:Dictionary<String,AnyObject>){
        
        var offerArr : Array<Dictionary<String,AnyObject>> = objResponse["offerList"] as! Array<Dictionary<String,AnyObject>>
        var arr : Array<Dictionary<String,AnyObject>> = []
        
        for i in 0 ..< offerArr.count {
            let dict = self.checkNullDataFromDict(offerArr[i] as Dictionary<String,AnyObject>)
            arr.append(dict)
        }
        
        userDefaults.set(arr, forKey: "offerList")
        userDefaults.synchronize()
        objAnimView.removeFromSuperview()
    }
    
    //function invoke when GetOfferlist API request fail
    func errorResponseForGetOfferlistAPI(_ error:String){
        objAnimView.removeFromSuperview()
    }

}


//  MARK:-  Delegate method for GetCategorySavingPlan

extension SACreateSavingPlanViewController : CategoriesSavingPlan {

    func successResponseForCategoriesSavingPlanAPI(_ objResponse: Dictionary<String, AnyObject>) {
        //setup UI and reload tableview
        print(objResponse)
        if let tblArray = (objResponse["savingPlanList"] as? Array<Dictionary<String,AnyObject>>)
        {
            tblArr = tblArray
            if(tblArr.count != 0)
            {
                for i in 0 ..< tblArr.count {
                    let dict = tblArr[i] as Dictionary<String,AnyObject>
                    if(dict[kTitle] as! String == "Group Save")
                    {
                        userDefaults.set(dict["savPlanID"], forKey: "savPlanID")
                        userDefaults.synchronize()
                    }
                }
            }
            else {
                tblArr = valueArray
            }
            self.setUpView()
            tblView?.scrollsToTop = true
            tblView?.reloadData()
            //Call get method of offer list
            self.callGetOfferListAPI()
            
        }
        
    }
    
    //function invoke when GetCategorysavingPlan API request fail
    func errorResponseForCategoriesSavingPlanAPI(_ error: String) {
        objAnimView.removeFromSuperview()
        if(error == kNonetworkfound)
        {
            AlertContoller(UITitle: kConnectionProblemTitle, UIMessage: kNonetworkfound)
        }
        else {
            AlertContoller(UITitle: kConnectionProblemTitle, UIMessage: kTimeOutNetworkMessage)
        }
    }

}

