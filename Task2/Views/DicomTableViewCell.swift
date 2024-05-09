//
//  DicomTableViewCell.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import UIKit

final class DicomTableViewCell: UITableViewCell {
    @IBOutlet weak var studyIdLabel: UILabel!
    @IBOutlet weak var patientInfoLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with model: StudySection) {
        self.studyIdLabel.text = "\(model.study.id)"
        self.patientInfoLabel.text = model.study.patientID
    }
}
