//
//  SACancelSavingViewController.swift
//  Savio
//
//  Created by Maheshwari on 07/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class SACancelSavingViewController: UIViewController,CancelSavingPlanDelegate {
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var wouldYouLikeToStartNewSavingPlanLabel: UILabel!
    @IBOutlet weak var yourMoneyWillBeReturnLabel: UILabel!
    @IBOutlet weak var cancelDetailLabel: UILabel!
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var  objAnimView = ImageViewAnimation()
    
    //MARK: ViewController lifeCycle method.  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        
        //set attributed text for UILabel
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.alignment = NSTextAlignment.center
//        let attrString = NSMutableAttributedString(string: "There will be no more automated, regular payments taken from your card. Any money you have added will remain on your Savio card and you are able to use it in most shops and ATMs.")
        let attrString = NSMutableAttributedString(string: "Cancelling your plan will stop all regular top ups. Your money will remain on your Savio card and you are able to use it in ATMs and shops as usual.")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        cancelDetailLabel.attributedText = attrString
        
        let para1 = NSMutableAttributedString()
        let attrStringForWouldYouLikeToStartNewSavingPlanLabel = NSMutableAttributedString(string: "Would you like to start a new plan?", attributes:[NSFontAttributeName: UIFont(name: kBookFont, size: 15)!])
        para1.append(attrStringForWouldYouLikeToStartNewSavingPlanLabel)
        para1.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, para1.length))
        wouldYouLikeToStartNewSavingPlanLabel.attributedText = para1
        
        let para = NSMutableAttributedString()
        let attrStringForYourMoneyWillBeReturnLabelLabel = NSAttributedString(string: "There will be no more automated, regular payments taken from your card. Any money you have added will remain on your Savio card and you are able to use it in most shops and ATMs.", attributes:[NSFontAttributeName: UIFont(name: kBookFont, size: 15)!])
//        let attrStringForYourMoneyWillBeReturnLabelLabel = NSMutableAttributedString(string: "There will be no more automated, regular payments taken from your card. Any money you have added will remain on your Savio card and you are able to use it in most shops and ATMs.")
        para.append(attrStringForYourMoneyWillBeReturnLabelLabel)
        para.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, para.length))
        yourMoneyWillBeReturnLabel.attributedText = para
        
        self.setUpView()
    }
 
    //Set up the UIView
    func setUpView(){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "Plan setup"
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SACancelSavingViewController.menuButtonClicked), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.addTarget(self, action: #selector(SACancelSavingViewController.heartBtnClicked), for: .touchUpInside)
        
        //Check if NSUserDefaults.standardUserDefaults() has value for "wishlistArray"
        if let str = UserDefaults.standard.object(forKey: "wishlistArray") as? Data
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
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    //MARK: Bar button action
    func menuButtonClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    
    func heartBtnClicked(){
        if wishListArray.count>0{
            //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")
        }
        else {
            let alert = UIAlertView(title: kWishlistempty, message: kEmptyWishListMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    @IBAction func keepSavingButtonPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    //Call the API for cancelling the saving plan
    @IBAction func yesButtonPressed(_ sender: AnyObject) {
        self.objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        self.objAnimView.frame = self.view.frame
        self.objAnimView.animate()
        self.navigationController!.view.addSubview(self.objAnimView)
        
        let objAPI = API()
        objAPI.cancelSavingPlanDelegate = self
        objAPI .cancelSavingPlan()
    }
    
    //success rsponse of CancelSavingPlanDelegate
    func successResponseForCancelSavingPlanAPI(_ objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String
        {
            if (message == "Cancelled Plan successfully")
            {
                //Remove the individualPlan's value from NSUserDefaults
                UserDefaults.standard.setValue(0, forKey: kIndividualPlan)
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationIdentifier), object: nil)
                view1.isHidden = true
                view2.isHidden = false
            }
            else {
                let alert = UIAlertView(title: "Alert", message: "Internal server error", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
        else  if let message = objResponse["error"] as? String{
            let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
        
    }
    
    //error rsponse of CancelSavingPlanDelegate
    func errorResponseForCancelSavingPlanAPI(_ error: String) {
        objAnimView.removeFromSuperview()
        if error == "Network not available" {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
        let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        }
    }
    
    //Your saving plan is canceled, go to create new saving plan
    @IBAction func startNewSavingPlanButtonPressed(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SACreateSavingPlanViewController")
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SACreateSavingPlanViewController")
    }
}
