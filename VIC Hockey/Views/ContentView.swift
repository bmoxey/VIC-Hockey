//
//  ContentView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 20/10/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var networkMonitor = NetworkMonitor()
    @State var stillLoading : Bool = false
    @Environment(\.modelContext) var context
    @Query(sort: \Teams.compID) var teams: [Teams]
    @Query(filter: #Predicate<Teams> {$0.isCurrent} ) var currentTeam: [Teams]

    var body: some View {
        VStack {
            if !networkMonitor.isConnected {
                NoNetworkView()
            } else {
                if teams.isEmpty || stillLoading {
                    SelectCompView(stillLoading: $stillLoading)
                } else {
                    if currentTeam.isEmpty {
                        SelectClubView()
                    } else {
                        MainTabView()
                    }
                }
            }
        }
        .onAppear { networkMonitor.start() }
        .onDisappear { networkMonitor.stop() }
    }
}

#Preview {
    ContentView()
}
