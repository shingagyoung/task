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
        
        let huValues = self.raw
            .withUnsafeBytes {
                Array($0.bindMemory(to: Int16.self))
                    .map(Int16.init(littleEndian:))
                    .map {
                        if $0 > 3071 {
                            return Int16(255)
                        }
                        if $0 < -1024 {
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
            singleImageHuValues = Array(huValues[startIndex..<startIndex+sliceLength])
            startIndex += sliceLength
            
            // Convert to a single image.
            guard let imageSlice = UIImage(
                huValues: singleImageHuValues,
                size: dataSize
            ) else { return [] }
            
            images.append(imageSlice)
        }
        return images
    }
    
}
