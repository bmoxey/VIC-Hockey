//
//  LadderView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 3/11/2023.
//

import SwiftUI
import SwiftData

struct LadderView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) var context
    @EnvironmentObject private var sharedData: SharedData
    @State private var errURL = ""
    @State private var rounds = [Round]()
    @State private var haveData = false
    @State private var linkEnabled = false
    @Query(filter: #Predicate<Teams> {$0.isCurrent} ) var currentTeam: [Teams]
    @State private var ladder = [LadderItem]()
    var body: some View {
        if !currentTeam.isEmpty {
            NavigationStack {
                VStack {
                    if sharedData.lastLadder != currentTeam[0].teamID && sharedData.activeTabIndex == 1 {
                        LoadingView()
                            .task { await loadData() }
                    } else {
                        if errURL != "" {
                            InvalidURLView(url: errURL)
                        } else {
                            List {
                                Section(header: Text("Ladder")) {
                                    DetailLadderHeaderView()
                                    ForEach(ladder, id: \.id) { item in
                                        if !currentTeam.isEmpty {
                                            VStack {
                                                NavigationLink(destination: LadderItemView(item: item, myTeamID: currentTeam[0].teamID)) {
                                                    DetailLadderItemView(myTeam: currentTeam[0].teamName, item: item)
                                                }
                                            }
                                            .listRowSeparatorTint( item.pos == 4 ? Color("ForegroundColor") : Color(UIColor.separator), edges: .all)
                                        }
                                    }
                                }
                            }
                            .refreshable {
                                sharedData.lastLadder = ""
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "list.number")
                            .foregroundStyle(Color("AccentColor"))
                            .font(.title3)
                    }
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text(currentTeam[0].divName)
                                .foregroundStyle(Color("ForegroundColor"))
                        }
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
    
    func loadData() async {
        var myLadder = LadderItem(id: UUID(), pos: 0, teamName: "", compID: "", teamID: "", played: 0, wins: 0, draws: 0, losses: 0, forfeits: 0, byes: 0, scoreFor: 0, scoreAgainst: 0, diff: 0, points: 0, winRatio: 0)
        var pos = 0
        ladder = []
        var lines: [String] = []
        (lines, errURL) = GetUrl(url: "https://www.hockeyvictoria.org.au/pointscores/" + currentTeam[0].compID + "/&d=" + currentTeam[0].divID)
        for i in 0 ..< lines.count {
            if lines[i].contains("This ladder is not currently available") {
                errURL = "This ladder is not currently available"
            }
            if lines[i].contains("hockeyvictoria.org.au/teams/") {
                pos += 1
                myLadder.teamID = GetPart(fullString: String(lines[i]), partNumber: 5)
                myLadder.compID = GetPart(fullString: String(lines[i]), partNumber: 3)
                myLadder.teamName = ShortTeamName(fullName: GetPart(fullString: String(lines[i]), partNumber: 6))
                let lineArray = lines[i+2].replacingOccurrences(of: ">", with: "<").split(separator: "<")
                myLadder.played = Int(lineArray[2]) ?? 0
                myLadder.wins = Int(lineArray[5]) ?? 0
                myLadder.draws = Int(lineArray[8]) ?? 0
                myLadder.losses = Int(lineArray[11]) ?? 0
                myLadder.forfeits = Int(lineArray[14]) ?? 0
                myLadder.byes = Int(lineArray[17]) ?? 0
                myLadder.scoreFor = Int(lineArray[20]) ?? 0
                myLadder.scoreAgainst = Int(lineArray[23]) ?? 0
                myLadder.diff = Int(lineArray[26]) ?? 0
                myLadder.points = Int(lineArray[29]) ?? 0
                myLadder.winRatio = Int(lineArray[33]) ?? 0
                myLadder.pos = pos
                myLadder.id = UUID()
                ladder.append(myLadder)
            }
        }
        sharedData.lastLadder = currentTeam[0].teamID
    }
}

#Preview {
    LadderView()
}
