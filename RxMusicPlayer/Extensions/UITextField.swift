//
//  UITextField.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/31/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit

extension UITextField {
    var textLength: Int {
        get {
            guard let text = self.text else { return 0 }
            return text.length
        }
    }

    var isEmail: Bool {
        get {
            guard let text = self.text else { return false }
            return text.isEmail
        }
    }
}
