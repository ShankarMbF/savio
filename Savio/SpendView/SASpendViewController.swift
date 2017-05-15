//
//  SASpendViewController.swift
//  Savio
//
//  Created by Maheshwari on 24/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SASpendViewController: UIViewController,GetAffiliatedTrackID {
    
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var congratsLbl: UILabel!
    @IBOutlet weak var spendNowBtn: UIButton!
    @IBOutlet weak var btnBg: UIView!
    @IBOutlet weak var congratsView: UIView!
    
    
    var AffURL : Dictionary<String,AnyObject> = [:]
    let objAPI = API()
    
    var objAnimView = ImageViewAnimation()
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        congratsView.isHidden = true
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        spendButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        spendButton.tintColor = UIColor.white
        spendButton.setImage(UIImage(named: "stats-spend-tab-active.png"), for: UIControlState())
        planButton.setImage(UIImage(named: "stats-plan-tab.png"), for: UIControlState())
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), for: UIControlState())
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    //Set up the NavigationBar
    func setUpView(){
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.isNavigationBarHidden = false
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SASpendViewController.menuButtonClicked), for: .touchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "Spend now"
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.addTarget(self, action: #selector(SASpendViewController.heartBtnClicked), for: .touchUpInside)
        
        if let str = UserDefaults.standard.object(forKey: "wishlistArray") as? Data
        {
            let dataSave = str
            wishListArray = (NSKeyedUnarchiver.unarchiveObject(with: dataSave) as? Array<Dictionary<String,AnyObject>>)!
            //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
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
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        if UserDefaults.standard.object(forKey: kSNSITEURL) != nil{
            // exist
            self.showCongratsView()
            
        }
        else {
            // not exist
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //customization of spend button
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.spendButton!.bounds, byRoundingCorners: ([.topRight, .topLeft]), cornerRadii: CGSize(width: 3.0, height: 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.spendButton!.bounds
        maskLayer.path = maskPath.cgPath
        self.spendButton?.layer.mask = maskLayer
    }
    
    //MARK: Bar button actions
    func menuButtonClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    
    func heartBtnClicked(){
        //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
        if wishListArray.count>0{
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: kWishlistempty, message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func showCongratsView() {
        congratsView.isHidden = false
        let planTitle = UserDefaults.standard.object(forKey: "PlanTitle")
        print(planTitle)
        let str = "Congratulations,\nyou have reached your target for your \(planTitle!) !"
        let lenStr = " you have reached your target for your "
        
        
        //        let attrText = NSMutableAttributedString(string: String(format: "My %@ plan target is £%@",itemTitle,cost))
        let attrText = NSMutableAttributedString(string: str)
        attrText.addAttribute(NSFontAttributeName,
                              value: UIFont(
                                name: kLightFont,
                                size: 20.0)!,
                              range: NSRange(
                                location: 16,
                                length: lenStr.characters.count))
        
        congratsLbl.attributedText = attrText
    }
    
    @IBAction func spendNowButtonClicked(_ sender:UIButton) {
        print("Spend Button Clicked...")
        
        //Add animation of logo
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        
        let URL = Foundation.URL(string: UserDefaults.standard.object(forKey: kSNSITEURL) as! String )
        if URL?.host != "www.getsavio.com"{
             let strURL : String! = "\(URL?.scheme)://\(URL?.host)"
             print(strURL)
             AffURL["affiliate_url"] = strURL as AnyObject
             
             objAPI.getAffiliateIdDelegate = self
             objAPI.getAffiliateID(AffURL)
            UIApplication.shared.openURL(URL!)
        }else{
            UIApplication.shared.openURL(URL!)
        }
    }
    
    @IBAction func planButtonPressed(_ sender: AnyObject) {
        var vw = UIViewController?()
        let individualFlag = UserDefaults.standard.value(forKey: kIndividualPlan) as! NSNumber
        var isAvailble: Bool = false
        var usersPlanFlag = ""
        if let usersPlan = UserDefaults.standard.value(forKey: kUsersPlan) as? String
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
            self.navigationController?.popToViewController(vw!, animated: false)
        }
        else{
            
            self.navigationController?.pushViewController(vw!, animated: false)
        }
    }
    
    //Go to SAOffersViewController
    @IBAction func offersButtonPressed(_ sender: AnyObject) {
        var isAvailble: Bool = false
        var vw = UIViewController?()
        
        for var obj in (self.navigationController?.viewControllers)!{
            if obj.isKind(of: SAOfferListViewController.self) {
                isAvailble = true
                vw = obj as! SAOfferListViewController
                break
            }
        }
        
        if isAvailble {
            self.navigationController?.popToViewController(vw!, animated: false)
        }
        else{
            let obj = SAOfferListViewController()
            obj.savID = 92
            obj.isComingProgress = true
            //save the Generic plan in NSUserDefaults, so it will show its specific offers
            let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92] as [String : Any]
            UserDefaults.standard.set(dict, forKey:"colorDataDict")
            UserDefaults.standard.synchronize()
            obj.hideAddOfferButton = true
            self.navigationController?.pushViewController(obj, animated: false)
        }
    }
    
    
    //MARK: GetWishlist Delegate method
    func successResponseAffiliated(_ objResponse: Dictionary<String, AnyObject>) {
        print(objResponse)
        if let status = objResponse["status"] as? String{
            if status == "405" {
                if let url = URL(string: UserDefaults.standard.object(forKey: kSNSITEURL) as! String ){
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    //function invoke when GetWishlist API request fail
    func errorResponseAffiliated(_ error: String) {
        objAnimView.removeFromSuperview()
        if(error == kNonetworkfound)
        {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        else {
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
    }
}
