# NSOperation 是什麼，如何使用，它有哪些狀態

## 一、NSOperation 是什麼

**NSOperation**（在 Swift 中稱為 `Operation`）是 Apple 提供的一個**抽象類**，用於封裝任務的代碼和數據。它是建立在 GCD (Grand Central Dispatch) 之上的更高層級抽象，提供了更多的控制功能。

### 核心概念

```
┌─────────────────────────────────────────────────────────────┐
│                    NSOperation 架構                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌──────────────────┐    ┌──────────────────────────────┐ │
│   │   Operation      │    │     OperationQueue           │ │
│   │   (任務單元)      │───>│     (任務佇列)                │ │
│   └──────────────────┘    └──────────────────────────────┘ │
│            │                          │                     │
│            │                          │                     │
│            ▼                          ▼                     │
│   ┌──────────────────┐    ┌──────────────────────────────┐ │
│   │ - isReady        │    │ - maxConcurrentOperationCount │ │
│   │ - isExecuting    │    │ - qualityOfService           │ │
│   │ - isFinished     │    │ - isSuspended                │ │
│   │ - isCancelled    │    │ - addOperation()             │ │
│   │ - dependencies   │    │ - cancelAllOperations()      │ │
│   └──────────────────┘    └──────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### NSOperation vs GCD

| 特性 | NSOperation | GCD |
|------|-------------|-----|
| 抽象層級 | 高層 | 底層 |
| 任務取消 | ✅ 支持 | ❌ 不支持 |
| 依賴關係 | ✅ 支持 | ⚠️ 需手動實現 |
| KVO 監聽 | ✅ 支持 | ❌ 不支持 |
| 任務優先級 | ✅ 支持 | ✅ 支持 |
| 最大併發數控制 | ✅ 簡單設置 | ⚠️ 需使用信號量 |
| 適用場景 | 複雜任務管理 | 簡單任務調度 |

---

## 二、NSOperation 的狀態

NSOperation 有四個關鍵狀態，由四個布林屬性表示：

### 狀態屬性

```
┌─────────────────────────────────────────────────────────────┐
│                   Operation 狀態流程圖                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│     ┌───────────┐                                           │
│     │  isReady  │ ─── 準備就緒，等待執行                      │
│     │   = true  │                                           │
│     └─────┬─────┘                                           │
│           │                                                 │
│           ▼                                                 │
│     ┌─────────────┐                                         │
│     │ isExecuting │ ─── 正在執行中                           │
│     │   = true    │                                         │
│     └──────┬──────┘                                         │
│            │                                                │
│      ┌─────┴─────┐                                          │
│      ▼           ▼                                          │
│ ┌──────────┐ ┌────────────┐                                 │
│ │isFinished│ │isCancelled │                                 │
│ │  = true  │ │   = true   │                                 │
│ └──────────┘ └────────────┘                                 │
│   正常完成      被取消                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1. isReady（準備就緒）
- **含義**：Operation 已準備好可以執行
- **預設行為**：當所有依賴都已完成時，變為 `true`
- **注意**：系統會在 isReady 變為 true 時自動將任務加入執行

### 2. isExecuting（執行中）
- **含義**：Operation 正在執行任務
- **狀態轉換**：從 `isReady = true` 轉換而來
- **注意**：自定義 Operation 需要手動管理此狀態

### 3. isFinished（已完成）
- **含義**：Operation 已完成執行（成功或失敗）
- **重要性**：OperationQueue 依賴此屬性來移除已完成的任務
- **注意**：必須在任務結束時將此設為 `true`，否則會導致記憶體洩漏

### 4. isCancelled（已取消）
- **含義**：Operation 已被請求取消
- **重要**：調用 `cancel()` 只會設置此標誌，不會自動停止任務
- **責任**：開發者需要在代碼中檢查此標誌並適當終止任務

### 狀態轉換規則

```swift
// 狀態轉換是單向的，不可逆
isReady → isExecuting → isFinished
            ↓
       isCancelled (可在任何時候發生)
```

---

## 三、如何使用 NSOperation

### 方式一：BlockOperation（最簡單）

```swift
// 創建 BlockOperation
let operation = BlockOperation {
    // 執行任務
    print("執行任務")
}

// 可以添加多個執行塊
operation.addExecutionBlock {
    print("額外的任務")
}

// 設置完成回調
operation.completionBlock = {
    print("任務完成")
}

// 添加到佇列執行
let queue = OperationQueue()
queue.addOperation(operation)
```

### 方式二：繼承 Operation（自定義控制）

