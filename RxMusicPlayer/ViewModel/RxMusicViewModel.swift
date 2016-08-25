//
//  RxMusicViewModel.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RxMusicViewModel {
    private let disposeBag = DisposeBag()

    var music: RxMusic

    var musicId: BehaviorSubject<Int>
    var name: BehaviorSubject<String>
    var artistName: BehaviorSubject<String>

    init(_ music: RxMusic) {
        self.music = music
        musicId = BehaviorSubject<Int>(value: music.musicId)
        name = BehaviorSubject<String>(value: music.name)
        artistName = BehaviorSubject<String>(value: music.artistName)

        artistName
            .subscribeNext { self.music.artistName = $0 }
            .addDisposableTo(disposeBag)

        name
            .subscribeNext { self.music.name = $0 }
            .addDisposableTo(disposeBag)

        musicId
            .subscribeNext { self.music.musicId = $0 }
            .addDisposableTo(disposeBag)

    }

}
