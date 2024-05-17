//
//  NetworkService.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest, delegate: (URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

final class DefaultNetworkService {
    
    private let cacheManager: CacheManager
    private let session: URLSessionProtocol
    
    init(cacheManager: CacheManager,
         session: URLSessionProtocol = URLSession.shared) {
        self.cacheManager = cacheManager
        self.session = session
    }
    
    func execute<T:Decodable>(_ request: NetworkRequest) async throws -> T {
        guard let urlRequest = self.request(from: request) else {
            throw NetworkServiceError.wrongRequest
        }
        
        guard let cachedData = self.cacheManager.retrieveCache(url: request.url) else {
            
            let result = try await self.session.data(for: urlRequest, delegate: nil)
            self.cacheManager.setCache(url: request.url, data: result.0)
            return try JSONDecoder().decode(T.self, from: result.0)
        }
        
        return try JSONDecoder().decode(T.self, from: cachedData)
    }
    
    private func request(from networkRequest: NetworkRequest) -> URLRequest? {
        guard let url = networkRequest.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = networkRequest.httpMethod.rawValue
        return request
    }

}

enum NetworkServiceError: Error {
    case wrongRequest
}
