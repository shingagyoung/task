//
//  SeriesTableViewCell.swift
//  Task2
//
//  Created by skia mac mini on 5/9/24.
//

import UIKit
import OSLog

final class SeriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dicomImageView: UIImageView!
    @IBOutlet weak var dicomImageSlider: UISlider!
    @IBOutlet weak var seriesId: UILabel!
    @IBOutlet weak var seriesDescription: UILabel!
    @IBOutlet weak var numberOfDicomFiles: UILabel!
    
    //NOTE: SeriesInfo class 사용하지말고 member 변수로 [UIImage]를 두는 방식 고려해보기.
    private var model: SeriesInfo?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.dicomImageView.image = nil
    }
    
    func configure(with model: SeriesInfo) {
        self.model = model
        
        self.seriesId.text = String(model.series.id)
        self.seriesDescription.text = model.series.seriesDescription
        self.numberOfDicomFiles.text = "\(model.series.numberOfDicomFiles)"
        self.dicomImageView.contentMode = .scaleAspectFit
        self.loadIndicator.hidesWhenStopped = true
        
        guard model.images.isEmpty else {
            self.dicomImageView.image = model.images.first
            self.setSlider(with: model.images)
            return
        }
        
        Task {
            do {
                self.loadIndicator.startAnimating()
                try await model.fetchDicomImage()
                
                self.dicomImageView.image = model.images.first
                self.setSlider(with: model.images)
            }
            catch {
                Logger.network.error("\(error)")
            }
            self.loadIndicator.stopAnimating()
        }
        
    }
    
    private func setSlider(with images: [UIImage]) {
        self.dicomImageSlider.value = 0
        self.dicomImageSlider.minimumValue = 0
        self.dicomImageSlider.maximumValue = Float(images.count - 1)
        
        self.dicomImageSlider.addTarget(self,
                                        action: #selector(sliderValueDidChange(_:)),
                                        for: .valueChanged)
    }
    
    @objc
    private func sliderValueDidChange(_ selector: UISlider) {
        let index = Int(selector.value)
        guard let model = self.model else { return }
        self.dicomImageView.image = model.images[index]
    }
}
