//
//  Date+Util.swift
//  SocialLite
//
//  Created by Tei on 17/3/21.
//

import Foundation

extension Date {
    
    // Helper function to format timeInterval for displaying
    static func stringFromTimeInterval(_ time: TimeInterval) -> String {
        let calendar = Calendar.current
        let date = Date(timeIntervalSinceReferenceDate: time)
        let formatter = DateFormatter()
        if calendar.isDateInToday(date) {
            // 17:00
            formatter.dateFormat = "HH:mm"
        } else {
            // 17 Mar 2021
            formatter.dateFormat = "d MMM y"
        }
        return formatter.string(from: date)
    }
}
