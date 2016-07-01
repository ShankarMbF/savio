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
    
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var makeImpulseBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()
        var views: [String: AnyObject] = [:]
        
        label.text = "Current Value"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.Center
        self.contentView!.addSubview(label)
        views["label"] = label
        self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: [], metrics: nil, views: views))
        self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[label]", options: [], metrics: nil, views: views))
        
        //   var data: [CGFloat] = [50, 30, 50, 113, 317, 50, 24,]
        let data: [CGFloat] = [10,25,50,75,100]
        
        // simple line with custom x axis labels // hear need to pass json value
        let xLabels: [String] = ["1'st Month","2nd Month","3rd Month","4th Month","5th Month"]
//        let xLabels: [String] = ["1'st Month","2nd Month"]
        
        lineChart = LineChart()
        
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
        lineChart.y.labels.visible = false
        
//        for var i = 0; i < xLabels.count; i++ {
//            if i%2 == 0 {
//                lineChart.dots.color = UIColor.blackColor()
//            }
//            else{
//                lineChart.dots.color = UIColor.whiteColor()
//            }
//        }
//        lineChart.dots.color = UIColor.blackColor()
        
        lineChart.addLine(data)
        //  lineChart.addLine(data2)
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        self.contentView?.addSubview(lineChart)
//        scrHt.constant = lineChart.frame.size.height
//        self.view.addSubview(lineChart)
        views["chart"] = lineChart
        self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: [], metrics: nil, views: views))
        self.contentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[label]-[chart(==\((self.contentView?.frame.size.height)! - 50))]", options: [], metrics: nil, views: views))
        
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
        
        makeImpulseBtn!.layer.shadowColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).CGColor
        makeImpulseBtn!.layer.shadowOffset = CGSizeMake(0, 2)
        makeImpulseBtn!.layer.shadowOpacity = 1
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

}
