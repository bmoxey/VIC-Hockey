//
//  DetailScheduleView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 6/11/2023.
//

import SwiftUI

struct DetailScheduleView: View {
    let myTeam: String
    let round: Round
    var body: some View {
        VStack {
            Text("\(round.fullRound)")
                .font(.footnote)
                .foregroundStyle(Color(.gray))
            HStack {
                Image(ShortClubName(fullName: round.opponent))
                    .resizable()
                    .frame(width: 60, height: 60)
                VStack {
                    HStack {
                        Text("\(round.dateTime)")
                            .foregroundStyle(Color(round.result == "BYE" ? "AccentColor" : "DefaultColor"))
                        Spacer()
                    }
                    HStack {
                        Text("\(round.opponent) @ \(round.field)")
                            .foregroundStyle(Color(round.result == "BYE" ? "AccentColor" : "DefaultColor"))
                        Spacer()
                    }
                }
            }
            if round.starts != "" {
                Text("\(round.starts)")
                    .foregroundStyle(Color(.red))
            }
            if round.result != "" {
                HStack {
                    HStack {
                        Spacer()
                        Text(String(repeating: "●", count: round.homeGoals))
                            .foregroundStyle(round.homeTeam == myTeam ? Color.green : Color.red)
                            .font(.system(size:20))
                            .padding(.vertical, 0)
                            .padding(.horizontal, 0)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(nil)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(.leading, -8)
                    Text(" \(round.score) \(round.result) ")
                        .foregroundStyle(Color(round.result == "BYE" ? Color.white : Color.black))
                        .fontWeight(.bold)
                        .background(BarBackground(result: round.result))
                    HStack {
                        Text(String(repeating: "●", count: round.awayGoals))
                            .foregroundStyle(round.awayTeam == myTeam ? Color.green : Color.red)
                            .font(.system(size:20))
                            .padding(.vertical, 0)
                            .padding(.horizontal, 0)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                        Spacer()
                    }
                    .padding(.trailing, -8)
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
                
            }
            
        }
        
    }
}

#Preview {
    DetailScheduleView(myTeam: "MHSOB", round: Round(id: UUID(), fullRound: "Round 1", dateTime: "Sat 15 Apr 2023 @ 14:00", field: "MBT", venue: "Melbourne Hockey Field", address: "21 Smith St", opponent: "Hawthorn", homeTeam: "Hawthorn", awayTeam: "MHSOB", homeGoals: 6, awayGoals: 11, score: "6 - 7", starts: "", result: "Win", played: "Completed", game: "1439971"))
}


