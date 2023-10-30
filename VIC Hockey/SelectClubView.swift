//
//  SelectClubView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 25/10/2023.
//

import SwiftUI
import SwiftData

struct SelectClubView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @Query(sort: \Teams.clubName) var teams: [Teams]
    @State private var showingConfirmation = false
    var body: some View {
        NavigationStack {
            let uniqueClubs = Array(Set(teams.map { $0.clubName }))
            List {
                ForEach(uniqueClubs.sorted(), id: \.self) { club in
                    NavigationLink(destination: SelectTeamView(selectedText: club)) {
                        HStack {
                            Image(club)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .padding(.horizontal, 8)
                            Text(club)
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image("fulllogo1")
                        .resizable()
                        .frame(width: 93, height: 34)
                }
                ToolbarItem(placement: .principal) {
                    Text("Select your club")
                        .foregroundStyle(Color(.white))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingConfirmation = true
                    }) {
                        VStack {
                            Image(systemName: "arrow.triangle.2.circlepath.icloud")
                            Text("Rebuild lists")
                                .font(.subheadline)
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
            .toolbarBackground(Color("VICBlue"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    SelectClubView()
}
