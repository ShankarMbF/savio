//
//  ContainerViewController.swift
//  Savio
//
//  Created by Prashant on 20/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit
import Stripe

let kNotificationToggleMenuView = "ToggleCentreView"   //NotificationIdentifier for toggle menu
let kNotificationAddCentreView = "AddCentreView"       //NotificationIdentifier for menu selection
var objAnimView = ImageViewAnimation()

class ContainerViewController: UIViewController,STPAddCardViewControllerDelegate,AddSavingCardDelegate,UIImagePickerControllerDelegate {
    //Create object for mnuviewcontroller
    var menuVC: UIViewController! = SAMenuViewController(nibName: "SAMenuViewController", bundle: nil)
    //Create object for showing selected menu
    var centreVC: UIViewController! =  SACreateSavingPlanViewController(nibName: "SACreateSavingPlanViewController", bundle: nil)
    var navController: UINavigationController!
    var isShowingProgress:String?
    var newView = UIView()
    var isFromGroupMemberPlan = false
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let userPlan    = userDefaults.object(forKey: "savingPlanDict") as? Dictionary<String,AnyObject>
        if (userPlan != nil)
        {
            let savedCard   = userDefaults.object(forKey: "saveCardArray")
            if savedCard != nil
            {
                self.setUpViewController()
            }else {
                //                Go to SAPaymentFlowViewController if you did not find the saved card details
                //                self.centreVC = SAPaymentFlowViewController()
                
                let addCardViewController = STPAddCardViewController()
                addCardViewController.delegate = self
                // STPAddCardViewController must be shown inside a UINavigationController.
                let navigationController = UINavigationController(rootViewController: addCardViewController)
                self.present(navigationController, animated: true, completion: nil)
            }
        }
        else {
            self.setUpViewController()
        }
        
        //--------------Setting up navigation controller--------------------------------
        self.navController = UINavigationController(rootViewController: self.centreVC)
        self.navController.view.frame = self.view.frame
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        //        self.navController.navigationBar.hidden = true
        
        self.view.addSubview(self.menuVC!.view)
        self.view.addSubview(self.navController!.view)
        self.addChildViewController(self.navController)
        self.view.addSubview(self.navController!.view)
        //----------------------------------------------------------------------------------
        
