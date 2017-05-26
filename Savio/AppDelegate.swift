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
import UserNotifications
import Stripe

struct Device {
    static var udid = UIDevice.current.identifierForVendor!.uuidString
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var objSANav: UINavigationController?
    var objSAWelcomViewController: SAWelcomeViewController?
    var objEnterYourPinViewController: SAEnterYourPINViewController?
    var objRegisterViewController: SARegistrationScreenOneViewController?
    var objCreateViewController: CreatePINViewController?
    
    
    //Set up the window and UINavigationViewController
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Import the library for finding crashesr
         let objApi = API()
        
        Stripe.setDefaultPublishableKey(objApi.valueForAPIKey(named: kSTRIPEPUBLISHABLEKEY))
        Fabric.with([Crashlytics.self])
        Fabric.with([STPAPIClient.self])
        
        STPPaymentConfiguration.shared().smsAutofillDisabled = true
        
        let notificationTypes: UIUserNotificationType = [.badge, .sound, .alert]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        
        // Check if launched from notification
        let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject]
        if notification != nil {
            // Do the stuff after geting Notification when app is not running mode
        }
        
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        //Set the status bar color
        self.setStatusBarBackgroundColor(UIColor.black)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
        let passcode = userDefaults.value(forKey: "myPasscode") as? String
        
        if (passcode?.characters.count)! > 0{
            //Go to SAEnterYourPINViewController
            objEnterYourPinViewController = SAEnterYourPINViewController()
            //Set SAEnterYourPINViewController as rootViewController of UINavigationViewController
            objSANav = UINavigationController(rootViewController: objEnterYourPinViewController!)
            window?.rootViewController = objSANav
        }else{
            //If no then Go to SAWelcomViewController
            objSAWelcomViewController = SAWelcomeViewController()
            //Set SAWelcomViewController as rootViewController of UINavigationViewController
            objSANav = UINavigationController(rootViewController: objSAWelcomViewController!)
            window?.rootViewController = objSANav
        }
        
     /*
        //Check if keychain has encrypted pin value.
        let objApi = API()
//        objApi.deleteKeychainValue("savingPlanDict")
//        objApi.deleteKeychainValue("saveCardArray")
        //Check if passcode is stored into keychain.
        if let passcode = objApi.getValueFromKeychainOfKey("myPasscode") as? String
        {
            //If passcode is empty go to SARegistrationViewController.
            if(passcode != "")
            {
                //Check if userInfo is stored into keychain.
                if let userInfoDict = objApi.getValueFromKeychainOfKey("userInfo") as? Dictionary<String,AnyObject>
                {
                    let udidDict = userInfoDict["deviceRegistration"] as! Array<Dictionary<String,AnyObject>>
                    let udidArray = udidDict[0]
                    print(udidDict)
                    //Check if current deviceID is present in keychain.
                    if(udidArray["DEVICE_ID"] as! String  == Device.udid)
                    {
                        //else Go to SAEnterYourPINViewController
                        objEnterYourPinViewController = SAEnterYourPINViewController()
                        //Set SAEnterYourPINViewController as rootViewController of UINavigationViewController
                        objSANav = UINavigationController(rootViewController: objEnterYourPinViewController!)
                        window?.rootViewController = objSANav
                    }
                    else {
                        //If no then Go to SAWelcomViewController
                        objSAWelcomViewController = SAWelcomeViewController()
                        //Set SAWelcomViewController as rootViewController of UINavigationViewController
                        objSANav = UINavigationController(rootViewController: objSAWelcomViewController!)
                        window?.rootViewController = objSANav
                    }
                }
                else {
                    //If no then Go to SAWelcomViewController
                    objSAWelcomViewController = SAWelcomeViewController()
                    //Set SAWelcomViewController as rootViewController of UINavigationViewController
                    objSANav = UINavigationController(rootViewController: objSAWelcomViewController!)
                    window?.rootViewController = objSANav
                }
            }
            else  {
                //If no then Go to SARegistrationScreenOneViewController
                objRegisterViewController = SARegistrationScreenOneViewController()
                //Set SAWelcomViewController as rootViewController of UINavigationViewController
                objSANav = UINavigationController(rootViewController: objRegisterViewController!)
                window?.rootViewController = objSANav
                
            }
        }
        else {

            //If no then Go to SAWelcomViewController
            objSAWelcomViewController = SAWelcomeViewController()
            //Set SAWelcomViewController as rootViewController of UINavigationViewController
            objSANav = UINavigationController(rootViewController: objSAWelcomViewController!)
            window?.rootViewController = objSANav
            
        }
        */
        //Customize the UINavigationBar
        objSANav!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "GothamRounded-Medium", size: 20)!]
        objSANav?.isNavigationBarHidden = true
        window?.makeKeyAndVisible()
        return true
    }
    
    //Set statusBarBackgrounColor
    func setStatusBarBackgroundColor(_ color: UIColor) {
        guard  let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView else {
            return
        }
        
        statusBar.backgroundColor = color
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //Register device for APNS.
    func registerForPushNotifications(_ application: UIApplication) {
        
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted)
                {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                else{
                    //Do stuff if unsuccessful...
                    print("not Successfully updated ......")
                }
            })
        }
            
        else{ //If user is not on iOS 10 use the old methods we've been using
            let notificationSettings = UIUserNotificationSettings(
                types: [.badge, .sound, .alert], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        }
        
    }
    
    //Delegate method to verfy if the user accepts or denys the APNS.
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        print(userInfo)
    }
    
    //Delegate method invoke when APNS is successfully registered, and provide deviceToken.
   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("DEVICE TOKEN = \(deviceToken)")

        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
         print(tokenString)
        userDefaults.set(tokenString, forKey: "APNSTOKEN")
        userDefaults.synchronize()
    }
    
    //Delegate method invoke when the APNS registration is failed
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    // MARK: Handle notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //--------------For Future Use---------------//
        /*
         let aps = userInfo["aps"] as! [String: AnyObject]
         if let contentAvaiable = aps["content-available"] as? NSString where contentAvaiable.integerValue == 1 {
         // Refresh App with new Content
         
         } else  {
         
         }
         */
        
        if ( application.applicationState == UIApplicationState.inactive || application.applicationState == UIApplicationState.background  )
        {
            //opened from a push notification when the app was on background
            var badgeCount = UIApplication.shared.applicationIconBadgeNumber
            badgeCount = badgeCount - 1
            UIApplication.shared.applicationIconBadgeNumber = badgeCount
        }
        if(application.applicationState == UIApplicationState.active) {
            let dict = userInfo["aps"] as! Dictionary<String,AnyObject>
            let apnsDict = dict["alert"]  as! Dictionary<String,AnyObject>
            //Show the view with the content of the push
            completionHandler(UIBackgroundFetchResult.newData);
            //Show notification in banner view
            TWMessageBarManager.sharedInstance().showMessage(withTitle: apnsDict[kTitle] as? String, description: apnsDict["body"] as? String, type: TWMessageBarMessageType.info)
            //Change apps badge count
            UIApplication.shared.applicationIconBadgeNumber = Int(dict["badge"] as! NSNumber)
            
        } else if (application.applicationState == UIApplicationState.background) {
            //Refresh the local model
            completionHandler(UIBackgroundFetchResult.newData);
            
        } else {
            //Show an in-app banner
            completionHandler(UIBackgroundFetchResult.newData);
        }
    }
}

