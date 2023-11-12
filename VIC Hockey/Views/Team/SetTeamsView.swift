//
//  SettingsView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 2/11/2023.
//

import SwiftUI
import SwiftData

struct SetTeamsView: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject private var sharedData: SharedData
    @Query (sort: \Teams.divType) var teams: [Teams]
    @Query(filter: #Predicate<Teams> {$0.isCurrent} ) var currentTeam: [Teams]
    @Query(filter: #Predicate<Teams> {$0.isUsed} ) var usedTeams: [Teams]
    @State private var isButtonTapped = false
    @State private var showingConfirmation = false
    @State private var shouldShowNoDataView = false
    @State private var isNavigationLinkActive = false
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Current")) {
                    ForEach(currentTeam, id: \.self) { team in
                        DetailTeamView(team: team)
                    }
                }
                if usedTeams.count > 1 {
                    Section(header: Text("Previous")) {
                        ForEach(usedTeams, id: \.self) { team in
                            if !currentTeam.isEmpty {
                                if team.teamID != currentTeam[0].teamID {
                                    DetailTeamView(team: team)
                                    .onTapGesture  { indexSet in
                                        for index in 0 ..< teams.count {
                                            teams[index].isCurrent = false
                                        }
                                        if let index = usedTeams.firstIndex(of: team) {
                                            usedTeams[index].isCurrent = true
                                            sharedData.refreshSchedule = true
                                            sharedData.refreshLadder = true
                                            sharedData.refreshRound = true
                                            sharedData.refreshStats = true
                                            sharedData.activeTabIndex = 0
                                        }
                                        
                                    }
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                usedTeams[index].isUsed = false
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Select team")
                            .foregroundStyle(Color("BarForeground"))
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Image(systemName: "person.text.rectangle.fill")
                            .foregroundStyle(Color.white)
                            .font(.title3)
                        Button(action: {
                            showingConfirmation = true
                        }, label: {
                            VStack {
                                Image(systemName: "arrow.triangle.2.circlepath.icloud.fill")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 40)
                                    .foregroundStyle(Color.white)
                                Text("Rebuild")
                                    .font(.footnote)
                                    .foregroundStyle(Color.white)
                            }
                        })
                        .confirmationDialog("Are you sure?", isPresented: $showingConfirmation)
                        {
                            Button("Rebuild club/team lists from website?", role: .destructive) {
                                do {
                                    try context.delete(model: Teams.self)
                                    try context.save()
                                    try context.delete(model: Teams.self)
                                    try context.save()
                                    shouldShowNoDataView = true
                                } catch {
                                    print("failed to delete")
                                }
                                
                            }
                            .sheet(isPresented: $shouldShowNoDataView) {
                                ContentView()
                            }
                        } message: {
                            Text("This will delete all currently selected teams \n This process will take approx 5 mins")
                        }
                    }

                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SelectClubView(isNavigationLink: true, isResetRefresh: true)) {
                        HStack {
                            Text("Add")
                                .foregroundStyle(Color.white)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.white)
                                .font(Font.system(size: 17, weight: .semibold))
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
            .padding(.horizontal, -8)
            .toolbarBackground(Color("BarBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color("BarBackground"), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
        
    }
}

#Preview {
    SetTeamsView()
}
