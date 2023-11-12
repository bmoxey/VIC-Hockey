//
//  DetailGameView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 7/11/2023.
//

import SwiftUI

struct DetailGameView: View {
    var myTeam: String
    var myRound: Round
    var body: some View {
        Section(header: Text("Game Details")) {
            VStack {
                Text(myRound.dateTime)
                    .frame(maxWidth: .infinity, alignment: .center)
                if myRound.starts != "" {
                    Text(myRound.starts)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                HStack {
                    Image(ShortClubName(fullName: myRound.homeTeam))
                        .resizable()
                        .frame(width: 120, height: 120)
                    Text("VS")
                    Image(ShortClubName(fullName: myRound.awayTeam))
                        .resizable()
                        .frame(width: 120, height: 120)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                VStack {
                    if myRound.starts == "" {
                        HStack {
                            Text("\(myRound.homeGoals)")
                                .font(.largeTitle)
                                .frame(width: 140, height: 50)
                                .background(myRound.homeTeam == myTeam ? BarBackground(result: myRound.result) : Color(.clear))
                            Text("\(myRound.awayGoals)")
                                .font(.largeTitle)
                                .frame(width: 140, height: 50)
                                .background(myRound.awayTeam == myTeam ? BarBackground(result: myRound.result) : Color(.clear))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    HStack {
                        Text(myRound.homeTeam)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .frame(width: 140)
                            .fontWeight(myRound.homeTeam == myTeam ? .bold : .regular)
                            .foregroundStyle(Color(myRound.homeTeam == myTeam ? "AccentColor" : "DefaultColor"))
                        Text(myRound.awayTeam)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .frame(width: 140)
                            .fontWeight(myRound.awayTeam == myTeam ? .bold : .regular)
                            .foregroundStyle(Color(myRound.awayTeam == myTeam ? "AccentColor" : "DefaultColor"))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

#Preview {
    DetailGameView(myTeam: "MHSOB", myRound: Round(id: UUID(), roundNo: "1", fullRound: "Round 1", dateTime: "Sat 15 Apr 2023 @ 14:00", field: "MBT", venue: "Melbourne Hockey Field", address: "21 Smith St", opponent: "Hawthorn", homeTeam: "Hawthorn", awayTeam: "MHSOB", homeGoals: 6, awayGoals: 7, score: "6 - 7", starts: "", result: "Win", played: "Completed", game: "1439971"))
}
