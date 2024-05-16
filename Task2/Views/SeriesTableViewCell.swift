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
    
    // [[UInt16]]을 UIImage?로 변환.
    static func convertUInt16ToImage(from pixelData: [[UInt16]]) -> UIImage? {
        let data = NSMutableData()

        for row in pixelData {
            var rowData = row
            data.append(&rowData, length: MemoryLayout<UInt16>.size * row.count)
        }

        guard let provider = CGDataProvider(data: data) else {
            return nil
        }

        guard let cgImage = CGImage(
            width: pixelData[0].count,
            height: pixelData.count,
            bitsPerComponent: 16,
            bitsPerPixel: 16,
            bytesPerRow: MemoryLayout<UInt16>.size * pixelData[0].count,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            return nil
        }

        let image = UIImage(cgImage: cgImage)
        return image
    }

    // [[UInt18]]을 UIImage?로 변환.
    static func convertUInt8ToImage(from pixelData: [[UInt8]]) -> UIImage? {
        let data = NSMutableData()

        // 2D array를 1D array로 변경.
        pixelData.forEach {
            data.append(Data($0))
        }
        
        guard let provider = CGDataProvider(data: data) else {
            return nil
        }
 
        guard let cgImage = CGImage(
            width: pixelData[0].count,
            height: pixelData.count,
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            bytesPerRow: pixelData[0].count,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: .byteOrderDefault,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            return nil
        }

        let image = UIImage(cgImage: cgImage)
        return image
    }
}
