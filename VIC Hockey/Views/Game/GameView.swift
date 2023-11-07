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
    @State var myRound: Round = Round(id: UUID(), roundNo: "", fullRound: "", dateTime: "", field: "", venue: "", address: "", opponent: "", homeTeam: "", awayTeam: "", homeGoals: 0, awayGoals: 0, score: "", starts: "", result: "", played: "", game: "")
    @State private var haveData = false
    @State private var homePlayers: [Player] = []
    @State private var awayPlayers: [Player] = []
    
    var body: some View {
        NavigationStack {
            if haveData {
                NavigationStack {
                    List {
                        DetailGameView(myTeam: myTeam, myRound: myRound)
                        
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
                    }
                }
            } else {
                Text("Loading...")
                    .font(.largeTitle)
                    .foregroundStyle(Color(.gray))
                    .task {
                        await loadData()
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
                        .fontWeight(.bold)
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
        if sharedData.lastSchedule != myTeam {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func loadData() async {
        print(sharedData.activeTabIndex)
        guard let url = URL(string: "https://www.hockeyvictoria.org.au/game/" + gameNumber + "/") else {
            print("Invalid URL")
            return
        }
        do {
            var count = 0
            let html = try String.init(contentsOf: url)
            let line = html.split(whereSeparator: \.isNewline)
            for i in 0 ..< line.count {
                if line[i].contains("<h1 class=\"h3 mb-0\">") {
                    if line[i+1].contains("&middot;") {
                        let mybit = String(line[i+1]).split(separator: ";")
                        myRound.fullRound = String(mybit[mybit.count-1]).trimmingCharacters(in: .whitespaces)
                        if myRound.fullRound.count < 5 {
                            myRound.fullRound = String(mybit[mybit.count-2]).trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " &middot", with: "")
                        }
                        myRound.roundNo = GetRound(fullString: myRound.fullRound)
                    }
                }
                if line[i].contains("www.hockeyvictoria.org.au/teams/") {
                    count += 1
                    if count == 1 {
                        myRound.homeTeam = GetPart(fullString: String(line[i]), partNumber: 9)
                        myRound.homeTeam = ShortTeamName(fullName: myRound.homeTeam)
                        myRound.awayTeam = GetPart(fullString: String(line[i]), partNumber: 19)
                        myRound.awayTeam = ShortTeamName(fullName: myRound.awayTeam)
                        
                    }
                    if count == 2 {
                        let mybit = line[i].split(whereSeparator: \.isSymbol)
                        for j in 0 ..< mybit.count {
                            if String(mybit[j]).contains(" -") {
                                myRound.result = ShortTeamName(fullName: GetPart(fullString: String(line[i]), partNumber: 8))
                                
                                myRound.result = myRound.result + GetPart(fullString: String(line[i]), partNumber: 10)
                                let mybit1 = String(mybit[j]).split(separator: "-")
                                myRound.homeGoals = Int(String(mybit1[0]).trimmingCharacters(in: .whitespaces)) ?? 0
                                myRound.awayGoals = Int(String(mybit1[1]).trimmingCharacters(in: .whitespaces)) ?? 0
                            }
                        }
                    }
                }
                if line[i].contains("Teams drew!") {
                    let mybit1 = GetPart(fullString: String(line[i]), partNumber: 7).split(separator: "-")
                    myRound.homeGoals = Int(String(mybit1[0]).trimmingCharacters(in: .whitespaces)) ?? 0
                    myRound.awayGoals = Int(String(mybit1[1]).trimmingCharacters(in: .whitespaces)) ?? 0
                    myRound.result = "Teams drew!"
                }
                if line[i].contains("Date &amp; time") {
                    myRound.dateTime = String(line[i+1].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "2023 ", with: "2023 @ "))
                    myRound.starts = GetStart(inputDate: myRound.dateTime)
                    if myRound.starts == "" {
                        myRound.played = "Completed"
                    } else {
                        myRound.played = "Upcoming"
                    }
                }
                
                
                if line[i].contains("Venue") {
                    myRound.venue = GetPart(fullString: String(line[i+1]), partNumber: 0).trimmingCharacters(in: .whitespaces)
                    myRound.address = GetPart(fullString: String(line[i+1]), partNumber: 3).trimmingCharacters(in: .whitespaces)
                    //                    venue = String(line[i+1].replacingOccurrences(of: "      ", with: "")
                    //                        .replacingOccurrences(of: "<div class=\"font-size-sm\">", with: " ")
                    //                        .replacingOccurrences(of: "</div>", with: ""))
                }
                if line[i].contains(">Field<") {
                    myRound.field = String(line[i+1].replacingOccurrences(of: "      ", with: ""))
                }
                if line[i].contains("<div class=\"table-responsive\">") {
                    
                    let myTeamName = ShortTeamName(fullName: GetPart(fullString: String(line[i-3]), partNumber: 3))
                    if myRound.homeTeam == "" {
                        myRound.homeTeam = myTeamName
                    } else {
                        myRound.awayTeam = myTeamName
                    }
                }
                
                if line[i].contains("https://www.hockeyvictoria.org.au/statistics/") {
                    if String(GetPart(fullString: String(line[i]), partNumber: 11)) == "Attended" {
                        var myName = GetPart(fullString: String(line[i]), partNumber: 18).capitalized
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
                        var myGoals = GetPart(fullString: String(line[i+2]), partNumber: 3)
                        if myGoals.contains("/td") { myGoals = ""}
                        let myGreen = Int(GetPart(fullString: String(line[i+4]), partNumber: 3)) ?? 0
                        let myYellow = Int(GetPart(fullString: String(line[i+6]), partNumber: 3)) ?? 0
                        let myRed = Int(GetPart(fullString: String(line[i+8]), partNumber: 3)) ?? 0
                        let myGoalie = Int(GetPart(fullString: String(line[i+10]), partNumber: 3)) ?? 0
                        if myRound.awayTeam == "" {
                            homePlayers.append(Player(name: myName, goals: myGoals, greenCards: myGreen, yellowCards: myYellow, redCards: myRed, goalie: myGoalie, surname: surname, captain: myCap))
                        } else {
                            awayPlayers.append(Player(name: myName, goals: myGoals, greenCards: myGreen, yellowCards: myYellow, redCards: myRed, goalie: myGoalie, surname: surname, captain: myCap))
                            
                        }
                    }
                }
            }
        }
        catch {
            print("Invalid data")
        }
        haveData = true
    }
}

#Preview {
    GameView(gameNumber: "1471439", myTeam: "Hawthorn")
}
