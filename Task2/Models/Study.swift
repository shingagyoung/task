//
//  Study.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import Foundation

struct Study: Decodable {
    let id: Int
    let studyInstanceUID: String
    let studyID: String
    let studyDateTime: String
    let studyDescription: String
    let patientID: String
    let patientName: String
    let patientBirthDate: String
    let patientSex: String
    let referringPhysicianName: String?
    let numberOfSeries: Int
    let createdDateTime: String
    let lastModifiedDateTime: String
    let tag: Int?
    let memo: String?
}

