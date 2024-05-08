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
    private var networkService: DefaultNetworkService!
    
    override func setUpWithError() throws {
        self.dicomStudyRequest = NetworkRequest(
            httpMethod: .get,
            resource: .dicom,
            endpoint: .study
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
        
        self.networkService = DefaultNetworkService()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNetWorkRequest_urlString_shouldReturnTrue() throws {
        let urlStringWithNoQueryItem = "http://10.10.20.102:6080/v2/Dicom/Study"
        XCTAssertNotNil(self.dicomStudyRequest.url)
        XCTAssertTrue(URL(string: urlStringWithNoQueryItem) == self.dicomStudyRequest.url)
        
        let urlStringWithQueryItem = "http://10.10.20.102:6080/v2/Dicom/Study?filter=head"
        XCTAssertNotNil(self.dicomStudyRequestWithQueryItems.url)
        XCTAssertTrue(URL(string: urlStringWithQueryItem) == self.dicomStudyRequestWithQueryItems.url)
    }

    func testNetworkService_execute_shouldReturnTrue() async throws {

    }
}
