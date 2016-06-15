//
//  SAOfferListViewController.swift
//  Savio
//
//  Created by Prashant on 06/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

protocol SAOfferListViewDelegate {
    
    func addedOffers(offerForSaveDict:Dictionary<String,AnyObject>)
}

class SAOfferListViewController: UIViewController,GetOfferlistDelegate{
    var indx : Int = 0
    var  prevIndxArr: Array<Int> = []
    var rowHT : CGFloat = 310.0
    
    var  offerArr: Array<Dictionary<String,AnyObject>> = []

    
    @IBOutlet weak var tblView : UITableView?
    @IBOutlet weak var closeLbl : UILabel?
    
    var delegate : SAOfferListViewDelegate?
    
     var objAnimView = ImageViewAnimation()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView(){
        self.title = "Partner offers"
        
        //set Navigation left button
        let leftBtnName = UIButton()
        leftBtnName.setImage(UIImage(named: "nav-back.png"), forState: UIControlState.Normal)
        leftBtnName.frame = CGRectMake(0, 0, 30, 30)
        leftBtnName.addTarget(self, action: #selector(SAOfferListViewController.backButtonPress), forControlEvents: .TouchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBtnName
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        //set Navigation right button nav-heart
        let btnName = UIButton()
        btnName.setBackgroundImage(UIImage(named: "nav-heart.png"), forState: UIControlState.Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.titleLabel!.font = UIFont(name: "GothamRounded-Book", size: 12)
        btnName.setTitle("0", forState: UIControlState.Normal)
        btnName.setTitleColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1), forState: UIControlState.Normal)
        btnName.addTarget(self, action: #selector(SAOfferListViewController.heartBtnClicked), forControlEvents: .TouchUpInside)
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") != nil)
        {
            let wishListArray = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? Array<Dictionary<String,AnyObject>>
            btnName.setBackgroundImage(UIImage(named: "nav-heart-fill.png"), forState: UIControlState.Normal)
            
            btnName.setTitle(String(format:"%d",wishListArray!.count), forState: UIControlState.Normal)
           btnName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        }
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        closeLbl?.layer.cornerRadius = (closeLbl?.frame.size.width)!/2
        closeLbl?.layer.masksToBounds = false
        closeLbl?.layer.borderWidth = 2.0
        closeLbl?.layer.borderColor = UIColor.whiteColor().CGColor
        objAnimView = (NSBundle.mainBundle().loadNibNamed("ImageViewAnimation", owner: self, options: nil)[0] as! ImageViewAnimation)
        objAnimView.frame = self.view.frame
        objAnimView.animate()
        
        self.view.addSubview(objAnimView)
         let objAPI = API()
        objAPI.getofferlistDelegate = self
        objAPI.getOfferListForSavingId("1")
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
    func backButtonPress()  {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func heartBtnClicked(){
        
        if  (NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") != nil) {
            let wishListArray = NSUserDefaults.standardUserDefaults().objectForKey("wishlistArray") as? Array<Dictionary<String,AnyObject>>
            
            if wishListArray!.count>0{
                
                let objSAWishListViewController = SAWishListViewController()
                objSAWishListViewController.wishListArray = wishListArray!
                self.navigationController?.pushViewController(objSAWishListViewController, animated: true)
            }
            else{
                let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        else{
            let alert = UIAlertView(title: "Alert", message: "You have no items in your wishlist", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    // MARK: - Button Action
    @IBAction func clickedOnSkipOffersBtn(sender:UIButton){
        self.backButtonPress()
    }
    
    // MARK: - Tableview Delegate & Datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return offerArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        //        let cell = tableView.dequeueReusableCellWithIdentifier("SavingCategoryTableViewCell") as? SavingCategoryTableViewCell
        
        let bundleArr : Array = NSBundle.mainBundle().loadNibNamed("SAOfferListTableViewCell", owner: nil, options: nil) as Array
        let cell = bundleArr[0] as! SAOfferListTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.btnAddOffer?.addTarget(self, action: #selector(SAOfferListViewController.clickedOnAddOffer(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.btnAddOffer?.tag = indexPath.row
        cell.btnOfferDetail?.addTarget(self, action: #selector(SAOfferListViewController.clickedOnOfferDetail(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.btnOfferDetail?.tag = indexPath.row
        let cellDict = offerArr[indexPath.row]
        cell.lblOfferTitle?.text = cellDict["offCompanyName"] as? String
        cell.lblOfferDiscount?.text = cellDict["offTitle"] as? String
        cell.lblOfferSummary?.text = cellDict["offSummary"] as? String
        cell.lblProductOffer?.text = cellDict["offDesc"] as? String
        
        let urlStr = cellDict["offImage"] as! String
        let url = NSURL(string: urlStr)
        
        let request: NSURLRequest = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { ( response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
            let image = UIImage(data: data!)
            
            //                self.imageCache[unwrappedImage] = image
            dispatch_async(dispatch_get_main_queue(), {
                cell.offerImage?.image = image
            })
        })
        
        let attributes = [
            NSForegroundColorAttributeName :cell.setUpColor(),
            NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue
        ]
        var attributedString = NSAttributedString(string: "Offer details v", attributes: attributes)
        
        
        if prevIndxArr.count > 0 {
            var ht: CGFloat = 0.0
            var str = ""
            
            for var i in 0 ..< prevIndxArr.count {
                if prevIndxArr[i] == indexPath.row {
                    attributedString = NSAttributedString(string: "Offer details ^", attributes: attributes)
                    str = (cellDict["offDesc"] as? String)!
                    ht = self.heightForView(str, font: UIFont(name: "GothamRounded-Book", size: 10)!, width: (cell.lblProductOffer?.frame.size.width)! )
                }
                else{
                    str = ""
                    ht = 0.0
                }
                cell.lblHT.constant = ht
                cell.lblProductOffer?.text = str
            }
            
            
        }
        else{
            cell.lblHT.constant = 0.0
            cell.lblProductOffer?.text = ""
        }
        
        cell.btnOfferDetail?.setAttributedTitle(attributedString, forState: UIControlState.Normal)
        //        cell.lblHT.constant = 20.0
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if prevIndxArr.count > 0 {
            for var i in 0 ..< prevIndxArr.count {
                if prevIndxArr[i] == indexPath.row {
                    return rowHT + 310.0
                }
            }
        }
        return 310.0
    }
    
//    func clickedOnAddOffer(sender:UIButton) {
//        print(sender.tag)
//    }
    
    func clickedOnOfferDetail(sender:UIButton) {
        print(sender.tag)
        dispatch_async(dispatch_get_main_queue()){
        self.indx = sender.tag
        var isVisible = false
        if self.prevIndxArr.count > 0{
            for i in 0 ..< self.prevIndxArr.count {
               let obj = self.prevIndxArr[i] as Int
                if obj == sender.tag{
                  isVisible = true
                    self.prevIndxArr.removeAtIndex(i)
                    break
                }
            }
            if(isVisible == false){
                self.prevIndxArr.removeAll()
                self.prevIndxArr.append(sender.tag)
            }
        }
        else{
            self.prevIndxArr.append(sender.tag)
        }
        self.tblView?.reloadData()
        }
    }

    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        rowHT = label.frame.height
        return rowHT
    }

    func clickedOnAddOffer(sender: UIButton){
//        let offerTitle = obj.lblOfferTitle?.text
//        let  offerDiscount = obj.lblOfferDiscount?.text
//        let offerSummary = obj.lblOfferSummary?.text
//        print(offerTitle)
//        print(offerDiscount)
//        print(offerSummary)
//        let  dict = ["offerTitle":offerTitle,"offerDiscount":offerDiscount,]
        
         let cellDict = offerArr[sender.tag]
//        let arr : Array<Dictionary<String,AnyObject>> = [cellDict]
        delegate?.addedOffers(cellDict)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func successResponseForGetOfferlistAPI(objResponse:Dictionary<String,AnyObject>){
        print(objResponse)
        objAnimView.removeFromSuperview()
        if offerArr.count > 0 {
            offerArr.removeAll()
        }
        offerArr = objResponse["offers"] as! Array<Dictionary<String,AnyObject>>
        tblView?.reloadData()
        
    }
    func errorResponseForGetOfferlistAPI(error:String){
        objAnimView.removeFromSuperview()
    }
    
}
