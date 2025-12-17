//
//  SynchronizedSingletonDemoViewController.swift
//  InterviewDemoProject
//
//  Created by MarsChang on 2025/12/17.
//

import UIKit

// MARK: - @synchronized 單例模式演示
/// 本檔案演示如何使用 @synchronized（及其 Swift 等效方式）來保證單例模式下創建對象的唯一性
///
/// 核心概念：
/// - @synchronized 是 Objective-C 中的互斥鎖語法糖
/// - Swift 中沒有 @synchronized 關鍵字，但可以使用 objc_sync_enter/objc_sync_exit
/// - Swift 推薦使用 static let，因為它本身就是線程安全的（dispatch_once 語義）

// MARK: - 方式一：Objective-C 風格的 @synchronized（在 Swift 中的實現）

/// 模擬 Objective-C 的 @synchronized 功能
/// 使用 objc_sync_enter 和 objc_sync_exit 來實現互斥鎖
///
/// - Parameters:
///   - lock: 用作鎖的對象（通常是 self 或類對象）
///   - closure: 需要同步執行的閉包
/// - Returns: 閉包的返回值
///
/// 原理：
/// 1. objc_sync_enter(lock) - 獲取與 lock 對象關聯的互斥鎖
/// 2. 執行 closure 中的代碼（臨界區）
/// 3. objc_sync_exit(lock) - 釋放鎖
/// 4. defer 確保無論是否發生異常，鎖都會被釋放
@inline(__always)
func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
    // 獲取鎖 - 如果鎖已被其他線程持有，當前線程會阻塞等待
    objc_sync_enter(lock)
    // defer 確保在函數返回前一定會釋放鎖，即使 closure 拋出異常
    defer { objc_sync_exit(lock) }
    // 執行臨界區代碼
    return try closure()
}

// MARK: - 方式二：使用 @synchronized 實現的單例（模擬 Objective-C 寫法）

/// 使用 objc_sync_enter/exit 實現的單例類
/// 這是模擬 Objective-C 中使用 @synchronized 的寫法
///
/// Objective-C 原始寫法：
/// ```objc
/// + (instancetype)sharedInstance {
///     static MyClass *instance = nil;
///     @synchronized (self) {
///         if (instance == nil) {
///             instance = [[MyClass alloc] init];
///         }
///     }
///     return instance;
/// }
/// ```
class ObjCSynchronizedSingleton {
    
    /// 存儲單例實例的靜態變量
    /// 使用 nonisolated(unsafe) 標記來允許跨隔離邊界訪問
    /// 注意：這是為了演示 @synchronized 的用法，實際上 Swift 有更好的方式
    nonisolated(unsafe) private static var _instance: ObjCSynchronizedSingleton?
    
    /// 唯一標識符，用於驗證是否為同一個實例
    let identifier: String
    
    /// 創建時間戳，用於調試
    let createdAt: Date
    
    /// 私有初始化方法，防止外部直接創建實例
    private init() {
        self.identifier = UUID().uuidString
        self.createdAt = Date()
        print("🔵 ObjCSynchronizedSingleton 被創建 - ID: \(identifier)")
    }
    
    /// 獲取單例實例的類方法
    /// 使用 @synchronized（objc_sync_enter/exit）確保線程安全
    ///
    /// 工作原理：
    /// 1. 第一個線程進入時，_instance 為 nil，創建實例
    /// 2. 其他線程如果同時嘗試訪問，會被 synchronized 阻塞
    /// 3. 當第一個線程完成創建後，_instance 不再為 nil
    /// 4. 後續線程直接返回已創建的實例
    ///
    /// - Returns: 單例實例
    static func sharedInstance() -> ObjCSynchronizedSingleton {
        // 使用 synchronized 函數來實現 @synchronized 的效果
        // 傳入 self（類對象）作為鎖
        synchronized(self) {
            // 雙重檢查：如果實例為空才創建
            if _instance == nil {
                // 模擬耗時操作，讓多線程競爭更明顯
                Thread.sleep(forTimeInterval: 0.1)
                _instance = ObjCSynchronizedSingleton()
            }
            return _instance!
        }
    }
    
    /// 重置單例（僅供測試用）
    static func reset() {
        synchronized(self) {
            _instance = nil
            print("🔄 ObjCSynchronizedSingleton 已重置")
        }
    }
}

