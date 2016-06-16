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

class ShareViewController: UIViewController,UITextFieldDelegate,ShareExtensionDelegate {
    
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet var lblImagePagingCount: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var bgView: UIView!
    var spinner =  UIActivityIndicatorView()
    var currentImagePosition: Int = 0;
    var dictGlobal: Dictionary = [String: AnyObject]()
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
    }
    
    @IBAction func postButtonTapped(sender: AnyObject) {
        priceTextField.resignFirstResponder()
        let objAPI = API()
        
        self.spinner.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, 200)
        self.spinner.hidesWhenStopped = true
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(self.spinner)
        self.spinner.startAnimating()
        
        
        let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.com.mbf.savio")!
 

        let data = defaults.valueForKey("myPasscode") as! NSData

        
        if((NSKeyedUnarchiver.unarchiveObjectWithData(data) as! String) == "")
        {
            let alert = UIAlertController(title: "Warning", message: "Please login to Savio first", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
            { action -> Void in
                self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
                
                })
            
            self.presentViewController(alert, animated: true, completion: nil)
            //self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
        }
        else
        {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let imageData:NSData = UIImageJPEGRepresentation(self.imageView.image!, 1.0)!
                let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                let data = defaults.valueForKey("userInfo") as! NSData
                let userDict = NSKeyedUnarchiver.unarchiveObjectWithData(data)
                var dict : Dictionary<String,AnyObject> = [:]
                dict["title"] = self.textView.text
                dict["amount"] = self.priceTextField.text
                dict["pty_id"] = userDict!["partyId"]
                dict["imageURL"] = base64String
                objAPI.shareExtensionDelegate = self
                objAPI.sendWishList(dict)
                
            });
            
        }
        
        
    }
    
    //UITextfieldDelegate method
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if (newLength > 4) {
            return false;
        }
        return true;
    }
    
    @IBAction func leftBtnPressed(sender: AnyObject) {
        currentImagePosition -= 1;
        if currentImagePosition < 0 {
            currentImagePosition += 1;
        } else {
            self.showImage(currentImagePosition)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
//        if((priceTextField.text! as NSString).floatValue > 3000)
//        {
// 
//            let alert = UIAlertController(title: "Warning", message: "Please enter cost less than £ 3000", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default))
//
//            self.presentViewController(alert, animated: true, completion: nil)
//
//        }
        return textField.resignFirstResponder()
    }
    
    @IBAction func rightButtonPressed(sender: AnyObject) {
        let imgString = self.dictGlobal["image"] as! String
        let arrayImgUrl:  Array? = imgString.componentsSeparatedByString("#~@")   // #~@ taken from ShareExtensio.js file
        currentImagePosition += 1;
        if currentImagePosition >= arrayImgUrl?.count {
            currentImagePosition -= 1
        }
        else
        {
            self.showImage(currentImagePosition)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.bgView.layer.borderColor = UIColor.grayColor().CGColor
        self.bgView.layer.borderWidth = 2.0
        self.bgView.layer.cornerRadius = 5.0
        for item: AnyObject in (self.extensionContext?.inputItems)! {
            let inputItem = item as! NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as String, options: nil, completionHandler: { (result: NSSecureCoding?, error: NSError!) -> Void in
                        if let resultDict = result as? NSDictionary {
                            print(resultDict)
                            dispatch_async(dispatch_get_main_queue(), {
                                self.dictGlobal = resultDict[NSExtensionJavaScriptPreprocessingResultsKey] as! [String : AnyObject]
                                self.textView.text = self.dictGlobal["title"] as! String
                            });
                            self.showImage(self.currentImagePosition)
                            
                        }
                    })
                }
            }
        }
        
        var customToolBar : UIToolbar?
        customToolBar = UIToolbar(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,44))
        let acceptButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action:Selector("doneBarButtonPressed"))
        
        customToolBar!.items = [acceptButton]
        
        priceTextField.inputAccessoryView = customToolBar
        
    }
    
    
    func doneBarButtonPressed() {
        priceTextField.resignFirstResponder()
    }
    
    func showImage(idx: Int)  {
        dispatch_async(dispatch_get_main_queue(), {
            let imgString = self.dictGlobal["image"] as! String
            let arrayImgUrl:  Array? = imgString.componentsSeparatedByString("#~@")   // #~@ taken from ShareExtensio.js file
            
            var imgURLString: String? = arrayImgUrl![idx] as String
            imgURLString = imgURLString?.stringByReplacingOccurrencesOfString("'", withString: "")
            
            let imgURL: NSURL? = NSURL.init(string: imgURLString!)
            
            let imgData:  NSData? = NSData.init(contentsOfURL: imgURL!)
            
            if imgData != nil {
                self.imageView.image = UIImage(data: imgData!)
                
            }
            
            self.lblImagePagingCount.text = String(format: "%d / %d", arguments:[idx+1, (arrayImgUrl?.count)!])
            
        });
    }
    
    func successResponseForResetPasscodeAPI(objResponse: Dictionary<String, AnyObject>) {
        
        spinner.stopAnimating()
        spinner.hidden = true
        
        let alert = UIAlertController(title: "Success", message: "Item successfully added to wishlist", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
        { action -> Void in
            self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
            
            })
        
        self.presentViewController(alert, animated: true, completion: nil)
        //
    }
    
    func errorResponseForOTPResetPasscodeAPI(error: String) {
        //        dispatch_async(dispatch_get_main_queue()){
        spinner.stopAnimating()
        spinner.hidden = true
        //  }
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
        { action -> Void in
            self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
            
            })
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
