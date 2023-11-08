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
    @Query(filter: #Predicate<Teams> {$0.isCurrent} ) var currentTeam: [Teams]
    var body: some View {
        if !currentTeam.isEmpty {
            NavigationStack {
                VStack {
                    if sharedData.lastSchedule != currentTeam[0].teamID && sharedData.activeTabIndex == 0 {
                        LoadingView()
                            .task { await loadData() }
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
                                sharedData.lastSchedule = ""
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(currentTeam[0].divName)
                            .fontWeight(.bold)
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
        }
    }
    
    
    func loadData() async {
        var myRound = Round(id: UUID(), roundNo: "", fullRound: "", dateTime: "", field: "", venue: "", address: "", opponent: "", homeTeam: "", awayTeam: "", homeGoals: 0, awayGoals: 0, score: "", starts: "", result: "", played: "", game: "")
        rounds = []
        var lines: [String] = []
        (lines, errURL) = GetUrl(url: "https://www.hockeyvictoria.org.au/teams/" + currentTeam[0].compID + "/&t=" + currentTeam[0].teamID)
        for i in 0 ..< lines.count {
            if lines[i].contains("There are no draws to show") {
                errURL = "There are no draws to show"
            }
            if lines[i].contains("col-md pb-3 pb-lg-0 text-center text-md-left") {
                myRound.fullRound = GetPart(fullString: String(lines[i+1]), partNumber: 2)
                myRound.roundNo = GetRound(fullString: myRound.fullRound)
                myRound.dateTime = String(lines[i+2].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "<br />", with: " @ "))
                myRound.starts = GetStart(inputDate: myRound.dateTime)
                if myRound.starts == "" { myRound.played = "Completed" }
                else { myRound.played = "Upcoming" }
            }
            if lines[i].contains("col-md pb-3 pb-lg-0 text-center text-md-right text-lg-left") {
                myRound.field = GetPart(fullString: String(lines[i+2]), partNumber: 2)
            }
            if lines[i].contains("col-lg-3 pb-3 pb-lg-0 text-center") {
                if myRound.field == "/div" {
                    myRound.field = "BYE"
                    myRound.opponent = "BYE"
                    myRound.score = "BYE"
                    myRound.result = "BYE"
                } else {
                    myRound.opponent = ShortTeamName(fullName: GetPart(fullString: String(lines[i+2]), partNumber: 6))
                    myRound.score = GetPart(fullString: GetScore(fullString: String(lines[i+2])), partNumber: 9)
                    (myRound.homeGoals, myRound.awayGoals) = GetScores(scores: myRound.score)
                    
                    if myRound.score == "div" {
                        myRound.score = ""
                        myRound.result = ""
                    } else {
                        myRound.result = GetPart(fullString: GetScore(fullString: String(lines[i+2])), partNumber: 14)
                    }
                    (myRound.homeTeam, myRound.awayTeam) = GetHomeTeam(result: myRound.result, homeGoals: myRound.homeGoals, awayGoals: myRound.awayGoals, myTeam: currentTeam[0].teamName, opponent: myRound.opponent, rounds: rounds, venue: myRound.venue)
                }
                
            }
            if lines[i].contains("https://www.hockeyvictoria.org.au/game/") {
                myRound.game = String(GetPart(fullString: String(lines[i]), partNumber: 4).split(separator: "/")[3])
                myRound.id = UUID()
                rounds.append(myRound)
            }
        }
        sharedData.lastSchedule = currentTeam[0].teamID
    }
}

#Preview {
    ScheduleView()
}
