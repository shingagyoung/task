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
        size: Size
    ) {
        let data = NSData(bytes: huValues,
                          length: MemoryLayout<Int16>.size * huValues.count)
        
        guard let provider = CGDataProvider(data: data) else {
            return nil
        }
        
        // 변환된 data를 이용하여 CGImage 생성
        guard let cgImage = CGImage(
            width: size.col,
            height: size.row,
            bitsPerComponent: 16,
            bitsPerPixel: 16,
            bytesPerRow: MemoryLayout<Int16>.size * size.col,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else { return nil }
        
        self.init(cgImage: cgImage)
    }

    static func makeImages(
        with huValues: [Int16],
        size: Size,
        plane: AnatomicalPlane)
    -> [UIImage] {
        
        guard !huValues.isEmpty else { return [] }
        var images: [UIImage] = []
        
        var startIndex = 0
        switch plane {
        case .axial:
            startIndex = 0
        case .sagittal:
            startIndex = size.depth
        case .coronal:
            startIndex = size.col * (size.depth-1)
        }
        
        for _ in 0..<size.depth {
            var singleImagePixelValues: [Int16] = []
            
            switch plane {
            case .axial:
                let sliceLength = size.row * size.col
                singleImagePixelValues = Array(huValues[startIndex..<startIndex+sliceLength])
                startIndex += sliceLength
                
            case .sagittal:
                var colStartIndex = size.depth * size.col * (size.row-1) + startIndex
                for _ in 0..<size.row {
                    var rowData: [Int16] = []
                    
                    for c in 0..<size.col {
                        rowData.append(huValues[colStartIndex + size.depth * c])
                    }
                    singleImagePixelValues.append(contentsOf: rowData)
                    colStartIndex -= size.depth * size.col
                }
                startIndex -= 1
                
            case .coronal:
                var colStartIndex = startIndex + (size.col * size.depth * size.row)
                for _ in 0..<size.row {
                    singleImagePixelValues.append(contentsOf: huValues[colStartIndex..<colStartIndex+size.col])
                    colStartIndex -= size.col * size.depth
                }
                startIndex -= size.col
            }
            
            // Convert to a single image.
            guard let imageSlice = UIImage(
                huValues: singleImagePixelValues,
                size: size)
            else { return [] }
            images.append(imageSlice)
        }
       
        return images
    }
}
