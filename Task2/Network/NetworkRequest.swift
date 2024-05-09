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
    private let pathComponents: [String]
    private let queryItems: [URLQueryItem]
    
    private var urlComponents: URLComponents {
        
        guard var urlComponents = URLComponents(string: AppConstants.baseUrl) else {
            return URLComponents()
        }
        urlComponents.path.append("/\(resource.rawValue)")
        urlComponents.path.append("/\(endpoint.rawValue)")

        pathComponents.forEach {
            urlComponents.path.append("/\($0)")
        }
        
        if !queryItems.isEmpty {
            urlComponents.queryItems = self.queryItems
        }

        return urlComponents
    }
    
    var url: URL? {
        return self.urlComponents.url
    }
    
    init(httpMethod: HTTPMethod,
         resource: APIResource,
         endpoint: EndPoint,
         pathComponents: [String] = [],
         queryItems: [URLQueryItem] = []) {
        self.httpMethod = httpMethod
        self.resource = resource
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryItems = queryItems
    }
    
}
