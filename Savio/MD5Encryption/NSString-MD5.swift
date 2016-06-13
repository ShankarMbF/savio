//
//  NSString-MD5.swift
//  AESDemo
//
//  Created by Maheshwari on 17/05/16.
//  Copyright © 2016 Maheshwari. All rights reserved.
//

import UIKit

//extension of NSString to create encryption
extension String {
    func MD5() -> String {
        var pointer = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &pointer)
        }
        
        var str = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            str += String(format: "%02x", pointer[index])
        }
        str = String(format:"%@",str)
        
        return str
    }
}
