//
//  MainViewModel.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import Foundation

struct MainViewModel {
    private let networkService = DefaultNetworkService()
    
    func requestStudyList() async throws -> [Study] {
        let request = NetworkRequest(
            httpMethod: .get,
            resource: .dicom,
            endpoint: .study
        )
        let result: [Study] = try await networkService.execute(request)
        
        return result
    }
    
    func requestSeries(of id: String) async throws -> Series {
        let request = NetworkRequest(
            httpMethod: .get,
            resource: .dicom,
            endpoint: .series,
            pathComponents: [id]
        )
        let result: Series = try await networkService.execute(request)
        
        return result
    }
}
