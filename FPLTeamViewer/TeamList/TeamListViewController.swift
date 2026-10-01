//
//  TeamListViewController.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//

import UIKit
import Combine

final class TeamListViewController: UIViewController {

    private let router: TeamListRouter
    private let viewModel: TeamListViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.register(TeamListCell.self, forCellReuseIdentifier: TeamListCell.reuseIdentifier)
        tableView.refreshControl = refreshControl
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Retry", for: .normal)
        button.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        return button
    }()

    private lazy var messageView: UIView = {
        let stackView = UIStackView(arrangedSubviews: [messageLabel, retryButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24)
        ])
        return container
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.title = "Team List"
        router.navigationController = navigationController
        setupTableView()
        bindViewModel()
        fetchTeams()
    }

    init(router: TeamListRouter, viewModel: TeamListViewModel) {
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

    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    private func render(_ state: ViewState) {
        switch state {
        case .initialLoading:
            tableView.backgroundView = loadingIndicator
        case .loaded:
            tableView.backgroundView = nil
            refreshControl.endRefreshing()
        case .initialFailure(let message):
            showMessage(message, showsRetry: true)
            refreshControl.endRefreshing()
        case .refreshing:
            if !refreshControl.isRefreshing {
                refreshControl.beginRefreshing()
            }
        case .refreshFailure(let message):
            refreshControl.endRefreshing()
            showRefreshFailureAlert(message: message)
        case .empty:
            showMessage("No teams found", showsRetry: false)
            refreshControl.endRefreshing()
        }
        tableView.reloadData()
    }

    private func showMessage(_ message: String, showsRetry: Bool) {
        messageLabel.text = message
        retryButton.isHidden = !showsRetry
        tableView.backgroundView = messageView
    }

    private func showRefreshFailureAlert(message: String) {
        let alert = UIAlertController(title: "Couldn't Refresh", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func fetchTeams(isRefreshing: Bool = false) {
        Task { [weak self] in
            await self?.viewModel.getTeamList(isRefreshing: isRefreshing)
        }
    }

    @objc private func didPullToRefresh() {
        fetchTeams(isRefreshing: true)
    }

    @objc private func didTapRetry() {
        fetchTeams()
    }
}

// MARK: - UITableViewDataSource

extension TeamListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.teams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamListCell.reuseIdentifier, for: indexPath) as? TeamListCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.teams[indexPath.row], league: viewModel.league)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TeamListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        router.openTeamSquad(team: viewModel.teams[indexPath.row], league: viewModel.league)
    }
}

// MARK: - TeamListCell

