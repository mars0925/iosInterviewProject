//
//  NSOperationDemoViewController.swift
//  InterviewDemoProject
//
//  演示 NSOperation 的使用方式和狀態管理
//  包含：BlockOperation、自定義 Operation、依賴關係、狀態監聽
//

import UIKit

// MARK: - NSOperation Demo View Controller

/// 主要演示頁面，展示 NSOperation 的各種使用方式
class NSOperationDemoViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 滾動視圖，用於容納所有按鈕和輸出區域
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    /// 垂直堆疊視圖，用於排列按鈕
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// 輸出文字視圖，顯示執行結果
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
    
    /// 操作佇列，用於管理和執行 Operation
    private let operationQueue = OperationQueue()
    
    /// 串行佇列，用於線程安全的輸出操作
    private let outputQueue = DispatchQueue(label: "com.demo.nsoperation.output")
    
    /// 用於追蹤當前正在觀察的 Operation
    private var observedOperations: [Operation] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureOperationQueue()
    }
    
    deinit {
        // 移除所有 KVO 觀察者，避免記憶體洩漏
        removeAllObservers()
    }
    
    // MARK: - UI Setup
    
    /// 設置使用者介面
    private func setupUI() {
        title = "NSOperation 演示"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        // 設置約束
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
        
        // 添加各個演示按鈕
        addSectionLabel("📦 基礎使用")
        addButton(title: "1. BlockOperation 基本用法", action: #selector(blockOperationDemo))
        addButton(title: "2. 操作狀態演示", action: #selector(operationStateDemo))
        
        addSectionLabel("🔗 依賴關係")
        addButton(title: "3. 設置任務依賴", action: #selector(dependencyDemo))
        
        addSectionLabel("⚙️ 進階功能")
        addButton(title: "4. 自定義 Operation", action: #selector(customOperationDemo))
        addButton(title: "5. 取消操作演示", action: #selector(cancelOperationDemo))
        addButton(title: "6. KVO 監聽狀態變化", action: #selector(kvoDemo))
        
        addSectionLabel("📊 佇列管理")
        addButton(title: "7. 併發數控制", action: #selector(concurrencyDemo))
        addButton(title: "8. 暫停/恢復佇列", action: #selector(suspendResumeDemo))
        
        // 清除輸出按鈕
        addButton(title: "清除輸出", action: #selector(clearOutput), color: .systemGray)
        
        // 添加輸出文字視圖
        contentStackView.addArrangedSubview(outputTextView)
        NSLayoutConstraint.activate([
            outputTextView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    /// 添加區段標籤
    private func addSectionLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        contentStackView.addArrangedSubview(label)
    }
    
    /// 添加按鈕
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
    
    /// 配置 OperationQueue 的基本屬性
    private func configureOperationQueue() {
        // 設置佇列名稱，方便調試
        operationQueue.name = "com.demo.nsoperation.queue"
        // 設置預設最大併發數
        operationQueue.maxConcurrentOperationCount = 3
    }
    
    // MARK: - Demo 1: BlockOperation 基本用法
    
    /// 演示最簡單的 BlockOperation 使用方式
    /// BlockOperation 允許以閉包形式定義任務，無需繼承 Operation
    @objc private func blockOperationDemo() {
        clearOutput()
        appendOutput("=== BlockOperation 基本用法 ===\n\n")
        
        // 創建一個 BlockOperation
        // BlockOperation 是 Operation 的子類，提供簡便的閉包式任務創建
        let operation = BlockOperation {
            self.appendOutput("📍 主任務正在執行...\n")
            Thread.sleep(forTimeInterval: 0.5)
            self.appendOutput("📍 主任務完成\n")
        }
        
        // BlockOperation 可以添加多個執行塊
        // 這些執行塊可能會並行執行
        operation.addExecutionBlock {
            self.appendOutput("📍 附加任務 1 執行中...\n")
            Thread.sleep(forTimeInterval: 0.3)
            self.appendOutput("📍 附加任務 1 完成\n")
        }
        
        operation.addExecutionBlock {
            self.appendOutput("📍 附加任務 2 執行中...\n")
            Thread.sleep(forTimeInterval: 0.4)
            self.appendOutput("📍 附加任務 2 完成\n")
        }
        
        // 設置完成回調
        // completionBlock 會在所有執行塊完成後調用
        operation.completionBlock = { [weak self] in
            self?.appendOutput("\n✅ 所有任務已完成（completionBlock）\n")
        }
        
        appendOutput("➡️ 開始執行 BlockOperation...\n\n")
        
        // 將操作添加到佇列中執行
        operationQueue.addOperation(operation)
    }
    
    // MARK: - Demo 2: 操作狀態演示
    
    /// 演示 Operation 的四種狀態：isReady, isExecuting, isFinished, isCancelled
    @objc private func operationStateDemo() {
        clearOutput()
        appendOutput("=== Operation 狀態演示 ===\n\n")
        appendOutput("Operation 有四種關鍵狀態：\n")
        appendOutput("• isReady - 準備就緒\n")
        appendOutput("• isExecuting - 執行中\n")
        appendOutput("• isFinished - 已完成\n")
        appendOutput("• isCancelled - 已取消\n\n")
        
        // 創建操作
        let operation = BlockOperation {
            Thread.sleep(forTimeInterval: 1)
        }
        
        // 在執行前檢查狀態
        appendOutput("【執行前】\n")
        logOperationState(operation)
        
        // 設置完成回調來顯示完成後的狀態
        operation.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.appendOutput("\n【執行後】\n")
                self?.logOperationState(operation)
            }
        }
        
        // 稍等一下後開始執行，讓用戶看到執行前的狀態
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.appendOutput("\n➡️ 開始執行...\n")
            self?.operationQueue.addOperation(operation)
            
            // 短暫延遲後顯示執行中的狀態
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.appendOutput("\n【執行中】\n")
                self?.logOperationState(operation)
            }
        }
    }
    
    /// 記錄並輸出 Operation 的當前狀態
    private func logOperationState(_ operation: Operation) {
        appendOutput("isReady: \(operation.isReady)\n")
        appendOutput("isExecuting: \(operation.isExecuting)\n")
        appendOutput("isFinished: \(operation.isFinished)\n")
        appendOutput("isCancelled: \(operation.isCancelled)\n")
    }
    
    // MARK: - Demo 3: 依賴關係演示
    
    /// 演示如何使用 addDependency 設置任務之間的依賴關係
    /// 依賴的任務必須在被依賴的任務完成後才能執行
    @objc private func dependencyDemo() {
        clearOutput()
        appendOutput("=== 任務依賴關係演示 ===\n\n")
        appendOutput("執行順序：下載 → 解析 → 儲存 → 更新UI\n")
        appendOutput("（每個任務都依賴前一個任務）\n\n")
        
        // 創建四個操作，模擬常見的數據處理流程
        
        // 操作 1：下載數據
        let downloadOperation = BlockOperation { [weak self] in
            self?.appendOutput("1️⃣ 下載數據開始...\n")
            Thread.sleep(forTimeInterval: 0.8)
            self?.appendOutput("1️⃣ 下載數據完成 ✓\n\n")
        }
        downloadOperation.name = "Download"
        
        // 操作 2：解析數據
        let parseOperation = BlockOperation { [weak self] in
            self?.appendOutput("2️⃣ 解析數據開始...\n")
            Thread.sleep(forTimeInterval: 0.5)
            self?.appendOutput("2️⃣ 解析數據完成 ✓\n\n")
        }
        parseOperation.name = "Parse"
        
        // 操作 3：儲存數據
        let saveOperation = BlockOperation { [weak self] in
            self?.appendOutput("3️⃣ 儲存數據開始...\n")
            Thread.sleep(forTimeInterval: 0.4)
            self?.appendOutput("3️⃣ 儲存數據完成 ✓\n\n")
        }
        saveOperation.name = "Save"
        
        // 操作 4：更新 UI（必須在主線程執行）
        let updateUIOperation = BlockOperation { [weak self] in
            DispatchQueue.main.async {
                self?.appendOutput("4️⃣ 更新 UI 完成 ✓\n\n")
                self?.appendOutput("✅ 所有任務按順序完成！\n")
            }
        }
        updateUIOperation.name = "UpdateUI"
        
        // 設置依賴關係
        // 解析依賴下載
        parseOperation.addDependency(downloadOperation)
        // 儲存依賴解析
        saveOperation.addDependency(parseOperation)
        // 更新 UI 依賴儲存
        updateUIOperation.addDependency(saveOperation)
        
        appendOutput("➡️ 開始執行任務鏈...\n\n")
        
        // 將操作添加到佇列（順序不重要，系統會根據依賴自動排序）
        operationQueue.addOperations([updateUIOperation, saveOperation, parseOperation, downloadOperation],
                                     waitUntilFinished: false)
    }
    
    // MARK: - Demo 4: 自定義 Operation
    
    /// 演示如何繼承 Operation 創建自定義的異步操作
    @objc private func customOperationDemo() {
        clearOutput()
        appendOutput("=== 自定義 Operation 演示 ===\n\n")
        appendOutput("使用自定義的 AsyncDownloadOperation\n")
        appendOutput("可以完全控制操作的生命週期\n\n")
        
        // 創建自定義操作
        let customOperation = AsyncDownloadOperation(url: "https://example.com/data")
        
        // 設置完成回調
        customOperation.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                if customOperation.isCancelled {
                    self?.appendOutput("\n❌ 操作被取消\n")
                } else {
                    self?.appendOutput("\n✅ 自定義操作完成！\n")
                    self?.appendOutput("📄 下載結果：\(customOperation.downloadedData ?? "無數據")\n")
                }
            }
        }
        
        appendOutput("➡️ 開始執行自定義操作...\n\n")
        operationQueue.addOperation(customOperation)
    }
    
    // MARK: - Demo 5: 取消操作演示
    
    /// 演示如何取消正在執行的操作
    /// 注意：取消只是設置 isCancelled 標誌，需要在代碼中主動檢查
    @objc private func cancelOperationDemo() {
        clearOutput()
        appendOutput("=== 取消操作演示 ===\n\n")
        appendOutput("⚠️ 重要：cancel() 只設置 isCancelled 標誌\n")
        appendOutput("開發者需要主動檢查並終止任務\n\n")
        
        // 創建一個會執行較長時間的操作
        let longOperation = BlockOperation()
        
        // 添加一個會定期檢查取消狀態的執行塊
        longOperation.addExecutionBlock { [weak longOperation, weak self] in
            for i in 1...10 {
                // 關鍵：定期檢查取消狀態
                if longOperation?.isCancelled == true {
                    self?.appendOutput("🛑 在第 \(i) 步檢測到取消，停止執行\n")
                    return
                }
                
                self?.appendOutput("📍 執行步驟 \(i)/10\n")
                Thread.sleep(forTimeInterval: 0.3)
            }
            self?.appendOutput("✅ 任務正常完成\n")
        }
        
        appendOutput("➡️ 開始執行長時間任務...\n")
        appendOutput("⏱ 1.5 秒後將調用 cancel()\n\n")
        
        operationQueue.addOperation(longOperation)
        
        // 1.5 秒後取消操作
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.appendOutput("\n🔴 調用 cancel()...\n\n")
            longOperation.cancel()
        }
    }
    
    // MARK: - Demo 6: KVO 監聽狀態變化
    
    /// 演示使用 KVO 監聽 Operation 的狀態變化
    @objc private func kvoDemo() {
        clearOutput()
        appendOutput("=== KVO 監聽狀態變化 ===\n\n")
        appendOutput("使用 KVO 監聽 isExecuting、isFinished 狀態\n\n")
        
        // 清除舊的觀察者
        removeAllObservers()
        
        // 創建操作
        let operation = BlockOperation { [weak self] in
            self?.appendOutput("📍 任務執行中...\n")
            Thread.sleep(forTimeInterval: 1)
        }
        
        // 添加 KVO 觀察者
        // 監聽 isExecuting 狀態
        operation.addObserver(self, forKeyPath: "isExecuting", options: [.new, .old], context: nil)
        // 監聽 isFinished 狀態
        operation.addObserver(self, forKeyPath: "isFinished", options: [.new, .old], context: nil)
        
        // 追蹤觀察的操作，以便之後移除觀察者
        observedOperations.append(operation)
        
        appendOutput("➡️ 開始執行並監聽狀態...\n\n")
        operationQueue.addOperation(operation)
    }
    
    /// KVO 回調方法，當被觀察的屬性變化時調用
    override func observeValue(forKeyPath keyPath: String?,
                              of object: Any?,
                              change: [NSKeyValueChangeKey : Any]?,
                              context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath,
              let newValue = change?[.newKey] as? Bool else { return }
        
        DispatchQueue.main.async { [weak self] in
            switch keyPath {
            case "isExecuting":
                self?.appendOutput("🔔 [KVO] isExecuting 變為: \(newValue)\n")
            case "isFinished":
                self?.appendOutput("🔔 [KVO] isFinished 變為: \(newValue)\n")
                if newValue {
                    self?.appendOutput("\n✅ 任務完成！\n")
                }
            default:
                break
            }
        }
    }
    
    /// 移除所有 KVO 觀察者
    private func removeAllObservers() {
        for operation in observedOperations {
            operation.removeObserver(self, forKeyPath: "isExecuting")
            operation.removeObserver(self, forKeyPath: "isFinished")
        }
        observedOperations.removeAll()
    }
    
    // MARK: - Demo 7: 併發數控制
    
    /// 演示如何控制 OperationQueue 的最大併發數
    @objc private func concurrencyDemo() {
        clearOutput()
        appendOutput("=== 併發數控制演示 ===\n\n")
        
        // 設置最大併發數為 2
        operationQueue.maxConcurrentOperationCount = 2
        appendOutput("📊 設置 maxConcurrentOperationCount = 2\n")
        appendOutput("將添加 5 個任務，每次最多同時執行 2 個\n\n")
        
        // 創建 5 個操作
        for i in 1...5 {
            let operation = BlockOperation { [weak self] in
                self?.appendOutput("▶️ 任務 \(i) 開始執行\n")
                Thread.sleep(forTimeInterval: 0.8)
                self?.appendOutput("⏹ 任務 \(i) 完成\n")
            }
            operation.name = "Task \(i)"
            
            operationQueue.addOperation(operation)
        }
        
        appendOutput("➡️ 5 個任務已添加到佇列\n\n")
        
        // 所有任務完成後恢復預設併發數
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.appendOutput("\n✅ 所有任務完成\n")
            self?.operationQueue.maxConcurrentOperationCount = 3
        }
    }
    
    // MARK: - Demo 8: 暫停/恢復佇列
    
    /// 演示如何暫停和恢復 OperationQueue
    @objc private func suspendResumeDemo() {
        clearOutput()
        appendOutput("=== 暫停/恢復佇列演示 ===\n\n")
        appendOutput("⚠️ isSuspended = true 只影響尚未開始的任務\n")
        appendOutput("正在執行的任務不會被暫停\n\n")
        
        // 確保佇列處於運行狀態
        operationQueue.isSuspended = false
        operationQueue.maxConcurrentOperationCount = 1  // 串行執行便於觀察
        
        // 創建 5 個操作
        for i in 1...5 {
            let operation = BlockOperation { [weak self] in
                self?.appendOutput("📍 任務 \(i) 執行中...\n")
                Thread.sleep(forTimeInterval: 0.5)
                self?.appendOutput("✓ 任務 \(i) 完成\n")
            }
            operationQueue.addOperation(operation)
        }
        
        appendOutput("➡️ 添加了 5 個任務\n")
        
        // 0.8 秒後暫停佇列
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.appendOutput("\n⏸ 暫停佇列 (isSuspended = true)\n")
            self?.appendOutput("（等待 2 秒後恢復）\n\n")
            self?.operationQueue.isSuspended = true
        }
        
        // 2.8 秒後恢復佇列
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { [weak self] in
            self?.appendOutput("\n▶️ 恢復佇列 (isSuspended = false)\n\n")
            self?.operationQueue.isSuspended = false
        }
        
        // 恢復預設併發數
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in
            self?.operationQueue.maxConcurrentOperationCount = 3
        }
    }
    
    // MARK: - Helper Methods
    
    /// 清除輸出文字
    @objc private func clearOutput() {
        DispatchQueue.main.async { [weak self] in
            self?.outputTextView.text = ""
        }
    }
    
    /// 線程安全地添加輸出文字
    /// 使用串行佇列確保多線程環境下的輸出順序正確
    private func appendOutput(_ text: String) {
        outputQueue.async { [weak self] in
            DispatchQueue.main.async {
                self?.outputTextView.text += text
                // 自動滾動到底部
                if let textView = self?.outputTextView {
                    let range = NSRange(location: max(0, textView.text.count - 1), length: 1)
                    textView.scrollRangeToVisible(range)
                }
            }
        }
    }
}

