//
//  TermsAndConditionView.swift
//  PostalCodeVerification-Demo
//
//  Created by Maheshwari on 19/05/16.
//  Copyright © 2016 Maheshwari. All rights reserved.
//

import UIKit

protocol ImportantInformationViewDelegate {
    func acceptPolicy(obj:ImportantInformationView)
}

class ImportantInformationView: UIView {
 
    var delegate: ImportantInformationViewDelegate?
    @IBOutlet weak var termsAndConditionTextView: UITextView!
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code

        //set the shadow color for accept button
        gotItButton.layer.shadowColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        
        //set the content offset for textview so it,will begin at point(0,0)
        termsAndConditionTextView.contentOffset = CGPointMake(0, 0)
      }
    
    @IBAction func gotItButtonPressed(sender: AnyObject) {
        self.removeFromSuperview()
        delegate?.acceptPolicy(self)
    }

}
