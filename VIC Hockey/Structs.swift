//
//  Structs.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 20/10/2023.
//

import Foundation

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

struct Rounds: Codable {
    var rounds: [Round]
}

struct Round: Codable {
    var id: Int
    var roundNo: String
    var dateTime: String
    var venue: String
    var opponent: String
    var score: String
    var starts: String
    var result: String
    var played: String
}
