//
//  StudySection.swift
//  Task2
//
//  Created by skia mac mini on 5/9/24.
//

import UIKit
import OSLog

final class StudySection {
    var study: Study
    var seriesList: [SeriesInfo]
    var isExpanded: Bool
    
    init(study: Study,
         seriesList: [SeriesInfo] = [],
         isExpanded: Bool = false) {
        self.study = study
        self.seriesList = seriesList
        self.isExpanded = isExpanded
    }
}

final class SeriesInfo {
    let series: Series
    var images: [UIImage]
    
    init(series: Series,
         images: [UIImage] = []) {
        self.series = series
        self.images = images
    }
    
    func fetchDicomImage() async throws {
        guard let url = URL(string: "\(AppConstants.baseUrl)/\(APIResource.dicom)/\(series.volumeFilePath)") else {
            throw DicomError.wrongFilePath
        }
        let nrrdData = try await NrrdRaw.loadAsync(url)
        self.images = try nrrdData.convertNrrdToImage() 
    }
    
}

enum DicomError: Error {
    case wrongFilePath
    case imageError
    case keyNotFound
}
 
