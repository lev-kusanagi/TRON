//
//  JSONDecodableTestCase.swift
//  Hint
//
//  Created by Denys Telezhkin on 11.12.15.
//  Copyright © 2015 MLSDev. All rights reserved.
//

import XCTest
@testable import TRON
import SwiftyJSON
import Alamofire

struct JSONDecodableResponse : JSONDecodable {
    let title : String
    
    init(json: JSON) throws {
        self.title = json["title"].stringValue
    }
}

class Ancestor: JSONDecodable {
    required init(json: JSON) {
        
    }
}

class Sibling: Ancestor {
    let foo: String = "4"
    
    required init(json: JSON) {
        super.init(json: json)
    }
}
struct ThrowError : Error {}

class Throwable : JSONDecodable {
    required init(json: JSON) throws {
        throw ThrowError()
    }
}

class JSONDecodableTestCase: ProtocolStubbedTestCase {
 
    func testVariousJSONDecodableTypes() throws
    {
        let json = JSON([])
        XCTAssertEqual(Float(json: JSON(4.5)), 4.5)
        XCTAssertEqual(Double(json: JSON(3.5)), 3.5)
        XCTAssertEqual(Bool(json: JSON(true)), true)
        try XCTAssertEqual(JSON(json: json), json)
        XCTAssertEqual(String(json: JSON("foo")), "foo")
        XCTAssertEqual(Int8(json: JSON(3)), 3)
        XCTAssertEqual(Int16(json: JSON(3)), 3)
        XCTAssertEqual(Int32(json: JSON(3)), 3)
        XCTAssertEqual(Int64(json: JSON(3)), 3)
        XCTAssertEqual(UInt(json: JSON(3)), 3)
        XCTAssertEqual(UInt8(json: JSON(3)), 3)
        XCTAssertEqual(UInt16(json: JSON(3)), 3)
        XCTAssertEqual(UInt32(json: JSON(3)), 3)
        XCTAssertEqual(UInt64(json: JSON(3)), 3)
    }

    func testJSONDecodableParsing() {
        let request: APIRequest<JSONDecodableResponse,APIError> = tron.swiftyJSON.request("response")
        request.stubSuccess(["title":"Foo"].asData)
        let expectation = self.expectation(description: "Parsing headers response")
        request.perform(withSuccess:  { response in
            XCTAssertEqual(response.title, "Foo")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testJSONDecodableWorksWithSiblings() {
        let request: APIRequest<Sibling,APIError> = tron.swiftyJSON.request("headers")
        request.stubSuccess([:].asData)
        let expectation = self.expectation(description: "Parsing headers response")
        request.perform(withSuccess:  { sibling in
            XCTAssertEqual(sibling.foo, "4")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
