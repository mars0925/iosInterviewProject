# iOS 多線程開發

## 什麼是多線程？

多線程（Multithreading）是指在一個程序中同時執行多個線程（Thread）的技術。每個線程可以獨立執行不同的任務，從而提高程序的效率和響應性。

## 為什麼需要多線程？

1. **提高響應性**：將耗時任務放到後台線程執行，避免阻塞主線程（UI 線程）
2. **提高效率**：充分利用多核 CPU 的計算能力
3. **改善用戶體驗**：確保 UI 流暢，不會因為耗時操作而卡頓

## iOS 中的主線程與後台線程

### 主線程（Main Thread）
- 負責處理 UI 更新和用戶交互
- 所有 UI 操作必須在主線程執行
- 不應該執行耗時操作，否則會導致界面卡頓

### 後台線程（Background Thread）
- 用於執行耗時操作（網絡請求、檔案讀寫、圖片處理等）
- 可以有多個後台線程同時運行
- 完成後需要回到主線程更新 UI

---

## iOS 中實現多線程的方法

iOS 提供了多種實現多線程的方式，從底層到高層抽象依次為：

### 1. pthread（POSIX Thread）

**層級**：最底層的 C 語言多線程 API

**特點**：
- 跨平台（POSIX 標準）
- 需要手動管理線程生命週期
- 使用複雜，很少在實際開發中直接使用

```swift
import Darwin

var thread: pthread_t?
pthread_create(&thread, nil, { _ in
    print("pthread running")
    return nil
}, nil)
```

**適用場景**：極少使用，通常只在需要跨平台 C 代碼時考慮

---

### 2. NSThread

**層級**：Objective-C 對 pthread 的封裝

**特點**：
- 面向對象的線程封裝
- 需要手動管理線程生命週期
- 需要自己處理線程同步

**創建方式**：

```swift
// 方式一：類方法創建並自動啟動
Thread.detachNewThread {
    print("Thread running")
}

// 方式二：實例化後手動啟動
let thread = Thread {
    print("Thread running")
}
thread.start()

// 方式三：使用 Selector
let thread = Thread(target: self, selector: #selector(threadMethod), object: nil)
thread.start()
```

**優點**：
- 可以直接控制線程屬性（優先級、名稱等）
- 適合簡單的單獨線程任務

**缺點**：
- 需要手動管理線程生命週期
- 無法自動管理線程池
- 線程間通信較為複雜

**適用場景**：簡單的單獨後台任務，或需要精細控制線程時

---

### 3. GCD（Grand Central Dispatch）

**層級**：Apple 提供的高效多線程解決方案

**特點**：
- 基於 C 語言的底層 API，性能優異
- 自動管理線程池
- 基於「隊列」的任務管理
- Apple 官方推薦的多線程方案

**核心概念**：

| 概念 | 說明 |
|-----|------|
| Serial Queue | 串行隊列，一次執行一個任務 |
| Concurrent Queue | 併發隊列，可同時執行多個任務 |
| Main Queue | 主隊列，在主線程執行 |
| sync | 同步執行，阻塞當前線程 |
| async | 異步執行，不阻塞當前線程 |

**基本使用**：

```swift
// 後台執行任務
DispatchQueue.global().async {
    // 耗時操作
    
    // 回到主線程更新 UI
    DispatchQueue.main.async {
        // 更新 UI
    }
}

// 創建自定義隊列
let serialQueue = DispatchQueue(label: "com.app.serial")
let concurrentQueue = DispatchQueue(label: "com.app.concurrent", attributes: .concurrent)
```

**優點**：
- 自動管理線程，無需手動創建和銷毀
- API 簡潔易用
- 性能優秀
- 提供豐富的功能（Group、Barrier、Semaphore 等）

**缺點**：
- 任務一旦加入隊列就無法取消
- 任務之間的依賴關係處理較複雜

**適用場景**：大多數多線程場景的首選

---

### 4. Operation / OperationQueue

**層級**：基於 GCD 的高級抽象（Objective-C: NSOperation / NSOperationQueue）

**特點**：
- 面向對象的任務封裝
- 支持任務依賴、取消、優先級
- 可以控制最大併發數
- 可以監聽任務狀態（KVO）

**基本使用**：

```swift
// 創建 BlockOperation
let operation = BlockOperation {
    print("Task 1")
}
operation.addExecutionBlock {
    print("Task 2")
}

// 創建隊列並添加操作
let queue = OperationQueue()
queue.maxConcurrentOperationCount = 2  // 限制最大併發數
queue.addOperation(operation)

// 設置依賴關係
let op1 = BlockOperation { print("Op 1") }
let op2 = BlockOperation { print("Op 2") }
op2.addDependency(op1)  // op2 會等待 op1 完成

queue.addOperations([op1, op2], waitUntilFinished: false)
```

