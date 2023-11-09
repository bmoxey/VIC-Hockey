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
            HStack {
                Image(ShortClubName(fullName: round.opponent))
                    .resizable()
                    .frame(width: 45, height: 45)
                VStack {
                    HStack {
                        Text("\(round.dateTime)")
                        Spacer()
                    }
                    HStack {
                        Text("\(round.opponent) @ \(round.field)")
                        Spacer()
                    }
                }
            }
            if round.starts != "" {
                Text("\(round.starts)")
                    .foregroundColor(Color.red)
            } else {
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
                        .foregroundStyle(Color.black)
                        .fontWeight(.bold)
                        .background(BackgroundColor(result: round.result))
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
    DetailScheduleView(myTeam: "MHSOB", round: Round(id: UUID(), roundNo: "1", fullRound: "Round 1", dateTime: "Sat 15 Apr 2023 @ 14:00", field: "MBT", venue: "Melbourne Hockey Field", address: "21 Smith St", opponent: "Hawthorn", homeTeam: "Hawthorn", awayTeam: "MHSOB", homeGoals: 6, awayGoals: 11, score: "6 - 7", starts: "", result: "Win", played: "Completed", game: "1439971"))
}


