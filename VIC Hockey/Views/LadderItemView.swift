//
//  LadderItemView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 3/11/2023.
//

import SwiftUI

struct LadderItemView: View {
    var item: LadderItem
    var body: some View {
        NavigationStack {
            VStack {
                Text("")
                Text(item.teamName)
                    .font(.largeTitle)
                Image(ShortClubName(fullName: item.teamName))
                    .resizable()
                    .frame(width: 120, height: 120)
                Text("Results")
                    .font(.title)
                HStack {
                    ForEach(0 ..< item.wins, id: \.self) { _ in
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(.green)
                            .padding(.horizontal,-4)
                    }
                    ForEach(0 ..< item.draws, id: \.self) { _ in
                        Image(systemName: "minus.square.fill")
                            .foregroundColor(.gray)
                            .padding(.horizontal,-4)
                    }
                    ForEach(0 ..< item.losses, id: \.self) { _ in
                        Image(systemName: "xmark.square.fill")
                            .foregroundColor(.red)
                            .padding(.horizontal,-4)
                    }
                    
                }
                Text("Wins: \(item.wins) Draws: \(item.draws) Losses: \(item.losses)")
                Text("Forfeits: \(item.forfeits) Byes: \(item.byes)")
                Text("")
                Text("Goals")
                    .font(.title)
                Text(String(repeating: "🟢", count: item.scoreFor))
                    .font(.system(size: 12))
                    .padding(.vertical, 0)
                    .padding(.horizontal, 8)
                Text(String(repeating: "🔴", count: item.scoreAgainst))
                    .font(.system(size:12))
                    .padding(.vertical, 0)
                    .padding(.horizontal, 8)
                Text("For: \(item.scoreFor) Against: \(item.scoreAgainst)")
                Text("Diff: \(item.diff)")
                Text("")
                Text("Points")
                    .font(.title)
                HStack {
                    VStack {
                        Text("Wins")
                        Text("\(item.wins)")
                            .font(.title)
                    }
                    Text("x 3 +")
                    VStack {
                        Text("Draws")
                        Text("\(item.draws)")
                            .font(.title)
                    }
                    Text("=")
                    VStack {
                        Text("Points")
                        Text("\(item.points)")
                            .font(.title)
                    }
                }
                HStack {
                    VStack {
                        Text("Points")
                        Text("\(item.points)")
                            .font(.title)
                    }
                    Text("/")
                    VStack {
                        Text("Games")
                        Text("\(item.played)")
                            .font(.title)
                    }
                    Text("*")
                    VStack {
                        Text(" ")
                        Text("33.3")
                            .font(.title)
                    }
                    Text("=")
                    VStack {
                        Text("WR")
                        Text("\(item.winRatio)%")
                            .font(.title)
                    }
                }
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(item.teamName)
                        .fontWeight(.bold)
                        .foregroundStyle(Color("ForegroundColor"))
                }
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
}

#Preview {
    LadderItemView(item: LadderItem(id: 1, teamName: "Greensborough", played: 18, wins: 12, draws: 1, losses: 5, forfeits: 0, byes: 0, scoreFor: 41, scoreAgainst: 12, diff: 21, points: 55, winRatio: 88))
}
