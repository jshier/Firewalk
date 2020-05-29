//
//  Data.swift
//  
//
//  Created by Jon Shier on 5/3/20.
//

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
    
    // Doesn't work.
//    app.on(.GET, "chunked", ":count") { request -> Response in
//        guard let count = request.parameters["count", as: Int.self], count > 0, count <= 100 else {
//            return Response(status: .badRequest)
//        }
//
//        let encoder = JSONEncoder()
//        let rep = try Reply(to: request)
//        let buffer = try! encoder.encodeAsByteBuffer(rep, allocator: app.allocator)
//        let response = Response(body: .init(stream: { writer in
//            let start = writer.write(.buffer(buffer.chunked(allocator: app.allocator)))
//            var next = start
//            for _ in 1..<count {
//                next = next.flatMap {
//                    request.eventLoop.scheduleTask(in: .milliseconds(1000)) {
//                        _ = writer.write(.buffer(buffer.chunked(allocator: app.allocator)))
//                    }.futureResult
//                }
//            }
//
//            var buffer = app.allocator.buffer(capacity: 3)
//            buffer.writeString("0\r\n\r\n")
//            next = next.flatMap { writer.write(.buffer(buffer)) }
//
//            _ = next.flatMap { writer.write(.end) }
//        }, count: 0))
//        response.headers.replaceOrAdd(name: .transferEncoding, value: "chunked")
//        response.headers.replaceOrAdd(name: .contentType, value: "application/json")
//        response.headers.remove(name: .contentLength)
//        print(response)
//        return response
//    }
}

extension ByteBuffer {
    func chunked(allocator: ByteBufferAllocator) -> ByteBuffer {
        var buffer = allocator.buffer(capacity: readableBytes + 3)
        let length = String(readableBytes, radix: 16, uppercase: true)
        buffer.writeString("\(length)\r\n")
        buffer.writeBytes(getBytes(at: 0, length: readableBytes) ?? [])
        buffer.writeString("\r\n")
        
        return buffer
    }
}
