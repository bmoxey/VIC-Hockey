//
//  DetailStatsView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 9/11/2023.
//

import SwiftUI

struct DetailStatsView: View {
    var player: Player
    var body: some View {
        HStack {
            Text(player.name)
            if player.goalie > 0 {
                Text("(GK)")
            }
            if player.captain {
                Image(systemName: "star.circle")
                    .foregroundStyle(Color("AccentColor"))
            }
            if player.greenCards > 0 {
                Text(String(repeating: "▲", count: player.greenCards))
                    .font(.system(size:20))
                    .foregroundStyle(Color.green)
                    .padding(.vertical, 0)
                    .padding(.horizontal, 0)
            }
            if player.yellowCards > 0 {
                Text(String(repeating: "■", count: player.yellowCards))
                    .font(.system(size:20))
                    .foregroundStyle(Color.yellow)
                    .padding(.vertical, 0)
                    .padding(.horizontal, 0)
            }
            if player.redCards > 0 {
                Text(String(repeating: "●", count: player.redCards))
                .font(.system(size:20))
                .foregroundStyle(Color.red)
                .padding(.vertical, 0)
                .padding(.horizontal, 0)
            }
            Spacer()
            Text("\(player.goals)")
                .frame(width: 30)
            Text("\(player.numberGames)")
                .frame(width: 30)
        }
        .lineLimit(nil)
    }
}

#Preview {
    DetailStatsView(player: Player(name: "Brett Moxey", numberGames: 2, goals: 5, greenCards: 1, yellowCards: 2, redCards: 0, goalie: 0, surname: "Moxey", captain: true, us: true, statsLink: ""))
}
