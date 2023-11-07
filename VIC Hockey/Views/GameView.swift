//
//  GameView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 30/10/2023.
//
import SwiftUI

struct GameView: View {
    @State var gameNumber: String
    @State var myTeam: String
    @State private var haveData = false
    @State private var team1 = ""
    @State private var team2 = ""
    @State private var score1 = ""
    @State private var score2 = ""
    @State private var dateTime = ""
    @State private var starts = ""
    @State private var venue = ""
    @State private var field = ""
    @State private var address = ""
    @State private var played = ""
    @State private var round = ""
    @State private var fullRound = ""
    @State private var result = ""
    @State private var home = ""
    @State private var away = ""
    @State private var homePlayers: [Player] = []
    @State private var awayPlayers: [Player] = []
    @State private var resultColor: Color = Color(.black)
    
    var body: some View {
        NavigationStack {
            if haveData {
                NavigationStack {
                    List {
                        Section(header: Text("Game Details")) {
                            VStack {
                                Text(dateTime)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                if starts != "" {
                                    Text(starts)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                HStack {
                                    Image(ShortClubName(fullName: team1))
                                        .resizable()
                                        .frame(width: 120, height: 120)
                                    Text("VS")
                                    Image(ShortClubName(fullName: team2))
                                        .resizable()
                                        .frame(width: 120, height: 120)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                VStack {
                                    HStack {
                                        if score1 != "" {
                                            Text(score1)
                                                .font(.largeTitle)
                                                .frame(width: 140, height: 50)
                                                .background(ShortClubName(fullName: team1) == myTeam ? resultColor : Color(.clear))
                                        }
                                        if score2 != "" {
                                            Text(score2)
                                                .font(.largeTitle)
                                                .frame(width: 140, height: 50)
                                                .background(ShortClubName(fullName: team2) == myTeam ? resultColor : Color(.clear))
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    HStack {
                                        Text(team1)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(nil)
                                            .frame(width: 140)
                                            .fontWeight(ShortClubName(fullName: team1) == myTeam ? .bold : .regular)
                                        Text(team2)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(nil)
                                            .frame(width: 140)
                                            .fontWeight(ShortClubName(fullName: team2) == myTeam ? .bold : .regular)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                        }
                        Section(header: Text("Ground Details")) {
                            HStack {
                                Spacer()
                                Image(systemName: "sportscourt.fill")
                                    .resizable()
                                    .frame(width: 40, height: 30)
                                Text(" \(field)")
                                    .font(.largeTitle)
                                Spacer()
                            }
                            VStack {
                                Text(venue)
                                Text(address)
                            }
                        }
                        if !homePlayers.isEmpty {
                            Section(header: Text(home)) {
                                ForEach(homePlayers.sorted { $0.surname < $1.surname }) { player in
                                    HStack {
                                        Text(player.name)
                                        if player.goalie == 1 {
                                            Text(" (GK)")
                                        }
                                        if player.captain {
                                            Image(systemName: "star.circle")
                                                .foregroundStyle(Color("ForegroundColor"))
                                        }
                                        ForEach(0 ..< player.greenCards, id: \.self) {_ in
                                            Image(systemName: "triangleshape.fill")
                                                .foregroundStyle(Color(.green))
                                        }
                                        ForEach(0 ..< player.yellowCards, id: \.self) {_ in
                                            Image(systemName: "square.fill")
                                                .foregroundStyle(Color(.yellow))
                                        }
                                        ForEach(0 ..< player.redCards, id: \.self) {_ in
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(Color(.red))
                                        }
                                        Spacer()
                                        Text(player.goals)
                                    }
                                }
                            }
                        }
                        if !awayPlayers.isEmpty {
                            Section(header: Text(away)) {
                                ForEach(awayPlayers.sorted { $0.surname < $1.surname }) { player in
                                    HStack {
                                        Text(player.name)
                                        if player.goalie == 1 {
                                            Text(" (GK)")
                                        }
                                        if player.captain {
                                            Image(systemName: "star.circle")
                                                .foregroundStyle(Color("ForegroundColor"))
                                        }
                                        ForEach(0 ..< player.greenCards, id: \.self) {_ in
                                            Image(systemName: "triangleshape.fill")
                                                .foregroundStyle(Color(.green))
                                        }
                                        ForEach(0 ..< player.yellowCards, id: \.self) {_ in
                                            Image(systemName: "square.fill")
                                                .foregroundStyle(Color(.yellow))
                                        }
                                        ForEach(0 ..< player.redCards, id: \.self) {_ in
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(Color(.red))
                                        }
                                        Spacer()
                                        Text(player.goals)
                                    }
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(fullRound)
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
    
    func loadData() async {
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
                        fullRound = String(mybit[mybit.count-1]).trimmingCharacters(in: .whitespaces)
                        if fullRound.count < 5 {
                            fullRound = String(mybit[mybit.count-2]).trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " &middot", with: "")
                        }
                        round = GetRound(fullString: fullRound)
                    }
                }
                if line[i].contains("www.hockeyvictoria.org.au/teams/") {
                    count += 1
                    if count == 1 {
                        team1 = GetPart(fullString: String(line[i]), partNumber: 9)
                        team1 = ShortTeamName(fullName: team1)
                        team2 = GetPart(fullString: String(line[i]), partNumber: 19)
                        team2 = ShortTeamName(fullName: team2)
                        
                    }
                    if count == 2 {
                        let mybit = line[i].split(whereSeparator: \.isSymbol)
                        for j in 0 ..< mybit.count {
                            if String(mybit[j]).contains(" -") {
                                result = ShortTeamName(fullName: GetPart(fullString: String(line[i]), partNumber: 8))
                                if result == myTeam {
                                    resultColor = Color(.green)
                                } else {
                                    resultColor = Color(.red)
                                }
                                
                                result = result + GetPart(fullString: String(line[i]), partNumber: 10)
                                let mybit1 = String(mybit[j]).split(separator: "-")
                                score1 = String(mybit1[0]).trimmingCharacters(in: .whitespaces)
                                score2 = String(mybit1[1]).trimmingCharacters(in: .whitespaces)
                            }
                        }
                    }
                }
                if line[i].contains("Teams drew!") {
                    let mybit1 = GetPart(fullString: String(line[i]), partNumber: 7).split(separator: "-")
                    score1 = String(mybit1[0]).trimmingCharacters(in: .whitespaces)
                    score2 = String(mybit1[1]).trimmingCharacters(in: .whitespaces)
                    result = "Teams drew!"
                    resultColor = Color(.gray)
                }
                if line[i].contains("Date &amp; time") {
                    dateTime = String(line[i+1].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "2023 ", with: "2023 @ "))
                    starts = GetStart(inputDate: dateTime)
                    if starts == "" {
                        played = "Completed"
                    } else {
                        played = "Upcoming"
                    }
                }
                
                
                if line[i].contains("Venue") {
                    venue = GetPart(fullString: String(line[i+1]), partNumber: 0).trimmingCharacters(in: .whitespaces)
                    address = GetPart(fullString: String(line[i+1]), partNumber: 3).trimmingCharacters(in: .whitespaces)
                    //                    venue = String(line[i+1].replacingOccurrences(of: "      ", with: "")
                    //                        .replacingOccurrences(of: "<div class=\"font-size-sm\">", with: " ")
                    //                        .replacingOccurrences(of: "</div>", with: ""))
                }
                if line[i].contains(">Field<") {
                    field = String(line[i+1].replacingOccurrences(of: "      ", with: ""))
                }
                if line[i].contains("<div class=\"table-responsive\">") {
                    
                    let myTeamName = ShortTeamName(fullName: GetPart(fullString: String(line[i-3]), partNumber: 3))
                    if home == "" {
                        home = myTeamName
                    } else {
                        away = myTeamName
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
                        if away == "" {
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
    GameView(gameNumber: "1471439", myTeam: "MHSOB")
}
