# Thread Safety (線程安全)

## 什麼是 Thread Safety？

**Thread Safety（線程安全）** 是指當多個線程同時訪問某個資源（如變量、物件、檔案等）時，程式能夠正確地處理這些訪問，不會產生數據競爭（Data Race）、死鎖（Deadlock）或其他並發問題。

簡單來說：**一個線程安全的程式碼，可以在多線程環境下正確執行，不會因為多線程同時訪問而產生錯誤的結果。**

## 為什麼需要 Thread Safety？

在現代應用程式中，為了提高性能和響應速度，我們經常使用多線程來並發執行任務：

- **主線程（Main Thread）**：處理 UI 更新和用戶交互
- **背景線程（Background Thread）**：處理網路請求、資料庫操作、圖片處理等耗時任務

當多個線程同時訪問和修改同一個資源時，如果沒有適當的保護機制，就會產生 **資料競爭（Data Race）**。

## 常見的線程不安全問題

### 1. 數據競爭（Data Race）

多個線程同時讀寫同一個變量，導致結果不可預測。

```swift
var counter = 0

// Thread 1 執行
counter += 1

// Thread 2 同時執行
counter += 1

// 預期結果：2，但可能是 1（因為兩個線程同時讀取到 0）
```

### 2. 競態條件（Race Condition）

程式的執行結果取決於線程執行的順序或時間點。

### 3. 死鎖（Deadlock）

兩個或多個線程互相等待對方釋放資源，導致所有線程都無法繼續執行。

## iOS/Swift 中的線程安全解決方案

### 1. Serial Dispatch Queue（串行佇列）

所有任務按照加入的順序依次執行，天然線程安全。

```swift
let serialQueue = DispatchQueue(label: "com.example.serialQueue")
serialQueue.async {
    // 安全的訪問共享資源
}
```

### 2. Dispatch Barrier（柵欄）

允許多個讀操作並發執行，但寫操作時會等待所有讀操作完成。

```swift
let concurrentQueue = DispatchQueue(label: "com.example.queue", attributes: .concurrent)
concurrentQueue.async(flags: .barrier) {
    // 寫操作
}
```

### 3. NSLock（鎖）

使用鎖來保護臨界區（Critical Section）。

```swift
let lock = NSLock()
lock.lock()
// 訪問共享資源
lock.unlock()
```

### 4. Atomic 屬性

Objective-C 中的 `atomic` 屬性會自動加鎖，但 Swift 沒有內建支援。

### 5. Actor（Swift 5.5+）

Swift 的 Actor 模型天然提供線程安全保證。

```swift
actor BankAccount {
    var balance: Int = 0

    func deposit(amount: Int) {
        balance += amount
    }
}
```

### 6. @synchronized（Objective-C）

Objective-C 中的同步鎖。

## 線程安全的最佳實踐

1. **最小化共享狀態**：盡量減少多個線程需要訪問的共享資源
2. **不可變對象**：使用不可變對象（let, immutable），避免修改
3. **使用高級抽象**：優先使用 GCD、OperationQueue 等高級 API
4. **避免過度加鎖**：過多的鎖會降低性能
5. **避免在鎖內執行耗時操作**：減少鎖的持有時間

## Swift 中的線程安全集合

Swift 的標準集合類型（Array、Dictionary、Set）**不是線程安全的**。

如果需要在多線程環境下使用，需要：

- 使用串行佇列保護
- 使用 Concurrent Queue + Barrier
- 使用 Actor 封裝

## 面試重點

1. **定義**：線程安全是指多線程同時訪問資源時不會產生錯誤
2. **問題**：數據競爭、競態條件、死鎖
3. **解決方案**：
   - Serial Queue（最簡單）
   - Concurrent Queue + Barrier（讀多寫少）
   - Lock/Mutex（細粒度控制）
   - Actor（Swift 新特性）
4. **實際應用**：
   - 網路請求回調
   - 資料庫訪問
   - 緩存管理
   - 狀態管理

## 注意事項

- **主線程更新 UI**：所有 UI 更新必須在主線程執行
- **避免死鎖**：注意鎖的獲取順序
- **性能權衡**：線程安全機制會帶來性能開銷
- **測試困難**：並發問題往往難以復現和測試
