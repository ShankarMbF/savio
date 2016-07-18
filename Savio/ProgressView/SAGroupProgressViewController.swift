//
//  SAGroupProgressViewController.swift
//  Savio
//
//  Created by Maheshwari on 06/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SAGroupProgressViewController: UIViewController,PiechartDelegate,GetUsersPlanDelegate {
    
    @IBOutlet weak var groupMembersLabel: UILabel!
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    @IBOutlet weak var horizontalScrollView: UIScrollView!
    @IBOutlet weak var spendButton: UIButton!
    
    @IBOutlet weak var planButton: UIButton!
    
    @IBOutlet weak var savingPlanTitleLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pagecontrol: UIPageControl!
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    var participantsArr : Array<Dictionary<String,AnyObject>> = []
    var  pieChartSliceArray: Array<Piechart.Slice> = []
    @IBOutlet weak var contentVwHt: NSLayoutConstraint!
    @IBOutlet weak var tblHt: NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!
    var chartValues : Array<Dictionary<String,AnyObject>> = [];
     var savingPlanDetailsDict : Dictionary<String,AnyObject> =  [:]
    var piechart : Piechart?
    var planTitle = ""
    var totalAmount : Int = 0
    var paidAmount : Float = 0.0
    var ht:CGFloat = 0.0
  var objAnimView = ImageViewAnimation()
    let chartColors = [
    UIColor(red:237/255,green:182/255,blue:242/255,alpha:1),
    UIColor(red:181/255,green:235/255,blue:157/255,alpha:1),
    UIColor(red:247/255,green:184/255,blue:183/255,alpha:1),
    UIColor(red:118/255,green:229/255,blue:224/255,alpha:1),
    UIColor(red:238/255,green:234/255,blue:108/255,alpha:1),
    UIColor(red:170/255,green:234/255,blue:184/255,alpha:1),
    UIColor(red:193/255,green:198/255,blue:227/255,alpha:1),
    UIColor(red:246/255,green:197/255,blue:124/255,alpha:1),
    UIColor(red:234/255,green:235/255,blue:237/255,alpha:1)
    ];
    
     var  prevIndxArr: Array<Int> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), forState: UIControlState.Normal)
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), forState: UIControlState.Normal)
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), forState: UIControlState.Normal)
        self.setUPNavigation()
        
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        
        self.view.addSubview(objAnimView)
        let objAPI = API()
        objAPI.getSavingPlanDelegate = self
        objAPI.getUsersSavingPlan("g")

        
       
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setUPNavigation()
    {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
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
    
    
    func setUpView(){
        
        
        planTitle = String(format: "My %@ saving plan",savingPlanDetailsDict["title"] as! String)
        
        var attrText = NSMutableAttributedString(string: planTitle)
        
        attrText.addAttribute(NSFontAttributeName,
            value: UIFont(
                name: "GothamRounded-Medium",
                size: 16.0)!,
            range: NSRange(
                location: 3,
                length: (savingPlanDetailsDict["title"] as! String).characters.count))
        
        
        savingPlanTitleLabel.attributedText = attrText
        
        if let amount = savingPlanDetailsDict["amount"] as? NSNumber
        {
            totalAmount = amount.integerValue
        }
        
        if let totalPaidAmount = savingPlanDetailsDict["totalPaidAmount"] as? NSNumber
        {
            
            paidAmount = totalPaidAmount.floatValue
            
        }

        
        prevIndxArr.append(0)
        horizontalScrollView.contentSize = CGSizeMake(3 * UIScreen.mainScreen().bounds.size.width, 0)
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
     
//        tblHt.constant = (5 * 55) + 220
//        contentVwHt.constant = tblView.frame.origin.y + tblHt.constant
        
        groupMembersLabel.text = String(format:"Group members (%d)",participantsArr.count)
        
        for(var i=0; i<participantsArr.count; i++)
        {
            var error = Piechart.Slice()
            error.value = 0
            error.color = chartColors[i]
            error.text = "Success"
            
            pieChartSliceArray.append(error)

        }
        
        if(pieChartSliceArray.count < 8)
        {
            var error = Piechart.Slice()
            error.value = 4
            error.color = UIColor(red:234/255,green:235/255,blue:237/255,alpha:1)
            error.text = "Error"
            
            pieChartSliceArray.append(error)

        }
        
        
        for var i=0; i<3; i++
        {
            let circularProgress = NSBundle.mainBundle().loadNibNamed("GroupCircularProgressView", owner: self, options: nil)[0] as! UIView
            circularProgress.frame = CGRectMake(CGFloat(i) * UIScreen.mainScreen().bounds.size.width,0,  horizontalScrollView.frame.size.width, horizontalScrollView.frame.size.height)
            
            
            let side =  circularProgress.frame.height
            let xValue =  (UIScreen.mainScreen().bounds.width -  side)/2
            let circularView = circularProgress.viewWithTag(1) as! KDCircularProgress
            
            circularView.startAngle = -90
            circularView.roundedCorners = true
            circularView.lerpColorMode = true
            
            circularView.angle = 90
            let labelOne = circularProgress.viewWithTag(4) as! UILabel
            
            let labelTwo = circularProgress.viewWithTag(5) as! UILabel
            
            circularView.angle = Double((paidAmount * 360)/Float(totalAmount))
   
            
            if(i == 0)
            {
                labelOne.hidden = true
                labelTwo.hidden = true
   
                circularView.hidden = true
                
                piechart = Piechart()
                piechart!.frame = CGRectMake(xValue,0, side, side)
                piechart!.delegate = self
                piechart?.backgroundColor = UIColor.clearColor()
                piechart!.slices = pieChartSliceArray
                circularProgress.addSubview(piechart!)
                
                let imgView = UIImageView()
                //imgView.layer.borderWidth = 1
                imgView.frame = CGRectMake(40,40,side-80,side-80)
                imgView.layer.cornerRadius = imgView.frame.size.height / 2
               // imgView.image = UIImage(named: "cycle.png")
                if let url = NSURL(string:savingPlanDetailsDict["image"] as! String)
                {
   
                    let request: NSURLRequest = NSURLRequest(URL: url)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                        let image = UIImage(data: data!)
                        dispatch_async(dispatch_get_main_queue(), {
                            imgView.image = image
                        })
                    })
                    
                    
                }

                piechart!.addSubview(imgView)
                
                
                
            }
            else if(i == 1)
            {
                labelOne.hidden = false
                labelOne.text = String(format: "%0.2f%%",paidAmount)
                labelTwo.hidden = false
                labelTwo.text = String(format: "£ %0.2f saved",String(paidAmount))
                circularView.hidden = false
            }
            else
            {
                labelOne.hidden = false
                labelOne.text = String(format: "£ %0.2f",Float(totalAmount) - Float(paidAmount))
                labelTwo.hidden = false
                labelTwo.text = String(format: "%0.0f days to go",Float(totalAmount) - Float(paidAmount))
                circularView.hidden = false
            }
 
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

    //MARK: TableView Delegate and Datasource method
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return participantsArr.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellId = "CellId"
        var cell: GroupProgressTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId) as? GroupProgressTableViewCell
        
        if cell == nil {
            var nibs: Array! =  NSBundle.mainBundle().loadNibNamed("GroupProgressTableViewCell", owner: self, options: nil)
            cell = nibs[0] as? GroupProgressTableViewCell
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        cell?.saveProgress.progressColors = [chartColors[indexPath.row]]
        cell?.planView.backgroundColor = chartColors[indexPath.row]
        cell?.topVw.backgroundColor = chartColors[indexPath.row]
        cell?.makeImpulseSavingButton.addTarget(self, action: Selector("impulseSavingButtonPressed:"), forControlEvents: .TouchUpInside)
        
         let cellDict = participantsArr[indexPath.row] as! Dictionary<String,AnyObject>
        if prevIndxArr.count > 0 {
            for var i in 0 ..< prevIndxArr.count {
                
                if prevIndxArr[i] == indexPath.row {
                    cell?.topVwHt.constant = 22.0
                    cell?.topSpaceProfilePic.constant = 0
                    if indexPath.row == 0{
                        ht = 220.0
                    }else {
                        ht = 160.0
                    }
                    break
                }
                else{
                    cell?.topVwHt.constant = 50.0 //(cell?.userProfile.frame.size.height)! + 5.0
                    cell?.topSpaceProfilePic.constant = -3
                }
            }
        }
        else{
            ht = 55.0
            cell?.topVwHt.constant = 50.0
            cell?.topSpaceProfilePic.constant = -3
//            cell?.topVwHt.constant = 55.0 //(cell?.userProfile.frame.size.height)! + 5.0
        }
        tblHt.constant = CGFloat(participantsArr.count * 50) + ht
        cell?.nameLabel.text = cellDict["partyName"] as? String
        cell?.cellTotalAmountLabel.text = String(format: "£%d",totalAmount)
        cell?.savedAmountLabel.text = String(format: "£%d",paidAmount)
        cell?.saveProgress.angle = Double((paidAmount * 360)/Float(totalAmount))
        
        cell?.remainingAmountLabel.text = String(format: "£%d",totalAmount - Int(paidAmount))
        cell?.remainingProgress.angle = Double(((totalAmount - Int(paidAmount)) * 360)/Int(totalAmount))
        
        contentVwHt.constant = tblView.frame.origin.y + tblHt.constant

        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        ht = 0
        dispatch_async(dispatch_get_main_queue()){
            let selectedCell:GroupProgressTableViewCell? = tableView.cellForRowAtIndexPath(indexPath)as? GroupProgressTableViewCell
            selectedCell?.topVwHt.constant = 22.0
               selectedCell?.topSpaceProfilePic.constant = 0
            var isVisible = false
            if self.prevIndxArr.count > 0{
                for i in 0 ..< self.prevIndxArr.count {
                    let obj = self.prevIndxArr[i] as Int
                    if obj == indexPath.row {
                        isVisible = true
                        selectedCell?.topVwHt.constant = 50.0
                           selectedCell?.topSpaceProfilePic.constant = -3
                        self.prevIndxArr.removeAtIndex(i)
                       break
                    }
                }
                if(isVisible == false){
                    self.prevIndxArr.removeAll()
                    self.prevIndxArr.append(indexPath.row)
                }
            }
            else{
                 selectedCell?.topVwHt.constant = 50.0
                   selectedCell?.topSpaceProfilePic.constant = -3
                self.prevIndxArr.append(indexPath.row)
            }
//            self.tblView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
              self.piechart!.click(indexPath.row)
            self.tblView.reloadData()
        }
    }
    
    // Just set it back in deselect
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:GroupProgressTableViewCell? = tableView.cellForRowAtIndexPath(indexPath)as? GroupProgressTableViewCell
        selectedCell?.topVwHt.constant = 50.0
        selectedCell?.topSpaceProfilePic.constant = -3
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if prevIndxArr.count > 0 {
            for var i in 0 ..< prevIndxArr.count {
                if prevIndxArr[i] == indexPath.row {
                    if indexPath.row == 0 {
                        return 220
                    }
                    else {
                        return 160.0
                    }
                }
            }
        }
        return 50.0
    }
    
    func impulseSavingButtonPressed(sender:UIButton)
    {
        let objImpulseSave = SAImpulseSavingViewController()
        self.navigationController?.pushViewController(objImpulseSave, animated: true)

    }
    
    
    func setSubtitle(total: CGFloat, slice: Piechart.Slice) -> String {
        return "\(Int(slice.value / total * 100))% \(slice.text)"
    }
    
    func setInfo(total: CGFloat, slice: Piechart.Slice) -> String {
        return "\(Int(slice.value))/\(Int(total))"
    }
    
    
    func successResponseForGetUsersPlanAPI(objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if let message = objResponse["message"] as? String
        {
            if(message == "Success")
            {
                savingPlanDetailsDict = objResponse["partySavingPlan"] as! Dictionary<String,AnyObject>
                participantsArr = objResponse["partySavingPlanMembers"] as! Array<Dictionary<String,AnyObject>>
                
                var userDict : Dictionary<String,AnyObject> = [:]
                userDict["partyName"] = objResponse["partyName"]
                userDict["partyImageUrl"] = objResponse["partyImageUrl"]
                userDict["savingPlanTransactionList"] = objResponse["savingPlanTransactionList"]
                
                participantsArr.append(userDict)
                
               participantsArr = participantsArr.reverse()
                
                self.setUpView()
                
                self.tblView.reloadData()
            }
            else
            {
                pageControl.hidden = true
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else
        {
            pageControl.hidden = true
            let alert = UIAlertView(title: "Alert", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
        objAnimView.removeFromSuperview()
        
    }
    
    func errorResponseForGetUsersPlanAPI(error: String) {
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        objAnimView.removeFromSuperview()
    }

}
