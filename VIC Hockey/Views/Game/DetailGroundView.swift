//
//  DetailGroundView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 7/11/2023.
//

import SwiftUI

struct DetailGroundView: View {
    var body: some View {
        Section(header: Text("Ground Details")) {
            HStack {
                Spacer()
                Image(systemName: "sportscourt.fill")
                    .resizable()
                    .frame(width: 40, height: 30)
                Text(" \(myRound.field)")
                    .font(.largeTitle)
                Spacer()
            }
            VStack {
                Text(myRound.venue)
                Text(myRound.address)
            }
        }
    }
}

#Preview {
    DetailGroundView()
}
