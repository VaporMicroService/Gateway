import Vapor

final class GatewayController {
    //MARK: Boot
    func boot(router: Router) throws {
        router.get(PathComponent.catchall, use: handler)
        router.post(PathComponent.catchall, use: handler)
        router.delete(PathComponent.catchall, use: handler)
        router.put(PathComponent.catchall, use: handler)
        router.patch(PathComponent.catchall, use: handler)
    }
    
    //MARK: Route Handler
    func handler(_ req: Request) throws -> Future<Response> {
        guard
            let service = req.http.urlString.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true).first,
            let hostData = Environment.get("HOST_\(service)")
            else { throw Abort(.badRequest) }
        let configuration = try JSONDecoder().decode(ServiceConfiguration.self, from: hostData.convertToData())
        return try handler(req, configuration: configuration)
    }
    
    func handler(_ req: Request, configuration: ServiceConfiguration) throws -> Future<Response> {
        let client = try req.make(Client.self)
        guard let host = configuration.host else {
            throw Abort(.internalServerError)
        }
        req.http.url = host.appendingPathComponent(req.http.urlString)
        req.http.headers.replaceOrAdd(name: "host", value: host.absoluteString)
        if configuration.loginRequired {
            return try authenticated(to: req, with: client).flatMap {
                return client.send($0)
            }
        }
        return client.send(req)
    }
    
    func authenticated(to request: Request, with client: Client) throws -> Future<Request> {
        struct ObjectIdentifier: Content {
            var id: Int
        }
        
        guard let url = Environment.get("AUTH") else { throw Abort(.badRequest) }
        
        var headers = HTTPHeaders()
        if let bearer = request.http.headers.bearerAuthorization {
            headers.replaceOrAdd(name: .authorization, value: "Bearer \(bearer.token)")
        }
        return client.send(.GET, headers: headers, to: url).map { response -> Request in
            let identifier = try response.content.syncDecode(ObjectIdentifier.self)
            request.http.headers.add(name: .contentID, value: String(identifier.id))
            return request
        }
    }
}
