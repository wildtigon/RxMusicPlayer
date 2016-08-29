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

    private var music: RxMusic

    var musicId: BehaviorSubject<Int>
    var name: BehaviorSubject<String>
    var artistName: BehaviorSubject<String>
    var fileName: BehaviorSubject<String>
    var cover: BehaviorSubject<String>

    var isPlaying: BehaviorSubject<Bool>
    var isFavorite: BehaviorSubject<Bool>

    init(_ music: RxMusic) {
        self.music = music
        musicId = BehaviorSubject<Int>(value: music.musicId)
        name = BehaviorSubject<String>(value: music.name)
        artistName = BehaviorSubject<String>(value: music.artistName)
        fileName = BehaviorSubject<String>(value: music.fileName)
        cover = BehaviorSubject<String>(value: music.cover)
        isPlaying = BehaviorSubject<Bool>(value: music.isPlaying)
        isFavorite = BehaviorSubject<Bool>(value: music.isFavorite)

        artistName
            .subscribeNext { self.music.artistName = $0 }
            .addDisposableTo(disposeBag)

        fileName
            .subscribeNext { self.music.fileName = $0 }
            .addDisposableTo(disposeBag)

        cover
            .subscribeNext { self.music.cover = $0 }
            .addDisposableTo(disposeBag)

        name
            .subscribeNext { self.music.name = $0 }
            .addDisposableTo(disposeBag)

        musicId
            .subscribeNext { self.music.musicId = $0 }
            .addDisposableTo(disposeBag)

        isPlaying
            .subscribeNext { self.music.isPlaying = $0 }
            .addDisposableTo(disposeBag)

        isFavorite
            .subscribeNext { self.music.isFavorite = $0 }
            .addDisposableTo(disposeBag)
    }
}
