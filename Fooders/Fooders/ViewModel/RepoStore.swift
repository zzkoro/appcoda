//
//  RepoViewModel.swift
//  Fooders
//
//  Created by junemp on 2022/02/06.
//

import Foundation
import Combine

final class RepoStore: ObservableObject {
    @Published private(set) var repos: [Repo]
    @Published private(set) var isLoading = false
    
    private let service: GithubService
    
    init(service: GithubService, initialState: [Repo] = Array(repeating: .mock, count: 5)) {
        self.service = service
        self.repos = initialState
    }
    
    func fetch(matching query: String) {
        isLoading = true
        service.search(matching: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let repos):
                    self?.repos = repos
                    self?.isLoading = false
                case .failure:
                    self?.repos = []
                    self?.isLoading = false
                    print("fetch failed: \(result)")
                }
            }
        }
    }
}
