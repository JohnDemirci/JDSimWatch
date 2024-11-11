//
//  LifecycleObservable.swift
//  JDSimWatch
//
//  Created by John Demirci on 11/9/24.
//

import Combine
import SwiftUI

protocol LifecycleObservable: AnyObject, Identifiable {
    var id: String { get }
    func didLaunchApplication()
    func didBecomeActive()
}

final class LifecycleObserver {
    var observers: [String: any LifecycleObservable] = [:]
    private var cancellables: [AnyCancellable] = []

    init() {
        observerLifecycle()
    }
}

extension LifecycleObserver {
    func register(_ observer: any LifecycleObservable) {
        observers[observer.id] = observer
    }

    func removeObserver(_ observer: any LifecycleObservable) {
        observers[observer.id] = nil
    }

    private func observerLifecycle() {
        NSWorkspace
            .shared
            .notificationCenter
            .publisher(for: NSWorkspace.didLaunchApplicationNotification)
            .sink { [weak self] _ in
                self?.observers.values.forEach {
                    $0.didLaunchApplication()
                }
            }
            .store(in: &cancellables)

        NSWorkspace
            .shared
            .notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .sink { [weak self] _ in
                self?.observers.values.forEach {
                    $0.didBecomeActive()
                }
            }
            .store(in: &cancellables)
    }
}
