//
//  LegueModelTests.swift
//  FPLTeamViewerTests
//
//  Created by Vivek Sadariya on 01/10/26.
//

import XCTest
@testable import FPLTeamViewer

/// Team/player data transformation.
final class LegueModelTests: XCTestCase {

    private let league = TestFixtures.league

    // MARK: - getPlayers(for:)

    func testGetPlayers_returnsOnlyPlayersOfThatTeam() {
        let players = league.getPlayers(for: TestFixtures.arsenal)

        XCTAssertEqual(players.count, 6)
        XCTAssertTrue(players.allSatisfy { $0.team == TestFixtures.arsenal.id })
    }

    func testGetPlayers_forTeamWithoutPlayers_returnsEmpty() {
        let unknownTeam = TeamModel(id: 99, code: 99, name: "Unknown", short_name: "UNK")

        XCTAssertTrue(league.getPlayers(for: unknownTeam).isEmpty)
    }

    // MARK: - makeSections(for:)

    func testMakeSections_groupsByPositionInOrder() {
        let sections = league.makeSections(for: TestFixtures.arsenal)

        XCTAssertEqual(
            sections.map(\.elementType.plural_name),
            ["Goalkeepers", "Defenders", "Midfielders"]
        )
    }

    func testMakeSections_skipsPositionsWithNoPlayers() {
        let sections = league.makeSections(for: TestFixtures.arsenal)

        XCTAssertFalse(sections.contains { $0.elementType.id == 4 })
    }

    func testMakeSections_eachSectionOnlyContainsItsPosition() {
        let sections = league.makeSections(for: TestFixtures.arsenal)

        for section in sections {
            XCTAssertTrue(section.players.allSatisfy { $0.element_type == section.elementType.id })
        }
    }

    func testMakeSections_ordersPlayersByTotalPointsDescending() {
        let sections = league.makeSections(for: TestFixtures.arsenal)
        let goalkeepers = sections.first { $0.elementType.id == 1 }

        XCTAssertEqual(goalkeepers?.players.map(\.id), [1, 2])
    }

    func testMakeSections_withEqualPoints_ordersByName() {
        let sections = league.makeSections(for: TestFixtures.arsenal)
        let defenders = sections.first { $0.elementType.id == 2 }

        // Both have 25 points; "Gabriel…" comes before "William…".
        XCTAssertEqual(defenders?.players.map(\.id), [4, 3])
    }

    func testMakeSections_treatsMissingPointsAsZero() {
        let players = [
            TestFixtures.player(id: 1, first: "No", second: "Points", web: nil, type: 3, cost: 50, points: nil, team: 1),
            TestFixtures.player(id: 2, first: "Some", second: "Points", web: nil, type: 3, cost: 50, points: 1, team: 1)
        ]
        let league = LegueModel(teams: [TestFixtures.arsenal], elements: players, element_types: TestFixtures.elementTypes)

        let sections = league.makeSections(for: TestFixtures.arsenal)

        XCTAssertEqual(sections.first?.players.map(\.id), [2, 1])
    }

    // MARK: - position(for:)

    func testPosition_returnsShortPositionName() {
        let saka = TestFixtures.players[4]

        XCTAssertEqual(league.position(for: saka), "MID")
    }

    func testPosition_forUnknownElementType_returnsDash() {
        let player = TestFixtures.player(id: 99, first: "A", second: "B", web: nil, type: 9, cost: 50, points: 0, team: 1)

        XCTAssertEqual(league.position(for: player), "-")
    }

    // MARK: - ElementsModel.name

    func testName_joinsFirstAndSecondName() {
        XCTAssertEqual(TestFixtures.players[0].name, "David Raya Martín")
    }

    func testName_withMissingFirstName_usesSecondNameOnly() {
        let player = TestFixtures.player(id: 1, first: nil, second: "Saka", web: nil, type: 3, cost: 50, points: 0, team: 1)

        XCTAssertEqual(player.name, "Saka")
    }
}
