//
//  WebSocket.swift
//  
//
//  Created by Jon Shier on 5/3/20.
//

import Vapor

func createWebSocketRoutes(for app: Application) throws {
    app.webSocket("websocket") { _, socket in
        socket.send("reply")
        _ = socket.close(code: .goingAway)
    }
}
