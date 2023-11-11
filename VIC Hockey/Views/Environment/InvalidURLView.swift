//
//  InvalidURLView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 6/11/2023.
//

import SwiftUI

struct InvalidURLView: View {
    var url: String
    var body: some View {
        Spacer()
        Image("swearing")
            .resizable()
            .scaledToFit()
            .frame(width: 240, height: 240)
            .foregroundStyle(Color(.gray))
        Text("ERROR:")
            .font(.largeTitle)
            .foregroundStyle(Color(.red))
        Text(url)
        Text("Teams database may need to be rebuilt")
            .foregroundStyle(Color(.red))
            .fontWeight(.bold)
        Spacer()
        Spacer()
    }
}

#Preview {
    InvalidURLView(url: "https://www.hockeyvictoria.org.au/games/14682/&r=1&d=26171")
}
