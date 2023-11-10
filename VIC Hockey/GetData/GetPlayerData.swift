//
//  GetPlayerData.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 10/11/2023.
//

import Foundation

func GetPlayerData(allTeams: [Teams], ourTeam: String, ourTeamID: String, myURL: String) -> ( [PlayerStat], String) {
    var lines: [String] = []
    var errURL = ""
    var attended = false
    var started = false
    var playersStats: [PlayerStat] = []
    (lines, errURL) = GetUrl(url: myURL)
    for i in 0 ..< lines.count {
        if lines[i].contains("Match history") { started = true }
        if lines[i].contains("Did not attend") { attended = false }
        if lines[i].contains("Attended") { attended = true }
        if lines[i].contains("https://www.hockeyvictoria.org.au/teams") {
            if started && attended {
                let myRound = GetPart(fullString: String(lines[i-1]), partNumber: 7)
                let myDateTime = GetPart(fullString: String(lines[i-1]), partNumber: 12)
                let myTeamID = GetPart(fullString: String(lines[i]), partNumber: 7)
                let filteredTeams = allTeams.filter { $0.teamID == myTeamID }
                let myGoals = Int(GetPart(fullString: String(lines[i+2]), partNumber: 3)) ?? 0
                let myGreenCards = Int(GetPart(fullString: String(lines[i+4]), partNumber: 3)) ?? 0
                let myYellowCards = Int(GetPart(fullString: String(lines[i+6]), partNumber: 3)) ?? 0
                let myRedCards = Int(GetPart(fullString: String(lines[i+8]), partNumber: 3)) ?? 0
                let myGoalie = Int(GetPart(fullString: String(lines[i+10]), partNumber: 3)) ?? 0
                playersStats.append(PlayerStat(roundNo: myRound, dateTime: myDateTime, teamID: myTeamID, teamName: filteredTeams[0].teamName, clubName: filteredTeams[0].clubName, divName: filteredTeams[0].divName, goals: myGoals, greenCards: myGreenCards, yellowCards: myYellowCards, redCards: myRedCards, goalie: myGoalie))
            }
        }
    }
    return (playersStats, errURL)
}
