//
//  InviteFriendsButtonTableViewCell.swift
//  Savio
//
//  Created by Maheshwari on 22/06/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class InviteFriendsButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var BGContentView: UIView!
    @IBOutlet weak var bottomBorderLabel: UILabel!
    @IBOutlet weak var orginisersLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    var userInfodict : Dictionary<String, AnyObject> = [:]
    override func awakeFromNib() {
        super.awakeFromNib()
        let objAPI = API()
        //************************************* cornerradious start
        let costpath = UIBezierPath(roundedRect:BGContentView.bounds, byRoundingCorners:[.topRight, .topLeft], cornerRadii: CGSize(width: 05,height: 05))
        let costmaskLayer = CAShapeLayer()
        costmaskLayer.path = costpath.cgPath
        BGContentView.layer.mask = costmaskLayer
        //************************************* cornerradious end
        let userInfodict = UserDefaults.standard.object(forKey: kUserInfo) as! Dictionary<String,AnyObject>
//        let userInfodict = objAPI.getValueFromKeychainOfKey("userInfo") as! Dictionary<String,AnyObject>
        let attributedString = NSMutableAttributedString(string: String(format: "%@ (organiser)",userInfodict["first_name"] as! String))
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                     value: UIColor.white,
                                     range: NSRange(
                                        location:0,
                                        length:(userInfodict["first_name"] as! String).characters.count))
        
        attributedString.addAttribute(NSForegroundColorAttributeName,
        value: UIColor(red: 161/255,green:214/255,blue:248/255,alpha:1),
        range: NSRange(
        location:(userInfodict["first_name"] as! String).characters.count,
        length:12))
        orginisersLabel.attributedText = attributedString
        self.addShadowView()
    }
    func addShadowView(){
        inviteButton?.layer.cornerRadius = 5.0
        inviteButton!.layer.masksToBounds = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
