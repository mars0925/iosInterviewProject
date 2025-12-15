//
//  MultithreadingDemoViewController.swift
//  InterviewDemoProject
//
//  Demonstrates all 5 multithreading approaches in iOS:
//  1. pthread - Low-level POSIX threads
//  2. NSThread - Objective-C thread wrapper
//  3. GCD - Grand Central Dispatch
//  4. Operation/OperationQueue - High-level abstraction
//  5. Swift Concurrency (async/await) - Modern Swift approach
//

import UIKit

// MARK: - Main Demo View Controller
class MultithreadingDemoViewController: UIViewController {
    
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
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Properties
    
    /// Serial queue for thread-safe output
    private let outputQueue = DispatchQueue(label: "com.demo.output")
    
    /// Operation queue for Operation demo
    private let operationQueue = OperationQueue()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "多線程開發演示"
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
        
        // Add section labels and demo buttons
        addSectionLabel("1️⃣ pthread (底層 C 線程)")
        addButton(title: "pthread Demo", action: #selector(pthreadDemo))
        
        addSectionLabel("2️⃣ NSThread (OC 線程封裝)")
        addButton(title: "NSThread Demo", action: #selector(nsThreadDemo))
        
        addSectionLabel("3️⃣ GCD (推薦方案)")
        addButton(title: "GCD Demo", action: #selector(gcdDemo))
        
        addSectionLabel("4️⃣ Operation (高級抽象)")
        addButton(title: "Operation Demo", action: #selector(operationDemo))
        
        addSectionLabel("5️⃣ Swift Concurrency (現代方案)")
        addButton(title: "async/await Demo", action: #selector(asyncAwaitDemo))
        
        addSectionLabel("📊 綜合比較")
        addButton(title: "五種方案並行比較", action: #selector(compareAllDemo))
        
        addButton(title: "清除輸出", action: #selector(clearOutput), color: .systemGray)
        
        // Add output text view
        contentStackView.addArrangedSubview(outputTextView)
        NSLayoutConstraint.activate([
            outputTextView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    private func addSectionLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        contentStackView.addArrangedSubview(label)
    }
    
    private func addButton(title: String, action: Selector, color: UIColor = .systemBlue) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        contentStackView.addArrangedSubview(button)
    }
    
    // MARK: - Demo 1: pthread
    
    /// Demonstrates the lowest level POSIX thread API
    /// pthread is rarely used directly in iOS development due to its complexity
    /// It requires manual thread lifecycle management
    @objc private func pthreadDemo() {
        clearOutput()
        appendOutput("=== pthread Demo ===\n")
        appendOutput("pthread 是 POSIX 標準的底層 C 線程 API\n")
        appendOutput("需要手動管理線程生命週期，很少在實際開發中使用\n\n")
        
        // Create a pthread
        // pthread requires a C function pointer, so we use a closure that returns UnsafeMutableRawPointer
        var thread: pthread_t?
        
        // The callback context - we pass self to access instance methods
        let context = Unmanaged.passRetained(self).toOpaque()
        
        // Create and start the thread
        // pthread_create takes:
        // - thread pointer
        // - attributes (nil for default)
        // - callback function
        // - context pointer
        let result = pthread_create(&thread, nil, { contextPtr -> UnsafeMutableRawPointer? in
            // Get the view controller instance from context
            let vc = Unmanaged<MultithreadingDemoViewController>
                .fromOpaque(contextPtr)
                .takeRetainedValue()
            
            // Check if running on main thread (should be NO for pthread)
            let threadName = Thread.current.isMainThread ? "Main Thread" : "pthread Thread"
            vc.appendOutput("✅ pthread 任務執行中... (\(threadName))\n")
            
            // Simulate some work
            Thread.sleep(forTimeInterval: 1)
            
            vc.appendOutput("✅ pthread 任務完成\n")
            vc.appendOutput("\n⚠️ 注意：pthread 需要手動管理，不推薦使用\n")
            
            return nil
        }, context)
        
        if result == 0 {
            appendOutput("pthread 創建成功，開始執行...\n")
        } else {
            appendOutput("❌ pthread 創建失敗\n")
        }
    }
    
    // MARK: - Demo 2: NSThread
    
    /// Demonstrates NSThread (Thread in Swift)
    /// This is an Objective-C wrapper around pthread
    /// Easier to use than pthread but still requires manual management
    @objc private func nsThreadDemo() {
        clearOutput()
        appendOutput("=== NSThread Demo ===\n")
        appendOutput("NSThread 是 Objective-C 對 pthread 的封裝\n")
        appendOutput("提供面向對象的 API，但仍需手動管理\n\n")
        
        // Method 1: Using Thread.detachNewThread (auto-starts)
        appendOutput("方式一：Thread.detachNewThread (自動啟動)\n")
        Thread.detachNewThread { [weak self] in
            let threadName = Thread.current.name ?? "未命名"
            let isMain = Thread.current.isMainThread ? "是" : "否"
            self?.appendOutput("→ 線程名稱：\(threadName)，主線程：\(isMain)\n")
            Thread.sleep(forTimeInterval: 0.5)
            self?.appendOutput("→ 方式一完成\n\n")
        }
        
        // Method 2: Create Thread instance and start manually
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.appendOutput("方式二：手動創建並啟動 Thread\n")
            
            let thread = Thread { [weak self] in
                // We can set thread properties before starting
                Thread.current.name = "MyCustomThread"
                
                let threadName = Thread.current.name ?? "未命名"
                self?.appendOutput("→ 線程名稱：\(threadName)\n")
                Thread.sleep(forTimeInterval: 0.5)
                self?.appendOutput("→ 方式二完成\n\n")
                
                self?.appendOutput("✅ NSThread 優點：可控制線程屬性\n")
                self?.appendOutput("⚠️ NSThread 缺點：需手動管理，無線程池\n")
            }
            
            // Set thread priority (0.0 to 1.0)
            thread.threadPriority = 0.8
            
            // Start the thread
            thread.start()
        }
    }
    
    // MARK: - Demo 3: GCD
    
    /// Demonstrates Grand Central Dispatch
    /// This is Apple's recommended approach for most multithreading scenarios
    /// It automatically manages the thread pool and provides efficient task scheduling
    @objc private func gcdDemo() {
        clearOutput()
        appendOutput("=== GCD Demo ===\n")
        appendOutput("GCD 是 Apple 推薦的多線程方案\n")
        appendOutput("自動管理線程池，簡單高效\n\n")
        
        // 1. Background task with main thread UI update
        appendOutput("📍 後台任務 + 主線程更新 UI\n")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.appendOutput("→ 後台任務開始...\n")
            Thread.sleep(forTimeInterval: 1)
            
            // Return to main thread to update UI
            DispatchQueue.main.async {
                self?.appendOutput("→ 回到主線程更新 UI ✓\n\n")
                self?.showGCDQueueDemo()
            }
        }
    }
    
    /// Shows different queue types in GCD
    private func showGCDQueueDemo() {
        appendOutput("📍 三種隊列類型\n")
        
        // Serial Queue - tasks execute one at a time
        let serialQueue = DispatchQueue(label: "com.demo.serial")
        appendOutput("\n串行隊列 (任務依次執行):\n")
        
        serialQueue.async { [weak self] in
            self?.appendOutput("→ 串行任務 1\n")
        }
        serialQueue.async { [weak self] in
            self?.appendOutput("→ 串行任務 2\n")
        }
        serialQueue.async { [weak self] in
            self?.appendOutput("→ 串行任務 3\n\n")
            
            // Show concurrent queue after serial completes
            DispatchQueue.main.async {
                self?.showConcurrentQueueDemo()
            }
        }
    }
    
    /// Demonstrates concurrent queue behavior
    private func showConcurrentQueueDemo() {
        appendOutput("併發隊列 (任務可同時執行):\n")
        
        // Concurrent Queue - tasks can execute simultaneously
        let concurrentQueue = DispatchQueue(label: "com.demo.concurrent", attributes: .concurrent)
        
        for i in 1...3 {
            concurrentQueue.async { [weak self] in
                self?.appendOutput("→ 併發任務 \(i) 開始\n")
                Thread.sleep(forTimeInterval: 0.3)
                self?.appendOutput("→ 併發任務 \(i) 完成\n")
            }
        }
        
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.appendOutput("\n✅ GCD 優點：自動線程管理，API 簡潔\n")
            self?.appendOutput("⚠️ GCD 缺點：任務無法取消\n")
        }
    }
    
    // MARK: - Demo 4: Operation
    
    /// Demonstrates OperationQueue
    /// This is a higher-level abstraction built on top of GCD
    /// Provides support for cancellation, dependencies, and KVO
    @objc private func operationDemo() {
        clearOutput()
        appendOutput("=== Operation Demo ===\n")
        appendOutput("Operation 是基於 GCD 的高級抽象\n")
        appendOutput("支持任務取消、依賴關係、優先級\n\n")
        
        // Reset and configure the operation queue
        operationQueue.cancelAllOperations()
        operationQueue.maxConcurrentOperationCount = 2  // Limit concurrent operations
        
        appendOutput("📍 設置最大併發數: 2\n")
        appendOutput("📍 創建有依賴關係的任務\n\n")
        
        // Create operations with dependencies
        // op3 depends on op1 and op2 completing first
        
        let op1 = BlockOperation { [weak self] in
            self?.appendOutput("→ 任務 1 執行中...\n")
            Thread.sleep(forTimeInterval: 0.8)
            self?.appendOutput("→ 任務 1 完成 ✓\n")
        }
        op1.name = "Operation 1"
        
        let op2 = BlockOperation { [weak self] in
            self?.appendOutput("→ 任務 2 執行中...\n")
            Thread.sleep(forTimeInterval: 0.5)
            self?.appendOutput("→ 任務 2 完成 ✓\n")
        }
        op2.name = "Operation 2"
        
        let op3 = BlockOperation { [weak self] in
            self?.appendOutput("\n→ 任務 3 執行中（依賴於 1 和 2）...\n")
            Thread.sleep(forTimeInterval: 0.3)
            self?.appendOutput("→ 任務 3 完成 ✓\n\n")
            
            DispatchQueue.main.async {
                self?.appendOutput("✅ Operation 優點：支持取消、依賴、優先級\n")
                self?.appendOutput("✅ 可以使用 KVO 監聽任務狀態\n")
            }
        }
        op3.name = "Operation 3"
        
        // Set up dependencies: op3 waits for op1 and op2
        op3.addDependency(op1)
        op3.addDependency(op2)
        
        // Add operations to queue
        // Order doesn't matter - dependencies control execution order
        operationQueue.addOperations([op1, op2, op3], waitUntilFinished: false)
    }
    
    // MARK: - Demo 5: Swift Concurrency
    
    /// Demonstrates Swift's modern concurrency model (async/await)
    /// Available from iOS 13+ (full features from iOS 15+)
    /// Provides cleaner syntax and compile-time safety
    @objc private func asyncAwaitDemo() {
        clearOutput()
        appendOutput("=== Swift Concurrency Demo ===\n")
        appendOutput("async/await 是 Swift 5.5 引入的現代並發模型\n")
        appendOutput("語法簡潔，編譯期安全檢查\n\n")
        
        // Use Task to enter async context
        Task { [weak self] in
            guard let self = self else { return }
            
            // Example 1: Simple async function
            self.appendOutput("📍 範例一：異步函數\n")
            let result = await self.simulateAsyncTask(name: "Task A", duration: 0.8)
            self.appendOutput("→ 結果: \(result)\n\n")
            
            // Example 2: Parallel execution with async let
            self.appendOutput("📍 範例二：並行執行 (async let)\n")
            self.appendOutput("→ 同時啟動兩個任務...\n")
            
            async let task1 = self.simulateAsyncTask(name: "Task 1", duration: 0.5)
            async let task2 = self.simulateAsyncTask(name: "Task 2", duration: 0.7)
            
            // Wait for both to complete
            let (r1, r2) = await (task1, task2)
            self.appendOutput("→ 結果: \(r1), \(r2)\n\n")
            
            // Example 3: Task cancellation
            self.appendOutput("📍 範例三：任務取消\n")
            
            let cancellableTask = Task {
                for i in 1...5 {
                    // Check for cancellation
                    if Task.isCancelled {
                        self.appendOutput("→ 任務被取消於 \(i)\n")
                        return "Cancelled"
                    }
                    self.appendOutput("→ 計數: \(i)\n")
                    try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                }
                return "Completed"
            }
            
            // Cancel after 0.5 seconds
            try? await Task.sleep(nanoseconds: 500_000_000)
            cancellableTask.cancel()
            
            let _ = await cancellableTask.value
            
            self.appendOutput("\n✅ async/await 優點：語法簡潔，編譯期安全\n")
            self.appendOutput("✅ 支持結構化並發，自動傳播取消\n")
        }
    }
    
    /// Simulates an async operation
    /// In real code, this might be a network request or file operation
    private func simulateAsyncTask(name: String, duration: TimeInterval) async -> String {
        appendOutput("→ \(name) 開始執行...\n")
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        appendOutput("→ \(name) 完成\n")
        return "\(name) Result"
    }
    
    // MARK: - Compare All Methods
    
    /// Runs all 5 methods simultaneously to compare their behavior
    @objc private func compareAllDemo() {
        clearOutput()
        appendOutput("=== 五種多線程方案比較 ===\n")
        appendOutput("同時啟動五種方案，觀察執行順序\n\n")
        
        let startTime = Date()
        
        // Create a dispatch group to track all completions
        let group = DispatchGroup()
        
        // 1. pthread
        group.enter()
        var pthread_thread: pthread_t?
        let pthreadContext = Unmanaged.passRetained(CompareContext(vc: self, group: group, name: "pthread")).toOpaque()
        pthread_create(&pthread_thread, nil, { ctx -> UnsafeMutableRawPointer? in
            let context = Unmanaged<CompareContext>.fromOpaque(ctx).takeRetainedValue()
            context.vc.appendOutput("1️⃣ [pthread] 執行中...\n")
            Thread.sleep(forTimeInterval: 0.3)
            context.vc.appendOutput("1️⃣ [pthread] 完成\n")
            context.group.leave()
            return nil
        }, pthreadContext)
        
        // 2. NSThread
        group.enter()
        Thread.detachNewThread { [weak self] in
            self?.appendOutput("2️⃣ [NSThread] 執行中...\n")
            Thread.sleep(forTimeInterval: 0.3)
            self?.appendOutput("2️⃣ [NSThread] 完成\n")
            group.leave()
        }
        
        // 3. GCD
        group.enter()
        DispatchQueue.global().async { [weak self] in
            self?.appendOutput("3️⃣ [GCD] 執行中...\n")
            Thread.sleep(forTimeInterval: 0.3)
            self?.appendOutput("3️⃣ [GCD] 完成\n")
            group.leave()
        }
        
        // 4. Operation
        group.enter()
        let operation = BlockOperation { [weak self] in
            self?.appendOutput("4️⃣ [Operation] 執行中...\n")
            Thread.sleep(forTimeInterval: 0.3)
            self?.appendOutput("4️⃣ [Operation] 完成\n")
            group.leave()
        }
        operationQueue.addOperation(operation)
        
        // 5. async/await
        group.enter()
        Task { [weak self] in
            self?.appendOutput("5️⃣ [async/await] 執行中...\n")
            try? await Task.sleep(nanoseconds: 300_000_000)
            self?.appendOutput("5️⃣ [async/await] 完成\n")
            group.leave()
        }
        
        // Summary when all complete
        group.notify(queue: .main) { [weak self] in
            let elapsed = Date().timeIntervalSince(startTime)
            self?.appendOutput("\n========== 總結 ==========\n")
            self?.appendOutput(String(format: "總耗時: %.2f 秒\n", elapsed))
            self?.appendOutput("\n推薦程度：\n")
            self?.appendOutput("⭐⭐⭐⭐⭐ GCD - 大多數場景首選\n")
            self?.appendOutput("⭐⭐⭐⭐⭐ async/await - 新項目首選\n")
            self?.appendOutput("⭐⭐⭐⭐   Operation - 需要任務管理時\n")
            self?.appendOutput("⭐⭐      NSThread - 簡單場景可用\n")
            self?.appendOutput("⭐        pthread - 不推薦直接使用\n")
        }
    }
    
    // MARK: - Helper Methods
    
    @objc private func clearOutput() {
        DispatchQueue.main.async { [weak self] in
            self?.outputTextView.text = ""
        }
    }
    
    /// Thread-safe output appending
    /// Uses serial queue to prevent race conditions on the text view
    private func appendOutput(_ text: String) {
        outputQueue.async { [weak self] in
            DispatchQueue.main.async {
                self?.outputTextView.text += text
                // Auto-scroll to bottom
                if let textView = self?.outputTextView {
                    let range = NSRange(location: textView.text.count - 1, length: 1)
                    textView.scrollRangeToVisible(range)
                }
            }
        }
    }
}

// MARK: - Helper Class for pthread Context

/// Context class to pass data to pthread callback
/// This is needed because pthread takes a C function pointer
/// and we need to pass Swift objects to it
fileprivate class CompareContext {
    let vc: MultithreadingDemoViewController
    let group: DispatchGroup
    let name: String
    
    init(vc: MultithreadingDemoViewController, group: DispatchGroup, name: String) {
        self.vc = vc
        self.group = group
        self.name = name
    }
}

// MARK: - Example: Thread-Safe Counter Using Actor

/// Demonstrates Swift Concurrency's Actor for thread safety
/// Actors automatically serialize access to their mutable state
/// This eliminates data races at compile time
actor ThreadSafeCounter {
    private var count = 0
    
    /// Increment is automatically thread-safe
    func increment() {
        count += 1
    }
    
    /// Decrement is automatically thread-safe
    func decrement() {
        count -= 1
    }
    
    /// Read is also automatically thread-safe
    func getCount() -> Int {
        return count
    }
}

// MARK: - Example Usage in Comments

/*
 =============================================
 面試常見問題與回答
 =============================================
 
 Q1: iOS 有幾種實現多線程的方法？
 A1: 五種 - pthread、NSThread、GCD、Operation、async/await
 
 Q2: 哪種方式最推薦使用？
 A2: GCD 是最常用且推薦的方案，async/await 是新項目的最佳選擇
 
 Q3: GCD 和 OperationQueue 的區別？
 A3: 
 - GCD 更輕量、高效，適合簡單任務
 - OperationQueue 支持取消、依賴、優先級，適合複雜任務管理
 
 Q4: 什麼時候用 Operation？
 A4: 需要取消任務、設置依賴關係、或監聽任務狀態時
 
 Q5: 主線程和後台線程的區別？
 A5:
 - 主線程：負責 UI 更新，不應執行耗時操作
 - 後台線程：執行耗時操作，完成後需回主線程更新 UI
 
 Q6: 如何保證線程安全？
 A6: 
 - 使用串行隊列
 - 使用鎖 (NSLock, os_unfair_lock)
 - 使用 GCD Barrier
 - 使用 Semaphore
 - 使用 Swift Actor
 
 =============================================
 各方案特點比較
 =============================================
 
 | 方案        | 自動管理 | 取消 | 依賴 | 推薦度 |
 |------------|---------|-----|-----|--------|
 | pthread    | ❌      | ❌  | ❌  | ⭐      |
 | NSThread   | ❌      | ❌  | ❌  | ⭐⭐    |
 | GCD        | ✅      | ❌  | ✅  | ⭐⭐⭐⭐⭐ |
 | Operation  | ✅      | ✅  | ✅  | ⭐⭐⭐⭐  |
 | async/await| ✅      | ✅  | ✅  | ⭐⭐⭐⭐⭐ |
 
 */

