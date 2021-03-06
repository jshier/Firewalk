//
//  DigestAuth.swift
//
//
//  Created by Jon Shier on 5/3/20.
//

import Vapor

func createDigestAuthRoute(for app: Application) throws {
//        let digestAuth = app.grouped(DigestPathAuthenticator())
//        digestAuth.on([.GET, .POST, .PUT, .PATCH, .DELETE], "digest-auth", ":user", ":passwd") { request -> EventLoopFuture<Response> in
//            guard request.isAuthenticated else {
//                var headers = HTTPHeaders()
//                let realm = "digest-auth@firewalk.alamofire.org"
//                let qop = "auth"
//                let nonce = ChaChaPoly.Nonce()
//                let opaque = DigestAuthorization.opaque
//                headers.add(name: .wwwAuthenticate, value: "Digest")
//                return request.eventLoop.makeSucceededFuture(Response(status: .unauthorized, headers: headers))
//            }
//
//            return try reply(to: request).encodeResponse(for: request)
//        }

    app.on([.GET, .POST, .PUT, .PATCH, .DELETE], "digest-auth", ":qop", ":user", ":passwd") { request -> Response in
        guard let qop = request.parameters["qop", as: String.self],
            let username = request.parameters["user", as: String.self],
            let password = request.parameters["passwd", as: String.self] else { return Response(status: .badRequest) }

        let response = Response(status: .permanentRedirect)
        response.headers.replaceOrAdd(name: .location, value: "https://httpbin.org/digest-auth/\(qop)/\(username)/\(password)")

        return response
    }
}

// struct DigestAuthorization {
//    static let opaque = "firewalkopaque"
//
//    let username: String
//    let qop: String
//    let nonce: String
//    let uri: String
//    let cnonce: String
//    let nonceCount: String
//    let oqaque: String
// }
//
// protocol DigestAuthenticator: RequestAuthenticator {
//    func authenticate(digest: DigestAuthorization, for request: Request) -> EventLoopFuture<Void>
// }
//
// extension DigestAuthenticator {
//    func authenticate(request: Request) -> EventLoopFuture<Void> {
//        guard let digestAuthorization = request.headers.digestAuthorization else {
//            return request.eventLoop.makeSucceededFuture(())
//        }
//
//        return authenticate(digest: digestAuthorization, for: request)
//    }
// }

// extension HTTPHeaders {
//    var digestAuthorization: DigestAuthorization? {
//        guard let value = first(name: .authorization) else { return nil }
//
//        let parts = value.split(separator: " ")
//        guard parts.count == 2 else { return nil }
//
//        guard parts[0] == "Digest" else { return nil }
//
//        let fields = parts[1].components(separatedBy: ",\r\n")
//        let fieldValues = fields.compactMap { field -> (name: String, value: String)? in
//            let parts = field.split(separator: "=")
//            guard parts.count == 2 else { return nil }
//            return (name: String(parts[0]), value: String(parts[1]))
//        }
//        let response = Dictionary(uniqueKeysWithValues: fieldValues)
//        guard let username = response["username"],
//            let realm = response["realm"],
//            let qop = response["qop"],
//            let nonce = response["nonce"],
//            let uri = response["uri"],
//            let cnonce = response["cnonce"],
//            let nonceCount = response["nc"],
//            let opaque = response["opaque"] else { return nil }
//
//        return DigestAuthorization(username: username,
//                                   qop: qop,
//                                   nonce: nonce,
//                                   cnonce: cnonce,
//                                   nonceCount: nonceCount,
//                                   oqaque: opaque)
//    }
// }
//
// struct DigestPathAuthenticator: DigestAuthenticator {
//    enum Error: Swift.Error { case invalidRequest, invalidCredentials }
//
//    func authenticate(digest: DigestAuthorization, for request: Request) -> EventLoopFuture<Void> {
//        guard let username = request.parameters["user", as: String.self],
//            let password = request.parameters["passwd", as: String.self] else {
//                return request.eventLoop.makeFailedFuture(Error.invalidRequest)
//        }
//
//        guard digest.username == username else {
//            return request.eventLoop.makeFailedFuture(Error.invalidCredentials)
//        }
//
//        let ha1String = "\(username):\(digest.realm):\(password)"
//        let ha1 = Insecure.MD5.hash(data: Data(ha1String.utf8))
//
//        let ha2String = "\(request.method.rawValue):"
//        let data = Data().hex
//
//
//        request.auth.login(request)
//        return request.eventLoop.makeSucceededFuture(())
//    }
// }
