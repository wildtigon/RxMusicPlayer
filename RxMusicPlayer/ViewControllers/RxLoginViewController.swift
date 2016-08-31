//
//  RxLoginViewController.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/31/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import IBAnimatable
import RxGesture
import EZSwiftExtensions

class RxLoginViewController: RxBaseViewController {

    @IBOutlet weak var tfEmail: AnimatableTextField!
    @IBOutlet weak var tfPassword: AnimatableTextField!
    @IBOutlet weak var btnSignIn: AnimatableButton!

    @IBOutlet var viewBackground: UIView!

    // Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initRx()
    }

    // Functions
    private func initRx() {
        // Shake when error
        tfEmail
            .rx_controlEvent(.EditingDidEnd)
            .map { self.tfEmail.isEmail }
            .filter { $0 == false }
            .subscribeNext { _ in self.tfEmail.shake() }
            .addDisposableTo(disposeBag)

        tfPassword
            .rx_controlEvent(.EditingDidEnd)
            .map { self.tfPassword.textLength > 6 }
            .filter { $0 == false }
            .subscribeNext { _ in self.tfPassword.shake() }
            .addDisposableTo(disposeBag)

        // Next Event
        tfEmail
            .rx_controlEvent(.EditingDidEndOnExit)
            .subscribeNext {
                self.tfPassword.becomeFirstResponder() }
            .addDisposableTo(disposeBag)

        tfPassword
            .rx_controlEvent(.EditingDidEndOnExit)
            .subscribeNext {
                self.tfPassword.resignFirstResponder() }
            .addDisposableTo(disposeBag)

        viewBackground
            .rx_gesture(.Tap)
            .subscribeNext { _ in self.dismissTextField() }
            .addDisposableTo(disposeBag)

        // Tap Event
        let btnSignInTapEvent = btnSignIn.rx_tap

        btnSignInTapEvent
            .subscribeNext { self.dismissTextField() }
            .addDisposableTo(disposeBag)

        btnSignInTapEvent
            .map { self.tfEmail.isEmail
                && self.tfPassword.textLength > 6 }
            .subscribeNext { isValid in
                if isValid {
                    self.performSegueWithIdentifier("segue_login_musiclist", sender: self)
                } else {
                    self.performSegueWithIdentifier("segue_login_musiclist", sender: self)
                    print("Oops") } }
            .addDisposableTo(disposeBag)
    }

    private func dismissTextField() {
        if self.tfEmail.isFirstResponder() {
            self.tfEmail.resignFirstResponder()
        }

        if self.tfPassword.isFirstResponder() {
            self.tfPassword.resignFirstResponder() }
    }
}
