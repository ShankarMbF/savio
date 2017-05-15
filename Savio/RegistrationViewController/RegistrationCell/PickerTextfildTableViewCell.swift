//
//  PickerTextfildTableViewCell.swift
//  Savio
//
//  Created by Prashant Mali on 21/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol PickerTxtFieldTableViewCellDelegate {
    func selectedDate(_ txtFldCell:PickerTextfildTableViewCell)
//    func cancleToSelectDate(txtFldCell:PickerTextfildTableViewCell)
}

class PickerTextfildTableViewCell: UITableViewCell,UITextFieldDelegate{

    @IBOutlet weak var tfDatePicker: UITextField!
    weak var tblView: UITableView?
    var previousDate: String?

    @IBOutlet weak var toolBarInput: UIToolbar?
    
    var datePickerView:UIDatePicker = UIDatePicker()

    var delegate: PickerTxtFieldTableViewCellDelegate?


    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tfDatePicker.inputAccessoryView = toolBarInput
        previousDate = tfDatePicker.text!
        
        tfDatePicker?.layer.cornerRadius = 2.0
        tfDatePicker?.layer.masksToBounds = true
        tfDatePicker?.layer.borderWidth=1.0
        tfDatePicker?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue: 120/256.0, alpha: 1.0).cgColor;

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectDate(_ sender: UITextField) {
        previousDate = tfDatePicker.text
        
        //        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        //        datePickerView.maximumDate=NSDate()
        
        
        let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let currentDate: Date = Date()
        var components: DateComponents = DateComponents()
        
        components.year = -18
        let minDate: Date = (gregorian as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
        datePickerView.maximumDate = minDate
        
        datePickerView.addTarget(self, action: #selector(PickerTextfildTableViewCell.datePickerValueChanged(_:)), for: UIControlEvents.valueChanged)
        //               datePickerView.selectRow(0!, inComponent: 0, animated: false)
        
    }
    
    func setDateToTextField(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        tfDatePicker.text = dateFormatter.string(from: datePickerView.date)
        previousDate = tfDatePicker.text!
        delegate?.selectedDate(self)


    }

    func datePickerValueChanged(_ sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        tfDatePicker.text = dateFormatter.string(from: datePickerView.date)
       self.setDateToTextField()
    }
    
    @IBAction func toolBarDoneBtnClicked(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
       let todayDate = dateFormatter.string(from: Date())
        
        let pickrDate = dateFormatter.string(from: datePickerView.date)
        
        if todayDate == pickrDate{
            let allarme = UIAlertView(title: "Warning", message: "Birthdate should not be today's date", delegate: nil, cancelButtonTitle: "Ok")
            allarme.show()
        }else {
        self.setDateToTextField()
        tfDatePicker.resignFirstResponder()
        previousDate = tfDatePicker.text!
        delegate?.selectedDate(self)
        }
        
    }
    
    @IBAction func toolBarCancleBtnClicked(){
        tfDatePicker.resignFirstResponder()
        previousDate = tfDatePicker.text!
        delegate?.selectedDate(self)

//        delegate?.cancleToSelectDate(self)
    }

}








































































