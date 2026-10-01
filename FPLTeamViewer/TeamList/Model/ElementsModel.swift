//
//  ElementsModel.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//
struct ElementsModel: Decodable {
    let id: Int?
    let code: Int?
    let first_name: String?
    let second_name: String?
    let web_name: String?
    let element_type: Int?
    let now_cost: Int?
    let total_points: Int?
    let team: Int?
    let team_code: Int?
}

extension ElementsModel {
    var name: String {
        [first_name, second_name]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    func position(in elementTypes: [ElementTypeModel]) -> String {
        elementTypes.first { $0.id == element_type }?.singular_name_short ?? "-"
    }
}

struct ElementTypeModel: Decodable {
    let id: Int?
    let plural_name: String?
    let plural_name_short: String?
    let singular_name: String?
    let singular_name_short: String?
}
