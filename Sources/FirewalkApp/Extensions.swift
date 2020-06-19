//
//  Extensions.swift
//
//
//  Created by Jon Shier on 5/3/20.
//

import Vapor

extension Request: Authenticatable {}

extension Request {
    var isAuthenticated: Bool {
        auth.has(Request.self)
    }
}

extension Application {
    @discardableResult
    func on<Response: ResponseEncodable>(_ methods: [HTTPMethod],
                                         _ path: PathComponent...,
                                         body: HTTPBodyStreamStrategy = .collect,
                                         use closure: @escaping (Request) throws -> Response) -> [Route] {
        methods.map { on($0, path, body: body, use: closure) }
    }

    @discardableResult
    func onMethods<Response: ResponseEncodable>(_ methods: [HTTPMethod],
                                                body: HTTPBodyStreamStrategy = .collect,
                                                use closure: @escaping (Request) throws -> Response) -> [Route] {
        methods.map { on($0, .constant($0.rawValue.lowercased()), body: body, use: closure) }
    }
}

extension RoutesBuilder {
    @discardableResult
    func on<Response: ResponseEncodable>(_ methods: [HTTPMethod],
                                         _ path: PathComponent...,
                                         body: HTTPBodyStreamStrategy = .collect,
                                         use closure: @escaping (Request) throws -> Response) -> [Route] {
        methods.map { on($0, path, body: body, use: closure) }
    }
}

extension Parameters {
    subscript<T>(_ name: String, as _: T.Type = T.self) -> T? where T: LosslessStringConvertible {
        // swiftformat:disable:next redundantBackticks
        `get`(name)
    }
}

extension HTTPServer.Configuration {
    var address: String {
        let scheme = tlsConfiguration == nil ? "http" : "https"
        return "\(scheme)://\(hostname):\(port)"
    }
}
