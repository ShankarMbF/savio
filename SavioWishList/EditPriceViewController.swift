//
//  EditPriceViewController.swift
//  Savio
//
//  Created by Maheshwari on 07/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit


protocol TeamViewProtocol {
    func sendingViewController(viewController: EditPriceViewController, sentItem: String)
}


class EditPriceViewController: UIViewController {
    var delegate: TeamViewProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
