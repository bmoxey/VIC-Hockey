//
//  RoundView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 11/11/2023.
//

import SwiftUI
import SwiftData

struct RoundView: View {
    @EnvironmentObject private var sharedData: SharedData
    @State private var errURL = ""
    @State private var rounds = [Round]()
    @State private var byeTeams: [String] = []
    @State private var haveData = false
    @State private var prev = ""
    @State private var current = ""
    @State private var next = ""
    @Query(filter: #Predicate<Teams> {$0.isCurrent} ) var currentTeam: [Teams]
    var body: some View {
        if !currentTeam.isEmpty {
            NavigationStack {
                VStack {
                    if !haveData {
                        LoadingView()
                            .task { await myloadData(roundName: sharedData.currentRound) }
                    } else {
                        if errURL != "" {
                            InvalidURLView(url: errURL)
                        } else {
                            List {
                                ForEach(rounds, id: \.id) { round in
                                    Section(header: Text("\(round.dateTime) - \(round.field)")) {
                                        NavigationLink(destination: GameView(gameNumber: round.game, myTeam: currentTeam[0].teamName, myTeamID: currentTeam[0].teamID)) {
                                            DetailRoundView(myTeam: currentTeam[0].teamName, myRound: round)
                                        }
                                    }
                                }
                                ForEach(byeTeams, id: \.self) {name in
                                    Section(header: Text("Teams with a bye")){
                                        HStack {
                                            Image(ShortClubName(fullName: name))
                                                .resizable()
                                                .frame(width: 45, height: 45)
                                            Text(name)
                                        }
                                    }}
                            }
                            .refreshable {
                                haveData = false
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(current)
                            .foregroundStyle(Color("BarForeground"))
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        HStack {
                            Image(systemName: "sportscourt.circle.fill")
                                .foregroundStyle(Color.white)
                                .font(.title3)
                            if prev != "" {
                                Button {
                                    Task {
                                        do { await myloadData(roundName: prev) }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                            .foregroundStyle(Color.white)
                                            .font(Font.system(size: 17, weight: .semibold))
                                            .frame(width: 20, height: 20)
                                        Text(GetRound(fullString: prev))
                                            .foregroundStyle(Color.white)
                                    }
                                }
                            }
                        }
                    }
                    if next != "" {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                Task {
                                    do { await myloadData(roundName: next) }
                                }
                            }, label: {
                                HStack {
                                    Text(GetRound(fullString: next))
                                        .foregroundStyle(Color.white)
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.white)
                                        .font(Font.system(size: 17, weight: .semibold))
                                        .frame(width: 20, height: 20)
                                }
                            })
                            
                        }
                    }
                }
                .padding(.horizontal, -8)
                .toolbarBackground(Color("BarBackground"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color("BarBackground"), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            }
            .onAppear() {
                if sharedData.refreshRound {
                    haveData = false
                }
            }
        }
    }
    
    func myloadData(roundName: String) async {
        (prev, current, next, rounds, byeTeams, errURL) = GetRoundData(mycompID: currentTeam[0].compID, myDivID: currentTeam[0].divID, myTeamName: currentTeam[0].teamName, currentRound: roundName)
        sharedData.refreshRound = false
        haveData = true
    }
}

#Preview {
    RoundView()
}
