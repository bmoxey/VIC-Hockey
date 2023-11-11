//
//  DetailRoundView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 11/11/2023.
//

import SwiftUI

struct DetailRoundView: View {
    var myTeam: String
    var myRound: Round
    var body: some View {
        
        VStack {
            if myRound.starts != "" {
                Text(myRound.starts)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            HStack {
                Image(ShortClubName(fullName: myRound.homeTeam))
                    .resizable()
                    .frame(width: 60, height: 60)
                Text(myRound.homeTeam)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .frame(width: 160)
                    .fontWeight(myRound.homeTeam == myTeam ? .bold : .regular)
                    .foregroundStyle(Color(myRound.homeTeam == myTeam ? Color("AccentColor") : .default))
                if myRound.starts == "" {
                    Text("\(myRound.homeGoals)")
                        .font(.largeTitle)
                        .frame(width: 60, height: 45)
                        .background(myRound.homeTeam == myTeam ? BarBackground(result: myRound.result) : Color(.clear))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            Text("VS")
            HStack {
                Image(ShortClubName(fullName: myRound.awayTeam))
                    .resizable()
                    .frame(width: 60, height: 60)
                Text(myRound.awayTeam)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .frame(width: 160)
                    .fontWeight(myRound.awayTeam == myTeam ? .bold : .regular)
                    .foregroundStyle(Color(myRound.awayTeam == myTeam ? Color("AccentColor") : .default))
                if myRound.starts == "" {
                    Text("\(myRound.awayGoals)")
                        .font(.largeTitle)
                        .frame(width: 60, height: 45)
                        
                        .background(myRound.awayTeam == myTeam ? BarBackground(result: myRound.result) : Color(.clear))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        
    }
}

#Preview {
    DetailRoundView(myTeam: "MHSOB", myRound: Round(id: UUID(), roundNo: "1", fullRound: "Round 1", dateTime: "Sat 15 Apr 2023 @ 14:00", field: "MBT", venue: "Melbourne Hockey Field", address: "21 Smith St", opponent: "Hawthorn", homeTeam: "Hawthorn", awayTeam: "MHSOB", homeGoals: 6, awayGoals: 7, score: "6 - 7", starts: "", result: "Win", played: "Completed", game: "1439971"))
}
