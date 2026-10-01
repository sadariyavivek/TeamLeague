//
//  LegueModel.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//
struct LegueModel: Decodable {
    let teams: [TeamModel]
    let elements: [ElementsModel]
    let element_types: [ElementTypeModel]
}

extension LegueModel {
    func getPlayers(for team: TeamModel) -> [ElementsModel] {
        return self.elements.filter { $0.team == team.id }
    }

    func position(for player: ElementsModel) -> String {
        player.position(in: element_types)
    }

    func makeSections(for team: TeamModel) -> [SquadSectionModel] {
        let players = getPlayers(for: team)

        return element_types
            .sorted { ($0.id ?? 0) < ($1.id ?? 0) }
            .compactMap { elementType in
                let groupedPlayers = players
                    .filter { $0.element_type == elementType.id }
                    .sorted {
                        let lhsPoints = $0.total_points ?? 0
                        let rhsPoints = $1.total_points ?? 0
                        if lhsPoints != rhsPoints {
                            return lhsPoints > rhsPoints
                        }
                        return $0.name < $1.name
                    }
                guard !groupedPlayers.isEmpty else { return nil }
                return SquadSectionModel(elementType: elementType, players: groupedPlayers)
            }
    }
}
