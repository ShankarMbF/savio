//
//  SASpendViewController.swift
//  Savio
//
//  Created by Maheshwari on 24/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASpendViewController: UIViewController {
    
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var offersButton: UIButton!
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        spendButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        spendButton.tintColor = UIColor.whiteColor()
        spendButton.setImage(UIImage(named: "stats-spend-tab-active.png"), forState: UIControlState.Normal)
        planButton.setImage(UIImage(named: "stats-plan-tab.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), forState: UIControlState.Normal)
        self.setUpView()
        // Do any additional setup after loading the view.
    }
 
    //Set up the NavigationBar
    func setUpView(){
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBarHidden = false

        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: #selector(SASpendViewController.menuButtonClicked), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "Spend now"
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: #selector(SASpendViewController.heartBtnClicked), forControlEvents: .TouchUpInside)
        
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = str
            wishListArray = (NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>)!
            //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
            if(wishListArray.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
            }
            btnName.setTitle(String(format:"%d",wishListArray.count), forState: UIControlState.Normal)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //customization of spend button
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.spendButton!.bounds, byRoundingCorners: ([.TopRight, .TopLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.spendButton!.bounds
        maskLayer.path = maskPath.CGPath
        self.spendButton?.layer.mask = maskLayer
    }
    
    //MARK: Bar button actions
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
        if wishListArray.count>0{
            NSNotificationCenter.defaultCenter().postNotificationName("SelectRowIdentifier", object: "SAWishListViewController")
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: "Wish list empty.", message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }

    @IBAction func planButtonPressed(sender: AnyObject) {
        var vw = UIViewController?()
        let individualFlag = NSUserDefaults.standardUserDefaults().valueForKey("individualPlan") as! NSNumber
        var isAvailble: Bool = false
        var usersPlanFlag = ""
        if let usersPlan = NSUserDefaults.standardUserDefaults().valueForKey("UsersPlan") as? String
        {
            usersPlanFlag = usersPlan
            //As per flag show the progress view of plan
            vw = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
            if individualFlag == 1 && usersPlanFlag == "I"{
                for var obj in (self.navigationController?.viewControllers)!{
                    if obj.isKindOfClass(SAProgressViewController) {
                        isAvailble = true
                        vw = obj as! SAProgressViewController
                        break
                    }
                }
            }
            else
            {
                vw = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
                for var obj in (self.navigationController?.viewControllers)!{
                    if obj.isKindOfClass(SAGroupProgressViewController) {
                        isAvailble = true
                        vw = obj as! SAGroupProgressViewController
                        break
                    }
                }
            }
            
        } else {
            usersPlanFlag = ""
            //As per flag show the progress view of plan
            
            if individualFlag == 1{
                vw = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
                for var obj in (self.navigationController?.viewControllers)!{
                    if obj.isKindOfClass(SAProgressViewController) {
                        isAvailble = true
                        vw = obj as! SAProgressViewController
                        break
                    }
                }
            }
            else
            {
                vw = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
                for var obj in (self.navigationController?.viewControllers)!{
                    if obj.isKindOfClass(SAGroupProgressViewController) {
                        isAvailble = true
                        vw = obj as! SAGroupProgressViewController
                        break
                    }
                }
            }
        }
        
        if isAvailble {
            self.navigationController?.popToViewController(vw!, animated: false)
        }
        else{
            
            self.navigationController?.pushViewController(vw!, animated: false)
        }
    }
    
    //Go to SAOffersViewController
    @IBAction func offersButtonPressed(sender: AnyObject) {
        var isAvailble: Bool = false
        var vw = UIViewController?()
        
        for var obj in (self.navigationController?.viewControllers)!{
            if obj.isKindOfClass(SAOfferListViewController) {
                isAvailble = true
                vw = obj as! SAOfferListViewController
                break
            }
        }
        
        if isAvailble {
            self.navigationController?.popToViewController(vw!, animated: false)
        }
        else{
            let obj = SAOfferListViewController()
            obj.savID = 92
            obj.isComingProgress = true
            //save the Generic plan in NSUserDefaults, so it will show its specific offers
            let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92]
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
            NSUserDefaults.standardUserDefaults().synchronize()
            obj.hideAddOfferButton = true
            self.navigationController?.pushViewController(obj, animated: false)
        }
    }
}
