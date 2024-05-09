//
//  MainViewModel.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import Foundation

    private let networkService = DefaultNetworkService()
    
    private var studySections: [StudySection] = []
    private var studyList: [Study] = []
    private var seriesList: [String: [Series]] = [:]
    
   
    
    private func convertStudyToStudySection(_ study: Study) -> StudySection {
        return StudySection(study: study)
    }
    
}

extension MainViewModel {
    func numberOfSections() -> Int {
        return self.studySections.count
    }
    
    func numberOfRows() -> Int {
        return self.studyList.count
    }
    
    func cellItem(at indexPath: IndexPath) -> StudySection {
        return self.studySections[indexPath.section]
    }
}

// MARK: - Fetch Server Data
extension MainViewModel {
    
    func fetchStudySectionData() async {
        do {
            let studies = try await requestStudyList()
            self.studySections = studies.map {
                self.convertStudyToStudySection($0)
            }
        }
        catch {
            print("Error -- \(error)")
        }
    }
    
    /// Request entire study list.
    private func requestStudyList() async throws -> [Study] {
        let request = NetworkRequest(
            httpMethod: .get,
            resource: .dicom,
            endpoint: .study
        )
        let result: [Study] = try await networkService.execute(request)
        
        return result
    }
    
    /// Request a single series data of a series.
    func requestSeries(of id: String) async throws -> [Series] {
        let request = NetworkRequest(
            httpMethod: .get,
            resource: .dicom,
            endpoint: .series,
            queryItems: [URLQueryItem(name: "studyId", value: id)]
        )
        let result: [Series] = try await networkService.execute(request)
        
        return result
    }
    
    /// Request series of each study.
    func requestDicomSeriesOfStudyList(_ list: [Study]) async throws -> [[Series]] {
        
        try await withThrowingTaskGroup(of: [Series].self) { group in
            var seriesList: [[Series]] = []
            
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
extension MainViewModel {
