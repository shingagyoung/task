//
//  UIImage+Extensions.swift
//  Task2
//
//  Created by skia mac mini on 5/22/24.
//

import UIKit

extension UIImage {
    convenience init?(
        huValues: [Int16],
        size: int3
    ) {
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
        
        self.init(cgImage: cgImage)
    }
    
}
