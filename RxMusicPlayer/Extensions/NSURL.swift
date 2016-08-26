//
//  NSURL.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/26/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import Foundation

extension NSURL {
    class func qiniuImageCenter(link: NSString, _ width: Int, _ height: Int) -> NSURL {
        var url = ""
        if height == 0 {
            url = String.init(format: "%@?imageView2/2/w/%d/", link, width)
        } else {
            url = String.init(format: "%@?imageView/1/w/%f/h/%d", link, width, height)
        }
        return NSURL(string: url)!
    }
}