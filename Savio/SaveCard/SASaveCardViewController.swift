//
//  SASaveCardViewController.swift
//  Savio
//
//  Created by Maheshwari on 14/09/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASaveCardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var cardListView: UITableView!
    @IBOutlet weak var cardViewOne: UIView!
    @IBOutlet weak var cardViewTwo: UIView!
    @IBOutlet weak var cardLastFourDigitTextField: UITextField!
    
    var isFromSavingPlan = false
    var savedCardArray : Array<Dictionary<String,AnyObject>> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    func setUpView()
    {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("backButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.frame = CGRectMake(0, 0, 60, 30)
        btnName.setTitle("Done", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.95, green: 0.69, blue: 0.25, alpha: 1), forState: UIControlState.Normal)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 15)
        btnName.addTarget(self, action: Selector("doneBtnClicked"), forControlEvents: .TouchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        cardViewOne.layer.borderWidth = 1
        cardViewOne.layer.cornerRadius = 5
        cardViewOne.layer.borderColor = UIColor(red: 0.95, green: 0.69, blue: 0.25, alpha: 1).CGColor
        
        cardViewTwo.layer.borderWidth = 1
        cardViewTwo.layer.cornerRadius = 5
        cardViewTwo.layer.borderColor = UIColor(red: 0.97, green: 0.87, blue: 0.69, alpha: 1).CGColor
        
        if let saveCardArray = NSUserDefaults.standardUserDefaults().valueForKey("saveCardArray") as? Array<Dictionary<String,AnyObject>>
        {
            savedCardArray = saveCardArray
        }
        cardListView.selectRowAtIndexPath(NSIndexPath(forRow:0,inSection: 0), animated: true, scrollPosition:UITableViewScrollPosition.Top)
        cardListView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //NavigationBar button methods
    func backButtonClicked()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func doneBtnClicked()
    {
        let objPaymentView = SAPaymentFlowViewController()
        objPaymentView.showCardInfo = true
        self.navigationController?.pushViewController(objPaymentView, animated: true)
    }
    
    // MARK: - Tableview Delegate & Datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return savedCardArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        //--------create custom cell from CardTableViewCell.xib------------
        let bundleArr : Array = NSBundle.mainBundle().loadNibNamed("CardTableViewCell", owner: nil, options: nil) as Array
        let cell = bundleArr[0] as! CardTableViewCell
        let dict = savedCardArray[indexPath.row]
        let trimmedString: String = (dict["cardNumber"] as! NSString).substringFromIndex(max(dict["cardNumber"]!.length-4,0))
        let attributedString = NSMutableAttributedString(string: String(format: "%@ Ending in %@",dict["cardHolderName"] as! String,trimmedString))
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                      value: UIColor.blackColor(),
                                      range: NSRange(
                                        location:0,
                                        length:(dict["cardHolderName"] as! String).characters.count))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: kMediumFont ,size: 15)!, range: NSRange(
            location:0,
            length:(dict["cardHolderName"] as! String).characters.count))
        
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                      value: UIColor.blackColor(),
                                      range: NSRange(
                                        location:((dict["cardHolderName"] as! String).characters.count),
                                        length:11))
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: kLightFont,size: 15)!, range: NSRange(
            location:((dict["cardHolderName"] as! String).characters.count),
            length:11))
        
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                      value: UIColor.blackColor(),
                                      range: NSRange(
                                        location:((dict["cardHolderName"] as! String).characters.count) + 11,
                                        length:trimmedString.characters.count))
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: kMediumFont,size: 15)!, range: NSRange(
            location:((dict["cardHolderName"] as! String).characters.count) + 11,
            length:trimmedString.characters.count))
        
        cell.cardHolderNameLabel.attributedText = attributedString
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:CardTableViewCell? = cardListView!.cellForRowAtIndexPath(indexPath)as? CardTableViewCell
        //Changing background color of selected row
        selectedCell!.contentView.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        
        let dict = savedCardArray[indexPath.row]
        NSUserDefaults.standardUserDefaults().setValue(dict, forKey: "activeCard")
        NSUserDefaults.standardUserDefaults().synchronize()
        let trimmedString: String = (dict["cardNumber"] as! NSString).substringFromIndex(max(dict["cardNumber"]!.length-4,0))
        cardLastFourDigitTextField.text = trimmedString
        
    }
    
    @IBAction func addNewCardButtonPressed(sender: UIButton) {
        let objPaymentView = SAPaymentFlowViewController()
        self.navigationController?.pushViewController(objPaymentView, animated: true)
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
