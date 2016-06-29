//
//  SavingPlanCostTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
protocol SavingPlanCostTableViewCellDelegate {
    func txtFieldCellText(txtFldCell:SavingPlanCostTableViewCell)
}
class SavingPlanCostTableViewCell: UITableViewCell,UITextFieldDelegate {
    weak var tblView : UITableView?
    weak var view : UIView?
    var delegate: SavingPlanCostTableViewCellDelegate?
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var costTextField: UITextField!
    
    
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    
    @IBOutlet weak var currencyLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        costTextField.delegate = self
        //Get the dictionary of selected theme from NSUserdefaults
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        
        //set the color and corner radius for minus and plus button
        minusButton.layer.cornerRadius = minusButton.frame.size.height / 2
        minusButton.setTitleColor(self.setUpColor(), forState: UIControlState.Normal)
        minusButton.layer.masksToBounds = true
        
        plusButton.layer.cornerRadius = plusButton.frame.size.height / 2
        plusButton.layer.masksToBounds = true
        plusButton.setTitleColor(self.setUpColor(), forState: UIControlState.Normal)
        
        slider.thumbTintColor = self.setUpColor()
        slider.setThumbImage(self.setUpImage(), forState: UIControlState.Normal)
        slider.setThumbImage(self.setUpImage(), forState: UIControlState.Highlighted)
        
        currencyLabel.textColor = self.setUpColor()
        let leftView = UIView()
        leftView.frame = CGRectMake(0, 0, 5, 26)
        leftView.backgroundColor = UIColor.clearColor()
        
        costTextField.leftView = leftView
        costTextField.leftViewMode = UITextFieldViewMode.Always
        
        var customToolBar : UIToolbar?
        customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        
        customToolBar!.items = [acceptButton]
        
        costTextField.inputAccessoryView = customToolBar
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func doneBarButtonPressed() {
        costTextField.resignFirstResponder()
        slider.value = (costTextField.text! as NSString).floatValue
        delegate?.txtFieldCellText(self)
        
        
        if(UIScreen.mainScreen().bounds.size.height == 480)
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y+100), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
        }
        else if(UIScreen.mainScreen().bounds.size.height == 568)
        {
            //UIViewAnimation for moving screen little bit up
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y+150), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
            
        }
        if((costTextField.text! as NSString).floatValue > 3000)
        {
            let alert = UIAlertView(title: "Warning", message: "Please enter cost less than £ 3000", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
    }
    
    //get the Image for selected theme
    func setUpImage()-> UIImage
    {
        
        var imageName = ""
        if(colorDataDict["title"] as! String == "Group Save")
        {
            imageName = "group-save-circle.png"
        }
        else if(colorDataDict["title"] as! String == "Wedding")
        {
            imageName = "wedding-circle.png"
        }
        else if(colorDataDict["title"] as! String == "Baby")
        {
            imageName = "baby-circle.png"
        }
        else if(colorDataDict["title"] as! String == "Holiday")
        {
            imageName = "holiday-circle.png"
        }
        else if(colorDataDict["title"] as! String == "Ride")
        {
            imageName = "ride-circle.png"
        }
        else if(colorDataDict["title"] as! String == "Home")
        {
            imageName = "home-circle.png"
        }
        else if(colorDataDict["title"] as! String == "Gadget")
        {
            imageName = "gadget-circle.png"
        }
        else
        {
            imageName = "generic-circle.png"
        }
        return UIImage(named:imageName)!
        
    }
    
    //get the color for selected theme
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
    
    //UISegmentcontrol value changed method
    @IBAction func sliderValueChanged(sender: UISlider) {
        if(sender.value >= 2000)
        {
            sender.value = sender.value + 30;
        }
        else{
            sender.value = sender.value + 10;
        }
        
        //set the slider value
        costTextField.text = String(format: "%d",Int(sender.value))
        costTextField.textColor = UIColor.whiteColor()
        delegate?.txtFieldCellText(self)
    }
    
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func plusButtonPressed(sender: AnyObject) {
        if(slider.value >= 2000)
        {
            slider.value = slider.value + 30;
        }
        else{
            slider.value = slider.value + 10;
        }
        
        costTextField.text = String(format: "%d",Int(slider.value))
        costTextField.textColor = UIColor.whiteColor()
        delegate?.txtFieldCellText(self)
    }
    @IBAction func minusButtonPressed(sender: AnyObject) {
        if(slider.value >= 2000)
        {
            slider.value = slider.value - 30;
        }
        else
        {
            slider.value = slider.value - 10;
        }
        
        costTextField.text = String(format: " %d",Int(slider.value))
        costTextField.textColor = UIColor.whiteColor()
        delegate?.txtFieldCellText(self)
    }
    
    
    //Keyboard notification function
    
    @objc func keyboardWasShown(notification: NSNotification){
        //do stuff
        
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize?.height)!, 0.0)
        tblView?.contentInset = contentInsets
        tblView?.scrollIndicatorInsets = contentInsets
        
        var aRect = costTextField?.frame
        aRect?.size.height = (aRect?.size.height)! - (kbSize?.height)!
        if !CGRectContainsPoint(aRect!, self.frame.origin) {
            tblView?.scrollRectToVisible(self.frame, animated: true)
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //do stuff
        
        let contentInsets: UIEdgeInsets =  UIEdgeInsetsZero;
        tblView?.contentInset = contentInsets;
        tblView?.scrollIndicatorInsets = contentInsets;
    }
    
    //UITextfieldDelegate method
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        
        textField.textColor = UIColor.whiteColor()
        //If the UIScreen size is 480 move the View little bit up so the UITextField will not be hidden
        if(UIScreen.mainScreen().bounds.size.height == 480)
        {
            //UIViewAnimation for moving screen little bit up
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y-100), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
        }
        else if(UIScreen.mainScreen().bounds.size.height == 568)
        {
            //UIViewAnimation for moving screen little bit up
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y-150), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
            
        }
            
        else{
            self.registerForKeyboardNotifications()
        }
        return true
    }
    
    //UITextfieldDelegate method
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if (newLength > 4) {
            return false;
        }
        return true;
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        slider.value = (costTextField.text! as NSString).floatValue
        delegate?.txtFieldCellText(self)
        
        if(UIScreen.mainScreen().bounds.size.height == 480)
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y+100), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
        }
        else if(UIScreen.mainScreen().bounds.size.height == 568)
        {
            //UIViewAnimation for moving screen little bit up
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y+150), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
            
        }
        
        
        if((costTextField.text! as NSString).floatValue > 3000)
        {
            let alert = UIAlertView(title: "Warning", message: "Please enter cost less than £ 3000", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        return true
    }
    
}
