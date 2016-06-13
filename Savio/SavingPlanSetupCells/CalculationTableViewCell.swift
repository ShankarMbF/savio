//
//  CalculationTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 01/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class CalculationTableViewCell: UITableViewCell {

    @IBOutlet weak var calculationLabel: UILabel!
       weak var tblView : UITableView?
    var colorDataDict : Dictionary<String,AnyObject> = [:]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
