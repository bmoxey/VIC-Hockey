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
    var body: some View {
        
        NavigationStack {
            List {
                Section(header: Text("Current")) {
                    ForEach(currentTeam, id: \.self) { team in
                        VStack {
                            HStack {
                                Spacer()
                                Image(team.clubName)
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                Text(team.divType.uppercased())
                                    .font(.largeTitle)
                                Spacer()
                            }
                            .padding(.bottom, -8)
                            .padding(.top, 8)
                            Text(team.clubName)
                                .font(.title)
                            Text(team.divName)
                            if team.teamName != team.clubName {
                                Text("competing as \(team.teamName)")
                                    .font(.footnote)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
                if usedTeams.count > 1 {
                    Section(header: Text("Previous")) {
                        ForEach(usedTeams, id: \.self) { team in
                            if !currentTeam.isEmpty {
                                if team.teamID != currentTeam[0].teamID {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Image(team.clubName)
                                                .resizable()
                                                .frame(width: 45, height: 45)
                                            Text(team.divType.uppercased())
                                                .font(.largeTitle)
                                            Spacer()
                                        }
                                        .padding(.bottom, -8)
                                        .padding(.top, 8)
                                        Text(team.clubName)
                                            .font(.title)
                                        Text(team.divName)
                                        if team.teamName != team.clubName {
                                            Text("competing as \(team.teamName)")
                                                .font(.footnote)
                                        }
                                    }
                                    .onTapGesture  { indexSet in
                                        for index in 0 ..< teams.count {
                                            teams[index].isCurrent = false
                                        }
                                        if let index = usedTeams.firstIndex(of: team) {
                                            usedTeams[index].isCurrent = true
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
                            .foregroundStyle(Color("ForegroundColor"))
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Image(systemName: "person.text.rectangle.fill")
                            .foregroundStyle(Color("AccentColor"))
                            .font(.title3)
                        Button(action: {
                            showingConfirmation = true
                        }, label: {
                                Text("Rebuild")
                                    .foregroundStyle(Color("AccentColor"))
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
                            Text("This will delete all currently selected teams ")
                        }
                    }

                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SelectClubView(isNavigationLink: true)) {
                        HStack {
                            Text("Add")
                                .foregroundStyle(Color("AccentColor"))
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color("AccentColor"))
                                .font(Font.system(size: 17, weight: .semibold))
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
            .padding(.horizontal, -8)
            .toolbarBackground(Color("BackgroundColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color("BackgroundColor"), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            
        }
    }
}

#Preview {
    SetTeamsView()
}
