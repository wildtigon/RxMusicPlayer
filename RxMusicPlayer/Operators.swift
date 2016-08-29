//
//  Operators.swift
//  DemoRxSwift
//
//  Created by Nguyễn Tiến Đạt on 8/8/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

infix operator <-> {}

func <-> <T>(property: ControlProperty<T>, variable: BehaviorSubject<T>) -> Disposable {
    let bindToUIDisposable = variable.bindTo(property)
    let bindToVariable =
        property.subscribe(
            onNext: {variable.onNext($0)},
            onDisposed: {bindToUIDisposable.dispose()} )

    return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
}
