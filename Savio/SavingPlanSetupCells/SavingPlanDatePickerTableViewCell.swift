//
//  SavingPlanDatePickerTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol SavingPlanDatePickerCellDelegate {
    func datePickerText(_ date:Int,dateStr:String)
    
}
class SavingPlanDatePickerTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var BGContentView: UIView!
    @IBOutlet weak var calenderImageView: UIImageView!
    @IBOutlet weak var datePickerTextField: UITextField!
    
    weak var tblView : UITableView?
    weak var view : UIScrollView?
    var customToolBar : UIToolbar?
    var datePickerView:UIDatePicker = UIDatePicker()
    var savingPlanDatePickerDelegate : SavingPlanDatePickerCellDelegate?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    var lastOffset: CGPoint = CGPoint.zero
    var dateString = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        colorDataDict =  userDefaults.object(forKey: "colorDataDict") as! Dictionary<String,AnyObject>
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE dd/MM/yyyy"
        var dateComponents = DateComponents()
        let calender = Calendar.current
        dateComponents.month = 3
        let newDate = (calender as NSCalendar).date(byAdding: dateComponents, to: Date(), options:NSCalendar.Options(rawValue: 0))
        self.datePickerView.minimumDate = Date()
        self.datePickerView.date = newDate!
         datePickerTextField.text = dateFormatter.string(from: newDate!)
        
        // cornerRadius changes
        datePickerTextField.layer.cornerRadius = 5
        BGContentView.layer.cornerRadius = 5
        customToolBar = UIToolbar(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action:#selector(SavingPlanDatePickerTableViewCell.doneBarButtonPressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SavingPlanDatePickerTableViewCell.cancelBarButtonPressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil);
        customToolBar!.items = [cancelButton,flexibleSpace,acceptButton]
        datePickerTextField.delegate = self
        datePickerTextField.inputView = datePickerView
        datePickerTextField.inputAccessoryView = customToolBar
        calenderImageView.image = self.setUpImage()
        
    }
    
    func setUpImage()-> UIImage
    {
        var imageName = ""
        if(colorDataDict["savPlanID"] as! Int == 85) {
            imageName = "group-save-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 86) {
            imageName = "wedding-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 87) {
            imageName = "baby-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 88) {
            imageName = "holiday-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 89) {
            imageName = "ride-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 90) {
            imageName = "home-calendar.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 91) {
            imageName = "gadget-calendar.png"
        }
        else {
            imageName = "generic-calendar.png"
        }
        return UIImage(named:imageName)!
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func doneBarButtonPressed(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE dd/MM/yyyy"
        let pickrDate = dateFormatter.string(from: datePickerView.date)
        datePickerTextField.text = pickrDate
        datePickerTextField.textColor = UIColor.white
        
        let timeDifference : TimeInterval = datePickerView.date.timeIntervalSince(Date())
        savingPlanDatePickerDelegate?.datePickerText(Int(timeDifference/3600),dateStr: datePickerTextField.text!)
        
        datePickerTextField.resignFirstResponder()
    }
       
    
    func cancelBarButtonPressed(){
        datePickerTextField.resignFirstResponder()
        
    }
    func changeDatePickerViewDate()
    {
        var dateComponents = DateComponents()
        let calender = Calendar.current
        if(dateString == kDate){
            dateComponents.month = 1
        }else {
            dateComponents.day = 7
        }
        let newDate = (calender as NSCalendar).date(byAdding: dateComponents, to: Date(), options:NSCalendar.Options(rawValue: 0))
        self.datePickerView.minimumDate = newDate
    }
    
    
    @objc func datePickerWasShown(_ notification: Notification){
        //do stuff
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize?.height)!, 0.0)
        tblView?.contentInset = contentInsets
        tblView?.scrollIndicatorInsets = contentInsets
        var aRect = datePickerTextField?.frame
        aRect?.size.height = (aRect?.size.height)! - (kbSize?.height)!
        if !aRect!.contains(self.frame.origin) {
            tblView?.scrollRectToVisible(self.frame, animated: true)
        }
    }
    
    @objc func datePickerWillBeHidden(_ notification: Notification){
        //do stuff
        let contentInsets: UIEdgeInsets =  UIEdgeInsets.zero;
        tblView?.contentInset = contentInsets;
        tblView?.scrollIndicatorInsets = contentInsets;
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        //self.changeDatePickerViewDate()
        self.registerForKeyboardNotifications()
        return true
    }
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(SavingPlanDatePickerTableViewCell.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SavingPlanDatePickerTableViewCell.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Keyboard notification function
    @objc func keyboardWasShown(_ notification: Notification){
        //do stuff
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue.size
        let visibleAreaHeight = UIScreen.main.bounds.height - 104 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
        lastOffset = (view?.contentOffset)!
        let cellFrame = tblView?.rectForRow(at: (tblView?.indexPath(for: self))!)
        
        let yOfTextField = datePickerTextField.frame.origin.y + (cellFrame?.origin.y)! + (tblView!.frame.origin.y) + self.frame.size.height
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
    
}
