//
//  UIButton.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/29/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit

extension UIButton {
    func setImageWithImageName(name: String) {
        guard let image = UIImage(named: name) else { return }

        setImage(image, forState: .Normal)
        setImage(image, forState: .Highlighted)
    }
}