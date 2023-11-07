//
//  DetailSearchView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 6/11/2023.
//

import SwiftUI

struct DetailSearchView: View {
    var searchComp: String
    var searchDiv: String
    var teamsFound: Int
    var body: some View {
        VStack {
            Spacer()
            Text("🔍")
                .font(.system(size: 128, weight: .bold))
            Text("")
            Text("Searching ...")
                .font(.largeTitle)
            Text("")
            Text(searchComp)
            Text(searchDiv)
            Text("Teams found: \(teamsFound)")
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    DetailSearchView(searchComp: "2023 Term 4 Summer", searchDiv: "Men's Premier League - 2023", teamsFound: 5)
}
