@testable import App
import Vapor
import XCTest

final class AppTests: XCTestCase {
    static let allTests = [
        ("testHost", testHost)
    ]
    
    var app: Application!
    
    override func setUp() {
        app = try! Application.testable()
    }
    
    override func tearDown() {
        try? app.syncShutdownGracefully()
    }
    
    func testHost() throws {
        let tokenResponse = try app.sendRequest(to: "/users/login", method: .GET)
        XCTAssertEqual(tokenResponse.http.status.code, 401)
    }
    
    func testLocationQuery() throws {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentID, value: "1234")
        let response = try app.sendRequest(to: "festivals/events?distance=10000&geoPoint%5Blongitude%5D=151.211&geoPoint%5Blatitude%5D=-33.8634", method: .GET, headers: headers)
        XCTAssertEqual(response.http.status.code, 200)
    }
}
