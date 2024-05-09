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
    private(set) var url: URL?
    
    init(httpMethod: HTTPMethod,
         resource: APIResource,
         endpoint: EndPoint,
         pathComponents: [String] = [],
         queryItems: [URLQueryItem] = [])
    {
        self.httpMethod = httpMethod
        self.url = self.makeUrl(httpMethod: httpMethod,
                                resource: resource,
                                endpoint: endpoint,
                                pathComponents: pathComponents,
                                queryItems: queryItems)
    }
    
    private func makeUrl(httpMethod: HTTPMethod,
                         resource: APIResource,
                         endpoint: EndPoint,
                         pathComponents: [String],
                         queryItems: [URLQueryItem]) -> URL? {
        
        guard var urlComponents = URLComponents(string: AppConstants.baseUrl) else { return nil }
        urlComponents.path.append("/\(resource.rawValue)")
        urlComponents.path.append("/\(endpoint.rawValue)")

        pathComponents.forEach {
            urlComponents.path.append("/\($0)")
        }
        
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        return urlComponents.url
    }
}
