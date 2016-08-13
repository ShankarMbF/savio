//
//  SavingPlanTitleTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol SavingPlanTitleTableViewCellDelegate {
    func getTextFieldText(text:String)
    
}
class SavingPlanTitleTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    weak var tblView : UITableView?
    weak var view : UIScrollView?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    var savingPlanTitleDelegate: SavingPlanTitleTableViewCellDelegate?
    var lastOffset: CGPoint = CGPointZero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleTextField.delegate = self
        titleTextField.layer.cornerRadius = 5
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //get the color for selected theme
    func setUpColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        
        if(colorDataDict["title"] as! String == "Group Save") {
            red = 161/255
            green = 214/255
            blue = 248/255
        }
        else if(colorDataDict["title"] as! String == "Wedding") {
            red = 189/255
            green = 184/255
            blue = 235/255
        }
        else if(colorDataDict["title"] as! String == "Baby") {
            red = 122/255
            green = 223/255
            blue = 172/255
        }
        else if(colorDataDict["title"] as! String == "Holiday") {
            red = 109/255
            green = 214/255
            blue = 200/255
        }
        else if(colorDataDict["title"] as! String == "Ride") {
            red = 242/255
            green = 104/255
            blue = 107/255
        }
        else if(colorDataDict["title"] as! String == "Home") {
            red = 244/255
            green = 161/255
            blue = 111/255
        }
        else if(colorDataDict["title"] as! String == "Gadget") {
            red = 205/255
            green = 220/255
            blue = 57/255
        }
        else {
            red = 244/255
            green = 176/255
            blue = 58/255
        }
        return UIColor(red:red as CGFloat, green: green as CGFloat, blue: blue as CGFloat, alpha: 1)
    }
    
  
    //Keyboard notification function
    @objc func keyboardWasShown(notification: NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        lastOffset = (view?.contentOffset)!
        let visibleAreaHeight = UIScreen.mainScreen().bounds.height - 64 - (kbSize?.height)! //64 height of nav bar + status bar
        let yOfTextField = titleTextField.frame.origin.y + (self.superview?.frame.origin.y)! + (tblView!.frame.origin.y) + self.frame.size.height

        if (yOfTextField - (lastOffset.y)) > visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            view?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //do stuff
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        view?.setContentOffset(lastOffset, animated: true)
    }
    
    //UITextfieldDelegate method
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        titleTextField.textColor = setUpColor()
        self.registerForKeyboardNotifications()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        savingPlanTitleDelegate?.getTextFieldText(textField.text!)
    }
    
    //UITextfieldDelegate method
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount) {
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if (newLength > 20) {
            return false;
        }
        return true;
    }
    
    //UITextfieldDelegate method
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        titleTextField.textColor = setUpColor()
        return true
    }
    
}
