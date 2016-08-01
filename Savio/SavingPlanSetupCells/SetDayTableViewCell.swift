//
//  SetDayTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol SegmentBarChangeDelegate {
    func segmentBarChanged(str:String)
    func getDateTextField(str:String)
}



class SetDayTableViewCell: UITableViewCell,UIPopoverPresentationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate {
    @IBOutlet weak var setDayDateButton: UIButton!

    @IBOutlet weak var BGContentView: UIView!
    @IBOutlet weak var dayDateTextField: UITextField!
    @IBOutlet weak var dayDateLabel: UILabel!
    // @IBOutlet weak var segmentControl: UISegmentedControl!
    var dayPickerView = UIPickerView()
    let dayArray : Array<String> = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    let dateArray : Array<String> = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28"]
    
    @IBOutlet weak var dropDownImageView: UIImageView!
    
    @IBOutlet weak var segmentBar: CustomSegmentBar!
    
    var segmentDelegate : SegmentBarChangeDelegate?
    var customToolBar : UIToolbar?
    weak var view : UIView?
    var dateStr : String = ""
    
    weak var tblView : UITableView?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    override func awakeFromNib() {
        super.awakeFromNib()
        
        BGContentView.layer.cornerRadius = 5
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
        
        let leftView = UIView()
        leftView.frame = CGRectMake(0, 0, 5, 26)
        leftView.backgroundColor = UIColor.clearColor()
        
        dayDateTextField.leftView = leftView
        dayDateTextField.layer.cornerRadius = 3
        dayDateTextField.leftViewMode = UITextFieldViewMode.Always
        
        customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelBarButtonPressed"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil);
        customToolBar!.items = [cancelButton,flexibleSpace,acceptButton]
        
        // Initialization cod
        
        // dayDateTextField.layer.borderColor = UIColor.clearColor().CGColor
        dayDateTextField.delegate = self
        dayDateTextField.inputView = dayPickerView
        dayDateTextField.inputAccessoryView = customToolBar
        
        let maskPath2: UIBezierPath = UIBezierPath(roundedRect: dropDownImageView!.bounds, byRoundingCorners: ([.TopRight, .BottomRight]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer2: CAShapeLayer = CAShapeLayer()
        maskLayer2.frame = dropDownImageView!.bounds
        maskLayer2.path = maskPath2.CGPath
        dropDownImageView?.layer.mask = maskLayer2
        
        dropDownImageView.backgroundColor = self.setUpColor()
        
        segmentBar.segmentSelected =  { (idx: Int)  in
            if(idx == 1)
            {
                self.dayDateLabel.text = "date"
                self.segmentDelegate!.segmentBarChanged("date")
            }
            else
            {
                self.dayDateLabel.text = "day"
                self.segmentDelegate!.segmentBarChanged("day")
            }
        }
        
    }
    
    
    func doneBarButtonPressed(){
        dayDateTextField.resignFirstResponder()
        
//        UIView.animateWithDuration(2.0, animations: {
//            self.dropDownImageView.transform = CGAffineTransformMakeRotation((180.0 * CGFloat(M_PI)) / 180.0)
//        })
        if(dayPickerView.selectedRowInComponent(0) == 0){
            if(dayDateLabel.text == "date")
            {
                
                dayDateTextField.text = "     1"
            }
            else
            {
                dayDateTextField.text = "Mon"
            }

        }
        else
        {
        if(dayDateLabel.text == "date")
        {
            
             dayDateTextField.text = String(format: "     %@",dateStr)
        }
        else
        {
             dayDateTextField.text = dateStr
        }
      

        }
        dayPickerView.reloadAllComponents()
        
        segmentDelegate!.getDateTextField(dateStr)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        view!.frame = CGRectMake(view!.frame.origin.x, 0, view!.frame.size.width, view!.frame.size.height)
        UIView.commitAnimations()
        
    }
    
    func cancelBarButtonPressed(){
        dayDateTextField.resignFirstResponder()
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        view!.frame = CGRectMake(view!.frame.origin.x, 0, view!.frame.size.width, view!.frame.size.height)
        UIView.commitAnimations()
        
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        if(dayDateLabel.text == "day")
        {
            return dayArray.count
        }
        else
        {
            return dateArray.count
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(dayDateLabel.text == "day")
        {
            return dayArray[row]
        }
        else
        {
            return dateArray[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(dayDateLabel.text == "day")
        {
            dateStr =  dayArray[row]
        }
        else
        {
            dateStr =  dateArray[row]
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setUpColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        
        if(colorDataDict["title"] as! String == "Group Save")
        {
            red = 161/255
            green = 214/255
            blue = 248/255
            
        }
        else if(colorDataDict["title"] as! String == "Wedding")
        {
            red = 189/255
            green = 184/255
            blue = 235/255
        }
        else if(colorDataDict["title"] as! String == "Baby")
        {
            red = 122/255
            green = 223/255
            blue = 172/255
        }
        else if(colorDataDict["title"] as! String == "Holiday")
        {
            red = 109/255
            green = 214/255
            blue = 200/255
        }
        else if(colorDataDict["title"] as! String == "Ride")
        {
            red = 242/255
            green = 104/255
            blue = 107/255
        }
        else if(colorDataDict["title"] as! String == "Home")
        {
            red = 244/255
            green = 161/255
            blue = 111/255
        }
        else if(colorDataDict["title"] as! String == "Gadget")
        {
            red = 205/255
            green = 220/255
            blue = 57/255
        }
        else
        {
            red = 244/255
            green = 176/255
            blue = 58/255
        }
        return UIColor(red:red as CGFloat, green: green as CGFloat, blue: blue as CGFloat, alpha: 1)
    }
    
    
    
    @IBAction func setDayDatePressed(sender: AnyObject) {
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        var y : Float = 0.0
        if(UIScreen.mainScreen().bounds.size.height == 480)
        {
            y = 250
        }
        else if(UIScreen.mainScreen().bounds.size.height == 568)
        {
            y = 220
        }
        else if(UIScreen.mainScreen().bounds.size.height == 667)
        {
            y = 120
        }
        dayPickerView.selectRow(0, inComponent: 0, animated: true)
       
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y - CGFloat(y) ), view!.frame.size.width, view!.frame.size.height)
        UIView.commitAnimations()
        return true
    }
}
