//
//  SAOfferListViewController.swift
//  Savio
//
//  Created by Prashant on 06/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


//----------Custom protocol for add or skip offerlist-----------------------
protocol SAOfferListViewDelegate {
    func addedOffers(_ offerForSaveDict:Dictionary<String,AnyObject>)
    func skipOffers()
}
//--------------------------------------------------------------------------
class SAOfferListViewController: UIViewController,GetOfferlistDelegate{
    
    @IBOutlet weak var tblViewBottomSpace: NSLayoutConstraint! //IBOutlet for setting bottom space of baleview
    @IBOutlet weak var bottomview: UIView!                     //IBOutlet of UIView
    @IBOutlet weak var tblView : UITableView?                  //IBOutlet for tableview
    @IBOutlet weak var closeLbl : UILabel?                     //IBOutlet for UILable
     @IBOutlet weak var tabVw : UIView?
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var offersButton: UIButton!
//    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    
    var indx : Int = 0
    var  prevIndxArr: Array<Int> = []                          //Array for hold previous selected index
    var rowHT : CGFloat = 310.0                                //set row height as per expand and collaps
    var savID : NSNumber = 0
    var hideAddOfferButton : Bool = false
    var  offerArr: Array<Dictionary<String,AnyObject>> = []   //Array for holding offer list
    var delegate : SAOfferListViewDelegate?
    var objAnimView = ImageViewAnimation()
    var isComingProgress: Bool?
    var addedOfferArr: Array<Dictionary<String,AnyObject>> = []   //Array for holding offer list



    // MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
         offersButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), for: UIControlState())
        progressButton.setImage(UIImage(named: "stats-plan-tab.png"), for: UIControlState())
        offersButton.setImage(UIImage(named: "stats-offers-tab-active.png"), for: UIControlState())

        if isComingProgress! {
            tabVw?.isHidden = false
        }
        else{
            tabVw?.isHidden = true
        }
        self.setUpView()  
        
         self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //customization of spend button
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.spendButton!.bounds, byRoundingCorners: ([.topRight, .topLeft]), cornerRadii: CGSize(width: 3.0, height: 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.spendButton!.bounds
        maskLayer.path = maskPath.cgPath
        self.offersButton?.layer.mask = maskLayer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function invoke for set up UI
    func setUpView(){
        //--------------Setting navigation bar-------------------------------
        self.title = "Partner offers"
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        //--------------------------------------------------------------------
        
        //set Navigation left button as per hideAddOfferButton flag
        if(hideAddOfferButton)
        {
            let leftBtnName = UIButton()
            leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
            leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            leftBtnName.addTarget(self, action: #selector(SAOfferListViewController.menuButtonClicked), for: .touchUpInside)
            
            let leftBarButton = UIBarButtonItem()
            leftBarButton.customView = leftBtnName
            self.navigationItem.leftBarButtonItem = leftBarButton
            bottomview.isHidden = true
            tblViewBottomSpace.constant = 0
            if isComingProgress! {
                tblViewBottomSpace.constant = 40
            }
            
        }
        else {
            let leftBtnName = UIButton()
            leftBtnName.setImage(UIImage(named: "nav-back.png"), for: UIControlState())
            leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            leftBtnName.addTarget(self, action: #selector(SAOfferListViewController.backButtonPress), for: .touchUpInside)
            let leftBarButton = UIBarButtonItem()
            leftBarButton.customView = leftBtnName
            self.navigationItem.leftBarButtonItem = leftBarButton
            bottomview.isHidden = false
            tblViewBottomSpace.constant = 40
        }
     
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.addTarget(self, action: #selector(SAOfferListViewController.heartBtnClicked), for: .touchUpInside)
        
        if let str = userDefaults.object(forKey: "wishlistArray") as? Data        {
            let dataSave = str
            let wishListArray = NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>
            btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), for: UIControlState())
            btnName.setTitle(String(format:"%d",wishListArray!.count), for: UIControlState())
           btnName.setTitleColor(UIColor.black, for: UIControlState())
        }
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        closeLbl?.layer.cornerRadius = (closeLbl?.frame.size.width)!/2
        closeLbl?.layer.masksToBounds = false
        closeLbl?.layer.borderWidth = 2.0
        closeLbl?.layer.borderColor = UIColor.white.cgColor
        
        //filter the offerlist as per saving plan type
        if let arr: Array<Dictionary<String,AnyObject>> = userDefaults.value(forKey: "offerList") as? Array {
            for var dict:Dictionary<String,AnyObject> in arr {
                let savingArr: Array<Dictionary<String,AnyObject>> = dict["savingPlanList"] as! Array
                if savingArr.count > 0 {
                    for var saveDict in savingArr {
                        if saveDict["savingID"] as! NSNumber == savID {
                            offerArr.append(dict)
                        }
                    }
                }
            }
            print(offerArr)
            tblView?.reloadData()
        }
        else {
            //Get fresh offerlist from API
            let objAPI = API()
            //Check Network rechability
            if objAPI.isConnectedToNetwork() {
            objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
            objAnimView.frame = self.view.frame
            objAnimView.animate()
            self.view.addSubview(objAnimView)
                objAPI.getofferlistDelegate = self
                objAPI.getOfferListForSavingId()
            }
            else {
                //If network not found
                let alert = UIAlertView(title: "Warning", message: "Network not available on your device.", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        //customization of plan button as per the psd
//        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.progressButton!.bounds, byRoundingCorners: ([.TopRight, .TopLeft]), cornerRadii: CGSizeMake(3.0, 3.0))
//        let maskLayer: CAShapeLayer = CAShapeLayer()
//        maskLayer.frame = self.progressButton!.bounds
//        maskLayer.path = maskPath.CGPath
//        self.progressButton?.layer.mask = maskLayer
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - Navigation Bar Button Action
    
    func menuButtonClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    //function invoke when user tapping on back button
    func backButtonPress()  {
        self.navigationController?.popViewController(animated: true)
    }
    //function invoke when user tapping on heart button from navigation bar
    func heartBtnClicked(){
        
        let str = userDefaults.object(forKey: "wishlistArray") as? Data
        if  str != nil {
            
            let dataSave = userDefaults.object(forKey: "wishlistArray") as! Data
            let wishListArray = NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>
            if wishListArray!.count>0{
                NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")            }
            else {
               let alert = UIAlertView(title: "Wish list empty", message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else {
            let alert = UIAlertView(title: "Wish list empty", message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    // MARK: - Button Action
    @IBAction func spendButtonPressed(_ sender: AnyObject) {
        var isAvailble: Bool = false
        var vw = UIViewController()
        
        for var obj in (self.navigationController?.viewControllers)!{
            if obj.isKind(of: SASpendViewController.self) {
                isAvailble = true
                vw = obj as! SASpendViewController
                break
            }
        }
        
        if isAvailble {
            self.navigationController?.popToViewController(vw, animated: false)
        }
        else{
        
        let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
        self.navigationController?.pushViewController(objPlan, animated: false)
        }
    }
    
    @IBAction func progressButtonPressed(_ sender: AnyObject) {
        var vw = UIViewController()
        let individualFlag = userDefaults.value(forKey: kIndividualPlan) as! NSNumber
        var isAvailble: Bool = false
        var usersPlanFlag = ""
        if let usersPlan = userDefaults.value(forKey: kUsersPlan) as? String
        {
            usersPlanFlag = usersPlan
            //As per flag show the progress view of plan
             vw = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
            if individualFlag == 1 && usersPlanFlag == "I"{
                for var obj in (self.navigationController?.viewControllers)!{
                    if obj.isKind(of: SAProgressViewController.self) {
                        isAvailble = true
                        vw = obj as! SAProgressViewController
                        break
                    }
                }
            }
            else
            {
                vw = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
                for var obj in (self.navigationController?.viewControllers)!{
                    if obj.isKind(of: SAGroupProgressViewController.self) {
                        isAvailble = true
                        vw = obj as! SAGroupProgressViewController
                        break
                    }
                }
            }
            
        } else {
            usersPlanFlag = ""
            //As per flag show the progress view of plan
            
            if individualFlag == 1{
                 vw = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
                for var obj in (self.navigationController?.viewControllers)!{
                    if obj.isKind(of: SAProgressViewController.self) {
                        isAvailble = true
                        vw = obj as! SAProgressViewController
                        break
                    }
                }
            }
            else
            {
                 vw = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
                for var obj in (self.navigationController?.viewControllers)!{
                    if obj.isKind(of: SAGroupProgressViewController.self) {
                        isAvailble = true
                        vw = obj as! SAGroupProgressViewController
                        break
                    }
                }
            }
        }
       
        if isAvailble {
            self.navigationController?.popToViewController(vw, animated: false)
        }
        else{
            
            self.navigationController?.pushViewController(vw, animated: false)
        }
    }
    
    
    @IBAction func clickedOnSkipOffersBtn(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
        delegate?.skipOffers()
    }
    
    // MARK: - Tableview Delegate & Datasource
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int  {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return offerArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{
        //Create custom cell from SAOfferListTableViewCell.xib
        let cell = Bundle.main.loadNibNamed("SAOfferListTableViewCell", owner: nil, options: nil)![0] as! SAOfferListTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        //Showing Add offer button as per flag
        if(hideAddOfferButton)
        {
            cell.btnAddOffer?.isHidden = true
            cell.suggestedHt.constant = 10
        }
        else {
            cell.btnAddOffer?.isHidden = false
            cell.btnAddOffer?.addTarget(self, action: #selector(SAOfferListViewController.clickedOnAddOffer(_:)), for: UIControlEvents.touchUpInside)
            cell.btnAddOffer?.tag = indexPath.row
            cell.suggestedHt.constant = 72
        }

        cell.btnOfferDetail?.addTarget(self, action: #selector(SAOfferListViewController.clickedOnOfferDetail(_:)), for: UIControlEvents.touchUpInside)
        cell.btnOfferDetail?.tag = indexPath.row
        let cellDict:Dictionary? = offerArr[indexPath.row]
        //--------------Showing offer detail-----------------------------
        cell.lblOfferTitle?.text = cellDict!["offCompanyName"] as? String
        cell.lblOfferDiscount?.text = cellDict!["offTitle"] as? String
        cell.lblOfferSummary?.text = cellDict!["offSummary"] as? String
        cell.lblProductOffer?.text = cellDict!["offDesc"] as? String
       //----------------------------------------------------------------
        
        //Showing offer image
        if let urlStr = cellDict!["offImage"] as? String {
            if urlStr != "" {
                let str = urlStr.replacingOccurrences(of: " ", with: "%20")
                let url = URL(string: str)
                let request: URLRequest = URLRequest(url: url!)
                let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                    print("Response: \(String(describing: response))")
                    if data != nil && data?.count > 0 {
                        let image = UIImage(data: data!)
                        DispatchQueue.main.async(execute: {
                            cell.offerImage?.image = image
                        })
                    }
                })
                
                task.resume()
            }
        }
        
        cell.btnOfferDetail?.titleEdgeInsets = UIEdgeInsetsMake(0, (cell.btnOfferDetail?.imageView?.frame.size.width)!, 0, -(((cell.btnOfferDetail!.imageView?.frame.size.width)!-30)))
        
        cell.btnOfferDetail?.setImage(UIImage(named:"detail-arrow-down.png"), for: UIControlState())
        cell.btnOfferDetail?.imageEdgeInsets = UIEdgeInsetsMake(0, (cell.btnOfferDetail?.titleLabel?.frame.size.width)!, 0, -(((cell.btnOfferDetail?.titleLabel?.frame.size.width)!+30)))
        //Expand and collaps cell
        if prevIndxArr.count > 0 {
            var ht: CGFloat = 0.0
            var str = ""
            //Check any cell is expanded before
            for i in 0 ..< prevIndxArr.count {
                //Check current cell call for expand
                if prevIndxArr[i] == indexPath.row {
                    //Expand cell and show offer  detail
                    cell.btnOfferDetail?.setImage(UIImage(named:"detail-arrow-up.png"), for: UIControlState())
                    cell.btnOfferDetail?.imageEdgeInsets = UIEdgeInsetsMake(0, (cell.btnOfferDetail?.titleLabel?.frame.size.width)!, 0, -(((cell.btnOfferDetail?.titleLabel?.frame.size.width)!+30)))
                    //Showing offer description
                    if let str1 = cellDict!["offDesc"] as? String  {
                    str = str1
                    //Calculating height of lable as per the string
                    ht = self.heightForView(str, font: UIFont(name: kBookFont, size: 10)!, width: (cell.lblProductOffer?.frame.size.width)! )
                    }
                }
                else {
                    //Colapsing Cell
                    str = ""
                    ht = 0.0
                }
                //Set hieght as per string lenght
                cell.lblHT.constant = ht
                cell.lblProductOffer?.text = str
            }
        }
        else {
            cell.lblHT.constant = 0.0
            cell.lblProductOffer?.text = ""
        }
        
        //cell.btnOfferDetail?.setAttributedTitle(attributedString, forState: UIControlState.Normal)
        //        cell.lblHT.constant = 20.0
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        //Calculating row height as per expanding and colapsing
        if prevIndxArr.count > 0 {
            for i in 0 ..< prevIndxArr.count {
                if prevIndxArr[i] == indexPath.row {
                    if hideAddOfferButton{
                        //return height when add offer button is hide
                        return 260.0
                    }
                    return rowHT + 310.0
                }
            }
        }
        if hideAddOfferButton{
            return 260.0
        }
        return 310.0
    }
    
    //Function invoke for expanding the cell and showing offer detail
    func clickedOnOfferDetail(_ sender:UIButton) {
        DispatchQueue.main.async{
            //Get cell index
        self.indx = sender.tag
        var isVisible = false
            //Check cell is already expanded
        if self.prevIndxArr.count > 0{
            for i in 0 ..< self.prevIndxArr.count {
               let obj = self.prevIndxArr[i] as Int
                //if cell is expanded then collaps it
                if obj == sender.tag{
                  isVisible = true
                    self.prevIndxArr.remove(at: i)
                    break
                }
            }
            if(isVisible == false){
                self.prevIndxArr.removeAll()
                self.prevIndxArr.append(sender.tag)
            }
        }
        else {
            //add cell index in array for expanding
            self.prevIndxArr.append(sender.tag)
        }
        self.tblView?.reloadData()
        }
    }

    //Function invoke for calculating height of lable as per given text, font and width
    func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        rowHT = label.frame.height
        return rowHT
    }

    //Function invoke on tapping add offer button
    func clickedOnAddOffer(_ sender: UIButton){
        let offerDict = self.offerArr[sender.tag] as Dictionary<String,AnyObject>
        print(offerDict["offId"]!)
    
        for i in 0 ..< addedOfferArr.count{
            let newDict = addedOfferArr[i]
          
            if offerDict["offId"] as! NSNumber == newDict["offId"] as! NSNumber {
                let alert = UIAlertView(title: "Offer already added", message: "You have already added this offer to your savings plan", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
                return
            }
        }
       
        let alertController = UIAlertController(title: "Alert", message: "Your offer has been added to your plan and will be applied when you make your purchase through Savio.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("OK")
            //collecting all detail of offer and send it to setup view
            let cellDict = self.offerArr[sender.tag]
            self.delegate?.addedOffers(cellDict)
            self.navigationController?.popViewController(animated: true)
        }
        alertController.title = nil
        alertController.addAction(okAction)
       self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    //get offerlist API's delegate method invoking when success response getting from API.
    func successResponseForGetOfferlistAPI(_ objResponse:Dictionary<String,AnyObject>){
        objAnimView.removeFromSuperview()
        if offerArr.count > 0 {
            offerArr.removeAll()
        }
        //Check any value is coming Null or not
        if let obj = objResponse["offerList"] as? Array<Dictionary<String,AnyObject>>{
            for i in 0 ..< obj.count {
                //Replace dict's Null value with blanck.
                let dict = self.checkNullDataFromDict(obj[i] as Dictionary<String,AnyObject>)
                offerArr.append(dict)
            }
            print(offerArr)
        tblView?.reloadData()
        }
    }
    
    //get offerlist API's delegate method invoking when fail or error response getting from API request.
    func errorResponseForGetOfferlistAPI(_ error:String){
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kTimeOutNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    //Function invoking for check null values in dictionary and replace null values with blank and return new dict
    func checkNullDataFromDict(_ dict:Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject> {
        var replaceDict: Dictionary<String,AnyObject> = dict
        let blank = ""
        
        //check each key's value
        for key:String in Array(dict.keys) {
            let ob = dict[key]! as? AnyObject
            //if value is Null or nil replace its value with blank
            if (ob is NSNull)  || ob == nil {
                replaceDict[key] = blank as AnyObject
            }
            else if (ob is Dictionary<String,AnyObject>) {
                replaceDict[key] = self.checkNullDataFromDict(ob as! Dictionary<String,AnyObject>) as AnyObject
            }
            else if (ob is Array<Dictionary<String,AnyObject>>) {
                var newArr: Array<Dictionary<String,AnyObject>> = []
                for arrObj:Dictionary<String,AnyObject> in ob as! Array {
                    newArr.append(self.checkNullDataFromDict(arrObj as Dictionary<String,AnyObject>))
                }
                replaceDict[key] = newArr as AnyObject
            }
        }
        return replaceDict
    }
}
