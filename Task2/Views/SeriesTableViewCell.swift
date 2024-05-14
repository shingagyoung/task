//
//  SeriesTableViewCell.swift
//  Task2
//
//  Created by skia mac mini on 5/9/24.
//

import UIKit

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
        
        self.seriesId.text = model.series.seriesNumber
        self.seriesDescription.text = model.series.seriesDescription
        self.numberOfDicomFiles.text = "\(model.series.numberOfDicomFiles)"
        self.dicomImageView.contentMode = .scaleAspectFit
        self.loadIndicator.hidesWhenStopped = true
        
        Task {
            do {
                self.loadIndicator.startAnimating()
                try await model.fetchDicomImage()
                
                self.dicomImageView.image = model.images.first
                self.setSlider(with: model.images)
                self.loadIndicator.stopAnimating()
            }
            catch {
                print("Error -- \(error)")
            }
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

//TODO: Create an individual file for this class.
final class ImageManger {
    static func imageFromPixelData(pixelData: [[UInt8]]) -> UIImage? {
        // Create a mutable data buffer
        let data = NSMutableData()

        // Flatten the 2D array into a 1D array and append to the data buffer
        for row in pixelData {
            let rowData = Data(row)
            data.append(rowData)
        }

        // Create a data provider
        guard let provider = CGDataProvider(data: data) else {
            return nil
        }

        // Create a CGImage
        guard let cgImage = CGImage(
            width: pixelData[0].count,
            height: pixelData.count,
            bitsPerComponent: 8,
            bitsPerPixel: 8 * MemoryLayout<UInt8>.size,
            bytesPerRow: pixelData[0].count * MemoryLayout<UInt8>.size,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            return nil
        }

        // Create a UIImage
        let image = UIImage(cgImage: cgImage)
        return image
    }
}
