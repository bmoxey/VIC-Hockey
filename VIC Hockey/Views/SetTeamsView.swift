//
//  SettingsView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 2/11/2023.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) var context
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
                            Text(team.divType.uppercased())
                                .font(.largeTitle)
                                .padding(.bottom, -8)
                            HStack {
                                Image(team.clubName)
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                VStack {
                                    HStack {
                                        Text(team.clubName)
                                        Spacer()
                                    }
                                    HStack {
                                        Text(team.divName)
                                        Spacer()
                                    }
                                }
                            }
                            if team.teamName != team.clubName {
                                Text("competing as \(team.teamName)")
                                    .font(.footnote)
                            }
                        }
                    }
                }
                if usedTeams.count > 1 {
                    Section(header: Text("Previous")) {
                        ForEach(usedTeams, id: \.self) { team in
                            if !currentTeam.isEmpty {
                                if team.teamID != currentTeam[0].teamID {
                                    VStack {
                                        Text(team.divType.uppercased())
                                            .font(.largeTitle)
                                            .padding(.bottom, -8)
                                        HStack {
                                            Image(team.clubName)
                                                .resizable()
                                                .frame(width: 45, height: 45)
                                            VStack {
                                                HStack {
                                                    Text(team.clubName)
                                                    Spacer()
                                                }
                                                HStack {
                                                    Text(team.divName)
                                                    Spacer()
                                                }
                                            }
                                        }
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
                        Text("Select your team")
                            .foregroundStyle(Color("ForegroundColor"))
                            .fontWeight(.bold)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showingConfirmation = true
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .foregroundStyle(Color("AccentColor"))
                            Text("Redo")
                                .foregroundStyle(Color("AccentColor"))
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
                        Text("This will delete all currently selected teams ")
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
    SettingsView()
}
