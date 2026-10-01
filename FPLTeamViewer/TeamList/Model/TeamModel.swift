//
//  TeamModel.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//
struct TeamModel: Decodable {
    let id, code: Int?
    let name, short_name: String?
}
