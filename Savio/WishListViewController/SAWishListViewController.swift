//
//  SAWishListViewController.swift
//  Savio
//
//  Created by Prashant on 04/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAWishListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()

        // Do any additional setup after loading the view.
    }

    func setUpView(){
        self.title = "My Wish List"
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: #selector(SACreateSavingPlanViewController.menuButtonClicked), forControlEvents: .TouchUpInside)
        
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
        btnName.addTarget(self, action: #selector(SACreateSavingPlanViewController.heartBtnClicked), forControlEvents: .TouchUpInside)
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
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
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        //        let cell = tableView.dequeueReusableCellWithIdentifier("SavingCategoryTableViewCell") as? SavingCategoryTableViewCell
        //        if cell == nil {
        let bundleArr : Array = NSBundle.mainBundle().loadNibNamed("WishListTableViewCell", owner: nil, options: nil) as Array
        let cell = bundleArr[0] as! WishListTableViewCell
        //        }
//        let cellDict = tblArr[indexPath.row]
//        print(cellDict["header"])
//        cell.lblHeader!.text = cellDict["header"] as? String;
//        cell.lblDetail?.text = cellDict["detail"] as? String
//        cell.imgView?.image = UIImage(named: cellDict["image"] as! String)
        
        cell.btnSavingPlan?.addTarget(self, action: #selector(SAWishListViewController.navigateToSetUpSavingPlan(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 310.0
    }

    func navigateToSetUpSavingPlan(sender:UIButton) {
        print("Clicked on Wishlist button")
        let dict = ["image":"generic-category-icon","header":"Generic plan","detail":"Don't want to be specific? No worries, we just can't give you any offers from our partners."]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let objSavingPlanViewController = SASavingPlanViewController(nibName: "SASavingPlanViewController",bundle: nil)
        self.navigationController?.pushViewController(objSavingPlanViewController, animated: true)
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        
    }
    
    func heartBtnClicked(){
//        let objSAWishListViewController = SAWishListViewController()
//        self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
        self.navigationController?.popViewControllerAnimated(true)
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
