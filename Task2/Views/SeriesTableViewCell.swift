//
//  SeriesTableViewCell.swift
//  Task2
//
//  Created by skia mac mini on 5/9/24.
//

import UIKit

final class SeriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var seriesId: UILabel!
    @IBOutlet weak var seriesDescription: UILabel!
    @IBOutlet weak var numberOfDicomFiles: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with model: Series) {
        self.seriesId.text = model.seriesNumber
        self.seriesDescription.text = model.seriesDescription
        self.numberOfDicomFiles.text = "\(model.numberOfDicomFiles)"
    }
}
