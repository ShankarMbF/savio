//
//  ContainerViewController.swift
//  Savio
//
//  Created by Prashant on 20/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

let kNotificationToggleMenuView = "ToggleCentreView"
let kNotificationAddCentreView = "AddCentreView"

class ContainerViewController: UIViewController {
    var menuVC: UIViewController! = SAMenuViewController(nibName: "SAMenuViewController", bundle: nil)
    var centreVC: UIViewController! =  SACreateSavingPlanViewController(nibName: "SACreateSavingPlanViewController", bundle: nil)
    var navController: UINavigationController!
    var isShowingProgress:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let individualFlag = NSUserDefaults.standardUserDefaults().valueForKey("individualPlan") as! NSNumber
        let groupFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupPlan") as! NSNumber
        let groupMemberFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupMemberPlan") as! NSNumber

        
        if individualFlag == 1 {
            self.centreVC = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
        }
        else if(groupFlag == 1 || groupMemberFlag == 1)
        {
            self.centreVC = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
        }
        else {
            self.centreVC = SACreateSavingPlanViewController(nibName: "SACreateSavingPlanViewController", bundle: nil)
        }
        
        self.navController = UINavigationController(rootViewController: self.centreVC)
        self.navController.view.frame = self.view.frame
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        //        self.navController.navigationBar.hidden = true
        
        self.view.addSubview(self.menuVC!.view)
        self.view.addSubview(self.navController!.view)
        
        self.addChildViewController(self.navController)
        self.view.addSubview(self.navController!.view)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addCentreView:", name: kNotificationAddCentreView, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ToggleCentreView", name: kNotificationToggleMenuView, object: nil)
       
    }
    
    func ToggleCentreView() {
        var destination = self.navController.view.frame;
        if (destination.origin.x > 0) {
            destination.origin.x = 0;
        } else {
            destination.origin.x += 250;
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.navController.view.frame = destination
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func addCentreView(notification: NSNotification) {
        let className = notification.object as! String
        if self.centreVC.nibName == className {
            self.ToggleCentreView()
            return
        }
//        if(className == "SASavingPlanViewController" && isShowingProgress == "GroupSaving PlanExist")
//        {
//            let alert = UIAlertView(title: "Alert", message: "You do not have individual saving plan", delegate: nil, cancelButtonTitle: "Ok")
//            alert.show()
//           self.ToggleCentreView()
//            return
//        }

        self.navController.view.removeFromSuperview()
        self.navController.removeFromParentViewController()

        switch className {
        case "SACreateSavingPlanViewController":
            self.centreVC = SACreateSavingPlanViewController(nibName: "SACreateSavingPlanViewController", bundle: nil)
            self.replaceViewController()
            
        case "SAWishListViewController":
            self.centreVC = SAWishListViewController(nibName: "SAWishListViewController", bundle: nil)
            self.replaceViewController()
            
        case "SAOfferListViewController":
            
            NSUserDefaults.standardUserDefaults().removeObjectForKey("offerList")
            
            let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :"63"]
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            NSUserDefaults.standardUserDefaults().synchronize()
            let obj = SAOfferListViewController(nibName: "SAOfferListViewController", bundle: nil)
            obj.hideAddOfferButton = true
            self.centreVC = obj
            centreVC.hidesBottomBarWhenPushed = true
            self.replaceViewController()
            
        case "SASwitchViewController":
            self.centreVC = SASwitchViewController(nibName: "SASwitchViewController", bundle: nil)
            self.replaceViewController()
            
        case "SAProgressViewController":
            NSUserDefaults.standardUserDefaults().removeObjectForKey("offerList")
            NSUserDefaults.standardUserDefaults().synchronize()

            if isShowingProgress == "I" {
                self.centreVC = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
            }
            else if(isShowingProgress == "G" || isShowingProgress == "GM")
            {
                self.centreVC = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
            }
            else {
                self.centreVC = SACreateSavingPlanViewController(nibName: "SACreateSavingPlanViewController", bundle: nil)
            }
            
            self.replaceViewController()
            
        case "SASavingPlanViewController":
            
//            if isShowingProgress == "PartySavingPlanExist" {
                let obj = SASavingPlanViewController(nibName: "SASavingPlanViewController", bundle: nil)
                obj.isUpdatePlan = true
                let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :"63"]
                NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.centreVC = obj
                
                self.replaceViewController()
//            }
//            else  {
//                
//            }
            
            
       
        case "SASettingsViewController":
            self.centreVC = SAEditUserInfoViewController(nibName: "SAEditUserInfoViewController", bundle: nil)
            self.replaceViewController()
        case "SignOut":
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        default:
            print("Default Line Reached")
            let alert = UIAlertView(title: "Alert", message: "Your saving plan is created successfully", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func replaceViewController() {
        self.navController = UINavigationController(rootViewController: self.centreVC)
        //        self.navController.navigationBar.hidden = true
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navController.view.frame = self.view.frame
        self.addChildViewController(self.navController)
        self.view.addSubview(self.navController!.view)
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