        //------Register notfication for menu toggel and menu selection-----------------------
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.addCentreView(_:)), name: NSNotification.Name(rawValue: kNotificationAddCentreView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.ToggleCentreView), name: NSNotification.Name(rawValue: kNotificationToggleMenuView), object: nil)
        //---------------------------------------------------------------------------------------
    }
    
    // Stripe Intagration
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        //        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        let objAPI = API()
        let userInfoDict = userDefaults.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
        
        let dict : Dictionary<String,AnyObject> = ["PTY_ID":userInfoDict[kPartyID] as! NSNumber,"STRIPE_TOKEN":(token.stripeID as AnyObject),"PTY_SAVINGPLAN_ID":userDefaults.value(forKey: kPTYSAVINGPLANID) as! NSNumber]
        
        
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.navigationController!.view.addSubview(objAnimView)
        
        objAPI.addSavingCardDelegate = self
        objAPI.addSavingCard(dict)
        
        //Use token for backend process
        self.dismiss(animated: true, completion: {
            completion(nil)
        })
    }
    
    
    func setUpViewController()
    {
        // Set all plan flag
        let individualFlag = userDefaults.value(forKey: kIndividualPlan) as! NSNumber
        let groupFlag = userDefaults.value(forKey: kGroupPlan) as! NSNumber
        let groupMemberFlag = userDefaults.value(forKey: kGroupMemberPlan) as! NSNumber
        if let usersPlan = userDefaults.value(forKey: kUsersPlan) as? String
        {
            //As per flag show the progress view of plan
            if usersPlan == "I"{
                self.centreVC = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
            }
            else
            {
                self.centreVC = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
            }
            
        }
        else {
            if individualFlag == 1 { //Individual plan
                self.centreVC = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
            }
            else if(groupFlag == 1 || groupMemberFlag == 1) //Group or group member plan
            {
                self.centreVC = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
            }
            else {//create saving plan if no plan exist
                self.centreVC = SACreateSavingPlanViewController(nibName: "SACreateSavingPlanViewController", bundle: nil)
            }
        }
    }
    
    //function invoke on tapping menu button.
    func ToggleCentreView() {
        var destination = self.navController.view.frame;
        if (destination.origin.x > 0) {
            destination.origin.x = 0;
            newView.removeFromSuperview()
        } else {
            destination.origin.x += 250
            newView.frame = CGRect(x: 250, y: 40, width: self.navController.view.frame.width, height: self.navController.view.frame.height)
            newView.backgroundColor = UIColor.clear
            let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTapsRequired = 1
            tapGesture.addTarget(self, action: #selector(ContainerViewController.newViewTouched(_:)))
            newView.addGestureRecognizer(tapGesture)
            self.view.addSubview(newView)
        }
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.navController.view.frame = destination
        })
    }
    
    func newViewTouched(_ sender:UITapGestureRecognizer)
    {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.navController.view.frame = CGRect(x: 0, y: 0, width: self.navController.view.frame.width, height: self.navController.view.frame.height)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //Function invoke when menu item selected and kNotificationAddCentreView notification is broadcast.
    func addCentreView(_ notification: Notification) {
        let className = notification.object as! String
        
        
        
        //Check selected menu class and current class is same then close menu
        if (self.centreVC.nibName == className) || (self.centreVC.nibName == "SAGroupProgressViewController" && className == "SAProgressViewController") {
            self.ToggleCentreView()
            return
        }
        self.navController.view.removeFromSuperview()
        self.navController.removeFromParentViewController()
        
        //Identify selected menu class and as per class name replace viewcontroller with selected class
        switch className {
        case "SACreateSavingPlanViewController":
            self.centreVC = SACreateSavingPlanViewController(nibName: "SACreateSavingPlanViewController", bundle: nil)
            self.replaceViewController()
            
        case "SAWishListViewController":
            self.centreVC = SAWishListViewController(nibName: "SAWishListViewController", bundle: nil)
            self.replaceViewController()
            
        case "SAOfferListViewController":
            
            userDefaults.removeObject(forKey: "offerList")
            
            let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92] as [String : Any]
            userDefaults.set(dict, forKey:"colorDataDict")
            userDefaults.synchronize()
            
            userDefaults.synchronize()
            let obj = SAOfferListViewController(nibName: "SAOfferListViewController", bundle: nil)
            obj.hideAddOfferButton = true
            obj.isComingProgress = false
            self.centreVC = obj
            centreVC.hidesBottomBarWhenPushed = true
            self.replaceViewController()
            
        case "SASwitchViewController":
            self.centreVC = SASwitchViewController(nibName: "SASwitchViewController", bundle: nil)
            self.replaceViewController()
            
        case "SAProgressViewController":
            userDefaults.removeObject(forKey: "offerList")
            userDefaults.synchronize()
            //Assigning all plan flag
            let individualFlag = userDefaults.value(forKey: kIndividualPlan) as! NSNumber
            
            var usersPlanFlag = ""
            if let usersPlan = userDefaults.value(forKey: kUsersPlan) as? String
            {
                usersPlanFlag = usersPlan
                //As per flag show the progress view of plan
                if individualFlag == 1 && usersPlanFlag == "I"{
                    self.centreVC = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
                }
                else
                {
                    self.centreVC = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
                }
                
            } else {
                usersPlanFlag = ""
                //As per flag show the progress view of plan
                if individualFlag == 1{
                    self.centreVC = SAProgressViewController(nibName: "SAProgressViewController", bundle: nil)
                }
                else
                {
                    self.centreVC = SAGroupProgressViewController(nibName: "SAGroupProgressViewController", bundle: nil)
                }
            }
            self.replaceViewController()
            
        case "SASavingPlanViewController":
            
            let obj = SASavingPlanViewController(nibName: "SASavingPlanViewController", bundle: nil)
            obj.isUpdatePlan = true
            let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92] as [String : Any]
            userDefaults.set(dict, forKey:"colorDataDict")
            userDefaults.synchronize()
            self.centreVC = obj
            self.replaceViewController()
            
        case "SASettingsViewController":
            self.centreVC = SAEditUserInfoViewController(nibName: "SAEditUserInfoViewController", bundle: nil)
            self.replaceViewController()
            
        case "SASpendViewController":
            self.centreVC = SASpendViewController(nibName: "SASpendViewController", bundle: nil)
            self.replaceViewController()
            
        case "SignOut":
            self.navController.removeFromParentViewController()
            var vw = UIViewController()
            
            for var obj in (self.navigationController?.viewControllers)!{
                if obj.isKind(of: SAEnterYourPINViewController.self) {
                    vw = obj as! SAEnterYourPINViewController
                    self.navigationController?.popToViewController(vw, animated: true)
                    break
                }
            }
        default:
            let alert = UIAlertView(title: "Alert", message: "Your saving plan is created successfully", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    //Function invoke for replace the current menu class with selected menu class
    func replaceViewController() {
        self.navController = UINavigationController(rootViewController: self.centreVC)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navController.view.frame = self.view.frame
        self.addChildViewController(self.navController)
        self.view.addSubview(self.navController!.view)
    }
    
    func successResponseForAddSavingCardDelegateAPI(_ objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        if let message = objResponse["message"] as? String{
            if(message == "Successful")
            {
                if(objResponse["stripeCustomerStatusMessage"] as? String == "Customer Card detail Added Succeesfully")
                {
                    userDefaults.set(1, forKey: "saveCardArray")
                    userDefaults.synchronize()
                    objAnimView.removeFromSuperview()
                    
                    //                     navigation to Summary Screen as well as for ProgressView (Force Close)
                    self.menuVC = SAMenuViewController(nibName: "SAMenuViewController", bundle: nil)
                    self.view.addSubview(self.menuVC!.view)
                    self.centreVC = SASavingSummaryViewController(nibName: "SASavingSummaryViewController", bundle: nil)
                    self.replaceViewController()
                    
                    //                    let objSummaryView = SASavingSummaryViewController()
                    //                    _ = UINavigationController.init(rootViewController: objSummaryView)
                    //                    self.navigationController?.pushViewController(objSummaryView, animated: true)
                }
            }
        }
    }
    
    //Error response of AddSavingCardDelegate
    func errorResponseForAddSavingCardDelegateAPI(_ error: String) {
        objAnimView.removeFromSuperview()
        if error == kNonetworkfound {
            let alert = UIAlertView(title: kConnectionProblemTitle, message: kNoNetworkMessage, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }else{
            let alert = UIAlertView(title: "Alert", message: error, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
}
