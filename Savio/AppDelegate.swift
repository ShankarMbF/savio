//
//  AppDelegate.swift
//  Savio
//
//  Created by Prashant on 16/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//savio123 - exposrt certificate P12 CertificatesAPNS

import UIKit
import Fabric
import Crashlytics

struct Device {
    static var udid = UIDevice.currentDevice().identifierForVendor!.UUIDString
}

@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {
    

    var window: UIWindow?
    var objSANav: UINavigationController?
    var objSAWelcomViewController: SAWelcomViewController?
    var objEnterYourPinViewController: SAEnterYourPINViewController?
    var objRegisterViewController: SARegistrationViewController?
    var objCreateViewController: CreatePINViewController?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        registerForPushNotifications(application)
        
        // Check if launched from notification
        // 1
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
           // Do the stuff after geting Notification when app is not running mode
        }
        
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
         //   window = UIWindow(frame:CGRect(x: 0, y: 20, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height))
   

        self.setStatusBarBackgroundColor(UIColor.blackColor())
         UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        //Check if keychain has encrypted pin value
        let objApi = API()
        //        objApi.deleteKeychainValue("myPasscode")
        //       objApi.deleteKeychainValue("myUserInfo")
        //        objApi.deleteKeychainValue("userInfo")
      
        //  if let passcode = objApi.getValueFromKeychainOfKey("myPasscode") as? String
   
        if let passcode = objApi.getValueFromKeychainOfKey("myPasscode") as? String
        {
            if let userInfoDict = objApi.getValueFromKeychainOfKey("userInfo") as? Dictionary<String,AnyObject>
            {
                print(userInfoDict)
                let udidDict = userInfoDict["deviceRegistration"] as! Array<Dictionary<String,AnyObject>>
                print(udidDict)
                print(Device.udid)
                
                let udidArray = udidDict[0]
                
                if(udidArray["DEVICE_ID"] as! String  == Device.udid)
                {
                    //else Go to SAEnterYourPINViewController
                    objEnterYourPinViewController = SAEnterYourPINViewController()
                    //Set SAEnterYourPINViewController as rootViewController of UINavigationViewController
                    objSANav = UINavigationController(rootViewController: objEnterYourPinViewController!)
                    window?.rootViewController = objSANav
                }
                else{
                    //If no then Go to SAWelcomViewController
                    objSAWelcomViewController = SAWelcomViewController()
                    //Set SAWelcomViewController as rootViewController of UINavigationViewController
                    objSANav = UINavigationController(rootViewController: objSAWelcomViewController!)
                    window?.rootViewController = objSANav
                }
            }
            else
            {
                //If no then Go to SAWelcomViewController
                objSAWelcomViewController = SAWelcomViewController()
                //Set SAWelcomViewController as rootViewController of UINavigationViewController
                objSANav = UINavigationController(rootViewController: objSAWelcomViewController!)
                window?.rootViewController = objSANav
            }
        }
        else{
            //If no then Go to SAWelcomViewController
            objSAWelcomViewController = SAWelcomViewController()
            //Set SAWelcomViewController as rootViewController of UINavigationViewController
            objSANav = UINavigationController(rootViewController: objSAWelcomViewController!)
            window?.rootViewController = objSANav
            
        }
        objSANav!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "GothamRounded-Medium", size: 20)!]
        objSANav?.navigationBarHidden = true
      
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        
        guard  let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView else {
            return
        }
        
        statusBar.backgroundColor = color
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
        
        NSUserDefaults.standardUserDefaults().setObject(tokenString, forKey: "APNSTOKEN")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    
    // MARK: Handle notifications
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        // 1
        if let contentAvaiable = aps["content-available"] as? NSString where contentAvaiable.integerValue == 1 {
            // Refresh App with new Content
            // 2

        } else  {
            //
            // 4
        }
    }
    
}

