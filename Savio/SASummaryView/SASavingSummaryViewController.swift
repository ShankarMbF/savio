//
//  SASavingSummaryViewController.swift
//  Savio
//
//  Created by Prashant on 08/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASavingSummaryViewController: UIViewController {
    

    @IBOutlet weak var vwCongrats : UIView?
    @IBOutlet weak var vwScrContent : UIView?
    @IBOutlet weak var vwSummary : UIView?
    @IBOutlet weak var vwOffer : UIView?
    @IBOutlet weak var vwOfferSubView : UIView?
    @IBOutlet weak var scrlVw : UIScrollView?
    @IBOutlet weak var lblOffer : UILabel?
    @IBOutlet weak var btnContinue : UIButton?

    @IBOutlet weak var htOfferView: NSLayoutConstraint!
    @IBOutlet weak var htContentView: NSLayoutConstraint!
    @IBOutlet weak var topSpaceForContinue: NSLayoutConstraint!
    
    var colorDataDict : Dictionary<String,AnyObject> = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
      self.setUpView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setUpView(){
        colorDataDict =  NSUserDefaults.standardUserDefaults().objectForKey("colorDataDict") as! Dictionary<String,AnyObject>

        btnContinue?.backgroundColor = self.setUpColor()
        btnContinue!.layer.shadowColor = self.setUpShadowColor().CGColor
        btnContinue!.layer.shadowOffset = CGSizeMake(0, 2)
        btnContinue!.layer.shadowOpacity = 1
        btnContinue!.layer.cornerRadius = 5
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: #selector(SASavingSummaryViewController.menuButtonClicked), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "Create a saving plan"
        //set Navigation right button nav-heart
        
        let btnName = UIButton()
        //        btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: #selector(SASavingSummaryViewController.heartBtnClicked), forControlEvents: .TouchUpInside)
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        vwCongrats?.layer.borderColor = UIColor.whiteColor().CGColor
        vwCongrats?.layer.borderWidth = 2.0
        vwScrContent?.layer.cornerRadius = 1.0
        vwScrContent?.layer.masksToBounds = true
        var contentRect = CGRectZero;
        
        vwSummary?.layer.borderColor = UIColor.blackColor().CGColor
        vwSummary?.layer.borderWidth = 1.5
        
        lblOffer?.hidden = true
         topSpaceForContinue.constant = 30
        htOfferView.constant = 0
        
        let offerCount = 2
         for var i=0; i<offerCount; i++ {
            
            lblOffer?.hidden = false
            // Load the TestView view.
            let testView = NSBundle.mainBundle().loadNibNamed("SummaryPage", owner: self, options: nil)[0] as! UIView
            // Set its frame and data to pageview
            testView.frame = CGRectMake(0, (CGFloat(i) * testView.frame.size.height) + 30, testView.frame.size.width - 60, testView.frame.size.height)
            vwOffer?.addSubview(testView)
            testView.layer.borderColor = UIColor.blackColor().CGColor
            testView.layer.borderWidth = 1.0
            
            htOfferView.constant = (CGFloat(i) * testView.frame.size.height) + 30
            htContentView.constant = (vwOffer?.frame.origin.y)! + htOfferView.constant + 200
            topSpaceForContinue.constant = 80
            scrlVw?.contentSize = CGSizeMake(0, (vwScrContent?.frame.size.height)!)

        }
        
        
//        for var i: CGFloat = 0.0; i<offerCount; i++ {
//            
//            var contentRect = CGRectZero;
//            
//            contentRect = CGRectMake(0, (i * 80)+10 , UIScreen.mainScreen().bounds.size.width - 60 , 80)
//            
//            let vw: UIView = vwOfferSubView!
//            
//            vw.frame = contentRect
//            vw.addSubview(vwOfferSubView!)
//            
//            
//        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlVw?.contentSize = CGSizeMake(0, (vwScrContent?.frame.size.height)!)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    //MARK: Bar button action
    func menuButtonClicked(){
        
    }
    
    func heartBtnClicked(){
        
    }
    
    
    
    func setUpShadowColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        
        if(colorDataDict["header"] as! String == "Group Save")
        {
            red = 114/255
            green = 177/255
            blue = 237/255
            
        }
        else if(colorDataDict["header"] as! String == "Wedding")
        {
            red = 153/255
            green = 153/255
            blue = 255/255
        }
        else if(colorDataDict["header"] as! String == "Baby")
        {
            red = 133/255
            green = 222/255
            blue = 175/255
        }
        else if(colorDataDict["header"] as! String == "Holiday")
        {
            red = 0/255
            green = 153/255
            blue = 153/255
        }
        else if(colorDataDict["header"] as! String == "Ride")
        {
            red = 244/255
            green = 87/255
            blue = 95/255
        }
        else if(colorDataDict["header"] as! String == "Home")
        {
            red = 251/255
            green = 151/255
            blue = 80/255
        }
        else if(colorDataDict["header"] as! String == "Gadget")
        {
            red = 187/255
            green = 211/255
            blue = 54/255
        }
        else
        {
            red = 240/255
            green = 164/255
            blue = 57/255
        }
        return UIColor(red:red as CGFloat, green: green as CGFloat, blue: blue as CGFloat, alpha: 1)
    }
    
    func setUpColor()-> UIColor
    {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue: CGFloat  = 0.0
        
        if(colorDataDict["header"] as! String == "Group Save")
        {
            red = 161/255
            green = 214/255
            blue = 248/255
            
        }
        else if(colorDataDict["header"] as! String == "Wedding")
        {
            red = 189/255
            green = 184/255
            blue = 235/255
        }
        else if(colorDataDict["header"] as! String == "Baby")
        {
            red = 122/255
            green = 223/255
            blue = 172/255
        }
        else if(colorDataDict["header"] as! String == "Holiday")
        {
            red = 109/255
            green = 214/255
            blue = 200/255
        }
        else if(colorDataDict["header"] as! String == "Ride")
        {
            red = 242/255
            green = 104/255
            blue = 107/255
        }
        else if(colorDataDict["header"] as! String == "Home")
        {
            red = 244/255
            green = 161/255
            blue = 111/255
        }
        else if(colorDataDict["header"] as! String == "Gadget")
        {
            red = 205/255
            green = 220/255
            blue = 57/255
        }
        else
        {
            red = 244/255
            green = 176/255
            blue = 58/255
        }
        return UIColor(red:red as CGFloat, green: green as CGFloat, blue: blue as CGFloat, alpha: 1)
    }
}
