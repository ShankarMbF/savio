//
//  NumericTextTableViewCell.swift
//  Savio
//
//  Created by Prashant on 13/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol NumericTxtTableViewCellDelegate {
    func numericCellText(txtFldCell:NumericTextTableViewCell)
}
class NumericTextTableViewCell: UITableViewCell,UITextFieldDelegate {

    var delegate: NumericTxtTableViewCellDelegate?
    @IBOutlet weak var tf: UITextField?
    weak var tblView: UITableView?
    @IBOutlet weak var tlBar: UIToolbar?
    var prevStr: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tf?.layer.cornerRadius = 2.0
        tf?.layer.masksToBounds = true
        tf?.layer.borderWidth=1.0
        tf?.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor;
        tf?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        let placeholder = NSAttributedString(string:"" , attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
        tf?.attributedPlaceholder = placeholder;
        tf?.delegate = self
        tf!.inputAccessoryView = tlBar
        prevStr = (tf?.text)!

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NumericTextTableViewCell.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NumericTextTableViewCell.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    
    @objc func keyboardWasShown(notification: NSNotification){
        //do stuff
        /*
         let info: NSDictionary = notification.userInfo! as NSDictionary
         let keyboardFrame: CGRect = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue
         let loginFormFrame: CGRect = self.convertRect(tblView!.frame, fromView: nil)
         let coveredFrame: CGRect = CGRectIntersection(loginFormFrame, keyboardFrame)
         
         
         tblView!.setContentOffset(CGPointMake(0, coveredFrame.height + 20), animated: true)
         */
        
        
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize?.height)!, 0.0)
        tblView?.contentInset = contentInsets
        tblView?.scrollIndicatorInsets = contentInsets
        
        var aRect = tf?.frame
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
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        tf!.textColor = UIColor.blackColor()
        self.registerForKeyboardNotifications()
        return true
    }
    func textFieldDidEndEditing(textField: UITextField){
        //        self.removeKeyboardNotification()
        self.delegate?.numericCellText(self)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if(textField.placeholder == "Mobile number" ){
            return  self.checkTextFieldTextLength(textField, range: range, replacementString: string, len: 15)
            
        }
        
        return true;
    }
    //    func textFieldShouldEndEditing(textField: UITextField) -> Bool{
    //        self.removeKeyboardNotification()
    //        textField.resignFirstResponder()
    //        return true
    //    }
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        self.delegate?.numericCellText(self)
        return true
    }
    
    func checkTextFieldTextLength(txtField: UITextField,range: NSRange, replacementString string: String, len: Int) -> Bool {
        let currentCharacterCount = txtField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if (newLength > len) {
            return false;
        }
        return true
    }
    
    @IBAction func clickOnDoneBtn(){
        tf!.resignFirstResponder()
        prevStr = (tf?.text)!
//        tf!.text = prevStr
        delegate?.numericCellText(self)
    }
    
    @IBAction func clickOnCancelBtn(){
        tf!.resignFirstResponder()
        tf!.text = prevStr
        delegate?.numericCellText(self)
    }
}
