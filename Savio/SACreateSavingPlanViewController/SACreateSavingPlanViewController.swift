//
//  SACreateSavingPlanViewController.swift
//  Savio
//
//  Created by Prashant on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SACreateSavingPlanViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GetWishlistDelegate{
    @IBOutlet weak var lblBoostedView: UIView?
    @IBOutlet weak var tblView: UITableView?
    @IBOutlet weak var scrlView: UIScrollView?
    @IBOutlet weak var pageControl: UIPageControl?
    @IBOutlet weak var btnWishList: UIButton?
    @IBOutlet weak var lblLine: UILabel?
    
    @IBOutlet weak var suggestedTop: NSLayoutConstraint!
    @IBOutlet weak var suggestedY: NSLayoutConstraint!
    @IBOutlet weak var suggestedHt: NSLayoutConstraint!
    
    var objAnimView = ImageViewAnimation()

    
    var heartBtn: UIButton = UIButton()
    var colors:[Dictionary<String,AnyObject>] = []
    var tblArr : Array<Dictionary<String,AnyObject>> = [["image":"group-save-category-icon","header":"Group Save","detail":"Set up savings goal between friends and family","sav-id":"8"]
        ,["image":"wedding-category-icon","header":"Wedding","detail":"Get great deals on everything from flowers to videos","sav-id":"1"]
        ,["image":"baby-category-icon","header":"Baby","detail":"Get everything ready for the new arrival","sav-id":"2"],
         ["image":"holiday-category-icon","header":"Holiday","detail":"Save up or some sunshine!","sav-id":"3"],
         ["image":"ride-category-icon","header":"Ride","detail":"There's always room for another bike.","sav-id":"4"],
         ["image":"home-category-icon","header":"Home","detail":"Time to make that project a reality.","sav-id":"5"],
         ["image":"gadget-category-icon","header":"Gadget","detail":"The one thing you really need, from smartphones to sewing machines.","sav-id":"6"],
         ["image":"generic-category-icon","header":"Generic plan","detail":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","sav-id":"7"]]
    let pageArr: Array<String> = ["Page5", "Page1", "Page2", "Page3", "Page4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        tblView?.registerClass(SavingCategoryTableViewCell.self, forCellReuseIdentifier: "SavingCategoryTableViewCell")
        self.setUpView()
      
    }
    override func viewWillAppear(animated: Bool) {
     super.viewWillAppear(animated)
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        
        self.view.addSubview(objAnimView)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    func setUpView(){
        btnWishList!.layer.shadowColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        btnWishList!.layer.shadowOffset = CGSizeMake(0, 2)
        btnWishList!.layer.shadowOpacity = 1
        btnWishList!.layer.cornerRadius = 5
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: #selector(SACreateSavingPlanViewController.menuButtonClicked), forControlEvents: .TouchUpInside)
        
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
        heartBtn.addTarget(self, action: #selector(SACreateSavingPlanViewController.heartBtnClicked), forControlEvents: .TouchUpInside)
        
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

                NSUserDefaults.standardUserDefaults().setObject(colors, forKey: "wishlistArray")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                // Load the TestView view.
                let testView = NSBundle.mainBundle().loadNibNamed("SavingPageView", owner: self, options: nil)[0] as! UIView
                // Set its frame and data to pageview
                testView.frame = CGRectMake(CGFloat(i) * UIScreen.mainScreen().bounds.size.width, -64, UIScreen.mainScreen().bounds.size.width, scrlView!.frame.size.height)
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
               
                let data :NSData = NSData(base64EncodedString: objDict["imageURL"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                
                let bgImageView = testView.viewWithTag(1) as! UIImageView
                bgImageView.image = UIImage(data: data)
                lblCost.hidden = false
                
                let imgEuro = testView.viewWithTag(6)! as! UIImageView
                imgEuro.hidden = false
                
                suggestedHt.constant = 113.0
                suggestedTop.constant = 16.0
                btnWishList?.hidden = false
                pageControl?.hidden = false
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
            scrlView!.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width , 0)
            let testView = NSBundle.mainBundle().loadNibNamed("SavingPageView", owner: self, options: nil)[0] as! UIView
            // Set its frame and data to pageview
            testView.frame = CGRectMake(scrlView!.bounds.origin.x, -64, scrlView!.frame.size.width, scrlView!.frame.size.height)
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
        //        let objAPI = API()
        //        //  let userDict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        //        objAPI.getWishlistDelegate = self
        //        objAPI.getWishListForUser("196")
    }
    
    func heartBtnClicked(){
        if colors.count>0{
            
            let objSAWishListViewController = SAWishListViewController()
            objSAWishListViewController.wishListArray = colors
            self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
        }
        else{
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "OK")
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
        objSAWishListViewController.wishListArray = colors
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
        //        let cell = tableView.dequeueReusableCellWithIdentifier("SavingCategoryTableViewCell") as? SavingCategoryTableViewCell
        //        if cell == nil {
        let bundleArr : Array = NSBundle.mainBundle().loadNibNamed("SavingCategoryTableViewCell", owner: nil, options: nil) as Array
        let cell = bundleArr[0] as! SavingCategoryTableViewCell
        //        }
        let cellDict = tblArr[indexPath.row]
        print(cellDict["header"])
        cell.lblHeader!.text = cellDict["header"] as? String;
        cell.lblDetail?.text = cellDict["detail"] as? String
        cell.imgView?.image = UIImage(named: cellDict["image"] as! String)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 79.0
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(tblArr[indexPath.row])
        if(indexPath.row == 0)
        {
            let alert = UIAlertView(title: "Alert", message: "Work in progress", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        else
        {
            NSUserDefaults.standardUserDefaults().setObject(tblArr[indexPath.row], forKey:"colorDataDict")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            let objSavingPlanViewController = SASavingPlanViewController(nibName: "SASavingPlanViewController",bundle: nil)
            self.navigationController?.pushViewController(objSavingPlanViewController, animated: true)
        }

    }
    
    //MARK: GetWishlist Delegate and Datasource method
    
    func successResponseForGetWishlistAPI(objResponse: Dictionary<String, AnyObject>) {
       
        colors = objResponse["wishListList"] as! Array<Dictionary<String,AnyObject>>
        self.setUpView()
        objAnimView.removeFromSuperview()
    }
    
    func errorResponseForGetWishlistAPI(error: String) {
        print(error)
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