// MARK: - 自定義異步 Operation

/// 自定義的異步下載操作類
/// 展示如何完整實現一個支持取消和狀態管理的異步 Operation
class AsyncDownloadOperation: Operation {
    
    // MARK: - Properties
    
    /// 下載的 URL 字串
    private let urlString: String
    
    /// 下載完成後的數據
    private(set) var downloadedData: String?
    
    /// 追蹤執行狀態
    /// 使用 _isExecuting 是因為 Operation 的 isExecuting 是 read-only
    private var _isExecuting = false
    
    /// 追蹤完成狀態
    private var _isFinished = false
    
    // MARK: - Initialization
    
    /// 初始化方法
    /// - Parameter url: 要下載的 URL 字串
    init(url: String) {
        self.urlString = url
        super.init()
    }
    
    // MARK: - Override Properties
    
    /// 覆寫 isExecuting 屬性
    /// 必須支持 KVO 通知
    override var isExecuting: Bool {
        return _isExecuting
    }
    
    /// 覆寫 isFinished 屬性
    /// 必須支持 KVO 通知
    override var isFinished: Bool {
        return _isFinished
    }
    
    /// 標記為異步操作
    /// 返回 true 表示我們會自己管理執行狀態
    override var isAsynchronous: Bool {
        return true
    }
    
