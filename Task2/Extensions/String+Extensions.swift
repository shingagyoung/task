//
//  String+Extensions.swift
//  Task2
//
//  Created by skia mac mini on 5/23/24.
//

import Foundation

extension String {
    func getNrrdFileName() -> String? {
        let parts = self.split(separator: "/")
        guard parts.count >= 4 else { return nil }
        
        // "yyyy/mm/dd/xxxx/x.nrrd" 형식의 파일 이름을 "/"로 나누고 "dd" 바로 다음 값 추출.
        return String(parts[3])
    }
}
