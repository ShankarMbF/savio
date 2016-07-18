//
//  SAProgressViewController.swift
//  Savio
//
//  Created by Prashant on 21/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAProgressViewController: UIViewController,GetUsersPlanDelegate {
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
    @IBOutlet weak var calculationLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var circularProgressOne: KDCircularProgress!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var makeImpulseSavingButton: UIButton!
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    var objAnimView = ImageViewAnimation()
    var totalAmount : Float = 0.0
    var paidAmount : Float = 0.0
    var planTitle = ""
    var savingPlanDetailsDict : Dictionary<String,AnyObject> =  [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), forState: UIControlState.Normal)
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), forState: UIControlState.Normal)
        
        self.setUPNavigation()
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        
        self.view.addSubview(objAnimView)
        let objAPI = API()
        objAPI.getSavingPlanDelegate = self
        objAPI.getUsersSavingPlan("i")
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlView.contentSize = CGSizeMake(3 * UIScreen.mainScreen().bounds.size.width, 0)
    }
    
    func setUPNavigation()
    {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "My Plan"
        //set Navigation right button nav-heart
        
        let btnName = UIButton()
        //btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
             let dataSave = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as! NSData
            wishListArray = (NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>)!

            
            if(wishListArray.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else{
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
                
                
            }
            
            btnName.setTitle(String(format:"%d",wishListArray.count), forState: UIControlState.Normal)
            
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        makeImpulseSavingButton!.layer.cornerRadius = 5
    }
    
    
    func setUpView(){

        
        planTitle = String(format: "My %@ saving plan",savingPlanDetailsDict["title"] as! String)

        var attrText = NSMutableAttributedString(string: planTitle)
        
        attrText.addAttribute(NSFontAttributeName,
                                     value: UIFont(
                                        name: "GothamRounded-Medium",
                                        size: 16.0)!,
                                     range: NSRange(
                                        location: 3,
                                        length: (savingPlanDetailsDict["title"] as! String).characters.count))
        
        
        savingPlanTitleLabel.attributedText = attrText
 
        if let amount = savingPlanDetailsDict["amount"] as? NSNumber
        {
             totalAmount = amount.floatValue
        }
        
        if let totalPaidAmount = savingPlanDetailsDict["totalPaidAmount"] as? NSNumber
        {
       
            paidAmount = totalPaidAmount.floatValue
            
        }
   
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
        

        
        for var i=0; i<3; i++
        {
            let circularProgress = NSBundle.mainBundle().loadNibNamed("CircularProgress", owner: self, options: nil)[0] as! UIView
            circularProgress.frame = CGRectMake(CGFloat(i) * UIScreen.mainScreen().bounds.size.width,0,  scrlView.frame.size.width, scrlView.frame.size.height)
            scrlView.addSubview(circularProgress)
            
            let circularView = circularProgress.viewWithTag(1) as! KDCircularProgress
            circularView.startAngle = -90
            circularView.roundedCorners = true
            print(paidAmount)
            print(totalAmount)
            print(Double((paidAmount * 360)/totalAmount))

            circularView.angle = Double((paidAmount * 360)/totalAmount)
            
             let labelOne = circularProgress.viewWithTag(3) as! UILabel
            
            let labelTwo = circularProgress.viewWithTag(2) as! UILabel
            
            let imgView = circularProgress.viewWithTag(4) as! UIImageView
        
            if let url = NSURL(string:savingPlanDetailsDict["image"] as! String)
            {

                let request: NSURLRequest = NSURLRequest(URL: url)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                    let image = UIImage(data: data!)
                    dispatch_async(dispatch_get_main_queue(), {
                        imgView.image = image
                    })
                })
                

            }
            
            if(i == 0)
            {
                labelOne.hidden = true
                labelTwo.hidden = true
                imgView.hidden = false
               
            }
            else if(i == 1)
            {
                labelOne.hidden = false
                labelOne.text = String(format: "%0.2f%%",paidAmount)
                labelTwo.hidden = false
                labelTwo.text = String(format: "£ %0.2f saved",paidAmount)
                imgView.hidden = true
               
            }
            else
            {
                labelOne.hidden = false
                labelOne.text = String(format: "£ %0.2f",String(totalAmount - paidAmount))
                labelTwo.hidden = false
                labelTwo.text = String(format: "%0.0f days to go",String(totalAmount - paidAmount))
                imgView.hidden = true
            }
        }
        
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        
        if wishListArray.count>0{
            
            let objSAWishListViewController = SAWishListViewController()
            //objSAWishListViewController.wishListArray = wishListArray
            self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
        }
        else{
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
        
        // Set the new page index to the page control.
        pageControl!.currentPage = Int(currentPage)
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var newFrame = scrlView!.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl!.currentPage)
        scrlView!.scrollRectToVisible(newFrame, animated: true)
    }
    
    @IBAction func clickOnStatButton(sender:UIButton){
        let obj = SAStatViewController()
        obj.itemTitle = planTitle
        self.navigationController?.pushViewController(obj, animated: false)
    }
    
    
    @IBAction func offersButtonPressed(sender: AnyObject) {
        
        let obj = SAOfferListViewController()
        obj.savID = 63
        let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :"63"]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
        NSUserDefaults.standardUserDefaults().synchronize()
        obj.hideAddOfferButton = true
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func spendButtonPressed(sender: AnyObject) {
        
        let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
        
        self.navigationController?.pushViewController(objPlan, animated: false)
    }
    
    
    @IBAction func impulseSavingButtonPressed(sender: UIButton) {
        let objImpulseSave = SAImpulseSavingViewController()
        self.navigationController?.pushViewController(objImpulseSave, animated: true)
    }
    
    
    func successResponseForGetUsersPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if let message = objResponse["message"] as? String
        {
            if(message == "Success")
            {
                savingPlanDetailsDict = objResponse["partySavingPlan"] as! Dictionary<String,AnyObject>
                self.setUpView()
            }
            else
            {
            pageControl.hidden = true
            let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            }
        }
        else
        {
            pageControl.hidden = true
            let alert = UIAlertView(title: "Alert", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }

         objAnimView.removeFromSuperview()
        
    }
    
    func errorResponseForGetUsersPlanAPI(error: String) {
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView.removeFromSuperview()
    }
    
   }
