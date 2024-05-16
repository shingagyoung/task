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
        guard let url = URL(string: "http://10.10.20.102:6080/dicom/\(series.volumeFilePath)") else {
            throw DicomError.wrongFilePath
        }
        
        let nrrdData = try await NrrdRaw.loadAsync(url)
        let dataSize = nrrdData.getSizes()
        let col = dataSize.x
        let row = dataSize.y
        let depth = dataSize.z

        let readable = ReadableData(nrrdData.raw)
        
        for _ in 0..<Int(depth) {
            var pixelData: [[Byte]] = []
            
            for _ in 0..<Int(row) {
                let byteLine = readable.readBytes(count: Int(col*2)).map {
                    return $0 == 252 ? 0 : $0
                }
                pixelData.append(byteLine)
            }
            guard let img = ImageManger.convertToImage(from: pixelData) else {
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
 
