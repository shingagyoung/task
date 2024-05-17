//
//  CacheManager.swift
//  Task2
//
//  Created by skia mac mini on 5/17/24.
//

import Foundation

final class CacheManager {
    
    /// Cache dictionary. Using url's end point as a key.
    private var cache = NSCache<NSString, NSData>()

    /// Save cache.
    func setCache(url: URL?,
                  data: Data) {
        guard let url else { return }
        
        cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
    }
    
    /// Retrieve saved cache.
    func retrieveCache(url: URL?) -> Data? {
        guard let url else { return nil }
        
        let cachedData = cache.object(forKey: url.absoluteString as NSString)
        return cachedData as? Data
    }
}
