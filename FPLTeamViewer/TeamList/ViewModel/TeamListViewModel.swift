//
//  TeamListViewModel.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//
import Combine

final class TeamListViewModel {
    @Published private(set) var teams: [TeamModel] = []
    @Published private(set) var league: LegueModel?
    @Published private(set) var state: ViewState = .initialLoading

    private let service: APIService

    init(service: APIService) {
        self.service = service
    }

    func getTeamList(isRefreshing: Bool = false) async {
        state = isRefreshing ? .refreshing : .initialLoading
        do {
            let data = try await service.request(endpoint: .getTeams, responseType: LegueModel.self)
            apply(data)
            self.state = data.teams.isEmpty ? .empty : .loaded
        } catch {
            let message = errorMessage(for: error)
            print(message)
            // On failure, fall back to the last saved response if there is one.
            if let cached = service.cachedResponse(endpoint: .getTeams, responseType: LegueModel.self),
               !cached.teams.isEmpty {
                apply(cached)
                self.state = .refreshFailure(message: "\(message)\nShowing previously saved data.")
            } else {
                // Keep showing existing data if a refresh fails.
                self.state = isRefreshing && !teams.isEmpty
                    ? .refreshFailure(message: message)
                    : .initialFailure(message: message)
            }
        }
    }

    private func apply(_ data: LegueModel) {
        self.teams = data.teams
        self.league = data
    }

    private func errorMessage(for error: Error) -> String {
        guard let error = error as? NetworkError else {
            return "Unexpected error: \(error.localizedDescription)"
        }
        switch error {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError(let decodingError):
            return "Decoding failed: \(decodingError)"
        }
    }
}
