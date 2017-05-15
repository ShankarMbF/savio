//
//  TitleTableViewCell.swift
//  Savio
//
//  Created by Prashant on 18/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol TitleTableViewCellDelegate {
    func titleCellText(_ titleCell:TitleTableViewCell)

}

class TitleTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var tfTitle: UITextField?
    @IBOutlet weak var tfName: UITextField?
    weak var tblView: UITableView?
     var delegate: TitleTableViewCellDelegate?
    weak var dict: NSDictionary?
    let dropDown = DropDown()
    var prevName = ""

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tfTitle?.layer.cornerRadius = 2.0
        tfTitle?.layer.masksToBounds = true
        tfTitle?.layer.borderWidth=1.0
//        tfTitle?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
        tfTitle?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        tfTitle?.delegate=self

        
        tfName?.layer.cornerRadius = 2.0
        tfName?.layer.masksToBounds = true
        tfName?.layer.borderWidth=1.0
//        tfName?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).CGColor;
        tfName?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        tfName?.delegate=self
        
        dropDown.dataSource = [
            "Mr.",
            "Ms."
        ]

        dropDown.selectionAction = { [unowned self] (index, item) in
            self.tfTitle?.text = item
            self.delegate?.titleCellText(self);
            
        }
        
        //		dropDown.cancelAction = { [unowned self] in
        //			self.dropDown.selectRowAtIndex(-1)
        //			self.actionButton.setTitle("Canceled", forState: .Normal)
        //		}
        
        dropDown.anchorView = tfTitle
        dropDown.selectionBackgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        dropDown.bottomOffset = CGPoint(x: 0, y:tfTitle!.bounds.height)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(TitleTableViewCell.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TitleTableViewCell.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    
    @objc func keyboardWasShown(_ notification: Notification){
        //do stuff
        
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize?.height)!, 0.0)
        tblView?.contentInset = contentInsets
        tblView?.scrollIndicatorInsets = contentInsets
        
        var aRect = tfName?.frame
        aRect?.size.height = (aRect?.size.height)! - (kbSize?.height)!
        if !aRect!.contains(self.frame.origin) {
            tblView?.scrollRectToVisible(self.frame, animated: true)
        }
 
    }
    
    @objc func keyboardWillBeHidden(_ notification: Notification){
        //do stuff
        prevName = (tfName?.text)!
          self.delegate?.titleCellText(self)
        let contentInsets: UIEdgeInsets =  UIEdgeInsets.zero;
        tblView?.contentInset = contentInsets;
        tblView?.scrollIndicatorInsets = contentInsets;
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        textField.textColor = UIColor.black
        if textField == tfTitle{
            self.showOrDismiss()
            return false
        }
        
        self.registerForKeyboardNotifications()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField){
        textField.resignFirstResponder()
        self.removeKeyboardNotification()
        prevName = textField.text!
        self.delegate?.titleCellText(self)
    }
//    func textFieldShouldEndEditing(textField: UITextField) -> Bool{
//        self.removeKeyboardNotification()
//        textField.resignFirstResponder()
//        return true
//    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
          prevName = textField.text!
        self.delegate?.titleCellText(self)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.placeholder == "Name" ){
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            if (newLength > 50) {
                return false;
            }
             var firstName = textField.text! + string
            if string == "" {
                firstName = String(firstName.characters.dropLast())
            }
            prevName = firstName
            self.delegate?.titleCellText(self)
        }
        
        return true;
    }
    
    func showOrDismiss(){
        if dropDown.isHidden {
            dropDown.show()
        } else {
            dropDown.hide()
        }
    }
    
    @IBAction func clickeOnDropDownArrow(_ sender:UIButton){
        self.showOrDismiss()
    }
    
}
