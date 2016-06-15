//
//  SetDayTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol SegmentBarChangeDelegate {
    func segmentBarChanged(str:String)
}

class SetDayTableViewCell: UITableViewCell,UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var setDayDateButton: UIButton!
    
    @IBOutlet weak var dayDateTextField: UITextField!
    @IBOutlet weak var dayDateLabel: UILabel!
   // @IBOutlet weak var segmentControl: UISegmentedControl!
   
    @IBOutlet weak var segmentBar: CustomSegmentBar!
    
    var segmentDelegate : SegmentBarChangeDelegate?
    
    weak var tblView : UITableView?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        
        // Initialization cod
        
        let layer =  CAGradientLayer()
        layer.frame.size = setDayDateButton.frame.size
        layer.startPoint = CGPointZero
        layer.endPoint = CGPointMake(1, 0)
        let colorGreen = UIColor.whiteColor().CGColor
        let colorBlack = self.setUpColor().CGColor
        
        layer.colors = [colorGreen, colorGreen, colorBlack, colorBlack]
        layer.locations = [0.0, 0.7, 0.7, 1.0]
        layer.cornerRadius = 5
        
        setDayDateButton.layer.insertSublayer(layer, atIndex: 0)
        

        segmentBar.segmentSelected =  { (idx: Int)  in
            if(idx == 0)
            {
                 self.dayDateLabel.text = "day"
            }
            else
            {
                 self.dayDateLabel.text = "date"
            }
        }
        
    }
    
    
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setUpColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        
        if(colorDataDict["header"] as! String == "Group Save")
        {
            red = 161/255
            green = 214/255
            blue = 248/255
            
        }
        else if(colorDataDict["header"] as! String == "Wedding")
        {
            red = 189/255
            green = 184/255
            blue = 235/255
        }
        else if(colorDataDict["header"] as! String == "Baby")
        {
            red = 122/255
            green = 223/255
            blue = 172/255
        }
        else if(colorDataDict["header"] as! String == "Holiday")
        {
            red = 109/255
            green = 214/255
            blue = 200/255
        }
        else if(colorDataDict["header"] as! String == "Ride")
        {
            red = 242/255
            green = 104/255
            blue = 107/255
        }
        else if(colorDataDict["header"] as! String == "Home")
        {
            red = 244/255
            green = 161/255
            blue = 111/255
        }
        else if(colorDataDict["header"] as! String == "Gadget")
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

   
    
    @IBAction func setDayDatePressed(sender: AnyObject) {
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    @IBAction func segmentControlChanged(sender: UISegmentedControl) {
        
        print(sender.titleForSegmentAtIndex(sender.selectedSegmentIndex))
        if(sender.selectedSegmentIndex == 0) {
            dayDateLabel.text = "date"
            segmentDelegate!.segmentBarChanged("date")
        }
        else{
            dayDateLabel.text = "day"
            segmentDelegate!.segmentBarChanged("day")
        }
    }
}
