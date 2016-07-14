//
//  ContactViewController.swift
//  Savio
//
//  Created by Prashant on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol SAContactViewDelegate {
    
    func addedContact(contactDict:Dictionary<String,AnyObject>)
    func skipContact()
}

class ContactViewController: UIViewController {
    
    var contactDict: Dictionary<String,AnyObject> = [:]
    var delegate : SAContactViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableView Delegate and Datasource method
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count = 2
        if (contactDict["mobileNum"] != nil && contactDict["email"] != nil) {
            count = 3
        }
        
        return count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if indexPath.row == 0{
            let cellID: String = "CellID"
            
            var cell: ContactProfileTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellID) as? ContactProfileTableViewCell
            if cell == nil {
                var nib :Array! = NSBundle.mainBundle().loadNibNamed("ContactProfileTableViewCell", owner: nil, options: nil)
                cell = nib[0] as? ContactProfileTableViewCell
            }
            
            cell?.personImage?.image = contactDict["imageData"] as? UIImage
            if let name = contactDict["name"] as? String
            {
                if let lastName = contactDict["lastName"] as? String
                {
                    cell?.name?.text = String(format: "%@ %@", contactDict["name"] as! String, contactDict["lastName"] as! String)
                }
                
            }
            return cell!
        }
        else{
            let cellID: String = "ContactCell"
            var cell: ContactTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellID) as? ContactTableViewCell
            if cell == nil {
                var nib :Array! = NSBundle.mainBundle().loadNibNamed("ContactTableViewCell", owner: nil, options: nil)
                cell = nib[0] as? ContactTableViewCell
            }
            
            cell?.inviteBtn?.tag = indexPath.row
            cell?.inviteBtn?.addTarget(self, action: Selector("clickOnInviteButton:"), forControlEvents: UIControlEvents.TouchUpInside)
            if indexPath.row == 1 {
                if let mobileNum: String = contactDict["mobileNum"] as? String {
                    cell?.headerLbl?.text = "mobile"
                    cell?.detailLable?.text = mobileNum
                }
                else{
                    if let emailStr: String = contactDict["email"] as? String {
                        cell?.headerLbl?.text = "email"
                        cell?.detailLable?.text = emailStr
                    }
                }
            }
            
            if indexPath.row == 2 {
                if let emailStr: String = contactDict["email"] as? String {
                    cell?.headerLbl?.text = "email"
                    cell?.detailLable?.text = emailStr
                }
                
            }
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80.0
        }
        else {
            return 77.0
        }
    }
    
    
    func clickOnInviteButton(sender:UIButton){
        var text: String = ""
        var name : String = ""
        var mobileArray : Array<String> = []
        var emailArray : Array<String> = []
        var nameArray : Array<String> = []
        
        if let contactArray = NSUserDefaults.standardUserDefaults().objectForKey("InviteGroupArray") as? Array<Dictionary<String,AnyObject>>
        {
            
            for i in 0 ..< contactArray.count {
                var dict = contactArray[i] as Dictionary<String,AnyObject>
                if let phone = dict["mobile_number"] as? String
                {
                    mobileArray.append(phone)
                }
                if let email = dict["email"] as? String
                {
                    emailArray.append(email)
                }
                if let first_name = dict["first_name"] as? String
                {
                    nameArray.append(first_name)
                }
            }
            
        }
        var dict : Dictionary<String,AnyObject> = [:]
        if sender.tag == 1 {
            if let mobileNum: String = contactDict["mobileNum"] as? String {
                dict["mobile_number"] = mobileNum
                dict["email_id"] = ""
                text = mobileNum
            }
            else{
                if let emailStr: String = contactDict["email"] as? String {
                    dict["email_id"] = emailStr
                    dict["mobile_number"] = ""
                    text = emailStr
                }
            }
        }
            
        else {
            if let emailStr: String = contactDict["email"] as? String {
                dict["email_id"] = emailStr
                dict["mobile_number"] = ""
                text = emailStr
            }
        }
        
        if let firstName = contactDict["name"] as? String
        {
            
            dict["first_name"] = String(format: "%@", firstName)
            
            name = String(format: "%@", contactDict["name"] as! String)
            
            
        }
        
        if let lastName = contactDict["lastName"] as? String
        {
            dict["first_name"] = String(format: "%@ %@", contactDict["name"] as! String, lastName)
            
            name = String(format: "%@ %@", contactDict["name"] as! String, contactDict["lastName"] as! String)
        }
        
        //dict["first_name"] = String(format: "%@ %@", contactDict["name"] as! String, contactDict["lastName"] as! String)
        
        
        if(mobileArray.count > 0 || emailArray.count > 0)
        {
            if(mobileArray.contains(text) || nameArray.contains(name))
            {
                let alert = UIAlertView(title: "Alert", message: "You have already invited this contact", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else if(emailArray.contains(text) || nameArray.contains(name))
            {
                let alert = UIAlertView(title: "Alert", message: "You have already invited this contact", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else
            {
                delegate?.addedContact(dict)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        else
        {
            delegate?.addedContact(dict)
            self.navigationController?.popViewControllerAnimated(true)
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
