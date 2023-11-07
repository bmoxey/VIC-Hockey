//
//  Structs.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 20/10/2023.
//

import Foundation
import SwiftUI
import Combine

class SharedData: ObservableObject {
    @Published var activeTabIndex: Int = 0
    @Published var lastSchedule: String = ""
    @Published var updateSchedule: Bool = true
    @Published var updateLadder: Bool = true
}

struct DivisionStruct : Identifiable {
    var id = UUID()
    var compName: String
    var compID: String
    var divisionName: String
    var divisionID: String
}

struct Team : Identifiable {
    var id = UUID()
    var compName: String
    var compID: String
    var divName: String
    var divID: String
    var teamName: String
    var teamID: String
    var clubName: String
}

struct Player : Identifiable {
    var id = UUID()
    var name: String
    var goals: String
    var greenCards: Int
    var yellowCards: Int
    var redCards: Int
    var goalie: Int
    var surname: String
    var captain: Bool
}

struct Rounds: Codable {
    var rounds: [Round]
}

struct Round: Codable {
    var id: UUID
    var roundNo: String
    var fullRound: String
    var dateTime: String
    var venue: String
    var opponent: String
    var homeTeam: String
    var homeGoals: Int
    var awayGoals: Int
    var score: String
    var starts: String
    var result: String
    var played: String
    var game: String
    
//    init(id: UUID, roundNo: String, fullRound: String, dateTime: String, venue: String, opponent: String, homeTeam: String, homeGoals: Int, awayGoals: Int, score: String, starts: String, result: String, played: String, game: String) {
//        self.id = UUID()
//        self.roundNo = ""
//        self.fullRound = ""
//        self.dateTime = ""
//        self.venue = ""
//        self.opponent = ""
//        self.homeTeam = ""
//        self.homeGoals = 0
//        self.awayGoals = 0
//        self.score = ""
//        self.starts = ""
//        self.result = ""
//        self.played = ""
//        self.game = ""
//    }
    
    
}
