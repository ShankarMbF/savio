//
//  SAImpulseSavingViewController.swift
//  Savio
//
//  Created by Maheshwari on 07/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

extension String {
    func chopPrefix(count: Int = 1) -> String {
        return self.substringFromIndex(self.startIndex.advancedBy(count))
    }
    
    func chopSuffix(count: Int = 1) -> String {
        return self.substringFromIndex(self.endIndex.advancedBy(-count))
    }
}

import UIKit


class SAImpulseSavingViewController: UIViewController {
    @IBOutlet weak var addFundsButton: UIButton!
    
    @IBOutlet weak var deductMoneyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var anotherStepLabel: UILabel!
    @IBOutlet weak var savedPaymentLabel: UILabel!
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var messagePopupImageView: UIImageView!
    @IBOutlet weak var messagePopUpView: UIView!
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    
    public var circleSlider: CircleSlider! {
        didSet {
            self.circleSlider.tag = 0
        }
    }
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
    
    private var valueLabel: UILabel!
    private var progressLabel: UILabel!
    private var timer: NSTimer?
    private var progressValue: Float = 0
    private var sliderOptions: [CircleSliderOption] {
        return [
            .BarColor(UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1)),
            .ThumbImage(UIImage (named: "slider-handle@2x.png")),
            .TrackingColor(UIColor(red: 244/255, green: 176/255, blue: 58/255, alpha: 1)),
            .BarWidth(20),
            .StartAngle(-90),
            .MaxValue(100),
            .MinValue(0),
            .ThumbWidth(30)
        ]
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.buildCircleSlider()
        self.setUpView()
        
    }
    
    
    private func buildCircleSlider() {
        
        self.circleSlider = CircleSlider(frame: CGRectMake(0, 0, circularView.frame.size.width, circularView.frame.size.height), options: self.sliderOptions)
        self.circleSlider?.addTarget(self, action: Selector("valueChange:"), forControlEvents: .ValueChanged)
        
        self.valueLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.valueLabel.textAlignment = .Center
        
        self.valueLabel.center = CGPoint(x: CGRectGetWidth(self.circleSlider.bounds) * 0.5, y: CGRectGetHeight(self.circleSlider.bounds) * 0.5)
        self.circleSlider.addSubview(self.valueLabel)
        circularView.addSubview(circleSlider)
    }
    
    
    func valueChange(sender: CircleSlider) {
        let singleAttribute3 = [ NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        messagePopUpView.hidden = true
        let attrString2 = NSAttributedString(string: String(format:"£%d",Int(sender.value)), attributes: singleAttribute3)
        priceTextField.attributedText = attrString2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.planButton!.bounds, byRoundingCorners: ([.TopRight, .TopLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.planButton!.bounds
        maskLayer.path = maskPath.CGPath
        self.planButton?.layer.mask = maskLayer
    }
    
    func setUpView(){
        
        scrlView.contentSize = CGSizeMake(0, 2300)
        
        
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), forState: UIControlState.Normal)
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), forState: UIControlState.Normal)
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        self.title = "Add Extra funds"
        
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        //set Navigation right button nav-heart
        
        let btnName = UIButton()

        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = str
            wishListArray = (NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>)!
            if(wishListArray.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
            }
            
            btnName.setTitle(String(format:"%d",wishListArray.count), forState: UIControlState.Normal)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        var customToolBar : UIToolbar?
        customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        customToolBar!.items = [acceptButton]

        priceTextField.inputAccessoryView = customToolBar
        priceTextField.layer.borderColor = UIColor.blackColor().CGColor
      
    }
    
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    
    //UITextfieldDelegate method
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
    
        messagePopUpView.hidden = true
        //If the UIScreen size is 480 move the View little bit up so the UITextField will not be hidden
        if(UIScreen.mainScreen().bounds.size.height == 480)
        {
            //UIViewAnimation for moving screen little bit up
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y-30), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
        }
        else if(UIScreen.mainScreen().bounds.size.height == 568)
        {
            //UIViewAnimation for moving screen little bit up
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y-60), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
            
        }
        return true
    }
    
    
    @IBAction func offersButtonPressed(sender: AnyObject) {
        let obj = SAOfferListViewController()
        obj.savID = 63
        let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
        NSUserDefaults.standardUserDefaults().synchronize()
        obj.hideAddOfferButton = true
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func spendButtonPressed(sender: AnyObject) {
        let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
        self.navigationController?.pushViewController(objPlan, animated: false)
    }

    func doneBarButtonPressed(){
        var tfString: String = priceTextField.text!
        tfString = tfString.chopPrefix(1)
        priceTextField.resignFirstResponder()
        circleSlider.value =  Float(tfString)!
        
        if(UIScreen.mainScreen().bounds.size.height == 480)
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y+30), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
        }
        else if(UIScreen.mainScreen().bounds.size.height == 568)
        {
            //UIViewAnimation for moving screen little bit up
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            view!.frame = CGRectMake(view!.frame.origin.x, (view!.frame.origin.y+60), view!.frame.size.width, view!.frame.size.height)
            UIView.commitAnimations()
            
        }

    }
   
    
    @IBAction func addFundsButtonPressed(sender: AnyObject) {
        if(addFundsButton.titleLabel?.text == "ADD FUNDS")
        {
            circularView.backgroundColor = UIColor(red : 244/255,
                green : 172/255,
                blue : 58/255, alpha: 1)
            circularView.layer.cornerRadius = circularView.frame.height / 2
            priceTextField.hidden = true
            priceLabel.text = String(format:"£%d",Int(circleSlider.value))
            circleSlider.hidden = true
            priceLabel.hidden = false
            anotherStepLabel.hidden = false
            savedPaymentLabel.hidden = false
            addFundsButton.setTitle("Continue", forState: .Normal)
            addFundsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            addFundsButton.backgroundColor = UIColor(red : 244/255,
                green : 172/255,
                blue : 58/255, alpha: 1)
            deductMoneyLabel.text = String(format:"Your payment of £%d has been added to your saving plan.",Int(circleSlider.value))
        }
        else
        {
            print("continue")
        }
        
        
    }
    
    
    func heartBtnClicked(){
        
        if wishListArray.count>0{
            
            let objSAWishListViewController = SAWishListViewController()
            objSAWishListViewController.wishListArray = wishListArray
            self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
        }
        else {
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
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
