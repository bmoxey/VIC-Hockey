//
//  StatisticsView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 9/11/2023.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject private var sharedData: SharedData
    @Environment(\.colorScheme) var colorScheme
    @State private var errURL = ""
    @State private var players = [Player]()
    @State private var sortedByName = true
    @State private var haveData = false
    @State private var sortedByNameValue: KeyPath<Player, String> = \Player.surname
    @State private var sortedByValue: KeyPath<Player, Int>? = nil
    @State private var sortAscending = true
    @State private var sortMode = 2
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
                                Section(header: Text("\(currentTeam[0].teamName) Stats")) {
                                    HStack {
                                        Button(action: {
                                            if sortMode == 1 {
                                                sortAscending.toggle()
                                            } else {
                                                sortedByNameValue = \Player.name
                                                sortedByName = true
                                                sortAscending = true
                                                sortedByValue = nil
                                                sortMode = 1
                                            }
                                        }) {
                                            Text(sortMode == 1 ? sortAscending ? "First▼" : "First▲" : "First")
                                                .font(.footnote)
                                                .padding(.all, 0)
                                                .foregroundStyle(Color(.gray))
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        Button(action: {
                                            if sortMode == 2 {
                                                sortAscending.toggle()
                                            } else {
                                                sortedByNameValue = \Player.surname
                                                sortedByName = true
                                                sortAscending = true
                                                sortedByValue = nil
                                                sortMode = 2
                                            }
                                        }) {
                                            Text(sortMode == 2 ? sortAscending ? "Surname▼" : "Surname▲" : "Surname")
                                                .font(.footnote)
                                                .padding(.all, 0)
                                                .foregroundStyle(Color(.gray))
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        Spacer()
                                        Button(action: {
                                            if sortMode == 3 {
                                                sortAscending.toggle()
                                            } else {
                                                sortedByValue = \Player.goals
                                                sortedByName = false
                                                sortAscending = false
                                                sortMode = 3
                                            }
                                        }) {
                                            Text(sortMode == 3 ? sortAscending ? "Goals▲" :"Goals▼" : "Goals" )
                                                .font(.footnote)
                                                .foregroundStyle(Color(.gray))
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        Button(action: {
                                            if sortMode == 4 {
                                                sortAscending.toggle()
                                            } else {
                                                sortedByValue = \Player.numberGames
                                                sortedByName = false
                                                sortAscending = false
                                                sortMode = 4
                                            }
                                        }) {
                                            Text(sortMode == 4 ? sortAscending ? "Games▲" :"Games▼" : "Games" )
                                                .font(.footnote)
                                                .foregroundStyle(Color(.gray))
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    ForEach(players.sorted(by: sortDescriptor)) { player in
                                        NavigationLink(destination: PlayerStatsView(myTeam: currentTeam[0].teamName, myTeamID: currentTeam[0].teamID, player: player)) {
                                            DetailStatsView(player: player)
                                        }
                                    }
                                }
                            }
                            .refreshable {
                                sharedData.refreshStats = true
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(currentTeam[0].divName)
                            .foregroundStyle(Color("BarForeground"))
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundStyle(Color.white)
                            .font(.title3)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(ShortClubName(fullName: currentTeam[0].teamName))
                            .resizable()
                            .frame(width: 45, height: 45)
                    }
                }
                .padding(.horizontal, -8)
                .toolbarBackground(Color("BarBackground"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color("BarBackground"), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            }
            .onAppear() {
                if sharedData.refreshStats {
                    haveData = false
                }
            }
        }
    }
        
        
    private var sortDescriptor: (Player, Player) -> Bool {
        let ascending = sortAscending
        if let sortedByValue = sortedByValue {
            return { (player1, player2) in
                if ascending {
                    return player1[keyPath: sortedByValue] < player2[keyPath: sortedByValue]
                } else {
                    return player1[keyPath: sortedByValue] > player2[keyPath: sortedByValue]
                }
            }
        } else if sortedByName {
            return { (player1, player2) in
                if ascending {
                    return player1[keyPath: sortedByNameValue] < player2[keyPath: sortedByNameValue]
                } else {
                    return player1[keyPath: sortedByNameValue] > player2[keyPath: sortedByNameValue]
                }
            }
        } else {
            return { _, _ in true }
        }
    
    }
    func myloadData() async {
        (players, errURL) = GetStatsData(myCompID: currentTeam[0].compID, myTeamID: currentTeam[0].teamID)
        sharedData.refreshStats = false
        haveData = true
    }
}

#Preview {
    StatisticsView()
}
