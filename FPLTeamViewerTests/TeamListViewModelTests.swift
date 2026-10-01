//
//  TeamListViewModelTests.swift
//  FPLTeamViewerTests
//
//  Created by Vivek Sadariya on 01/10/26.
//

import XCTest
@testable import FPLTeamViewer

/// Returns a league with no teams, for the empty-results state.
private final class EmptyAPIService: APIService {
    private let emptyLeague = LegueModel(teams: [], elements: [], element_types: [])

    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        try XCTUnwrap(emptyLeague as? T)
    }

    func cachedResponse<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) -> T? {
        nil
    }
}

/// Error handling, view states and the cache fallback.
final class TeamListViewModelTests: XCTestCase {

    // MARK: - Success

    func testGetTeamList_onSuccess_loadsTeamsAndLeague() async {
        let sut = TeamListViewModel(service: MockAPIManager(isCaching: false, isThrowError: false))

        await sut.getTeamList()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.teams.count, 20)
        XCTAssertEqual(sut.league?.elements.count, 667)
    }

    func testGetTeamList_withNoTeams_isEmpty() async {
        let sut = TeamListViewModel(service: EmptyAPIService())

        await sut.getTeamList()

        XCTAssertEqual(sut.state, .empty)
        XCTAssertTrue(sut.teams.isEmpty)
    }

    func testInitialState_isInitialLoading() {
        let sut = TeamListViewModel(service: MockAPIManager(isCaching: false, isThrowError: false))

        XCTAssertEqual(sut.state, .initialLoading)
    }

    // MARK: - Error handling

    func testGetTeamList_onFailureWithoutCache_isInitialFailure() async {
        let sut = TeamListViewModel(service: MockAPIManager(isCaching: false, isThrowError: true))

        await sut.getTeamList()

        XCTAssertEqual(sut.state, .initialFailure(message: "HTTP error with status code: 250"))
        XCTAssertTrue(sut.teams.isEmpty)
        XCTAssertNil(sut.league)
    }

    func testRefresh_onFailureWithExistingData_keepsDataAndIsRefreshFailure() async {
        let service = MockAPIManager(isCaching: false, isThrowError: false)
        let sut = TeamListViewModel(service: service)
        await sut.getTeamList()

        service.isThrowError = true
        await sut.getTeamList(isRefreshing: true)

        XCTAssertEqual(sut.state, .refreshFailure(message: "HTTP error with status code: 250"))
        XCTAssertEqual(sut.teams.count, 20)
    }

    func testRefresh_onFailureWithoutData_isInitialFailure() async {
        let sut = TeamListViewModel(service: MockAPIManager(isCaching: false, isThrowError: true))

        await sut.getTeamList(isRefreshing: true)

        XCTAssertEqual(sut.state, .initialFailure(message: "HTTP error with status code: 250"))
    }

    func testRetry_afterFailure_loadsTeams() async {
        let service = MockAPIManager(isCaching: false, isThrowError: true)
        let sut = TeamListViewModel(service: service)
        await sut.getTeamList()

        service.isThrowError = false
        await sut.getTeamList()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.teams.count, 20)
    }

    // MARK: - Caching

    func testGetTeamList_onFailureWithCache_showsCachedData() async {
        let sut = TeamListViewModel(service: MockAPIManager(isCaching: true, isThrowError: true))

        await sut.getTeamList()

        XCTAssertEqual(
            sut.state,
            .refreshFailure(message: "HTTP error with status code: 250\nShowing previously saved data.")
        )
        XCTAssertEqual(sut.teams.count, 20)
        XCTAssertNotNil(sut.league)
    }

    func testGetTeamList_onSuccess_doesNotUseCache() async {
        let sut = TeamListViewModel(service: MockAPIManager(isCaching: true, isThrowError: false))

        await sut.getTeamList()

        XCTAssertEqual(sut.state, .loaded)
    }
}
