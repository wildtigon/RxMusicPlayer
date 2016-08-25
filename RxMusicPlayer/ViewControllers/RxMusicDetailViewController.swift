//
//  RxMusicDetailViewController.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxMusicDetailViewController: RxBaseViewController {

    // IBOutlets
    @IBOutlet weak var hideButton: UIButton!

    // Variables
    weak var items: Variable<[RxMusic]>?

    // Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initRx()
    }

    // Functions
    private func initRx() {
        hideButton
            .rx_tap
            .subscribeNext {
                self.dismissViewControllerAnimated(true, completion: nil) }
            .addDisposableTo(disposeBag)
    }
}
