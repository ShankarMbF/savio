//
//  OfferTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 06/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class OfferTableViewCell: UITableViewCell {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var offerDetailLabel: UILabel!
    @IBOutlet weak var offerTitleLabel: UILabel!
    @IBOutlet weak var offerImageView: UIImageView!
     weak var tblView : UITableView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        offerImageView.layer.cornerRadius = 5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
