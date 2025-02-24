import SwiftUI

class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    
    @Published var completionData: [Date: [FocusData]] = [:]
    
    private init() {
        loadAllData()
    }
    
    func recordCompletion(focusTime: Int, tag: String, startDate: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
        guard let normalizedDate = calendar.date(from: components) else { return }
        
        let focusData = FocusData(tag: tag, duration: focusTime)
        
        if completionData[normalizedDate] != nil {
            completionData[normalizedDate]?.append(focusData)
        } else {
            completionData[normalizedDate] = [focusData]
        }
        
        let dataList = completionData[normalizedDate]?.map { [$0.tag, $0.duration] } ?? []
        UserDefaults.standard.set(dataList, forKey: dateKey(for: normalizedDate))
        objectWillChange.send()
    }
    
    private func loadAllData() {
        UserDefaults.standard.dictionaryRepresentation().forEach { key, value in
            if let date = date(from: key), let dataList = value as? [[Any]] {
                let focusDataList = dataList.compactMap { data -> FocusData? in
                    guard let tag = data.first as? String, let duration = data.last as? Int else { return nil }
                    return FocusData(tag: tag, duration: duration)
                }
                completionData[date] = focusDataList
            }
        }
    }
    
    func getCompletionData(forHour hour: Int, onDate date: Date) -> [FocusData]? {
        let calendar = Calendar.current
        let startOfHour = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date)!
        let endOfHour = calendar.date(bySettingHour: hour, minute: 59, second: 59, of: date)!
        
        return completionData.filter { key, _ in
            return key >= startOfHour && key <= endOfHour
        }.flatMap { $0.value }
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime]
        return formatter.string(from: date)
    }
    
    private func date(from key: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime]
        return formatter.date(from: key)
    }
}
