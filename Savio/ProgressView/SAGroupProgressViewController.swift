//
//  SAGroupProgressViewController.swift
//  Savio
//
//  Created by Maheshwari on 06/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAGroupProgressViewController: UIViewController {
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    @IBOutlet weak var horizontalScrollView: UIScrollView!
    @IBOutlet weak var spendButton: UIButton!
    
    @IBOutlet weak var planButton: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pagecontrol: UIPageControl!
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    var chartValues : Array<Dictionary<String,AnyObject>> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), forState: UIControlState.Normal)
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), forState: UIControlState.Normal)
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setUpView(){
        
        horizontalScrollView.contentSize = CGSizeMake(3 * UIScreen.mainScreen().bounds.size.width, 0)
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
        
        
        
        for var i=0; i<3; i++
        {
            let circularProgress = NSBundle.mainBundle().loadNibNamed("GroupCircularProgressView", owner: self, options: nil)[0] as! UIView
            circularProgress.frame = CGRectMake(CGFloat(i) * UIScreen.mainScreen().bounds.size.width,0,  horizontalScrollView.frame.size.width, horizontalScrollView.frame.size.height)
            
            
            let circularView = circularProgress.viewWithTag(1) as! KDCircularProgress
            circularView.startAngle = -90
            circularView.roundedCorners = true
            circularView.lerpColorMode = true
            
            circularView.angle = 90
            let labelOne = circularProgress.viewWithTag(4) as! UILabel
            
            let labelTwo = circularProgress.viewWithTag(5) as! UILabel
            
            let imgView = circularProgress.viewWithTag(3) as! UIImageView
            imgView.layer.borderColor = UIColor.blueColor().CGColor
            imgView.layer.borderWidth = 1
            imgView.layer.cornerRadius = imgView.frame.size.height / 2
            
            let chart = VBPieChart()
            let side =  circularProgress.frame.height + 10
            let xValue =  (UIScreen.mainScreen().bounds.width -  side)/2
            chart.frame = CGRectMake(xValue,-5, side, side)
            circularProgress.addSubview(chart)
            
            chart.enableStrokeColor = true;
            chart.holeRadiusPrecent = 0.75;
            
            chart.layer.shadowOffset = CGSizeMake(2, 2);
            chart.layer.shadowRadius = 3;
            chart.layer.shadowColor = UIColor.blackColor().CGColor;
            chart.layer.shadowOpacity = 0.7
            chart.startAngle = Float(M_PI+M_PI_2)
            self.chartValues = [
                ["name":"", "value": 20, "color":UIColor(red:237/255,green:182/255,blue:242/255,alpha:1)],
                ["name":"", "value": 20, "color":UIColor(red:181/255,green:235/255,blue:157/255,alpha:1)],
                ["name":"", "value": 20, "color":UIColor(red:247/255,green:184/255,blue:183/255,alpha:1)],
                ["name":"", "value": 20, "color":UIColor(red:118/255,green:229/255,blue:224/255,alpha:1)],
                ["name":"", "value": 20, "color":UIColor(red:238/255,green:234/255,blue:108/255,alpha:1)],
                ["name":"", "value": 20, "color":UIColor(red:170/255,green:234/255,blue:184/255,alpha:1)],
                ["name":"", "value": 20, "color":UIColor(red:193/255,green:198/255,blue:227/255,alpha:1)],
                ["name":"", "value": 20, "color":UIColor(red:246/255,green:197/255,blue:124/255,alpha:1)],
                ["name":"", "value": 100, "color":UIColor(red:234/255,green:235/255,blue:237/255,alpha:1)],
                
            ];
            
            chart.setChartValues(self.chartValues as [AnyObject], animation:true);
            
            if(i == 0)
            {
                labelOne.hidden = true
                labelTwo.hidden = true
                imgView.hidden = false
                circularView.hidden = true
                
            }
            else if(i == 1)
            {
                labelOne.hidden = false
                labelOne.text = "0.0%"
                labelTwo.hidden = false
                labelTwo.text = "£ 0.0 saved"
                imgView.hidden = true
                circularView.hidden = false
                chart.hidden = true
            }
            else
            {
                labelOne.hidden = false
                labelOne.text = "£ 0"
                labelTwo.hidden = false
                labelTwo.text = "0 days to go"
                imgView.hidden = true
                circularView.hidden = false
                chart.hidden = true
            }
            
            //Double((paidAmount * 360)/totalAmount)
            //            circularView.setColors(UIColor(red:237/255,green:182/255,blue:242/255,alpha:1),UIColor(red:181/255,green:235/255,blue:157/255,alpha:1),UIColor(red:247/255,green:184/255,blue:183/255,alpha:1),UIColor(red:118/255,green:229/255,blue:224/255,alpha:1),UIColor(red:238/255,green:234/255,blue:108/255,alpha:1),UIColor(red:170/255,green:234/255,blue:184/255,alpha:1),UIColor(red:193/255,green:198/255,blue:227/255,alpha:1),UIColor(red:246/255,green:197/255,blue:124/255,alpha:1))
            
            
           
           horizontalScrollView.addSubview(circularProgress)
            
        }
        
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NSNotificationCenter.defaultCenter().postNotificationName(kNotificationToggleMenuView, object: nil)
    }
    
    func heartBtnClicked(){
        
        if wishListArray.count>0{
            
            let objSAWishListViewController = SAWishListViewController()
            //objSAWishListViewController.wishListArray = wishListArray
            self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
        }
        else{
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    
    
    func statsButtonPressed(btn:UIButton)
    {
        let obj = SAStatViewController()
        self.navigationController?.pushViewController(obj, animated: false)
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
        
        // Set the new page index to the page control.
        pageControl!.currentPage = Int(currentPage)
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var newFrame = horizontalScrollView!.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl!.currentPage)
        horizontalScrollView!.scrollRectToVisible(newFrame, animated: true)
    }
    
    @IBAction func clickOnStatButton(sender:UIButton){
        let obj = SAStatViewController()
        self.navigationController?.pushViewController(obj, animated: false)
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
    
    
    
    
}
