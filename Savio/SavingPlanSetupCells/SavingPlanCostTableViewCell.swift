//
//  SavingPlanCostTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

protocol SavingPlanCostTableViewCellDelegate {
    func txtFieldCellText(_ txtFldCell:SavingPlanCostTableViewCell)
}
class SavingPlanCostTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var BGContentView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    weak var tblView : UITableView?
    weak var view : UIScrollView?
    var delegate: SavingPlanCostTableViewCellDelegate?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    var lastOffset: CGPoint = CGPoint.zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        costTextField.delegate = self
        //Get the dictionary of selected theme from NSUserdefaults
        colorDataDict =  userDefaults.object(forKey: "colorDataDict") as! Dictionary<String,AnyObject>
        // corner Radius of costTextField
        costTextField.layer.cornerRadius = 4
        //set the color and corner radius for minus and plus button
        minusButton.layer.cornerRadius = minusButton.frame.size.height / 2
        minusButton.setTitleColor(self.setUpColor(), for: UIControlState())
        minusButton.layer.masksToBounds = true
        
        plusButton.layer.cornerRadius = plusButton.frame.size.height / 2
        plusButton.layer.masksToBounds = true
        plusButton.setTitleColor(self.setUpColor(), for: UIControlState())
        
        slider.thumbTintColor = self.setUpColor()
        slider.setThumbImage(self.setUpImage(), for: UIControlState())
        slider.setThumbImage(self.setUpImage(), for: UIControlState.highlighted)
        
        var customToolBar : UIToolbar?
        customToolBar = UIToolbar(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action:#selector(SavingPlanCostTableViewCell.doneBarButtonPressed))
        customToolBar!.items = [acceptButton]
        costTextField.inputAccessoryView = customToolBar
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func doneBarButtonPressed() {
        if(costTextField.text?.characters.count > 1)
        {
            costTextField.resignFirstResponder()
            var textFieldValue: String  = (costTextField?.text)!
            textFieldValue = textFieldValue.chopPrefix(1)
            slider.value = Float(textFieldValue)!
            delegate?.txtFieldCellText(self)
            if(Float(textFieldValue)! > 3000) {
                let alert = UIAlertView(title: "Whoa!", message: "The maximum you can top up is £3000", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }else{
            let alert = UIAlertView(title: "Warning", message: "Please enter cost", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //get the Image for selected theme
    func setUpImage()-> UIImage
    {
        var imageName = ""
        if(colorDataDict["savPlanID"] as! Int == 85) {
            imageName = "group-save-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 86)
        {
            imageName = "wedding-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 87) {
            imageName = "baby-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 88) {
            imageName = "holiday-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 89) {
            imageName = "ride-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 90) {
            imageName = "home-circle.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 91) {
            imageName = "gadget-circle.png"
        }
        else {
            imageName = "generic-circle.png"
        }
        return UIImage(named:imageName)!
    }
    
    //get the color for selected theme
    func setUpColor()-> UIColor
    {
        return ColorCodes.colorForCode(colorDataDict["savPlanID"] as! Int)
    }
    
    //UISegmentcontrol value changed method
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        if(sender.value >= 2000) {
            sender.value = sender.value + 30;
        }
        else  if(sender.value <= 10){
//            sender.value = 0
        }
        else {
            sender.value = sender.value + 10;
        }
       
        
        //set the slider value
        self.costTextField.attributedText = self.createAttributedString("£" + String(format: "%d",Int(sender.value)))
        delegate?.txtFieldCellText(self)
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(SavingPlanCostTableViewCell.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SavingPlanCostTableViewCell.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func plusButtonPressed(_ sender: AnyObject) {
        if(slider.value >= 2000) {
            slider.value = slider.value + 30;
        }
        else {
            slider.value = slider.value + 10;
        }
        self.costTextField.attributedText = self.createAttributedString("£" + String(format: "%d",Int(slider.value)))
        delegate?.txtFieldCellText(self)
    }
    
    @IBAction func minusButtonPressed(_ sender: AnyObject) {
        if(slider.value >= 2000) {
            slider.value = slider.value - 30;
        }
        else {
            slider.value = slider.value - 10;
        }
        costTextField.text = String(format: " %d",Int(slider.value))
        self.costTextField.attributedText = self.createAttributedString("£" + String(format: "%d",Int(slider.value)))
        delegate?.txtFieldCellText(self)
    }
    
    //Keyboard notification function
    @objc func keyboardWasShown(_ notification: Notification){
        //do stuff
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue.size
        let visibleAreaHeight = UIScreen.main.bounds.height - 104 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
        //        let visibleRect = CGRect(x: 0, y: 0, width:  UIScreen.mainScreen().bounds.width, height: height)
        lastOffset = (view?.contentOffset)!
        let cellFrame = tblView?.rectForRow(at: (tblView?.indexPath(for: self))!)
        let yOfTextField = costTextField.frame.origin.y + (cellFrame?.origin.y)! + (tblView!.frame.origin.y) + self.frame.size.height
        if (yOfTextField - (lastOffset.y)) > visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            view?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(_ notification: Notification){
        //do stuff
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        view?.setContentOffset(lastOffset, animated: true)
    }
    
    //UITextfieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
            let alert = UIAlertView(title: "Whoa!", message: "The maximum you can top up is £3000", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            return false
        }
        if combinedString.characters.count < 6 {
            self.costTextField.attributedText = self.createAttributedString(combinedString)
            slider.value = Float(valueString)!
        }
        return false
    }
    
    func createAttributedString(_ string: String) -> NSAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes([NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)], range: NSRange(location: 0, length: 1))
        attributedString.addAttributes([NSForegroundColorAttributeName : self.setUpColor()], range: NSRange(location: 0, length: 1))
        return attributedString
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        self.registerForKeyboardNotifications()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        var textFieldValue: String  = (costTextField?.text)!
        textFieldValue = textFieldValue.chopPrefix(1)
        slider.value = Float(textFieldValue)!
        delegate?.txtFieldCellText(self)
        if(Float(textFieldValue) > 3000) {
            let alert = UIAlertView(title: "Whoa!", message: "The maximum you can top up is £3000", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        return true
    }
    
}
