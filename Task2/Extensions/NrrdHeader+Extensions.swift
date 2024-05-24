//
//  NrrdHeader.swift
//  Task2
//
//  Created by skia mac mini on 5/22/24.
//

import Foundation

extension NrrdHeader {
    private var minWidth: Int {
        return 2
    }
    
    private var minLevel: Int {
        return -1024
    }
    
    var wwl: WWL {
        WWL(w: ww, l: wl)
    }
    
    public var ww: Int {
        guard let value = key_value["WindowWidth"] else { return minWidth }
        let intArray = value.components(separatedBy: "\\\\").map { Int($0)! }
        guard !intArray.isEmpty else { return minWidth }
        return intArray.first!
    }
    
    public var wl: Int {
        guard let value = key_value["WindowCenter"] else { return minLevel }
        let intArray = value.components(separatedBy: "\\\\").map { Int($0)! }
        guard !intArray.isEmpty else { return minLevel }
        return intArray.first!
    }
}
