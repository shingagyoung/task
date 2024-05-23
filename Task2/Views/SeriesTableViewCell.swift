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
    
    @IBOutlet weak var planeSelector: UISegmentedControl!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var levelSlider: UISlider!
    @IBOutlet weak var widthValueLabel: UILabel!
    @IBOutlet weak var levelValueLabel: UILabel!
    
    //NOTE: SeriesInfo class 사용하지말고 member 변수로 [UIImage]를 두는 방식 고려해보기.
    private var model: SeriesInfo?
    private var currentSegment: AnatomicalPlane = .axial
    private var wwlMinValue: Int = 0
    private var wwlMaxValue: Int = 0
    
    // - MARK: Cell initial set up
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setWindowSlider()
        self.loadIndicator.hidesWhenStopped = true
        self.planeSelector.addTarget(
            self,
            action: #selector(segmentDidChange(_:)),
            for: .valueChanged
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.dicomImageView.image = nil
        self.planeSelector.selectedSegmentIndex = .zero
        self.widthValueLabel.text = String(0)
        self.levelValueLabel.text = String(0)
        self.widthSlider.value = 0
        self.levelSlider.value = 0
    }
    
    func configure(with model: SeriesInfo) {
        self.model = model
        
        self.seriesId.text = String(model.series.id)
        self.seriesDescription.text = model.series.seriesDescription
        self.numberOfDicomFiles.text = "\(model.series.numberOfDicomFiles)"
        
        guard let nrrd = model.nrrdRaw,
              !model.axialImages.isEmpty else {
            Task {
                do {
                    self.loadIndicator.startAnimating()
                    defer { self.loadIndicator.stopAnimating() }
                    
                    try await model.loadNrrdData()
                    self.setInitialWWLValues(with: model.nrrdRaw!.header)
                    
                    await model.fetchDicomImage(plane: .axial)
                    self.dicomImageView.image = model.axialImages.first
                    self.setDicomSlider(with: model.axialImages)
                }
                catch {
                    Logger.network.error("\(error)")
                }
            }
            return
        }
        
        self.setInitialWWLValues(with: nrrd.header)
        self.dicomImageView.image = model.axialImages.first
        self.setDicomSlider(with: model.axialImages)
   
    }

}

// - MARK: UI Setters.
extension SeriesTableViewCell {
    private func setInitialWWLValues(with header: NrrdHeader) {
        self.widthValueLabel.text = String(header.ww)
        self.widthSlider.value = Float(header.ww)
        self.levelValueLabel.text = String(header.wl)
        self.levelSlider.value = Float(header.wl)
        
        self.applyMinMax(width: header.ww, level: header.wl)
    }
    
    private func setDicomSlider(with images: [UIImage]) {
        self.dicomImageSlider.value = 0
        self.dicomImageSlider.minimumValue = 0
        self.dicomImageSlider.maximumValue = Float(images.count - 1)
        
        self.dicomImageSlider.addTarget(self,
                                        action: #selector(sliderValueDidChange(_:)),
                                        for: .valueChanged)
    }
    
    private func setWindowSlider() {
        self.widthSlider.minimumValue = 2
        self.widthSlider.maximumValue = 4094
        self.levelSlider.minimumValue = -1024
        self.levelSlider.maximumValue = 3071
        
        self.widthSlider.addTarget(
            self,
            action: #selector(self.widthDidChange(_:)),
            for: .valueChanged
        )
        self.levelSlider.addTarget(
            self,
            action: #selector(self.levelDidChange(_:)),
            for: .valueChanged
        )
    }
    
    private func applyMinMax(width: Int, level: Int) {
        self.wwlMaxValue = level + width / 2
        self.wwlMinValue = level - width / 2
    }

}

// - MARK: Selector functions.
extension SeriesTableViewCell {
    
    @objc
    private func sliderValueDidChange(_ selector: UISlider) {
        let index = Int(selector.value)
        guard let model = self.model else { return }
        switch self.currentSegment {
        case .axial:
            guard !model.axialImages.isEmpty else { return }
            self.dicomImageView.image = model.axialImages[index]
        case .sagittal:
            guard !model.sagittalImages.isEmpty else { return }
            self.dicomImageView.image = model.sagittalImages[index]
        case .coronal:
            guard !model.coronalImages.isEmpty else { return }
            self.dicomImageView.image = model.coronalImages[index]
        }
    }
    
    @objc
    private func segmentDidChange(_ selector: UISegmentedControl) {

        self.loadIndicator.startAnimating()

        guard let model = self.model,
              let _ = model.nrrdRaw else { return }
        
        Task {
            defer { self.loadIndicator.stopAnimating() }
            
            switch selector.selectedSegmentIndex {
            case 0:
                if model.axialImages.isEmpty {
                    await model.fetchDicomImage(plane: .axial)
                }
                self.dicomImageView.image = model.axialImages[0]
                self.currentSegment = .axial
                self.setDicomSlider(with: model.axialImages)

            case 1:
                if model.sagittalImages.isEmpty {
                    await model.fetchDicomImage(plane: .sagittal)
                }
                self.dicomImageView.image = model.sagittalImages[0]
                self.currentSegment = .sagittal
                self.setDicomSlider(with: model.sagittalImages)
                
            case 2:
                if model.coronalImages.isEmpty {
                    await model.fetchDicomImage(plane: .coronal)
                }
                self.dicomImageView.image = model.coronalImages[0]
                self.currentSegment = .coronal
                self.setDicomSlider(with: model.coronalImages)
                
            default:
                return
            }
        }
    }
    
    @objc
    private func widthDidChange(_ selector: UISlider) {
        self.widthValueLabel.text = String(Int(selector.value))
        self.applyMinMax(
            width: Int(self.widthValueLabel.text!)!/2,
            level: Int(self.levelValueLabel.text!)!
        )
    }
    
    @objc
    private func levelDidChange(_ selector: UISlider) {
        self.levelValueLabel.text = String(Int(selector.value))
        self.applyMinMax(
            width: Int(self.widthValueLabel.text!)!/2,
            level: Int(self.levelValueLabel.text!)!
        )
    }
}
