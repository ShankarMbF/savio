//
//  SAStatViewController.swift
//  Savio
//
//  Created by Prashant on 27/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAStatViewController: UIViewController, LineChartDelegate {

    @IBOutlet weak var scrHt: NSLayoutConstraint!
    var lineChart: LineChart!
    var label = UILabel()
     var wishListArray : Array<Dictionary<String,AnyObject>> = []
    @IBOutlet weak var scrlView: UIScrollView?
    @IBOutlet weak var contentView: UIView?
    var itemTitle = ""
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var makeImpulseBtn: UIButton!
    @IBOutlet var scrollViewForGraph: UIScrollView!
    
    @IBOutlet var widthOfContentView: NSLayoutConstraint!
    @IBOutlet var graphSliderView: UISlider!
    
    @IBOutlet weak var sharingVw: UIView?

    
    var xLabels: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()
        
//        label.text = itemTitle
//        label.font = UIFont(name: "GothamRounded-Book", size: 16)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = NSTextAlignment.Center
//        self.contentView!.addSubview(label)
        lineChart = LineChart()
        
        let data: [CGFloat] = [10,25,30,45,55,                                                                                                                                                                                                                                                                                                                   10,25,30,45,55,10,25,30,45,55,65,75,86,98,100]
        
        // simple line with custom x axis labels // hear need to pass json value
        xLabels = ["1st Month","2nd Month","3rd Month","4th Month","5th Month","1st Month","2nd Month","3rd Month","4th Month","5th Month","6th Month","2nd Month","3rd Month","4th Month","5th Month","6th Month","7th Month","2nd Month","3rd Month","7th Month"]
        
        
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
        

    }
    
    // MARK: - Delegates and functions for  line chart
    func setValuesForSlider(min: CGFloat, max: CGFloat) {
        self.graphSliderView.maximumValue = Float(max)
        self.graphSliderView.minimumValue = Float(min)
        self.lineChart.drawScrollLineForPoint(min)
        self.graphSliderView.minimumTrackTintColor = UIColor.blackColor()
        self.graphSliderView.maximumTrackTintColor = UIColor.blackColor()
        self.graphSliderView.setThumbImage(UIImage(named: "slider-icon"), forState: UIControlState.Normal)
        self.scrollViewForGraph.contentOffset = CGPoint(x: Double(CGFloat(self.graphSliderView.minimumValue) / 2.0 ), y: 0  )
    }

    @IBAction func graphSliderValueChanged(sender: UISlider) {
        let widthScrollView : CGFloat = self.scrollViewForGraph.frame.size.width
        let widthOfContentView: CGFloat = self.widthOfContentView.constant
        if widthOfContentView > widthScrollView {
            let fraction: CGFloat = (widthOfContentView - widthScrollView) / CGFloat (self.graphSliderView.maximumValue)
            if sender.value <= 20.0 {
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
        obj.hideAddOfferButton = true
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func spendButtonPressed(sender: AnyObject) {
        
        let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
        self.navigationController?.pushViewController(objPlan, animated: false)
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
        view.addSubview(testView)
    }

}
