//
//  SACreateSavingPlanViewController.swift
//  Savio
//
//  Created by Prashant on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SACreateSavingPlanViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GetWishlistDelegate,CategoriesSavingPlan, GetOfferlistDelegate{
    @IBOutlet weak var lblBoostedView: UIView?
    @IBOutlet weak var tblView: UITableView?
    @IBOutlet weak var scrlView: UIScrollView?
    @IBOutlet weak var pageControl: UIPageControl?
    @IBOutlet weak var btnWishList: UIButton?
    @IBOutlet weak var lblLine: UILabel?
    
    @IBOutlet weak var suggestedTop: NSLayoutConstraint!
    @IBOutlet weak var suggestedY: NSLayoutConstraint!
    @IBOutlet weak var suggestedHt: NSLayoutConstraint!
    
    @IBOutlet weak var verticalScrlView: UIScrollView!
    var objAnimView = ImageViewAnimation()
    
    @IBOutlet weak var btnVwBg: UIView!
    
    @IBOutlet weak var contentView: UIView!
    var heartBtn: UIButton = UIButton()
    var colors:[Dictionary<String,AnyObject>] = []
    var placeHolderImgArr: Array<String> = ["group-save-category-icon","wedding-category-icon","baby-category-icon","holiday-category-icon","ride-category-icon","home-category-icon","gadget-category-icon","generic-category-icon"]
    var tblArr : Array<Dictionary<String,AnyObject>> = [["savLogo1x":"group-save-category-icon","savLogo2x":"group-save-category-icon","savLogo3x":"group-save-category-icon","header":"Group Save","detail":"Set up savings goal between friends and family","sav-id":"8"]
        ,["savLogo1x":"wedding-category-icon","savLogo2x":"wedding-category-icon","savLogo3x":"wedding-category-icon","header":"Wedding","detail":"Get great deals on everything from flowers to videos","sav-id":"1"]
        ,["savLogo1x":"baby-category-icon","savLogo2x":"baby-category-icon","savLogo3x":"baby-category-icon","header":"Baby","detail":"Get everything ready for the new arrival","sav-id":"2"],
         ["savLogo1x":"holiday-category-icon","savLogo2x":"holiday-category-icon","savLogo3x":"holiday-category-icon","header":"Holiday","detail":"Save up or some sunshine!","sav-id":"3"],
         ["savLogo1x":"ride-category-icon","savLogo2x":"ride-category-icon","savLogo3x":"ride-category-icon","header":"Ride","detail":"There's always room for another bike.","sav-id":"4"],
         ["savLogo1x":"home-category-icon","savLogo2x":"home-category-icon","savLogo3x":"home-category-icon","header":"Home","detail":"Time to make that project a reality.","sav-id":"5"],
         ["savLogo1x":"gadget-category-icon","savLogo2x":"gadget-category-icon","savLogo3x":"gadget-category-icon","header":"Gadget","detail":"The one thing you really need, from smartphones to sewing machines.","sav-id":"6"],
         ["savLogo1x":"generic-category-icon","savLogo2x":"generic-category-icon","savLogo3x":"generic-category-icon","header":"Generic plan","detail":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","sav-id":"7"]]
    let pageArr: Array<String> = ["Page5", "Page1", "Page2", "Page3", "Page4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("getWishListData"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        tblView?.registerClass(SavingCategoryTableViewCell.self, forCellReuseIdentifier: "SavingCategoryTableViewCell")
        tblView?.separatorInset = UIEdgeInsetsZero
        self.setUpView()
        
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        
        let objAPI = API()
        
        objAPI.categorySavingPlanDelegate = self
        objAPI.getCategoriesForSavingPlan()
        
        self.callWishListAPI()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpView()
    }
    
    func callGetOfferListAPI() {
        let objAPI = API()
        objAPI.getofferlistDelegate = self
        objAPI.getOfferListForSavingId()
        
    }
    
    func callWishListAPI()
    {
        let objAPI = API()
        let userDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        objAPI.getWishlistDelegate = self
        
        if(userDict["partyId"] is String)
        {
            objAPI.getWishListForUser(userDict["partyId"] as! String)
        }
        else
        {
            objAPI.getWishListForUser(String(format: "%d",((userDict["partyId"] as? NSNumber)?.doubleValue)!))
        }
        
    }
    
    func getWishListData(notification:NSNotification)
    {
        self.callWishListAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        verticalScrlView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width,  scrlView!.frame.size.height + tblView!.frame.size.height + suggestedHt.constant)
    }
    
    
    func setUpView(){
        //        btnWishList!.layer.shadowColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        //        btnWishList!.layer.shadowOffset = CGSizeMake(0, 2)
        //        btnWishList!.layer.shadowOpacity = 1
        btnWishList!.layer.cornerRadius = 5
        
        btnVwBg.layer.cornerRadius = 5
        
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "Create a saving plan"
        //set Navigation right button nav-heart
        
        heartBtn.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        heartBtn.frame = CGRectMake(0, 0, 30, 30)
        heartBtn.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        let heartCount:String = String(format: "%d",colors.count)
        heartBtn.setTitle(heartCount, forState: UIControlState.Normal)
        heartBtn.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        heartBtn.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = heartBtn
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.configureScrollView()
    }
    
    func configureScrollView() {
        if self.scrlView!.subviews.count > 0 {
            for subview in self.scrlView!.subviews{
                subview.removeFromSuperview()
            }
        }
        
        // Enable paging.
        scrlView!.pagingEnabled = true
        // Set the following flag values.
        scrlView!.showsHorizontalScrollIndicator = false
        scrlView!.showsVerticalScrollIndicator = false
        scrlView!.scrollsToTop = false
        
        // Set the scrollview content size.
        scrlView!.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width * CGFloat(colors.count), 0)
        // Load the PageView view from the TestView.xib file and configure it properly.
        
        
        if colors.count > 0{
            for i in 0 ..< colors.count {
                heartBtn.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                heartBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                let dataSave = NSKeyedArchiver.archivedDataWithRootObject(colors)
                
                NSUserDefaults.standardUserDefaults().setObject(dataSave, forKey: "wishlistArray")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                // Load the TestView view.
                let testView = NSBundle.mainBundle().loadNibNamed("SavingPageView", owner: self, options: nil)[0] as! UIView
                // Set its frame and data to pageview
                testView.frame = CGRectMake(CGFloat(i) * UIScreen.mainScreen().bounds.size.width, 0, UIScreen.mainScreen().bounds.size.width, scrlView!.frame.size.height)
                let vw = testView.viewWithTag(2)! as UIView
                vw.layer.borderWidth = 1
                vw.layer.borderColor = UIColor.whiteColor().CGColor
                
                let objDict = colors[i] as Dictionary<String,AnyObject>
                
                let lblNoWishList = testView.viewWithTag(5)! as! UILabel
                lblNoWishList.hidden = true
                
                let lblTitle = testView.viewWithTag(3)! as! UILabel
                lblTitle.text = objDict["title"] as? String
                lblTitle.hidden = false
                
                let lblCost = testView.viewWithTag(4)! as! UILabel
                
                if(objDict["amount"] is String)
                {
                    lblCost.text = objDict["amount"] as? String
                }
                else
                {
                    lblCost.text = String(format: "%d", (objDict["amount"] as! NSNumber).intValue)
                }
                
                
                let bgImageView = testView.viewWithTag(1) as! UIImageView
                
                let url = NSURL(string:objDict["imageURL"] as! String)
                
                let request: NSURLRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                    let image = UIImage(data: data!)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        bgImageView.image = image
                    })
                })
                
                
                let imgEuro = testView.viewWithTag(6)! as! UIImageView
                imgEuro.hidden = false
                
                suggestedHt.constant = 113.0
                suggestedTop.constant = 16.0
                btnWishList?.hidden = false
                pageControl?.hidden = false
                btnVwBg.hidden = false
                if(colors.count >= 5)
                {
                    pageControl?.numberOfPages = 5
                }
                else{
                    pageControl?.numberOfPages = colors.count
                }
                
                lblLine?.hidden = false
                
                // Add the test view as a subview to the scrollview.
                scrlView!.addSubview(testView)
            }
        }
        else{
            NSUserDefaults.standardUserDefaults().setObject(colors, forKey: "wishlistArray")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            scrlView!.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width , 0)
            let testView = NSBundle.mainBundle().loadNibNamed("SavingPageView", owner: self, options: nil)[0] as! UIView
            // Set its frame and data to pageview
            testView.frame = CGRectMake(scrlView!.bounds.origin.x, 0, scrlView!.frame.size.width, scrlView!.frame.size.height)
            let vw = testView.viewWithTag(2)! as UIView
            vw.layer.borderWidth = 1
            vw.layer.borderColor = UIColor.whiteColor().CGColor
            let lblNoWishList = testView.viewWithTag(5)! as! UILabel
            lblNoWishList.hidden = false
            let lblTitle = testView.viewWithTag(3)! as! UILabel
            lblTitle.hidden = true
            
            let lblCost = testView.viewWithTag(4)! as! UILabel
            lblCost.hidden = true
            
            let imgEuro = testView.viewWithTag(6)! as! UIImageView
            imgEuro.hidden = true
            
            suggestedHt.constant = 50.0
            suggestedTop.constant = -52.0
            btnVwBg.hidden = true
            btnWishList?.hidden = true
            pageControl?.hidden = true
            lblLine?.hidden = true
            // Add the test view as a subview to the scrollview.
            scrlView!.addSubview(testView)
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
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
        
        // Set the new page index to the page control.
        pageControl!.currentPage = Int(currentPage)
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        if colors.count>0{
            
            let objSAWishListViewController = SAWishListViewController()
            self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
        }
        else{
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
        //        let objSAWishListViewController = SAWishListViewController()
        //        self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
    }
    
    // MARK: IBAction method implementation
    @IBAction func changePage(sender: AnyObject) {
        // Calculate the frame that should scroll to based on the page control current page.
        var newFrame = scrlView!.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl!.currentPage)
        scrlView!.scrollRectToVisible(newFrame, animated: true)
    }
    
    @IBAction func clickedOnWishListButton(sender:UIButton){
        print("Clicked on Wishlist button")
        let objSAWishListViewController = SAWishListViewController()
        //objSAWishListViewController.wishListArray = colors
        self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
    }
    
    
    //MARK: TableView Delegate and Datasource method
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tblArr.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let bundleArr : Array = NSBundle.mainBundle().loadNibNamed("SavingCategoryTableViewCell", owner: nil, options: nil) as Array
        let cell = bundleArr[0] as! SavingCategoryTableViewCell
        let cellDict = tblArr[indexPath.row]
        cell.layoutMargins = UIEdgeInsetsZero
        cell.lblHeader!.text = cellDict["title"] as? String;
        cell.lblDetail?.text = cellDict["savDescription"] as? String
        cell.imgView?.image = UIImage(named: placeHolderImgArr[indexPath.row])  //placeHolderImgArr[indexPath.row]
        
        cell.imgView?.image = UIImage(named: placeHolderImgArr[indexPath.row])
        if (cellDict["savLogo1x"] != nil){
            let request: NSURLRequest = NSURLRequest(URL: NSURL(string:cellDict["savLogo1x"] as! String)!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if(data != nil)
                {
                    let image = UIImage(data: data!)
                    dispatch_async(dispatch_get_main_queue(), {
                        if image != nil {
                            cell.imgView?.image = image
                        }
                    })
                }
            })
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 79.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("SavingPlanPresent") as? String
        {
            if(str == "PartySavingPlanExist" || str == "GroupSaving PlanExist")
            { let alert = UIAlertView(title: "Alert", message: "You have already created one saving plan.", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else
            {
                NSUserDefaults.standardUserDefaults().setObject(tblArr[indexPath.row], forKey:"colorDataDict")
                NSUserDefaults.standardUserDefaults().synchronize()
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
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if( tblView!.respondsToSelector(Selector("setSeparatorInset:"))){
            tblView!.separatorInset = UIEdgeInsetsZero
        }
        
        if( tblView!.respondsToSelector(Selector("setLayoutMargins:"))){
            tblView!.layoutMargins = UIEdgeInsetsZero
        }
        
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    //MARK: GetCategorysavingPlan Delegate and Datasource method
    
    func successResponseForCategoriesSavingPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        self.setUpView()
        tblView?.scrollsToTop = true
        tblView?.reloadData()
        
        if let tblArray = (objResponse["savingPlanList"] as? Array<Dictionary<String,AnyObject>>)
        {
            tblArr = tblArray
            self.setUpView()
            tblView?.scrollsToTop = true
            tblView?.reloadData()
            self.callGetOfferListAPI()
        }
        
        
    }
    func errorResponseForCategoriesSavingPlanAPI(error: String) {
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        
    }
    
    
    //MARK: GetWishlist Delegate and Datasource method
    
    func successResponseForGetWishlistAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if let error = objResponse["error"] as? String
        {
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else
        {
            colors = objResponse["wishListList"] as! Array<Dictionary<String,AnyObject>>
            self.setUpView()
        }
        objAnimView.removeFromSuperview()
    }
    
    func errorResponseForGetWishlistAPI(error: String) {
        print(error)
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView.removeFromSuperview()
    }
    
    func successResponseForGetOfferlistAPI(objResponse:Dictionary<String,AnyObject>){
        //print(objResponse)
        objAnimView.removeFromSuperview()
        var offerArr:Array<Dictionary<String,AnyObject>> = objResponse["offerList"] as! Array<Dictionary<String,AnyObject>>
        var arr: Array<Dictionary<String,AnyObject>> = []
        for var i = 0; i < offerArr.count; i++ {
            let dict = self.checkNullDataFromDict(offerArr[i] as Dictionary<String,AnyObject>)
            arr.append(dict)
        }
        NSUserDefaults.standardUserDefaults().setObject(arr, forKey: "offerList")
        NSUserDefaults.standardUserDefaults().synchronize()

    }

    func checkNullDataFromDict(dict:Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject> {
        var replaceDict: Dictionary<String,AnyObject> = dict
        let blank = ""
        for var key:String in Array(dict.keys) {
            let ob = dict[key]! as? AnyObject
            
            if (ob is NSNull)  || ob == nil {
                replaceDict[key] = blank
            }
            else if (ob is Dictionary<String,AnyObject>) {
                replaceDict[key] = self.checkNullDataFromDict(ob as! Dictionary<String,AnyObject>)
            }
            else if (ob is Array<Dictionary<String,AnyObject>>) {
                
            }
        }
        return replaceDict
    }
    
    
    
    //    const NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:self];
    //    const id nul = [NSNull null];
    //    const NSString *blank = @"";
    //
    //    for (NSString *key in self.allKeys) {
    //    const id object = [self objectForKey:key];
    //    if (object == nul) {
    //    [replaced setObject:blank forKey:key];
    //    } else if ([object isKindOfClass:[NSDictionary class]]) {
    //    [replaced setObject:[(NSDictionary *)object dictionaryByReplacingNullsWithStrings] forKey:key];
    //    } else if ([object isKindOfClass:[NSArray class]]) {
    //
    //    }
    //    }
    
    
    
    func errorResponseForGetOfferlistAPI(error:String){
        objAnimView.removeFromSuperview()
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
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
