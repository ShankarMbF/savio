//
//  SASwitchViewController.swift
//  Savio
//
//  Created by Prashant on 21/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASwitchViewController: UIViewController {
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "GothamRounded-Medium", size: 16)!]
        self.setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setUpView(){
        
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false

        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "Switch plans"
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
    }
    
    


    
    //MARK: Bar button action
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        
        
        if wishListArray.count>0{
            
            let objSAWishListViewController = SAWishListViewController()
            objSAWishListViewController.wishListArray = wishListArray
            self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
        }
        else{
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
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
