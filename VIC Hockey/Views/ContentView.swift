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
    @Environment(\.modelContext) var context
    @State var stillLoading : Bool = false
    @Query var teams: [Teams]
    @Query(filter: #Predicate<Teams> {$0.isCurrent} ) var currentTeam: [Teams]
    
    var body: some View {
        VStack {
            if !networkMonitor.isConnected {
                NoNetworkView()
            } else {
                if teams.isEmpty || stillLoading {
                    SelectCompetitionView(stillLoading: $stillLoading)
                } else {
                    if currentTeam.isEmpty {
                        SelectClubView(isNavigationLink: false)
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
