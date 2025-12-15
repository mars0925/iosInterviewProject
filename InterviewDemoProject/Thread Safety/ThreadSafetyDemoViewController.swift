//
//  ThreadSafetyDemoViewController.swift
//  InterviewDemoProject
//
//  演示 Thread Safety（線程安全）的概念和實現方式
//

import UIKit

// MARK: - 不安全的計數器類別
/// 這個類別故意設計成線程不安全，用來演示問題
class UnsafeCounter {
    var count = 0
    
    func increment() {
        // 讀取當前值
        let currentValue = count
        // 模擬一些處理時間，增加競爭條件發生的機率
        Thread.sleep(forTimeInterval: 0.0001)
        // 寫入新值
        count = currentValue + 1
    }
}

// MARK: - 使用 Serial Queue 實現的安全計數器
/// 使用串行佇列確保所有操作按順序執行，天然線程安全
class SerialQueueSafeCounter {
    private var count = 0
    // 創建一個串行佇列來保護共享資源
    private let serialQueue = DispatchQueue(label: "com.example.serialCounter")
    
    func increment() {
        // 所有的修改操作都在串行佇列中執行
        serialQueue.sync {
            count += 1
        }
    }
    
    func getCount() -> Int {
        // 讀取操作也需要在同一個佇列中執行
        return serialQueue.sync {
            return count
        }
    }
}

// MARK: - 使用 NSLock 實現的安全計數器
/// 使用鎖機制來保護臨界區
class LockSafeCounter {
    private var count = 0
    // 創建一個鎖對象
    private let lock = NSLock()
    
    func increment() {
        // 進入臨界區前先獲取鎖
        lock.lock()
        count += 1
        // 離開臨界區後釋放鎖
        lock.unlock()
    }
    
    func getCount() -> Int {
        lock.lock()
        defer { lock.unlock() } // 使用 defer 確保鎖一定會被釋放
        return count
    }
}

// MARK: - 使用 Concurrent Queue + Barrier 實現的安全計數器
/// 適用於讀多寫少的場景，允許多個讀操作並發執行
class BarrierSafeCounter {
    private var count = 0
    // 創建一個並發佇列
    private let concurrentQueue = DispatchQueue(label: "com.example.barrierCounter", attributes: .concurrent)
    
    func increment() {
        // 使用 barrier flag 確保寫操作時沒有其他操作在執行
        concurrentQueue.async(flags: .barrier) {
            self.count += 1
        }
    }
    
    func getCount() -> Int {
        // 讀操作可以並發執行
        return concurrentQueue.sync {
            return count
        }
    }
}

// MARK: - 使用 Actor 實現的安全計數器（Swift 5.5+）
/// Actor 是 Swift 提供的線程安全抽象，自動處理同步
@available(iOS 13.0, *)
actor ActorSafeCounter {
    private var count = 0
    
    func increment() {
        // Actor 確保同一時間只有一個任務可以訪問 count
        count += 1
    }
    
    func getCount() -> Int {
        return count
    }
}

