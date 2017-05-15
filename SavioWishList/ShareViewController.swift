//
//  ShareViewController.swift
//  Share
//
//  Created by Mangesh on 03/06/16.
//  Copyright © 2016 Mangesh  Tekale. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class ShareViewController: UIViewController,UITextFieldDelegate,ShareExtensionDelegate {
    
    @IBOutlet var shareView: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet var lblImagePagingCount: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var bgView: UIView!
    
    var spinner =  UIActivityIndicatorView()
    var currentImagePosition: Int = 0;
    var dictGlobal : Dictionary  <String,AnyObject> = [:]
    var isWebserviceCall: Bool = false
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: AnyObject) {
        priceTextField.resignFirstResponder()
        let objAPI = API()
        let defaults: UserDefaults = UserDefaults(suiteName: "group.savio.web.share.extention")!
        
        if  let data = defaults.value(forKey: "myPasscode") as? Data
        {
            if((NSKeyedUnarchiver.unarchiveObject(with: data) as! String) == "")
            {
                let alert = UIAlertController(title: "You’re not logged into Savio", message: "Open the app and login or register before adding wish list items.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                { action -> Void in
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                    })
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                if self.textView.text.characters.count == 0 && self.priceTextField.text?.characters.count == 0 || self.imageView.image == nil {
                    let alert = UIAlertController(title: "Savio can’t get all the details of this item.", message: "Try again or enter the product name and price manually.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else if self.textView.text.characters.count == 0 {
                    let alert = UIAlertController(title: "Savio can’t get all the details of this item.", message: "Please enter the product name", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else if self.priceTextField.text!.characters.count == 0 {
                    
                    let alert = UIAlertController(title: "Savio can’t get all the details of this item.", message: "Please enter the product price", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
               else if((priceTextField.text! as NSString).floatValue > 3000)
                {
                    let alert = UIAlertController(title: "Whoa!", message: "The maximum you can top up is £3000", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                else {
                    var text = priceTextField.text
                    text = text?.replacingOccurrences(of: ",", with: "")
                    text = text?.replacingOccurrences(of: "£", with: "")
                    print(text)
                    if(Float(text!) < 3000)
                    {
                    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                        if self.isWebserviceCall == false {
                            self.isWebserviceCall = true
//                        self.spinner.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, 200)
//                        self.spinner.hidesWhenStopped = true
//                        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
//                        self.view.addSubview(self.spinner)
//                        self.spinner.startAnimating()
                        var dict : Dictionary<String,AnyObject> = [:]
                        
                        if(self.imageView.image != nil)
                        {
                        let imageData:Data = UIImageJPEGRepresentation(self.imageView.image!, 1.0)!
                        let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                        var newDict : Dictionary<String,AnyObject> = [:]
                        newDict["imageName.jpg"] = base64String as AnyObject
                        dict["IMAGEURL"] = newDict as AnyObject
                        }
                        let data = defaults.value(forKey: kUserInfo) as! Data
                        let userDict = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
                        dict["TITLE"] = self.textView.text as AnyObject
                        dict["AMOUNT"] = self.priceTextField.text?.replacingOccurrences(of: "£", with: "") as AnyObject
                        dict["PARTYID"] = userDict["partyId"] as AnyObject
                        dict["SHAREDSAVINGPLANID"] = "" as AnyObject
                        dict["SITEURL"] = self.dictGlobal["ProdURL"]!
                        print(dict)
                        objAPI.shareExtensionDelegate = self
                        objAPI.sendWishList(dict)
                        }
                    });
                    }
                    else {
                        let alert = UIAlertController(title: "Warning", message: "Please pick up item which cost less than £ 3000", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            spinner.stopAnimating()
            spinner.isHidden = true
            let alert = UIAlertController(title: "You’re not logged into Savio", message: "Open the app and login or register before adding wish list items.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    //UITextfieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if (newLength > 4) {
            let fullNameArr = textField.text!.components(separatedBy: ".")
            print(fullNameArr)
            if ((fullNameArr[0].characters.count - 1) > 4 && string != ""){
                return false
            }
//            return false;
        }
        return true;
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        
        return numberOfChars < 40;
    }
    
    
    @IBAction func leftBtnPressed(_ sender: AnyObject) {
        currentImagePosition -= 1;
        if currentImagePosition < 0 {
            currentImagePosition += 1;
        } else {
            self.showImage(currentImagePosition)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(UIScreen.main.bounds.size.height == 480)
        {
            //UIViewAnimation for moving screen little bit up
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            self.view!.frame = CGRect(x: view!.frame.origin.x, y: (view!.frame.origin.y-30), width: view!.frame.size.width, height: view!.frame.size.height)
            UIView.commitAnimations()
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if(UIScreen.main.bounds.size.height == 480)
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            self.view!.frame = CGRect(x: view!.frame.origin.x, y: (view!.frame.origin.y+30), width: view!.frame.size.width, height: view!.frame.size.height)
            UIView.commitAnimations()
        }
        
        return true
    }
    
    @IBAction func rightButtonPressed(_ sender: AnyObject) {
        let imgString = self.dictGlobal["image"] as! String
        let arrayImgUrl:  Array? = imgString.components(separatedBy: "#~@")   // #~@ taken from ShareExtensio.js file
        currentImagePosition += 1;
        if currentImagePosition >= arrayImgUrl?.count {
            currentImagePosition -= 1
        }
        else {
            self.showImage(currentImagePosition)
        }
    }
    //UIView life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        for item: Any in (self.extensionContext?.inputItems)! {
            let inputItem = item as! NSExtensionItem
            for provider: Any in inputItem.attachments! {//group.com.mbf.savio
                let itemProvider = provider as! NSItemProvider
                let defaults: UserDefaults = UserDefaults(suiteName: "group.savio.web.share.extention")!
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { (result: NSSecureCoding?, error: NSError!) -> Void in
                        if let resultDict = result as? NSDictionary {
                            DispatchQueue.main.async(execute: {
                                self.dictGlobal = resultDict[NSExtensionJavaScriptPreprocessingResultsKey] as! [String : AnyObject]
                                print(self.dictGlobal)
                                print("URL = \(self.dictGlobal["url"])")
                                defaults.set(self.dictGlobal, forKey: "ScrapingResult")
                                let str = self.dictGlobal["title"] as! String
                                var subStr = str
                                if str.characters.count > 40 {
                                    subStr = str[str.characters.index(str.startIndex, offsetBy: 0)...str.characters.index(str.startIndex, offsetBy: 40 - 1)]
                                }
                                self.textView.text = subStr//self.dictGlobal["title"] as! String
                                self.priceTextField.text = self.dictGlobal["price"] as? String
                            });
                            self.showImage(self.currentImagePosition)
                            
                        }
                        else {
                            print("no dictionary found")
                        }
                    } as! NSItemProvider.CompletionHandler)
                }
                else{
                   self.dictGlobal = defaults.value(forKey: "ScrapingResult") as! Dictionary<String,AnyObject>
                    DispatchQueue.main.async(execute: {
                        self.textView.text = self.dictGlobal["title"] as! String
                        self.priceTextField.text = self.dictGlobal["price"] as? String
                    });
                    self.showImage(self.currentImagePosition)
                }
            }
        }
        
        var customToolBar : UIToolbar?
        customToolBar = UIToolbar(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action:#selector(ShareViewController.doneBarButtonPressed))
        customToolBar!.items = [acceptButton]
        
        bgView.layer.cornerRadius = 5
        bgView.layer.borderColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1).cgColor
         bgView.layer.borderWidth = 2.0
        bgView.layer.masksToBounds = true
        priceTextField.inputAccessoryView = customToolBar
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    func doneBarButtonPressed() {
        priceTextField.resignFirstResponder()
        if(UIScreen.main.bounds.size.height == 480)
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(true)
            self.view!.frame = CGRect(x: view!.frame.origin.x, y: (view!.frame.origin.y+30), width: view!.frame.size.width, height: view!.frame.size.height)
            UIView.commitAnimations()
        }
        
        if((priceTextField.text! as NSString).floatValue > 3000)
        {
            let alert = UIAlertController(title: "Whoa!", message: "The maximum you can top up is £3000", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showImage(_ idx: Int)  {
        DispatchQueue.main.async(execute: {
            let imgString = self.dictGlobal["image"] as! String
            let arrayImgUrl:  Array? = imgString.components(separatedBy: "#~@")   // #~@ taken from ShareExtensio.js file
            
            var imgURLString: String? = arrayImgUrl![idx] as String
            imgURLString = imgURLString?.replacingOccurrences(of: "'", with: "")
            let imgURL: URL? = URL.init(string: imgURLString!)
            let imgData:  Data? = try? Data.init(contentsOf: imgURL!)
            if imgData != nil {
                self.imageView.image = UIImage(data: imgData!)
            }
            self.lblImagePagingCount.text = String(format: "%d / %d", arguments:[idx+1, (arrayImgUrl?.count)!])
        });
    }
    
    func successResponseForShareExtensionAPI(_ objResponse: Dictionary<String, AnyObject>) {
        spinner.stopAnimating()
        spinner.isHidden = true
        isWebserviceCall = false
        print(objResponse)
        let alert = UIAlertController(title: "We've added this product to your wish list.", message: "Open the Savio app to start your saving plan.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
        { action -> Void in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            
            })
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorResponseForShareExtensionAPI(_ error: String) {
        spinner.stopAnimating()
        spinner.isHidden = true
        isWebserviceCall = false
        if(error == "No network found")
        {
            let alert = UIAlertController(title: "Connection problem", message: "Savio needs the internet to Save wish list items. Check your data connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            { action -> Void in
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                })
            self.present(alert, animated: true, completion: nil)
        }else {
            let alert = UIAlertController(title: "Warning", message: error, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            { action -> Void in
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                })
            self.present(alert, animated: true, completion: nil)

        }
       
    }
}
