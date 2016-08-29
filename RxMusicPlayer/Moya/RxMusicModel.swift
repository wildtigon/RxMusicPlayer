//
//  RxMusicModel.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import RxSwift
import Moya
import Moya_ObjectMapper

struct RxMusicModel {
    static let shareInstance = RxMusicModel()
    var provider: RxMoyaProvider<RxMockyJSON>

    private init() { provider = RxMoyaProvider<RxMockyJSON>() }

    internal func getMusic() -> Observable<[RxMusic]> {
        return provider
            .request(RxMockyJSON.Music())
            .debug()
            .timeout(5, scheduler: MainScheduler.instance)
            .retry(3)
            .mapArray(RxMusic)
    }
}
