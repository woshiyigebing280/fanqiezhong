import SwiftUI

struct CalendarView: View {
    @StateObject private var calendarManager = CalendarManager.shared
    @State private var selectedDate = Date()
    @Environment(\.colorScheme) var colorScheme

    @State private var showDetails: Bool = false
    @State private var selectedFocusData: FocusData? = nil

    private var baseColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private func hourView(for hour: Int) -> some View {
        VStack {
            HStack(alignment: .center) {
                Text(String(format: "%02d:00", hour))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                    .frame(width: 60, alignment: .leading) // 靠左居中对齐并设置固定宽度
                
                if let focusDataList = calendarManager.getCompletionData(forHour: hour, onDate: selectedDate) {
                    ForEach(focusDataList, id: \.self) { focusData in
                        Image(systemName: "timer")
                            .foregroundColor(.red) // 番茄图标
                            .frame(width: 30, height: 30, alignment: .leading) // 靠左居中对齐并设置固定宽度和高度
                            .onTapGesture {
                                showFocusData(focusData)
                            }
                    }
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 30)
                }
            }
            .padding(.horizontal)
            
            Divider()
                .background(Color.gray)
                .padding(.horizontal)
        }
    }

    private func showFocusData(_ focusData: FocusData) {
        selectedFocusData = focusData
        showDetails = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showDetails = false
            selectedFocusData = nil
        }
    }

    private func changeDate(byAdding days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }

    var body: some View {
        ZStack {
            baseColor
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) { // 间距调大到现在的两倍
                HStack {
                    Button(action: {
                        changeDate(byAdding: -1)
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(textColor)
                    }
                    
                    Text(selectedDate, style: .date)
                        .font(.largeTitle)
                        .foregroundColor(textColor)
                    
                    Button(action: {
                        changeDate(byAdding: 1)
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(textColor)
                    }
                }
                
                ScrollView {
                    VStack(spacing: 40) { // 间距调大到现在的两倍
                        ForEach(0..<24) { hour in
                            hourView(for: hour)
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .environment(\.locale, Locale(identifier: "zh_CN"))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("每日时间轴")
                        .font(.headline)
                        .foregroundColor(textColor)
                }
            }
            .navigationBarTitleDisplayMode(.inline)

            if showDetails, let focusData = selectedFocusData {
                VStack {
                    Text("当前标签: \(focusData.tag)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    Text("专注 \(focusData.duration) 分钟")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
            }
        }
        .accentColor(textColor)
    }
}
