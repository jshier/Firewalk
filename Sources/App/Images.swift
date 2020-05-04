//
//  Images.swift
//  
//
//  Created by Jon Shier on 5/3/20.
//

import Vapor

func createImageRoutes(for app: Application) throws {
    app.on(.GET, "image", ":type") { request -> Response in
        guard let type = request.parameters["type", as: String.self], ["jpeg", "png", "svg", "webp"].contains(type) else { return Response(status: .badRequest) }

        let response = Response(status: .permanentRedirect)
        response.headers.replaceOrAdd(name: .location, value: "https://httpbin.org/image/\(type)")
        
        return response
    }
}
