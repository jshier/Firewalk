import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.routes.defaultMaxBodySize = 10_000_000
    try createXMLRoute(for: app)
    try createMethodRoutes(for: app)
    try createIPRoute(for: app)
    try createBasicAuthRoutes(for: app)
    try createDigestAuthRoute(for: app)
    try createWebSocketRoutes(for: app)
    try createDataRoutes(for: app)
    try createImageRoutes(for: app)
    try createInspectionRoutes(for: app)
}