```swift
class DownloadOperation: Operation {
    private var _isExecuting = false
    private var _isFinished = false
    
    override var isExecuting: Bool {
        return _isExecuting
    }
    
    override var isFinished: Bool {
        return _isFinished
    }
    
    override var isAsynchronous: Bool {
        return true  // 標記為異步操作
    }
    
    override func start() {
        // 檢查是否已取消
        if isCancelled {
            finish()
            return
        }
        
        // 更新狀態為執行中
        willChangeValue(forKey: "isExecuting")
        _isExecuting = true
        didChangeValue(forKey: "isExecuting")
        
        // 執行實際任務
        performTask()
    }
    
    private func performTask() {
        // 執行耗時操作...
        
        // 定期檢查取消狀態
        if isCancelled {
            finish()
            return
        }
        
        // 任務完成
        finish()
    }
    
    private func finish() {
        willChangeValue(forKey: "isExecuting")
        willChangeValue(forKey: "isFinished")
        _isExecuting = false
        _isFinished = true
        didChangeValue(forKey: "isExecuting")
        didChangeValue(forKey: "isFinished")
    }
}
```

### 方式三：使用依賴關係

```swift
let queue = OperationQueue()

let op1 = BlockOperation {
    print("下載數據")
}

let op2 = BlockOperation {
    print("解析數據")
}

let op3 = BlockOperation {
    print("更新 UI")
}

// 設置依賴：op2 依賴 op1，op3 依賴 op2
op2.addDependency(op1)  // op1 完成後才執行 op2
op3.addDependency(op2)  // op2 完成後才執行 op3

// 添加到佇列（順序不重要，系統會根據依賴自動排序）
queue.addOperations([op3, op1, op2], waitUntilFinished: false)

// 執行順序：op1 → op2 → op3
```

---

## 四、OperationQueue 配置

### 常用屬性

```swift
let queue = OperationQueue()

// 1. 設置最大併發數
queue.maxConcurrentOperationCount = 3  // 最多同時執行 3 個任務
queue.maxConcurrentOperationCount = 1  // 變成串行隊列

// 2. 設置服務質量（優先級）
queue.qualityOfService = .userInitiated  // 高優先級

// 3. 暫停/恢復佇列
queue.isSuspended = true   // 暫停執行新任務
queue.isSuspended = false  // 恢復執行

// 4. 取消所有任務
queue.cancelAllOperations()

// 5. 等待所有任務完成
queue.waitUntilAllOperationsAreFinished()

// 6. 獲取當前任務數量
let count = queue.operationCount
```

### QualityOfService 優先級

```
從高到低：
.userInteractive  → UI 相關，最高優先級
.userInitiated    → 用戶主動請求，高優先級
.default          → 預設
.utility          → 長時間任務，低優先級
.background       → 後台任務，最低優先級
```

---

## 五、使用 KVO 監聽狀態

```swift
class MyViewController: UIViewController {
    var operation: Operation?
    
    func startOperation() {
        operation = BlockOperation {
            // 執行任務
        }
        
        // 監聽狀態變化
        operation?.addObserver(self, forKeyPath: "isFinished", options: .new, context: nil)
        operation?.addObserver(self, forKeyPath: "isCancelled", options: .new, context: nil)
        
        OperationQueue().addOperation(operation!)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                              of object: Any?,
                              change: [NSKeyValueChangeKey : Any]?,
                              context: UnsafeMutableRawPointer?) {
        if keyPath == "isFinished" {
            print("任務完成")
        } else if keyPath == "isCancelled" {
            print("任務被取消")
        }
    }
    
    deinit {
        operation?.removeObserver(self, forKeyPath: "isFinished")
        operation?.removeObserver(self, forKeyPath: "isCancelled")
    }
}
```

---

## 六、面試常見問題

### Q1: NSOperation 和 GCD 的區別？
**A:** NSOperation 是基於 GCD 的高層封裝，提供任務取消、依賴關係、KVO 監聽等功能。GCD 更輕量，適合簡單任務；NSOperation 適合需要複雜任務管理的場景。

### Q2: 調用 cancel() 會立即停止任務嗎？
**A:** 不會。`cancel()` 只是將 `isCancelled` 屬性設為 `true`，開發者必須在代碼中主動檢查此屬性並終止任務。

### Q3: isFinished 為什麼重要？
**A:** OperationQueue 依賴 `isFinished` 來判斷任務是否完成並釋放資源。如果不正確設置，會導致任務永不從佇列移除，造成記憶體洩漏。

### Q4: 如何實現任務的串行執行？
**A:** 設置 `operationQueue.maxConcurrentOperationCount = 1`

### Q5: NSOperation 的狀態可以回退嗎？
**A:** 不可以。狀態轉換是單向的：Ready → Executing → Finished，一旦轉換就不能回退。

---

## 七、總結

| 要點 | 說明 |
|------|------|
| 定義 | 封裝任務代碼和數據的抽象類 |
| 四種狀態 | isReady、isExecuting、isFinished、isCancelled |
| 使用方式 | BlockOperation、繼承 Operation、依賴關係 |
| 優勢 | 支持取消、依賴、KVO、併發控制 |
| 適用場景 | 複雜任務管理、需要取消支持、任務有先後順序 |

