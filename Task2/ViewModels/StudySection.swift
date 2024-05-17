//
//  StudySection.swift
//  Task2
//
//  Created by skia mac mini on 5/9/24.
//

import UIKit

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
        let dataSize = nrrdData.getSizes()
        let readable = ReadableData(nrrdData.raw)
        
        // Convert to [UInt16].
        for _ in 0..<Int(dataSize.z) {
            var pixelData: [[UInt16]] = []
            
            for _ in 0..<Int(dataSize.y) {
                // Convert to UInt16.
                let byteLine = readable.readBytes(count: Int(dataSize.x)*MemoryLayout<UInt16>.size).withUnsafeBytes {
                    Array($0.bindMemory(to: UInt16.self)).map(UInt16.init(littleEndian:))
                }
                pixelData.append(byteLine)
            }
            guard let img = ImageConverter.convertUInt16ToImage(from: pixelData) else {
                throw DicomError.imageError
            }
            self.images.append(img)
        }
    }
    
}

enum DicomError: Error {
    case wrongFilePath
    case imageError
}
 
