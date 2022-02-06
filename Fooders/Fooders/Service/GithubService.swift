//
//  GithubService.swift
//  Fooders
//
//  Created by junemp on 2022/02/06.
//

import Foundation

struct Repo: Decodable, Hashable {
    var id: Int
    let name: String
    let description: String
    let forks: Int
}

struct SearchResponse: Decodable {
    let items: [Repo]
}

class GithubService {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    func search(matching query: String, handler: @escaping (Result<[Repo], Error>) -> Void) {
        guard var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")
        else {
            preconditionFailure("Can't create url components...")
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        
        guard let url = urlComponents.url
        else {
            preconditionFailure("Can't create url from url components...")
        }
    
        session.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    let response = try self?.decoder.decode(SearchResponse.self, from: data)
                    handler(.success(response?.items ?? []))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
}
