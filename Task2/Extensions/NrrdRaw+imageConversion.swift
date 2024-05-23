//
//  NrrdRaw+imageConversion.swift
//  Task2
//
//  Created by skia mac mini on 5/22/24.
//

import UIKit

enum AnatomicalPlane {
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
    
    func convertToImages(plane: AnatomicalPlane) throws -> [UIImage] {
        let min = Int16(self.header.wl - self.header.ww) / 2
        let max = Int16(self.header.wl + self.header.ww) / 2
        
        // [UInt8] -> [Int16]
        let normalized = try self.clampAndNormalize(range: (min, max))
        
        let size = self.getSizes().arrange(as: plane)
        
        return UIImage.makeImages(from: normalized,
                                  size: size,
                                  plane: plane)
    }
    
    private func clampAndNormalize(range: Range) throws -> [Int16] {
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

extension UIImage {
    static func makeImages(
        from huValues: [Int16],
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
