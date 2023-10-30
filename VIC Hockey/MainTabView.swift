//
//  MainTabView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 26/10/2023.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) var context
    @Query(filter: #Predicate<Teams> {$0.isCurrent} ) var currentTeam: [Teams]
    var body: some View {
        TabView {
            ScheduleView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Schedule")
                }
            Text("bb")
                .tabItem {
                    Image(systemName: "list.number")
                    Text("Ladder")
                }
            Text("cc")
                .tabItem {
                    Image(systemName: "sportscourt.circle")
                    Text("Round")
                }
            Text("cd")
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Stats")
                }
            Text("dd")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Settings")
                }
            
        }
        .accentColor(Color(.white))
    }
}

#Preview {
    MainTabView()
}
