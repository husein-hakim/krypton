//
//  StatisticsViewModel.swift
//  Focus
//
//  Created by Husein Hakim on 16/01/25.
//

import Foundation

func prepareGraphData(sessions: [FocusSessionManager]) -> [GraphData] {
    let filteredSession = filterSessionsForCurrentWeek(sessions: sessions)
    let sessionDurations = mapSessionsToWeekdays(sessions: filteredSession)
    let weekdays = generateWeekdays()
    
    return weekdays.map { day in
        GraphData(day: day, duration: sessionDurations[day]!)
    }
}

func prepareBreakGraphData(breaks: [FocusSessionManager]) -> [BreakGraphData] {
    let filteredBreaks = filterSessionsForCurrentWeek(sessions: breaks)
    let breakDurations = mapBreaksToWeekdays(breaks: filteredBreaks)
    let weekdays = generateWeekdays()
    
    return weekdays.map { day in
        let data = breakDurations[day]!
        return BreakGraphData(day: day, duration: data.duration / 60, count: data.count)
    }
}

func currentWeekRange() -> (startOfWeek: Date, endOfWeek: Date) {
    let calendar = Calendar.current
    let today = Date()
    
    // Get the start of the week
    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
    
    // Get the end of the week by adding 6 days
    let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
    
    return (startOfWeek, endOfWeek)
}

func filterSessionsForCurrentWeek(sessions: [FocusSessionManager]) -> [FocusSessionManager] {
    let weekRange = currentWeekRange()
    
    return sessions.filter { session in
        session.timestamp >= weekRange.startOfWeek && session.timestamp <= weekRange.endOfWeek
    }
}

func mapSessionsToWeekdays(sessions: [FocusSessionManager]) -> [String: Int] {
    let weekdays = generateWeekdays()
    var sessionDurations = [String: Int]()
    
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    
    for day in weekdays {
        sessionDurations[day] = 0 // Initialize all days with 0 duration
    }
    
    for session in sessions {
        let dayName = formatter.string(from: session.timestamp)
        sessionDurations[dayName, default: 0] += session.duration // Add session duration
    }
    
    return sessionDurations
}

func generateWeekdays() -> [String] {
    let calendar = Calendar.current
    let today = Date()
    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
    
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE" // Full day name (e.g., "Monday")
    
    return (0...6).map { offset in
        let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
        return formatter.string(from: date)
    }
}

func prepareMonthlyGraphData(sessions: [FocusSessionManager]) -> [(day: String, duration: Int)] {
    let filteredSessions = filterSessionsForCurrentMonth(sessions: sessions)
    let sessionDurations = mapSessionsToMonthDays(sessions: filteredSessions)
    let monthDays = generateMonthDays()
    
    return monthDays.map { day in
        (day: day, duration: sessionDurations[day]!)
    }
}

func currentMonthRange() -> (startOfMonth: Date, endOfMonth: Date) {
    let calendar = Calendar.current
    let today = Date()
    
    // Get the start of the month
    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
    
    // Get the end of the month by adding the number of days in the current month
    let range = calendar.range(of: .day, in: .month, for: today)!
    let endOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth)!
    
    return (startOfMonth, endOfMonth)
}

func filterSessionsForCurrentMonth(sessions: [FocusSessionManager]) -> [FocusSessionManager] {
    let monthRange = currentMonthRange()
    
    return sessions.filter { session in
        session.timestamp >= monthRange.startOfMonth && session.timestamp <= monthRange.endOfMonth
    }
}

func mapSessionsToMonthDays(sessions: [FocusSessionManager]) -> [String: Int] {
    let monthDays = generateMonthDays()
    var sessionDurations = [String: Int]()
    
    let formatter = DateFormatter()
    formatter.dateFormat = "d" // Day of the month as a number (e.g., "1", "2", "3")
    
    for day in monthDays {
        sessionDurations[day] = 0 // Initialize all days with 0 duration
    }
    
    for session in sessions {
        let dayName = formatter.string(from: session.timestamp)
        sessionDurations[dayName, default: 0] += session.duration // Add session duration
    }
    
    return sessionDurations
}

func generateMonthDays() -> [String] {
    let calendar = Calendar.current
    let today = Date()
    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
    
    let range = calendar.range(of: .day, in: .month, for: today)!
    
    return range.map { day in
        String(day) // Return each day as a string (e.g., "1", "2", "3")
    }
}

func mapBreaksToWeekdays(breaks: [FocusSessionManager]) -> [String: (duration: Int, count: Int)] {
    let weekdays = generateWeekdays()
    var breakDurations = [String: (duration: Int, count: Int)]()
    
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE" // Short weekday name
    
    for day in weekdays {
        breakDurations[day] = (duration: 0, count: 0) // Initialize all days with 0 duration and count
    }
    
    for breakSession in breaks {
        let dayName = formatter.string(from: breakSession.timestamp)
        if var current = breakDurations[dayName] {
            current.duration += breakSession.breaks_duration
            current.count += breakSession.breaks_taken
            breakDurations[dayName] = current
        }
    }
    
    return breakDurations
}

