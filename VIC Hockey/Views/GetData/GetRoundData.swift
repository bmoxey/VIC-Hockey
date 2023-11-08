//
//  GetRoundData.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 9/11/2023.
//

import Foundation

func GetRoundData(mycompID: String, myTeamID: String, myTeamName: String) -> ([Round], String) {
    var myRound = Round(id: UUID(), roundNo: "", fullRound: "", dateTime: "", field: "", venue: "", address: "", opponent: "", homeTeam: "", awayTeam: "", homeGoals: 0, awayGoals: 0, score: "", starts: "", result: "No Data", played: "", game: "")
    var rounds = [Round]()
    var lines: [String] = []
    var errURL = ""
    (lines, errURL) = GetUrl(url: "https://www.hockeyvictoria.org.au/teams/" + mycompID + "/&t=" + myTeamID)
    for i in 0 ..< lines.count {
        if lines[i].contains("There are no draws to show") {
            errURL = "There are no draws to show"
        }
        if lines[i].contains("col-md pb-3 pb-lg-0 text-center text-md-left") {
            myRound.fullRound = GetPart(fullString: String(lines[i+1]), partNumber: 2)
            myRound.roundNo = GetRound(fullString: myRound.fullRound)
            myRound.dateTime = String(lines[i+2].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "<br />", with: " @ "))
            myRound.starts = GetStart(inputDate: myRound.dateTime)
            if myRound.starts == "" { myRound.played = "Completed" }
            else { myRound.played = "Upcoming" }
        }
        if lines[i].contains("https://www.hockeyvictoria.org.au/venues") {
            myRound.venue = GetPart(fullString: lines[i], partNumber: 5)
            myRound.field = GetPart(fullString: lines[i+1], partNumber: 2)
            if myRound.field == "/div" {
                myRound.field = "BYE"
                myRound.opponent = "BYE"
                myRound.score = ""
                myRound.result = "BYE"
                myRound.homeGoals = 0
                myRound.awayGoals = 0
            }
        }
        if lines[i].contains("https://www.hockeyvictoria.org.au/teams/") {
            myRound.opponent = ShortTeamName(fullName: GetPart(fullString: String(lines[i]), partNumber: 6))
            myRound.score = GetPart(fullString: GetScore(fullString: String(lines[i])), partNumber: 9)
            if myRound.score == "div" {
                myRound.score = ""
                myRound.result = "No data"
                myRound.homeGoals = 0
                myRound.awayGoals = 0
            } else {
                myRound.result = GetPart(fullString: GetScore(fullString: String(lines[i])), partNumber: 14)
                (myRound.homeGoals, myRound.awayGoals) = GetScores(scores: myRound.score)
                (myRound.homeTeam, myRound.awayTeam) = GetHomeTeam(result: myRound.result, homeGoals: myRound.homeGoals, awayGoals: myRound.awayGoals, myTeam: myTeamName, opponent: myRound.opponent, rounds: rounds, venue: myRound.venue)
//                myRound.result = GetResult(myTeam: myTeamName, homeTeam: myRound.homeTeam, awayTeam: myRound.awayTeam, homeGoals: myRound.homeGoals, awayGoals: myRound.awayGoals)
                if lines[i].contains(" <div class=\"badge badge-danger\">FF</div>") {
                    if myRound.result == "Win" { myRound.result = "+FF" } else { myRound.result = "-FF" } }
                if lines[i].contains(" <div class=\"badge badge-warning\">FL</div>") {
                    if myRound.result == "Win" { myRound.result = "+FL" } else { myRound.result = "-FL"} }
            }
        }
        if lines[i].contains("https://www.hockeyvictoria.org.au/game/") {
            myRound.game = String(GetPart(fullString: String(lines[i]), partNumber: 4).split(separator: "/")[3])
            myRound.id = UUID()
            rounds.append(myRound)
        }
    }
    return (rounds, errURL)
}
