//
//  TeamListRouter.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//

import UIKit

final class TeamListRouter {
    weak var navigationController: UINavigationController?

    func openTeamSquad(team: TeamModel, league: LegueModel?) {
        let teamSquadViewController = TeamSquadBuilder(team: team, league: league).build()
        navigationController?.pushViewController(teamSquadViewController, animated: true)
    }
}
