//
//  SASaveCardViewController.swift
//  Savio
//
//  Created by Maheshwari on 14/09/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASaveCardViewController: UIViewController {

    @IBOutlet weak var cardViewOne: UIView!
    @IBOutlet weak var cardViewTwo: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    func setUpView()
    {
        cardViewOne.layer.borderWidth = 1
        cardViewOne.layer.cornerRadius = 5
        cardViewOne.layer.borderColor = UIColor(red: 0.95, green: 0.69, blue: 0.25, alpha: 1).CGColor
        
        cardViewTwo.layer.borderWidth = 1
        cardViewTwo.layer.cornerRadius = 5
        cardViewTwo.layer.borderColor = UIColor(red: 0.97, green: 0.87, blue: 0.69, alpha: 1).CGColor
        
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
