//
//  ObserverVCProtocol.swift
//  YJF
//
//  Created by edz on 2019/9/6.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol ObserverVCProtocol: class {
    var observers: [[Any?]] {get set}
    func deinitObservers()
    func registObservers(_ names: [Notification.Name],
                         queue: OperationQueue,
                         block: @escaping (Notification)->())
}

extension ObserverVCProtocol {
    func deinitObservers() {
        observers.forEach { (obs) in
            obs.forEach({ (ob) in
                ob.flatMap({
                    NotificationCenter.default.removeObserver($0)
                })
            })
        }
    }
    
    func registObservers(_ names: [Notification.Name],
                         queue: OperationQueue = .main,
                         block: @escaping (Notification)->()) {
        var obs = [Any?](repeating: nil, count: names.count)
        let handler = { (notice: Notification) in
            block(notice)
        }
        names.enumerated().forEach { (tuple) in
            obs[tuple.offset] = NotificationCenter.default
                .addObserver(forName: tuple.element,
                             object: nil,
                             queue: queue,
                             using: handler)
        }
        observers.append(obs)
    }
}
