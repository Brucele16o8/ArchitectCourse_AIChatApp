//
//  Date+EXT.swift
//  AIChatCourse
//
//  Created by Tung Le on 13/10/2025.
//

import Foundation

extension Date {
    func addingTimeInterval(days: Int = 0, hours: Int = 0, minutes: Int = 0) -> Date {
        let totalSeconds = TimeInterval(days * 86_400 + hours * 3_600 + minutes * 60)
        return addingTimeInterval(totalSeconds)
    }
}
