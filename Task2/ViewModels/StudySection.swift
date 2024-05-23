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
    var nrrdRaw: NrrdRaw?
    private(set) var axialImages: [UIImage] = []
    private(set) var sagittalImages: [UIImage] = []
    private(set) var coronalImages: [UIImage] = []
    
    init(series: Series) {
        self.series = series
    }
    
    func loadNrrdData() async throws {
        guard let url = URL(string: "\(AppConstants.baseUrl)/\(APIResource.dicom)/\(series.volumeFilePath)") else {
            throw DicomError.wrongFilePath
        }
        self.nrrdRaw = try await NrrdRaw.loadAsync(url)
    }
    
    func fetchDicomImage(plane: AnatomicalPlane) async {
        guard let nrrdData = self.nrrdRaw else { return }
        do {
            let images = try nrrdData.convertToImages(plane: plane)
            
            switch plane {
            case .axial:
                self.axialImages = images
            case .sagittal:
                self.sagittalImages = images
            case .coronal:
                self.coronalImages = images
            }
        }
        catch {
            Logger().error("Error -- \(error)")
        }
    }
    
    /// Series 저장할 local file url 반환.
    private func getFileUrl(of data: Series) throws -> URL {
        guard var directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileManagerError.directoryNotFound
        }
        directory.append(path: series.volumeFilePath.fileName)
        return directory
    }
    
    /// Nrrd file caching.
    private func setNrrdCache(of nrrdFile: URL, to cache: URL) throws {
        guard NrrdUtil.isNrrdFile(nrrdFile) else { return }
        let data = try Data(contentsOf: nrrdFile)
        try data.write(to: cache)
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

