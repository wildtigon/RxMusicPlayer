//
//  RxMockyJSON.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import Foundation
import Moya

enum RxMockyJSON {
    case Music()
}

extension RxMockyJSON: TargetType {
    var baseURL: NSURL { return NSURL(string: "http://www.mocky.io/v2")! }
    var path: String {
        switch self {
        case .Music():
            return "/57be9fe40f00004c05a6a636"
        }
    }
    var method: Moya.Method { return .GET }
    var parameters: [String: AnyObject]? { return [:] }
    var sampleData: NSData { return "".dataUsingEncoding(NSUTF8StringEncoding)! }
    var multipartBody: [MultipartFormData]? { return nil }
}

