//
//  ObservableType.swift
//  DemoRxSwift
//
//  Created by Nguyễn Tiến Đạt on 8/8/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import RxSwift

// Currently bug on the first tap
extension ObservableType {
    func throttleFirst(time: RxTimeInterval, scheduler: SchedulerType) -> Observable<E> {
        let s = self.share()
        return s
            .throttle(time, scheduler: scheduler)
            .asObservable()
            .map { _ in () }
            .startWith()
            .flatMapLatest { _ in s.take(1) }
    }

    func windows(time: RxTimeInterval, scheduler: SchedulerType) -> Observable<E> {
        return self
            .window(timeSpan: time, count: 1000, scheduler: scheduler)
            .flatMap { $0.take(1) }
    }
}

