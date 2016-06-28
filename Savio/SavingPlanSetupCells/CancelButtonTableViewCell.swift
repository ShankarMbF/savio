//
//  CancelButtonTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 27/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class CancelButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var cancelSavingPlanButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cancelSavingPlanButton.layer.shadowColor = UIColor(red: 205/255,green:62/255,blue:56/255,alpha:1).CGColor
        cancelSavingPlanButton.layer.shadowOffset = CGSizeMake(0, 3)
        cancelSavingPlanButton.layer.shadowOpacity = 1
        cancelSavingPlanButton.layer.cornerRadius = 5
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
