//
//  Buildable.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//


protocol Buildable {
    associatedtype ViewController
    associatedtype Router
    associatedtype ViewModel

    func build() -> ViewController
    func buildRouter() -> Router
    func buildViewModel() -> ViewModel
}
