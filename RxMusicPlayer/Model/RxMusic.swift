//
//  RxMusic.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import ObjectMapper

struct RxMusic: Mappable {

    var musicId = 0
    var name = ""
    var musicUrl = ""
    var cover = ""
    var artistName = ""
    var fileName = ""
    var isFavorited = false

    init?(_ map: Map) { }

    mutating func mapping(map: Map) {
        musicId <- map["id"]
        name <- map["title"]
        musicUrl <- map["music_url"]
        cover <- map["pic"]
        artistName <- map["artist"]
        fileName <- map["file_name"]
        isFavorited <- map["isFavorited"]
    }
}
