import Foundation
import simd

public extension NrrdRaw {
    
    // TODO: 다차원 지원
    
    func getPixelSpaces() -> float3 {
        let spaceDirections = header.space_directions
        assert(spaceDirections.count == 3)
        
        return float3(length(spaceDirections[0]),
                      length(spaceDirections[1]),
                      length(spaceDirections[2]))
    }

    func getSizes() -> int3 {
        let sizes = header.sizes
        assert(sizes.count == 3)
        return int3(sizes[0], sizes[1], sizes[2])
    }
}

public class NrrdUtil {
    public static func readLine(_ readable: Readable) throws -> String {
        let NEW_LINE = "\n"
        let EOF = ""

        var line = ""

        while true {
            try Task.checkCancellation()
            let byte = readable.readBytes(count: 1)
            guard let string = String(bytes: byte, encoding: .ascii)
            else {
                throw SkiaError.error(msg: "failed to read bytes to string")
            }

            if string == NEW_LINE || string == EOF {
                return line.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            line.append(string)
        }
    }

    public static func parse(_ headerLine: String) throws -> (isField: Bool, key: String, value: String) {
        // http://teem.sourceforge.net/nrrd/format.html#general.1
        // <key>:=<value>
        // <field>: <desc>
        
        if let index = headerLine.index(of: ":=") {
            let key = headerLine[headerLine.startIndex ..< index]
            // 구분자가 2글자이므로 offset을 2로 한다.
            let value = headerLine[headerLine.index(index, offsetBy: 2) ..< headerLine.endIndex]

            return (false, String(key), String(value))
        }

        if let index = headerLine.index(of: ": ") {
            let key = headerLine[headerLine.startIndex ..< index]
            // 구분자가 2글자이므로 offset을 2로 한다.
            let value = headerLine[headerLine.index(index, offsetBy: 2) ..< headerLine.endIndex]

            return (true, String(key), String(value))
        }
        throw SkiaError.error(msg:"failed to parse NRRD header : \(headerLine)")
    }

    public static func isNrrdFile(_ fileUrl: URL) -> Bool {
        do {
            let data = try Data(contentsOf: fileUrl)
            let reader = ReadableData(data)
            let line = try readLine(reader)
            return line.hasPrefix("NRRD")
        } catch {
            NSLog("\(error)")
            return false
        }
    }

    public static func parseNrrdVector(_ str: String) throws -> float3 {
        guard str.hasPrefix("("), str.hasSuffix(")") else {
            throw SkiaError.invalidFormat(msg:"invalid to convert to vector : \(str)")
        }

        var vectorStr = str // 값을 바꾸기 위해서 var로 재정의

        vectorStr.removeFirst()
        vectorStr.removeLast()

        let floatArray = vectorStr.components(separatedBy: ",").map { Float($0)! }
        assert(floatArray.count == 3)
        return float3(floatArray[0], floatArray[1], floatArray[2])
    }
}
