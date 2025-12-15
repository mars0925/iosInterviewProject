//
//  QueueThreadCoroutineDemoViewController.swift
//  InterviewDemoProject
//
//  This demo illustrates the differences between:
//  1. Thread - OS-level execution unit
//  2. Queue  - Task scheduling abstraction (GCD)
//  3. Coroutine - Lightweight user-level execution unit (async/await)
//

import UIKit

class QueueThreadCoroutineDemoViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let outputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.isEditable = false
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.backgroundColor = UIColor.systemGray6
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Queue / Thread / 協程"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Section: Thread
        addSectionLabel("📍 Thread（線程）")
        addButton(title: "1. 直接使用 Thread", action: #selector(threadDemo))
        addButton(title: "2. 查看當前線程資訊", action: #selector(threadInfoDemo))
        
        // Section: Queue (GCD)
        addSectionLabel("📍 Queue（GCD 佇列）")
        addButton(title: "3. Serial Queue 串行隊列", action: #selector(serialQueueDemo))
        addButton(title: "4. Concurrent Queue 併發隊列", action: #selector(concurrentQueueDemo))
        addButton(title: "5. Queue 與 Thread 的關係", action: #selector(queueThreadRelationDemo))
        
        // Section: Coroutine (async/await)
        addSectionLabel("📍 Coroutine（協程 - async/await）")
        addButton(title: "6. 協程基本使用", action: #selector(coroutineBasicDemo))
        addButton(title: "7. 協程 vs 阻塞式調用", action: #selector(coroutineVsBlockingDemo))
        addButton(title: "8. 協程的暫停與恢復", action: #selector(coroutineSuspendResumeDemo))
        
        // Section: Comparison
        addSectionLabel("📍 三者比較")
        addButton(title: "9. 執行相同任務的對比", action: #selector(comparisonDemo))
        
        // Clear button
        addButton(title: "🗑️ 清除輸出", action: #selector(clearOutput), color: .systemGray)
        
        // Output text view
        contentStackView.addArrangedSubview(outputTextView)
        outputTextView.heightAnchor.constraint(equalToConstant: 350).isActive = true
    }
    
    private func addSectionLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        contentStackView.addArrangedSubview(label)
    }
    
    private func addButton(title: String, action: Selector, color: UIColor = .systemBlue) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentStackView.addArrangedSubview(button)
    }
    
    // MARK: - Thread Demos
    
    /// Demo 1: Direct Thread creation and management
    /// Shows that Thread is an OS-level execution unit that requires manual management
    @objc private func threadDemo() {
        clearOutput()
        appendOutput("=== Thread Demo ===\n")
        appendOutput("直接創建 Thread 物件，由 OS 管理生命週期\n\n")
        
        // Create a custom thread
        // Thread is the lowest level abstraction we typically use
        // Each thread has its own stack (~512KB-1MB)
        let customThread = Thread { [weak self] in
            // This code runs on a new OS thread
            let threadName = Thread.current.name ?? "unnamed"
            let isMain = Thread.current.isMainThread
            
            self?.appendOutput("🔵 Thread 名稱: \(threadName)\n")
            self?.appendOutput("🔵 是否為主線程: \(isMain)\n")
            self?.appendOutput("🔵 Thread 優先級: \(Thread.current.threadPriority)\n")
            
            // Simulate some work
            for i in 1...3 {
                Thread.sleep(forTimeInterval: 0.5)
                self?.appendOutput("🔵 Thread 執行中... (\(i)/3)\n")
            }
            
            self?.appendOutput("🔵 Thread 完成\n")
        }
        
        // Configure thread before starting
        customThread.name = "MyCustomThread"
        customThread.qualityOfService = .userInitiated
        
        appendOutput("準備啟動 Thread...\n")
        
        // Start the thread - OS takes control from here
        customThread.start()
        
        appendOutput("Thread.start() 已調用（非阻塞）\n")
        appendOutput("注意：Thread 需要手動管理，無法直接取消\n\n")
    }
    
    /// Demo 2: Display current thread information
    /// Shows how to inspect thread properties
    @objc private func threadInfoDemo() {
        clearOutput()
        appendOutput("=== Thread Info Demo ===\n")
        appendOutput("檢視當前線程的詳細資訊\n\n")
        
        // Get info from main thread
        let mainThread = Thread.main
        appendOutput("【主線程資訊】\n")
        appendOutput("• 名稱: \(mainThread.name ?? "main")\n")
        appendOutput("• 是主線程: \(mainThread.isMainThread)\n")
        appendOutput("• Stack 大小: \(mainThread.stackSize / 1024) KB\n")
        appendOutput("• 優先級: \(mainThread.threadPriority)\n\n")
        
        // Create background thread and inspect
        DispatchQueue.global().async { [weak self] in
            let currentThread = Thread.current
            
            self?.appendOutput("【背景線程資訊】\n")
            self?.appendOutput("• 名稱: \(currentThread.name ?? "unnamed")\n")
            self?.appendOutput("• 是主線程: \(currentThread.isMainThread)\n")
            self?.appendOutput("• Stack 大小: \(currentThread.stackSize / 1024) KB\n")
            self?.appendOutput("• 優先級: \(currentThread.threadPriority)\n\n")
            
            self?.appendOutput("💡 說明：每個 Thread 有獨立的 Stack\n")
            self?.appendOutput("   典型的 Stack 大小是 512KB - 1MB\n")
        }
    }
    
    // MARK: - Queue (GCD) Demos
    
    /// Demo 3: Serial Queue demonstration
    /// Shows how serial queue executes tasks one by one
    @objc private func serialQueueDemo() {
        clearOutput()
        appendOutput("=== Serial Queue Demo ===\n")
        appendOutput("串行隊列：任務按順序執行，一次只執行一個\n\n")
        
        // Create a serial queue (default is serial)
        // Serial queue guarantees FIFO execution order
        let serialQueue = DispatchQueue(label: "com.demo.serialQueue")
        
        appendOutput("提交 3 個任務到串行隊列...\n\n")
        
        // Submit multiple tasks
        for i in 1...3 {
            serialQueue.async { [weak self] in
                // Each task executes after the previous one completes
                let threadId = pthread_mach_thread_np(pthread_self())
                self?.appendOutput("📋 任務 \(i) 開始 (Thread: \(threadId))\n")
                
                // Simulate work
                Thread.sleep(forTimeInterval: 0.5)
                
                self?.appendOutput("📋 任務 \(i) 完成\n")
            }
        }
        
        // This executes immediately, before queue tasks
        appendOutput("所有任務已提交（async 不阻塞）\n")
        appendOutput("觀察：任務會按 1→2→3 順序執行\n\n")
    }
    
    /// Demo 4: Concurrent Queue demonstration
    /// Shows how concurrent queue can execute multiple tasks simultaneously
    @objc private func concurrentQueueDemo() {
        clearOutput()
        appendOutput("=== Concurrent Queue Demo ===\n")
        appendOutput("併發隊列：多個任務可同時執行\n\n")
        
        // Create a concurrent queue
        // System will use multiple threads from thread pool
        let concurrentQueue = DispatchQueue(
            label: "com.demo.concurrentQueue",
            attributes: .concurrent
        )
        
        appendOutput("提交 3 個任務到併發隊列...\n\n")
        
        for i in 1...3 {
            concurrentQueue.async { [weak self] in
                // Tasks may execute on different threads simultaneously
                let threadId = pthread_mach_thread_np(pthread_self())
                self?.appendOutput("🔀 任務 \(i) 開始 (Thread: \(threadId))\n")
                
                Thread.sleep(forTimeInterval: 0.5)
                
                self?.appendOutput("🔀 任務 \(i) 完成\n")
            }
        }
        
        appendOutput("所有任務已提交\n")
        appendOutput("觀察：任務可能同時執行，順序不固定\n\n")
    }
    
    /// Demo 5: Relationship between Queue and Thread
    /// Shows that Queue is an abstraction over Thread Pool
    @objc private func queueThreadRelationDemo() {
        clearOutput()
        appendOutput("=== Queue 與 Thread 的關係 ===\n")
        appendOutput("Queue 是任務調度的抽象，Thread 是實際執行載體\n\n")
        
        let concurrentQueue = DispatchQueue(
            label: "com.demo.relation",
            attributes: .concurrent
        )
        
        // Track which threads are used
        var threadIds = Set<UInt32>()
        let lock = NSLock()
        
        let group = DispatchGroup()
        
        appendOutput("提交 10 個任務，觀察使用了多少 Thread...\n\n")
        
        for i in 1...10 {
            group.enter()
            concurrentQueue.async {
                // Get thread ID (Mach thread ID)
                let threadId = pthread_mach_thread_np(pthread_self())
                
                // Thread-safe access to shared set
                lock.lock()
                threadIds.insert(threadId)
                lock.unlock()
                
                // Simulate varying work durations
                Thread.sleep(forTimeInterval: Double.random(in: 0.1...0.3))
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.appendOutput("📊 結果統計：\n")
            self?.appendOutput("• 提交的任務數: 10\n")
            self?.appendOutput("• 使用的 Thread 數: \(threadIds.count)\n")
            self?.appendOutput("• Thread IDs: \(threadIds.sorted())\n\n")
            
            self?.appendOutput("💡 重點：\n")
            self?.appendOutput("1. Queue 不是 Thread\n")
            self?.appendOutput("2. Queue 從 Thread Pool 借用 Thread\n")
            self?.appendOutput("3. 系統自動管理 Thread 的創建和重用\n")
            self?.appendOutput("4. 開發者無需手動管理 Thread 生命週期\n")
        }
    }
    
    // MARK: - Coroutine (async/await) Demos
    
    /// Demo 6: Basic coroutine usage with async/await
    /// Shows the basic syntax and execution model of Swift concurrency
    @objc private func coroutineBasicDemo() {
        clearOutput()
        appendOutput("=== 協程基本使用 (async/await) ===\n")
        appendOutput("協程是輕量級的用戶態執行單元\n\n")
        
        // Task creates a new coroutine
        // Unlike Thread, Task is lightweight (only a few KB)
        Task { [weak self] in
            self?.appendOutput("🚀 Task (協程) 開始執行\n")
            self?.appendOutput("   當前在主線程: \(Thread.isMainThread)\n\n")
            
            // await marks a suspension point
            // The coroutine can be suspended here without blocking the thread
            self?.appendOutput("⏸️  調用 async 函數 (協程可能暫停)...\n")
            
            let result = await self?.simulateAsyncWork()
            
            // After await, execution resumes (possibly on different thread)
            self?.appendOutput("▶️  協程恢復執行\n")
            self?.appendOutput("   結果: \(result ?? "nil")\n\n")
            
            self?.appendOutput("💡 說明：\n")
            self?.appendOutput("• async/await 是 Swift 的協程實現\n")
            self?.appendOutput("• await 是暫停點，線程不會被阻塞\n")
            self?.appendOutput("• 協程記憶體開銷很小（KB 級別）\n")
            self?.appendOutput("• 可以創建成千上萬個 Task\n")
        }
    }
    
    /// Simulates an async operation
    /// This function represents a coroutine that can be suspended
    private func simulateAsyncWork() async -> String {
        // Simulate network delay
        // Unlike Thread.sleep(), this doesn't block the thread
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        return "異步操作完成 ✓"
    }
    
    /// Demo 7: Coroutine vs Blocking comparison
    /// Shows the difference between coroutine suspension and thread blocking
    @objc private func coroutineVsBlockingDemo() {
        clearOutput()
        appendOutput("=== 協程 vs 阻塞式調用 ===\n")
        appendOutput("展示協程暫停與線程阻塞的區別\n\n")
        
        // Part 1: Thread blocking (bad)
        appendOutput("【1. 線程阻塞方式（不推薦）】\n")
        appendOutput("Thread.sleep() 會阻塞整個線程...\n")
        
        let blockingStart = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.global().async { [weak self] in
            // This blocks the entire thread
            Thread.sleep(forTimeInterval: 1)
            
            let elapsed = CFAbsoluteTimeGetCurrent() - blockingStart
            self?.appendOutput("阻塞完成，耗時: \(String(format: "%.2f", elapsed))s\n")
            self?.appendOutput("⚠️ 線程在等待期間完全被占用\n\n")
            
            // Part 2: Coroutine suspension (good)
            self?.appendOutput("【2. 協程暫停方式（推薦）】\n")
            self?.appendOutput("Task.sleep() 只暫停協程...\n")
            
            let suspendStart = CFAbsoluteTimeGetCurrent()
            
            Task {
                // This only suspends the coroutine, thread is free
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                
                let elapsed = CFAbsoluteTimeGetCurrent() - suspendStart
                self?.appendOutput("暫停完成，耗時: \(String(format: "%.2f", elapsed))s\n")
                self?.appendOutput("✅ 線程可以執行其他任務\n\n")
                
                self?.appendOutput("💡 關鍵區別：\n")
                self?.appendOutput("• Thread.sleep: 阻塞線程，浪費資源\n")
                self?.appendOutput("• Task.sleep: 暫停協程，線程可重用\n")
            }
        }
    }
    
    /// Demo 8: Coroutine suspend and resume
    /// Shows how multiple coroutines can interleave on the same thread
    @objc private func coroutineSuspendResumeDemo() {
        clearOutput()
        appendOutput("=== 協程的暫停與恢復 ===\n")
        appendOutput("多個協程可以交替執行\n\n")
        
        // Create multiple tasks (coroutines)
        // They can interleave execution without blocking threads
        Task { [weak self] in
            self?.appendOutput("🔴 協程 A 開始\n")
            
            // Start another coroutine
            async let resultB = self?.runCoroutineB()
            
            self?.appendOutput("🔴 協程 A 第一階段完成\n")
            
            // Suspension point - coroutine A pauses here
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            self?.appendOutput("🔴 協程 A 恢復執行\n")
            
            // Wait for coroutine B
            _ = await resultB
            
            self?.appendOutput("🔴 協程 A 完成\n\n")
            
            self?.appendOutput("💡 說明：\n")
            self?.appendOutput("• 協程 A 和 B 交替執行\n")
            self?.appendOutput("• 每個 await 都是潛在的暫停點\n")
            self?.appendOutput("• 暫停時，線程可執行其他協程\n")
            self?.appendOutput("• 這就是「協作式多工」的含義\n")
        }
    }
    
    private func runCoroutineB() async -> String {
        appendOutput("  🔵 協程 B 開始\n")
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        appendOutput("  🔵 協程 B 完成\n")
        
        return "B done"
    }
    
    // MARK: - Comparison Demo
    
    /// Demo 9: Compare Thread, Queue, and Coroutine
    /// Shows the same task implemented with all three approaches
    @objc private func comparisonDemo() {
        clearOutput()
        appendOutput("=== 三者比較：執行相同任務 ===\n")
        appendOutput("任務：執行 3 個模擬 API 請求\n\n")
        
        // 1. Using Thread directly (rarely used)
        appendOutput("【1. 使用 Thread】\n")
        appendOutput("需要手動創建和管理線程\n")
        appendOutput("每個線程開銷約 512KB-1MB\n\n")
        
        // 2. Using Queue (GCD)
        appendOutput("【2. 使用 Queue (GCD)】\n")
        appendOutput("系統自動管理 Thread Pool\n")
        appendOutput("通過回調處理結果\n\n")
        
        // 3. Using Coroutine (async/await)
        appendOutput("【3. 使用協程 (async/await)】\n")
        appendOutput("語法簡潔，像同步代碼\n")
        appendOutput("輕量級，可創建大量協程\n\n")
        
        appendOutput("---\n")
        appendOutput("實際執行比較：\n\n")
        
        // Run with GCD
        let gcdStart = CFAbsoluteTimeGetCurrent()
        let group = DispatchGroup()
        
        for i in 1...3 {
            group.enter()
            DispatchQueue.global().async {
                Thread.sleep(forTimeInterval: 0.3)
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            let gcdTime = CFAbsoluteTimeGetCurrent() - gcdStart
            self?.appendOutput("GCD 完成時間: \(String(format: "%.3f", gcdTime))s\n")
            
            // Run with async/await
            Task {
                let asyncStart = CFAbsoluteTimeGetCurrent()
                
                // Parallel execution with async let
                async let task1: Void = self?.simulateAPICall(id: 1) ?? ()
                async let task2: Void = self?.simulateAPICall(id: 2) ?? ()
                async let task3: Void = self?.simulateAPICall(id: 3) ?? ()
                
                _ = await (task1, task2, task3)
                
                let asyncTime = CFAbsoluteTimeGetCurrent() - asyncStart
                self?.appendOutput("async/await 完成時間: \(String(format: "%.3f", asyncTime))s\n\n")
                
                self?.appendOutput("📊 結論：\n")
                self?.appendOutput("• 性能相近，但協程語法更簡潔\n")
                self?.appendOutput("• 協程避免回調地獄\n")
                self?.appendOutput("• 協程有更好的錯誤處理\n")
                self?.appendOutput("• 新專案推薦使用 async/await\n")
            }
        }
    }
    
    private func simulateAPICall(id: Int) async {
        try? await Task.sleep(nanoseconds: 300_000_000)
    }
    
    // MARK: - Helper Methods
    
    @objc private func clearOutput() {
        outputTextView.text = ""
    }
    
    private func appendOutput(_ text: String) {
        // Ensure UI updates happen on main thread
        DispatchQueue.main.async { [weak self] in
            self?.outputTextView.text += text
            
            // Auto-scroll to bottom
            if let textView = self?.outputTextView,
               textView.text.count > 0 {
                let range = NSRange(
                    location: textView.text.count - 1,
                    length: 1
                )
                textView.scrollRangeToVisible(range)
            }
        }
    }
}

// MARK: - Summary Comments

/*
 ╔══════════════════════════════════════════════════════════════════╗
 ║                    Thread vs Queue vs Coroutine                   ║
 ╠══════════════════════════════════════════════════════════════════╣
 ║                                                                   ║
 ║  Thread（線程）                                                   ║
 ║  ─────────────                                                    ║
 ║  • OS 核心管理的執行單位                                          ║
 ║  • 重量級：每個約 512KB-1MB                                       ║
 ║  • 數量有限：系統資源受限                                          ║
 ║  • 上下文切換開銷大                                               ║
 ║  • 很少直接使用                                                   ║
 ║                                                                   ║
 ║  Queue（佇列 - GCD）                                              ║
 ║  ─────────────────                                                ║
 ║  • 任務調度的抽象層                                               ║
 ║  • 自動管理 Thread Pool                                          ║
 ║  • Serial Queue：保證順序執行                                     ║
 ║  • Concurrent Queue：支持並行執行                                 ║
 ║  • iOS 開發最常用的方式                                           ║
 ║                                                                   ║
 ║  Coroutine（協程 - async/await）                                  ║
 ║  ───────────────────────────                                      ║
 ║  • 用戶態的輕量級執行單元                                         ║
 ║  • 極輕量：只有幾 KB                                              ║
 ║  • 可創建成千上萬個                                               ║
 ║  • 暫停時不阻塞線程                                               ║
 ║  • 語法簡潔，避免回調地獄                                         ║
 ║  • Swift 5.5+ 推薦方式                                           ║
 ║                                                                   ║
 ╚══════════════════════════════════════════════════════════════════╝
 
 層級關係：
 
     Coroutines（協程）
          ↓
     Queues（佇列）
          ↓
     Thread Pool（線程池）
          ↓
     OS Kernel（作業系統核心）
 
 選擇建議：
 - 簡單背景任務 → GCD (DispatchQueue)
 - 需要取消/依賴 → OperationQueue
 - 新專案異步代碼 → async/await
 - 精細線程控制 → Thread（很少需要）
 */

