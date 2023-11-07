//
//  SelectTeamView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 24/10/2023.
//

import SwiftUI
import SwiftData

struct SelectTeamView: View {
    @Environment(\.modelContext) var context
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var sharedData: SharedData
    @State var myClub: String
    @Query var teams: [Teams]
    var myTeams: [Teams] {
        return teams.filter { team in
            return team.clubName == myClub
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
        NavigationView {
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
                                    var count = 0
                                    for index in 0 ..< teams.count {
                                        if teams[index].isCurrent == true {
                                            count = count + 1
                                            teams[index].isCurrent = false
                                        }
                                    }
                                    team.isCurrent = true
                                    team.isUsed = true
                                    if count > 0 {
                                        sharedData.activeTabIndex = 0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .accentColor(Color("AccentColor"))
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Select your team")
                    .foregroundStyle(Color("ForegroundColor"))
                    .fontWeight(.bold)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(myClub)
                    .resizable()
                    .frame(width: 45, height: 45)
            }
        }
        .toolbarBackground(Color("BackgroundColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    SelectTeamView(myClub: "MHSOB")
}
