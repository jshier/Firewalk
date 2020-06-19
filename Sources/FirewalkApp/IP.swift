//
//  IP.swift
//
//
//  Created by Jon Shier on 5/3/20.
//

import Vapor

func createIPRoute(for app: Application) throws {
    app.on(.GET, "ip") { request in
        IPReply(origin: request.remoteAddress?.description ?? "No IP Address.")
    }
}
