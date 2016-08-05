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
    weak var view : UIScrollView?
    var delegate: SavingPlanCostTableViewCellDelegate?
  
    
    @IBOutlet weak var BGContentView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var costTextField: UITextField!
    
    
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        costTextField.delegate = self
        //Get the dictionary of selected theme from NSUserdefaults
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        
        
        // corner Radius of costTextField, currencyLabel And BGContentView *************************
        //BGContentView.layer.cornerRadius = 5
        
        costTextField.layer.cornerRadius = 4
        // Corner Radius of End *************************
        
        
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
        var textFieldValue: String  = (costTextField?.text)!
        textFieldValue = textFieldValue.chopPrefix(1)
        slider.value = Float(textFieldValue)!
        delegate?.txtFieldCellText(self)
        
        
        if(Float(textFieldValue)! > 3000)
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
        self.costTextField.attributedText = self.createAttributedString("£" + String(format: "%d",Int(sender.value)))

//        costTextField.textColor = UIColor.whiteColor()
        delegate?.txtFieldCellText(self)
    }
    
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    
    @IBAction func plusButtonPressed(sender: AnyObject) {
        if(slider.value >= 2000)
        {
            slider.value = slider.value + 30;
        }
        else{
            slider.value = slider.value + 10;
        }
        self.costTextField.attributedText = self.createAttributedString("£" + String(format: "%d",Int(slider.value)))

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
        self.costTextField.attributedText = self.createAttributedString("£" + String(format: "%d",Int(slider.value)))

        delegate?.txtFieldCellText(self)
    }
    
    
    var lastOffset: CGPoint?
    //Keyboard notification function
    @objc func keyboardWasShown(notification: NSNotification){
        //do stuff
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)

        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let visibleAreaHeight = UIScreen.mainScreen().bounds.height - 104 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
        //        let visibleRect = CGRect(x: 0, y: 0, width:  UIScreen.mainScreen().bounds.width, height: height)
        lastOffset = (view?.contentOffset)!
        let cellFrame = tblView?.rectForRowAtIndexPath((tblView?.indexPathForCell(self))!)
        let yOfTextField = costTextField.frame.origin.y + (cellFrame?.origin.y)! + (tblView!.frame.origin.y) + self.frame.size.height
        if (yOfTextField - (lastOffset?.y)!) > visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            view?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //do stuff
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        view?.setContentOffset(lastOffset!, animated: true)
    }
    
    //UITextfieldDelegate method
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.characters.count > 1  && string == "" {
            return true
        }
        let combinedString = textField.text! + string
        let valueString = combinedString.chopPrefix(1)
        if valueString.characters.count == 0 {
            return false 
        }
        if(Float(valueString)! > 3000)
        {
             self.costTextField.attributedText = self.createAttributedString("£3000")
            slider.value = 3000
            let alert = UIAlertView(title: "Warning", message: "Please enter cost less than £ 3000", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            return false
        }

        if combinedString.characters.count < 6 {
        self.costTextField.attributedText = self.createAttributedString(combinedString)
            slider.value = Float(valueString)!
        }
        return false
    }
    
    func createAttributedString(string: String) -> NSAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(15)], range: NSRange(location: 0, length: 1))
        attributedString.addAttributes([NSForegroundColorAttributeName : self.setUpColor()], range: NSRange(location: 0, length: 1))
        return attributedString
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        self.registerForKeyboardNotifications()
        return true
    }


    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        var textFieldValue: String  = (costTextField?.text)!
        textFieldValue = textFieldValue.chopPrefix(1)
        
        slider.value = Float(textFieldValue)!
        delegate?.txtFieldCellText(self)

        if(Float(textFieldValue) > 3000)
        {
            let alert = UIAlertView(title: "Warning", message: "Please enter cost less than £ 3000", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        return true
    }
    
}
