//
//  SelectClubView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 25/10/2023.
//

import SwiftUI
import SwiftData

struct SelectClubView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \Teams.clubName) var teams: [Teams]
    var isNavigationLink: Bool
    @State private var showingConfirmation = false
    var body: some View {
        NavigationStack {
            let uniqueClubs = Array(Set(teams.map { $0.clubName }))
            List {
                ForEach(uniqueClubs.sorted(), id: \.self) { club in
                    NavigationLink(destination: SelectTeamView(myClub: club)) {
                        HStack {
                            Image(club)
                                .resizable()
                                .frame(width: 45, height: 45)
                            Text(club)
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image("fulllogo1")
                        .resizable()
                        .frame(width: 93, height: 34)
                }
                ToolbarItem(placement: .principal) {
                    Text("Select your club")
                        .foregroundStyle(Color("ForegroundColor"))
                        .fontWeight(.bold)
                }
                if !isNavigationLink {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            showingConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "chevron.backward")
                                    .font(Font.system(size: 17, weight: .semibold))
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color("AccentColor"))
                                Text("Rebuild")
                                    .foregroundStyle(Color("AccentColor"))
                            }
                        }
                        .confirmationDialog("Are you sure?", isPresented: $showingConfirmation)
                        {
                            Button("Rebuild club/team lists from website?", role: .destructive) {
                                do {
                                    try context.delete(model: Teams.self)
                                    try context.save()
                                    try context.delete(model: Teams.self)
                                    try context.save()
                                } catch {
                                    print("failed to delete")
                                }
                            }
                        } message: {
                            Text("This will delete all currently selected teams ")
                        }
                    }
                }
            }
            .toolbarBackground(Color("BackgroundColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            
        }
        .accentColor(Color("AccentColor"))
    }
}

#Preview {
    SelectClubView(isNavigationLink: false)
}
