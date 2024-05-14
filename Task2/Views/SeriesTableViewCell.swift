//
//  SeriesTableViewCell.swift
//  Task2
//
//  Created by skia mac mini on 5/9/24.
//

import UIKit

final class SeriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dicomImageView: UIImageView!
    @IBOutlet weak var dicomImageSlider: UISlider!
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
        self.setSlider()
    }
    
    private func setSlider() {
        self.dicomImageSlider.value = 0
        self.dicomImageSlider.minimumValue = 0
        self.dicomImageSlider.maximumValue = 138
        
        self.dicomImageSlider.addTarget(self,
                                        action: #selector(sliderValueDidChange(_:)),
                                        for: .valueChanged)
    }
    
    @objc
    private func sliderValueDidChange(_ selector: UISlider) {
        let index = Int(selector.value)
        //TODO: index에 맞는 이미지 선택하기
    }
}

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
