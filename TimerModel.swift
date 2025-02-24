//TimerModel.swift
import SwiftUI
import AudioToolbox
import Combine

class TimerModel: ObservableObject {
    
    @AppStorage("completedCount") var completedCount = 0
    @AppStorage("focusTime") var focusTime = 25 {
        didSet { if isFocusSession { syncTimeSetting() } }
    }
    @AppStorage("breakTime") var breakTime = 5 {
        didSet { if !isFocusSession { syncTimeSetting() } }
    }
    @Published var remainingTime: (minutes: Int, seconds: Int) = (0, 0)
    @Published var isRunning = false
    @Published var isFocusSession = true
    @Published var isResting = false
    @Published var targetTime: Date = Date()

    let completionPublisher = PassthroughSubject<Void, Never>()
    let autoEndRestPublisher = PassthroughSubject<Void, Never>()

    private var timer: Timer?
    private var cancellables: Set<AnyCancellable> = []

    init() {
        
         syncTimeSetting()
        print("TimerModel init: targetTime = \(targetTime), remainingTime = \(remainingTime)")
    }

    func syncTimeSetting() {
        remainingTime = isFocusSession ? (focusTime, 0) : (breakTime, 0)
        print("syncTimeSetting: remainingTime = \(remainingTime)")
    }

        func updateTargetTime() {
              let minutesToAdd = isFocusSession ? focusTime : breakTime
              var components = DateComponents()
              components.minute = minutesToAdd
               targetTime = Calendar.current.date(byAdding: components, to: Date(), wrappingComponents: false)!
              print("updateTargetTime: targetTime = \(targetTime)")
        }
    
    func setupTargetTime() {
        updateTargetTime()
        calculateRemainingTime()
    }

    func start() {
           isRunning = true
           timer?.invalidate()
           print("start - before timer creation: remainingTime = \(remainingTime)")

        timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
               guard let self = self else { return }
               if self.remainingTime.minutes == 0 && self.remainingTime.seconds == 0 {
                self.timerCompleted()
               } else if self.remainingTime.seconds == 0 {
                   self.remainingTime.minutes -= 1
                   self.remainingTime.seconds = 59
               } else {
                   self.remainingTime.seconds -= 1
               }
           }
           RunLoop.current.add(timer!, forMode: .common)
       }
    

    func resetAndStart() {
          pause()
          syncTimeSetting()
          updateTargetTime()
          start()
      }

    func switchSession() {
            isFocusSession.toggle()
            isResting = !isFocusSession // 确保 isResting 与 isFocusSession 相反
            syncTimeSetting()
            updateTargetTime()

        }
    func pause() {
        isRunning = false
        timer?.invalidate()
        
    }

    func timerCompleted() {
        if isFocusSession {
            completedCount += 1
            completionPublisher.send()
            
            // 专注时间结束后，,调用switchSession()
            switchSession()
        }else if isResting{
              autoEndRestPublisher.send() // 发送自动结束休息的通知
          }
        timer?.invalidate()
        isRunning = false
    }

    
    func reset() {
         pause() // 暂停计时器
         isFocusSession = true // 重置为专注模式
          isResting = false  //新增
          syncTimeSetting()  //新增
       }

      func resetUIState() {
           isResting = false
           isRunning = false
       }

    func calculateRemainingTime() {
        
        let timeLeft = Calendar.current.dateComponents([.minute, .second], from: Date(), to: targetTime)
           remainingTime = (timeLeft.minute ?? 0, timeLeft.second ?? 0)

           if remainingTime.minutes < 0 || remainingTime.seconds < 0 {
               remainingTime = (0, 0)
           }
    }
}
