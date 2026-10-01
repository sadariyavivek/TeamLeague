//
//  ViewState.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//

enum ViewState: Equatable {
    case initialLoading
    case loaded
    case initialFailure(message: String)
    case refreshing
    case refreshFailure(message: String)
    case empty
}