    // MARK: - Main Methods
    
    /// 開始執行操作
    /// 這是異步操作的入口點，需要手動管理狀態
    override func start() {
        // 在開始前檢查是否已被取消
        if isCancelled {
            finish()
            return
        }
        
        // 發送 KVO 通知：isExecuting 即將變化
        willChangeValue(forKey: "isExecuting")
        _isExecuting = true
        didChangeValue(forKey: "isExecuting")
        
        // 執行實際的任務
        performDownload()
    }
    
    /// 執行下載任務（模擬）
    private func performDownload() {
        print("AsyncDownloadOperation: 開始下載 \(urlString)")
        
        // 模擬異步下載過程
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // 模擬下載過程中的多個步驟
            for step in 1...5 {
                // 定期檢查取消狀態
                // 這是響應取消請求的關鍵點
                if self.isCancelled {
                    print("AsyncDownloadOperation: 在步驟 \(step) 被取消")
                    self.finish()
                    return
                }
                
                // 模擬網絡延遲
                Thread.sleep(forTimeInterval: 0.3)
                print("AsyncDownloadOperation: 下載進度 \(step * 20)%")
            }
            
            // 下載完成，設置結果
            self.downloadedData = "模擬下載的數據內容（URL: \(self.urlString)）"
            
            // 完成操作
            self.finish()
        }
    }
    
    /// 完成操作並更新狀態
    /// 必須正確發送 KVO 通知，否則 OperationQueue 不會知道操作已完成
    private func finish() {
        // 發送 KVO 通知：isExecuting 和 isFinished 即將變化
        willChangeValue(forKey: "isExecuting")
        willChangeValue(forKey: "isFinished")
        
        _isExecuting = false
        _isFinished = true
        
        // 發送 KVO 通知：屬性已經變化
        didChangeValue(forKey: "isExecuting")
        didChangeValue(forKey: "isFinished")
    }
}

