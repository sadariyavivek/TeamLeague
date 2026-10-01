//
//  TeamSquadViewModel.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//
import Foundation

final class TeamSquadViewModel {
    let team: TeamModel
    let league: LegueModel?
    private(set) var sections: [SquadSectionModel] = []
    private let allSections: [SquadSectionModel]

    init(team: TeamModel, league: LegueModel?) {
        self.team = team
        self.league = league
        self.allSections = league?.makeSections(for: team) ?? []
        self.sections = allSections
    }

    func search(text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            sections = allSections
            return
        }

        sections = allSections.compactMap { section in
            let players = section.players.filter { player in
                [player.name, player.web_name ?? ""].contains {
                    $0.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                }
            }
            guard !players.isEmpty else { return nil }
            return SquadSectionModel(elementType: section.elementType, players: players)
        }
    }
}