// MARK: - 方式三：Swift 推薦的單例寫法（dispatch_once 語義）

/// Swift 推薦的單例實現方式
/// 使用 static let，因為 Swift 保證 static let 是線程安全的
///
/// 原理：
/// - Swift 的 static let 使用 dispatch_once 語義
/// - 系統會自動處理線程同步
/// - 懶加載：只有在首次訪問時才會創建實例
/// - 這是 Swift 中最簡潔、最安全的單例實現方式
class SwiftSingleton {
    
    /// 唯一標識符
    let identifier: String
    
    /// 創建時間戳
    let createdAt: Date
    
    /// 共享實例 - Swift 保證這是線程安全的
    /// static let 只會被初始化一次，且是線程安全的
    static let shared = SwiftSingleton()
    
    /// 私有初始化方法
    private init() {
        self.identifier = UUID().uuidString
        self.createdAt = Date()
        print("🟢 SwiftSingleton 被創建 - ID: \(identifier)")
    }
}

// MARK: - 方式四：使用 NSLock 實現的單例

/// 使用 NSLock 實現的單例類
/// 這是另一種線程安全的單例實現方式
class NSLockSingleton {
    
    /// 用於同步的鎖
    nonisolated(unsafe) private static let lock = NSLock()
    
    /// 存儲單例實例
    nonisolated(unsafe) private static var _instance: NSLockSingleton?
    
    /// 唯一標識符
    let identifier: String
    
    /// 創建時間戳
    let createdAt: Date
    
    /// 私有初始化方法
    private init() {
        self.identifier = UUID().uuidString
        self.createdAt = Date()
        print("🟡 NSLockSingleton 被創建 - ID: \(identifier)")
    }
    
    /// 獲取單例實例
    /// 使用 NSLock 確保線程安全
    static func sharedInstance() -> NSLockSingleton {
        // 獲取鎖
        lock.lock()
        // 確保鎖會被釋放
        defer { lock.unlock() }
        
        if _instance == nil {
            Thread.sleep(forTimeInterval: 0.1)
            _instance = NSLockSingleton()
        }
        return _instance!
    }
    
    /// 重置單例（僅供測試用）
    static func reset() {
        lock.lock()
        defer { lock.unlock() }
        _instance = nil
        print("🔄 NSLockSingleton 已重置")
    }
}

// MARK: - 方式五：不安全的單例（用於對比演示）

/// 不安全的單例實現 - 沒有任何線程同步機制
/// ⚠️ 警告：這是錯誤的寫法，僅用於演示問題
class UnsafeSingleton {
    
    /// 存儲單例實例（沒有任何保護）
    nonisolated(unsafe) private static var _instance: UnsafeSingleton?
    
    /// 唯一標識符
    let identifier: String
    
    /// 創建時間戳
    let createdAt: Date
    
    /// 記錄創建次數
    nonisolated(unsafe) private static var creationCount = 0
    
    /// 私有初始化方法
    private init() {
        UnsafeSingleton.creationCount += 1
        self.identifier = UUID().uuidString
        self.createdAt = Date()
        print("🔴 UnsafeSingleton 被創建第 \(UnsafeSingleton.creationCount) 次 - ID: \(identifier)")
    }
    
    /// 獲取單例實例
    /// ⚠️ 這個方法不是線程安全的！
    /// 多個線程可能同時進入 if 判斷，導致創建多個實例
    static func sharedInstance() -> UnsafeSingleton {
        if _instance == nil {
            // 模擬耗時操作，讓問題更容易出現
            Thread.sleep(forTimeInterval: 0.1)
            _instance = UnsafeSingleton()
        }
        return _instance!
    }
    
    /// 重置單例（僅供測試用）
    static func reset() {
        _instance = nil
        creationCount = 0
        print("🔄 UnsafeSingleton 已重置")
    }
    
    /// 獲取創建次數
    static var totalCreations: Int {
        return creationCount
    }
}

// MARK: - 演示視圖控制器

class SynchronizedSingletonDemoViewController: UIViewController {
    
    // MARK: - UI 元件
    
