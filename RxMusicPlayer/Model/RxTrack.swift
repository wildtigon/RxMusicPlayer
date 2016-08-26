//
//  RxTrack.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/26/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import Foundation
import DOUAudioStreamer

class RxTrack: NSObject, DOUAudioFile {
    var artist = ""
    var title = ""
    var url: NSURL!

    func audioFileURL() -> NSURL! {
        return url
    }
}
