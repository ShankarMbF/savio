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
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var deleteButtonTopSpace: NSLayoutConstraint!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Set attributed title to delete button
        let attributes = [
            NSForegroundColorAttributeName : UIColor(red:100/256, green: 101/256, blue: 109/256, alpha: 1),
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
        ] as [String : Any]
        let attributedString = NSAttributedString(string: "Delete", attributes: attributes)
        btnDelete?.setAttributedTitle(attributedString, for: UIControlState())
        
        btnSavingPlan!.layer.cornerRadius = 5
        
        //set border to uiview
        vwProductDetail?.layer.borderWidth = 1.5
        vwProductDetail?.layer.borderColor = UIColor.white.cgColor
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
