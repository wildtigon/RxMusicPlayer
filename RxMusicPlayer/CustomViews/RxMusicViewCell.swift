//
//  RxMusicViewCell.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import NAKPlaybackIndicatorView
import RxSwift
import RxCocoa

class RxMusicViewCell: UITableViewCell {
    @IBOutlet weak var musicIndicator: NAKPlaybackIndicatorView!

    @IBOutlet weak var musicNumberLabel: UILabel!
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet weak var musicArtistLabel: UILabel!
    @IBOutlet weak var musicFavoriteLabel: UIButton!

    let disposeBag = DisposeBag()

    var musicInfo: RxMusicViewModel? {
        didSet {
            guard let data = musicInfo else { return }

            data.name
                .bindTo(musicTitleLabel.rx_text)
                .addDisposableTo(disposeBag)

            data.artistName
                .bindTo(musicArtistLabel.rx_text)
                .addDisposableTo(disposeBag)

            data.musicId
                .map { "\($0)" }
                .bindTo(musicTitleLabel.rx_text)
                .addDisposableTo(disposeBag)

            data.isPlaying
                .map { $0 ? .Playing : .Paused }
                .subscribeNext { self.musicIndicator.state = $0 }
                .addDisposableTo(disposeBag)

            data.isFavorite
                .bindTo(musicFavoriteLabel.rx_selected)
                .addDisposableTo(disposeBag)

            data.isPlaying
                .subscribeNext { "reset state: \($0)" }
                .addDisposableTo(disposeBag)
        }
    }
}
