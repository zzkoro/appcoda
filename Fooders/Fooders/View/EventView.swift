//
//  EventView.swift
//  Fooders
//
//  Created by junemp on 2022/01/30.
//

import SwiftUI

let events = ["Wake up", "Breakfast", "Go to work", "Lunch", "Come home", "Go to sleep"]
let eventTimes = ["7:00 AM", "8:00 AM", "8:30 AM", "12:00 PM", "5:00 PM", "11:00 PM"]

struct EventView: View {
    
    enum ViewLink: String, Identifiable {
        var id: UUID {
            UUID()
        }
        case redactedTest
    }
    
    @State private var linkId: ViewLink?
    
    var body: some View {
        VStack {
            Text("Daily Events")
                .bold()
                .italic()
                .padding()
            Form {
                ForEach(0..<events.count) { index in
                    Text("- \(events[index]) [ \(eventTimes[index]) ]")
                }
            }
            Label("redacted modifier 이용하기", image: "instagram")
                .onTapGesture {
                    linkId = ViewLink.redactedTest
                }

            
        }
        .sheet(item: $linkId) { item in
            if item == ViewLink.redactedTest {
                RedactedTestView()
            }
            Button(action: {
                linkId = nil
                
            }) {
                Text("닫기")
            }
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView()
    }
}
