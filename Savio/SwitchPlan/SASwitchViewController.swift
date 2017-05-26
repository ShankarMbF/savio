//
//  SASwitchViewController.swift
//  Savio
//
//  Created by Prashant on 21/06/16.
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


class SASwitchViewController: UIViewController,GetListOfUsersPlanDelegate {
    
    
    @IBOutlet var scrView : UIScrollView?
    @IBOutlet var confirmBtn : UIButton?
    @IBOutlet weak var planOneImageView: UIImageView!
    @IBOutlet weak var planTwoImageView: UIImageView!
    @IBOutlet weak var planOneButton: UIButton!
    @IBOutlet weak var planTwoButton: UIButton!
    @IBOutlet weak var spinnerOne: UIActivityIndicatorView!
    @IBOutlet weak var spinnerTwo: UIActivityIndicatorView!
    
    var usersPlanArray : Array<Dictionary<String,AnyObject>> = []
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    var objAnimView = ImageViewAnimation()
    var planOneSharedSavingPlanID = ""
    var planTwoSharedSavingPlanID = ""
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: kMediumFont, size: 16)!]
        objAnimView = (Bundle.main.loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        self.view.addSubview(objAnimView)
        
        //Create object of API class to call the GETSavingPlanDelegate methods.
        let objAPI = API()
        objAPI.getListOfUsersPlanDelegate = self
        objAPI.getListOfUsersPlan()
        self.setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrView?.contentSize = CGSize(width: 0, height: confirmBtn!.frame.origin.y + confirmBtn!.frame.size.height + 10)
        //        scrlVw?.contentSize = CGSizeMake(0, htContentView.constant)
    }
    
    func setUpView(){
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SASwitchViewController.menuButtonClicked), for: .touchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.title = "Switch plans"
        //set Navigation right button nav-heart
        
        let btnName = UIButton()
        //        btnName.setImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), for: UIControlState())
        btnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnName.titleLabel!.font = UIFont(name: kBookFont, size: 12)
        btnName.setTitle("0", for: UIControlState())
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), for: UIControlState())
        btnName.addTarget(self, action: #selector(SASwitchViewController.heartBtnClicked), for: .touchUpInside)
        
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
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    @IBAction func confirmButtonPressed(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAProgressViewController")
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAProgressViewController")
    }
    
    //MARK: Bar button action
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
    
    @IBAction func planOneButtonPressed(_ sender: AnyObject) {
        planTwoImageView.layer.borderWidth = 0
        planOneImageView.layer.borderWidth = 3
        planOneImageView.layer.borderColor = UIColor(red:244/255,green: 176/255,blue: 58/255,alpha: 1).cgColor
        
        let dictOne = usersPlanArray[0] as Dictionary<String,AnyObject>
        
        var planOneType = ""
        if(dictOne["partySavingPlanType"] as! String == "Group")
        {
            let sharedSavingPlanID = dictOne["sharedSavingPlanID"] as? NSNumber
            if (sharedSavingPlanID != nil)
            {
                planOneType = "GM"
            }
            else {
                planOneType = "G"
            }
        }
        else {
            planOneType = "I"
        }
        
        userDefaults.set(planOneType, forKey: kUsersPlan)
        userDefaults.synchronize()
    }
    
    @IBAction func planTwoButtonPressed(_ sender: AnyObject) {
        planOneImageView.layer.borderWidth = 0
        planTwoImageView.layer.borderWidth = 3
        planTwoImageView.layer.borderColor = UIColor(red:244/255,green: 176/255,blue: 58/255,alpha: 1).cgColor
        
        let dictTwo = usersPlanArray[1] as Dictionary<String,AnyObject>
        
        var planTwoType = ""
        if(dictTwo["partySavingPlanType"] as! String == "Group")
        {
            if (dictTwo["sharedSavingPlanID"] as? NSNumber) != nil
            {
                planTwoType = "GM"
            }
            else {
                planTwoType = "G"
            }
        }
        else {
            planTwoType = "I"
        }
        
        userDefaults.set(planTwoType, forKey: kUsersPlan)
        userDefaults.synchronize()
        
    }
    
    //MARK: GetListOfUsersPlanDelegate methods
    
    func successResponseForGetListOfUsersPlanAPI(_ objResponse: Dictionary<String, AnyObject>) {
        objAnimView.removeFromSuperview()
        print(objResponse)
        if let message = objResponse["message"] as? String
        {
            if(message == "Successfully received")
            {
                usersPlanArray = (objResponse["lstPartysavingplan"] as? Array<Dictionary<String,AnyObject>>)!
                
                for i in 0 ..< usersPlanArray.count {
                    spinnerOne.isHidden = false
                    spinnerOne.startAnimating()
                    
                    spinnerTwo.isHidden = false
                    spinnerTwo.startAnimating()
                    
                    let dict = usersPlanArray[i] as Dictionary<String,AnyObject>
                    if(i == 0)
                    {
                        planOneButton .setTitle(dict[kTitle] as? String , for: UIControlState())
                        self.view.bringSubview(toFront: planOneButton)
                    }
                    else if(i == 1)
                    {
                        planTwoButton .setTitle(dict[kTitle] as? String , for: UIControlState())
                        self.view.bringSubview(toFront: planTwoButton)
                    }
                    
                    if let urlString = dict["image"] as? String
                    {
                        let url = URL(string:urlString)
                        let request: URLRequest = URLRequest(url: url!)
                        if(urlString != "")
                        {
                            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { ( response: URLResponse?,data: Data?,error: NSError?) -> Void in
                                if data?.count > 0
                                {
                                    let image = UIImage(data: data!)
                                    DispatchQueue.main.async(execute: {
                                        if(i == 0)
                                        {
                                            self.planOneImageView.image = image
                                            self.spinnerOne.isHidden = true
                                            self.spinnerOne.stopAnimating()
                                        }
                                        else {
                                            self.planTwoImageView.image = image
                                            self.spinnerTwo.isHidden = true
                                            self.spinnerTwo.stopAnimating()
                                        }
                                    })
                                }
                                else {
                                    DispatchQueue.main.async(execute: {
                                        self.spinnerOne.isHidden = true
                                        self.spinnerOne.stopAnimating()
                                        self.spinnerTwo.isHidden = true
                                        self.spinnerTwo.stopAnimating()
                                    })
                                }
                            } as! (URLResponse?, Data?, Error?) -> Void)
                        }
                        else {
                            self.spinnerOne.isHidden = true
                            self.spinnerOne.stopAnimating()
                            self.spinnerTwo.isHidden = true
                            self.spinnerTwo.stopAnimating()
                        }
                    }else {
                        self.spinnerOne.isHidden = true
                        self.spinnerOne.stopAnimating()
                        self.spinnerTwo.isHidden = true
                        self.spinnerTwo.stopAnimating()
                    }
                    
                    
                }
                
                planOneImageView.layer.cornerRadius = planOneImageView.frame.size.height / 2
                self.planOneImageView.clipsToBounds = true
                planTwoImageView.layer.cornerRadius = planTwoImageView.frame.size.height / 2
                self.planTwoImageView.clipsToBounds = true
                self.setUpView()
            }
        }
    }
    
    func errorResponseForGetListOfUsersPlanAPI(_ error: String) {
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
