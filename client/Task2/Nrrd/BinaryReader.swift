// https://github.com/HearthSim/UnityPack-Swift/blob/master/Sources/BinaryReader.swift

import Foundation

public typealias Byte = UInt8

extension Data {
    func toByteArray() -> [Byte] {
        let count = self.count / MemoryLayout<Byte>.size
        var array = [Byte](repeating: 0, count: count)
        copyBytes(to: &array, count: count * MemoryLayout<Byte>.size)
        return array
    }
}

public protocol Readable {
    func readBytes(count: Int) -> [UInt8]
    func seek(count: Int, whence: Int)
    func readToEnd() -> [UInt8]
    var tell: Int { get }
}

public class ReadableData: Readable {
    var location: Int = 0
    var data: Data
    
    public init(_ data: Data) {
        self.data = data
    }
    
    public func readBytes(count: Int) -> [UInt8] {
        if location >= data.count {
            return [UInt8]()
        }
        
        let startIndex = location
        let endIndex = location + count
        
        var bytes = [UInt8](repeating: 0, count: count)
        data.copyBytes(to: &bytes, from: startIndex ..< endIndex)
        
        location += count
        return bytes
    }
    
    public func readToEnd() -> [UInt8] {
        return readBytes(count: data.count - location)
    }
    
    public var tell: Int { return location }
    
    public func seek(count: Int, whence: Int = 0) {
        location = count
    }
}

public class FileData: Readable {
    let fileHandle: FileHandle
    
    init(withFileHandle fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }
    
    public func readBytes(count: Int) -> [UInt8] {
        return fileHandle.readData(ofLength: count).toByteArray()
    }
    
    public func readToEnd() -> [UInt8] {
        do {
            let data = try fileHandle.readToEnd()!
            return data.toByteArray()
        } catch {
            fatalError("FileHandle.readToEnd() failed. \(error)")
        }
    }
    
    public var tell: Int { return Int(fileHandle.offsetInFile) }
    
    public func seek(count: Int, whence: Int = 0) {
        fileHandle.seek(toFileOffset: UInt64(count))
    }
}

public enum ByteOrder {
    case bigEndian
    case littleEndian
    
    /// Machine specific byte order
    static let nativeByteOrder: ByteOrder = (Int(CFByteOrderGetCurrent()) == Int(CFByteOrderLittleEndian.rawValue)) ? .littleEndian : .bigEndian
}

/// BinarySupportType 조건
/// - Platform에 따라 크기가 달라지지 않는 크기가 정해져 있는 자료형. (예시: Int32 가능, Int는 불가능)
/// - Struct처럼 고정된 크기의 자료형.
public protocol BinarySupportType {}

extension Int8: BinarySupportType {}
extension Int16: BinarySupportType {}
extension Int32: BinarySupportType {}
extension Int64: BinarySupportType {}
extension UInt8: BinarySupportType {}
extension UInt16: BinarySupportType {}
extension UInt32: BinarySupportType {}
extension UInt64: BinarySupportType {}
extension Float32: BinarySupportType {}
extension Float64: BinarySupportType {}

public class BinaryReader: Readable {
    public var tell: Int { return buffer.tell }

    public func seek(count: Int, whence: Int) {
        buffer.seek(count: count, whence: whence)
    }

    var buffer: Readable
    var endianness: ByteOrder = .littleEndian
    
    public init(data: Readable) {
        self.buffer = data
    }
    
    public func readBytes(count: Int) -> [UInt8] {
        return buffer.readBytes(count: count)
    }
    
    public func seek(count: Int32) {
        buffer.seek(count: Int(count), whence: 0)
    }
    
    public func readToEnd() -> [UInt8] {
        return buffer.readToEnd()
    }
    
    func align() {
        let old = tell
        let new = (old + 3) & -4
        if new > old {
            seek(count: Int32(new))
        }
    }
    
    // where T is struct
    public func read<T: BinarySupportType>() -> T {
        return read(byteOrder: endianness) as T
    }

    // where T is struct
    public func read<T: BinarySupportType>(byteOrder: ByteOrder) -> T {
        let b = buffer.readBytes(count: MemoryLayout<T>.size)
        let t: T = BinaryReader.fromByteArray(b, T.self, byteOrder: byteOrder)
        return t
    }
    
    public func readUInt8() -> UInt8 {
        let bytes = readBytes(count: 1)
        return bytes[0]
    }
    
    public func readInt8() -> Int8 {
        let bytes = readBytes(count: 1)
        return Int8(bitPattern: bytes[0])
    }

    public func readBool() -> Bool {
        let byte = readBytes(count: 1)[0]
        return byte != 0
    }
    
    public func readInt32() -> Int32 {
        return readInt32(byteOrder: endianness)
    }
    
    public func readInt32(byteOrder: ByteOrder) -> Int32 {
        let b = buffer.readBytes(count: 4)
        let int: Int32 = BinaryReader.fromByteArray(b, Int32.self, byteOrder: byteOrder)
        return int
    }
    
    public func readInt16() -> Int16 {
        return readInt16(byteOrder: endianness)
    }
    
    public func readInt16(byteOrder: ByteOrder) -> Int16 {
        let b = buffer.readBytes(count: 2)
        let int: Int16 = BinaryReader.fromByteArray(b, Int16.self, byteOrder: byteOrder)
        return int
    }
    
    public func readInt64() -> Int64 {
        return readInt64(byteOrder: endianness)
    }
    
    public func readInt64(byteOrder: ByteOrder) -> Int64 {
        let b = buffer.readBytes(count: 8)
        let int: Int64 = BinaryReader.fromByteArray(b, Int64.self, byteOrder: byteOrder)
        return int
    }
    
    public func readUInt32() -> UInt32 {
        return readUInt32(byteOrder: endianness)
    }
    
    public func readUInt32(byteOrder: ByteOrder) -> UInt32 {
        let b = buffer.readBytes(count: 4)
        let int: UInt32 = BinaryReader.fromByteArray(b, UInt32.self, byteOrder: byteOrder)
        return int
    }
    
    public func readFloat32() -> Float32 {
        let bytes = buffer.readBytes(count: 4)
        var f: Float32 = 0.0

        memcpy(&f, bytes, 4)
        return f
    }
    
    static func toByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }
    }
    
    static func fromByteArray<T>(_ value: [UInt8], _: T.Type, byteOrder: ByteOrder = ByteOrder.nativeByteOrder) -> T {
        let bytes: [UInt8] = (byteOrder == .littleEndian) ? value : value.reversed()
        return bytes.withUnsafeBufferPointer {
            return $0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) {
                $0.pointee
            }
        }
    }
}
