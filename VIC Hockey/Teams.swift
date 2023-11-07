//
//  Teams.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 20/10/2023.
//

import Foundation
import SwiftData

@Model
class Teams : ObservableObject {
    var compName: String
    var compID: String
    var divName: String
    var divID: String
    var divType: String
    var divLevel: String
    var teamName: String
    var teamID: String
    var clubName: String
    var isCurrent: Bool
    var isUsed: Bool
    
    init(compName: String, compID: String, divName: String, divID: String, divType: String, divLevel: String, teamName: String, teamID: String, clubName: String, isCurrent: Bool, isUsed: Bool) {
        self.compName = compName
        self.compID = compID
        self.divName = divName
        self.divID = divID
        self.divType = divType
        self.divLevel = divLevel
        self.teamName = teamName
        self.teamID = teamID
        self.clubName = clubName
        self.isCurrent = isCurrent
        self.isUsed = isUsed
    }
}


