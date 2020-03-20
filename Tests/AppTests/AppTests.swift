@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testGet() throws {
        // Given
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        var response: XCTHTTPResponse?
        var value: Reply?

        // When
        try app.test(.GET, "get", into: &response, decoding: &value)

        // Then
        XCTAssertEqual(response?.status, .ok)
        XCTAssertEqual(value?.url, "/get")
    }

    func testPost() throws {
        // Given
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        var response: XCTHTTPResponse?
        var value: Reply?

        // When
        try app.test(.POST, "post", into: &response, decoding: &value)

        // Then
        XCTAssertEqual(response?.status, .ok)
        XCTAssertEqual(value?.url, "/post")
    }

    func testGetWithQueryParameters() throws {
        // Given
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        var response: XCTHTTPResponse?
        var value: Reply?

        // When
        try app.test(.GET, "get?one=one&two=two", into: &response, decoding: &value)

        // Then
        XCTAssertEqual(response?.status, .ok)
        XCTAssertEqual(value?.url, "/get?one=one&two=two")
        XCTAssertEqual(value?.args, ["one": "one", "two": "two"])
    }

    func testPostWithBodyForm() throws {
        // Given
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        var response: XCTHTTPResponse?
        var value: Reply?

        // When
        try app.test(.GET, "get?one=one&two=two", into: &response, decoding: &value)

        // Then
        XCTAssertEqual(response?.status, .ok)
        XCTAssertEqual(value?.url, "/get?one=one&two=two")
        XCTAssertEqual(value?.args, ["one": "one", "two": "two"])
    }

    func testAllMethodQueries() throws {
        // Given
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        var response: XCTHTTPResponse?
        var value: Reply?

        // When
        let methods: [HTTPMethod] = [.GET, .POST, .DELETE, .PATCH, .PUT]
        for method in methods {
            try app.test(method, "/\(method.rawValue.lowercased())", into: &response, decoding: &value)

            // Then
            XCTAssertEqual(response?.status, .ok)
            XCTAssertEqual(value?.url, "/\(method.rawValue.lowercased())")
        }
    }

    func testPostWithFormBody() throws {
        // Given
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        var response: XCTHTTPResponse?
        var reply: Reply?

        var headers = HTTPHeaders()
        var body = app.allocator.buffer(capacity: 100)
        try URLEncodedFormEncoder().encode(["one": "one"], to: &body, headers: &headers)

        // When
        try app.test(.POST, "post", headers: headers, body: body, into: &response, decoding: &reply)

        // Then
        XCTAssertEqual(response?.status, .ok)
        XCTAssertEqual(reply?.form, ["one": "one"])
    }
}

extension XCTApplicationTester {
    @discardableResult
    func test(_ method: HTTPMethod,
              _ path: String,
              headers: HTTPHeaders = [:],
              body: ByteBuffer? = nil,
              file _: StaticString = #file,
              line _: UInt = #line,
              into response: inout XCTHTTPResponse?) throws -> XCTApplicationTester {
        try test(method, path, headers: headers, body: body) { response = $0 }
    }

    @discardableResult
    func test<T: Decodable>(_ method: HTTPMethod,
                            _ path: String,
                            headers: HTTPHeaders = [:],
                            body: ByteBuffer? = nil,
                            file _: StaticString = #file,
                            line _: UInt = #line,
                            into response: inout XCTHTTPResponse?,
                            decoding value: inout T?) throws -> XCTApplicationTester {
        try test(method, path, headers: headers, body: body) {
            response = $0
            value = try $0.body.getJSONDecodable(T.self, at: $0.body.readerIndex, length: $0.body.readableBytes)
        }
    }
}
