//
//  NextButtonTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 02/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class NextButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var btnVwBg: UIView!
    
    weak var tblView : UITableView?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    
   override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
//        nextButton.layer.shadowColor = self.setUpShadowColor().CGColor
//        nextButton.layer.shadowOffset = CGSizeMake(0, 3)
//        nextButton.layer.shadowOpacity = 1
        nextButton.layer.cornerRadius = 5
        nextButton.backgroundColor = self.setUpColor()
//    btnVwBg.backgroundColor = self.setUpColor()
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
 
        if(colorDataDict["title"] as! String == "Group Save")
        {
            red = 161/255
            green = 214/255
            blue = 248/255
            
        }
        else if(colorDataDict["title"] as! String == "Wedding")
        {
            red = 189/255
            green = 184/255
            blue = 235/255
        }
        else if(colorDataDict["title"] as! String == "Baby")
        {
            red = 133/255
            green = 227/255
            blue = 177/255
        }
        else if(colorDataDict["title"] as! String == "Holiday")
        {
            red = 109/255
            green = 214/255
            blue = 200/255
        }
        else if(colorDataDict["title"] as! String == "Ride")
        {
            red = 242/255
            green = 104/255
            blue = 107/255
        }
        else if(colorDataDict["title"] as! String == "Home")
        {
            red = 244/255
            green = 161/255
            blue = 111/255
        }
        else if(colorDataDict["title"] as! String == "Gadget")
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

    func setUpShadowColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        
        if(colorDataDict["title"] as! String == "Group Save")
        {
            red = 114/255
            green = 177/255
            blue = 237/255
            
        }
        else if(colorDataDict["title"] as! String == "Wedding")
        {
            red = 153/255
            green = 153/255
            blue = 255/255
        }
        else if(colorDataDict["title"] as! String == "Baby")
        {
            red = 133/255
            green = 222/255
            blue = 175/255
        }
        else if(colorDataDict["title"] as! String == "Holiday")
        {
            red = 0/255
            green = 153/255
            blue = 153/255
        }
        else if(colorDataDict["title"] as! String == "Ride")
        {
            red = 244/255
            green = 87/255
            blue = 95/255
        }
        else if(colorDataDict["title"] as! String == "Home")
        {
            red = 251/255
            green = 151/255
            blue = 80/255
        }
        else if(colorDataDict["title"] as! String == "Gadget")
        {
            red = 187/255
            green = 211/255
            blue = 54/255
        }
        else
        {
            red = 240/255
            green = 164/255
            blue = 57/255
        }
        return UIColor(red:red as CGFloat, green: green as CGFloat, blue: blue as CGFloat, alpha: 1)
    }

}
