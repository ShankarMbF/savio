//
//  SAPopOverViewController.swift
//  Savio
//
//  Created by Maheshwari on 03/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol PopOverDelegate{
    
    func popOverValueChanged(value:String)
}

class SAPopOverViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var popOverTableView: UITableView!
    var setArrayString = ""
    var popOverDelegate : PopOverDelegate?
    let dayArray : Array<String> = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    let dateArray : Array<String> = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popOverTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        popOverTableView.separatorInset = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(setArrayString == "day") {
            return 7
        }
        else {
            return 28
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = self.popOverTableView.dequeueReusableCellWithIdentifier("cell" as String) as UITableViewCell?
        if(cell != nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell" as String)
        }
        cell?.textLabel?.font = UIFont(name: "GothamRounded-Light", size: 12)
        cell!.layoutMargins = UIEdgeInsetsZero
        if(setArrayString == "day")
        {
            cell!.textLabel?.text = dayArray[indexPath.row]
        }
        else{
            cell!.textLabel?.text = dateArray[indexPath.row]
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(setArrayString == "day")
        {
            popOverDelegate?.popOverValueChanged(dayArray[indexPath.row])
        }
        else{
            popOverDelegate?.popOverValueChanged(dateArray[indexPath.row])
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
