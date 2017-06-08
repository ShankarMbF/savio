//
//  SAImpulseSavingViewController.swift
//  Savio
//
//  Created by Maheshwari on 07/07/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

extension String {
    func chopPrefix(_ count: Int = 1) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return self.substring(from: self.characters.index(self.endIndex, offsetBy: -count))
    }
}

import UIKit

class SAImpulseSavingViewController: UIViewController {
    
    @IBOutlet weak var addFundsButton: UIButton!
    @IBOutlet weak var deductMoneyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var anotherStepLabel: UILabel!
    @IBOutlet weak var savedPaymentLabel: UILabel!
    @IBOutlet weak var offersButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var messagePopupImageView: UIImageView!
    @IBOutlet weak var messagePopUpView: UIView!
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var addFundsViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var circularViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var cancleButton: UIButton!
    
    var isFromPayment = false
    var circleSlider: CircleSlider! {
        didSet {
            self.circleSlider.tag = 0
        }
    }
    
    var wishListArray : Array<Dictionary<String,AnyObject>> = []
    fileprivate var valueLabel: UILabel!
    fileprivate var progressLabel: UILabel!
    fileprivate var timer: Timer?
    fileprivate var progressValue: Float = 0
    var lastOffset: CGPoint = CGPoint.zero
    var maxPrice: Float?
    
