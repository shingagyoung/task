//
//  CacheManager.swift
//  Task2
//
//  Created by skia mac mini on 5/17/24.
//

import Foundation

final class CacheManager {
    
    static let shared = CacheManager()
    private init() {}
    
    enum DataType {
        case data
        case images
        case nrrdRaw
    }
    
    /// Cache dictionary per data type.
    private var dataCache = NSCache<NSString, NSData>()
    private var imagesCache = NSCache<NSString, NSArray>()
    private var nrrdRawCache = NSCache<NSString, NrrdRaw>()

    /// Save cache.
    func setCache(type: DataType,
                  key: String,
                  data: AnyObject) {
        
        switch type {
        case .data:
            guard let data = data as? NSData else { return }
            self.dataCache.setObject(data, forKey: key as NSString)
        case .images:
            guard let images = data as? NSArray else { return }
            self.imagesCache.setObject(images, forKey: key as NSString)
        case .nrrdRaw:
            guard let nrrd = data as? NrrdRaw else { return }
            self.nrrdRawCache.setObject(nrrd, forKey: key as NSString)
        }
        
    }
    
    /// Retrieve saved cache.
    func retrieveCache(type: DataType,
                       key: String) -> AnyObject? {
        switch type {
        case .data:
            return dataCache.object(forKey: key as NSString)
        case .images:
            return imagesCache.object(forKey: key as NSString)
        case .nrrdRaw:
            return nrrdRawCache.object(forKey: key as NSString)
        }
    }
}
