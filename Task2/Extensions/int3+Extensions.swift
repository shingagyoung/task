//
//  int3+Extensions.swift
//  Task2
//
//  Created by skia mac mini on 5/22/24.
//

import Foundation

struct Size {
    var row: Int
    var col: Int
    var depth: Int
}

extension int3 {
    func arrange(as plane: AnatomicalPlane) -> Size {
        var size = Size(row: 0, col: 0, depth: 0)
        
        switch plane {
        case .axial:
            size.row = Int(self.x)
            size.col = Int(self.y)
            size.depth = Int(self.z)
        case .sagittal:
            size.row = Int(self.z)
            size.col = Int(self.x)
            size.depth = Int(self.y)
        case .coronal:
            size.row = Int(self.z)
            size.col = Int(self.y)
            size.depth = Int(self.x)
        }
        
        return size
    }
}
