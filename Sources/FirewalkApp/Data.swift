//
//  Data.swift
//
//
//  Created by Jon Shier on 5/3/20.
//

import AsyncKit
import Vapor

func createDataRoutes(for app: Application) throws {
    app.on(.GET, "bytes", ":count") { request -> Response in
        guard let count = request.parameters["count", as: Int.self], count <= 100_000 else {
            return Response(status: .badRequest)
        }

        var buffer = request.application.allocator.buffer(capacity: count)
        let big = count / 8
        let remainder = count % 8

        for _ in 0..<big {
            buffer.writeInteger(UInt64.random())
        }

        for _ in 0..<remainder {
            buffer.writeInteger(UInt8.random())
        }

        return Response(body: .init(buffer: buffer))
    }

    app.on(.GET, "stream", ":count") { request -> Response in
        guard let count = request.parameters["count", as: Int.self], count > 0, count <= 100 else {
            return Response(status: .badRequest)
        }

        let encoder = JSONEncoder()
        let reply = try Reply(to: request)
        var encodedReply = try encoder.encodeAsByteBuffer(reply, allocator: app.allocator)
        var buffer = app.allocator.buffer(capacity: (encodedReply.readableBytes * count) + (count - 1))
        for _ in 1..<count {
            buffer.writeBuffer(&encodedReply)
            buffer.writeString("\n")
        }
        buffer.writeBuffer(&encodedReply)

        return Response(body: .init(buffer: buffer))
    }

    app.on(.GET, "manyBytes", ":count") { request -> Response in
        guard let count = request.parameters["count", as: Int.self], count <= 10_000_000 else {
            return Response(status: .badRequest)
        }

        var buffer = request.application.allocator.buffer(capacity: count)
        buffer.writeRepeatingByte(UInt8.random(), count: count)

        return Response(body: .init(buffer: buffer))
    }

    app.on(.GET, "chunked", ":count") { request -> Response in
        guard let count = request.parameters["count", as: Int.self], count > 0, count <= 100 else {
            return Response(status: .badRequest)
        }

        let response = Response(body: .init(stream: { writer in
            var bytesToSend = count
            request.eventLoop.scheduleRepeatedTask(initialDelay: .seconds(0), delay: .milliseconds(1)) { task in
                guard bytesToSend > 0 else { task.cancel(); _ = writer.write(.end); return }

                _ = writer.write(.buffer(.init(integer: UInt8(bytesToSend))))
                bytesToSend -= 1
            }
        }, count: 0))

        response.headers.remove(name: .contentLength)
        response.headers.replaceOrAdd(name: .contentType, value: "application/octet-stream")
        return response
    }
    
    app.on(.GET, "payloads", ":count") { request -> Response in
        guard let count = request.parameters["count", as: Int.self], count > 0, count <= 100 else {
            return Response(status: .badRequest)
        }
        
        let encoder = JSONEncoder()
        let reply = try Reply(to: request)
        let encodedReply = try encoder.encodeAsByteBuffer(reply, allocator: app.allocator)
        let response = Response(body: .init(stream: { writer in
            var repliesToSend = count
            request.eventLoop.scheduleRepeatedTask(initialDelay: .seconds(0), delay: .milliseconds(1)) { task in
                guard repliesToSend > 0 else { task.cancel(); _ = writer.write(.end); return }
                
                _ = writer.write(.buffer(encodedReply))
                repliesToSend -= 1
            }
        }, count: 0))
        
        response.headers.remove(name: .contentLength)
        response.headers.replaceOrAdd(name: .contentType, value: "application/octet-stream")
        return response
    }
}
