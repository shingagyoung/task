//
//  AppConstants.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import Foundation

struct AppConstants {
    static let baseUrl: String = "http://localhost:5275"
    
    struct APIQuery {
        static let filter: String = "filter"
        static let studyId: String = "studyId"
    }
    
    struct ImageQuery {
        static let imageKey: String = "source"
    }
}
