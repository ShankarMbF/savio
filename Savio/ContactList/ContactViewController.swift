//
//  ContactViewController.swift
//  Savio
//
//  Created by Prashant on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

//----------Custom protocol for add or skip contact-----------------------
protocol SAContactViewDelegate {
    
    func addedContact(_ contactDict:Dictionary<String,AnyObject>)
    func skipContact()
}
//------------------------------------------------------------------------

class ContactViewController: UIViewController {
    
    var contactDict: Dictionary<String,AnyObject> = [:] //Dictionary for holding contact info
    var delegate : SAContactViewDelegate?
    
     //MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableView Delegate and Datasource method
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //by default 2 rows visible
        var count = 2
        //if mobile number and email id both available then 3 rows visible
        if (contactDict["mobileNum"] != nil && contactDict["email"] != nil) {
            count = 3
        }
        return count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{
        if indexPath.row == 0{
            let cellID: String = "CellID"
            //create reusable custom cell from ContactProfileTableViewCell.xib to show user info
            var cell: ContactProfileTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellID) as? ContactProfileTableViewCell
            if cell == nil {
                var nib :Array! = Bundle.main.loadNibNamed("ContactProfileTableViewCell", owner: nil, options: nil)
                cell = nib[0] as? ContactProfileTableViewCell
            }
            cell?.selectionStyle = .none
            //Showing contact image
            cell?.personImage?.image = contactDict["imageData"] as? UIImage
            //Showing name
            if let name = contactDict["name"] as? String{
                if let lastName = contactDict["lastName"] as? String{
                    cell?.name?.text = String(format: "%@ %@", name, lastName)
                }
            }
            return cell!
        }
        else {
            //create reusable custom cell from ContactTableViewCell.xib to show user contact
            let cellID: String = "ContactCell"
            var cell: ContactTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellID) as? ContactTableViewCell
            if cell == nil {
                var nib :Array! = Bundle.main.loadNibNamed("ContactTableViewCell", owner: nil, options: nil)
                cell = nib[0] as? ContactTableViewCell
            }
             cell?.selectionStyle = .none
            //setting up invite button
            cell?.inviteBtn?.tag = indexPath.row
            cell?.inviteBtn?.addTarget(self, action: #selector(ContactViewController.clickOnInviteButton(_:)), for: UIControlEvents.touchUpInside)
            if indexPath.row == 1 {
                //mobile number avalable then showing in contact list
                if let mobileNum: String = contactDict["mobileNum"] as? String {
                    cell?.headerLbl?.text = "mobile"
                    cell?.detailLable?.text = mobileNum
                }
                else {
                    //showing email id if mobile num not present
                    if let emailStr: String = contactDict["email"] as? String {
                        cell?.headerLbl?.text = "email"
                        cell?.detailLable?.text = emailStr
                         cell?.inviteBtn?.isEnabled = false
                        cell?.inviteBtn?.alpha = 0.6
                    }
                }
            }
            if indexPath.row == 2 {
                //Showing email id from contact
                if let emailStr: String = contactDict["email"] as? String {
                    cell?.headerLbl?.text = "email"
                    cell?.detailLable?.text = emailStr
                    cell?.inviteBtn?.isEnabled = false
                    cell?.inviteBtn?.alpha = 0.6
                }
            }
            return cell!
        }
    }
    //set row height
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80.0
        }
        else {
            return 77.0
        }
    }
    
    //function invoke when user tapped on invite button from cell
    func clickOnInviteButton(_ sender:UIButton){
        var text: String = ""
        var name : String = ""
        var mobileArray : Array<String> = [] // holding available mobile number
        var emailArray : Array<String> = [] // holding available mobile number
        var nameArray : Array<String> = []
        
        //Validating if user alredy select for invitation
        if let contactArray = UserDefaults.standard.object(forKey: "InviteGroupArray") as? Array<Dictionary<String,AnyObject>>
        {
            for i in 0 ..< contactArray.count {
                
                var dict = contactArray[i] as Dictionary<String,AnyObject>
                if let phone = dict["mobile_number"] as? String
                {
                    mobileArray.append(String(format:"%@",phone))
                }
                if let email = dict["email"] as? String
                {
                    emailArray.append(email)
                }
                var name = ""
                if let first_name = dict["first_name"] as? String
                {
                     name = first_name//String(format:"%@ %@",dict["first_name"] as! String,dict["second_name"] as! String)
//                    nameArray.append(name)
                }
                if let last_name = dict["second_name"] as? String
                {
                    name = String(format:"%@ %@",name,last_name)
                    //                    nameArray.append(name)
                }
                if name.characters.count > 0{
                    nameArray.append(name)
                }
            }
        }
        //get all contact detail for invitation
        var dict : Dictionary<String,AnyObject> = [:]
        if sender.tag == 1 {
            if let mobileNum: String = contactDict["mobileNum"] as? String {
                dict["mobile_number"] = mobileNum.replacingOccurrences(of: "[^0-9]", with: "", options: NSString.CompareOptions.regularExpression, range: nil) as AnyObject
                let num = String(format: "+44%@", dict["mobile_number"] as! String)
                dict["mobile_number"] = num as AnyObject
                dict["email_id"] = "" as AnyObject
                 dict["NOMID"] = "4" as AnyObject
                text = num//mobileNum
                print(dict["mobile_number"]!)
            }
            else {
                if let emailStr: String = contactDict["email"] as? String {
                    dict["email_id"] = emailStr as AnyObject
                    dict["mobile_number"] = "" as AnyObject
                    dict["NOMID"] = "6" as AnyObject
                    text = emailStr
                }
            }
        }
        else {
            if let emailStr: String = contactDict["email"] as? String {
                dict["email_id"] = emailStr as AnyObject
                dict["mobile_number"] = "" as AnyObject
                dict["NOMID"] = "6" as AnyObject
                text = emailStr
            }
        }
        
        if let firstName = contactDict["name"] as? String
        {
            dict["first_name"] = String(format: "%@", firstName) as AnyObject
            name = String(format: "%@", contactDict["name"] as! String)
        }
        
        if let lastName = contactDict["lastName"] as? String
        {
//            dict["first_name"] = String(format: "%@ %@", contactDict["name"] as! String, lastName)
            dict["second_name"] = String(format: "%@", lastName) as AnyObject
            name = String(format: "%@ %@", contactDict["name"] as! String, contactDict["lastName"] as! String)
        }
  
        if(mobileArray.count > 0 || emailArray.count > 0)
        {
            //checking is contact alredy selected
            if(mobileArray.contains(text) || nameArray.contains(name))
            {
                let alert = UIAlertView(title: "Alert", message: "You have already invited this contact", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else if(emailArray.contains(text) || nameArray.contains(name)) {
                let alert = UIAlertView(title: "Alert", message: "You have already invited this contact", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
            else {
                //not selected then select contact for invitation
                delegate?.addedContact(dict)
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            delegate?.addedContact(dict)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
