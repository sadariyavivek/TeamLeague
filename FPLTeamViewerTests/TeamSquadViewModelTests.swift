//
//  TeamSquadViewModelTests.swift
//  FPLTeamViewerTests
//
//  Created by Vivek Sadariya on 01/10/26.
//

import XCTest
@testable import FPLTeamViewer

/// Player filtering/search.
final class TeamSquadViewModelTests: XCTestCase {

    private var sut: TeamSquadViewModel!

    override func setUp() {
        super.setUp()
        sut = TeamSquadViewModel(team: TestFixtures.arsenal, league: TestFixtures.league)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private var visiblePlayerIDs: [Int?] {
        sut.sections.flatMap(\.players).map(\.id)
    }

    func testInit_showsAllPlayersOfTheTeam() {
        XCTAssertEqual(visiblePlayerIDs.count, 6)
        XCTAssertEqual(sut.sections.count, 3)
    }

    func testInit_withoutLeague_hasNoSections() {
        let sut = TeamSquadViewModel(team: TestFixtures.arsenal, league: nil)

        XCTAssertTrue(sut.sections.isEmpty)
    }

    func testSearch_matchesFullName() {
        sut.search(text: "Saka")

        XCTAssertEqual(visiblePlayerIDs, [5])
    }

    func testSearch_isCaseInsensitive() {
        sut.search(text: "sALiBa")

        XCTAssertEqual(visiblePlayerIDs, [3])
    }

    func testSearch_isDiacriticInsensitive() {
        sut.search(text: "martin")

        // "Raya Martín" and "Martin Ødegaard".
        XCTAssertEqual(Set(visiblePlayerIDs), [1, 6])
    }

    func testSearch_matchesPartialName() {
        sut.search(text: "ga")

        // Gabriel, Ødegaard, Arrizabalaga.
        XCTAssertEqual(Set(visiblePlayerIDs), [2, 4, 6])
    }

    func testSearch_matchesWebName() {
        let player = TestFixtures.player(id: 10, first: "Gabriel", second: "Martinelli Silva", web: "Martinelli", type: 3, cost: 70, points: 5, team: 1)
        let league = LegueModel(teams: [TestFixtures.arsenal], elements: [player], element_types: TestFixtures.elementTypes)
        let sut = TeamSquadViewModel(team: TestFixtures.arsenal, league: league)

        sut.search(text: "Martinelli")

        XCTAssertEqual(sut.sections.flatMap(\.players).map(\.id), [10])
    }

    func testSearch_doesNotIncludePlayersFromOtherTeams() {
        sut.search(text: "Palmer")

        XCTAssertTrue(sut.sections.isEmpty)
    }

    func testSearch_removesSectionsWithoutMatches() {
        sut.search(text: "Raya")

        XCTAssertEqual(sut.sections.map(\.elementType.id), [1])
    }

    func testSearch_keepsPointsOrderWithinSection() {
        sut.search(text: "a")

        let midfielders = sut.sections.first { $0.elementType.id == 3 }
        XCTAssertEqual(midfielders?.players.map(\.id), [5, 6])
    }

    func testSearch_withNoMatch_returnsEmptySections() {
        sut.search(text: "zzz")

        XCTAssertTrue(sut.sections.isEmpty)
    }

    func testSearch_withEmptyOrWhitespaceText_showsAllPlayers() {
        sut.search(text: "Saka")
        sut.search(text: "   ")

        XCTAssertEqual(visiblePlayerIDs.count, 6)
    }

    func testSearch_trimsWhitespace() {
        sut.search(text: "  Saka  ")

        XCTAssertEqual(visiblePlayerIDs, [5])
    }
}
