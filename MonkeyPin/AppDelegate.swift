//
//  AppDelegate.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 3/18/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var retainedGameScene:MPGameScene?
    
    override static func initialize(){
        NSUserDefaults.standardUserDefaults().registerDefaults(["MP_GAME_DIFFICULTY_DEFAULTS_KEY" : 1, "MP_AUDIO_ON_DEFAULTS_KEY" : 1])
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize Parse.
        let configuration = ParseClientConfiguration {
            $0.applicationId = "com.hooapps.alexramey.spring2016.MonkeyPin"
            $0.server = "http://ec2-52-87-160-169.compute-1.amazonaws.com:1337/parse"
            $0.clientKey = "165739A5-027A-4200-8E24-DC4831380A3A"
        }
        Parse.initializeWithConfiguration(configuration)
        return true
    }
    
    func retainGameScene(scene: MPGameScene){
        self.retainedGameScene = scene
    }
    
    func releaseGameScene(){
        self.retainedGameScene = nil
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
}

