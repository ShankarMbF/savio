//
//  DefaultTextField.swift
//  Savio
//
//  Created by Bala-MAC on 5/23/17.
//  Copyright © 2017 Prashant. All rights reserved.
//

import UIKit

protocol DefaultTextFieldDelegate {
    func textFieldDidBeginEditing(textField: DefaultTextField)
    func textFieldShouldReturn(textField: DefaultTextField) -> Bool
}


class DefaultTextField: UITextField {
    
    @IBOutlet var nextTextField     : DefaultTextField?
    @IBOutlet var previousTextField : DefaultTextField?
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 5)
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    @IBInspectable var placeholderColor: UIColor? {
        get {
            return self.placeholderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
    
    
    func trimmedText() -> String? {
        return self.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }

}
