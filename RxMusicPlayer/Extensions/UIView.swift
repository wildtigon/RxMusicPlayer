//
//  UIView.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/26/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit

extension UIView {
    func startDuangAnimation() {
        UIView.animateWithDuration(0.15, delay: 0, options: [.AllowAnimatedContent, .BeginFromCurrentState], animations: { () -> Void in
            self.layer.setValue(0.80, forKeyPath: "transform.scale")
            }, completion: { (finished: Bool) -> Void in
            UIView.animateWithDuration(0.15, delay: 0, options: [.AllowAnimatedContent, .BeginFromCurrentState], animations: { () -> Void in
                self.layer.setValue(1.3, forKeyPath: "transform.scale")
                }, completion: { (finished: Bool) -> Void in
                UIView.animateWithDuration(0.15, delay: 0, options: [.AllowAnimatedContent, .BeginFromCurrentState], animations: { () -> Void in
                    self.layer.setValue(1, forKeyPath: "transform.scale")
                    }, completion: { _ in })
            })
        })
    }
}