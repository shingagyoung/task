//
//  MainViewModel.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import Foundation
import OSLog

class MainViewModel {
    private let networkService = DefaultNetworkService()
    private var studySections: [StudySection] = []
    
}

// MARK: - TableView에 출력할 데이터
extension MainViewModel {
    func numberOfSections() -> Int {
        return self.studySections.count
    }
    
    func numberOfRows(at section: Int) -> Int {
        return studySections[section].isExpanded ? studySections[section].seriesList.count+1 : 1
    }
    
    func cellItem(at section: Int) -> StudySection {
        return self.studySections[section]
    }
    
    private func convertStudyToStudySection(_ study: Study) -> StudySection {
        return StudySection(study: study)
    }
}

// MARK: - Fetch Server Data
extension MainViewModel {
    
    func fetchStudySectionData(with text: String = "") async {
        do {
            let studies = try await requestStudyList(with: text)
            self.studySections = studies.map {
                self.convertStudyToStudySection($0)
            }
        }
        catch {
            Logger().log(level: .error, "Error -- \(error)")
        }
    }
    
    /// Request entire study list.
    private func requestStudyList(with text: String) async throws -> [Study] {
        let request = NetworkRequest(
            httpMethod: .get,
            resource: .dicom,
            endpoint: .study,
            queryItems: [URLQueryItem(name: AppConstants.APIQuery.filter, value: text)]
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
            queryItems: [URLQueryItem(name: AppConstants.APIQuery.studyId, value: id)]
        )
        let result: [Series] = try await networkService.execute(request)
        
        return result
    }

}

