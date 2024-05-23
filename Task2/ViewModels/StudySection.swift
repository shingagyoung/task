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
        
        let directory = try self.getFilePath(of: series)
        
        // Local에 저장된 data가 있는 지 확인.
        guard FileManager.default.fileExists(atPath: directory.path()) else {
            let nrrdData = try await NrrdRaw.loadAsync(url)
            try JSONEncoder().encode(nrrdData).write(to: directory)
            self.images = try nrrdData.convertNrrdToImage()
         
            return
        }
        
        let data = try Data(contentsOf: directory)
        let cached = try JSONDecoder().decode(NrrdRaw.self, from: data)

        self.images = try cached.convertNrrdToImage()
    }
    
    /// Series 저장할 local file url 반환.
    private func getFilePath(of data: Series) throws -> URL {
        guard var directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileManagerError.directoryNotFound
        }
        directory.append(path: "\(series.volumeFilePath.fileName).txt")
        return directory
    }
}

enum FileManagerError: Error {
    case directoryNotFound
}

enum DicomError: Error {
    case wrongFilePath
    case wrongNameFormat
    case imageError
    case keyNotFound
}

