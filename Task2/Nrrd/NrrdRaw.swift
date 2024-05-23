import Foundation
import GZIP

public class NrrdRaw: Codable {
    public private(set) var header: NrrdHeader

    // 배열을 사용하면 생성자에서 배열을 복사하는 시간이 오래 걸려서 Data 타입을 사용
    public let raw: Data // set은 생성자에서만 할 수 있도록 함.

    init(header: NrrdHeader, rawData: Data) {
        self.header = header
        raw = rawData
    }

    public static func loadAsync(_ fileUrl: URL) async throws -> NrrdRaw {
        guard NrrdUtil.isNrrdFile(fileUrl)
        else {
            throw SkiaError.invalidResource(url: fileUrl, msg: "failed to load invalid NRRD")
        }

        let data = try Data(contentsOf: fileUrl)
        let reader = BinaryReader(data: ReadableData(data))

        let header = try await NrrdHeader.readAsync(readable: reader)
        let body = try await readAllDataBlockAsync(reader, header.encoding)

        let nrrdRaw = NrrdRaw(header: header, rawData: body)
        
        return nrrdRaw
    }

    public static func readAllDataBlockAsync(_ reader: Readable, _ encoding: NrrdHeader.Encoding?) async throws -> Data
    {
        return try await Task.detached { () -> Data in
            let bytes = reader.readToEnd()

            // TODO: 다른 인코딩도 필요하면 추가하기
            if encoding == .gzip {
                let nsdata = NSData(data: Data(bytes: bytes, count: bytes.count))

                guard let unzipped = nsdata.gunzipped() else {
                    throw SkiaError.error(msg: "failed to decompress")
                }
                return unzipped
            }

            return Data(bytes: bytes, count: bytes.count)
        }.value
    }
}
