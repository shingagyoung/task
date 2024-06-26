//
//  AppConstants.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import Foundation

struct AppConstants {
    static let baseUrl: String = "http://10.10.20.136:6080"
    
    struct APIQuery {
        static let filter: String = "filter"
        static let studyId: String = "studyId"
    }
    
    struct ImageQuery {
        static let imageKey: String = "source"
    }
}
