//
//  UITableViewCell+identifier.swift
//  Task2
//
//  Created by skia mac mini on 5/10/24.
//

import UIKit

extension UITableViewCell {
    static var identifier: String {
        return String(describing: Self.self)
    }
}
