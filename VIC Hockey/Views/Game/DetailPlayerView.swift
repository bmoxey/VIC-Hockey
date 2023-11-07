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
            ForEach(0 ..< player.greenCards, id: \.self) {_ in
                Image(systemName: "triangleshape.fill")
                    .foregroundStyle(Color(.green))
            }
            ForEach(0 ..< player.yellowCards, id: \.self) {_ in
                Image(systemName: "square.fill")
                    .foregroundStyle(Color(.yellow))
            }
            ForEach(0 ..< player.redCards, id: \.self) {_ in
                Image(systemName: "circle.fill")
                    .foregroundStyle(Color(.red))
            }
            Spacer()
            Text(player.goals)
        }
    }
}

#Preview {
    DetailPlayerView(player: Player(name: "Brett Moxey", goals: "12", greenCards: 1, yellowCards: 2, redCards: 0, goalie: 0, surname: "Moxey", captain: true))
}
