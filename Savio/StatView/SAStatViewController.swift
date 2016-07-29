//
//  SAStatViewController.swift
//  Savio
//
//  Created by Prashant on 27/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
import Social
import Google
import SafariServices

class SAStatViewController: UIViewController, LineChartDelegate, UIDocumentInteractionControllerDelegate,SFSafariViewControllerDelegate {
    
    @IBOutlet weak var GraphContentView: UIView!
    @IBOutlet weak var scrHt: NSLayoutConstraint!
    var planType = ""
    var lineChart: LineChart!
    var label = UILabel()
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    @IBOutlet weak var scrlView: UIScrollView?
    @IBOutlet weak var contentView: UIView?
    var itemTitle = ""
    var endDate = ""
    var cost = ""
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var makeImpulseBtn: UIButton!
    @IBOutlet var scrollViewForGraph: UIScrollView!
    
    @IBOutlet var widthOfContentView: NSLayoutConstraint!
    @IBOutlet var graphSliderView: UISlider!
    
    @IBOutlet weak var sharingVw: UIView?
    @IBOutlet weak var lbl: UILabel?
    
    var xLabels: [String] = []
    var documentInteractionController = UIDocumentInteractionController()
    var shareImg: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        
        //        label.text = itemTitle
        //        label.font = UIFont(name: "GothamRounded-Book", size: 16)
        //        label.translatesAutoresizingMaskIntoConstraints = false
        //        label.textAlignment = NSTextAlignment.Center
        //        self.contentView!.addSubview(label)
        lineChart = LineChart()
        lineChart.planTitle = self.planType

        lineChart.maximumValue = 3000
        lineChart.minimumValue = 0
        
        let data: [CGFloat] = [0,600,600,-1,-1]
        
        // simple line with custom x axis labels // hear need to pass json value
        xLabels = ["1","2","3","4","5"]
        
        lineChart.animation.enabled = true
        lineChart.area = true
        
        // hide grid line Visiblity
        lineChart.x.grid.visible = true
        lineChart.y.grid.visible = true
        
        // hide dots visiblety in line chart
        // lineChart.dots.visible = false
        
        lineChart.x.labels.visible = true
        lineChart.x.grid.count = CGFloat(data.count)
        lineChart.x.grid.color = UIColor.grayColor()
        lineChart.y.grid.count = CGFloat(xLabels.count)
        lineChart.y.grid.color = UIColor.grayColor()
        
        lineChart.x.labels.values = xLabels
        lineChart.y.labels.visible = true
        
