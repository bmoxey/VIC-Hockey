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
    @State private var played = ""
    @State private var round = ""
    @State private var result = ""
    @State private var resultColor: Color = Color(.black)
    var body: some View {
        if haveData {
            NavigationStack {
                List {
                    Section(header: Text("Game Details")) {
                        VStack {
                            Text(dateTime)
                            if starts != "" {
                                Text(starts)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            HStack {
                                VStack {
                                    Image(ShortClubName(fullName: team1))
                                        .resizable()
                                        .frame(width: 120, height: 120)
                                    if score1 != "" {
                                        Text(score1)
                                            .font(.largeTitle)
                                            .frame(width: 140, height: 50)
                                    }
                                    Text(team1)
                                        .frame(width: 140, height: 60)
                                        .multilineTextAlignment(.center)
                                }
                                Text("VS")
                                VStack {
                                    Image(ShortClubName(fullName: team2))
                                        .resizable()
                                        .frame(width: 120, height: 120)
                                    if score2 != "" {
                                        Text(score2)
                                            .font(.largeTitle)
                                            .frame(width: 140, height: 50)
                                    }
                                    Text(team2)
                                        .frame(width: 140, height: 60)
                                        .multilineTextAlignment(.center)
                                }
                                
                                
                            }
                            Text(result)
                                .background(Color(resultColor))
                            Text("")
                            //                    Divider()
                            //                    //                        Map(coordinateRegion: $region,
                            //                    //                            interactionModes: .all,
                            //                    //                            showsUserLocation: true
                            //                    //                        )
                            //                    //                        .ignoresSafeArea(edges: .all)
                            //                    HStack {
                            //                        //                            Image("groundTab2")
                            //                        Text(field)
                            //                    }
                            Text(venue)
                                .padding(.horizontal)
                                .padding(.bottom)
                            
                            
                            
                        }
                    }
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("\(team1) vs")
                            .foregroundStyle(Color(.white))
                        Text("\(team2)")
                            .foregroundStyle(Color(.white))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Text(round)
                        .font(.largeTitle)
                        .foregroundStyle(Color(.white))
                }
            }
            .toolbarBackground(Color("VICBlue"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color("VICBlue"), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        } else {
            Text("Loading...")
                .font(.largeTitle)
                .foregroundStyle(Color(.gray))
                .task {
                    await loadData()
                }
            
        }
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
                        round = GetRound(fullString: String(mybit[mybit.count-1]).trimmingCharacters(in: .whitespaces))
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
                    venue = String(line[i+1].replacingOccurrences(of: "      ", with: "")
                        .replacingOccurrences(of: "<div class=\"font-size-sm\">", with: " ")
                        .replacingOccurrences(of: "</div>", with: ""))
                    //                        Task  {
                    //                            //                        do {
                    //                            ////                            try await lookupCoordinates(venue: venue)
                    //                            //                        }
                    //                            //                        catch {
                    //                            ////                            print(error)
                    //                            //                        }
                    //                        }
                    
                }
                if line[i].contains(">Field<") {
                    field = String(line[i+1].replacingOccurrences(of: "      ", with: ""))
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
