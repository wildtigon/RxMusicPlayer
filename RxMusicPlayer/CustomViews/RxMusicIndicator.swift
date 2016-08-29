//
//  RxMusicIndicator.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import NAKPlaybackIndicatorView

class RxMusicIndicator: NAKPlaybackIndicatorView {
    static let shareInstance = RxMusicIndicator()
    private init() {
        let frame = CGRectMake(Screen.WIDTH - 50, 0, 50, 44)
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
