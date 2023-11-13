//
//  GetRoundData.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 11/11/2023.
//

import Foundation

func GetRoundData(mycompID: String, myDivID: String, myTeamName: String, currentRound: String) -> (String, String, String, [Round], [String], String) {
    var myRound = Round(id: UUID(), fullRound: "", dateTime: "", field: "", venue: "", address: "", opponent: "", homeTeam: "", awayTeam: "", homeGoals: 0, awayGoals: 0, score: "", starts: "", result: "No Data", played: "", game: "")
    var rounds = [Round]()
    var lines: [String] = []
    var byeTeams: [String] = []
    var errURL = ""
    var prev = ""
    var next = ""
    var myURL = ""
    var byes = false
    var started: Bool = false
    myRound.fullRound = currentRound
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
            if lines[i].contains("BYEs") { byes = true }
            if lines[i].contains("https://www.hockeyvictoria.org.au/venues/") {
                myRound.dateTime = String(lines[i-5].replacingOccurrences(of: "<br />", with: " @ ").trimmingCharacters(in: .whitespaces))
                (myRound.starts, myRound.played) = GetStart(inputDate: myRound.dateTime)
                myRound.venue = GetPart(fullString: lines[i], partNumber: 5)
                myRound.field = GetPart(fullString: lines[i+1], partNumber: 2)
            }
            if lines[i].contains("https://www.hockeyvictoria.org.au/teams/") {
                if byes {
                    byeTeams.append(ShortTeamName(fullName: GetPart(fullString: String(lines[i]), partNumber: 6)))
                } else {
                    let myBits = lines[i].split(separator: ":")
                    myRound.homeTeam = ShortTeamName(fullName: GetPart(fullString: String(myBits[1]), partNumber: 4))
                    myRound.awayTeam = ShortTeamName(fullName: GetPart(fullString: String(myBits[2]), partNumber: 4))
                    if myBits[1].contains("badge badge-warning align-middle\">FL<") {
                        if String(myBits[1]).contains("font-size-xs\"></div") {
                            myRound.starts = myRound.homeTeam + " lost by default: "
                        } else {
                            myRound.starts = myRound.homeTeam + " lost by default: " + GetPart(fullString: String(myBits[1]), partNumber: 13)
                        }
                    }
                    if myBits[2].contains("badge badge-warning align-middle\">FL<") {
                        if String(myBits[2]).contains("font-size-xs\"></div") {
                            myRound.starts = myRound.awayTeam + " lost by default: "
                        } else {
                            myRound.starts = myRound.awayTeam + " lost by default: " + GetPart(fullString: String(myBits[2]), partNumber: 13)
                        }
                    }
                    if myBits[1].contains("badge badge-danger align-middle\">FF<") {
                        if String(myBits[1]).contains("font-size-xs\"></div") {
                            myRound.starts = myRound.homeTeam + " forefeited: "
                        } else {
                            myRound.starts = myRound.homeTeam + " forefeited: " + GetPart(fullString: String(myBits[1]), partNumber: 13)
                        }
                    }
                    if myBits[2].contains("badge badge-danger align-middle\">FF<") {
                        if String(myBits[2]).contains("font-size-xs\"></div") {
                            myRound.starts = myRound.awayTeam + " forefeited: "
                        } else {
                            myRound.starts = myRound.awayTeam + " forefeited: " + GetPart(fullString: String(myBits[2]), partNumber: 13)
                        }
                    }
                    let myBits1 = lines[i].split(separator: ">")
                    for j in 0 ..< myBits1.count {
                        if String(myBits1[j]).contains("vs</div") || String(myBits1[j]).contains("vs ") {
                            myRound.score = String(myBits1[j].split(separator: "<")[0])
                        }
                    }
                    if myRound.score == "vs" {
                        if myRound.starts == "" { myRound.starts = "No results available."}
                        myRound.result = "No Data"
                    } else {
                        (myRound.homeGoals, myRound.awayGoals) = GetScores(scores: myRound.score, seperator: "vs")
                        myRound.result = GetResult(myTeam: myTeamName, homeTeam: myRound.homeTeam, awayTeam: myRound.awayTeam, homeGoals: myRound.homeGoals, awayGoals: myRound.awayGoals)
                    }
                }
            }
            if lines[i].contains("https://www.hockeyvictoria.org.au/game/") {
                myRound.game = String(GetPart(fullString: String(lines[i]), partNumber: 4).split(separator: "/")[3])
                myRound.id = UUID()
                rounds.append(myRound)
            }
        }
    }
    return (prev, currentRound, next, rounds, byeTeams, errURL)
}
