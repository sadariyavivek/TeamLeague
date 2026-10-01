//
//  TeamSquadBuilder.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//
import UIKit

final class TeamSquadBuilder: Buildable {
    private let team: TeamModel
    private let league: LegueModel?

    init(team: TeamModel, league: LegueModel?) {
        self.team = team
        self.league = league
    }

    func build() -> TeamSquadViewController {
        let view = viewBuilder(router: buildRouter())
        return view
    }

    func buildRouter() -> TeamSquadRouter {
        TeamSquadRouter()
    }

    func buildViewModel() -> TeamSquadViewModel {
        TeamSquadViewModel(team: team, league: league)
    }

    private func viewBuilder(router: TeamSquadRouter) -> TeamSquadViewController {
        let vc = TeamSquadViewController(router: router, viewModel: buildViewModel())
        return vc
    }
}
