//
//  LadderItemView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 3/11/2023.
//

import SwiftUI

struct LadderItemView: View {
    @EnvironmentObject private var sharedData: SharedData
    @Environment(\.presentationMode) var presentationMode
    @State var item: LadderItem
    @State var myTeamID: String
    @State private var haveData: Bool = false
    @State private var errURL = ""
    @State private var rounds = [Round]()
    var body: some View {
        NavigationStack {
            if !haveData {
                LoadingView()
                .task { await myloadData() }
            } else {
                if errURL != "" {
                    InvalidURLView(url: errURL)
                } else {
                    HStack {
                        Image(ShortClubName(fullName: item.teamName))
                            .resizable()
                            .frame(width: 45, height: 45)
                        Spacer()
                        Text(item.teamName)
                            .font(.title)
                        Spacer()
                        if item.pos == 1 {
                            Text("\(item.pos)st")
                                .font(.largeTitle)
                        }
                        if item.pos == 2 {
                            Text("\(item.pos)nd")
                                .font(.largeTitle)
                        }
                        if item.pos == 3 {
                            Text("\(item.pos)rd")
                                .font(.largeTitle)
                        }
                        if item.pos > 3 {
                            Text("\(item.pos)th")
                                .font(.largeTitle)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                    List {
                        Section(header: Text("Results")) {
                            VStack {
                                HStack {
                                    ForEach(0 ..< item.wins, id: \.self) { _ in
                                        Image(systemName: "checkmark.square.fill")
                                            .foregroundColor(.green)
                                            .frame(width: 12, height: 12)
                                    }
                                    ForEach(0 ..< item.draws, id: \.self) { _ in
                                        Image(systemName: "minus.square.fill")
                                            .foregroundColor(.gray)
                                            .frame(width: 12, height: 12)
                                    }
                                    ForEach(0 ..< item.byes, id: \.self) { _ in
                                        Image(systemName: "hand.raised.square.fill")
                                            .foregroundColor(.cyan)
                                            .frame(width: 12, height: 12)
                                    }
                                    ForEach(0 ..< item.losses, id: \.self) { _ in
                                        Image(systemName: "xmark.square.fill")
                                            .foregroundColor(.red)
                                            .frame(width: 12, height: 12)
                                    }
                                    ForEach(0 ..< item.forfeits, id: \.self) { _ in
                                        Image(systemName: "exclamationmark.square.fill")
                                            .foregroundColor(.pink)
                                            .frame(width: 12, height: 12)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                Text("Wins: \(item.wins) Draws: \(item.draws) Losses: \(item.losses)")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                Text("Forfeits: \(item.forfeits) Byes: \(item.byes)")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        Section(header: Text("Goals")) {
                            VStack {
                                Text(String(repeating: "●", count: item.scoreFor))
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.green)
                                    .padding(.vertical, 0)
                                    .padding(.horizontal, -8)
                                Text(String(repeating: "●", count: item.scoreAgainst))
                                    .font(.system(size:20))
                                    .foregroundStyle(Color.red)
                                    .padding(.vertical, 0)
                                    .padding(.horizontal, -8)
                                Text("For: \(item.scoreFor) Against: \(item.scoreAgainst) Diff: \(item.diff)")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        Section(header: Text("Games")) {
                            ForEach(rounds, id: \.id) { round in
                                DetailScheduleView(myTeam: item.teamName, round: round)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if sharedData.refreshLadder {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(item.teamName)
                    .foregroundStyle(Color("ForegroundColor"))
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(ShortClubName(fullName: item.teamName))
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
        
    func myloadData() async {
        (rounds, errURL) = GetSchedData(mycompID: item.compID, myTeamID: item.teamID, myTeamName: item.teamName)
        haveData = true
    }
}

#Preview {
    LadderItemView(item: LadderItem(id: UUID(), pos:1, teamName: "Greensborough", compID: "123123", teamID: "12312",  played: 18, wins: 12, draws: 1, losses: 5, forfeits: 0, byes: 0, scoreFor: 41, scoreAgainst: 12, diff: 21, points: 55, winRatio: 88), myTeamID: "12312")
}
