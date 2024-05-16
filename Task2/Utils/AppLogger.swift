//
//  AppLogger.swift
//  Task2
//
//  Created by skia mac mini on 5/16/24.
//

import OSLog

let appLog = OSLog(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "app"
)

let appLogger = Logger(appLog)
