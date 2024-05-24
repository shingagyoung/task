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

        // [UInt8] -> [Int16]
        let normalized = try self.clampAndNormalize(range: (wwl.min, wwl.max))
        
        let size = self.getSizes().arrange(as: plane)
        
        return UIImage.makeImages(with: normalized,
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
