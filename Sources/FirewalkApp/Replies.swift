//
//  Replies.swift
//  
//
//  Created by Jon Shier on 5/3/20.
//

import Vapor

struct Reply: Content {
    let date = Date()
    let url: String
    let origin: String
    let headers: HTTPHeaders
    let data: String?
    let form: [String: String]?
    let args: [String: String]
}

extension Reply {
    init(to request: Request) throws {
        url = "\(request.application.http.server.configuration.address)\(request.url.string)"
        origin = request.remoteAddress?.description ?? "No remote address."
        headers = request.headers
        let bodyString = request.body.string
        data = (bodyString?.isEmpty == true) ? nil : bodyString
        form = try? request.content.get([String: String].self, at: [])
        args = try request.query.get([String: String].self, at: [])
    }
}

struct IPReply: Content {
    let origin: String
}

struct RedirectURL: Decodable {
    let url: String
}