// MARK: - 主視圖控制器
class ThreadSafetyDemoViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let resultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI 設置
    private func setupUI() {
        title = "Thread Safety 演示"
        view.backgroundColor = .systemBackground
        
        // 設置 ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 結果顯示標籤
        resultLabel.numberOfLines = 0
        resultLabel.font = .systemFont(ofSize: 14)
        resultLabel.textColor = .label
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resultLabel)
        
        // 創建測試按鈕
        let buttons = [
            createButton(title: "❌ 演示不安全計數器", action: #selector(testUnsafeCounter)),
            createButton(title: "✅ Serial Queue 安全計數器", action: #selector(testSerialQueueCounter)),
            createButton(title: "✅ NSLock 安全計數器", action: #selector(testLockCounter)),
            createButton(title: "✅ Barrier 安全計數器", action: #selector(testBarrierCounter)),
            createButton(title: "✅ Actor 安全計數器", action: #selector(testActorCounter)),
            createButton(title: "🔄 清除結果", action: #selector(clearResults))
        ]
        
        var previousButton: UIButton?
        for button in buttons {
            contentView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            if let previous = previousButton {
                button.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 12).isActive = true
            } else {
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
            }
            
            previousButton = button
        }
        
        // 設置約束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            resultLabel.topAnchor.constraint(equalTo: previousButton!.bottomAnchor, constant: 30),
            resultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // MARK: - 測試方法
    
    /// 測試不安全的計數器 - 會產生數據競爭
    @objc private func testUnsafeCounter() {
        let counter = UnsafeCounter()
        let iterations = 1000
        let group = DispatchGroup()
        
        appendResult("🔴 開始測試不安全計數器...")
        appendResult("啟動 10 個並發線程，每個執行 \(iterations) 次遞增")
        
        // 啟動多個並發線程
        for i in 1...10 {
            group.enter()
            DispatchQueue.global().async {
                for _ in 0..<iterations {
                    counter.increment()
                }
                group.leave()
            }
        }
        
        // 等待所有線程完成
        group.notify(queue: .main) {
            let expectedCount = 10 * iterations
            let actualCount = counter.count
            self.appendResult("預期結果: \(expectedCount)")
            self.appendResult("實際結果: \(actualCount)")
            
            if actualCount != expectedCount {
                self.appendResult("❌ 發生數據競爭！丟失了 \(expectedCount - actualCount) 次更新")
            } else {
                self.appendResult("✅ 結果正確（但這只是巧合，仍然不安全）")
            }
            self.appendResult("---\n")
        }
    }
    
    /// 測試使用 Serial Queue 的安全計數器
    @objc private func testSerialQueueCounter() {
        let counter = SerialQueueSafeCounter()
        let iterations = 1000
        let group = DispatchGroup()
        
        appendResult("🟢 開始測試 Serial Queue 安全計數器...")
        
        for _ in 1...10 {
            group.enter()
            DispatchQueue.global().async {
                for _ in 0..<iterations {
                    counter.increment()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let expectedCount = 10 * iterations
            let actualCount = counter.getCount()
            self.appendResult("預期結果: \(expectedCount)")
            self.appendResult("實際結果: \(actualCount)")
            self.appendResult(actualCount == expectedCount ? "✅ 線程安全！" : "❌ 失敗")
            self.appendResult("---\n")
        }
    }
    
    /// 測試使用 NSLock 的安全計數器
    @objc private func testLockCounter() {
        let counter = LockSafeCounter()
        let iterations = 1000
        let group = DispatchGroup()
        
        appendResult("🟢 開始測試 NSLock 安全計數器...")
        
        for _ in 1...10 {
            group.enter()
            DispatchQueue.global().async {
                for _ in 0..<iterations {
                    counter.increment()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let expectedCount = 10 * iterations
            let actualCount = counter.getCount()
            self.appendResult("預期結果: \(expectedCount)")
            self.appendResult("實際結果: \(actualCount)")
            self.appendResult(actualCount == expectedCount ? "✅ 線程安全！" : "❌ 失敗")
            self.appendResult("---\n")
        }
    }
    
    /// 測試使用 Barrier 的安全計數器
    @objc private func testBarrierCounter() {
        let counter = BarrierSafeCounter()
        let iterations = 1000
        let group = DispatchGroup()
        
        appendResult("🟢 開始測試 Barrier 安全計數器...")
        
        for _ in 1...10 {
            group.enter()
            DispatchQueue.global().async {
                for _ in 0..<iterations {
                    counter.increment()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Barrier 是異步的，需要等待一下
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let expectedCount = 10 * iterations
                let actualCount = counter.getCount()
                self.appendResult("預期結果: \(expectedCount)")
                self.appendResult("實際結果: \(actualCount)")
                self.appendResult(actualCount == expectedCount ? "✅ 線程安全！" : "❌ 失敗")
                self.appendResult("---\n")
            }
        }
    }
    
    /// 測試使用 Actor 的安全計數器
    @objc private func testActorCounter() {
        if #available(iOS 13.0, *) {
            let counter = ActorSafeCounter()
            let iterations = 1000
            
            appendResult("🟢 開始測試 Actor 安全計數器...")
            
            Task {
                // 啟動多個並發任務
                await withTaskGroup(of: Void.self) { group in
                    for _ in 1...10 {
                        group.addTask {
                            for _ in 0..<iterations {
                                await counter.increment()
                            }
                        }
                    }
                }
                
                let expectedCount = 10 * iterations
                let actualCount = await counter.getCount()
                
                await MainActor.run {
                    self.appendResult("預期結果: \(expectedCount)")
                    self.appendResult("實際結果: \(actualCount)")
                    self.appendResult(actualCount == expectedCount ? "✅ 線程安全！" : "❌ 失敗")
                    self.appendResult("---\n")
                }
            }
        } else {
            appendResult("❌ Actor 需要 iOS 13.0 以上版本")
            appendResult("---\n")
        }
    }
    
    @objc private func clearResults() {
        resultLabel.text = ""
    }
    
    private func appendResult(_ text: String) {
        let currentText = resultLabel.text ?? ""
        resultLabel.text = currentText + text + "\n"
    }
}

