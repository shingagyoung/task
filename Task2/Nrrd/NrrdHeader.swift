import Foundation

public class NrrdHeader {
    static let VERSION = 4
    static let NRRD_PREFIX = "NRRD00"

    public var sizes: [Int32] {
        let value = key_value["sizes"]!
        let intArray = value.components(separatedBy: " ").map { Int32($0)! }

        var sizes = [Int32]()
        for i in intArray {
            sizes.append(i)
        }
        return sizes
    }

    // 3차원이라고 가정
    // TODO: 차원이 특정되지 않은 NrrdVector 타입으로 변경
    public var space_origin: float3 {
        let value = key_value["space origin"]!
        return try! NrrdUtil.parseNrrdVector(value)
    }

    public var space_directions: [float3] {
        let value = key_value["space directions"]!
        let vectors = value.components(separatedBy: " ")
        var directions = [float3]()
        for v in vectors {
            directions.append(try! NrrdUtil.parseNrrdVector(v))
        }
        return directions
    }

    public var encoding: Encoding? {
        guard let value = key_value["encoding"]
        else { return nil }

        return Encoding(rawValue: value)
    }

    public var key_value = [String: String]()

    public static func readAsync(readable: Readable) async throws -> NrrdHeader {
        let version = try readNrrdMagicAsync(readable)
        guard version <= VERSION
        else {
            throw SkiaError.notSupported(msg: "Not supported NRRD version. version: \(version).")
        }

        let header = NrrdHeader()

        while true {
            try Task.checkCancellation()
            let line = try NrrdUtil.readLine(readable)

            if line.isEmpty { // end of header
                break
            }

            if line.hasPrefix("#") // #: comment
            {
                continue
            }

            let keyValue = try NrrdUtil.parse(line)

            // TODO: parsing해서 나온 field는 변수로 만들어서 넣고
            // 나머지만 key_value에 들어갈 수 있도록 변경하기.
            // 아래는 nrrd field 목록
            // http://teem.sourceforge.net/nrrd/format.html#space
            // http://teem.sourceforge.net/nrrd/format.html#basic
            // http://teem.sourceforge.net/nrrd/format.html#per-axis
            header.key_value.updateValue(keyValue.value, forKey: keyValue.key)
        }

        return header
    }

    static func readNrrdMagicAsync(_ readable: Readable) throws -> Int32 {
        // http://teem.sourceforge.net/nrrd/format.html#general.1
        let firstLine = try NrrdUtil.readLine(readable)

        guard firstLine.count >= NRRD_PREFIX.count + 2,
              firstLine.lowercased().hasPrefix(NRRD_PREFIX.lowercased())
        else {
            throw SkiaError.error(msg: "invalid NRRD magic number : \(firstLine)")
        }

        var startIndex = firstLine.index(firstLine.startIndex, offsetBy: NRRD_PREFIX.count)

        // NRRD00.01 for circa 1998 files handling
        if firstLine[startIndex] == "." {
            startIndex = firstLine.index(after: startIndex)
        }
        let versionString = String(firstLine[startIndex...])

        guard let version = Int32(versionString)
        else {
            throw SkiaError.error(msg: "invalid NRRD version : \(versionString)")
        }
        return version
    }

    public enum Encoding: String {
        case raw,
             txt, text, ascii,
             hex,
             gz, gzip,
             bz2, bzip2
    }
}
