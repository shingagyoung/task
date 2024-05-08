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
    let studyDateTime: Date
    let studyDescription: String
    let patientID: String
    let patientName: String
    let patientBirthDate: Date
    let patientSex: String
    let referringPhysicianName: String
    let numberOfSeries: Int
    let createdDateTime: Date
    let lastModifiedDateTime: Date
    let tag: String
    let memo: String
}

