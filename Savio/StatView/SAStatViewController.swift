//
//  SAStatViewController.swift
//  Savio
//
//  Created by Prashant on 27/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAStatViewController: UIViewController, LineChartDelegate {

    var lineChart: LineChart!
    var label = UILabel()
     var wishListArray : Array<Dictionary<String,AnyObject>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()
        var views: [String: AnyObject] = [:]
        
        label.text = "Current Value"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.Center
        self.view.addSubview(label)
        views["label"] = label
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-80-[label]", options: [], metrics: nil, views: views))
        
        //   var data: [CGFloat] = [50, 30, 50, 113, 317, 50, 24,]
        let data: [CGFloat] = [10, 30, 50, 113, 117]
        
        // simple line with custom x axis labels // hear need to pass json value
        let xLabels: [String] = ["1'st Month","2nd Month", "3rd Month", "4th Month", "5th Month"]
        
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
        lineChart.x.grid.color = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        lineChart.y.grid.count = CGFloat(xLabels.count)
        lineChart.y.grid.color = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        
        lineChart.x.labels.values = xLabels
        lineChart.y.labels.visible = true
        
        lineChart.dots.color = UIColor.blackColor()
        
        lineChart.addLine(data)
        //  lineChart.addLine(data2)
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        self.view.addSubview(lineChart)
        views["chart"] = lineChart
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[label]-[chart(==200)]", options: [], metrics: nil, views: views))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView(){
        
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: #selector(SASavingSummaryViewController.menuButtonClicked), forControlEvents: .TouchUpInside)
        
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
        btnName.addTarget(self, action: #selector(SASavingSummaryViewController.heartBtnClicked), forControlEvents: .TouchUpInside)
        
         if let str = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? NSData
        {
            let dataSave = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as! NSData
            wishListArray = (NSKeyedUnarchiver.unarchiveObjectWithData(dataSave) as? Array<Dictionary<String,AnyObject>>)!
            
            NSUserDefaults.standardUserDefaults().setObject(wishListArray, forKey: "wishlistArray")
            NSUserDefaults.standardUserDefaults().synchronize()
            
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func didSelectDataPoint(x: CGFloat, yValues: Array<CGFloat>) {
        label.text = "Value : \(yValues)"
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
//        if let chart = lineChart {
//            chart.setNeedsDisplay()
//        }
    }

}
