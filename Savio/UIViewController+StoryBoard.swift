//
//  UIViewController+StoryBoard.swift
//  Savio
//
//  Created by Bala-MAC on 6/5/17.
//  Copyright © 2017 Prashant. All rights reserved.
//

import UIKit

extension UIViewController {

    func AlertContoller(UITitle : String?, UIMessage : String){
        let alertController = UIAlertController(title: UITitle, message: UIMessage, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }

}
