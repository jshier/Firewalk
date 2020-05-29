//
//  Methods.swift
//  
//
//  Created by Jon Shier on 5/3/20.
//

import Vapor

func createMethodRoutes(for app: Application) throws {
    app.onMethods([.GET, .POST, .PUT, .PATCH, .DELETE], use: Reply.init(to:))
    
    app.on([.GET, .POST, .PUT, .PATCH, .DELETE], "delay", ":interval") { request -> EventLoopFuture<Reply> in
        guard let interval = request.parameters["interval", as: Int64.self], interval <= 10 else {
            return request.eventLoop.future(try Reply(to: request))
        }
        
        let scheduled = request.eventLoop.scheduleTask(in: .seconds(interval)) { try Reply(to: request) }
        
        return scheduled.futureResult
    }
    
    app.on([.GET, .POST, .PUT, .PATCH, .DELETE], "status", ":code") { request -> Response in
        guard let code = request.parameters["code", as: Int.self] else { return Response(status: .badRequest) }
        
        switch code {
        case Int.min..<200:
            return Response(status: .badRequest)
        case 200..<300:
            let reply = try Reply(to: request)
            let encodedReply = try JSONEncoder().encodeAsByteBuffer(reply, allocator: app.allocator)
            return Response(status: .init(statusCode: code), body: .init(buffer: encodedReply))
        case 300..<400:
            let response = Response(status: .init(statusCode: code))
            let address = app.http.server.configuration.address
            let path = request.method.rawValue.lowercased()
            let redirectAddress = "\(address)/\(path)"
            response.headers.replaceOrAdd(name: .location, value: redirectAddress)
            return response
        case 400..<600:
            return Response(status: .init(statusCode: code))
        default:
            return Response(status: .badRequest)
        }
    }
    
    // TODO: Vapor should handle more types of redirects.
    app.on([.GET, .POST, .PUT, .PATCH, .DELETE], "redirect-to") { request -> Response in
        let url = try request.query.get(RedirectURL.self).url
        
        let response = Response(status: .found)
        response.headers.replaceOrAdd(name: .location, value: url)
        
        return response
    }
    
    app.on(.GET, "redirect", ":count") { request -> Response in
        guard let count = request.parameters["count", as: Int.self], count > 0, count < 100 else { return Response(status: .badRequest) }
        
        let url: String
        if count > 1 {
            url = "\(request.application.http.server.configuration.address)/redirect/\(count - 1)"
        } else {
            let address = app.http.server.configuration.address
            let path = request.method.rawValue.lowercased()
            url = "\(address)/\(path)"
        }
        let response = Response(status: .found)
        response.headers.replaceOrAdd(name: .location, value: url)
        
        return response
    }
}

