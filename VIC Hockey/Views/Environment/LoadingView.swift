//
//  LoadingView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 6/11/2023.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
//            Image(systemName: "hourglass")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 120, height: 240)
//                .foregroundStyle(Color(.gray))
            Text("Loading...")
                .font(.largeTitle)
                .foregroundStyle(Color(.gray))
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    LoadingView()
}
