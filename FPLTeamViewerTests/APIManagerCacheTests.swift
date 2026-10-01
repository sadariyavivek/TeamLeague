//
//  APIManagerCacheTests.swift
//  FPLTeamViewerTests
//
//  Created by Vivek Sadariya on 01/10/26.
//

import XCTest
@testable import FPLTeamViewer

/// Disk cache read path of the real `APIManager` (no network involved).
final class APIManagerCacheTests: XCTestCase {

    private var sut: APIManager!

    /// Must match `APIManager.cacheFileURL(for:)`.
    private var cacheURL: URL {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(APIEndpoint.getTeams).json")
    }

    override func setUp() {
        super.setUp()
        sut = APIManager()
        try? FileManager.default.removeItem(at: cacheURL)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: cacheURL)
        sut = nil
        super.tearDown()
    }

    func testCachedResponse_withNoSavedFile_returnsNil() {
        XCTAssertNil(sut.cachedResponse(endpoint: .getTeams, responseType: LegueModel.self))
    }

    func testCachedResponse_withSavedFile_returnsDecodedData() throws {
        let fixtureURL = try XCTUnwrap(Bundle.main.url(forResource: "response", withExtension: "json"))
        try Data(contentsOf: fixtureURL).write(to: cacheURL)

        let cached = sut.cachedResponse(endpoint: .getTeams, responseType: LegueModel.self)

        XCTAssertEqual(cached?.teams.count, 20)
        XCTAssertEqual(cached?.elements.count, 667)
    }

    func testCachedResponse_withCorruptFile_returnsNil() throws {
        try Data("not json".utf8).write(to: cacheURL)

        XCTAssertNil(sut.cachedResponse(endpoint: .getTeams, responseType: LegueModel.self))
    }
}
