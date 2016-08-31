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
import IBAnimatable
import NAKPlaybackIndicatorView

class RxBaseViewController: AnimatableViewController {

    // Constant
    let disposeBag = DisposeBag()

    // Functions
    internal func initNavigationBarWithText(title: String) {
        navigationController?.navigationBar.topItem?.title = title
    }
}
