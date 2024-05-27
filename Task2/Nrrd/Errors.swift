import Foundation

public enum SkiaError: Error {
    case error(msg: String = "")
    case error(detail: [String: Any])
    case invalidResource(url: URL, msg: String="")
    case invalidArgument(argName: String, msg: String="")
    case notSupported(msg: String="")
    case invalidFormat(msg: String = "")

    
//    case nilReference(function: String, variable: String)
//    
//    
//    // TODO: Web URL로 기반이된 캐시 경로가 올바르게 출력될 수 있도록
//    // 특수문자로 Bulky해지는 경로출력이 문제였고 경로전달 전에 PercentEncoding을 1차제거하여 전달해 길이는 줄었지만,
//    // 아직 올바른 경로를 출력하지 못함.
//    case cacheNotExist(path: String)
//    case jsonParsingError(data: Data)
//    
//    case webCustomError(url: URL,
//                        info: [String: Any]? = nil)
//    case webResponseError(url: URL, code: Int)
//    
//    case cacheNotExistAndWebError(
//        cachePath: String,
//        webError: Error
//    )
//    
//    case invalidMeshFile(filePath: URL)
//    case loadFileFail(fileName: String)
//    case loadMeshFail(filePath: URL)
//    case loadImageFail(filePath: URL)
//    case loadCacheFail(filePath: URL)
//    
//    case fileNotExist(filePath: URL)
//    
//    case invalidParameters(info: String)
}
