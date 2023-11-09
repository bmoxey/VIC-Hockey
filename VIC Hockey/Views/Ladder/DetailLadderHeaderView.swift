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
                .font(.footnote)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Text("GD")
                .font(.footnote)
                .frame(width: 35, alignment: .trailing)
            Text("Pts")
                .font(.footnote)
                .frame(width: 35, alignment: .trailing)
            Text("WR")
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
