//
//  DetailGroundView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 7/11/2023.
//

import SwiftUI

struct DetailGroundView: View {
    var myRound: Round
    var body: some View {
        
        Section(header: Text("Ground Details")) {
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "sportscourt.fill")
                        .resizable()
                        .frame(width: 40, height: 30)
                    Text(" \(myRound.field)")
                        .font(.largeTitle)
                    Spacer()
                }
                VStack {
                    Text(myRound.venue)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Button {
                    openGoogleMaps(with: "\(myRound.venue), \(myRound.address) , Victoria, Australia", label: "\(myRound.venue)")
                } label: {
                    HStack {
                        Text("Open in Google Maps")
                            .foregroundColor(Color("AccentColor"))
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 17, weight: .semibold))
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("AccentColor"))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
    
    func openGoogleMaps(with address: String, label: String) {
        if let url = URL(string: "comgooglemaps://?q=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&label=\(label.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let safariURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")
                UIApplication.shared.open(safariURL!, options: [:], completionHandler: nil)
            }
        }
    }
}

#Preview {
    DetailGroundView(myRound: Round(id: UUID(), roundNo: "1", fullRound: "Round 1", dateTime: "Sat 15 Apr 2023 @ 14:00", field: "HHF", venue: "Hedley Hull Field", address: "1 Winbirra Parade, Ashwood VIC 3147", opponent: "Hawthorn", homeTeam: "Hawthorn", awayTeam: "MHSOB", homeGoals: 6, awayGoals: 7, score: "6 - 7", starts: "", result: "Win", played: "Completed", game: "1439971"))
}
