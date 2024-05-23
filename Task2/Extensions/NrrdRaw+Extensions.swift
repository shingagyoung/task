//
//  NrrdRaw+Extensions.swift
//  Task2
//
//  Created by skia mac mini on 5/17/24.
//

import UIKit
import OSLog

extension NrrdRaw {
    
    private func clampData(min: Int, max: Int) throws -> [Int16] {
        return self.raw
            .withUnsafeBytes {
                Array($0.bindMemory(to: Int16.self))
                    .map(Int16.init(littleEndian:))
                    .map {
                        if $0 > max {
                            return Int16(max)
                        }
                        if $0 < min {
                            return Int16(min)
                        }
                        return $0
                    }
            }
    }
    
    func convertNrrdToImage() throws -> [UIImage] {
        guard !self.raw.isEmpty else { return [] }
        
        // Grayscale로 clamping.
        let min = 0
        let max = 255
        let grayScales = try self.clampData(min: min, max: max)
        
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
