//
//  MockAPIManagerTests.swift
//  FPLTeamViewerTests
//
//  Created by Vivek Sadariya on 01/10/26.
//

import XCTest
@testable import FPLTeamViewer

/// Requires a key that `response.json` doesn't contain.
private struct MissingKeyResponse: Decodable {
    let players: [Int]
}

final class MockAPIManagerTests: XCTestCase {

    // MARK: - API / data decoding

    func testRequest_decodesLeagueFromLocalJSON() async throws {
        let sut = MockAPIManager(isCaching: false, isThrowError: false)

        let league = try await sut.request(endpoint: .getTeams, responseType: LegueModel.self)

        XCTAssertEqual(league.teams.count, 20)
        XCTAssertEqual(league.elements.count, 667)
        XCTAssertEqual(league.element_types.map(\.id), [1, 2, 3, 4])
    }

    func testRequest_decodesTeamFields() async throws {
        let sut = MockAPIManager(isCaching: false, isThrowError: false)

        let league = try await sut.request(endpoint: .getTeams, responseType: LegueModel.self)
        let team = try XCTUnwrap(league.teams.first)

        XCTAssertEqual(team.id, 1)
        XCTAssertEqual(team.name, "Arsenal")
        XCTAssertEqual(team.short_name, "ARS")
    }

    func testRequest_decodesPlayerFields() async throws {
        let sut = MockAPIManager(isCaching: false, isThrowError: false)

        let league = try await sut.request(endpoint: .getTeams, responseType: LegueModel.self)
        let player = try XCTUnwrap(league.elements.first)

        XCTAssertEqual(player.id, 1)
        XCTAssertEqual(player.name, "David Raya Martín")
        XCTAssertEqual(player.web_name, "Raya")
        XCTAssertEqual(player.element_type, 1)
        XCTAssertEqual(player.now_cost, 61)
        XCTAssertEqual(player.total_points, 30)
        XCTAssertEqual(player.team, 1)
    }

    func testRequest_decodesElementTypeFields() async throws {
        let sut = MockAPIManager(isCaching: false, isThrowError: false)

        let league = try await sut.request(endpoint: .getTeams, responseType: LegueModel.self)
        let goalkeepers = try XCTUnwrap(league.element_types.first)

        XCTAssertEqual(goalkeepers.plural_name, "Goalkeepers")
        XCTAssertEqual(goalkeepers.singular_name_short, "GKP")
    }

    // MARK: - Error handling

    func testRequest_whenThrowErrorIsEnabled_throwsHTTPError() async {
        let sut = MockAPIManager(isCaching: false, isThrowError: true)

        do {
            _ = try await sut.request(endpoint: .getTeams, responseType: LegueModel.self)
            XCTFail("Expected httpError to be thrown")
        } catch NetworkError.httpError(let statusCode) {
            XCTAssertEqual(statusCode, 250)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRequest_whenTypeDoesNotMatch_throwsDecodingError() async {
        let sut = MockAPIManager(isCaching: false, isThrowError: false)

        do {
            _ = try await sut.request(endpoint: .getTeams, responseType: [TeamModel].self)
            XCTFail("Expected decodingError to be thrown")
        } catch NetworkError.decodingError(let underlyingError) {
            guard case DecodingError.typeMismatch = underlyingError else {
                return XCTFail("Expected typeMismatch, got \(underlyingError)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRequest_whenRequiredKeyIsMissing_throwsDecodingError() async {
        let sut = MockAPIManager(isCaching: false, isThrowError: false)

        do {
            _ = try await sut.request(endpoint: .getTeams, responseType: MissingKeyResponse.self)
            XCTFail("Expected decodingError to be thrown")
        } catch NetworkError.decodingError(let underlyingError) {
            guard case DecodingError.keyNotFound(let key, _) = underlyingError else {
                return XCTFail("Expected keyNotFound, got \(underlyingError)")
            }
            XCTAssertEqual(key.stringValue, "players")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Caching

    func testCachedResponse_whenCachingEnabled_returnsSavedData() {
        let sut = MockAPIManager(isCaching: true, isThrowError: false)

        let cached = sut.cachedResponse(endpoint: .getTeams, responseType: LegueModel.self)

        XCTAssertEqual(cached?.teams.count, 20)
    }

    func testCachedResponse_whenCachingDisabled_returnsNil() {
        let sut = MockAPIManager(isCaching: false, isThrowError: false)

        XCTAssertNil(sut.cachedResponse(endpoint: .getTeams, responseType: LegueModel.self))
    }

    func testCachedResponse_whenTypeDoesNotMatch_returnsNil() {
        let sut = MockAPIManager(isCaching: true, isThrowError: false)

        XCTAssertNil(sut.cachedResponse(endpoint: .getTeams, responseType: MissingKeyResponse.self))
    }
}
