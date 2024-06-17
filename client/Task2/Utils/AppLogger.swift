//
//  AppLogger.swift
//  Task2
//
//  Created by skia mac mini on 5/16/24.
//

import OSLog

extension Logger {
    private static var bundleId = Bundle.main.bundleIdentifier!

    static let network = Logger(subsystem: bundleId, category: "Network")
}