// MARK: - 面試重點總結

/*
 =============================================
 NSOperation 面試常見問題
 =============================================
 
 Q1: NSOperation 是什麼？
 A1: NSOperation 是 Apple 提供的抽象類，用於封裝任務的代碼和數據。
     它是建立在 GCD 之上的更高層級抽象，提供更多的控制功能。
 
 Q2: NSOperation 有哪些狀態？
 A2: 四種關鍵狀態：
     - isReady: 準備就緒，可以開始執行
     - isExecuting: 正在執行中
     - isFinished: 已完成（必須設置，否則會記憶體洩漏）
     - isCancelled: 已被請求取消
 
 Q3: 調用 cancel() 會立即停止任務嗎？
 A3: 不會！cancel() 只是將 isCancelled 設為 true。
     開發者必須在代碼中主動檢查 isCancelled 並終止任務。
 
 Q4: 如何使用 NSOperation？
 A4: 三種方式：
     1. BlockOperation - 使用閉包，最簡單
     2. 繼承 Operation - 完全控制，需手動管理狀態
     3. 設置依賴關係 - 控制任務執行順序
 
 Q5: NSOperation 和 GCD 的區別？
 A5:
     | 特性       | NSOperation | GCD |
     |-----------|-------------|-----|
     | 任務取消   | ✅ 支持     | ❌   |
     | 依賴關係   | ✅ 支持     | ⚠️   |
     | KVO 監聽   | ✅ 支持     | ❌   |
     | 併發控制   | ✅ 簡單     | ⚠️   |
 
 Q6: 什麼時候用 NSOperation？
 A6: 需要以下功能時選擇 NSOperation：
     - 取消正在執行的任務
     - 設置任務之間的依賴關係
     - 監聽任務狀態變化
     - 複雜的任務調度和管理
 
 Q7: 自定義 Operation 需要注意什麼？
 A7:
     - 必須正確實現 isExecuting、isFinished 屬性
     - 必須發送 KVO 通知（willChangeValue/didChangeValue）
     - 必須在任務結束時將 isFinished 設為 true
     - 應該定期檢查 isCancelled 以響應取消請求
 
 =============================================
 */

