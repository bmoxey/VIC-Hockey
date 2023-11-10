//
//  GetGameData.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 9/11/2023.
//

import Foundation

func GetGameData(gameNumber: String, myTeam: String) -> (Round, [Player], [Player], [Round], String) {
    var lines: [String] = []
    var myTeamName: String = ""
    var myRound: Round = Round(id: UUID(), roundNo: "", fullRound: "", dateTime: "", field: "", venue: "", address: "", opponent: "", homeTeam: "", awayTeam: "", homeGoals: 0, awayGoals: 0, score: "", starts: "", result: "", played: "", game: "")
    var myGame: Round = Round(id: UUID(), roundNo: "", fullRound: "", dateTime: "", field: "", venue: "", address: "", opponent: "", homeTeam: "", awayTeam: "", homeGoals: 0, awayGoals: 0, score: "", starts: "", result: "", played: "", game: "")
    var homePlayers: [Player] = []
    var awayPlayers: [Player] = []
    var otherGames: [Round] = []
    var errURL = ""
    (lines, errURL) = GetUrl(url: "https://www.hockeyvictoria.org.au/game/" + gameNumber + "/")
    var count = 0
    for i in 0 ..< lines.count {
        if lines[i].contains("Match not found.") {
            errURL = "Match not found."
        }
        if lines[i].contains("<h1 class=\"h3 mb-0\">") {
            if lines[i+1].contains("&middot;") {
                let mybit = String(lines[i+1]).split(separator: ";")
                myRound.fullRound = String(mybit[mybit.count-1]).trimmingCharacters(in: .whitespaces)
                if myRound.fullRound.count < 5 {
                    myRound.fullRound = String(mybit[mybit.count-2]).trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " &middot", with: "")
                }
                myRound.roundNo = GetRound(fullString: myRound.fullRound)
            }
        }
        if lines[i].contains("www.hockeyvictoria.org.au/teams/") {
            if lines[i].contains("<span class=\"badge badge-danger\">FF</span>") || lines[i].contains("<span class=\"badge badge-warning\">FL</span>") {
                let team = ShortTeamName(fullName: GetPart(fullString: String(lines[i]), partNumber: 13))
                let msg = GetPart(fullString: String(lines[i]), partNumber: 17)
                let msg2 = GetPart(fullString: String(lines[i]), partNumber: 19)
                myRound.result = team + " " + msg + " " + msg2
            }
            count += 1
            
            if count == 1 {
                myRound.homeTeam = ShortTeamName(fullName:GetPart(fullString: String(lines[i]), partNumber: 9))
                myRound.awayTeam = ShortTeamName(fullName:GetPart(fullString: String(lines[i]), partNumber: 19))
            }
            if count == 2 {
                let mybit = lines[i].split(whereSeparator: \.isSymbol)
                for j in 0 ..< mybit.count {
                    if String(mybit[j]).contains(" - ") {
                        let mybit1 = String(mybit[j]).split(separator: "-")
                        myRound.homeGoals = Int(String(mybit1[0]).trimmingCharacters(in: .whitespaces)) ?? 0
                        myRound.awayGoals = Int(String(mybit1[1]).trimmingCharacters(in: .whitespaces)) ?? 0
                    }
                }
                myRound.result = GetResult(myTeam: myTeam, homeTeam: myRound.homeTeam, awayTeam: myRound.awayTeam, homeGoals: myRound.homeGoals, awayGoals: myRound.awayGoals)
            }
            if count > 2 {
                let mybit = lines[i].split(separator: ":")
                myGame.homeTeam = ShortTeamName(fullName:GetPart(fullString: String(mybit[1]), partNumber: 4))
                myGame.awayTeam = ShortTeamName(fullName:GetPart(fullString: String(mybit[2]), partNumber: 4))
                if myGame.starts == "" {
                    let score = GetPart(fullString: String(lines[i]), partNumber: 10)
                    if score == "/div" {
                        myGame.homeGoals = 0
                        myGame.awayGoals = 0
                        myGame.result = "No data"
                        myGame.score = ""
                    } else {
                        let numbers = score.components(separatedBy: CharacterSet(charactersIn: " vs ")).compactMap { Int($0.trimmingCharacters(in: .whitespaces))}
                        myGame.homeGoals = numbers.first ?? 0
                        myGame.awayGoals = numbers.last ?? 0
                        myGame.result = GetResult(myTeam: myTeam, homeTeam: myGame.homeTeam, awayTeam: myGame.awayTeam, homeGoals: myGame.homeGoals, awayGoals: myGame.awayGoals)
                        myGame.score = "\(myGame.homeGoals) - \(myGame.awayGoals)"
                    }
                }
                if myGame.homeTeam == myTeam { myGame.opponent = myGame.awayTeam }
                else {myGame.opponent = myGame.homeTeam}
            }
        }
        if lines[i].contains("Results for this match are not currently available") {
            count += 1
            myRound.result = "No data"
        }
        if lines[i].contains("Teams drew!") {
            let mybit1 = GetPart(fullString: String(lines[i]), partNumber: 7).split(separator: "-")
            myRound.homeGoals = Int(String(mybit1[0]).trimmingCharacters(in: .whitespaces)) ?? 0
            myRound.awayGoals = Int(String(mybit1[1]).trimmingCharacters(in: .whitespaces)) ?? 0
            myRound.result = "Draw"
            count += 1
        }
        if lines[i].contains(">Date &amp; time<") {
            myRound.dateTime = ChangeLastSpace(in: String(lines[i+1].trimmingCharacters(in: .whitespaces)))
            myRound.starts = GetStart(inputDate: myRound.dateTime)
            if myRound.starts == "" && myRound.result == "No data" { myRound.starts = "Results currently unavailable"}
            if myRound.starts == "" { myRound.played = "Completed" } else { myRound.played = "Upcoming" }
            if myRound.starts == "" && myRound.result.count > 10 {
                myRound.starts = myRound.result
            }
        }
        if lines[i].contains(">Venue<") {
            myRound.venue = GetPart(fullString: String(lines[i+1]), partNumber: 0).trimmingCharacters(in: .whitespaces)
            myRound.address = GetPart(fullString: String(lines[i+1]), partNumber: 3).trimmingCharacters(in: .whitespaces)
        }
        if lines[i].contains(">Field<") {
            myRound.field = String(lines[i+1]).trimmingCharacters(in: .whitespaces)
        }
        if lines[i].contains("<div class=\"table-responsive\">") {
            myTeamName = ShortTeamName(fullName: GetPart(fullString: String(lines[i-3]), partNumber: 3))
        }
        if lines[i].contains("https://www.hockeyvictoria.org.au/statistics/") {
            if String(GetPart(fullString: String(lines[i]), partNumber: 11)) == "Attended" {
                var myName = GetPart(fullString: String(lines[i]), partNumber: 18).capitalized
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
                let myGoals = Int(GetPart(fullString: String(lines[i+2]), partNumber: 3)) ?? 0
                let myGreen = Int(GetPart(fullString: String(lines[i+4]), partNumber: 3)) ?? 0
                let myYellow = Int(GetPart(fullString: String(lines[i+6]), partNumber: 3)) ?? 0
                let myRed = Int(GetPart(fullString: String(lines[i+8]), partNumber: 3)) ?? 0
                let myGoalie = Int(GetPart(fullString: String(lines[i+10]), partNumber: 3)) ?? 0
                var us = true
                if myTeamName != myTeam { us = false }
                let games = 0
                if myRound.homeTeam == myTeamName {
                    homePlayers.append(Player(name: myName, numberGames: games, goals: myGoals, greenCards: myGreen, yellowCards: myYellow, redCards: myRed, goalie: myGoalie, surname: surname, captain: myCap, us: us, statsLink: ""))
                } else {
                    awayPlayers.append(Player(name: myName, numberGames: games, goals: myGoals, greenCards: myGreen, yellowCards: myYellow, redCards: myRed, goalie: myGoalie, surname: surname, captain: myCap, us: us, statsLink: ""))
                }
            }
        }
        if lines[i].contains("https://www.hockeyvictoria.org.au/venues") {
            myGame.fullRound = GetPart(fullString: lines[i-7], partNumber: 2)
            myGame.dateTime = GetPart(fullString: lines[i-6], partNumber: 2) + " @ " +  String(lines[i-5]).trimmingCharacters(in: .whitespaces)
            myGame.starts = GetStart(inputDate: myGame.dateTime)
            myGame.venue = GetPart(fullString: lines[i], partNumber: 5)
            myGame.field = GetPart(fullString: lines[i+1], partNumber: 2)
        }
        if lines[i].contains("https://www.hockeyvictoria.org.au/game/") {
            myGame.id = UUID()
            otherGames.append(myGame)
        }
    }
    return (myRound, homePlayers, awayPlayers, otherGames, errURL)
}
