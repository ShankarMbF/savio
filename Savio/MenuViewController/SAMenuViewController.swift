//
//  SAMenuViewController.swift
//  Savio
//
//  Created by Prashant on 20/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var menuTable: UITableView?
    var arrMenu: Array<Dictionary<String,AnyObject>> = []
    var isFromSummary = false
    
    // MARK: - ViewController life cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup Menu as per plan created
        NotificationCenter.default.addObserver(self, selector: #selector(SAMenuViewController.methodOfReceivedNotification(_:)), name:NSNotification.Name(rawValue: kNotificationIdentifier), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SAMenuViewController.methodForSelectRowAtIndexPath(_:)), name:NSNotification.Name(rawValue: kSelectRowIdentifier), object: nil)
        //Set up UI for Menu
        self.setUpUI()
    }
    
    //Function invoke when NotificationIdentifier notification brodcast
    func methodOfReceivedNotification(_ notification: Notification){
        //Take Action on Notification
        arrMenu.removeAll()
        self.setUpUI()
        menuTable?.reloadData()
    }
    
    func methodForSelectRowAtIndexPath(_ notification: Notification)
    {
         if let indxPath = userDefaults.value(forKey: "SelectedIndexPath") as? Int
         {
          self.deSelectRow(IndexPath(row: indxPath,section: 0))
        }
        isFromSummary = true
        self.selectRow(IndexPath(row: 1,section: 0))
    }
    
    
    //Function invoking for setup the UI
    func setUpUI() {
        //Create Menu's JSON file URL
        let fileUrl: URL = Bundle.main.url(forResource: "Menu", withExtension: "json")!
        //Getting FileData
        let jsonData: Data = try! Data(contentsOf: fileUrl)
        //Parsing Json file data
        let arr: NSArray = (try! JSONSerialization.jsonObject(with: jsonData, options: [])) as! NSArray
        //setting individual, group and group member plan's flag
        let individualFlag = userDefaults.value(forKey: kIndividualPlan) as! NSNumber
        let groupFlag = userDefaults.value(forKey: kGroupPlan) as! NSNumber
        let groupMemberFlag = userDefaults.value(forKey: kGroupMemberPlan) as! NSNumber
        
        //Set up number of menu as per plan created
        for i in 0 ..< arr.count {
            var dict = arr[i] as! Dictionary<String,AnyObject>
            
            if dict["className"]!.isEqual(to: "SAProgressViewController") {
                dict["showInMenu"] = "No" as AnyObject
                if (individualFlag == 1 || groupFlag == 1 || groupMemberFlag == 1){
                    dict["showInMenu"] = "Yes" as AnyObject
                    arrMenu.append(dict)
                }
            }
            else if dict["className"]!.isEqual(to: "SASavingPlanViewController") {
                dict["showInMenu"] = "No" as AnyObject
                if(individualFlag == 1){
                    dict["showInMenu"] = "Yes" as AnyObject
                    arrMenu.append(dict)
                }
            }
             else if dict["className"]!.isEqual(to: "SASwitchViewController") {
                dict["showInMenu"] = "No" as AnyObject
                if (individualFlag == 1 && groupMemberFlag == 1) || (groupFlag == 1 && groupMemberFlag == 1){
                    dict["showInMenu"] = "Yes" as AnyObject
                    arrMenu.append(dict)
                }
            }
            else  if dict["className"]!.isEqual(to: "SASpendViewController") {
                dict["showInMenu"] = "No" as AnyObject
                if (individualFlag == 1 || groupFlag == 1 || groupMemberFlag == 1){
                    dict["showInMenu"] = "Yes" as AnyObject
                    arrMenu.append(dict)
                }
            }
            else {
                arrMenu.append(dict)
            }
        }
    }
    
    func selectRow(_ indexPath:IndexPath)
    {
        self.tableView(self.menuTable!, didSelectRowAt:indexPath)
        self.menuTable?.reloadData()
        isFromSummary = false
    }
    
    func deSelectRow(_ indexPath:IndexPath)
    {
        let indxPath = userDefaults.value(forKey: "SelectedIndexPath") as? Int
        self.tableView(self.menuTable!, didDeselectRowAt: IndexPath(row: indxPath!,section:0))
        self.menuTable?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Tableview datasource and delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Create reusable custom cell from MenuTableViewCell.xib
        let cellIdentifier:String = "CustomFields"
        var cell:MenuTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MenuTableViewCell
        
        if (cell == nil) {
            var nibs: Array! =  Bundle.main.loadNibNamed("MenuTableViewCell", owner: self, options: nil)
            cell = nibs[0] as? MenuTableViewCell
        }
        //got individual menu's info
        let dict =  self.arrMenu[indexPath.row]
        //Showing Menu title
        cell?.title?.text =  dict[kTitle] as? String
        //Showing menu icon
        let imageName =  dict["image"] as! String
        let imageIcon = UIImage(named: imageName)//?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell?.icon?.image = imageIcon
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict =  self.arrMenu[indexPath.row]
        
        let selectedCell:MenuTableViewCell? = menuTable!.cellForRow(at: indexPath)as? MenuTableViewCell
        //Changing background color of selected row
        selectedCell!.contentView.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        let imageName =  dict["activeImage"] as! String
        let imageIcon = UIImage(named: imageName)
        selectedCell?.icon?.image = imageIcon

        let className: String = dict["className"] as! String
        
        userDefaults.set(indexPath.row, forKey: "SelectedIndexPath")
        userDefaults.synchronize()
        
        //Brodcast the notification for navigating flow
        if(isFromSummary == false)
        {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: className)
        }
    }
    
    // Just set it back in deselect
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let indxPath = userDefaults.value(forKey: "SelectedIndexPath") as? Int
        self.menuTable?.deselectRow(at: IndexPath(row: indxPath!,section:0), animated: true)
        
        
        let selectedCell:MenuTableViewCell? = menuTable!.cellForRow(at: indexPath)as? MenuTableViewCell
        selectedCell!.contentView.backgroundColor = UIColor.white
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
