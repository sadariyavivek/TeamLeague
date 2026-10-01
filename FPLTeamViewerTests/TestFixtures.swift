//
//  TestFixtures.swift
//  FPLTeamViewerTests
//
//  Created by Vivek Sadariya on 01/10/26.
//

@testable import FPLTeamViewer

enum TestFixtures {
    static let arsenal = TeamModel(id: 1, code: 3, name: "Arsenal", short_name: "ARS")
    static let chelsea = TeamModel(id: 2, code: 8, name: "Chelsea", short_name: "CHE")

    static let elementTypes: [ElementTypeModel] = [
        // Deliberately out of order to check sections are sorted by id.
        elementType(id: 3, plural: "Midfielders", short: "MID"),
        elementType(id: 1, plural: "Goalkeepers", short: "GKP"),
        elementType(id: 4, plural: "Forwards", short: "FWD"),
        elementType(id: 2, plural: "Defenders", short: "DEF")
    ]

    static let players: [ElementsModel] = [
        player(id: 1, first: "David", second: "Raya Martín", web: "Raya", type: 1, cost: 61, points: 30, team: 1),
        player(id: 2, first: "Kepa", second: "Arrizabalaga", web: "Kepa", type: 1, cost: 45, points: 2, team: 1),
        player(id: 3, first: "William", second: "Saliba", web: "Saliba", type: 2, cost: 60, points: 25, team: 1),
        player(id: 4, first: "Gabriel", second: "dos Santos Magalhães", web: "Gabriel", type: 2, cost: 63, points: 25, team: 1),
        player(id: 5, first: "Bukayo", second: "Saka", web: "Saka", type: 3, cost: 101, points: 40, team: 1),
        player(id: 6, first: "Martin", second: "Ødegaard", web: "Ødegaard", type: 3, cost: 80, points: 10, team: 1),
        player(id: 7, first: "Cole", second: "Palmer", web: "Palmer", type: 3, cost: 105, points: 50, team: 2)
    ]

    static let league = LegueModel(teams: [arsenal, chelsea], elements: players, element_types: elementTypes)

    static func elementType(id: Int, plural: String, short: String) -> ElementTypeModel {
        ElementTypeModel(
            id: id,
            plural_name: plural,
            plural_name_short: short,
            singular_name: String(plural.dropLast()),
            singular_name_short: short
        )
    }

    static func player(
        id: Int,
        first: String?,
        second: String?,
        web: String?,
        type: Int?,
        cost: Int?,
        points: Int?,
        team: Int?
    ) -> ElementsModel {
        ElementsModel(
            id: id,
            code: id * 1000,
            first_name: first,
            second_name: second,
            web_name: web,
            element_type: type,
            now_cost: cost,
            total_points: points,
            team: team,
            team_code: nil
        )
    }
}
