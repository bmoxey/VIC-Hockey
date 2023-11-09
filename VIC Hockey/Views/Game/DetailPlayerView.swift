//
//  DetailPlayerView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 7/11/2023.
//

import SwiftUI

struct DetailPlayerView: View {
    var player: Player
    var body: some View {
        HStack {
            Text(player.name)
            if player.goalie == 1 {
                Text(" (GK)")
            }
            if player.captain {
                Image(systemName: "star.circle")
                    .foregroundStyle(Color("ForegroundColor"))
            }
            if player.greenCards > 0 {
                Text(String(repeating: "▲", count: player.greenCards))
                    .font(.system(size:24))
                    .foregroundStyle(Color.green)
                    .padding(.vertical, 0)
                    .padding(.horizontal, 0)
            }
            if player.yellowCards > 0 {
                Text(String(repeating: "■", count: player.yellowCards))
                    .font(.system(size:24))
                    .foregroundStyle(Color.yellow)
                    .padding(.vertical, 0)
                    .padding(.horizontal, 0)
            }
            if player.redCards > 0 {
                Text(String(repeating: "●", count: player.redCards))
                .font(.system(size:24))
                .foregroundStyle(Color.red)
                .padding(.vertical, 0)
                .padding(.horizontal, 0)
            }
//            ForEach(0 ..< player.greenCards, id: \.self) {_ in
//                Image(systemName: "triangleshape.fill")
//                    .foregroundStyle(Color(.green))
//            }
//            ForEach(0 ..< player.yellowCards, id: \.self) {_ in
//                Image(systemName: "square.fill")
//                    .foregroundStyle(Color(.yellow))
//            }
//            ForEach(0 ..< player.redCards, id: \.self) {_ in
//                Image(systemName: "circle.fill")
//                    .foregroundStyle(Color(.red))
//            }
            Spacer()
            if player.goals > 0 {
                Text(String(repeating: "●", count: player.goals))
                .font(.system(size:20))
                .foregroundStyle(player.us ? Color.green : Color.red)
                .padding(.vertical, 0)
                .padding(.horizontal, 0)
            }
        }
    }
}

#Preview {
    DetailPlayerView(player: Player(name: "Brett Moxey", numberGames: 0, goals: 5, greenCards: 1, yellowCards: 2, redCards: 0, goalie: 0, surname: "Moxey", captain: true, us: true))
}