    fileprivate var sliderOptions: [CircleSliderOption] {
        return [
            CircleSliderOption.startAngle(-90),
            CircleSliderOption.thumbImage(UIImage (named: "slider-handle@2x.png")),
            CircleSliderOption.barColor(UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1)),
            CircleSliderOption.trackingColor(UIColor(red: 244/255, green: 176/255, blue: 58/255, alpha: 1)),
            CircleSliderOption.barWidth(20),
            CircleSliderOption.thumbWidth(40),
            CircleSliderOption.maxValue(100),
            CircleSliderOption.minValue(0),
            CircleSliderOption.sliderEnabled(true)
        ]
    }
    
    //MARK: ViewController lifeCycle method.
    override func viewDidLoad() {
        super.viewDidLoad()
        let ImpMaxAmount = userDefaults.value(forKey: "ImpMaxAmount") as! Float
        maxPrice = ImpMaxAmount
        self.buildCircleSlider()
        self.setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(isFromPayment)
        {
            messagePopUpView.isHidden = true
            circularView.backgroundColor = UIColor(red : 244/255,
                                                   green : 172/255,
                                                   blue : 58/255, alpha: 1)
            circularView.layer.cornerRadius = circularView.frame.height / 2
            priceTextField.isHidden = true
            
            if let _ = userDefaults.value(forKey: "ImpulseAmount") as? String
            {
               priceLabel.text = String(format:"£%@",(userDefaults.value(forKey: "ImpulseAmount") as? String)!)
            }else {
                priceLabel.text = "£0"
            }
            cancleButton.isHidden = true
            priceTextField.borderStyle = UITextBorderStyle.none
            circleSlider.isHidden = true
            priceLabel.isHidden = false
            anotherStepLabel.isHidden = false
            savedPaymentLabel.isHidden = false
            addFundsButton.setTitle("Continue", for: UIControlState())
            addFundsButton.setTitleColor(UIColor.white, for: UIControlState())
            addFundsButton.backgroundColor = UIColor(red : 244/255,
                                                     green : 172/255,
                                                     blue : 58/255, alpha: 1)
            
            deductMoneyLabel.text = String(format:"Your payment of £%@ has been added to your saving plan.",(userDefaults.value(forKey: "ImpulseAmount") as? String)!)
            isFromPayment = false
            circularViewTopSpace.constant = 10
            
        }
        else {
          
            circularViewTopSpace.constant = 70
            deductMoneyLabel.text = ""
        }
    }
    
    //customization of circle slider
    fileprivate func buildCircleSlider() {
        self.circleSlider = CircleSlider(frame: CGRect(x: 0, y: 0, width: circularView.frame.size.width, height: circularView.frame.size.height), options: self.sliderOptions)
        self.circleSlider?.addTarget(self, action: #selector(SAImpulseSavingViewController.valueChange(_:)), for: .valueChanged)
        self.valueLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.valueLabel.textAlignment = .center
        self.valueLabel.center = CGPoint(x: self.circleSlider.bounds.width * 0.5, y: self.circleSlider.bounds.height * 0.5)
    
        self.circleSlider.addSubview(self.valueLabel)
        circularView.addSubview(circleSlider)
    }
    
    
    //Circle slider action method
    func valueChange(_ sender: CircleSlider) {
        
        let multipleAttributes: [String : AnyObject] = [
            NSFontAttributeName: UIFont(name:kMediumFont, size: 32.0)!,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleNone.rawValue as AnyObject ]
        
//        var attr = [[NSFontAttributeName : UIFont(name: kMediumFont, size: 10)],[NSUnderlineStyleAttributeName :  NSUnderlineStyle.StyleNone.rawValue]]
        
        _ = [ NSUnderlineStyleAttributeName: NSUnderlineStyle.styleNone.rawValue]
       // messagePopUpView.hidden = true
        priceTextField.borderStyle = UITextBorderStyle.roundedRect
        var calculatedValue: Float = 0.0
        if sender.value == 0 {
             priceTextField.borderStyle = UITextBorderStyle.none
        }
        else if (maxPrice! <= 200) {
            calculatedValue = (maxPrice! / 100) * Float(sender.value)
        }
        else {
            if Float(sender.value) <= 50 {
                calculatedValue = Float(sender.value) * 2.0
            }
            else{
                //NewSLider Value for second half-Non linear
                var senderValue = sender.value
                if sender.value > 100.0 {
                    senderValue = 100.0
                }
                let newMaxValue = maxPrice! - 100.0
                let newSliderValue = senderValue - 50.0
                calculatedValue = newMaxValue / 50.0 * newSliderValue
                calculatedValue += 100
//                calculatedValue = (maxPrice!/200) * Float(sender.value)
            }
            print(calculatedValue)
        }

//        let attrString2 = NSAttributedString(string: String(format:"£%d",Int(sender.value)), attributes: singleAttribute3)
//        var attributedString = NSMutableAttributedString(strin)
        let attrString2 = NSAttributedString(string: String(format:"£%.0f",calculatedValue), attributes: multipleAttributes)
        priceTextField.attributedText = attrString2
    }
    
    func createAttributedString(_ string: String) -> NSAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
        
        attributedString.addAttributes([ NSUnderlineStyleAttributeName: NSUnderlineStyle.styleNone.rawValue], range: NSRange(location: 0, length: string.characters.count))
//        attributedString.addAttributes([NSFontAttributeName:UIFont(name: kMediumFont, size: 10)!], range: NSRange(location: 0, length: string.characters.count))
        return attributedString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrlView.contentSize = CGSize(width: 0, height: UIScreen.main.bounds.height + 20)
        
        //add rounded corners to plan button
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.planButton!.bounds, byRoundingCorners: ([.topRight, .topLeft]), cornerRadii: CGSize(width: 3.0, height: 3.0))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.planButton!.bounds
        maskLayer.path = maskPath.cgPath
        self.planButton?.layer.mask = maskLayer
    }
    
    func setUpView(){
        
        spendButton.setImage(UIImage(named: "stats-spend-tab.png"), for: UIControlState())
        planButton.setImage(UIImage(named: "stats-plan-tab-active.png"), for: UIControlState())
        offersButton.setImage(UIImage(named: "stats-offers-tab.png"), for: UIControlState())
        planButton.backgroundColor = UIColor(red: 244/255,green:176/255,blue:58/255,alpha:1)
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "Add more funds"
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-menu.png"), for: UIControlState())
        leftBtnName.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBtnName.addTarget(self, action: #selector(SAImpulseSavingViewController.menuButtonClicked), for: .touchUpInside)
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
        btnName.addTarget(self, action: #selector(SAImpulseSavingViewController.heartBtnClicked), for: .touchUpInside)
        
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
        var customToolBar : UIToolbar?
        customToolBar = UIToolbar(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action:#selector(SAImpulseSavingViewController.doneBarButtonPressed))
        customToolBar!.items = [acceptButton]
        priceTextField.inputAccessoryView = customToolBar
        priceTextField.layer.borderColor = UIColor.black.cgColor
    }
    
    func menuButtonClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationToggleMenuView), object: nil)
    }
    
    //UITextfieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.characters.count)! > 1  && string == "" {
            return true
        }
        let combinedString = textField.text! + string
        let valueString = combinedString.chopPrefix(1)
        if valueString.characters.count == 0 {
            return false
        }
        if(Float(valueString)! > maxPrice!)
        {
            circleSlider.value = 0.0
            let msgStr = String(format: "The maximum you can top up is £%.0f", maxPrice!)
            AlertContoller(UITitle: "Whoa!", UIMessage: msgStr)

            self.removeKeyboardNotification()
            return false
        }
        if combinedString.characters.count < 6 {
            var slideValue: Float = 0.0
            if (Float(valueString)! <= 100) {
                slideValue = Float(valueString)! / 2.0
                if Int(maxPrice!) <= 100{
                    slideValue = Float(valueString)! / (Float(maxPrice!)/100)}
            } else {
                
                let newCurrentValue = Float(valueString)! - 100.0
                let newMaxPrice : Float = maxPrice! - 100.0
                
                slideValue = (newCurrentValue * 50.0) / newMaxPrice
                slideValue += 50.0

            }
            
//            if (Float(valueString)! <= 100){
//                slideValue = Float(valueString)! / (Float(maxPrice!)/100)
//            }
//            else{
//                slideValue = Float(valueString)! / 3.0
//            }
            print(slideValue)
            circleSlider.value = slideValue
        }
        return false
    }
    
    //Register keyboard notification
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(SAImpulseSavingViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SAImpulseSavingViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Keyboard notification function
    @objc func keyboardWasShown(_ notification: Notification){
        //do stuff
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        var info = notification.userInfo as! Dictionary<String,AnyObject>
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue.size
        let visibleAreaHeight = UIScreen.main.bounds.height - 30 - (kbSize?.height)! //64 height of nav bar + status bar + tab bar
        lastOffset = (scrlView?.contentOffset)!
        let yOfTextField = priceTextField.frame.height
        if (yOfTextField - (lastOffset.y)) > visibleAreaHeight {
            let diff = yOfTextField - visibleAreaHeight
            scrlView?.setContentOffset(CGPoint(x: 0, y: diff), animated: true)
        }
    }
    
    //Keyboard notification function
    @objc func keyboardWillBeHidden(_ notification: Notification){
        //do stuff
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        scrlView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    
    //UITextfieldDelegate method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
//        messagePopUpView.hidden = true
        self.registerForKeyboardNotifications()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        self.removeKeyboardNotification()
        return true
    }
    
    @IBAction func offersButtonPressed(_ sender: AnyObject) {
        let obj = SAOfferListViewController()
        obj.savID = 92
        //save the Generic plan in NSUserDefaults, so it will show its specific offers
        let dict = ["savLogo":"generic-category-icon","title":"Generic plan","savDescription":"Don't want to be specific? No worries, we just can't give you any offers from our partners.","savPlanID" :92] as [String : Any]
        userDefaults.set(dict, forKey:"colorDataDict")
        userDefaults.synchronize()
        obj.hideAddOfferButton = true
        obj.isComingProgress = true
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    //Go to SASpendViewController
    @IBAction func spendButtonPressed(_ sender: AnyObject) {
        let objPlan = SASpendViewController(nibName: "SASpendViewController",bundle: nil)
        self.navigationController?.pushViewController(objPlan, animated: false)
    }
    
    func doneBarButtonPressed(){
        var tfString: String = priceTextField.text!
        tfString = tfString.chopPrefix(1)
        priceTextField.resignFirstResponder()
    
        if(maxPrice! < Float(tfString)!) {
            AlertContoller(UITitle: "Whoa!", UIMessage: "The maximum you can top up is £3000")
        }
        self.removeKeyboardNotification()
        
    }
    
    @IBAction func addFundsButtonPressed(_ sender: AnyObject) {
        if(addFundsButton.titleLabel?.text == "MAKE PAYMENT")
        {
            var tfString: String = priceTextField.text!
            tfString = tfString.chopPrefix(1)
            if(tfString == "00" || tfString == "0")
            {
                AlertContoller(UITitle: "Hmmm", UIMessage: "You can't top up with no money, that won't get you anywhere!")
            }
            else {
                userDefaults.setValue(tfString, forKey: "ImpulseAmount")
                userDefaults.synchronize()
                let objSavedCardView = SASaveCardViewController()
                objSavedCardView.isFromImpulseSaving = true
//                objSavedCardView.isFromGroupMemberPlan = self.
                self.navigationController?.pushViewController(objSavedCardView, animated: true)
            }
    
        }
        else
        {
            userDefaults.setValue(1, forKey: "ContinueHit")
            userDefaults.synchronize()

            if let plan = userDefaults.value(forKey: "usersPlan") as? String
            { //Individual plan
                if(plan == kIndividualPlan)
                {
                    let objProgressView = SAProgressViewController()
                    self.navigationController?.pushViewController(objProgressView, animated: true)
                }
                else if(plan == kGroupPlan)
                {
                    let objProgressView = SAGroupProgressViewController()
                    self.navigationController?.pushViewController(objProgressView, animated: true)
                }
                else if(plan == kGroupMemberPlan)
                {
                    let objProgressView = SAGroupProgressViewController()
                    self.navigationController?.pushViewController(objProgressView, animated: true)
                }
            }

        }
    }
    
    
    @IBAction func CancelButtonPressed(_ sender: AnyObject) {
            self.navigationController?.popViewController(animated: true)
    }
    
    
    func heartBtnClicked(){
        //check if wishlistArray count is greater than 0 . If yes, go to SAWishlistViewController
        if wishListArray.count>0{
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSelectRowIdentifier), object: "SAWishListViewController")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationAddCentreView), object: "SAWishListViewController")
        }
        else {
            AlertContoller(UITitle: kWishlistempty, UIMessage: kEmptyWishListMessage)
        }
    }
    
}
