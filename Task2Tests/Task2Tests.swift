//
//  Task2Tests.swift
//  Task2Tests
//
//  Created by skia mac mini on 5/7/24.
//

import XCTest
@testable import Task2

final class Task2Tests: XCTestCase {
    private var dicomStudyRequest: NetworkRequest!
    private var dicomStudyRequestWithQueryItems: NetworkRequest!
    private var dicomSeriesRequest: NetworkRequest!
    
    private let nrrdUrl: URL = URL(string: "http://10.10.20.102:6080/dicom/2021/08/20/30000021081923435668600026257/1.3.12.2.1107.5.1.4.73230.30000021081923435668600026257.nrrd")!
    
    private let dcmUrl: URL = URL(string: "http://10.10.20.102:6080/dicom/2021/08/20/30000021081923435668600026257/1.3.12.2.1107.5.1.4.73230.30000021081923435668600026266.dcm")!
    
    override func setUpWithError() throws {
        self.dicomStudyRequest = NetworkRequest(
            httpMethod: .get,
            resource: .dicom,
            endpoint: .study,
            queryItems: []
        )
        
        self.dicomStudyRequestWithQueryItems = NetworkRequest(
            httpMethod: .get,
            resource: .dicom,
            endpoint: .study,
            queryItems: [URLQueryItem(name: "filter", value: "head")])
        
        self.dicomSeriesRequest = NetworkRequest(
            httpMethod: .get,
            resource: .dicom,
            endpoint: .series,
            pathComponents: ["3"]
        )
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNetWorkRequest_urlString_shouldReturnTrue() throws {
        let urlStringWithNoQueryItem = "http://10.10.20.102:6080/v2/Dicom/Study?"
        XCTAssertNotNil(self.dicomStudyRequest.url)
        XCTAssertTrue(URL(string: urlStringWithNoQueryItem) == self.dicomStudyRequest.url)
        
        let urlStringWithQueryItem = "http://10.10.20.102:6080/v2/Dicom/Study?filter=head"
        XCTAssertNotNil(self.dicomStudyRequestWithQueryItems.url)
        XCTAssertTrue(URL(string: urlStringWithQueryItem) == self.dicomStudyRequestWithQueryItems.url)
    }

    func testNetworkService_execute_shouldReturnTrue() async throws {
        let path = Bundle.main.path(forResource: "study_mock", ofType: ".json")!
        let jsonData = try Data(contentsOf: URL(filePath: path))
        let decodedData = try JSONDecoder().decode([Study].self, from: jsonData)
        
        let response = HTTPURLResponse(url: URL(string: "http://10.10.20.102:6080/v2/Dicom/Study")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)!
        
        let mockSession = MockURLSession(response:(jsonData, response))
        let networkService = DefaultNetworkService(session: mockSession)
        let mockResult: [Study] = try await networkService.execute(self.dicomStudyRequest)
       
        XCTAssertTrue(mockResult.count == decodedData.count)
        XCTAssertNotNil(mockResult.first?.patientBirthDate)
        XCTAssertTrue(mockResult.first?.patientBirthDate == decodedData.first?.patientBirthDate)
    }
    
    func testNrrd_isNrrdFile_shouldReturnTrue() throws {
        let isNrrd = NrrdUtil.isNrrdFile(nrrdUrl)
        XCTAssertTrue(isNrrd)
    }
    
    func testNrrd_nrrdHeader_shouldNotReturnData() async throws {
        let result = try await NrrdRaw.loadAsync(nrrdUrl)
        print("Sizes: \(result.header.sizes)")

        let bytes = result.raw.toByteArray()
        print("Total: \(bytes.count)")
        
        let readable = ReadableData(result.raw)
        var d2Bytes: [[Byte]] = []
       
        for _ in 0..<result.header.sizes[1] {
            
            let bt = readable.readBytes(count: 512)
            d2Bytes.append(bt)
            
        }
        if let image = ImageConverter.convertToImage(pixelData: d2Bytes) {
            // Use the resulting UIImage
            print(image)
        } else {
            print("Failed to create UIImage from pixel data")
        }

    }
    
}

/// Network test를 위한 mock url session class.
final class MockURLSession: URLSessionProtocol {
    let response: (Data, URLResponse)
    
    init(response: (Data, URLResponse)) {
        self.response = response
    }
    
    func data(for request: URLRequest, delegate: (URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse) {
        return  response
    }
}
