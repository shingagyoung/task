//
//  WWL.swift
//  Task2
//
//  Created by skia mac mini on 5/24/24.
//

import Foundation

struct WWL: CustomStringConvertible {
    let w: Int
    let l: Int
    
    var min: Int16 {
        return Int16(l - w / 2)
    }
    var max: Int16 {
        return Int16(l + w / 2)
    }
    var description: String {
        "width:\(w)_level:\(l)"
    }
}
