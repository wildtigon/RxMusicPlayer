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
import FirebaseAuth
import RxSwift

class RxLoginViewController: RxBaseViewController {

  @IBOutlet weak var tfEmail: AnimatableTextField!
  @IBOutlet weak var tfPassword: AnimatableTextField!

  @IBOutlet weak var btnSignIn: AnimatableButton!

  @IBOutlet var viewBackground: UIView!

  // Life cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    initRx()

    // Mock data
    tfEmail.text = "nguyentiendat7993@gmail.com"
    tfPassword.text = "thattinh"
  }
}
//Firebase
extension RxLoginViewController {
  private func loginFireBase() {
    RxFireBaseManager
      .sharedInstance
      .login(self.tfEmail.text, self.tfPassword.text)
      .subscribe(
        onNext: { user in
          self.performSegueWithIdentifier("segue_login_musiclist", sender: self)
        },
        onError: { print("onError: \($0)") })
      .addDisposableTo(disposeBag)
  }
}

//Reactive
extension RxLoginViewController {
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
    btnSignIn
      .rx_tap
      .subscribeNext(dismissTextField)
      .addDisposableTo(disposeBag)

    btnSignIn
      .rx_tap
      .map { self.tfEmail.isEmail && self.tfPassword.textLength > 6 }
      .filter { $0 == true }
      .map { _ in }
      .subscribeNext(loginFireBase)
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
