//
//  GetStatsData.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 9/11/2023.
//

import Foundation

func GetStatsData(myCompID: String, myTeamID: String) -> ( [Player], String) {
    var lines: [String] = []
    var errURL = ""
    var players: [Player] = []
    (lines, errURL) = GetUrl(url: "https://www.hockeyvictoria.org.au/teams-stats/" + myCompID + "/&t=" + myTeamID)
    for i in 0 ..< lines.count {
        if lines[i].contains("There are no records to show.") {
            errURL = "There are no records to show."
        }
        
        
        if lines[i].contains("https://www.hockeyvictoria.org.au/statistics/") {
            var myName = GetPart(fullString: String(lines[i]), partNumber: 7).capitalized.trimmingCharacters(in: CharacterSet.letters.inverted)
            var myCap = false
            if myName.contains(" (Captain)") {
                myCap = true
                myName = myName.replacingOccurrences(of: " (Captain)", with: "")
            }
            let mybits = myName.split(separator: ",")
            var surname = ""
            if mybits.count > 0 {
                surname = mybits[0].trimmingCharacters(in: .whitespaces).capitalized
                if surname.contains("'") {
                    let mybits1 = surname.split(separator: "'")
                    surname = mybits1[0].capitalized + "'" + mybits1[1].capitalized
                }
                myName = mybits[1].trimmingCharacters(in: .whitespaces).capitalized + " " + surname
            }
            let myGames = Int(GetPart(fullString: String(lines[i+1]), partNumber: 3)) ?? 0
            let myGoals = Int(GetPart(fullString: String(lines[i+3]), partNumber: 3)) ?? 0
            let myGreen = Int(GetPart(fullString: String(lines[i+5]), partNumber: 3)) ?? 0
            let myYellow = Int(GetPart(fullString: String(lines[i+7]), partNumber: 3)) ?? 0
            let myRed = Int(GetPart(fullString: String(lines[i+9]), partNumber: 3)) ?? 0
            let myGoalie = Int(GetPart(fullString: String(lines[i+11]), partNumber: 3)) ?? 0
            players.append(Player(name: myName, numberGames: myGames, goals: myGoals, greenCards: myGreen, yellowCards: myYellow, redCards: myRed, goalie: myGoalie, surname: surname, captain: myCap, us: true))
        }
    }
    
    return(players, errURL)
}

