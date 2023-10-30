//
//  ScheduleView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 29/10/2023.
//

import SwiftUI
import SwiftData


struct ScheduleView: View {
    @Environment(\.modelContext) var context
    @State private var rounds = [Round]()
    @Query(filter: #Predicate<Teams> {$0.isCurrent} ) var currentTeam: [Teams]
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(Set(rounds.map { $0.played })).sorted(by: >), id: \.self) { played in
                    Section(header: Text(played)) {
                        ForEach(rounds, id: \.id) {item in
                            if item.played == played {
                                NavigationLink(destination: SelectTeamView(selectedText: item.venue)) {
                                    HStack {
                                        VStack {
                                            Text(item.roundNo)
                                            Image(ShortClubName(fullName: item.opponent))
                                                .resizable()
                                                .frame(width: 45, height: 45)
                                                .padding(.top, -6)
                                        }
                                        VStack {
                                            HStack {
                                                Text("\(item.dateTime)")
                                                Spacer()
                                            }
                                            HStack {
                                                Text("\(item.opponent) @ \(item.venue)")
                                                Spacer()
                                            }
                                            HStack {
                                                if item.starts != "" {
                                                    Text("\(item.starts)")
                                                        .foregroundColor(Color.red)
                                                } else {
                                                    Text(" Result: \(item.score) \(item.result) ")
                                                        .foregroundColor(.white)
                                                        .background(backgroundColor(for: item.result))
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
//            .background(Color("VICOrange"))
            .scrollContentBackground(.hidden)
            .listStyle(GroupedListStyle())
            .task {
                await loadData()
            }
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("\(currentTeam[0].teamName)")
                            .foregroundColor(.white)
                            .font(.footnote)
                        Text("\(currentTeam[0].divName)")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(currentTeam[0].clubName)
                        .resizable()
                        .frame(width: 45, height: 45)
                }
            }
            .toolbarBackground(Color("VICBlue"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color("VICBlue"), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
    func loadData() async {
        var id: Int = 0
        var round: String = ""
        var dateTime: String = ""
        var venue: String = ""
        var opponent: String = ""
        var score: String = ""
        var starts: String = ""
        var result: String = ""
        var played: String = ""
        rounds = []
        guard let url = URL(string: "https://www.hockeyvictoria.org.au/teams/" + currentTeam[0].compID + "/&t=" + currentTeam[0].teamID) else {
            print("Invalid URL")
            return
        }
        
        do {
            let html = try String.init(contentsOf: url)
            let line = html.split(whereSeparator: \.isNewline)
            for i in 0 ..< line.count {
                if line[i].contains("col-md pb-3 pb-lg-0 text-center text-md-left") {
                    id += 1
                    round = GetRound(fullString: GetPart(fullString: String(line[i+1]), partNumber: 2))
                    dateTime = String(line[i+2].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "<br />", with: " @ "))
                    starts = GetStart(inputDate: dateTime)
                    if starts == "" {
                        played = "Completed"
                    } else {
                        played = "Upcoming"
                    }
                }
                if line[i].contains("col-md pb-3 pb-lg-0 text-center text-md-right text-lg-left") {
                    venue = GetPart(fullString: String(line[i+2]), partNumber: 2)
                }
                if line[i].contains("col-lg-3 pb-3 pb-lg-0 text-center") {
                    if venue == "/div" {
                        venue = "BYE"
                        opponent = "BYE"
                        score = "BYE"
                    } else {
                        opponent = ShortTeamName(fullName: GetPart(fullString: String(line[i+2]), partNumber: 6))
                        score = GetPart(fullString: GetScore(fullString: String(line[i+2])), partNumber: 9)
                        if score == "div" {
                            score = ""
                            result = ""
                        } else {
                            result = GetPart(fullString: GetScore(fullString: String(line[i+2])), partNumber: 14)
                        }
                    }
                    rounds.append(Round(id: id, roundNo: round, dateTime: dateTime, venue: venue, opponent: opponent, score: score, starts: starts, result: result, played: played))
                }
            }
        } catch {
            print("Invalid data")
            
        }
    }
    
    //    if item.result == "Win" {
    //                                            .background(.green)
    //                                    } else if item.result == "Loss" {
    //                                            .background(.red)
    //                                    } else if item.result == "Draw" {
    //                                            .background(.gray)
    //                                    } else  {
    //                                            .background(.cyan)
    //                                    }
    func backgroundColor(for result: String) -> Color {
        switch result {
        case "Win":
            return Color.green
        case "Loss":
            return Color.red
        case "Draw":
            return Color.gray
        default:
            return Color.cyan
        }
    }
}

#Preview {
    ScheduleView()
}
