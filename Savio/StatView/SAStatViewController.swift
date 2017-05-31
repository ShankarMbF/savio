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
    
    @IBOutlet weak var GraphContentView: UIView! //IBOutlet for Graph container
    @IBOutlet weak var scrHt: NSLayoutConstraint! //IBOutlet to set scrollview height
    @IBOutlet weak var scrlView: UIScrollView?   //IBOutlet for scrollview
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var offersButton: UIButton!   //IBoutlet for offer tab button
    @IBOutlet weak var planButton: UIButton!     //IBOutlet for plan tab button
    @IBOutlet weak var spendButton: UIButton!    //IBOutlet for spend tab button
    @IBOutlet weak var makeImpulseBtn: UIButton!  //IBOutlet for make impules button
    @IBOutlet var scrollViewForGraph: UIScrollView!   //IBOutlet for scrollview to scroll graph hotizantal
    @IBOutlet var widthOfContentView: NSLayoutConstraint!  //IBoutlet to set width of contentview
    @IBOutlet var graphSliderView: UISlider!               //IBOutlet for slider view
    @IBOutlet weak var sharingVw: UIView?                  //IBOutlet for social sharing popup.
    @IBOutlet weak var lbl: UILabel?
    
    var planType = ""   //Variable for identifying plan type
    var lineChart: LineChart! //Object of LineChart class to draw Line chart
    var label = UILabel()
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var itemTitle = ""
    var endDate = ""
    var cost = ""
    var documentInteractionController = UIDocumentInteractionController()  // UIDocumentInteractionController object for sharing data to whatsapp friends
    var shareImg: UIImage?
    var xLabels: Array<String> = [] //Array for holding x-axis lable
    var savingPlanDict: Dictionary<String,AnyObject>?
    
    // MARK: - View life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let savingsPlan = savingPlanDict!["partySavingPlan"]
        guard (savingPlanDict!["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>) != nil else {
            print(" There is no value ")
            self.lineChartFunct([],planType: "")
            return
        }
        
        let savingsPlanType = savingsPlan!["partySavingPlanType"] as! String
        guard savingsPlanType == "Individual" else {
            //            if (savingPlanDict!["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>) != nil
            //            {
            //                print(" There is no value ")
            //                self.lineChartFunct([],planType: "")
            //            }
            print("______________  guard Group Condition  ______________")
            let transactionArr = savingPlanDict!["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
            
            guard savingPlanDict!["partySavingPlanMembers"] == nil else {
                
                let SavingPlanMembers = savingPlanDict!["partySavingPlanMembers"] as? Array<Dictionary<String,AnyObject>>
                let Transactions = SavingPlanMembers![0]["savingPlanTransactionList"]!
                let finalAddValue = self.calcTotalAmount(Transactions as? Array<Dictionary<String, AnyObject>>)
                
                guard savingsPlan!["payType"] as! String == "Week" else {
                    self.grouplineChartFunct(transactionArr!, planType: "Month", inviteAmount: finalAddValue)
                    print("guard for month")
                    return
                }
                self.grouplineChartFunct(transactionArr!, planType: "Week", inviteAmount: finalAddValue)
                print("Function For week")
                return
            }
            self.lineChartFunct([],planType: "")
            return
        }
        
        print("Function For Individual")
        
        let transactionArr = savingPlanDict!["savingPlanTransactionList"] as? Array<Dictionary<String,AnyObject>>
        print(transactionArr!)
        
        guard savingsPlan!["payType"] as! String == "Week" else {
            print("guard for month")
            self.lineChartFunct(transactionArr ?? Array<Dictionary<String,AnyObject>>(), planType: "Month")
            return
        }
        print("Function For week")
        self.lineChartFunct(transactionArr ?? Array<Dictionary<String,AnyObject>>(),planType: "Week")
        
        return
        /*     xLabels.append("newdate")       */
    }
    
    func calcTotalAmount(_ TotalArr: Array<Dictionary<String,AnyObject>>?) -> CGFloat {
        if TotalArr == nil{
            return 0.0
        }
        var AddedValue : Array<CGFloat> = [0]
        var sum : CGFloat = 0.0
        for i in 0 ..< TotalArr!.count
        {
            AddedValue.append(TotalArr![i]["amount"] as! CGFloat)
            sum = AddedValue.reduce(0,+)
            print(sum)
        }
        return sum
    }
    
    
    func lineChartFunct(_ transactionArr: Array<Dictionary<String,AnyObject>> , planType : String) {
        // y axis caluculation
        let maxValue:CGFloat = self.calculateMaxPriceForYAxix(NSInteger(cost)!)
        // new Array for Individual Graph chart
        var MonthLabel: Array<String> = []
        var xAxisLabels: Array<CGFloat> = []
        var dataArr: Array<CGFloat> = [0]
        
        //Setting up Stat view UI
        self.setUpView()
        //--------------Draw Line chart on graph contentview----------------------------
        lineChart = LineChart()
        lineChart.clipsToBounds  = false
        lineChart.planTitle = self.planType
        lineChart.maximumValue = maxValue
        lineChart.minimumValue = 0
        let data: [CGFloat] = [0,100,200-1,350,400,550,600,700]
        var imp: [String] = ["sub"]
        xLabels.append("")
        
        for i in 0 ..< transactionArr.count {
            let dict = transactionArr[i] as Dictionary<String,AnyObject>
            imp.append(dict["paymentMode"] as! String)
            dataArr.append(dict["amount"] as! CGFloat)
            xLabels.append(dict["paymentMode"] as! String)
            if i % 2 == 0 {
                imp.append("Subscription")
            }
            else{
                imp.append("IMPULSE")
            }
        }
        
        //   Amount Calculations
        var tempAddValue : CGFloat = 0
        for i in 0 ..< dataArr.count{
            if xLabels[i] == "IMPULSE"{
                tempAddValue = tempAddValue + dataArr[i]
                print(tempAddValue)
                let counnt = dataArr.count - 1
                if i == counnt {
                    xAxisLabels.append(tempAddValue)
                    break
                }
            }else{
                tempAddValue = tempAddValue + dataArr[i]
                xAxisLabels.append(tempAddValue)
                print(xAxisLabels)
            }
        }
        
        MonthLabel.append("")
        // label Process
        for i in 1 ..< xAxisLabels.count {
            let month = "\(planType) \(i)"
            MonthLabel.append(month)
        }
        
        print(xLabels)
        lineChart.impulseStore = imp
        // simple line with custom x axis labels // hear need to pass json value
        //        xLabels = ["1","2","3","4","5","6","7","8"]
        //        xLabels = ["0","1","2"]
        lineChart.animation.enabled = true
        lineChart.area = true
        // hide grid line Visiblity
        lineChart.x.grid.visible = true
        lineChart.y.grid.visible = true
        print(dataArr)
        
        // hide dots visiblety in line chart
        lineChart.x.labels.visible = true
        lineChart.x.grid.count = CGFloat(data.count)    //dont change this
        lineChart.x.grid.color = UIColor.gray
        lineChart.y.grid.count = CGFloat(8)
        lineChart.y.grid.color = UIColor.gray
        lineChart.scrollViewReference = self.scrollViewForGraph
        
        lineChart.x.labels.values = MonthLabel
        lineChart.y.labels.visible = true
        lineChart.addLine(xAxisLabels)
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        
        self.contentView?.addSubview(lineChart)
        
    }
    
    func grouplineChartFunct(_ transactionArr: Array<Dictionary<String,AnyObject>> , planType : String , inviteAmount : CGFloat) {
        // y axis caluculation
        let maxValue:CGFloat = self.calculateMaxPriceForYAxix(NSInteger(cost)!)
        // new Array for Individual Graph chart
        var MonthLabel: Array<String> = []
        var xAxisLabels: Array<CGFloat> = []
        var dataArr: Array<CGFloat> = [0]
        
        //Setting up Stat view UI
        self.setUpView()
        //--------------Draw Line chart on graph contentview----------------------------
        lineChart = LineChart()
        lineChart.clipsToBounds  = false
        lineChart.planTitle = self.planType
        lineChart.maximumValue = maxValue
        lineChart.minimumValue = 0
        let data: [CGFloat] = [0,100,200-1,350,400,550,600,700]
        var imp: [String] = ["sub"]
        xLabels.append("")
        
        for i in 0 ..< transactionArr.count {
            let dict = transactionArr[i] as Dictionary<String,AnyObject>
            imp.append(dict["paymentMode"] as! String)
            dataArr.append(dict["amount"] as! CGFloat)
            xLabels.append(dict["paymentMode"] as! String)
            if i % 2 == 0 {
                imp.append("Subscription")
            }
            else{
                imp.append("IMPULSE")
            }
        }
        
        //   Amount Calculations
        var tempAddValue : CGFloat = 0
        for i in 0 ..< dataArr.count{
            if xLabels[i] == "IMPULSE"{
                tempAddValue = tempAddValue + dataArr[i]
                print(tempAddValue)
                let counnt = dataArr.count - 1
                if i == counnt {
                    xAxisLabels.append(tempAddValue)
                    break
                }
            }else{
                tempAddValue = tempAddValue + dataArr[i]
                xAxisLabels.append(tempAddValue)
                print(xAxisLabels)
            }
        }
        
        MonthLabel.append("")
        // label Process
        for i in 1 ..< xAxisLabels.count {
            let month = "\(planType) \(i)"
            MonthLabel.append(month)
        }
        
        // Add inviteAmount at Last
        print(inviteAmount)
        if inviteAmount != 0{
            var finalarray = [CGFloat]()
            finalarray.append(0.0)
            
            if xAxisLabels.count == 0 {
                finalarray.append(inviteAmount)
            }else{
                var value = xAxisLabels.dropFirst(xAxisLabels.count - 1)
                let value1 = CGFloat(value[xAxisLabels.count - 1]) + inviteAmount
                
                xAxisLabels.removeLast()
                xAxisLabels.append(value1)
                
            }
        }
        //        for i in 0 ..< xAxisLabels.count {
        //            if i == xAxisLabels.count - 1 {
        ////                let lastArrObj = lastobj + inviteAmount
        ////                print(lastArrObj)
        ////                finalarray.append(lastArrObj)
        //            }else{
        //                finalarray.append(xAxisLabels[i])
        //            }
        //        }
        
        
        
        print(xLabels)
        lineChart.impulseStore = imp
        // simple line with custom x axis labels // hear need to pass json value
        //        xLabels = ["1","2","3","4","5","6","7","8"]
        //        xLabels = ["0","1","2"]
        lineChart.animation.enabled = true
        lineChart.area = true
        // hide grid line Visiblity
        lineChart.x.grid.visible = true
        lineChart.y.grid.visible = true
        print(dataArr)
        
        // hide dots visiblety in line chart
        lineChart.x.labels.visible = true
        lineChart.x.grid.count = CGFloat(data.count)    //dont change this
        lineChart.x.grid.color = UIColor.gray
        lineChart.y.grid.count = CGFloat(8)
        lineChart.y.grid.color = UIColor.gray
        lineChart.scrollViewReference = self.scrollViewForGraph
        
        lineChart.x.labels.values = MonthLabel
        lineChart.y.labels.visible = true
        lineChart.addLine(xAxisLabels)
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        
        self.contentView?.addSubview(lineChart)
        
    }
    
    
    func createPlanDate(_ PayDate : String, planType : String, userDefault : String) -> Date {
        let grpCurrentdate = userDefaults.object(forKey: userDefault) as? String
        let Date = "\(PayDate)-\(String(describing: grpCurrentdate))"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-mm-yyyy"
        let Idate = dateFormatter.date(from: Date)
        return Idate!
    }
    
    
    //IndCurrentDateForPlan
    //GrpCurrentDateForPlan
    
    func calculateMaxPriceForYAxix(_ maxPrice:NSInteger) -> CGFloat {
        var outputNum:CGFloat = 0.0
        if(maxPrice < 1000){
            outputNum = (CGFloat)(ceil(Double( maxPrice)/100) * 100);
        }else{
            outputNum = (CGFloat)(ceil(Double( maxPrice)/1000) * 1000);
        }
        print(outputNum)
        return outputNum
    }
    
    //Function invoke for formatting graph as per plan type.
    func chartVerticalLineDrawingCompleted() {
        if planType == "Individual" {
            GraphContentView.backgroundColor = UIColor(red: 252/255,green:246/255,blue:236/255,alpha:1)
            lineChart.thumbImgView.image = UIImage(named: "generic-stats-slider-tab")
            lineChart.graphMovingVerticalLine.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
        }
        else {
            GraphContentView.backgroundColor = UIColor(red: 239/255,green:247/255,blue:253/255,alpha:1)
            lineChart.thumbImgView.image = UIImage(named: "group-save-stats-slider-tab")
            lineChart.graphMovingVerticalLine.backgroundColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1)
        }
    }
    
    //MARK:- Delegate slider
    
    func scrollLineDragged(_ xValue: CGFloat, widhtContent: CGFloat) {
        let widthScrollView : CGFloat = self.scrollViewForGraph.frame.size.width
        let widthOfContentView: CGFloat = self.widthOfContentView.constant
        if widthOfContentView > widthScrollView {
            let fraction: CGFloat = (widthOfContentView - widthScrollView) / widhtContent
            if xValue <= CGFloat(30) {
                self.scrollViewForGraph.contentOffset = CGPoint(x: 5, y: 0  )
            } else {
                self.scrollViewForGraph.contentOffset = CGPoint(x: Double(CGFloat(xValue) * fraction ), y: 0  )
            }
        }
    }
    
    //MARK: -
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var views: [String: AnyObject] = [:]
        views["chart"] = lineChart
        if xLabels.count > 5 {
            self.contentView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[chart]-|", options: [], metrics: nil, views: views))
            let offsetSpace = 70
            let constant = String.init(format: "H:|-[chart(%d)]-|", xLabels.count * offsetSpace)
            self.contentView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: constant, options: [], metrics: nil, views: views))
            self.widthOfContentView.constant = CGFloat( xLabels.count * offsetSpace)
            self.scrollViewForGraph.contentSize = CGSize(width: CGFloat( xLabels.count * offsetSpace), height: self.scrollViewForGraph.frame.height)
        }
        else  {
            self.contentView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chart]-|", options: [], metrics: nil, views: views))
            self.contentView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[chart]-|", options: [], metrics: nil, views: views))
            self.widthOfContentView.constant = self.scrollViewForGraph.frame.width
            self.scrollViewForGraph.contentSize = CGSize(width: self.scrollViewForGraph.frame.width, height: self.scrollViewForGraph.frame.height)
        }
        //add rounded corners plan button
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.planButton!.bounds, byRoundingCorners: ([.topRight, .topLeft]), cornerRadii: CGSize(width: 3.0, height: 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.planButton!.bounds
        maskLayer.path = maskPath.cgPath
        self.planButton?.layer.mask = maskLayer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function invoke for set up the UI of stat view
    func setUpView(){
        //-------------------Set up navigation bar--------------------------------
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        //-------------------------------------------------------------------------
        
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        makeImpulseBtn!.layer.cornerRadius = 5
        //-----------------------------Set up tab buttons--------------------------------------------
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), for: UIControlState())
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), for: UIControlState())
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), for: UIControlState())
        //-------------------------------------------------------------------------------------------
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SAStatViewController.menuButtonClicked), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "My Plan"
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.addTarget(self, action: #selector(SAStatViewController.heartBtnClicked), for: .touchUpInside)
        
        //Showing wishlist count
        if let str = userDefaults.object(forKey: "wishlistArray") as? Data
        {
            let dataSave = str
            wishListArray = (NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>)!
            if(wishListArray.count > 0)
            {
                btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), for: UIControlState())
                btnName.setTitleColor(UIColor.black, for: UIControlState())
            }
            else {
                btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
                btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
            }
            
            btnName.setTitle(String(format:"%d",wishListArray.count), for: UIControlState())
        }
        
        //Setting right button of navigation bar
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        if(planType == "Individual") {
            let attrText = NSMutableAttributedString(string: String(format: "My %@ plan target is £%@",itemTitle,cost))
            attrText.addAttribute(NSFontAttributeName,
                                  value: UIFont(
                                    name: kMediumFont,
                                    size: 15.0)!,
                                  range: NSRange(
                                    location: 3,
                                    length: itemTitle.characters.count))
            lbl!.attributedText = attrText
        }
        else{
            lbl!.text = String(format: "Our target is £%@",cost)
            lbl?.textColor = UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1)
            self.view.bringSubview(toFront: lbl!)
        }
    }
    
    //Function invoke when user tapping on menu button from navigation bar.
    func menuButtonClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    
    //Function invoke when user tapping on heart button from navigation bar.
    func heartBtnClicked(){
        if wishListArray.count>0{
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: kWishlistempty, message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //Function invoke when progress button clicked
    @IBAction func clickOnProgressBtn(_ sender:UIButton){
        self.navigationController?.popViewController(animated: false)
    }
    
    //Function invoke when offer tab button clicked
    @IBAction func offersButtonPressed(_ sender: AnyObject) {
        let obj = SAOfferListViewController()
        obj.savID = 63
        let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92] as [String : Any]
        userDefaults.set(dict, forKey:"colorDataDict")
        userDefaults.synchronize()
        //Hide add offer button from offer list
        obj.hideAddOfferButton = true
        obj.isComingProgress = true
        
        //navigate to offer list
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    //Function invoke when offer tab button clicked
    @IBAction func spendButtonPressed(_ sender: AnyObject) {
        let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
        self.navigationController?.pushViewController(objPlan, animated: false)
    }
    
    //Function invoke when make impulse button clicked for make extra payment
    @IBAction func makeImpulseSavingPressed(_ sender: AnyObject) {
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
    
    //function invoke when user select point from line chart
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>) {
        label.text = "\(yValues[0])"
    }
    
    
    //Mark: - Social Sharing
    //function invoke on tapping any achivement button for showing social media sharing option
    @IBAction func clickedOnAchivements(_ sender: UIButton){
        //load SocialSharingView.xib for showing pop up
        let testView = Bundle.main.loadNibNamed("SocialSharingView", owner: self, options: nil)![0] as! UIView
        testView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        let vw = testView.viewWithTag(7)! as UIView
        vw.layer.borderWidth = 2.0
        
        //------------------------------Formatting popUp-----------------------------------------
        switch sender.tag {
        case 0:
            if(planType == "Individual") {
                vw.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
                shareImg = UIImage(named: "generic-streak-popup.png")
            }
            else {
                vw.layer.borderColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1).cgColor
                shareImg = UIImage(named: "group-save-streak-popup.png")
            }
        case 1:
            if(planType == "Individual"){
                vw.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
                shareImg = UIImage(named: "stats-achievement-smiley-popup.png")
            }
            else {
                vw.layer.borderColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1).cgColor
                shareImg = UIImage(named: "group-stats-achievement-smiley-popup.png")
            }
            
        case 2:
            if(planType == "Individual") {
                vw.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
                shareImg = UIImage(named: "stats-achievement-popup.png")
            }
            else {
                vw.layer.borderColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1).cgColor
                shareImg = UIImage(named: "group-stats-achievement-badge-popup.png")
            }
            
        case 3:
            if(planType == "Individual") {
                vw.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
                shareImg = UIImage(named: "stats-achievement-money-popup.png")
            }
            else {
                vw.layer.borderColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1).cgColor
                shareImg = UIImage(named: "group-stats-achievement-money-popup.png")
            }
            
        default:
            if(planType == "Individual"){
                vw.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
                shareImg = UIImage(named: "generic-streak-popup.png")
            }
            else {
                vw.layer.borderColor =  UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1).cgColor
                shareImg = UIImage(named: "group-save-streak-popup.png")
            }
        }
        //----------------------------------------------------------------------------------------------------------------
        //Showing image to be sharing
        let imgVw = testView.viewWithTag(10) as! UIImageView
        imgVw.image = shareImg
        
        //Set up for close button
        let btnClose = testView.viewWithTag(6)! as! UIButton
        if(planType == "Individual")
        {
            btnClose.setImage(UIImage(named:"social-pop-up-close.png"), for: UIControlState())
        }
        else {
            btnClose.setImage(UIImage(named:"Group-social-pop-up-close.png"), for: UIControlState())
        }
        
        btnClose.addTarget(self, action: #selector(SAStatViewController.closeSharePopup(_:)), for: UIControlEvents.touchUpInside)
        
        //setup for facebook sharing button
        let fbBtn = testView.viewWithTag(2) as! UIButton
        fbBtn.addTarget(self, action: #selector(SAStatViewController.clickedOnSocialMediaButton(_:)), for: UIControlEvents.touchUpInside)
        
        //setup for twitter sharing button
        let twBtn = testView.viewWithTag(3) as! UIButton
        twBtn.addTarget(self, action: #selector(SAStatViewController.clickedOnSocialMediaButton(_:)), for: UIControlEvents.touchUpInside)
        
        //setup for google sharing button
        let glBtn = testView.viewWithTag(4) as! UIButton
        glBtn.addTarget(self, action: #selector(SAStatViewController.clickedOnSocialMediaButton(_:)), for: UIControlEvents.touchUpInside)
        
        //setup for whatsapp sharing button
        let waBtn = testView.viewWithTag(5) as! UIButton
        waBtn.addTarget(self, action: #selector(SAStatViewController.clickedOnSocialMediaButton(_:)), for: UIControlEvents.touchUpInside)
        
        self.navigationController?.view.addSubview(testView)
    }
    
    //Close the share popup
    func closeSharePopup(_ sender: UIButton) {
        sender.superview?.superview!.removeFromSuperview()
    }
    
    //function identifying social media for sharing
    func clickedOnSocialMediaButton(_ sender: UIButton){
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
        //        self.shareOnFacebook(sender)
    }
    
    //Function invoke to open compose view for share content on facebook
    func shareOnFacebook(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Share on Facebook")
            self.present(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "You’re not logged into Facebook", message: "You need to login to Facebook to be able share this.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Function invoke to open compose view for share content on twitter
    func shareOnTwitter(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Share on Twitter")
            self.present(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Twitter isn’t set up", message: "You can add your twitter account in the iOS Settings screens", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Function invoke for open whatsapp with content
    func shareOnWhatsApp(_ sender: UIButton) {
        let urlWhats = "whatsapp://app"
        //Make URl for open whatsapp
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                //Open application if whatsapp is installed
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    //Attached image to whatsapp dialog
                    if let image = shareImg {
                        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                            let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                            do {
                                try imageData.write(to: tempFile, options: .atomic)
                                documentInteractionController = UIDocumentInteractionController(url: tempFile)
                                documentInteractionController.uti = "net.whatsapp.image"
                                documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                            } catch {
                                print(error)
                            }
                        }
                    }
                } else {
                    //Whatsapp not install in device
                    let alert = UIAlertController(title: "No Whatsapp account set up", message: "Your What’s app account isn’t connected to iOS.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //Function invoke for share content on twitter
    func shareOnGoogle(_ sender: UIButton)
    {
        var urlComponents = URLComponents()
        urlComponents.path = "https://plus.google.com/share"
        urlComponents.queryItems = [URLQueryItem(name: "url", value: "hello")]
        let url =  URL(string: "https://plus.google.com/share")
        if #available(iOS 9.0, *) {
            let controller: SFSafariViewController = SFSafariViewController(url: url!)
            controller.delegate = self
            self.present(controller, animated: true, completion: { _ in })
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
}


/*
 *  Note:
 *  let Startdate = self.createPlanDate( savingsPlan!["payDate"], planType: savingsPlanType, userDefault: "IndCurrentDateForPlan")   //  "GrpCurrentDateForPlan"
 *
 *
 *
 *
 *
 *
 */