        lineChart.addLine(data)
        //  lineChart.addLine(data2)
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        
        self.contentView?.addSubview(lineChart)
        if planType == "Individual" {
        GraphContentView.backgroundColor = UIColor(red: 252/255,green:246/255,blue:236/255,alpha:1)
    }
        else{
             GraphContentView.backgroundColor = UIColor(red: 239/255,green:247/255,blue:253/255,alpha:1)
        }
    }
    
    // MARK: - Delegates and functions for  line chart
    func setValuesForSlider(min: CGFloat, max: CGFloat) {
        self.graphSliderView.maximumValue = Float(max)
        self.graphSliderView.minimumValue = Float(min)
        self.lineChart.drawScrollLineForPoint(min)
        let trackImage = UIImage(named: "stats-slider-bar")?.stretchableImageWithLeftCapWidth(5, topCapHeight: 0)
        self.graphSliderView.setMinimumTrackImage(trackImage, forState: UIControlState.Normal)
        self.graphSliderView.setMaximumTrackImage(trackImage, forState: .Normal)
        if planType == "Individual" {
            self.graphSliderView.setThumbImage(UIImage(named: "generic-stats-slider-tab"), forState: UIControlState.Normal)
        }
        else{
            self.graphSliderView.setThumbImage(UIImage(named: "group-save-stats-slider-tab"), forState: UIControlState.Normal)
        }
//        self.graphSliderView.setThumbImage(UIImage(named: "generic-stats-slider-tab"), forState: UIControlState.Normal)
        self.scrollViewForGraph.contentOffset = CGPoint(x: Double(CGFloat(self.graphSliderView.minimumValue) / 2.0 ), y: 0  )
    }
    
    @IBAction func graphSliderValueChanged(sender: UISlider) {
        let widthScrollView : CGFloat = self.scrollViewForGraph.frame.size.width
        let widthOfContentView: CGFloat = self.widthOfContentView.constant
        if widthOfContentView > widthScrollView {
            let fraction: CGFloat = (widthOfContentView - widthScrollView) / CGFloat (self.graphSliderView.maximumValue)
            if sender.value <= self.graphSliderView.minimumValue {
                self.scrollViewForGraph.contentOffset = CGPoint(x: 5, y: 0  )
            } else {
                self.scrollViewForGraph.contentOffset = CGPoint(x: Double(CGFloat(sender.value) * fraction ), y: 0  )
            }
        }
        self.lineChart.sliderValueChanged(sender)
    }
    
    //MARK: -
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var views: [String: AnyObject] = [:]
        
        //        views["label"] = label
        //        self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: [], metrics: nil, views: views))
        //        self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[label]", options: [], metrics: nil, views: views))
        views["chart"] = lineChart
        if xLabels.count > 5 {
            self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[chart]-|", options: [], metrics: nil, views: views))
            let offsetSpace = 70
            let constant = String.init(format: "H:|-[chart(%d)]-|", xLabels.count * offsetSpace)
            self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constant, options: [], metrics: nil, views: views))
            self.widthOfContentView.constant = CGFloat( xLabels.count * offsetSpace)
            self.scrollViewForGraph.contentSize = CGSize(width: CGFloat( xLabels.count * offsetSpace), height: self.scrollViewForGraph.frame.height)
        }
        else  {
            self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: [], metrics: nil, views: views))
            self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[chart]-|", options: [], metrics: nil, views: views))
            self.widthOfContentView.constant = self.scrollViewForGraph.frame.width
            self.scrollViewForGraph.contentSize = CGSize(width: self.scrollViewForGraph.frame.width, height: self.scrollViewForGraph.frame.height)
        }
        
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.planButton!.bounds, byRoundingCorners: ([.TopRight, .TopLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.planButton!.bounds
        maskLayer.path = maskPath.CGPath
        self.planButton?.layer.mask = maskLayer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView(){
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.title = "My Plan"
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        
        //        makeImpulseBtn!.layer.shadowColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        //        makeImpulseBtn!.layer.shadowOffset = CGSizeMake(0, 2)
        //        makeImpulseBtn!.layer.shadowOpacity = 1
        makeImpulseBtn!.layer.cornerRadius = 5
        
        
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), forState: UIControlState.Normal)
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), forState: UIControlState.Normal)
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: Selector("menuButtonClicked"), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "My Plan"
        //set Navigation right button nav-heart
        
        let btnName = UIButton()
        //btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: Selector("heartBtnClicked"), forControlEvents: .TouchUpInside)
        
        if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as! NSData
            wishListArray = (NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>)!
            
            if(wishListArray.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            else{
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
            }
            
            btnName.setTitle(String(format:"%d",wishListArray.count), forState: UIControlState.Normal)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        if(planType == "Individual")
        {
        let attrText = NSMutableAttributedString(string: String(format: "My %@ saving plan target is £%@",itemTitle,cost))
        
        attrText.addAttribute(NSFontAttributeName,
                              value: UIFont(
                                name: "GothamRounded-Medium",
                                size: 16.0)!,
                              range: NSRange(
                                location: 3,
                                length: itemTitle.characters.count))
        
        
        lbl!.attributedText = attrText
        }
        else
        {
            /*
            let attrText = NSMutableAttributedString(string: String(format: "Our target is %@",cost))
            
            attrText.addAttribute(NSFontAttributeName,
                                  value: UIFont(
                                    name: "GothamRounded-Medium",
                                    size: 15.0)!,
                                  range: NSRange(
                                    location: 4,
                                    length: itemTitle.characters.count))
            */
            
            
            lbl!.text = String(format: "Our target is £%@",cost)
            lbl?.textColor = UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1)
            self.view.bringSubviewToFront(lbl!)
        }

    }
    
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        
        if wishListArray.count>0{
            let objSAWishListViewController = SAWishListViewController()
            objSAWishListViewController.wishListArray = wishListArray
            self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
        }
        else{
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    @IBAction func clickOnProgressBtn(sender:UIButton){
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func offersButtonPressed(sender: AnyObject) {
        
        let obj = SAOfferListViewController()
        obj.savID = 63
        let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :"63"]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey:"colorDataDict")
        NSUserDefaults.standardUserDefaults().synchronize()
        obj.hideAddOfferButton = true
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func spendButtonPressed(sender: AnyObject) {
        
        let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
        self.navigationController?.pushViewController(objPlan, animated: false)
    }
    
    
    @IBAction func makeImpulseSavingPressed(sender: AnyObject) {
        
        let objImpulseSave = SAImpulseSavingViewController()
        self.navigationController?.pushViewController(objImpulseSave, animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func didSelectDataPoint(x: CGFloat, yValues: Array<CGFloat>) {
        label.text = "\(yValues[0])"
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        //        if let chart = lineChart {
        //            chart.setNeedsDisplay()
        //        }
    }
    
    
    //Mark: - Social Sharing
    
    @IBAction func clickedOnAchivements(sender: UIButton){
        let testView = NSBundle.mainBundle().loadNibNamed("SocialSharingView", owner: self, options: nil)[0] as! UIView
        
        testView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        
        let vw = testView.viewWithTag(7)! as UIView
        vw.layer.borderWidth = 2.0
        if(planType == "Individual")
        {
            vw.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
            shareImg = UIImage(named: "generic-streak-popup.png")
        }
        else
        {
            vw.layer.borderColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1).CGColor
            shareImg = UIImage(named: "generic-streak-popup.png")
        }
       
        let imgVw = testView.viewWithTag(10) as! UIImageView
        imgVw.image = shareImg
        
        let btnClose = testView.viewWithTag(6)! as! UIButton
        btnClose.addTarget(self, action: Selector("closeSharePopup:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let fbBtn = testView.viewWithTag(2) as! UIButton
        fbBtn.addTarget(self, action: Selector("clickedOnSocialMediaButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let twBtn = testView.viewWithTag(3) as! UIButton
        twBtn.addTarget(self, action: Selector("clickedOnSocialMediaButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let glBtn = testView.viewWithTag(4) as! UIButton
        glBtn.addTarget(self, action: Selector("clickedOnSocialMediaButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let waBtn = testView.viewWithTag(5) as! UIButton
        waBtn.addTarget(self, action: Selector("clickedOnSocialMediaButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.navigationController?.view.addSubview(testView)
    }
    
    //Close the share popup
    func closeSharePopup(sender: UIButton) {
        sender.superview?.superview!.removeFromSuperview()
    }
    
    func clickedOnSocialMediaButton(sender: UIButton){
        print(sender.tag)
        
        switch sender.tag {
        case 2:
            self.shareOnFacebook(sender)
            
        case 3:
            self.shareOnTwitter(sender)
        case 4:
            self.shareOnGoogle(sender)
        case 5:
            self.shareOnWhatsApp(sender)
        default:
            print("Nothing")
        }
        self.shareOnFacebook(sender)
    }
    
    func shareOnFacebook(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Share on Facebook")
            
            self.presentViewController(facebookSheet, animated: true, completion: nil)
            
            //        self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    func shareOnTwitter(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Share on Twitter")
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func shareOnWhatsApp(sender: UIButton) {
        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            if let whatsappURL = NSURL(string: urlString) {
                
                if UIApplication.sharedApplication().canOpenURL(whatsappURL) {
                    
                    if let image = shareImg {
                        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                            let tempFile = NSURL(fileURLWithPath: NSHomeDirectory()).URLByAppendingPathComponent("Documents/whatsAppTmp.wai")
                            do {
                                try imageData.writeToURL(tempFile, options: .DataWritingAtomic)
                                documentInteractionController = UIDocumentInteractionController(URL: tempFile)
                                documentInteractionController.UTI = "net.whatsapp.image"
                                documentInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                } else {
                    let alert = UIAlertController(title: "Accounts", message: "Your device has not WhatsApp installed.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    

    func shareOnGoogle(sender: UIButton)
    {
        let urlComponents = NSURLComponents()
        urlComponents.path = "https://plus.google.com/share"
        urlComponents.queryItems = [NSURLQueryItem(name: "url", value: "hello")]
        let url =  NSURL(string: "https://plus.google.com/share")
        
        
        if #available(iOS 9.0, *) {
            let controller: SFSafariViewController = SFSafariViewController(URL: url!)
            controller.delegate = self
            self.presentViewController(controller, animated: true, completion: { _ in })
        } else {
           UIApplication.sharedApplication().openURL(url!)
        }
        
        
    }
}



