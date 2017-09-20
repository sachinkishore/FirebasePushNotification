//
//  PushNotification.swift
//  DemoPushNotification
//
//  Created by kishore on 19/09/17.
//  Copyright © 2017 Innotical. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseInstanceID
import FirebaseMessaging
import UserNotifications



extension AppDelegate : FIRMessagingDelegate,UNUserNotificationCenterDelegate{
    
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerUnLocalNotification()
        FIRApp.configure()
        FIRMessaging.messaging().remoteMessageDelegate = self
        application.registerForRemoteNotifications()
        
        if FIRInstanceID.instanceID().token() == nil{
        self.perform(#selector(getFcmToken), with: nil, afterDelay: 0.5)
        }
        return true
    }

    func messaging(_ messaging: FIRMessaging, didRefreshRegistrationToken fcmToken: String) {
        SaveToDefaults().setFcmToken(token: fcmToken)
        if let token = SaveToDefaults().getFcmToken(){
            hitPushNotificationSubcribeApi(token: token)
        }
        }
    
    func getFcmToken(){
        if let token = FIRInstanceID.instanceID().token(){
            SaveToDefaults().setFcmToken(token: token)
           hitPushNotificationSubcribeApi(token: token)
        }
    
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
        print("didReceiveRemoteNotificationuserInfo")
    }
    
    
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage){
        print("applicationReceivedRemoteMessage")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //handling of screen in different States
        
        if application.applicationState == .background{
           
        
        }
        else if application.applicationState == .active{
            
        }
        else{
           
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    func registerUnLocalNotification(){
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
                if !accepted {
                    print("Notification access denied.")
                }
            }
        } else {
            let notificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.sound, UIUserNotificationType.alert, UIUserNotificationType.badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        }
        
        if #available(iOS 10.0, *) {
            let action = UNNotificationAction(identifier: "First", title: "Snooze", options: [])
            let category = UNNotificationCategory(identifier: "First", actions: [action], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
        } else {
            // Fallback on earlier versions
        }
        
    }

    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            SaveToDefaults().setFcmToken(token:refreshedToken)
            if let token = SaveToDefaults().getFcmToken(){
              hitPushNotificationSubcribeApi(token: token)
            }
            
        }
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .sandbox)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .prod)
        
     }
    
    func hitPushNotificationSubcribeApi(token : String){
        let url = pushNotificationSuscribeUrl()
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        print(deviceId ?? "Nildevicd")
        let param : [String : Any] =
            ["sub_id" : token,
             "device_id" : deviceId ?? "",
             "app_id" : "0HhblVA564hCUd6k2cSkhOmlDHEE2Q2Cs05DSRLvmkg=",
             "device_type" : "ios",
             "city" :  "",
             "state" : "",
             "country" : ""]
        
        print(param)
        api_manager.POSTApi(url, param: param, header: nil, completion: { (response, error, statusCode) in
            print(response ?? "NilResponse")
            if let json = response{
                let sid = json["sid"].intValue
                SaveToDefaults().setSID(sid: sid)
            }
        })
    }

     //MARK: hitWhen user LogOut
    func hitPushNotificationUnsubscribeApi(){
        let url = pushNotificationUnSuscribeUrl()
        let param : [String : Any] = ["sid" : SaveToDefaults().getSID() ?? ""]
        print(param)
        api_manager.POSTApi(url, param: param, header: nil, completion: { (reponse, error, statuscode) in
            print(reponse ?? "nil")
        })
    }
    
     //MARK: url for the Notification
    func pushNotificationSuscribeUrl()->String{
        var url = "http://apipush.sia.co.in/api/push/token/v/subscribe/"
        url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        print("pushNotificationSuscribeUrl : \(url)")
        return url
    }
    
    func pushNotificationUnSuscribeUrl()->String{
        var url = "http://apipush.sia.co.in/api/notify/v/unsubscribe/"
        url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        print("pushNotificationUnSuscribeUrl : \(url)")
        return url
    }
}


struct SaveToDefaults {
    
    func setSID(sid : Int?) {
        defaults.set(sid, forKey: "sid")
    }
    func getSID()->Int?{
        return defaults.value(forKey: "sid") as? Int
    }
    func setFcmToken(token : String?) {
        defaults.set(token, forKey: "fcm")
    }
    func getFcmToken()->String?{
        return defaults.value(forKey: "fcm") as? String
    }
}
