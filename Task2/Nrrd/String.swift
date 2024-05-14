import CommonCrypto
import Foundation

public extension String {
    var dicomDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: self)
    }

    // ref: https://dishware.sakura.ne.jp/swift/archives/243
    var md5: String { return digest(string: self, algorithm: .md5) }
    var sha1: String { return digest(string: self, algorithm: .sha1) }
    var sha224: String { return digest(string: self, algorithm: .sha224) }
    var sha256: String { return digest(string: self, algorithm: .sha256) }
    var sha384: String { return digest(string: self, algorithm: .sha384) }
    var sha512: String { return digest(string: self, algorithm: .sha512) }


    // MARK: private helpers
    private enum CryptoAlgorithm {
        case md5, sha1, sha224, sha256, sha384, sha512

        var digestLength: Int {
            var result: Int32 = 0
            switch self {
            case .md5: result = CC_MD5_DIGEST_LENGTH
            case .sha1: result = CC_SHA1_DIGEST_LENGTH
            case .sha224: result = CC_SHA224_DIGEST_LENGTH
            case .sha256: result = CC_SHA256_DIGEST_LENGTH
            case .sha384: result = CC_SHA384_DIGEST_LENGTH
            case .sha512: result = CC_SHA512_DIGEST_LENGTH
            }
            return Int(result)
        }
    }

    private func digest(string: String, algorithm: CryptoAlgorithm) -> String {
        var result: [CUnsignedChar]
        let digestLength = Int(algorithm.digestLength)
        if let cdata = string.cString(using: String.Encoding.utf8) {
            result = Array(repeating: 0, count: digestLength)
            switch algorithm {
            case .md5:
                NSLog("CC_MD5 is deprecated in ios 13. You should migrate to sha256.")
                CC_SHA256(cdata, CC_LONG(cdata.count - 1), &result)
            case .sha1: CC_SHA1(cdata, CC_LONG(cdata.count - 1), &result)
            case .sha224: CC_SHA224(cdata, CC_LONG(cdata.count - 1), &result)
            case .sha256: CC_SHA256(cdata, CC_LONG(cdata.count - 1), &result)
            case .sha384: CC_SHA384(cdata, CC_LONG(cdata.count - 1), &result)
            case .sha512: CC_SHA512(cdata, CC_LONG(cdata.count - 1), &result)
            }
        }
        else {
            fatalError("Nil returned when processing input strings as UTF8")
        }
        return (0 ..< digestLength).reduce("") { $0 + String(format: "%02hhx", result[$1]) }
    }
    }

public extension StringProtocol {
    // https://stackoverflow.com/a/32306142
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...]
            .range(of: string, options: options)
        {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
            index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
