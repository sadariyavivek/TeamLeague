//
//  APIEndpoint.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//
enum APIEndpoint {
    case getTeams
}

extension APIEndpoint: EndPointType {
    var baseURL: String {
        return "https://fantasy.premierleague.com"
    }
    
    var path: String {
        switch self {
        case .getTeams:
            "/api/bootstrap-static/"
        }
    }
}
