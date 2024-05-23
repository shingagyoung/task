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
    func convertToImages(plane: AnatomicalPlane) throws -> [UIImage] {
        let minValue = self.header.wl - self.header.ww / 2
        let maxValue = self.header.wl + self.header.ww / 2
        
        // [UInt8] -> [Int16]
        let data = self.raw
            .withUnsafeBytes {
                Array($0.bindMemory(to: Int16.self))
                    .map(Int16.init(littleEndian:))
                    .map {
                        if $0 > maxValue { return Int16(255) }
                        if $0 < minValue { return Int16(0) }
                        return $0
                    }
            }
        
        let size = self.getSizes().arrange(as: plane)
        return UIImage.makeImages(from: data,
                                  size: size,
                                  plane: plane)
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
                let sliceLength = size.row * size.col //TODO: 위치 확인
                singleImagePixelValues = Array(huValues[startIndex..<startIndex+sliceLength])
                startIndex += sliceLength
                
            case .sagittal:
                var rowStartIndex = size.depth * size.col * (size.row-1) + startIndex
                for _ in 0..<size.row {
                    var rowData: [Int16] = []
                    
                    for c in 0..<size.col {
                        rowData.append(huValues[rowStartIndex + size.depth * c])
                    }
                    singleImagePixelValues.append(contentsOf: rowData)
                    rowStartIndex -= size.depth * size.col
                }
                startIndex -= 1
                
            case .coronal:
                var colStartIndex = startIndex + (size.col * size.depth * size.row)
                for _ in 0..<size.row {
                    singleImagePixelValues.append(contentsOf: huValues[colStartIndex..<colStartIndex+size.col])
                    colStartIndex -= (size.col * size.depth)
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
