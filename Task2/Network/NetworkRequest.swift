//
//  NetworkRequest.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import Foundation

enum APIResource: String {
    case dicom = "Dicom"
}

enum EndPoint: String {
    case study = "Study"
    case series = "Series"
}

enum HTTPMethod: String {
    case get = "GET"
}

final class NetworkRequest {
    let httpMethod: HTTPMethod
    private let resource: APIResource
    private let endpoint: EndPoint
    private let pathComponents: [String]?
    
    private var urlString: String {
        var urlStr = AppConstants.baseUrl
        urlStr += "/"
        urlStr += resource.rawValue
        urlStr += "/"
        urlStr += endpoint.rawValue
        
        if let components = self.pathComponents {
            if !components.isEmpty {
                components.forEach {
                    urlStr += "/"
                    urlStr += $0
                }
            }
        }
        
        return urlStr
    }
    
    var url: URL? {
        return URL(string: self.urlString)
    }
    
    init(httpMethod: HTTPMethod,
         resource: APIResource,
         endpoint: EndPoint,
         pathComponents: [String]? = nil) {
        self.httpMethod = httpMethod
        self.resource = resource
        self.endpoint = endpoint
        self.pathComponents = pathComponents
    }
    
}
