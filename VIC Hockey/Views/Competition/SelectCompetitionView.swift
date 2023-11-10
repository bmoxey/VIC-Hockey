//
//  SelectCompetitionView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 6/11/2023.
//

import SwiftUI
import SwiftData

struct SelectCompetitionView: View {
    @Environment(\.modelContext) var context
    @Binding var stillLoading: Bool
    @State private var haveData = false
    @State private var errURL = ""
    @State private var searching = false
    @State private var comps: [String] = []
    @State private var selectedComps: Set<String> = []
    @State private var searchComp: String = ""
    @State private var searchDiv: String = ""
    @State private var teamsFound = 0
    @State private var selectedWeek = 1
    var body: some View {
        NavigationStack {
            VStack {
                if !haveData {
                    LoadingView()
                        .task { await loadData() }
                } else {
                    if errURL != "" {
                        InvalidURLView(url: errURL)
                    } else {
                        if searching {
                            DetailSearchView(searchComp: searchComp, searchDiv: searchDiv, teamsFound: teamsFound)
                                .task { await searchData() }
                        } else {
                            DetailCompetitionView(selectedComps: $selectedComps, searching: $searching, comps: comps)
                                .onAppear { stillLoading = true }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(searching ? "Searching competitions..." : "Select your competitions")
                        .foregroundStyle(Color("BarForeground"))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image("fulllogo1")
                        .resizable()
                        .frame(width: 93, height: 34)
                }
            }
            .toolbarBackground(Color("BarBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    func loadData() async {
        var myCompName = ""
        var lines: [String] = []
        (lines, errURL) = GetUrl(url: "https://www.hockeyvictoria.org.au/games/")
        for i in 0 ..< lines.count {
            if lines[i].contains("https://www.hockeyvictoria.org.au/reports/games/download/") {
                myCompName = GetPart(fullString: String(lines[i-1]), partNumber: 3)
                comps.append(myCompName)
                if myCompName.contains("Senior Competition") { selectedComps.insert(myCompName)}
                if myCompName.contains("Midweek Competition") { selectedComps.insert(myCompName)}
                if myCompName.contains("Junior Competition") { selectedComps.insert(myCompName)}
            }
        }
        haveData = true
    }
    
    func searchData() async {
        var myStatus = false
        var myCompName = ""
        var myCompID = ""
        var myDivName = ""
        var myDivID = ""
        var myTeamName = ""
        var myTeamID = ""
        var myClubName = ""
        var myDivType = ""
        var myDivLevel = ""
        var lines: [String] = []
        var newlines: [String] = []
        (lines, errURL) = GetUrl(url: "https://www.hockeyvictoria.org.au/games/")
        for i in 0 ..< lines.count {
            if lines[i].contains("https://www.hockeyvictoria.org.au/reports/games/download/") {
                myCompName = GetPart(fullString: String(lines[i-1]), partNumber: 3)
                if selectedComps.contains(myCompName) { myStatus = true } else {myStatus = false}
            }
            if myStatus {
                if lines[i].contains("https://www.hockeyvictoria.org.au/games/") {
                    myCompID = GetPart(fullString: String(lines[i]), partNumber: 3)
                    myDivID = GetPart(fullString: String(lines[i]), partNumber: 5)
                    myDivName = GetPart(fullString: String(lines[i]), partNumber: 6)
                    myDivName = ShortDivName(fullName: myDivName)
                    myDivLevel = GetDivLevel(fullString: myDivName)
                    if myDivID.isNumeric && myCompID.isNumeric {
                        searchComp = myCompName
                        searchDiv = myDivName
                        (newlines, errURL) = GetUrl(url: "https://www.hockeyvictoria.org.au/games/\(myCompID)/&r=\(selectedWeek)&d=\(myDivID)")
                        for j in 0 ..< newlines.count {
                            if newlines[j].contains("https://www.hockeyvictoria.org.au/teams") {
                                let mybit = newlines[j].components(separatedBy: ":")
                                for k in 0 ..< mybit.count {
                                    if mybit[k].contains("//www.hockeyvictoria.org.au/teams") {
                                        myTeamName = GetPart(fullString: String(mybit[k]), partNumber: 4)
                                        myTeamName = ShortTeamName(fullName: myTeamName)
                                        myClubName = ShortClubName(fullName: myTeamName)
                                        myTeamID = GetPart(fullString: String(mybit[k]), partNumber: 3)
                                        myDivType = GetDivType(fullName: myDivName)
                                        teamsFound += 1
                                        let team = Teams(compName: myCompName, compID: myCompID, divName: myDivName, divID: myDivID, divType: myDivType, divLevel: myDivLevel, teamName: myTeamName, teamID: myTeamID, clubName: myClubName, isCurrent: false, isUsed: false)
                                        context.insert(team)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        stillLoading = false
    }
}

#Preview {
    SelectCompetitionView(stillLoading: Binding.constant(true))
}
