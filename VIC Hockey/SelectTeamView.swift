//
//  SelectTeamView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 24/10/2023.
//

import SwiftUI
import SwiftData

struct SelectTeamView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @State var selectedText: String
    @Query (sort: \Teams.divType) var teams: [Teams]
    var myTeams: [Teams] {
        return teams.filter { team in
            return team.clubName == selectedText
        }
    }
    var mySortedTeams: [Teams] {
        return myTeams.sorted { (team1, team2) in
            if team1.divLevel == team2.divLevel {
                return team1.divName < team2.divName
            } else {
                return team1.divLevel < team2.divLevel
            }
        }
    }
    var body: some View {
        NavigationStack {
            List {
                ForEach(Dictionary(grouping: myTeams, by: { $0.divType }).sorted(by: { $0.key < $1.key }), id: \.key) { (key, divType) in
                    Section(header: Text(key).font(.largeTitle)) {
                        ForEach(mySortedTeams, id: \.self) { team in
                            if team.divType == key {
                                VStack {
                                    HStack {
                                        Text(team.divName)
                                        Spacer()
                                    }
                                    if team.clubName != team.teamName {
                                        HStack {
                                            Text(team.teamName)
                                                .font(.footnote)
                                            Spacer()
                                        }
                                    }
                                }
                                .onTapGesture {
                                    team.isCurrent = true
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(selectedText)
                        .fontWeight(.bold)
                        .font(.footnote)
                        .foregroundStyle(Color(.white))
                    Text("Select your team")
                        .foregroundStyle(Color(.white))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(selectedText)
                    .resizable()
                    .frame(width: 45, height: 45)
            }
        }
        .toolbarBackground(Color("VICBlue"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    SelectTeamView(selectedText: "MHSOB")
}