    /// 結果顯示文本視圖
    private let resultTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    /// 按鈕堆疊視圖
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - 生命週期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 初始顯示說明
        appendResult("""
        === @synchronized 單例模式演示 ===
        
        本演示展示如何使用 @synchronized（及其 Swift 等效方式）
        來保證單例模式下創建對象的唯一性。
        
        點擊按鈕開始測試各種實現方式...
        
        """)
    }
    
    // MARK: - UI 設置
    
    private func setupUI() {
        title = "@synchronized 單例"
        view.backgroundColor = .systemBackground
        
        // 創建按鈕
        let buttons = [
            ("1. 測試 @synchronized 單例", #selector(testObjCSynchronized)),
            ("2. 測試 Swift 推薦單例", #selector(testSwiftSingleton)),
            ("3. 測試 NSLock 單例", #selector(testNSLockSingleton)),
            ("4. 測試不安全單例（會出問題）", #selector(testUnsafeSingleton)),
            ("5. 對比所有方式", #selector(compareAll)),
            ("清除結果", #selector(clearResults))
        ]
        
        for (title, action) in buttons {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.addTarget(self, action: action, for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
        
        view.addSubview(buttonStackView)
        view.addSubview(resultTextView)
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            resultTextView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 16),
            resultTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resultTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - 測試方法
    
    /// 測試 @synchronized 風格的單例
    @objc private func testObjCSynchronized() {
        appendResult("\n--- 測試 @synchronized 單例 ---\n")
        ObjCSynchronizedSingleton.reset()
        
        testSingletonConcurrently(name: "@synchronized") {
            return ObjCSynchronizedSingleton.sharedInstance().identifier
        }
    }
    
    /// 測試 Swift 推薦的單例
    @objc private func testSwiftSingleton() {
        appendResult("\n--- 測試 Swift 推薦單例 ---\n")
        appendResult("注意：Swift static let 無法重置，所以只能測試一次\n")
        
        testSingletonConcurrently(name: "Swift static let") {
            return SwiftSingleton.shared.identifier
        }
    }
    
    /// 測試 NSLock 單例
    @objc private func testNSLockSingleton() {
        appendResult("\n--- 測試 NSLock 單例 ---\n")
        NSLockSingleton.reset()
        
        testSingletonConcurrently(name: "NSLock") {
            return NSLockSingleton.sharedInstance().identifier
        }
    }
    
    /// 測試不安全的單例
    @objc private func testUnsafeSingleton() {
        appendResult("\n--- 測試不安全單例 ---\n")
        appendResult("⚠️ 這個測試可能會創建多個實例！\n")
        UnsafeSingleton.reset()
        
        testSingletonConcurrently(name: "Unsafe") {
            return UnsafeSingleton.sharedInstance().identifier
        } completion: { [weak self] in
            let count = UnsafeSingleton.totalCreations
            self?.appendResult("🔴 總共創建了 \(count) 次實例（應該只有 1 次）\n")
        }
    }
    
    /// 對比所有方式
    @objc private func compareAll() {
        appendResult("""
        
        ========================================
        === 對比所有單例實現方式 ===
        ========================================
        
        """)
        
        // 依次測試所有方式
        testObjCSynchronized()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.testNSLockSingleton()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            self?.testUnsafeSingleton()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in
            self?.appendResult("""
            
            ========================================
            === 總結 ===
            
            ✅ @synchronized：線程安全，適用於 ObjC 兼容
            ✅ Swift static let：最簡潔，推薦使用
            ✅ NSLock：線程安全，明確的鎖控制
            ❌ 無保護：會創建多個實例，不安全
            ========================================
            
            """)
        }
    }
    
    /// 清除結果
    @objc private func clearResults() {
        resultTextView.text = ""
    }
    
    // MARK: - 輔助方法
    
    /// 並發測試單例
    /// - Parameters:
    ///   - name: 測試名稱
    ///   - getInstance: 獲取實例的閉包
    ///   - completion: 完成回調
    private func testSingletonConcurrently(
        name: String,
        getInstance: @escaping () -> String,
        completion: (() -> Void)? = nil
    ) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        
        var identifiers: [String] = []
        let lock = NSLock()
        
        // 同時從 10 個線程獲取單例
        for i in 1...10 {
            group.enter()
            queue.async {
                let id = getInstance()
                
                lock.lock()
                identifiers.append(id)
                lock.unlock()
                
                DispatchQueue.main.async { [weak self] in
                    self?.appendResult("線程 \(i) 獲取實例: \(id.prefix(8))...\n")
                }
                
                group.leave()
            }
        }
        
        // 所有線程完成後檢查結果
        group.notify(queue: .main) { [weak self] in
            let uniqueIds = Set(identifiers)
            let isSuccess = uniqueIds.count == 1
            
            self?.appendResult("""
            
            === \(name) 測試結果 ===
            唯一 ID 數量: \(uniqueIds.count)
            結果: \(isSuccess ? "✅ 成功！只創建了一個實例" : "❌ 失敗！創建了多個實例")
            
            """)
            
            completion?()
        }
    }
    
    /// 添加結果到文本視圖
    private func appendResult(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.resultTextView.text += text
            
            // 自動滾動到底部
            if let textView = self?.resultTextView {
                let bottom = NSMakeRange(textView.text.count - 1, 1)
                textView.scrollRangeToVisible(bottom)
            }
        }
    }
}

// MARK: - @synchronized 原理說明

/*
 ┌─────────────────────────────────────────────────────────────────────────────┐
 │                    @synchronized 在單例模式中的應用原理                       │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │                                                                             │
 │  1. 問題背景：                                                               │
 │     在多線程環境下創建單例，如果沒有同步機制，可能會創建多個實例                   │
 │                                                                             │
 │  2. @synchronized 的作用：                                                   │
 │     確保同一時間只有一個線程可以執行被保護的代碼塊                               │
 │                                                                             │
 │  3. 工作流程：                                                               │
 │     ┌─────────────────────────────────────────────────────────┐            │
 │     │  Thread 1        Thread 2         Thread 3              │            │
 │     │     │               │                │                  │            │
 │     │     ▼               ▼                ▼                  │            │
 │     │  [進入 synchronized] [等待...]       [等待...]           │            │
 │     │     │                                                   │            │
 │     │     ▼                                                   │            │
 │     │  [檢查 instance == nil]                                 │            │
 │     │     │                                                   │            │
 │     │     ▼                                                   │            │
 │     │  [創建實例]                                              │            │
 │     │     │                                                   │            │
 │     │     ▼                                                   │            │
 │     │  [退出 synchronized]                                    │            │
 │     │                 │                │                      │            │
 │     │                 ▼                │                      │            │
 │     │           [進入 synchronized]    [等待...]              │            │
 │     │                 │                                       │            │
 │     │                 ▼                                       │            │
 │     │           [檢查 instance != nil]                        │            │
 │     │                 │                                       │            │
 │     │                 ▼                                       │            │
 │     │           [直接返回已有實例]                              │            │
 │     │                 │                                       │            │
 │     │                 ▼                                       │            │
 │     │           [退出 synchronized]                           │            │
 │     │                             │                           │            │
 │     │                             ▼                           │            │
 │     │                       [Thread 3 同理]                   │            │
 │     └─────────────────────────────────────────────────────────┘            │
 │                                                                             │
 │  4. Swift 中的實現方式對比：                                                  │
 │                                                                             │
 │     ┌────────────────────┬────────────────────────────────────────────┐    │
 │     │ 方式               │ 說明                                       │    │
 │     ├────────────────────┼────────────────────────────────────────────┤    │
 │     │ objc_sync_enter/   │ 底層 C 函數，@synchronized 的實際實現       │    │
 │     │ objc_sync_exit     │                                            │    │
 │     ├────────────────────┼────────────────────────────────────────────┤    │
 │     │ NSLock             │ Foundation 框架的鎖，更明確的控制           │    │
 │     ├────────────────────┼────────────────────────────────────────────┤    │
 │     │ DispatchQueue      │ GCD 方式，使用串行隊列保證同步              │    │
 │     │ (serial)           │                                            │    │
 │     ├────────────────────┼────────────────────────────────────────────┤    │
 │     │ static let         │ Swift 推薦方式，自動線程安全                │    │
 │     │                    │ 底層使用 dispatch_once                     │    │
 │     └────────────────────┴────────────────────────────────────────────┘    │
 │                                                                             │
 │  5. 最佳實踐：                                                               │
 │     - Swift 項目：優先使用 static let shared = MyClass()                    │
 │     - ObjC 兼容：使用 objc_sync_enter/exit 模擬 @synchronized              │
 │     - 需要額外控制：使用 NSLock 或 DispatchQueue                            │
 │                                                                             │
 └─────────────────────────────────────────────────────────────────────────────┘
 */

