//
//  SAThankYouViewController.swift
//  Savio
//
//  Created by Maheshwari on 16/09/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAThankYouViewController: UIViewController {
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView()
    {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "Thank you"
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SAThankYouViewController.menuButtonClicked), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.addTarget(self, action: #selector(SAThankYouViewController.heartBtnClicked), for: .touchUpInside)
        
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
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func menuButtonClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAProgressViewController")
        // Set all plan flag
        let individualFlag = UserDefaults.standard.value(forKey: kIndividualPlan) as! NSNumber
        let groupFlag = UserDefaults.standard.value(forKey: kGroupPlan) as! NSNumber
        let groupMemberFlag = UserDefaults.standard.value(forKey: kGroupMemberPlan) as! NSNumber
        
        let plan = UserDefaults.standard.value(forKey: "usersPlan") as? String
        //Individual plan
        if(plan == kIndividualPlan || individualFlag == 1)
        {
            let objProgressView = SAProgressViewController()
            self.navigationController?.pushViewController(objProgressView, animated: true)
            UserDefaults.standard.setValue(1, forKey: kIndividualPlan)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationIdentifier), object: nil)
        }
        else if(plan == kGroupPlan || groupFlag == 1)//group plan
        {
            UserDefaults.standard.setValue(1, forKey: kGroupPlan)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationIdentifier), object: nil)
            
            let objProgressView = SAGroupProgressViewController()
            self.navigationController?.pushViewController(objProgressView, animated: true)
        }
        else if(plan == kGroupMemberPlan || groupMemberFlag == 1)//Group member plan
        {
            UserDefaults.standard.setValue(1, forKey: kGroupMemberPlan)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationIdentifier), object: nil)
            
            let objProgressView = SAGroupProgressViewController()
            self.navigationController?.pushViewController(objProgressView, animated: true)
        }
    }
}
