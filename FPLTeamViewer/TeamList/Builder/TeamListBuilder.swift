//
//  TeamListBuilder.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//
import UIKit

final class TeamListBuilder: Buildable {
    func build() -> TeamListViewController {
        let view = viewBuilder(router: buildRouter())
        return view
    }

    func buildRouter() -> TeamListRouter {
        TeamListRouter()
    }
    
    func buildViewModel() -> TeamListViewModel {
        TeamListViewModel(service: APIManager())
    }

    private func viewBuilder(router: TeamListRouter) -> TeamListViewController {
        let vc = TeamListViewController(router: router, viewModel: buildViewModel())
        return vc
    }
}




