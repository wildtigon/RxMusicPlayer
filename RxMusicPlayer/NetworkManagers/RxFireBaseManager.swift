//
//  RxFireBaseManager.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/31/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import RxSwift
import Firebase
import FirebaseAuth

class RxFireBaseManager {

  static let sharedInstance = RxFireBaseManager()
  private init() { }

  func login(email: String?, _ pass: String?) -> Observable <FIRUser> {
    return Observable.create { observer in
      guard let email = email, let pass = pass else {
        let errorInputValue = NSError(domain: "Error input value", code: 1, userInfo: nil)
        observer.onError(errorInputValue)
        return NopDisposable.instance
      }

      let errorInputValue = NSError(domain: "Error input value", code: 1, userInfo: nil)
      observer.onError(errorInputValue)

      FIRAuth.auth()?.signInWithEmail(email, password: pass, completion: { user, error in
        if error != nil {
          observer.onError(error!)
        } else {
          guard let user = user else {
            let errorInputValue = NSError(domain: "Login error", code: 1, userInfo: nil)
            observer.onError(errorInputValue)
            return }

          observer.onNext(user)
          observer.onCompleted()
        }
      })
      return AnonymousDisposable() { }
    }.retry(10)
  }

  internal func logout() -> Observable<Void> {
    return Observable.create { observer in
      guard (try? FIRAuth.auth()?.signOut()) != nil else {
        let errorLogout = NSError(domain: "Can't logout", code: 1, userInfo: nil)
        observer.onError(errorLogout)
        return AnonymousDisposable() { }
      }
      observer.onNext()
      observer.onCompleted()

      return AnonymousDisposable() { }
    }
  }
}