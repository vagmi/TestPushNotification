//
//  AppDelegate.swift
//  TestPushNotification
//
//  Created by Vagmi Mudumbai on 18/06/16.
//  Copyright © 2016 Vagmi Mudumbai. All rights reserved.
//

import UIKit
import PubNub
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {

  var window: UIWindow?
  var client : PubNub?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    NSLog("\(launchOptions)")
    let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert,.Badge,.Sound], categories: nil)
    application.registerUserNotificationSettings(notificationSettings)
    application.registerForRemoteNotifications()
    return true
  }
  func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
    print(message)
  }
  func client(client: PubNub, didReceiveStatus status: PNStatus) {
    print(status)
  }
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    
    let pnConfig = PNConfiguration(publishKey: "pub-c-80373d88-709b-4207-942e-fc3b542c55ba", subscribeKey: "sub-c-5ac5f118-355e-11e6-b8b0-0619f8945a4f")
    self.client = PubNub.clientWithConfiguration(pnConfig)
    if let oldKey = NSUserDefaults.standardUserDefaults().dataForKey("DEVICE_TOKEN") {
      if !oldKey.isEqualToData(deviceToken) {
        self.client?.removePushNotificationsFromChannels(["user1"], withDevicePushToken: oldKey) { print($0) }
        self.client?.addPushNotificationsOnChannels(["user1"], withDevicePushToken: deviceToken) { print($0) }
      }
    } else {
      self.client?.addPushNotificationsOnChannels(["user1"], withDevicePushToken: deviceToken) { print($0) }
    }
    client?.addListener(self)
    NSUserDefaults.standardUserDefaults().setObject(deviceToken, forKey: "DEVICE_TOKEN")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    print(userInfo)
  }

  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    NSLog("with fetch completion")
    NSLog("\(userInfo)")
    if let url = userInfo["url"] as? String {
      NSLog("fetching data for URL")
      Alamofire.request(.GET, url).responseJSON { response in
        NSLog("Response from request is ")
        switch(response.result) {
        case .Success(let val):
          NSLog("\(val)")
          let localNotification = UILocalNotification()
          localNotification.fireDate = NSDate()
          localNotification.userInfo = ["title": "from remote notification", "url": "some url"]
          localNotification.alertBody = "The is the alert body"
          localNotification.soundName = UILocalNotificationDefaultSoundName
          application.scheduleLocalNotification(localNotification)
          completionHandler(.NewData)
        case .Failure(let err):
          NSLog("\(err)")
          completionHandler(.Failed)
        }
      }
    }
    
  }
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    NSLog("received local notification")
    NSLog("\(notification)")
  }
  func applicationWillResignActive(application: UIApplication) {
  }

  func applicationDidEnterBackground(application: UIApplication) {
  }

  func applicationWillEnterForeground(application: UIApplication) {
  }

  func applicationDidBecomeActive(application: UIApplication) {
  }

  func applicationWillTerminate(application: UIApplication) {  }


}

