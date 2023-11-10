//
//  ScheduleView2.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 1/11/2023.
//

import SwiftUI
import SwiftData

struct ScheduleView: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject private var sharedData: SharedData
    @State private var errURL = ""
    @State private var rounds = [Round]()
    @State private var haveData = false
    @Query(filter: #Predicate<Teams> {$0.isCurrent} ) var currentTeam: [Teams]
    var body: some View {
        if !currentTeam.isEmpty {
            NavigationStack {
                VStack {
                    if !haveData {
                        LoadingView()
                            .task { await myloadData() }
                    } else {
                        if errURL != "" {
                            InvalidURLView(url: errURL)
                        } else {
                            List {
                                ForEach(["Upcoming", "Completed"], id: \.self) { played in
                                    let filteredRounds = rounds.filter { $0.played == played }
                                    if !filteredRounds.isEmpty {
                                        Section(header: Text(played)) {
                                            ForEach(filteredRounds, id: \.id) { item in
                                                if !currentTeam.isEmpty {
                                                    if item.opponent == "BYE" {
                                                        DetailScheduleView(myTeam: currentTeam[0].teamName, round: item)
                                                    } else {
                                                        NavigationLink(destination: GameView(gameNumber: item.game, myTeam: currentTeam[0].teamName, myTeamID: currentTeam[0].teamID)) {
                                                            DetailScheduleView(myTeam: currentTeam[0].teamName, round: item)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                            .refreshable {
                                sharedData.refreshSchedule = true
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(currentTeam[0].divName)
                            .foregroundStyle(Color("ForegroundColor"))
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color("AccentColor"))
                            .font(.title3)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(ShortClubName(fullName: currentTeam[0].teamName))
                            .resizable()
                            .frame(width: 45, height: 45)
                    }
                }
                .padding(.horizontal, -8)
                .toolbarBackground(Color("BackgroundColor"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color("BackgroundColor"), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            }
            .onAppear() {
                if sharedData.refreshSchedule {
                    haveData = false
                }
            }
        }
    }
    func myloadData() async {
        (rounds, errURL) = GetSchedData(mycompID: currentTeam[0].compID, myTeamID: currentTeam[0].teamID, myTeamName: currentTeam[0].teamName)
        sharedData.refreshSchedule = false
        haveData = true
        
    }
}

#Preview {
    ScheduleView()
}
