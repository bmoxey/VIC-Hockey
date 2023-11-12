//
//  GetPlayerData.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 10/11/2023.
//

import Foundation

func GetPlayerData(allTeams: [Teams], ourCompID: String, ourTeam: String, ourTeamID: String, myURL: String) -> ( [PlayerStat], String) {
    var lines: [String] = []
    var newlines: [String] = []
    var errURL = ""
    var playersStats: [PlayerStat] = []
    (lines, errURL) = GetUrl(url: myURL.replacingOccurrences(of: "&amp;", with: "&"))
    for i in 0 ..< lines.count {
        if lines[i].contains("https://www.hockeyvictoria.org.au/statistics/") {
            let opts = String(lines[i+3]).split(separator: "option")
            for j in 0 ..< opts.count{
                if String(opts[j]).contains("value=") {
                    let testCompID = GetPart(fullString: String(opts[j]), partNumber: 1)
                    if testCompID != ourCompID {
                        (newlines, errURL) = GetUrl(url: myURL.replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: ourCompID, with: testCompID))
                        lines = lines + newlines
                    }
                }
            }
        }
    }
    for i in 0 ..< lines.count {
        if lines[i].contains("https://www.hockeyvictoria.org.au/teams") {
            if lines[i-2].contains("Attended") {
                let myRound = GetPart(fullString: String(lines[i-1]), partNumber: 7)
                let myDateTime = GetPart(fullString: String(lines[i-1]), partNumber: 12)
                let myTeamID = GetPart(fullString: String(lines[i]), partNumber: 7)
                let filteredTeams = allTeams.filter { $0.teamID == myTeamID }
                let myGoals = Int(GetPart(fullString: String(lines[i+2]), partNumber: 3)) ?? 0
                let myGreenCards = Int(GetPart(fullString: String(lines[i+4]), partNumber: 3)) ?? 0
                let myYellowCards = Int(GetPart(fullString: String(lines[i+6]), partNumber: 3)) ?? 0
                let myRedCards = Int(GetPart(fullString: String(lines[i+8]), partNumber: 3)) ?? 0
                let myGoalie = Int(GetPart(fullString: String(lines[i+10]), partNumber: 3)) ?? 0
                if !filteredTeams.isEmpty {
                    playersStats.append(PlayerStat(roundNo: myRound, dateTime: myDateTime, teamID: myTeamID, teamName: filteredTeams[0].teamName, clubName: filteredTeams[0].clubName, divName: filteredTeams[0].divName, goals: myGoals, greenCards: myGreenCards, yellowCards: myYellowCards, redCards: myRedCards, goalie: myGoalie))
                }
            }
        }
    }
    return (playersStats, errURL)
}
