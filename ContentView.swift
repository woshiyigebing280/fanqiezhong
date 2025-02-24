import SwiftUI
import AudioToolbox
import Combine

struct BackgroundOpacityKey: EnvironmentKey {
    static let defaultValue: Double = 0.0
}

extension EnvironmentValues {
    var backgroundOpacity: Double {
        get { self[BackgroundOpacityKey.self] }
        set { self[BackgroundOpacityKey.self] = newValue }
    }
}

struct ContentView: View {
    @StateObject private var timerModel = TimerModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.window) var window: UIWindow?

    @State private var isAnimating = false
    @State private var isFocusActive = false
    @State private var clockOffset: CGFloat = 0
    @State private var elementsOpacity: Double = 1.0
    @State private var backgroundOpacity: Double = 0.0
    @State private var initialClockOffset: CGFloat = 0
    @State private var isResting: Bool = false
    @State private var isButtonsVisible = true

    @State private var showCompletionCard = false
    @State private var cardScale: CGFloat = 1.0
    @State private var cardRotation: Double = 0
    @State private var longPressTimer: Timer?
    @State private var longPressProgress: CGFloat = 0
    @State private var oneCentimeterInPoints: CGFloat = 38
    @State private var cancellables: Set<AnyCancellable> = []

    // 番茄钟循环相关状态
    @State private var isCycleEnabled = false
    @State private var showCycleSettings = false

    // 循环间确认卡片
    @State private var showCycleCompletionCard = false

    // 将 currentCycle 作为 @State 变量
    @State private var currentCycle = 1

    // 标签相关状态
    @State private var showTagView = false
    @StateObject private var tagManager = TagManager.shared

    // 控制显示“结束休息”按钮的状态
    @State private var showEndRestButton = false

    private var baseColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Rectangle()
                    .fill(Color.white.opacity(1 - backgroundOpacity))
                    .edgesIgnoringSafeArea(.all)
                Rectangle()
                    .fill(Color.black.opacity(backgroundOpacity))
                    .edgesIgnoringSafeArea(.all)
                
                // 长按手势
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .allowsHitTesting(isFocusActive && !timerModel.isResting)
                    .onLongPressGesture(minimumDuration: 3, pressing: { pressing in
                        if pressing {
                            // 启动长按计时器
                            longPressTimer?.invalidate()
                            longPressProgress = 0
                            longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                                longPressProgress += 0.01
                                if longPressProgress >= 1.0 {
                                    timer.invalidate()
                                    longPressProgress = 0
                                    DispatchQueue.main.async {
                                        endFocus(forceEnd: true)
                                    }
                                }
                            }
                        } else {
                            // 取消长按计时器
                            longPressTimer?.invalidate()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                longPressProgress = 0
                            }
                        }
                    }, perform: {})
                
                // UI 内容
                VStack(spacing: 50) {
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            NavigationLink(destination: SettingsView(isCycleEnabled: $isCycleEnabled).environmentObject(timerModel)) {
                                FlipClock(minutes: $timerModel.remainingTime.minutes,
                                          seconds: $timerModel.remainingTime.seconds,
                                          fontSize: verticalFontSize(geometry: geometry))
                                .offset(y: clockOffset)
                            }
                            .buttonStyle(PlainButtonStyle()) // 添加 PlainButtonStyle 以确保点击事件
                            .disabled(timerModel.isRunning)
                            Spacer()
                        }
                        .padding(.top, window?.safeAreaInsets.top ?? 0)
                        .onAppear {
                            initialClockOffset = (UIScreen.main.bounds.height * 0.4) - (geometry.size.height / 2) - (window?.safeAreaInsets.top ?? 0)
                            clockOffset = initialClockOffset
                        }
                        .onChange(of: isFocusActive) { oldValue, newValue in
                            if newValue {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    clockOffset = (UIScreen.main.bounds.height / 2) - (geometry.size.height / 2) - (window?.safeAreaInsets.top ?? 0)
                                }
                            } else if !timerModel.isResting {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    clockOffset = initialClockOffset
                                }
                            }
                        }
                        .onChange(of: timerModel.isResting) { oldValue, newValue in
                            withAnimation(.easeInOut(duration: 0.8)) {
                                if newValue {
                                    clockOffset = (UIScreen.main.bounds.height / 2) - (geometry.size.height / 2) - (window?.safeAreaInsets.top ?? 0)
                                } else {
                                    clockOffset = initialClockOffset
                                }
                            }
                        }
                    }
                    if !timerModel.isResting {
                        HStack(spacing: 20) { // 调整间距
                            // 循环开关按钮
                            Button(action: {
                                showCycleSettings = true
                            }) {
                                Image(systemName: isCycleEnabled ? "repeat.circle.fill" : "repeat.circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(textColor)
                                
                            }
                            .sheet(isPresented: $showCycleSettings) {
                                CycleSettingsView(isCycleEnabled: $isCycleEnabled)
                                    .environmentObject(timerModel)
                                    .accentColor(textColor)
                                    .environment(\.colorScheme, colorScheme)
                            }
                            
                            ActionButton(
                                label: timerModel.isRunning ? "暂停" : (timerModel.isFocusSession ? "开始" : "继续"),
                                gradient: LinearGradient(colors: [textColor.opacity(timerModel.isRunning ? 0.7 : 1.0), textColor.opacity(timerModel.isRunning ? 0.5 : 0.8)], startPoint: .leading, endPoint: .trailing),
                                action: {
                                    if timerModel.isRunning {
                                        timerModel.pause()
                                    } else {
                                        startFocus()
                                    }
                                }
                            )
                            
                            // 标签设置按钮
                            Button(action: {
                                showTagView = true
                            }) {
                                Image(systemName: "tag.circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(textColor)
                            }
                            .sheet(isPresented: $showTagView) {
                                TagView()
                            }
                        }
                        .opacity(isButtonsVisible ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.3), value: isButtonsVisible)
                    }
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: CalendarView()) {
                            Image(systemName: "calendar")
                                .foregroundColor(textColor)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("番茄钟")
                            .font(.headline)
                            .foregroundColor(textColor)
                    }
                }
                
                // 完成一个番茄钟的卡片
                if showCompletionCard {
                    CompletionCard(onRest: {
                        animateCardAndStartRest()
                        showEndRestButton = true // 设置为显示“结束休息”按钮
                    })
                    .scaleEffect(cardScale)
                    .rotationEffect(.degrees(cardRotation))
                }
                
                // 循环间确认卡片
                if showCycleCompletionCard {
                    // 直接传递 currentCycle 的值
                    CycleCompletionCard(currentCycle: currentCycle, onConfirm: {
                        continueToNextCycle()
                    })
                }
                
                // 显示当前标签
                if timerModel.isRunning && !timerModel.isResting {
                    Text("\(tagManager.currentTag)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // 长按结束专注 UI
                if isFocusActive && !timerModel.isResting {
                    VStack {
                        Spacer()
                        VStack {
                            Text("长按结束专注")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: oneCentimeterInPoints, height: 4)
                                    .foregroundColor(.white.opacity(0.3))
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .frame(width: oneCentimeterInPoints * longPressProgress, height: 4)
                                    .foregroundColor(.white)
                                    .cornerRadius(2)
                            }
                            .frame(height: 4)
                        }
                        .padding(.bottom, window?.safeAreaInsets.bottom ?? 0)
                    }
                } else if timerModel.isResting && showEndRestButton {
                    VStack {
                        Spacer()
                        Button("结束休息") {
                            endRest()
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(textColor)
                        .cornerRadius(30)
                    }
                }
            }
            .accentColor(textColor)
            .onReceive(timerModel.completionPublisher) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    showCompletionCard = true
                }
                // 记录完成的专注时间和标签
                CalendarManager.shared.recordCompletion(focusTime: timerModel.focusTime, tag: tagManager.currentTag, startDate: Date())
            }
            .onReceive(timerModel.autoEndRestPublisher) { _ in
                endRest()
            }
        }
        .environment(\.backgroundOpacity, backgroundOpacity)
    }
    
    private func startFocus() {
        isAnimating = true
        isFocusActive = true
        isButtonsVisible = false
        timerModel.setupTargetTime()
        timerModel.start()
        
        withAnimation(.easeInOut(duration: 0.8)) {
            elementsOpacity = 0.0
            backgroundOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            isAnimating = false
        }
    }
    
    private func endFocus(forceEnd: Bool) {
        guard !isAnimating else { return }
        isAnimating = true
        timerModel.pause()
        longPressProgress = 0
        isButtonsVisible = true
        
        withAnimation(.easeInOut(duration: 0.8)) {
            elementsOpacity = 1.0
            backgroundOpacity = 0.0
            isFocusActive = false
        }
        
        // 循环逻辑
        if !forceEnd && isCycleEnabled {
            // 显示循环间确认卡片
            showCycleCompletionCard = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [self] in
                isAnimating = false
            }
        } else {
            timerModel.reset() // 重置计时器状态
            currentCycle = 1 // 重置番茄钟循环计数
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.isAnimating = false
            }
            
        }
    }
    
    private func startRest() {
        isResting = true
        isButtonsVisible = false
        timerModel.start()
        withAnimation(.easeInOut(duration: 0.8)) {
            backgroundOpacity = 1.0
        }
    }
    
    private func endRest() {
        timerModel.pause()
        isResting = false
        
        if isCycleEnabled {
            // 显示循环间确认卡片
            showCycleCompletionCard = true
        } else {
            // 如果不是循环，或者循环结束，则重置
            withAnimation(.easeInOut(duration: 0.8)) {
                backgroundOpacity = 0.0
                elementsOpacity = 1.0
            }
            isButtonsVisible = true
            timerModel.resetUIState()
            timerModel.reset()
            isFocusActive = false
            showEndRestButton = false // 重置显示“结束休息”按钮的状态
            currentCycle = 1 // 重置番茄钟循环计数
        }
    }
    
    // 继续到下一个循环
    private func continueToNextCycle() {
        showCycleCompletionCard = false
        currentCycle += 1
        timerModel.switchSession()
        
        isFocusActive = timerModel.isFocusSession
        isResting = !timerModel.isFocusSession
        
        // 根据新的 session 类型，启动计时器
        if timerModel.isFocusSession {
            timerModel.setupTargetTime() //要重新设置
            startFocus() // 显式调用
        } else {
            startRest() // 显式调用
        }
    }
    
    private func animateCardAndStartRest() {
        withAnimation(.easeInOut(duration: 0.6)) {
            cardScale = 0.1
            cardRotation = 360
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showCompletionCard = false
            startRest()
            cardScale = 1.0
            cardRotation = 0
        }
    }
    
    private func verticalFontSize(geometry: GeometryProxy) -> CGFloat {
        let height = geometry.size.height
        let width = geometry.size.width
        
        let clockAspectRatio: CGFloat = 4.5 / 1
        let widthBasedFontSize = (width * 0.9) / clockAspectRatio
        let heightBasedFontSize = height * 0.25
        return min(widthBasedFontSize, heightBasedFontSize)
    }
}
