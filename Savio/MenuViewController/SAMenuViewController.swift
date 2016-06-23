//
//  SAMenuViewController.swift
//  Savio
//
//  Created by Prashant on 20/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAMenuViewController: UIViewController {

    var arrMenu: Array<Dictionary<String,AnyObject>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileUrl: NSURL = NSBundle.mainBundle().URLForResource("Menu", withExtension: "json")!
        let jsonData: NSData = NSData(contentsOfURL: fileUrl)!
        let arr: NSArray = (try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as! NSArray
        arrMenu = arr as! Array<Dictionary<String,AnyObject>>

        // Do any additional setup after loading the view.
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
        let imageIcon = UIImage(named: imageName)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell?.icon?.image = imageIcon
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dict =  self.arrMenu[indexPath.row]
        let className: String = dict["className"] as! String
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationAddCentreView, object: className)
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
