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

    internal func getMusic() -> Observable<[RxMusicViewModel]> {
        return provider
            .request(RxMockyJSON.Music())
            .debug()
            .timeout(5, scheduler: MainScheduler.instance)
            .retry(3)
            .mapArray(RxMusic)
            .map { // Temp
                let result: NSMutableArray = []
                for item in $0 {
                    let addItem = RxMusicViewModel(item)
                    if item.name == "letter song" {
                        addItem.isFavorite.onNext(true)
                    }
                    result.addObject(addItem)
                }

                return (result as NSArray) as! [RxMusicViewModel] }
    }
}
