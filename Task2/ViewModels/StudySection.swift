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
    private(set) var nrrdRaw: NrrdRaw? {
        didSet {
            AnatomicalPlane.allCases.forEach {
                self.currentWwls[$0] = WWL(w: nrrdRaw!.header.ww,
                                           l: nrrdRaw!.header.wl)
            }
        }
    }
    private(set) var imageDictionary: [AnatomicalPlane: NSCache<NSString, NSArray>] = [:]
    var currentWwls: [AnatomicalPlane: WWL] = [:]
    
    init(series: Series) {
        self.series = series
        
        AnatomicalPlane.allCases.forEach {
            self.imageDictionary[$0] = NSCache<NSString, NSArray>()
        }
    }
    
    func loadNrrdData() async throws {
        guard let url = URL(string: "\(AppConstants.baseUrl)/\(APIResource.dicom)/\(series.volumeFilePath)") else {
            throw DicomError.wrongFilePath
        }
        self.nrrdRaw = try await NrrdRaw.loadAsync(url)
    }
    
    func fetchDicomImage(plane: AnatomicalPlane,
                         wwl: WWL) async {
        // Check cache
        guard self.imageDictionary[plane]?.object(forKey: NSString(string: wwl.description)) == nil,
              let nrrdData = self.nrrdRaw else { return }
        
        do {
            let images = try nrrdData.convertToImages(plane: plane,
                                                      wwl: wwl)
            
            self.imageDictionary[plane]?
                .setObject(images as NSArray,
                           forKey: NSString(string: wwl.description))
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

