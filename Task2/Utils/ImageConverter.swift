//
//  ImageConverter.swift
//  Task2
//
//  Created by skia mac mini on 5/17/24.
//

import UIKit

extension NrrdRaw {
    func convertNrrdToImage() throws -> [UIImage] {
        
        var images: [UIImage] = []
        let dataSize = self.getSizes()
        let readable = ReadableData(self.raw)
        
        // Nrrd Raw 데이터를 [[UInt16]] type으로 변환.
        for _ in 0..<Int(dataSize.z) {
            var pixelData: [[UInt16]] = []
            
            for _ in 0..<Int(dataSize.y) {
                // 각 row를 [UInt16]로 변환.
                let byteLine = readable.readBytes(count: Int(dataSize.x)*MemoryLayout<UInt16>.size).withUnsafeBytes {
                    Array($0.bindMemory(to: UInt16.self)).map(UInt16.init(littleEndian:))
                }
                pixelData.append(byteLine)
            }
            // [[UInt16]]를 [UIImage]로 변환.
            guard let img = UIImage.convertUInt16ToImage(from: pixelData) else {
                throw DicomError.imageError
            }
            images.append(img)
        }
        
        return images
    }
}

extension UIImage {
    
    // Convert [[UInt16]] to UIImage.
    static func convertUInt16ToImage(from pixelData: [[UInt16]]) -> UIImage? {
        guard !pixelData.isEmpty else { return nil }
        let data = NSMutableData()

        // pixelData에 있는 [UInt16]을 데이터로 변환 (2D array to 1D array)
        for element in pixelData {
            data.append(element, length: MemoryLayout<UInt16>.size * element.count)
        }
        
        guard let provider = CGDataProvider(data: data) else {
            return nil
        }
        
        // 변환된 data를 이용하여 CGImage 생성
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
        ) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
