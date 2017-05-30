//
//  PasscodeTextField.swift
//  Savio
//
//  Created by Bala-MAC on 5/23/17.
//  Copyright © 2017 Prashant. All rights reserved.
//

import UIKit

class PasscodeTextField: UITextField {

    @IBOutlet var nextTextField: DefaultTextField?
    @IBOutlet var previousTextField: DefaultTextField?
    
    override func deleteBackward() {
        super.deleteBackward()
        let shouldDismiss = self.text?.characters.count == 0
        if shouldDismiss {
            if (self.delegate?.responds(to: #selector(self.delegate?.textField(_:shouldChangeCharactersIn:replacementString:))))! {
                _ = self.delegate?.textField!(self, shouldChangeCharactersIn: NSMakeRange(0, 0), replacementString: "")
            }
        }
    }

    func canPerformAction(action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
}