**自定義 Operation**：

```swift
class MyOperation: Operation {
    override func main() {
        if isCancelled { return }
        // 執行任務
    }
}
```

**優點**：
- 支持任務取消
- 支持任務依賴關係
- 可以設置優先級
- 可以使用 KVO 監聽狀態
- 可以控制最大併發數

**缺點**：
- 相比 GCD 稍有性能開銷
- API 相對較多

**適用場景**：
- 需要取消任務的場景
- 需要任務依賴的場景
- 需要精細控制併發數的場景

---

### 5. Swift Concurrency（async/await）

**層級**：Swift 5.5 引入的現代並發模型

**特點**：
- 語法簡潔，可讀性強
- 編譯期安全檢查
- 結構化並發
- 內建 Actor 隔離

**基本使用**：

```swift
// 異步函數
func fetchData() async throws -> Data {
    let url = URL(string: "https://api.example.com/data")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}

// 調用異步函數
Task {
    do {
        let data = try await fetchData()
        // 處理數據
    } catch {
        // 錯誤處理
    }
}

// 並行執行多個任務
async let result1 = fetchData1()
async let result2 = fetchData2()
let results = try await (result1, result2)

// TaskGroup 處理動態數量的併發任務
let results = await withTaskGroup(of: Int.self) { group in
    for i in 1...10 {
        group.addTask { await processItem(i) }
    }
    return await group.reduce(into: [Int]()) { $0.append($1) }
}
```

**Actor（避免數據競爭）**：

```swift
actor Counter {
    private var value = 0
    
    func increment() {
        value += 1
    }
    
    func getValue() -> Int {
        return value
    }
}
```

**優點**：
- 語法簡潔，避免回調地獄
- 編譯期檢查數據競爭
- 自動處理線程切換
- 與 Swift 類型系統深度整合

**缺點**：
- 需要 iOS 13+（完整功能需要 iOS 15+）
- 學習曲線較陡
- 與舊代碼整合需要適配

**適用場景**：新項目的首選，特別是網絡請求、檔案操作等異步場景

---

## 五種方法的比較

| 特性 | pthread | NSThread | GCD | Operation | async/await |
|-----|---------|----------|-----|-----------|-------------|
| 層級 | 底層 | 中層 | 中層 | 高層 | 高層 |
| 語言 | C | OC/Swift | C/Swift | OC/Swift | Swift |
| 自動管理線程 | ❌ | ❌ | ✅ | ✅ | ✅ |
| 任務取消 | 手動 | 手動 | ❌ | ✅ | ✅ |
| 任務依賴 | ❌ | ❌ | Group/Barrier | ✅ | ✅ |
| 優先級 | ✅ | ✅ | QoS | ✅ | ✅ |
| 易用性 | 低 | 中 | 高 | 高 | 最高 |
| 推薦程度 | ⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 線程安全

多線程開發中必須注意線程安全問題：

### 常見問題
1. **資料競爭（Data Race）**：多個線程同時讀寫同一數據
2. **死鎖（Deadlock）**：線程互相等待對方釋放資源

### 解決方案
1. **串行隊列**：使用 GCD 串行隊列保護共享資源
2. **鎖（Lock）**：NSLock、NSRecursiveLock、os_unfair_lock
3. **Barrier**：GCD 的 barrier flag
4. **Semaphore**：DispatchSemaphore 控制訪問
5. **Actor**：Swift Concurrency 的 Actor 類型

---

## 面試重點

1. **iOS 有幾種多線程實現方式？**
   - pthread、NSThread、GCD、Operation、async/await（共 5 種）

2. **GCD 與 OperationQueue 的區別？**
   - GCD：輕量、高效，適合簡單任務
   - OperationQueue：支持取消、依賴、KVO，適合複雜任務管理

3. **什麼時候使用哪種方案？**
   - 簡單後台任務：GCD
   - 需要取消或依賴：OperationQueue
   - 新項目異步代碼：async/await

4. **如何保證線程安全？**
   - 串行隊列、鎖、Barrier、Semaphore、Actor

5. **主線程的重要性？**
   - 所有 UI 操作必須在主線程
   - 耗時操作會阻塞 UI

---

## 總結

iOS 提供了從底層到高層的多種多線程解決方案。在實際開發中：

- **GCD** 是最常用且推薦的方案，適合大多數場景
- **OperationQueue** 適合需要任務管理（取消、依賴）的場景
- **Swift Concurrency** 是未來趨勢，新項目建議優先採用
- **NSThread** 和 **pthread** 很少直接使用

選擇合適的多線程方案，並注意線程安全，是開發高質量 iOS 應用的關鍵。

