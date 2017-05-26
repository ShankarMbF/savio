
//
//  SetDayTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol SegmentBarChangeDelegate
{
    func segmentBarChanged(_ str:String)
    func getDateTextField(_ str:String)
    
}

class SetDayTableViewCell: UITableViewCell,UIPopoverPresentationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var setDayDateButton : UIButton!
    @IBOutlet weak var BGContentView    : UIView!
    @IBOutlet weak var dayDateTextField : UITextField!
    @IBOutlet weak var dayDateLabel     : UILabel!
    @IBOutlet weak var titleLbl         : UILabel!
    @IBOutlet weak var dropDownImageView: UIImageView!
    @IBOutlet weak var segmentBar       : CustomSegmentBar!
    var acceptButton: UIBarButtonItem?

    var dayPickerView = UIPickerView()
    let dayArray    : Array<String> = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    let dateArray   : Array<String> = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28"]
    
    var segmentDelegate : SegmentBarChangeDelegate?
    var customToolBar : UIToolbar?
    weak var view : UIScrollView?
    var dateStr : String = ""
    var dayDateStr : String = kDate
    weak var tblView : UITableView?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    var lastOffset: CGPoint = CGPoint.zero
    var updatedDateStr: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        BGContentView.layer.cornerRadius = 5
        colorDataDict =  userDefaults.object(forKey: "colorDataDict") as! Dictionary<String,AnyObject>
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 5, height: 26)
        leftView.backgroundColor = UIColor.clear
        dayDateTextField.leftView = leftView
        dayDateTextField.leftViewMode = UITextFieldViewMode.always
        
        print(colorDataDict["savPlanID"] ?? "Id is not pressent")
        
        if(colorDataDict["savPlanID"] as! Int == 92) {
            titleLbl.text = "Adding funds every"
        }
        //add corner radius to textfield
        let maskPath1: UIBezierPath = UIBezierPath(roundedRect: dayDateTextField!.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: 3.0, height: 3.0))
        let maskLayer1: CAShapeLayer = CAShapeLayer()
        maskLayer1.frame = dayDateTextField!.bounds
        maskLayer1.path = maskPath1.cgPath
        dayDateTextField?.layer.mask = maskLayer1
        //Create custon tool bar for dayDateTextField
        customToolBar = UIToolbar(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 44))
         acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action:#selector(SetDayTableViewCell.doneBarButtonPressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SetDayTableViewCell.cancelBarButtonPressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil);
