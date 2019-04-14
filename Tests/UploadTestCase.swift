//
//  UploadTestCase.swift
//  TRON
//
//  Created by Denys Telezhkin on 13.05.16.
//  Copyright © 2016 Denys Telezhkin. All rights reserved.
//

import Foundation
import XCTest
import TRON

extension XCTestCase {
    func URLForResource(_ fileName: String, withExtension: String) -> URL {
        let bundle = Bundle(for: UploadTestCase.self)
        return bundle.url(forResource:fileName, withExtension: withExtension)!
    }
}

class UploadTestCase: ProtocolStubbedTestCase {
    
    func testUploadFromFile() {
        let request: UploadAPIRequest<JSONDecodableResponse,APIError> = tron.swiftyJSON.upload("/post", fromFileAt: URLForResource("cat", withExtension: "jpg"))
        request.method = .post
        request.stubSuccess(["title":"Foo"].asData)
        let expectation = self.expectation(description: "Upload from file")
        request.perform(withSuccess: { result in
            XCTAssertEqual(result.title, "Foo")
            expectation.fulfill()
        }, failure: { _ in
            XCTFail()
        })
        waitForExpectations(timeout: 1) { error in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testUploadData() {
        let request: UploadAPIRequest<JSONDecodableResponse,APIError> = tron.swiftyJSON.upload("/post", data: "foo".asData)
        request.method = .post
        request.stubSuccess(["title":"Foo"].asData)
        let expectation = self.expectation(description: "Upload data")
        request.perform(withSuccess: { result in
            XCTAssertEqual(result.title, "Foo")
            expectation.fulfill()
        }, failure: { _ in
                XCTFail()
        })
        waitForExpectations(timeout: 5) { error in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testMultipartUploadWorks() {
        let request: UploadAPIRequest<JSONDecodableResponse,APIError> = tron.swiftyJSON.uploadMultipart("post") { formData in
            formData.append("bar".data(using: .utf8) ?? Data(), withName: "foo")
        }
        request.method = .post
        request.stubSuccess(["title":"Foo"].asData)
        let expectation = self.expectation(description: "foo")
        
        request.perform(withSuccess: { result in
            XCTAssertEqual(result.title, "Foo")
            expectation.fulfill()
        }, failure: { error in
            XCTFail(error.localizedDescription)
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMultipartUploadIsAbleToUploadFile() {
        let path = Bundle(for: type(of: self)).path(forResource: "cat", ofType: "jpg")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path ?? ""))
        let request: UploadAPIRequest<JSONDecodableResponse,APIError> = tron.swiftyJSON.uploadMultipart("post") { formData in
            formData.append(data ?? Data(), withName: "cat", mimeType: "image/jpeg")
        }
        request.method = .post
        request.stubSuccess(["title":"Foo"].asData)
        
        let catExpectation = expectation(description: "meau!")
        
        request.perform(withSuccess: { result in
            XCTAssertEqual(result.title, "Foo")
            catExpectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testIntParametersAreAcceptedAsMultipartParameters() {
        let request: UploadAPIRequest<JSONDecodableResponse,APIError> = tron.swiftyJSON.uploadMultipart("post") { _ in }
        request.method = .post
        request.parameters = ["foo":1 as AnyObject]
        request.stubSuccess(["title":"Foo"].asData)
        let expectation = self.expectation(description: "Int expectation")
        request.perform(withSuccess: { result in
            XCTAssertEqual(result.title, "Foo")
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testBoolParametersAreAcceptedAsMultipartParameters() {
        let request: UploadAPIRequest<JSONDecodableResponse,APIError> = tron.swiftyJSON.uploadMultipart("post") { _ in }
        request.method = .post
        request.parameters = ["foo":true as AnyObject]
        request.stubSuccess(["title":"Foo"].asData)
        let expectation = self.expectation(description: "Int expectation")
        
        request.perform(withSuccess: { result in
            XCTAssertEqual(result.title, "Foo")
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
}
