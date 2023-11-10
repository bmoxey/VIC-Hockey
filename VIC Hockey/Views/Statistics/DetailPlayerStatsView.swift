//
//  DetailPlayerStatsView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 10/11/2023.
//

import SwiftUI

struct DetailPlayerStatsView: View {
    var playerStat: PlayerStat
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(playerStat.roundNo) - \(playerStat.dateTime)")
                    .font(.footnote)
                    .foregroundStyle(Color(.gray))
                Text(playerStat.teamName)
            }
            if playerStat.goalie == 1 {
                Text(" (GK)")
            }
            if playerStat.greenCards > 0 {
                Text(String(repeating: "▲", count: playerStat.greenCards))
                    .font(.system(size:24))
                    .foregroundStyle(Color.green)
                    .padding(.vertical, 0)
                    .padding(.horizontal, 0)
            }
            if playerStat.yellowCards > 0 {
                Text(String(repeating: "■", count: playerStat.yellowCards))
                    .font(.system(size:24))
                    .foregroundStyle(Color.yellow)
                    .padding(.vertical, 0)
                    .padding(.horizontal, 0)
            }
            if playerStat.redCards > 0 {
                Text(String(repeating: "●", count: playerStat.redCards))
                .font(.system(size:24))
                .foregroundStyle(Color.red)
                .padding(.vertical, 0)
                .padding(.horizontal, 0)
            }
            Spacer()
            if playerStat.goals > 0 {
                Text(String(repeating: "●", count: playerStat.goals))
                .font(.system(size:20))
                .foregroundStyle(Color.green)
                .padding(.vertical, 0)
                .padding(.horizontal, 0)
            }
        }
    }
}

#Preview {
    DetailPlayerStatsView(playerStat: PlayerStat(roundNo: "Round 1", dateTime: "Sat 15 Apr 2023 15:30", teamID: "123", teamName: "Waverley Hockey Club", clubName: "Waverley", divName: "State league 1", goals: 2, greenCards: 1, yellowCards: 1, redCards: 0, goalie: 0))
}
