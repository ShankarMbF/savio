//
//  SavingPlanTitleTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol SavingPlanTitleTableViewCellDelegate {
    func getTextFieldText(_ text:String)
    
}
class SavingPlanTitleTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    weak var tblView : UITableView?
    weak var view : UIScrollView?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    var savingPlanTitleDelegate: SavingPlanTitleTableViewCellDelegate?
    var lastOffset: CGPoint = CGPoint.zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleTextField.delegate = self
        titleTextField.layer.cornerRadius = 5
        colorDataDict =  userDefaults.object(forKey: "colorDataDict") as! Dictionary<String,AnyObject>
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(SavingPlanTitleTableViewCell.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SavingPlanTitleTableViewCell.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //get the color for selected theme
    func setUpColor()-> UIColor
    {
     return ColorCodes.colorForCode(colorDataDict["savPlanID"] as! Int)
    }
    
  
    //Keyboard notification function
    @objc func keyboardWasShown(_ notification: Notification){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue.size
        lastOffset = (view?.contentOffset)!
        let visibleAreaHeight = UIScreen.main.bounds.height - 64 - (kbSize?.height)! //64 height of nav bar + status bar
        let yOfTextField = titleTextField.frame.origin.y + (self.superview?.frame.origin.y)! + (tblView!.frame.origin.y) + self.frame.size.height

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
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        titleTextField.textColor = setUpColor()
        self.registerForKeyboardNotifications()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        savingPlanTitleDelegate?.getTextFieldText(textField.text!)
    }
    
    //UITextfieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        titleTextField.textColor = setUpColor()
        return true
    }
    
}
