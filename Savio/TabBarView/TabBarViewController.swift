//
//  TabBarViewController.swift
//  Savio
//
//  Created by Maheshwari on 23/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class TabBarViewController: UIViewController {
    @IBOutlet weak var spendButton: UIButton!
    
    @IBOutlet weak var offersButton: UIButton!
    
    @IBOutlet weak var progressButton: UIButton!
    var navController: UINavigationController!
    var centreVC: UIViewController! = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navController = UINavigationController(rootViewController: self.centreVC)
        self.navController.view.frame = self.view.frame
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        self.view.addSubview(centreVC.view)
        self.view.addSubview(self.navController!.view)
        
        self.addChildViewController(self.navController)
        self.view.addSubview(self.navController!.view)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addCentreView:", name: kNotificationAddCentreView, object: nil)
        
        progressButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        progressButton.tintColor = UIColor.whiteColor()
        
        spendButton.setImage(UIImage(named: "menu-spend.png"), forState: UIControlState.Normal)
        
        progressButton.setImage(UIImage(named: "menu-start.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "menu-offers.png"), forState: UIControlState.Normal)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func spendButtonPressed(sender: AnyObject) {
         spendButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        spendButton.tintColor = UIColor.whiteColor()
    }
    
    
    @IBAction func offersButtonPressed(sender: AnyObject) {
        self.centreVC = SAOfferListViewController(nibName:"SAOfferListViewController",bundle: nil)
         offersButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        offersButton.tintColor = UIColor.whiteColor()
        self.replaceViewController()
        
    }
    
    @IBAction func planButtonPressed(sender: AnyObject) {
        self.centreVC = SAProgressViewController(nibName:"SAProgressViewController",bundle: nil)
      
        self.replaceViewController()
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
