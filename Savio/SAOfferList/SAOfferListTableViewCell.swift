//
//  SAOfferListTableViewCell.swift
//  Savio
//
//  Created by Prashant on 06/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit



class SAOfferListTableViewCell: UITableViewCell {
    
     var colorDataDict : Dictionary<String,AnyObject> = [:]
    
     @IBOutlet weak var lblOfferSummary: UILabel?
     @IBOutlet weak var lblOfferTitle: UILabel?
    @IBOutlet weak var lblOfferDiscount: UILabel?
    @IBOutlet weak var lblProductOffer: UILabel?
    @IBOutlet weak var offerImage: UIImageView?

    @IBOutlet weak var btnAddOffer: UIButton?
    @IBOutlet weak var btnOfferDetail: UIButton?
   

    @IBOutlet weak var lblHT: NSLayoutConstraint!

    @IBOutlet weak var vwBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
         colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>
        lblOfferDiscount?.textColor = self.setUpColor()
        
        btnAddOffer?.backgroundColor = self.setUpColor()
        
        btnOfferDetail?.setTitleColor(self.setUpColor(), forState: UIControlState.Normal)
        //Set Shadow to saving plan button
        btnAddOffer!.layer.shadowColor = self.setUpShadowColor().CGColor
        btnAddOffer!.layer.shadowOffset = CGSizeMake(0, 2)
        btnAddOffer!.layer.shadowOpacity = 1
        btnAddOffer!.layer.cornerRadius = 5
        
        let attributes = [
            NSForegroundColorAttributeName : self.setUpColor(),
            NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue
        ]
        let attributedString = NSAttributedString(string: "Offer detail V", attributes: attributes)
        btnOfferDetail?.setAttributedTitle(attributedString, forState: UIControlState.Normal)

        
//        var attrs = [ NSFontAttributeName : UIFont(name: "GothamRounded-Book", size: 14.0),NSForegroundColorAttributeName : UIColor.redColor(),NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue]
        
       
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func setUpShadowColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        
        if(colorDataDict["header"] as! String == "Group Save")
        {
            red = 114/255
            green = 177/255
            blue = 237/255
            
        }
        else if(colorDataDict["header"] as! String == "Wedding")
        {
            red = 153/255
            green = 153/255
            blue = 255/255
        }
        else if(colorDataDict["header"] as! String == "Baby")
        {
            red = 133/255
            green = 222/255
            blue = 175/255
        }
        else if(colorDataDict["header"] as! String == "Holiday")
        {
            red = 0/255
            green = 153/255
            blue = 153/255
        }
        else if(colorDataDict["header"] as! String == "Ride")
        {
            red = 244/255
            green = 87/255
            blue = 95/255
        }
        else if(colorDataDict["header"] as! String == "Home")
        {
            red = 251/255
            green = 151/255
            blue = 80/255
        }
        else if(colorDataDict["header"] as! String == "Gadget")
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

}
