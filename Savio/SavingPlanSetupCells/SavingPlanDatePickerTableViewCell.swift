//
//  SavingPlanDatePickerTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol SavingPlanDatePickerCellDelegate {
    func datePickerText(date:Int,dateStr:String)

}
class SavingPlanDatePickerTableViewCell: UITableViewCell,UITextFieldDelegate,SegmentBarChangeDelegate {
    
    @IBOutlet weak var calenderImageView: UIImageView!
    @IBOutlet weak var datePickerTextField: UITextField!
    weak var tblView : UITableView?
    weak var view : UIView?
    var customToolBar : UIToolbar?
    var datePickerView:UIDatePicker = UIDatePicker()
    var savingPlanDatePickerDelegate : SavingPlanDatePickerCellDelegate?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    var segmentBarDelegate = SegmentBarChangeDelegate.self
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        datePickerView.datePickerMode = UIDatePickerMode.Date
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        components.day = +7
        let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        datePickerView.minimumDate = minDate
        
        let date = datePickerView.date
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "EEE dd/MM/yyyy"
        
        datePickerTextField.text = dateFormatter.stringFromDate(date)
        
        customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelBarButtonPressed"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar!.items = [cancelButton,flexibleSpace,acceptButton]
        datePickerTextField.delegate = self
        datePickerTextField.inputView = datePickerView
        datePickerTextField.inputAccessoryView = customToolBar
        
        calenderImageView.image = self.setUpImage()
        
    }
    
    func segmentBarChanged(str: String) {
        if(str == "date")
        {
            let dateComponents = NSDateComponents()
            dateComponents.month = 1
            let calender = NSCalendar.currentCalendar()
            let newDate = calender.dateByAddingComponents(dateComponents, toDate: NSDate(), options:NSCalendarOptions(rawValue: 0))
            datePickerView.minimumDate = newDate
        }
        else{
            let daysToAdd : Double = 7
            let newDate = NSDate().dateByAddingTimeInterval(60*60*24 * daysToAdd)
            datePickerView.minimumDate = newDate
            
        }
        
    }
    
    func getDateTextField(str: String) {
        
    }
    
    func setUpImage()-> UIImage
    {
        
        var imageName = ""
        if(colorDataDict["title"] as! String == "Group save")
        {
            imageName = "group-save-calendar.png"
        }
        else if(colorDataDict["title"] as! String == "Wedding")
        {
            imageName = "wedding-calendar.png"
        }
        else if(colorDataDict["title"] as! String == "Baby")
        {
            imageName = "baby-calendar.png"
        }
        else if(colorDataDict["title"] as! String == "Holiday")
        {
            imageName = "holiday-calendar.png"
        }
        else if(colorDataDict["title"] as! String == "Ride")
        {
            imageName = "ride-calendar.png"
        }
        else if(colorDataDict["title"] as! String == "Home")
        {
            imageName = "home-calendar.png"
        }
        else if(colorDataDict["title"] as! String == "Gadget")
        {
            imageName = "gadget-calendar.png"
        }
        else
        {
            imageName = "generic-calendar.png"
        }
        return UIImage(named:imageName)!
        
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func doneBarButtonPressed(){
        datePickerTextField.resignFirstResponder()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE dd/MM/yyyy"
        let pickrDate = dateFormatter.stringFromDate(datePickerView.date)
        datePickerTextField.text = pickrDate
        datePickerTextField.textColor = UIColor.whiteColor()
        let timeDifference : NSTimeInterval = datePickerView.date.timeIntervalSinceDate(NSDate())
        print(timeDifference)
        
        savingPlanDatePickerDelegate?.datePickerText(Int(timeDifference/3600),dateStr: datePickerTextField.text!)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        view!.frame = CGRectMake(view!.frame.origin.x, 0, view!.frame.size.width, view!.frame.size.height)
        UIView.commitAnimations()
        
    }
    
    func cancelBarButtonPressed(){
        datePickerTextField.resignFirstResponder()
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        view!.frame = CGRectMake(view!.frame.origin.x, 0, view!.frame.size.width, view!.frame.size.height)
        UIView.commitAnimations()
        
    }
    
    
    
    
    @objc func datePickerWasShown(notification: NSNotification){
        //do stuff
        
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize?.height)!, 0.0)
        tblView?.contentInset = contentInsets
        tblView?.scrollIndicatorInsets = contentInsets
        
        var aRect = datePickerTextField?.frame
        aRect?.size.height = (aRect?.size.height)! - (kbSize?.height)!
        if !CGRectContainsPoint(aRect!, self.frame.origin) {
            tblView?.scrollRectToVisible(self.frame, animated: true)
        }
    }
    
    @objc func datePickerWillBeHidden(notification: NSNotification){
        //do stuff
        
        let contentInsets: UIEdgeInsets =  UIEdgeInsetsZero;
        tblView?.contentInset = contentInsets;
        tblView?.scrollIndicatorInsets = contentInsets;
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        var y : Float = 0.0
        if(UIScreen.mainScreen().bounds.size.height == 480)
        {
            y = 220
        }
        else if(UIScreen.mainScreen().bounds.size.height == 568)
        {
            y = 150
        }
        else if(UIScreen.mainScreen().bounds.size.height == 667)
        {
            y = 50
        }
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y - CGFloat(y) ), view!.frame.size.width, view!.frame.size.height)
        UIView.commitAnimations()
        return true
    }
    
}
