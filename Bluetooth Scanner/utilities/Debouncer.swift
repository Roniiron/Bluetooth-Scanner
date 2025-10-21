//
//  Debouncer.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation

/// Debouncer for preventing rapid repeated actions
actor Debouncer {
    private var task: Task<Void, Never>?
    private let delay: TimeInterval
    
    init(delay: TimeInterval = 0.5) {
        self.delay = delay
    }
    
    /// Debounces an action - cancels previous pending action and schedules new one
    func debounce(action: @escaping @Sendable () async -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            await action()
        }
    }
    
    /// Immediately cancels any pending action
    func cancel() {
        task?.cancel()
        task = nil
    }
}

