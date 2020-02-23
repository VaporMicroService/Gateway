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
            throw Abort(.custom(code: 511, reasonPhrase: "Gateway host url is missing"))
        }
        
        let route = host.appendingPathComponent(req.http.url.path)
        var components = URLComponents(url: route, resolvingAgainstBaseURL: false)
        
        if let query = req.http.url.query {
            components?.query = query
        }

        guard let url = components?.url else {
            throw Abort(.custom(code: 511, reasonPhrase: "Unable to create URL from the components."))
        }
        
        req.http.url = url
        req.http.headers.replaceOrAdd(name: "host", value: host.absoluteString)
        return authenticated(to: req, with: client)?.flatMap {
            return client.send($0)
        } ?? client.send(req)
    }
    
    func authenticated(to request: Request, with client: Client) -> Future<Request>? {
        struct ObjectIdentifier: Content {
            var id: Int
        }
        
        guard let url = Environment.get("AUTH") else {
            print("🚪 AUTH env. variable is missing.")
            return nil
        }
        
        guard let bearer = request.http.headers.firstValue(name: .authorization), bearer.starts(with: "Bearer ")  else {
            print("🚪 Skipping auth, bearer authorization header missing")
            return nil
        }

        return client.send(.GET, headers: request.http.headers, to: url).map { response -> Request in
            print("Requesting user id with status: \(response.http.status)")
            if let identifier = try? response.content.syncDecode(ObjectIdentifier.self) {
                request.http.headers.add(name: .contentID, value: String(identifier.id))
            }
            return request
        }
    }
}
