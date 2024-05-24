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
    @IBOutlet weak var applyButton: UIButton!
    
    private var model: SeriesInfo?
    private var currentPlane: AnatomicalPlane = .axial
    
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
        
        guard let nrrd = model.nrrdRaw else {
            Task {
                do {
                    self.loadIndicator.startAnimating()
                    defer { self.loadIndicator.stopAnimating() }
                    
                    try await model.loadNrrdData()
                    self.setInitialWWLValues(with: model.nrrdRaw!.header)
                    
                    await model.fetchDicomImage(plane: .axial,
                                                wwl: model.nrrdRaw!.header.wwl)
                    self.changeImagesAndSlider(as: .axial)
                }
                catch {
                    Logger.network.error("\(error)")
                }
            }
            return
        }
        
//        self.setInitialWWLValues(with: nrrd.header)
        self.setWwlLabels(with: nrrd.header.wwl)
        self.changeImagesAndSlider(as: .axial)
    }
    
}

// - MARK: UI Setters.
extension SeriesTableViewCell {
    private func setWwlLabels(with value: WWL) {
        self.widthValueLabel.text = String(value.w)
        self.widthSlider.value = Float(value.w)
        self.levelValueLabel.text = String(value.l)
        self.levelSlider.value = Float(value.l)
    }
    
    private func setInitialWWLValues(with header: NrrdHeader) {
        self.widthValueLabel.text = String(header.ww)
        self.widthSlider.value = Float(header.ww)
        self.levelValueLabel.text = String(header.wl)
        self.levelSlider.value = Float(header.wl)
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
    
    private func changeImagesAndSlider(as plane: AnatomicalPlane) {
        guard let model = self.model,
              let wwl = model.currentWwls[plane],
              let images = model.imageDictionary[plane]?.object(forKey: wwl.description as NSString) as? [UIImage]
        else { return }
        
        self.dicomImageView.image = images.first
        self.setDicomSlider(with: images)
    }
    
}

// - MARK: Selector functions.
extension SeriesTableViewCell {
    @IBAction func applyDidTap(_ sender: Any) {
        guard let model = self.model else { return }
        let selectedWwl = WWL(w: Int(self.widthValueLabel.text!)!,
                              l: Int(self.levelValueLabel.text!)!)
        model.currentWwls[self.currentPlane] = selectedWwl
        
        Task {
            self.loadIndicator.startAnimating()
            await model.fetchDicomImage(plane: self.currentPlane, wwl: selectedWwl)
            
            self.changeImagesAndSlider(as: self.currentPlane)
            self.loadIndicator.stopAnimating()
        }
    }
    
    @objc
    private func sliderValueDidChange(_ selector: UISlider) {
        let index = Int(selector.value)
        guard let model = self.model,
              let wwl = model.currentWwls[self.currentPlane],
              let images = model.imageDictionary[self.currentPlane]?.object(forKey: wwl.description as NSString) as? [UIImage]
        else { return }
        
        self.dicomImageView.image = images[index]
    }
    
    @objc
    private func segmentDidChange(_ selector: UISegmentedControl) {

        guard let model = self.model else { return }
        
        Task {
            self.loadIndicator.startAnimating()
            defer { self.loadIndicator.stopAnimating() }
            let plane = AnatomicalPlane(rawValue: selector.selectedSegmentIndex)!
            self.currentPlane = plane
            
            guard selector.selectedSegmentIndex < AnatomicalPlane.allCases.count,
                  let wwl = model.currentWwls[self.currentPlane] else { return }
            
            self.setWwlLabels(with: wwl)
            await model.fetchDicomImage(plane: plane, wwl: wwl)
            self.changeImagesAndSlider(as: plane)
        }
        
    }
    
    @objc
    private func widthDidChange(_ selector: UISlider) {
        self.widthValueLabel.text = String(Int(selector.value))
    }
    
    @objc
    private func levelDidChange(_ selector: UISlider) {
        self.levelValueLabel.text = String(Int(selector.value))
    }
}
