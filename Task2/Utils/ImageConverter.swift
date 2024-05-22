//
//  ImageConverter.swift
//  Task2
//
//  Created by skia mac mini on 5/17/24.
//

import UIKit

extension NrrdRaw {
    func convertNrrdToImage() throws -> [UIImage] {
        guard !self.raw.isEmpty else { return [] }
        
        let huValues = self.raw
            .withUnsafeBytes {
                Array($0.bindMemory(to: Int16.self)).map(Int16.init(littleEndian:))
            }
        
        var images: [UIImage] = []
        let dataSize = self.getSizes()
        var startIndex = 0
        
        for _ in 0..<Int(dataSize.z) {
            var singleImageHuValues: [Int16] = []

                let sliceLength = Int(dataSize.y) * Int(dataSize.x)
                singleImageHuValues = Array(huValues[startIndex..<startIndex+sliceLength])
                startIndex += sliceLength

            // Convert to a single image.
            guard let imageSlice = NrrdRaw.convertSingleImage(
                with: singleImageHuValues,
                size: dataSize
            ) else { return [] }
            
            images.append(imageSlice)
        }
       
        return images

    }
    
    static func convertSingleImage(with huValues: [Int16],
                                   size: int3) -> UIImage? {
        let data = NSData(bytes: huValues,
                          length: MemoryLayout<Int16>.size * huValues.count)
        
        guard let provider = CGDataProvider(data: data) else {
            return nil
        }
        
        // 변환된 data를 이용하여 CGImage 생성
        guard let cgImage = CGImage(
            width: Int(size.y),
            height: Int(size.x),
            bitsPerComponent: 16,
            bitsPerPixel: 16,
            bytesPerRow: MemoryLayout<Int16>.size * Int(size.y),
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

