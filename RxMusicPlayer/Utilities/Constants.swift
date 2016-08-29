//
//  Constants.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit

class Constants {
    let musicURL = "http://www.mocky.io/v2/57be9fe40f00004c05a6a636"
}

// get ratio screen
struct RATIO {
    static let SCREEN_WIDTH = (DeviceType.IPHONE_4_OR_LESS ? 1.0 : Screen.WIDTH / 375.0)
    static let SCREEN_HEIGHT = (DeviceType.IPHONE_4_OR_LESS ? 1.0 : Screen.HEIGHT / 667.0)
    static let SCREEN = ((RATIO.SCREEN_WIDTH + RATIO.SCREEN_HEIGHT) / 2.0)
}

// get scale screen
struct ScaleValue {
    static let SCREEN_WIDTH = (DeviceType.IPAD ? 1.8 : (DeviceType.IPHONE_6 ? 1.174 : (DeviceType.IPHONE_6P ? 1.295 : 1.0)))
    static let SCREEN_HEIGHT = (DeviceType.IPAD ? 2.4 : (DeviceType.IPHONE_6 ? 1.171 : (DeviceType.IPHONE_6P ? 1.293 : 1.0)))
    // static let FONT                 = (DeviceType.IPAD ? 1.5 : (DeviceType.IPHONE_6P ? 1.27 : (DeviceType.IPHONE_6 ? 1.15 : 1.0)))
    static let FONT = (DeviceType.IPAD ? 1.0 : (DeviceType.IPHONE_6P ? 1.27 : (DeviceType.IPHONE_6 ? 1.15 : 1.0)))
}

// get screen size
struct Screen {
    static let BOUNDS = UIScreen.mainScreen().bounds
    static let WIDTH = UIScreen.mainScreen().bounds.size.width
    static let HEIGHT = UIScreen.mainScreen().bounds.size.height
    static let MAX = max(Screen.WIDTH, Screen.HEIGHT)
    static let MIN = min(Screen.WIDTH, Screen.HEIGHT)
}

// get device type
struct DeviceType {
    static let IPHONE_4_OR_LESS = UIDevice.currentDevice().userInterfaceIdiom == .Phone && Screen.MAX < 568.0
    static let IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && Screen.MAX == 568.0
    static let IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && Screen.MAX == 667.0
    static let IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && Screen.MAX == 736.0
    static let IPAD = UIDevice.currentDevice().userInterfaceIdiom == .Pad && Screen.MAX == 1024.0
}
