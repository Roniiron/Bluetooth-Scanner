//
//  TaskExtensions.swift
//  Bluetooth Scanner
//
//  Created by Roni on 05. 08. 2025.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    /// Suspends the current task for the specified number of seconds
    /// - Parameter seconds: Duration to sleep in seconds
    /// - Throws: `CancellationError` if the task is cancelled
    static func sleep(for seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

enum ConcurrencyTimeouts {
    /// Run an async operation with a timeout. The slower competing task is cancelled.
    static func withTimeout<T>(
        _ timeout: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await Task.sleep(for: timeout)
                throw BLEError.timeout
            }
            group.addTask {
                return try await operation()
            }
            guard let result = try await group.next() else {
                throw BLEError.unknown
            }
            group.cancelAll()
            return result
        }
    }
}
