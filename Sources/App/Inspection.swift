//
//  Inspection.swift
//  
//
//  Created by Jon Shier on 5/3/20.
//

import Vapor

func createInspectionRoutes(for app: Application) throws {
    app.on(.GET, "response-headers") { request -> Response in
        let query = try request.query.decode([String: String].self)
        let encodedHeaders = try JSONEncoder().encodeAsByteBuffer(query, allocator: request.application.allocator)
        return Response(status: .permanentRedirect, headers: HTTPHeaders(query.map { $0 }), body: .init(buffer: encodedHeaders))
    }
}
