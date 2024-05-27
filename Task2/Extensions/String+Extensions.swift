//
//  String+Extensions.swift
//  Task2
//
//  Created by skia mac mini on 5/23/24.
//

import Foundation

extension String {
    var fileName: String {
        return NSString(string: self).lastPathComponent
    }
}
