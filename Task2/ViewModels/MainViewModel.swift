//
//  MainViewModel.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import Foundation

struct MainViewModel {
    private let networkService = DefaultNetworkService()
    
    /// Request entire study list.
    func requestStudyList() async throws -> [Study] {
        let request = NetworkRequest(
            httpMethod: .get,
            resource: .dicom,
            endpoint: .study
        )
        let result: [Study] = try await networkService.execute(request)
        
        return result
    }
    
    /// Request a single series data of a series.
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
    
    /// Request series of each study.
    func requestDicomSeriesOfStudyList(_ list: [Study]) async throws -> [Series] {
        
        try await withThrowingTaskGroup(of: Series.self) { group in
            var seriesList: [Series] = []
            
            for study in list {
                group.addTask {
                    return try await self.requestSeries(of: "\(study.id)")
                }
                
                for try await series in group {
                    seriesList.append(series)
                }
            }
            
            return seriesList
        }
    }
}
