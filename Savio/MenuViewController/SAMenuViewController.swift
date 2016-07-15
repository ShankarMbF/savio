//
//  SAMenuViewController.swift
//  Savio
//
//  Created by Prashant on 20/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAMenuViewController: UIViewController {

    @IBOutlet weak var menuTable: UITableView?
    var arrMenu: Array<Dictionary<String,AnyObject>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SAMenuViewController.methodOfReceivedNotification(_:)), name:"NotificationIdentifier", object: nil)
        self.setUpUI()

    }
    
    func methodOfReceivedNotification(notification: NSNotification){
        //Take Action on Notification
        arrMenu.removeAll()
        self.setUpUI()
        menuTable?.reloadData()
    }
    
    func setUpUI() {
        let fileUrl: NSURL = NSBundle.mainBundle().URLForResource("Menu", withExtension: "json")!
        let jsonData: NSData = NSData(contentsOfURL: fileUrl)!
        let arr: NSArray = (try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as! NSArray
        
        let individualFlag = NSUserDefaults.standardUserDefaults().valueForKey("individualPlan") as! NSNumber
        let groupFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupPlan") as! NSNumber
        let groupMemberFlag = NSUserDefaults.standardUserDefaults().valueForKey("groupMemberPlan") as! NSNumber

        
        for var i = 0; i < arr.count; i++ {
            var dict = arr[i] as! Dictionary<String,AnyObject>
            if dict["className"]!.isEqualToString("SAProgressViewController") {
                                dict["showInMenu"] = "No"
                if (individualFlag == 1 || groupFlag == 1 || groupMemberFlag == 1){
                    dict["showInMenu"] = "Yes"
                    arrMenu.append(dict)
                }
            }
           else if dict["className"]!.isEqualToString("SASavingPlanViewController") {
                dict["showInMenu"] = "No"
                if(individualFlag == 1)
                {
                    dict["showInMenu"] = "Yes"
                    arrMenu.append(dict)
                }
            }
            else{
                arrMenu.append(dict)
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMenu.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier:String = "CustomFields"
        var cell:MenuTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? MenuTableViewCell
        
        if (cell == nil) {
            var nibs: Array! =  NSBundle.mainBundle().loadNibNamed("MenuTableViewCell", owner: self, options: nil)
            cell = nibs[0] as? MenuTableViewCell
        }
        
        let dict =  self.arrMenu[indexPath.row]
        
        cell?.title?.text =  dict["title"] as? String
        let imageName =  dict["image"] as! String
        let imageIcon = UIImage(named: imageName)//?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell?.icon?.image = imageIcon
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         let dict =  self.arrMenu[indexPath.row]
        let selectedCell:MenuTableViewCell? = tableView.cellForRowAtIndexPath(indexPath)as? MenuTableViewCell
        selectedCell!.contentView.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        let imageName =  dict["activeImage"] as! String
        let imageIcon = UIImage(named: imageName)
        selectedCell?.icon?.image = imageIcon
       
        let className: String = dict["className"] as! String
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: className)
    }
    
    // if tableView is set in attribute inspector with selection to multiple Selection it should work.
    
    // Just set it back in deselect
     func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:MenuTableViewCell? = tableView.cellForRowAtIndexPath(indexPath)as? MenuTableViewCell
        selectedCell!.contentView.backgroundColor = UIColor.whiteColor()
        let dict =  self.arrMenu[indexPath.row]
        let imageName =  dict["image"] as! String
        let imageIcon = UIImage(named: imageName)
        selectedCell?.icon?.image = imageIcon
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
