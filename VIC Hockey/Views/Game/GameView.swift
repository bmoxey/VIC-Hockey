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
                    NavigationStack {
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
        }
        .task {
            await myData()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(myRound.fullRound)
                        .foregroundStyle(Color("ForegroundColor"))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(ShortClubName(fullName: myTeam))
                    .resizable()
                    .frame(width: 45, height: 45)
            }
        }
        .toolbarBackground(Color("BackgroundColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color("BackgroundColor"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
    
    func myData() async {
        if sharedData.lastSchedule != myTeamID {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func myloadData() async {
        (myRound, homePlayers, awayPlayers, otherGames, errURL) = GetGameData(gameNumber: gameNumber, myTeam: myTeam)
        haveData = true
    }
    
    func loadData() async {
        var lines: [String] = []
        var myTeamName: String = ""
        (lines, errURL) = GetUrl(url: "https://www.hockeyvictoria.org.au/game/" + gameNumber + "/")
        var count = 0
        for i in 0 ..< lines.count {
            if lines[i].contains("Match not found.") {
                errURL = "Match not found."
            }
            if lines[i].contains("<h1 class=\"h3 mb-0\">") {
                if lines[i+1].contains("&middot;") {
                    let mybit = String(lines[i+1]).split(separator: ";")
                    myRound.fullRound = String(mybit[mybit.count-1]).trimmingCharacters(in: .whitespaces)
                    if myRound.fullRound.count < 5 {
                        myRound.fullRound = String(mybit[mybit.count-2]).trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " &middot", with: "")
                    }
                    myRound.roundNo = GetRound(fullString: myRound.fullRound)
                }
            }
            if lines[i].contains("www.hockeyvictoria.org.au/teams/") {
                count += 1
                if count == 1 {
                    myRound.homeTeam = ShortTeamName(fullName:GetPart(fullString: String(lines[i]), partNumber: 9))
                    myRound.awayTeam = ShortTeamName(fullName:GetPart(fullString: String(lines[i]), partNumber: 19))
                }
                if count == 2 {
                    let mybit = lines[i].split(whereSeparator: \.isSymbol)
                    for j in 0 ..< mybit.count {
                        if String(mybit[j]).contains(" - ") {
                            let mybit1 = String(mybit[j]).split(separator: "-")
                            myRound.homeGoals = Int(String(mybit1[0]).trimmingCharacters(in: .whitespaces)) ?? 0
                            myRound.awayGoals = Int(String(mybit1[1]).trimmingCharacters(in: .whitespaces)) ?? 0
                        }
                    }
                    myRound.result = GetResult(myTeam: myTeam, homeTeam: myRound.homeTeam, awayTeam: myRound.awayTeam, homeGoals: myRound.homeGoals, awayGoals: myRound.awayGoals)
                }
                if count > 2 {
                    let mybit = lines[i].split(separator: ":")
                    myGame.homeTeam = ShortTeamName(fullName:GetPart(fullString: String(mybit[1]), partNumber: 4))
                    myGame.awayTeam = ShortTeamName(fullName:GetPart(fullString: String(mybit[2]), partNumber: 4))
                    if myGame.starts == "" {
                        let score = GetPart(fullString: String(lines[i]), partNumber: 10)
                        let numbers = score.components(separatedBy: CharacterSet(charactersIn: " vs ")).compactMap { Int($0.trimmingCharacters(in: .whitespaces))}
                        myGame.homeGoals = numbers.first ?? 0
                        myGame.awayGoals = numbers.last ?? 0
                        myGame.result = GetResult(myTeam: myTeam, homeTeam: myGame.homeTeam, awayTeam: myGame.awayTeam, homeGoals: myGame.homeGoals, awayGoals: myGame.awayGoals)
                        myGame.score = "\(myGame.homeGoals) - \(myGame.awayGoals)"
                    }
                    if myGame.homeTeam == myTeam { myGame.opponent = myGame.awayTeam }
                    else {myGame.opponent = myGame.homeTeam}
                }
            }
            if lines[i].contains("Results for this match are not currently available") {
                count += 1
            }
            if lines[i].contains("Teams drew!") {
                let mybit1 = GetPart(fullString: String(lines[i]), partNumber: 7).split(separator: "-")
                myRound.homeGoals = Int(String(mybit1[0]).trimmingCharacters(in: .whitespaces)) ?? 0
                myRound.awayGoals = Int(String(mybit1[1]).trimmingCharacters(in: .whitespaces)) ?? 0
                myRound.result = "Draw"
                count += 1
            }
            if lines[i].contains(">Date &amp; time<") {
                myRound.dateTime = ChangeLastSpace(in: String(lines[i+1].trimmingCharacters(in: .whitespaces)))
                myRound.starts = GetStart(inputDate: myRound.dateTime)
                if myRound.starts == "" { myRound.played = "Completed" } else { myRound.played = "Upcoming" }
            }
            if lines[i].contains(">Venue<") {
                myRound.venue = GetPart(fullString: String(lines[i+1]), partNumber: 0).trimmingCharacters(in: .whitespaces)
                myRound.address = GetPart(fullString: String(lines[i+1]), partNumber: 3).trimmingCharacters(in: .whitespaces)
            }
            if lines[i].contains(">Field<") {
                myRound.field = String(lines[i+1]).trimmingCharacters(in: .whitespaces)
            }
            if lines[i].contains("<div class=\"table-responsive\">") {
                myTeamName = ShortTeamName(fullName: GetPart(fullString: String(lines[i-3]), partNumber: 3))
            }
            if lines[i].contains("https://www.hockeyvictoria.org.au/statistics/") {
                if String(GetPart(fullString: String(lines[i]), partNumber: 11)) == "Attended" {
                    var myName = GetPart(fullString: String(lines[i]), partNumber: 18).capitalized
                    var myCap = false
                    if myName.contains(" (Captain)") {
                        myCap = true
                        myName = myName.replacingOccurrences(of: " (Captain)", with: "")
                    }
                    let mybits = myName.split(separator: ",")
                    var surname = ""
                    if mybits.count > 0 {
                        surname = mybits[0].trimmingCharacters(in: .whitespaces).capitalized
                        if surname.contains("'") {
                            let mybits1 = surname.split(separator: "'")
                            surname = mybits1[0].capitalized + "'" + mybits1[1].capitalized
                        }
                        myName = mybits[1].trimmingCharacters(in: .whitespaces).capitalized + " " + surname
                    }
                    let myGoals = Int(GetPart(fullString: String(lines[i+2]), partNumber: 3)) ?? 0
                    let myGreen = Int(GetPart(fullString: String(lines[i+4]), partNumber: 3)) ?? 0
                    let myYellow = Int(GetPart(fullString: String(lines[i+6]), partNumber: 3)) ?? 0
                    let myRed = Int(GetPart(fullString: String(lines[i+8]), partNumber: 3)) ?? 0
                    let myGoalie = Int(GetPart(fullString: String(lines[i+10]), partNumber: 3)) ?? 0
                    var us = true
                    if myTeamName != myTeam { us = false }
                    if myRound.homeTeam == myTeamName {
                        homePlayers.append(Player(name: myName, numberGames: 0, goals: myGoals, greenCards: myGreen, yellowCards: myYellow, redCards: myRed, goalie: myGoalie, surname: surname, captain: myCap, us: us))
                    } else {
                        awayPlayers.append(Player(name: myName, numberGames: 0, goals: myGoals, greenCards: myGreen, yellowCards: myYellow, redCards: myRed, goalie: myGoalie, surname: surname, captain: myCap, us: us))
                    }
                }
            }
            if lines[i].contains("https://www.hockeyvictoria.org.au/venues") {
                myGame.fullRound = GetPart(fullString: lines[i-7], partNumber: 2)
                myGame.dateTime = GetPart(fullString: lines[i-6], partNumber: 2) + " @ " +  String(lines[i-5]).trimmingCharacters(in: .whitespaces)
                myGame.starts = GetStart(inputDate: myGame.dateTime)
                myGame.venue = GetPart(fullString: lines[i], partNumber: 5)
                myGame.field = GetPart(fullString: lines[i+1], partNumber: 2)
            }
            if lines[i].contains("https://www.hockeyvictoria.org.au/game/") {
                myGame.id = UUID()
                otherGames.append(myGame)
            }
        }
        haveData = true
    }
}

#Preview {
    GameView(gameNumber: "1471439", myTeam: "Hawthorn", myTeamID: "123332")
}
