//
//  NrrdRaw+Extensions.swift
//  Task2
//
//  Created by skia mac mini on 5/17/24.
//

import UIKit

extension NrrdRaw {
    func convertNrrdToImage() throws -> [UIImage] {
        guard !self.raw.isEmpty else { return [] }
        
        let min = 0
        let max = 255

        let grayScales = self.raw
            .withUnsafeBytes {
                Array($0.bindMemory(to: Int16.self))
                    .map(Int16.init(littleEndian:))
                    .map {
                        if $0 > max {
                            return Int16(255)
                        }
                        if $0 < min {
                            return Int16(0)
                        }
                        return $0
                    }
            }
        
        var images: [UIImage] = []
        let dataSize = self.getSizes()
        var startIndex = 0
        
        for _ in 0..<Int(dataSize.z) {
            var singleImageHuValues: [Int16] = []
            
            let sliceLength = Int(dataSize.y) * Int(dataSize.x)
            singleImageHuValues = Array(grayScales[startIndex..<startIndex+sliceLength])
            startIndex += sliceLength
            
            // Convert to a single image.
            guard let imageSlice = UIImage(
                grayScales: singleImageHuValues,
                size: dataSize
            ) else { return [] }
            
            images.append(imageSlice)
        }
        return images
    }
    
}
