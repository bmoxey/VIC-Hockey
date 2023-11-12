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
                                        Section(header: Text(round.dateTime)) {
                                        DetailRoundView(myTeam: currentTeam[0].teamName, myRound: round)
                                    }
                                }
                            }
                            .refreshable {
                                sharedData.refreshRound = true
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
        (prev, current, next, rounds, errURL) = GetRoundData(mycompID: currentTeam[0].compID, myDivID: currentTeam[0].divID, myTeamName: currentTeam[0].teamName, currentRound: roundName)
        sharedData.refreshRound = false
        haveData = true
    }
}

#Preview {
    RoundView()
}
