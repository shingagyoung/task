import simd

public typealias float2 = simd_float2
public typealias float3 = simd_float3
public typealias float4 = simd_float4
public typealias float4x4 = simd_float4x4
public typealias int2 = simd_int2
public typealias int3 = simd_int3
public typealias int4 = simd_int4

protocol sizeable {}
extension sizeable {
    static var size: Int {
        return MemoryLayout<Self>.size
    }

    static var stride: Int {
        return MemoryLayout<Self>.stride
    }

    static func size(_ count: Int)->Int {
        return MemoryLayout<Self>.size * count
    }

    static func stride(_ count: Int)->Int {
        return MemoryLayout<Self>.stride * count
    }
}

extension Int32: sizeable {}
extension Int16: sizeable {}
extension Float: sizeable {}
extension float2: sizeable {}
extension float3: sizeable {}
extension float4: sizeable {}
extension UInt32: sizeable {}
extension UInt16: sizeable {}
