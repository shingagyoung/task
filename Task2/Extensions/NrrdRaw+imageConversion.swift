//
//  NrrdRaw+imageConversion.swift
//  Task2
//
//  Created by skia mac mini on 5/22/24.
//

import UIKit
import OSLog

enum AnatomicalPlane: Int, CaseIterable {
    case axial, sagittal, coronal
}

extension NrrdRaw {

    typealias Range = (min: Int16, max: Int16)
    
    private enum ColorSystem {
        case grayScale
        
        var value: Int {
            switch self {
            case .grayScale:
                return 255
            }
        }
    }
    
    func convertToImages(plane: AnatomicalPlane,
                         wwl: WWL) throws -> [UIImage] {

        guard !self.raw.isEmpty else { return [] }
        let normalized = self.clampAndNormalize(range: (wwl.min, wwl.max))
        let size = self.getSizes().arrange(as: plane)
        var images: [UIImage] = []
        
        // Plane 종류에 따라 image 생성을 위한 연산 수행
        var imageStartIndex = 0
        switch plane {
        case .axial:
            imageStartIndex = 0
        case .sagittal:
            imageStartIndex = size.depth
        case .coronal:
            imageStartIndex = size.col * (size.depth-1)
        }
        
        for _ in 0..<size.depth {
            var singleImageData: [Int16] = []
            
            switch plane {
            case .axial:
                let sliceLength = size.row * size.col
                singleImageData = Array(normalized[imageStartIndex..<imageStartIndex+sliceLength])
                imageStartIndex += sliceLength
                
            case .sagittal:
                var colStartIndex = size.depth * size.col * (size.row-1) + imageStartIndex
                for _ in 0..<size.row {
                    var rowData: [Int16] = []
                    
                    for col in 0..<size.col {
                        rowData.append(normalized[colStartIndex + size.depth * col])
                    }
                    singleImageData.append(contentsOf: rowData)
                    colStartIndex -= size.depth * size.col
                }
                imageStartIndex -= 1
                
            case .coronal:
                var colStartIndex = imageStartIndex + (size.col * size.depth * size.row)
                for _ in 0..<size.row {
                    singleImageData.append(contentsOf: normalized[colStartIndex..<colStartIndex+size.col])
                    colStartIndex -= size.col * size.depth
                }
                imageStartIndex -= size.col
            }
            
            // Convert to a single image.
            guard let imageSlice = UIImage(
                grayScales: singleImageData,
                size: size)
            else { throw SkiaError.error(msg: "Failed to initialize a grayscale image.") }
            images.append(imageSlice)
        }
       
        return images

    }
    
    private func clampAndNormalize(range: Range) -> [Int16] {
        return self.raw
            .withUnsafeBytes {
                Array($0.bindMemory(to: Int16.self))
                    .map(Int16.init(littleEndian:))
                    .map {
                        var val = $0
                        if $0 > range.max {
                            val = Int16(range.max)
                        }
                        if $0 < range.min {
                            val = Int16(range.min)
                        }
                        return NrrdRaw.normalize(
                            range: range,
                            value: val
                        )
                    }
            }
    }
    
    static private func normalize(as system: ColorSystem = .grayScale,
                                  range: Range,
                                  value: Int16) -> Int16 {
        
        let calculated = Double(value-range.min) / Double(range.max-range.min) * Double(system.value)
        return Int16(calculated)
    }
    
}
