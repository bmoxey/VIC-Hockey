//
//  GameView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 30/10/2023.
//
import SwiftUI

struct GameView: View {
    @EnvironmentObject private var sharedData: SharedData
    @Environment(\.presentationMode) var presentationMode
    @State var gameNumber: String
    @State var myTeam: String
    @State var myTeamID: String
    @State var errURL = ""
    @State var myRound: Round = Round(id: UUID(), roundNo: "", fullRound: "", dateTime: "", field: "", venue: "", address: "", opponent: "", homeTeam: "", awayTeam: "", homeGoals: 0, awayGoals: 0, score: "", starts: "", result: "", played: "", game: "")
    @State var myGame: Round = Round(id: UUID(), roundNo: "", fullRound: "", dateTime: "", field: "", venue: "", address: "", opponent: "", homeTeam: "", awayTeam: "", homeGoals: 0, awayGoals: 0, score: "", starts: "", result: "", played: "", game: "")
    @State private var haveData = false
    @State private var homePlayers: [Player] = []
    @State private var awayPlayers: [Player] = []
    @State private var otherGames: [Round] = []
    
    var body: some View {
        NavigationStack {
            if !haveData {
                LoadingView()
                    .task { await myloadData() }
            } else {
                if errURL != "" {
                    InvalidURLView(url: errURL)
                } else {
                    List {
                        DetailGameView(myTeam: myTeam, myRound: myRound)
                        DetailGroundView(myRound: myRound)
                        if !homePlayers.isEmpty {
                            Section(header: Text(myRound.homeTeam)) {
                                ForEach(homePlayers.sorted { $0.surname < $1.surname }) { player in
                                    DetailPlayerView(player: player)
                                }
                            }
                        }
                        if !awayPlayers.isEmpty {
                            Section(header: Text(myRound.awayTeam)) {
                                ForEach(awayPlayers.sorted { $0.surname < $1.surname }) { player in
                                    DetailPlayerView(player: player)
                                }
                            }
                        }
                        if !otherGames.isEmpty {
                            Section(header: Text("Other matches between these teams")) {
                                ForEach(otherGames, id: \.id) { item in
                                    DetailScheduleView(myTeam: myTeam, round: item)
                                }
                            }
                        }
                    }
                    .refreshable {
                        haveData = false
                    }
                }
            }
        }
        .onAppear {
            if sharedData.refreshSchedule {
                sharedData.refreshSchedule = false
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(myRound.fullRound)
                        .foregroundStyle(Color("BarForeground"))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(ShortClubName(fullName: myTeam))
                    .resizable()
                    .frame(width: 45, height: 45)
            }
        }
        .toolbarBackground(Color("BarBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color("BarBackground"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
    
    func myloadData() async {
        (myRound, homePlayers, awayPlayers, otherGames, errURL) = GetGameData(gameNumber: gameNumber, myTeam: myTeam)
        haveData = true
    }
}

#Preview {
    GameView(gameNumber: "1471439", myTeam: "Hawthorn", myTeamID: "123332")
}
