//
//  FindAddressTableViewCell.swift
//  Savio
//
//  Created by Prashant on 19/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
protocol FindAddressCellDelegate {
    func getAddressButtonClicked(_ findAddrCell: FindAddressTableViewCell)
    func getTextFOrPostCode(_ findAddrCell: FindAddressTableViewCell)
}
class FindAddressTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var tfPostCode: UITextField?
    @IBOutlet weak var btnPostCode: UIButton?
    
    weak var tblView: UITableView?
    var delegate: FindAddressCellDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tfPostCode?.layer.cornerRadius = 2.0
        tfPostCode?.layer.masksToBounds = true
        tfPostCode?.layer.borderWidth=1.0
        tfPostCode?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue:120/256.0, alpha: 1.0).cgColor;
        tfPostCode?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center

        btnPostCode?.layer.cornerRadius = 2.0
        btnPostCode?.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(FindAddressTableViewCell.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FindAddressTableViewCell.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        
        var aRect = tfPostCode?.frame
        aRect?.size.height = (aRect?.size.height)! - (kbSize?.height)!
        if !aRect!.contains(self.frame.origin) {
            tblView?.scrollRectToVisible(self.frame, animated: true)
        }
    }
    
    @objc func keyboardWillBeHidden(_ notification: Notification){
        //do stuff
        
        let contentInsets: UIEdgeInsets =  UIEdgeInsets.zero;
        tblView?.contentInset = contentInsets;
        tblView?.scrollIndicatorInsets = contentInsets;
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        textField.textColor = UIColor.black
        self.registerForKeyboardNotifications()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField){
        self.removeKeyboardNotification()
    }
    //    func textFieldShouldEndEditing(textField: UITextField) -> Bool{
    //        self.removeKeyboardNotification()
    //        textField.resignFirstResponder()
    //        return true
    //    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        delegate?.getTextFOrPostCode(self)
        return true
    }
    @IBAction func clickOnAddressButton(_ sender:UIButton){
        tfPostCode?.resignFirstResponder()
        delegate?.getAddressButtonClicked(self)
    }

    
}
