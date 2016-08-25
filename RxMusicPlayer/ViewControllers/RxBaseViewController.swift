//
//  RxBaseViewController.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NAKPlaybackIndicatorView

class RxBaseViewController: UIViewController {

    // Constant
    let disposeBag = DisposeBag()

    // Functions
    internal func initNavigationBarWithText(title: String) {
        navigationController?.navigationBar.topItem?.title = title
    }
}
