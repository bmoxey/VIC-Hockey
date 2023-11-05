//
//  SelectCompView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 20/10/2023.
//

import SwiftUI
import SwiftData

struct SelectCompView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @Binding var stillLoading: Bool
    @State private var comps: [String] = []
    @State private var selectedComps: Set<String> = []
    @State private var searching = false
    @State private var searchComp: String = ""
    @State private var searchDiv: String = ""
    @State private var selectedWeek = 1
    @State private var teamsFound = 0
    var body: some View {
        NavigationStack {
            VStack {
                if searching {
                    VStack {
                        Spacer()
                        Text("🔍")
                            .font(.system(size: 128, weight: .bold))
                        Text("")
                        Text("Searching ...")
                            .font(.largeTitle)
                        Text("")
                        Text(searchComp)
                        Text(searchDiv)
                        Text("Teams found: \(teamsFound)")
                        Spacer()
                        Spacer()
                    }
                } else {
                    VStack {
                        List(comps, id: \.self ) { comp in
                            HStack {
                                if self.selectedComps.contains(comp) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "hand.raised")
                                        .foregroundColor(.red)
                                }
                                
                                Text(comp)
                            }
                            .onTapGesture {
                                if self.selectedComps.contains(comp) {
                                    self.selectedComps.remove(comp)
                                } else {
                                    self.selectedComps.insert(comp)
                                }
                            }
                        }
                        Picker("Select week to search for teams", selection: $selectedWeek) {
                            ForEach(1..<19, id: \.self) { number in
                                Text("\(number)")
                            }
                        }
                        
                        .pickerStyle(.navigationLink)
                        .padding(.horizontal, 32)
                        .padding(.bottom)
                        Button(action: {
                            searching = true
                            Task { await searchData() }
                        }, label: {
                            Text("Search competitions")
                                .frame(width: 280, height: 50)
                                .background(.blue.gradient)
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .cornerRadius(10.0)
                        })
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image("fulllogo1")
                        .resizable()
                        .frame(minWidth: 93, idealWidth: 93, maxWidth: 93, minHeight: 34, idealHeight: 34, maxHeight: 34, alignment: .center)
                }
                ToolbarItem(placement: .principal) {
                    Text(searching ? "Searching competitions..." : "Select your competitions")
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color("VICBlue"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                stillLoading = true
            }
            
            
        }
        .task { await loadData() }
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
        guard let url = URL(string: "https://www.hockeyvictoria.org.au/games/")
        else {
            print("Invalid URL")
            return
        }
        do {
            let html = try String.init(contentsOf: url)
            let line = html.split(whereSeparator: \.isNewline)
            for i in 0 ..< line.count {
                if line[i].contains("https://www.hockeyvictoria.org.au/reports/games/download/") {
                    myCompName = GetPart(fullString: String(line[i-1]), partNumber: 3)
                    if selectedComps.contains(myCompName) { myStatus = true } else {myStatus = false}
                }
                if myStatus {
                    if line[i].contains("https://www.hockeyvictoria.org.au/games/") {
                        myCompID = GetPart(fullString: String(line[i]), partNumber: 3)
                        myDivID = GetPart(fullString: String(line[i]), partNumber: 5)
                        myDivName = GetPart(fullString: String(line[i]), partNumber: 6)
                        myDivName = ShortDivName(fullName: myDivName)
                        myDivLevel = GetDivLevel(fullString: myDivName)
                        if myDivID.isNumeric && myCompID.isNumeric {
                            searchComp = myCompName
                            searchDiv = myDivName
                            let myURL = "https://www.hockeyvictoria.org.au/games/\(myCompID)/&r=\(selectedWeek)&d=\(myDivID)"
                            guard let newurl = URL(string: myURL)
                            else {
                                print("Invalid URL")
                                return
                            }
                            do {
                                let newhtml = try String.init(contentsOf: newurl)
                                let newline = newhtml.split(whereSeparator: \.isNewline)
                                for j in 0 ..< newline.count {
                                    if newline[j].contains("https://www.hockeyvictoria.org.au/teams") {
                                        let mybit = newline[j].components(separatedBy: ":")
                                        for k in 0 ..< mybit.count {
                                            if mybit[k].contains("//www.hockeyvictoria.org.au/teams") {
                                                myTeamName = GetPart(fullString: String(mybit[k]), partNumber: 4)
                                                myTeamName = ShortTeamName(fullName: myTeamName)
                                                myClubName = ShortClubName(fullName: myTeamName)
                                                myTeamID = GetPart(fullString: String(mybit[k]), partNumber: 3)
                                                myDivType = GetDivType(fullName: myDivName)
                                                teamsFound += 1
                                                if myDivType == "Other" { print(myDivName)}
                                                let team = Teams(compName: myCompName, compID: myCompID, divName: myDivName, divID: myDivID, divType: myDivType, divLevel: myDivLevel, teamName: myTeamName, teamID: myTeamID, clubName: myClubName, isCurrent: false, isUsed: false)
                                                context.insert(team)
                                            }
                                        }
                                    }
                                }
                            } catch {
                                print("Invalid Data")
                            }
                        }
                    }
                }
            }
            stillLoading = false
        } catch {
            print("Invalid data")
        }
    }
    
    func loadData() async {
        var myCompName = ""
        guard let url = URL(string: "https://www.hockeyvictoria.org.au/games/")
        else {
            print("Invalid URL")
            return
        }
        do {
            let html = try String.init(contentsOf: url)
            let line = html.split(whereSeparator: \.isNewline)
            for i in 0 ..< line.count {
                if line[i].contains("https://www.hockeyvictoria.org.au/reports/games/download/") {
                    myCompName = GetPart(fullString: String(line[i-1]), partNumber: 3)
                    comps.append(myCompName)
                    if myCompName.contains("Senior Competition") { selectedComps.insert(myCompName)}
                    if myCompName.contains("Midweek Competition") { selectedComps.insert(myCompName)}
                    if myCompName.contains("Junior Competition") { selectedComps.insert(myCompName)}
                }
            }
            
        } catch {
            print("Invalid data")
        }
    }
}

#Preview {
    SelectCompView(stillLoading: .constant(false))
}
