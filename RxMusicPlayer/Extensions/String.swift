//
//  String.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/26/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import Foundation

extension String {
    static func timeIntervalToMMSSFormat(interval: NSTimeInterval) -> String {
        let ti = Int(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        return String(format: "%02ld:%02ld", Int(minutes), Int(seconds))
    }
}