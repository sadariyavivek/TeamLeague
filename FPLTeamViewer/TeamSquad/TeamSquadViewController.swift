//
//  TeamSquadViewController.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//

import UIKit

final class TeamSquadViewController: UIViewController {

    private let router: TeamSquadRouter
    private let viewModel: TeamSquadViewModel

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.register(TeamSquadCell.self, forCellReuseIdentifier: TeamSquadCell.reuseIdentifier)
        return tableView
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search players"
        return searchController
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No players found"
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.title = viewModel.team.name ?? "Team Squad"
        router.navigationController = navigationController
        setupTableView()
        setupSearch()
    }

    init(router: TeamSquadRouter, viewModel: TeamSquadViewModel) {
        self.router = router
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSearch() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}

extension TeamSquadViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.search(text: searchController.searchBar.text ?? "")
        tableView.backgroundView = viewModel.sections.isEmpty ? emptyLabel : nil
        tableView.reloadData()
    }
}

extension TeamSquadViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sections[section].elementType.plural_name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].players.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamSquadCell.reuseIdentifier, for: indexPath) as? TeamSquadCell else {
            return UITableViewCell()
        }
        let player = viewModel.sections[indexPath.section].players[indexPath.row]
        cell.configure(with: player, position: viewModel.league?.position(for: player) ?? "-")
        return cell
    }
}

extension TeamSquadViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        var background = UIBackgroundConfiguration.listPlainHeaderFooter()
        background.backgroundColor = .systemBlue.withAlphaComponent(0.15)
        header.backgroundConfiguration = background
    }
}