//        acceptButton?.enabled = false
        customToolBar!.items = [cancelButton,flexibleSpace,acceptButton!]

        dayDateTextField.delegate = self
        dayDateTextField.inputView = dayPickerView
        dayDateTextField.inputAccessoryView = customToolBar
        
        //add corner radius to dropdownimageview
        let maskPath2: UIBezierPath = UIBezierPath(roundedRect: dropDownImageView!.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: 3.0, height: 3.0))
        let maskLayer2: CAShapeLayer = CAShapeLayer()
        maskLayer2.frame = dropDownImageView!.bounds
        maskLayer2.path = maskPath2.cgPath
        dropDownImageView?.layer.mask = maskLayer2
        dropDownImageView.image = self.setDownWordImage()
        segmentBar.segmentSelected =  { (idx: Int)  in
            if(idx == 1) {
                self.dayDateLabel.text = kDate
                self.segmentDelegate!.segmentBarChanged(kDate)
                self.dayDateTextField.text = ""
                self.dayDateStr = kDate
               
            }
            else {
                self.dayDateLabel.text = kDay
                self.segmentDelegate!.segmentBarChanged(kDay)
                self.dayDateTextField.text = ""
                self.dayDateStr = kDay
                self.dayDateTextField.text = "Mon"
                self.dayDateTextField.font = UIFont(name: kMediumFont, size:10)
            }
            self.dayPickerView.reloadAllComponents()
            self.dayPickerView.selectRow(0, inComponent: 0, animated: false)
            self.segmentseletion()
        }
    }
    
    func segmentseletion() {
//        if(self.dayPickerView.selectedRowInComponent(0) == 0) {
//        if updatedDateStr?.characters.count > 0{
//            
//        }
            if(self.dayDateStr == kDate) {
                
                self.dayDateTextField.attributedText = self.createXLabelText(1, text: "1")
                self.segmentDelegate!.getDateTextField("1")
                dateStr = "1"
//                self.dayDateTextField.attributedText = self.createXLabelText(1, text: updatedDateStr!)
//                self.segmentDelegate!.getDateTextField(updatedDateStr!)
            }
            else {
                self.dayDateTextField.text = "Mon"
                self.dayDateTextField.font = UIFont(name: kMediumFont, size:10)
                self.segmentDelegate!.getDateTextField("Mon")
//                self.dayDateTextField.text = updatedDateStr!
//                self.dayDateTextField.font = UIFont(name: kMediumFont, size:10)
//                self.segmentDelegate!.getDateTextField(updatedDateStr!)
            }
//        }

    }
    
    
    fileprivate func createXLabelText (_ index: Int,text:String) -> NSMutableAttributedString {
        let fontNormal:UIFont? = UIFont(name: kMediumFont, size:10)
        let normalscript = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:fontNormal!,NSBaselineOffsetAttributeName:0])
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:5)
        switch index {
        case 1:
            let superscript = NSMutableAttributedString(string: "st", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        case 2:
            let superscript = NSMutableAttributedString(string: "nd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        case 3:
            let superscript = NSMutableAttributedString(string: "rd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        case 21:
            let superscript = NSMutableAttributedString(string: "st", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        case 22:
            let superscript = NSMutableAttributedString(string: "nd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        case 23:
            let superscript = NSMutableAttributedString(string: "rd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        default:
            let superscript = NSMutableAttributedString(string: "th", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            normalscript.append(superscript)
            break
            
        }
        
        return normalscript
    }
    
    func doneBarButtonPressed(){
        DispatchQueue.main.async{
            self.dayDateTextField.resignFirstResponder()
            self.dropDownImageView.image = self.setUpWordImage()
            if(self.dayPickerView.selectedRow(inComponent: 0) == 0) {
                if(self.dayDateStr == kDate) {
                    
                    self.dayDateTextField.attributedText = self.createXLabelText(1, text: "1")
                    self.segmentDelegate!.getDateTextField("1")
                }
                else {
                    self.dayDateTextField.text = "Mon"
                    self.dayDateTextField.font = UIFont(name: kMediumFont, size:10)
                    self.segmentDelegate!.getDateTextField("Mon")
                }
            }
            else {
                if(self.dayDateStr == kDate) {
                    let date : Int? = Int(self.dateStr)
                    if(date != 0 && self.dateStr.characters.count != 0)
                    {
                        self.dayDateTextField.attributedText = self.createXLabelText(date!, text: String(format: "%@",self.dateStr))
                    }
                }
                else {
                    self.dayDateTextField.font = UIFont(name: kMediumFont, size:10)
                    self.dayDateTextField.text = self.dateStr
                }
                self.segmentDelegate!.getDateTextField(self.dateStr)
            }
            self.dayPickerView.reloadAllComponents()
            
        }
    }
    
    func cancelBarButtonPressed(){
        DispatchQueue.main.async{
            self.dayDateTextField.resignFirstResponder()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        if(dayDateStr == kDay) {
            return dayArray.count
        }
        else {
            return dateArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if(dayDateStr == kDay) {
            return dayArray[row]
        }
        else {
            return dateArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
  
            if(dayDateStr == kDay) {
                dateStr =  dayArray[row]
            }
            else {
                dateStr =  dateArray[row]
            }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
//        self.doneBarButtonPressed()
           }
    
    func setUpWordImage()->UIImage
    {
        var imageName = ""
        if(colorDataDict["savPlanID"] as! Int == 85) {
            imageName = "group-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 86) {
            imageName = "wedding-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 87) {
            imageName = "baby-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 88) {
            imageName = "holiday-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 89) {
            imageName = "ride-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 90) {
            imageName = "home-updown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 91) {
            imageName = "gadget-updown.png"
        }
        else {
            imageName = "generic-updown.png"
        }
        return UIImage(named:imageName)!
    }
    
    func setDownWordImage()->UIImage
    {
        var imageName = ""
        if(colorDataDict["savPlanID"] as! Int == 85) {
            imageName = "group-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 86) {
            imageName = "wedding-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 87) {
            imageName = "baby-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 88) {
            imageName = "holiday-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 89) {
            imageName = "ride-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 90) {
            imageName = "home-dropdown.png"
        }
        else if(colorDataDict["savPlanID"] as! Int == 91) {
            imageName = "gadget-dropdown.png"
        }
        else {
            imageName = "generic-dropdown.png"
        }
        return UIImage(named:imageName)!
        
    }
    
    func setUpColor()-> UIColor
    {
        return ColorCodes.colorForCode(colorDataDict["savPlanID"] as! Int)
    }
    
    @IBAction func btnCLick(_ sender : AnyObject){
        self.dayDateTextField.becomeFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        self.registerForKeyboardNotifications()
        return true
    }
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(SetDayTableViewCell.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SetDayTableViewCell.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        
        let yOfTextField = dayDateTextField.frame.origin.y + (cellFrame?.origin.y)! + (tblView!.frame.origin.y) + self.frame.size.height
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
