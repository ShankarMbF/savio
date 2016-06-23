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
    var centreVC: UIViewController! = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
    var navController: UINavigationController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            self.centreVC = SAOfferListViewController(nibName: "SAOfferListViewController", bundle: nil)
            self.replaceViewController()
            
        case "SASwitchViewController":
            self.centreVC = SASwitchViewController(nibName: "SASwitchViewController", bundle: nil)
            self.replaceViewController()
            
        case "SAProgressViewController":
            self.centreVC = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
            self.replaceViewController()
            
        case "SignOut":
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        default: print("Default Line Reached")
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
