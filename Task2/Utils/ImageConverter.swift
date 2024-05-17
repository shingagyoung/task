//
//  ImageConverter.swift
//  Task2
//
//  Created by skia mac mini on 5/17/24.
//

import UIKit

struct ImageConverter {
    
    // Convert [[UInt16]] to UIImage.
    static func convertUInt16ToImage(from pixelData: [[UInt16]]) -> UIImage? {
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
