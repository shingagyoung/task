//
//  Series.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import Foundation

struct Series: Decodable {
    
    let id: Int
    let dicomStudyId: Int
    let seriesInstanceUID: String
    let seriesNumber: String
    let modality: String
    let seriesDateTime: String
    let patientPosition: String
    let acquisitionNumber: String
    let scanningSequence: String?
    let bodyPartExamined: String
    let seriesDescription: String
    let rows: String
    let columns: String
    let pixelSpacing: String
    let sliceThickness: String
    let imageType: String
    let imageOrientationPatient: String
    let numberOfDicomFiles: Int
    let createdDateTime: String
    let lastModifiedDateTime: String
    let volumeFilePath: String
    let tag: String?
    let memo: String?
    
}
