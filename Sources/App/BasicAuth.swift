//
//  BasicAuth.swift
//  
//
//  Created by Jon Shier on 5/3/20.
//

import Vapor

func createBasicAuthRoutes(for app: Application) throws {
    let basicAuth = app.grouped(BasicPathAuthenticator())
    basicAuth.on([.GET, .POST, .PUT, .PATCH, .DELETE], "basic-auth", ":user", ":passwd") { request -> EventLoopFuture<Response> in
        guard request.isAuthenticated else {
            var headers = HTTPHeaders()
            headers.add(name: .wwwAuthenticate, value: "Basic")
            return request.eventLoop.makeSucceededFuture(Response(status: .unauthorized, headers: headers))
        }
        
        return try Reply(to: request).encodeResponse(for: request)
    }
    
    basicAuth.on([.GET, .POST, .PUT, .PATCH, .DELETE], "hidden-basic-auth", ":user", ":passwd") { request -> EventLoopFuture<Response> in
        guard request.isAuthenticated else {
            return request.eventLoop.makeSucceededFuture(Response(status: .unauthorized))
        }
        
        return try Reply(to: request).encodeResponse(for: request)
    }
}

struct BasicPathAuthenticator: BasicAuthenticator {
    enum Error: Swift.Error { case invalidRequest, invalidCredentials }
    
    func authenticate(basic: BasicAuthorization, for request: Request) -> EventLoopFuture<Void> {
        guard let username = request.parameters["user", as: String.self],
            let password = request.parameters["passwd", as: String.self] else {
                return request.eventLoop.makeFailedFuture(Error.invalidRequest)
        }
        
        guard basic.username == username, basic.password == password else {
            return request.eventLoop.makeFailedFuture(Error.invalidCredentials)
        }
        
        request.auth.login(request)
        return request.eventLoop.makeSucceededFuture(())
    }
}
