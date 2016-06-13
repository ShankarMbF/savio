//
//  WishListTableViewCell.swift
//  Savio
//
//  Created by Prashant on 04/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class WishListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btnSavingPlan: UIButton?
    @IBOutlet weak var btnDelete: UIButton?
    @IBOutlet weak var vwProductDetail: UIView?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Set attributed title to delete button
        let attributes = [
            NSForegroundColorAttributeName : UIColor(red:100/256, green: 101/256, blue: 109/256, alpha: 1),
            NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue
        ]
        let attributedString = NSAttributedString(string: "Delete", attributes: attributes)
        btnDelete?.setAttributedTitle(attributedString, forState: UIControlState.Normal)
        
        //Set Shadow to saving plan button
        btnSavingPlan!.layer.shadowColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        btnSavingPlan!.layer.shadowOffset = CGSizeMake(0, 2)
        btnSavingPlan!.layer.shadowOpacity = 1
        btnSavingPlan!.layer.cornerRadius = 5
        
        //set border to uiview
        vwProductDetail?.layer.borderWidth = 1.5
        vwProductDetail?.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
