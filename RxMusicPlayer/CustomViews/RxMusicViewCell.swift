//
//  RxMusicViewCell.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import NAKPlaybackIndicatorView

class RxMusicViewCell: UITableViewCell {
    @IBOutlet weak var musicIndicator: NAKPlaybackIndicatorView!

    @IBOutlet weak var musicNumberLabel: UILabel!
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet weak var musicArtistLabel: UILabel!

    internal func setData(data: RxMusic) {
        musicTitleLabel.text = data.name
        musicArtistLabel.text = data.artistName
        musicNumberLabel.text = "\(data.musicId)"
    }
}
