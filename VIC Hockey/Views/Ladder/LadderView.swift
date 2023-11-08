//
//  LadderView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 3/11/2023.
//

import SwiftUI
import SwiftData

struct Ladder: Codable {
    var ladder: [LadderItem]
}

struct LadderItem: Codable {
    var id: Int
    var teamName: String
    var played: Int
    var wins: Int
    var draws: Int
    var losses: Int
    var forfeits: Int
    var byes: Int
    var scoreFor: Int
    var scoreAgainst: Int
    var diff: Int
    var points: Int
    var winRatio: Int
}

struct LadderView: View {
    @Environment(\.modelContext) var context
    @State private var rounds = [Round]()
    @State private var haveData = false
    @Query(filter: #Predicate<Teams> {$0.isCurrent} ) var currentTeam: [Teams]
    @State private var ladder = [LadderItem]()
    var body: some View {
        if !currentTeam.isEmpty {
            VStack {
                if !haveData {
                    Text("Loading...")
                        .font(.largeTitle)
                        .foregroundStyle(Color(.gray))
                } else {
                    NavigationStack {
                        List {
                            HStack {
                                Text("")
                                    .frame(width: 20)
                                Text("")
                                    .frame(width: 45)
                                Text("Team")
                                    .fontWeight(.bold)
                                    .font(.footnote)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Text("GD")
                                    .fontWeight(.bold)
                                    .font(.footnote)
                                    .frame(width: 35, alignment: .trailing)
                                Text("Pts")
                                    .fontWeight(.bold)
                                    .font(.footnote)
                                    .frame(width: 35, alignment: .trailing)
                                Text("WR")
                                    .fontWeight(.bold)
                                    .font(.footnote)
                                    .frame(width: 35, alignment: .trailing)
                                Text(" ")
                                    .frame(width: 12)
                            }
                            ForEach(ladder, id: \.id) { item in
                                VStack {
                                    NavigationLink(destination: LadderItemView(item: item)) {
                                        HStack {
                                            Text("\(item.id)")
                                                .frame(width: 20, alignment: .leading)
                                                .font(.footnote)
                                                .foregroundStyle(Color(item.teamName == currentTeam[0].teamName ? "ForegroundColor" : "DefaultColor"))
                                            Image(ShortClubName(fullName: item.teamName))
                                                .resizable()
                                                .frame(width: 45, height: 45)
                                                .padding(.vertical, -4)
                                                    Text(item.teamName)
                                                        .multilineTextAlignment(.leading)
                                                        .lineLimit(nil)
                                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                                        .foregroundStyle(Color(item.teamName == currentTeam[0].teamName ? "ForegroundColor" : "DefaultColor"))
                                                    Text("\(item.diff)")
                                                        .frame(width: 35, alignment: .trailing)
                                                        .foregroundStyle(Color(item.teamName == currentTeam[0].teamName ? "ForegroundColor" : "DefaultColor"))
                                                    Text("\(item.points)")
                                                        .frame(width: 35, alignment: .trailing)
                                                        .foregroundStyle(Color(item.teamName == currentTeam[0].teamName ? "ForegroundColor" : "DefaultColor"))
                                                    Text("\(item.winRatio)")
                                                        .frame(width: 35, alignment: .trailing)
                                                        .foregroundStyle(Color(item.teamName == currentTeam[0].teamName ? "ForegroundColor" : "DefaultColor"))
                                        }
                                    }
                                }
                                .listRowSeparatorTint( item.id == 4 ? Color("ForegroundColor") : Color(UIColor.separator),
                                    edges: .all)
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                VStack {
                                    Text(currentTeam[0].divName)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("ForegroundColor"))
                                }
                            }
                            ToolbarItem(placement: .topBarLeading) {
                                Image(systemName: "list.number")
                                    .foregroundStyle(Color("AccentColor"))
                                    .font(.title3)
                            }
                            
                            ToolbarItem(placement: .topBarTrailing) {
                                Image(currentTeam[0].clubName)
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
            .task {
                if !currentTeam.isEmpty {
                    await loadData()
                }
            }
        }
    }
    
    func loadData() async {
        var id: Int = 0
        var teamName: String = ""
        var played: Int = 0
        var wins: Int = 0
        var draws: Int = 0
        var losses: Int = 0
        var forfeits: Int = 0
        var byes: Int = 0
        var scoreFor: Int = 0
        var scoreAgainst: Int = 0
        var diff: Int = 0
        var points: Int = 0
        var winRatio: Int = 0
        ladder = []
        guard let url = URL(string: "https://www.hockeyvictoria.org.au/pointscores/" + currentTeam[0].compID + "/&d=" + currentTeam[0].divID) else {
            print("Invalid URL")
            return
        }
        do {
            let html = try String.init(contentsOf: url)
            let line = html.split(whereSeparator: \.isNewline)
            for i in 0 ..< line.count {
                if line[i].contains("hockeyvictoria.org.au/teams/") {
                    id += 1
                    teamName = ShortTeamName(fullName: GetPart(fullString: String(line[i]), partNumber: 6))
                    let lineArray = line[i+2].replacingOccurrences(of: ">", with: "<").split(separator: "<")
                    played = Int(lineArray[2]) ?? 0
                    wins = Int(lineArray[5]) ?? 0
                    draws = Int(lineArray[8]) ?? 0
                    losses = Int(lineArray[11]) ?? 0
                    forfeits = Int(lineArray[14]) ?? 0
                    byes = Int(lineArray[17]) ?? 0
                    scoreFor = Int(lineArray[20]) ?? 0
                    scoreAgainst = Int(lineArray[23]) ?? 0
                    diff = Int(lineArray[26]) ?? 0
                    points = Int(lineArray[29]) ?? 0
                    winRatio = Int(lineArray[33]) ?? 0
                    ladder.append(LadderItem(id: id, teamName: teamName, played: played, wins: wins, draws: draws, losses: losses, forfeits: forfeits, byes: byes, scoreFor: scoreFor, scoreAgainst: scoreAgainst, diff: diff, points: points, winRatio: winRatio))
                }
            }
        } catch {
            print("Invalid data")
            
        }
        haveData = true
    }
    
}

#Preview {
    LadderView()
}
