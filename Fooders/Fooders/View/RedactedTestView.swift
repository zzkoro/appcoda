//
//  RedactedTestView.swift
//  Fooders
//
//  Created by junemp on 2022/02/06.
//

import SwiftUI

struct RedactedTestView: View {
    @StateObject var repoStore = RepoStore(service: .init())
    
    var body: some View {
        
        List(repoStore.repos, id: \.self) { repo in
            RepoView(repo: repo)
        }
        .onAppear {
            repoStore.fetch(matching: "SwiftUI")
        }
        .redacted(reason: repoStore.isLoading ? .placeholder :.init())
    }
}

//struct Repo: Hashable, Decodable {
//    let name: String
//    let description: String
//    let stars: Int
//}

//struct Repo {
//    let name: String
//    let description: String
//    let stars: Int
//}

extension Repo {
    static let mock = Repo(
        id: 1,
        name: "SwiftUICharts",
        description: "A simple line and bar charting library that support",
        forks: 579
    )
}

struct RepoView: View {
    let repo: Repo
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .unredacted()
                Text(String(repo.forks))
                    .font(.title)
            }
            .foregroundColor(.red)
            
            VStack(alignment: .leading) {
                Text(repo.name)
                    .font(.headline)
                Text(repo.description)
                    .foregroundColor(.secondary)
                
            }
        }
    }
}


struct RedactedTestView_Previews: PreviewProvider {
    static var previews: some View {
        RedactedTestView()
    }
}
