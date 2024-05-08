//
//  NetworkService.swift
//  Task2
//
//  Created by skia mac mini on 5/8/24.
//

import Foundation

protocol NetworkService {
    func execute<T:Decodable>(_ request: NetworkRequest) async throws -> T
    func request(from networkRequest: NetworkRequest) -> URLRequest?
}

final class DefaultNetworkService: NetworkService {
    
    func execute<T:Decodable>(_ request: NetworkRequest) async throws -> T {
        guard let urlRequest = self.request(from: request) else {
            throw NetworkServiceError.wrongRequest
        }
        
        let result = try await URLSession.shared.data(for: urlRequest)
        
        return try JSONDecoder().decode(T.self, from: result.0)
    }
    
    func request(from networkRequest: NetworkRequest) -> URLRequest? {
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
