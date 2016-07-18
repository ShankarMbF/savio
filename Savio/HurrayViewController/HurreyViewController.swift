//
//  HurreyViewController.swift
//  Savio
//
//  Created by Prashant on 23/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class HurreyViewController: UIViewController {
    @IBOutlet weak var btn:UIButton?
    var isSavingPresent:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//
//        btn?.layer.masksToBounds = true
        btn?.layer.cornerRadius = 5.0
    }
    
    func addShadowView(){
        
//        btn!.layer.shadowColor = UIColor(red: 222/256, green: 154/256, blue: 62/256, alpha: 1.0).CGColor
//        btn!.layer.shadowOffset = CGSize(width: 0, height: 2)
//        btn!.layer.shadowRadius = 4
//        btn!.layer.shadowOpacity = 10
//        btn!.layer.masksToBounds = false
    }


    @IBAction func createPlanPressed(sender: AnyObject) {
        let objContainer = ContainerViewController(nibName: "ContainerViewController", bundle: nil)

        self.navigationController?.pushViewController(objContainer, animated: true)
    }
}
