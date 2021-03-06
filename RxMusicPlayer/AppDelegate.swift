//
//  AppDelegate.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var musicVC: RxMusicListViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Firebase
        FIRApp.configure()

        // Remote controls
        UIApplication
            .sharedApplication()
            .beginReceivingRemoteControlEvents()

        becomeFirstResponder()
        return true
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        guard let event = event else { return }

        if event.type == .RemoteControl {
            switch event.subtype {
            case .RemoteControlPlay:
                RxMusicDetailViewController.sharedInstance().streamer.play()
            case .RemoteControlPause:
                RxMusicDetailViewController.sharedInstance().streamer.pause()
            case .RemoteControlStop:
                RxMusicDetailViewController.sharedInstance().streamer.stop()
            case .RemoteControlNextTrack:
                RxMusicDetailViewController.sharedInstance().playNextMusic()
            case .RemoteControlPreviousTrack:
                RxMusicDetailViewController.sharedInstance().playPreviousMusic()
            case .RemoteControlBeginSeekingBackward:
                break
            case .RemoteControlEndSeekingBackward:
                break
            case .RemoteControlBeginSeekingForward:
                break
            case .RemoteControlEndSeekingForward:
                break
            default:
                break
            }
        }
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

