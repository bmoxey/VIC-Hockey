//
//  GetRoundData.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 11/11/2023.
//

import Foundation

func GetRoundData(mycompID: String, myDivID: String, myTeamName: String, currentRound: String) -> (String, String, String, [Round], String) {
    var myRound = Round(id: UUID(), roundNo: "", fullRound: "", dateTime: "", field: "", venue: "", address: "", opponent: "", homeTeam: "", awayTeam: "", homeGoals: 0, awayGoals: 0, score: "", starts: "", result: "No Data", played: "", game: "")
    var rounds = [Round]()
    var lines: [String] = []
    var errURL = ""
    var prev = ""
    var next = ""
    var myURL = ""
    var started: Bool = false
    myRound.fullRound = currentRound
    myRound.roundNo = GetRound(fullString: myRound.fullRound)
    (lines, errURL) = GetUrl(url: "https://www.hockeyvictoria.org.au/games/" + mycompID + "/&d=" + myDivID)
    for i in 0 ..< lines.count {
        if lines[i].contains("https://www.hockeyvictoria.org.au/pointscores/") { started = true }
        if lines[i].contains("https://www.hockeyvictoria.org.au/games/") {
            if started {
                let roundName = GetPart(fullString: String(lines[i]), partNumber: 8)
                if roundName == currentRound {
                    if lines[i-6].contains("https://www.hockeyvictoria.org.au/games/") {
                        prev = GetPart(fullString: String(lines[i-6]), partNumber: 8)
                    } else {
                        prev = ""
                    }
                    if lines[i+6].contains("https://www.hockeyvictoria.org.au/games/") {
                        next = GetPart(fullString: String(lines[i+6]), partNumber: 8)
                    } else {
                        next = ""
                    }
                    let mybit = String(lines[i]).split(separator: "\"")
                    myURL = String(mybit[1]).replacingOccurrences(of: "&amp;", with: "&")
                    
                }
            }
        }
    }
    if myURL != "" {
        (lines, errURL) = GetUrl(url: myURL)
        for i in 0 ..< lines.count {
            if lines[i].contains("https://www.hockeyvictoria.org.au/venues/") {
                myRound.dateTime = String(lines[i-5].replacingOccurrences(of: "<br />", with: " @ ").trimmingCharacters(in: .whitespaces))
                myRound.starts = GetStart(inputDate: myRound.dateTime)
                if myRound.starts == "" { myRound.played = "Completed" }
                else { myRound.played = "Upcoming" }
                myRound.venue = GetPart(fullString: lines[i], partNumber: 5)
                myRound.field = GetPart(fullString: lines[i+1], partNumber: 2)
            }
            if lines[i].contains("https://www.hockeyvictoria.org.au/teams/") {
                myRound.homeTeam = ShortTeamName(fullName: GetPart(fullString: lines[i], partNumber: 6))
                if lines[i].contains("<div>vs</div>") {
                    myRound.awayTeam = ShortTeamName(fullName: GetPart(fullString: lines[i], partNumber: 16))
                    if myRound.starts == "" { myRound.starts = "No results available."}
                } else {
                    myRound.score = GetPart(fullString: GetScore(fullString: String(lines[i])), partNumber: 10)
                    (myRound.homeGoals, myRound.awayGoals) = GetScores(scores: myRound.score, seperator: "vs")
                    myRound.awayTeam = ShortTeamName(fullName: GetPart(fullString: lines[i], partNumber: 18))
                    myRound.result = GetResult(myTeam: myTeamName, homeTeam: myRound.homeTeam, awayTeam: myRound.awayTeam, homeGoals: myRound.homeGoals, awayGoals: myRound.awayGoals)
                }
            }
            if lines[i].contains("https://www.hockeyvictoria.org.au/game/") {
                myRound.game = String(GetPart(fullString: String(lines[i]), partNumber: 4).split(separator: "/")[3])
                myRound.id = UUID()
                rounds.append(myRound)
            }
        }
    }
    return (prev, currentRound, next, rounds, errURL)
}
