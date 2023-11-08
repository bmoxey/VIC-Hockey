//
//  DetailLadderHeaderView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 8/11/2023.
//

import SwiftUI

struct DetailLadderHeaderView: View {
    var body: some View {
        HStack {
            Text("")
                .frame(width: 20)
            Text("")
                .frame(width: 45)
            Text("Team")
                .fontWeight(.bold)
                .font(.footnote)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Text("GD")
                .fontWeight(.bold)
                .font(.footnote)
                .frame(width: 35, alignment: .trailing)
            Text("Pts")
                .fontWeight(.bold)
                .font(.footnote)
                .frame(width: 35, alignment: .trailing)
            Text("WR")
                .fontWeight(.bold)
                .font(.footnote)
                .frame(width: 35, alignment: .trailing)
            Text(" ")
                .frame(width: 12)
        }
    }
}

#Preview {
    DetailLadderHeaderView()
}
