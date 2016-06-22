//
//  CreateSavingPlanTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class CreateSavingPlanTableViewCell: UITableViewCell {

    @IBOutlet weak var createSavingPlanButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addShadowView()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func addShadowView(){
        createSavingPlanButton?.layer.cornerRadius = 2.0
        createSavingPlanButton!.layer.shadowColor = UIColor(red: 114/256, green: 177/256, blue: 237/256, alpha: 1.0).CGColor
        createSavingPlanButton!.layer.shadowOffset = CGSize(width: 0, height:3)
        createSavingPlanButton!.layer.shadowOpacity = 1
        createSavingPlanButton!.layer.masksToBounds = false
    }
    
}
