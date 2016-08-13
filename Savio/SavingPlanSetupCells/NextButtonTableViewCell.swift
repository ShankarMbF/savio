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
        nextButton.layer.cornerRadius = 5
        nextButton.backgroundColor = self.setUpColor()
        btnVwBg.backgroundColor = self.setUpShadowColor()
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
        if(colorDataDict["title"] as! String == "Group Save")  {
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
            red = 133/255
            green = 227/255
            blue = 177/255
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
            green = 172/255
            blue = 58/255
        }
        return UIColor(red:red as CGFloat, green: green as CGFloat, blue: blue as CGFloat, alpha: 1)
    }

    func setUpShadowColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        if(colorDataDict["title"] as! String == "Group Save") {
            red = 122/255
            green = 182/255
            blue = 240/255
        }
        else if(colorDataDict["title"] as! String == "Wedding") {
            red = 138/255
            green = 132/255
            blue = 186/255
        }
        else if(colorDataDict["title"] as! String == "Baby") {
            red = 135/255
            green = 199/255
            blue = 165/255
        }
        else if(colorDataDict["title"] as! String == "Holiday") {
            red = 86/255
            green = 153/255
            blue = 146/255
        }
        else if(colorDataDict["title"] as! String == "Ride") {
            red = 202/255
            green = 60/255
            blue = 65/255
        }
        else if(colorDataDict["title"] as! String == "Home") {
            red = 231/255
            green = 149/255
            blue = 64/255
        }
        else if(colorDataDict["title"] as! String == "Gadget") {
            red = 166/255
            green = 180/255
            blue = 60/255
        }
        else {
            red = 244/255
            green = 148/255
            blue = 54/255
        }
        return UIColor(red:red as CGFloat, green: green as CGFloat, blue: blue as CGFloat, alpha: 1)
    }

}
