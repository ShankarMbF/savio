//
//  DropDownCellTableViewCell.swift
//  DropDown
//
//  Created by Kevin Hirsch on 28/07/15.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

internal final class DropDownCell: UITableViewCell {
	
	//MARK: - Properties
	static let Nib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
	
	//UI
	@IBOutlet weak var optionLabel: UILabel!
	
	var selectedBackgroundColor: UIColor?

}

//MARK: - UI

internal extension DropDownCell {
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		backgroundColor = UIColor.clear
//        optionLabel?.layer.cornerRadius = 2.0
//        optionLabel?.layer.masksToBounds = true
//        optionLabel?.layer.borderWidth=1.0
//        optionLabel?.layer.borderColor = UIColor(red: 202/256.0, green: 175/256.0, blue:120/256.0, alpha: 1.0).CGColor;
	}
	
	override var isSelected: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override var isHighlighted: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		setSelected(highlighted, animated: animated)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		let executeSelection: () -> Void = { [unowned self] in
			if let selectedBackgroundColor = self.selectedBackgroundColor {
				if selected {
					self.backgroundColor = selectedBackgroundColor
                    self.optionLabel.textColor = UIColor.white
				} else {
					self.backgroundColor = UIColor.clear
                    self.optionLabel.textColor = UIColor.black
				}
			}
		}
		
		if animated {
			UIView.animate(withDuration: 0.3, animations: {
				executeSelection()
			})
		} else {
			executeSelection()
		}
	}
	
}
