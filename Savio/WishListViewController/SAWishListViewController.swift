//
//  SAWishListViewController.swift
//  Savio
//
//  Created by Prashant on 04/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAWishListViewController: UIViewController,GetWishlistDelegate,DeleteWishListDelegate {
    
    @IBOutlet var wishListTable: UITableView?
    var objAnimView = ImageViewAnimation()
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.callWishListData()
        self.setUpView()
        self.wishListAPI()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Do any additional setup after loading the view.
    }
    
    func setUpView(){
        self.title = "My Wish List"
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("getWishListData"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        //set Navigation right button nav-heart
        
        let btnName = UIButton()
        //        btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as! NSData
            let wishListArray = NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>
            btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
            
            btnName.setTitle(String(format:"%d",wishListArray!.count), forState: UIControlState.Normal)
            
            if(wishListArray!.count > 0)
            {
                
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else{
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
                
                
            }
            
        }
        else
        {
            let dataNew = NSKeyedArchiver.archivedDataWithRootObject(wishListArray)
            
            NSUserDefaults.standardUserDefaults().setObject(dataNew, forKey: "wishlistArray")
            
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    func getWishListData(notification:NSNotification)
    {
        self.wishListAPI()
    }
    
    func wishListAPI(){
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
    
    // MARK: - Tableview Delegate & Datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return wishListArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        //        let cell = tableView.dequeueReusableCellWithIdentifier("SavingCategoryTableViewCell") as? SavingCategoryTableViewCell
        //        if cell == nil {
        let bundleArr : Array = NSBundle.mainBundle().loadNibNamed("WishListTableViewCell", owner: nil, options: nil) as Array
        let cell = bundleArr[0] as! WishListTableViewCell
        //        }
        let cellDict = wishListArray[indexPath.row]
        cell.lblTitle!.text = cellDict["title"] as? String;
        if(cellDict["amount"] is String)
        {
            cell.lblPrice.text = cellDict["amount"] as? String
        }
        else
        {
            cell.lblPrice.text = String(format: "%d", (cellDict["amount"] as! NSNumber).intValue)
        }
        
        if let sharedPartySavingPlan =  cellDict["sharedPtySavingPlanId"] as? NSNumber
        {
            if(sharedPartySavingPlan == 0)
            {
                if(NSUserDefaults.standardUserDefaults().objectForKey("individualPlan") as? NSNumber == 0 && NSUserDefaults.standardUserDefaults().objectForKey("groupPlan") as? NSNumber == 0)
                {
                    cell.btnSavingPlan?.setTitle("Start saving plan", forState: UIControlState.Normal)
                    cell.btnSavingPlan?.addTarget(self, action: Selector("navigateToSetUpSavingPlan:"), forControlEvents: UIControlEvents.TouchUpInside)
                    cell.deleteButtonTopSpace.constant = 60
                    
                }
                else
                {
                    cell.btnSavingPlan?.hidden = true
                    cell.deleteButtonTopSpace.constant = 20
                }
            }
            else
            {
                if(NSUserDefaults.standardUserDefaults().objectForKey("groupMemberPlan") as? NSNumber == 0)
                {
                    cell.btnSavingPlan?.setTitle("Join Group", forState: UIControlState.Normal)
                    cell.btnSavingPlan?.addTarget(self, action: Selector("joinGroupSavingPlan:"), forControlEvents: UIControlEvents.TouchUpInside)
                    cell.deleteButtonTopSpace.constant = 60
                }
                else
                {
                    cell.btnSavingPlan?.hidden = true
                    cell.deleteButtonTopSpace.constant = 20
                }
                
            }
            
        }
        else
        {
            if(NSUserDefaults.standardUserDefaults().objectForKey("individualPlan") as? NSNumber == 0 && NSUserDefaults.standardUserDefaults().objectForKey("groupPlan") as? NSNumber == 0)
            {
                cell.btnSavingPlan?.setTitle("Start saving plan", forState: UIControlState.Normal)
                cell.btnSavingPlan?.addTarget(self, action: Selector("navigateToSetUpSavingPlan:"), forControlEvents: UIControlEvents.TouchUpInside)
                cell.deleteButtonTopSpace.constant = 60
                
            }
            else
            {
                cell.btnSavingPlan?.hidden = true
                cell.deleteButtonTopSpace.constant = 20
            }
        }
        cell.btnDelete?.addTarget(self, action: Selector("deleteButtonPress:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        if let urlString = cellDict["imageURL"] as? String
        {
            let url = NSURL(string:urlString)
            
            let request: NSURLRequest = NSURLRequest(URL: url!)
            if(urlString != "")
            {
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                    if data?.length > 0
                    {
                    let image = UIImage(data: data!)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.imgView.image = image
                    })
                    }
                })
            }
        }
        cell.btnSavingPlan?.tag = indexPath.row
        
        
        cell.btnDelete?.tag = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       
        let cellDict = wishListArray[indexPath.row]
        if let sharedPartySavingPlan =  cellDict["sharedPtySavingPlanId"] as? NSNumber
        {
            if(sharedPartySavingPlan == 0)
            {
                if(NSUserDefaults.standardUserDefaults().objectForKey("individualPlan") as? NSNumber == 0 && NSUserDefaults.standardUserDefaults().objectForKey("groupPlan") as? NSNumber == 0)
                {
                   return 310.0
                }
                else
                {
                    return 280.0
                }
            }
            else
            {
                if(NSUserDefaults.standardUserDefaults().objectForKey("individualPlan") as? NSNumber == 0 && NSUserDefaults.standardUserDefaults().objectForKey("groupPlan") as? NSNumber == 0)
                {
                   return 310.0
                }
                else
                {
                   return 280.0
                }
                
            }
            
        }
        else
        {
            if(NSUserDefaults.standardUserDefaults().objectForKey("individualPlan") as? NSNumber == 0 && NSUserDefaults.standardUserDefaults().objectForKey("groupPlan") as? NSNumber == 0)
            {
               return 310.0
                
            }
            else
            {
               return 280.0
            }
        }

    }
    
    func navigateToSetUpSavingPlan(sender:UIButton) {
        let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :"63"]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let objSavingPlanViewController = SASavingPlanViewController(nibName: "SASavingPlanViewController",bundle: nil)
        objSavingPlanViewController.itemDetailsDataDict = wishListArray[sender.tag]
        self.navigationController?.pushViewController(objSavingPlanViewController, animated: true)
    }
    
    func joinGroupSavingPlan(sender: UIButton)
    {
        let dict = ["savLogo1x":"group-save-category-icon","savLogo2x":"group-save-category-icon","savLogo3x":"group-save-category-icon","title":"Group Save","detail":"Set up savings goal between friends and family","sav-id":"8"]
        
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let objSavingPlanViewController = GroupsavingViewController(nibName: "GroupsavingViewController",bundle: nil)
        objSavingPlanViewController.itemDetailsDataDict = wishListArray[sender.tag]
        self.navigationController?.pushViewController(objSavingPlanViewController, animated: true)
    }
    func deleteButtonPress(sender:UIButton)  {
        
        
        let alert = UIAlertController(title: "Are you sure", message: "You want to delete this item?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default)
        { action -> Void in
            
            self.objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
            self.objAnimView.frame = self.view.frame
            self.objAnimView.animate()
            
            self.view.addSubview(self.objAnimView)
            
            let objAPI = API()
            
            
            let dateDict = self.wishListArray[sender.tag] as Dictionary<String,AnyObject>
            let dict : Dictionary<String,AnyObject> = ["id":dateDict["id"] as! NSNumber]
            
            objAPI.deleteWishList = self
            objAPI.deleteWishList(dict)
            
            self.wishListArray.removeAtIndex(sender.tag)
            self.wishListTable?.reloadData()
            let dataNew = NSKeyedArchiver.archivedDataWithRootObject(self.wishListArray)
            
            NSUserDefaults.standardUserDefaults().setObject(dataNew, forKey: "wishlistArray")
            
            NSUserDefaults.standardUserDefaults().synchronize()
            
            
            })
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: DELETE Wishlist delegate
    
    func successResponseForDeleteWishListAPI(objResponse: Dictionary<String, AnyObject>) {
        
        print(objResponse)
        objAnimView.removeFromSuperview()
        self.setUpView()
    }
    
    func errorResponseForDeleteWishListAPI(error: String) {
        print(error)
        objAnimView.removeFromSuperview()
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        //        let objSAWishListViewController = SAWishListViewController()
        //        self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func successResponseForGetWishlistAPI(objResponse: Dictionary<String, AnyObject>) {
        
        print(objResponse)
        if wishListArray.count > 0 {
            wishListArray.removeAll()
        }
        
        if let obj = objResponse["wishListList"] as? Array<Dictionary<String,AnyObject>>{
            wishListArray = obj
            objAnimView.removeFromSuperview()
            self.setUpView()
            wishListTable?.reloadData()
        }
        
    }
    
    func errorResponseForGetWishlistAPI(error: String) {
        print(error)
        objAnimView.removeFromSuperview()
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
