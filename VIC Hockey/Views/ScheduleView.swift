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
    @State private var rounds = [Round]()
    @State private var haveData = false
    @Query(filter: #Predicate<Teams> {$0.isCurrent} ) var currentTeam: [Teams]
    var body: some View {
        if !haveData {
            Text("Loading...")
                .font(.largeTitle)
                .foregroundStyle(Color(.gray))
                .task {
                    await loadData()
                }
        } else {
            NavigationStack {
                List {
                    ForEach(["Upcoming", "Completed"], id: \.self) { played in
                        let filteredRounds = rounds.filter { $0.played == played }
                        if !filteredRounds.isEmpty {
                                Section(header: Text(played)) {
                                    ForEach(filteredRounds, id: \.id) { item in
                                        NavigationLink(destination: GameView(gameNumber: item.game, myTeam: currentTeam[0].teamName)) {
                                            ContentSubview(round: item)
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
                            Text(currentTeam[0].divName)
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.white))
                            Text(currentTeam[0].teamName)
                                .foregroundStyle(Color(.white))
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Image(currentTeam[0].teamName)
                            .resizable()
                            .frame(width: 45, height: 45)
                    }
                }
                .padding(.horizontal, -8)
                .toolbarBackground(Color("VICBlue"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color("VICBlue"), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            }
        }
    }
    
    
    func loadData() async {
        var id: Int = 0
        var round: String = ""
        var dateTime: String = ""
        var venue: String = ""
        var opponent: String = ""
        var score: String = ""
        var starts: String = ""
        var result: String = ""
        var played: String = ""
        var game: String = ""
        rounds = []
        guard let url = URL(string: "https://www.hockeyvictoria.org.au/teams/" + currentTeam[0].compID + "/&t=" + currentTeam[0].teamID) else {
            print("Invalid URL")
            return
        }
        
        do {
            let html = try String.init(contentsOf: url)
            let line = html.split(whereSeparator: \.isNewline)
            for i in 0 ..< line.count {
                if line[i].contains("col-md pb-3 pb-lg-0 text-center text-md-left") {
                    id += 1
                    round = GetRound(fullString: GetPart(fullString: String(line[i+1]), partNumber: 2))
                    dateTime = String(line[i+2].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "<br />", with: " @ "))
                    starts = GetStart(inputDate: dateTime)
                    if starts == "" {
                        played = "Completed"
                    } else {
                        played = "Upcoming"
                    }
                }
                if line[i].contains("col-md pb-3 pb-lg-0 text-center text-md-right text-lg-left") {
                    venue = GetPart(fullString: String(line[i+2]), partNumber: 2)
                }
                if line[i].contains("col-lg-3 pb-3 pb-lg-0 text-center") {
                    if venue == "/div" {
                        venue = "BYE"
                        opponent = "BYE"
                        score = "BYE"
                    } else {
                        opponent = ShortTeamName(fullName: GetPart(fullString: String(line[i+2]), partNumber: 6))
                        score = GetPart(fullString: GetScore(fullString: String(line[i+2])), partNumber: 9)
                        if score == "div" {
                            score = ""
                            result = ""
                        } else {
                            result = GetPart(fullString: GetScore(fullString: String(line[i+2])), partNumber: 14)
                        }
                    }
                }
                if line[i].contains("https://www.hockeyvictoria.org.au/game/") {
                    game = GetPart(fullString: String(line[i]), partNumber: 4)
                    game = String(game.split(separator: "/")[3])
                    rounds.append(Round(id: id, roundNo: round, dateTime: dateTime, venue: venue, opponent: opponent, score: score, starts: starts, result: result, played: played, game: game))
                }
            }
        } catch {
            print("Invalid data")
            
        }
        haveData = true
    }
    
    func backgroundColor(for result: String) -> Color {
        switch result {
        case "Win":
            return Color.green
        case "Loss":
            return Color.red
        case "Draw":
            return Color.gray
        default:
            return Color.cyan
        }
    }
}


struct ContentSubview: View {
    let round: Round
    var body: some View {
        HStack {
            VStack {
                Text(round.roundNo)
                Image(ShortClubName(fullName: round.opponent))
                    .resizable()
                    .frame(width: 45, height: 45)
                    .padding(.top, -6)
            }
            VStack {
                HStack {
                    Text("\(round.dateTime)")
                    Spacer()
                }
                HStack {
                    Text("\(round.opponent) @ \(round.venue)")
                    Spacer()
                }
                HStack {
                    if round.starts != "" {
                        Text("\(round.starts)")
                            .foregroundColor(Color.red)
                    } else {
                        Text(" Result: \(round.score) \(round.result) ")
                            .foregroundColor(.white)
                            .background(backgroundColor(for: round.result))
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal, -8)
    }
    
    func backgroundColor(for result: String) -> Color {
        switch result {
        case "Win":
            return Color.green
        case "Loss":
            return Color.red
        case "Draw":
            return Color.gray
        default:
            return Color.cyan
        }
    }
}

#Preview {
    ScheduleView()
}
