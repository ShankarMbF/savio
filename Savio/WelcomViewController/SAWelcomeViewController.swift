//
//  SAWelcomViewController.swift
//  Savio
//
//  Created by Prashant on 16/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit


class SAWelcomeViewController: UIViewController, NSURLSessionDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!      //IBOutlet for scrollview
    @IBOutlet weak var pageControl: UIPageControl!    //IBOutlet for pagination
    @IBOutlet weak var signUpBtn: UIButton!           //IBOutlet for signup button
    
    var timer: NSTimer?                               // variable for set delay time
    
    //flag holds the
    var idx: Int = 0
    //pageArr is an array which holds animation pages
    let pageArr: Array<String> = ["Page5", "Page1", "Page2", "Page3", "Page4"]
    var impText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide navigationbar
        self.callImportantAPI()
        self.navigationController?.navigationBarHidden = true

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Function invoke to configure scrollview for animating pages
        configureScrollView()
        //function invoke for set up page control with scrollview
        configurePageControl()
        //setting signup button corner
        signUpBtn.layer.cornerRadius = 5.0
        idx = 0
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        idx = 0
        self.change()
        timer?.invalidate()
        timer = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This function invoke when user tapping on sign up to savio button
    @IBAction func clickOnSignUpButton(sender:UIButton){
        //create instance of SARegistrationViewController
        let objSARegistarionViewController = SARegistrationScreenOneViewController(nibName:"SARegistrationScreenOneViewController",bundle: nil)
        //Navigate to registration screen
        self.navigationController?.pushViewController(objSARegistarionViewController, animated: true)
    }
    
    //Function invoking for configure the scrollview for page animation
    func configureScrollView() {
        // Enable paging.
        scrollView.pagingEnabled = true
        // Set the following flag values.
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        
        // Set the scrollview content size.
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * CGFloat(pageArr.count), scrollView.frame.size.height)
        
        // Load the PageView view from the TestView.xib file and configure it properly.
        for i in 0 ..< pageArr.count {
            // Load the TestView view.
            let testView = NSBundle.mainBundle().loadNibNamed("PageView", owner: self, options: nil)![0] as! UIView
            // Set its frame and the background color.
            testView.frame = CGRectMake(CGFloat(i) * scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height)
            // Set the proper message to the test view's label.
            let vw = testView.viewWithTag(1) as! UIImageView
            vw.image = UIImage(named: pageArr[i])
            // Add the test view as a subview to the scrollview.
            scrollView.addSubview(testView)
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(SAWelcomeViewController.change), userInfo: nil, repeats: true)
    }
    
    //Function invoking for configure the page control for animated pages
    func configurePageControl() {
        // Set the total pages to the page control.
        pageControl.numberOfPages = pageArr.count
        // Set the initial page.
        pageControl.currentPage = 0
    }
    
    
    // MARK: UIScrollViewDelegate method implementation
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
        
        // Set the new page index to the page control.
        pageControl.currentPage = Int(currentPage)
        idx = Int(currentPage)
        
        
    }
        
    //Function invoke for make animation on pages
    func change(){
        //flag set for showing animation or not
        var flag = true
        //Checkin last page appear, if appear then showing 1st page
        if(idx == 5){
            idx = 0
            flag = false
        }
        var newFrame = scrollView.frame
        //Set the new page index to the page control.
        pageControl.currentPage = idx
         // Calculate the frame that should scroll to based on the page control current page.
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl.currentPage)
        //Showing scrollview rect as per the page
        scrollView.scrollRectToVisible(newFrame, animated: flag)
        //set timer for showing animation
       
        idx += 1
    }
    
    
    // MARK: IBAction method implementation
    @IBAction func changePage(sender: AnyObject) {
        idx += 1
        self.change()
    }
    
    //Function invoke when user tap on important Information link
    @IBAction func clickOnImportantLink(sender:UIButton){
        let objImpInfo = NSBundle.mainBundle().loadNibNamed("ImportantInformationView", owner: self, options: nil)![0] as! ImportantInformationView
        objImpInfo.termsAndConditionTextView.text = impText
        objImpInfo.frame = self.view.frame
        objImpInfo.isFromRegistration = false
        self.view.addSubview(objImpInfo)
    }
    
    func callImportantAPI() {
        let objAPI = API()
        ////        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)![0] as! ImageViewAnimation)
        ////        objAnimView.frame = self.view.frame
        ////        objAnimView.animate()
        ////        self.view.addSubview(objAnimView)
        //        objAPI.termConditionDelegate = self
        //        objAPI.termAndCondition()
        
        
        
        
        let cookie = "e4913375-0c5e-4839-97eb-e9dde4a5c7ff"
        let partyID = "956"
        
        let utf8str = String(format: "%@:%@",partyID,cookie).dataUsingEncoding(NSUTF8StringEncoding)
        let base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        //Check if network is present
        if(objAPI.isConnectedToNetwork())
        {
            urlconfig.timeoutIntervalForRequest = 30
            urlconfig.timeoutIntervalForResource = 30
            let session = NSURLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            
            let request = NSMutableURLRequest(URL: NSURL(string: String(format:"%@/Content/11",baseURL))!)
            request.addValue(String(format: "Basic %@",base64Encoded!), forHTTPHeaderField: "Authorization")
            
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let data = data
                {
                    //                    print(response?.description)
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    if let dict = json as? Dictionary<String,AnyObject>
                    {
                        //                        print(dict)
                        dispatch_async(dispatch_get_main_queue())
                        {
                            if dict["errorCode"] as! String == "200"{
                                self.successResponseFortermAndConditionAPI(dict["content"] as! Dictionary)
                            }
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()){
                        }
                    }
                }
                else  if let error = error  {
                    dispatch_async(dispatch_get_main_queue()){
                    }
                    
                }
                
            }
            dataTask.resume()
        }
        else {
        }
    }
    
    func successResponseFortermAndConditionAPI(objResponse:Dictionary<String,AnyObject>){
        impText = objResponse["content"] as? String
    }
    
    func errorResponseFortermAndConditionAPI(error:String){
        
    }

}

  
