//
//  StudySection.swift
//  Task2
//
//  Created by skia mac mini on 5/9/24.
//

import Foundation

final class StudySection {
    var study: Study
    var seriesList: [Series]
    var isExpanded: Bool
    
    init(study: Study,
         seriesList: [Series] = [],
         isExpanded: Bool = false) {
        self.study = study
        self.seriesList = seriesList
        self.isExpanded = isExpanded
    }
}
