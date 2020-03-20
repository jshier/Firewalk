import Vapor

func routes(_ app: Application) throws {
    func reply(to request: Request) throws -> Reply {
        Reply(url: request.url.string,
              origin: request.remoteAddress?.description ?? "No remote address.",
              headers: request.headers,
              data: (request.body.string?.isEmpty == true) ? nil : request.body.string,
              form: try? request.content.get([String: String].self, at: []),
              args: try request.query.get([String: String].self, at: []))
    }

    app.onMethods([.GET, .POST, .DELETE, .PATCH, .PUT], use: reply(to:))

    app.on([.GET, .POST, .PUT, .PATCH, .DELETE], "delay", ":interval") { request -> EventLoopFuture<Reply> in
        if let interval = request.parameters["interval", as: Int64.self] {
            let scheduled = request.eventLoop.scheduleTask(in: .seconds(min(interval, 10))) { try reply(to: request) }

            return scheduled.futureResult
        }

        return request.eventLoop.future(try reply(to: request))
    }

    app.webSocket("websocket") { _, socket in
        socket.send("reply")
        socket.close(code: .goingAway)
    }
}

struct Reply: Content {
    let date = Date()
    let url: String
    let origin: String
    let headers: HTTPHeaders
    let data: String?
    let form: [String: String]?
    let args: [String: String]
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

extension Parameters {
    subscript<T>(_ name: String, as _: T.Type = T.self) -> T? where T: LosslessStringConvertible {
        `get`(name)
    }
}
