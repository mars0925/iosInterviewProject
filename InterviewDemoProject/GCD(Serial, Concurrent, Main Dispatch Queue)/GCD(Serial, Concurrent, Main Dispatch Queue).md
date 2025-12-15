# GCD (Grand Central Dispatch)

## 什麼是 GCD？

GCD (Grand Central Dispatch) 是 Apple 開發的一套低階 C API，用於管理併發操作。它提供了一種簡單且高效的方式來執行多線程任務，讓開發者不需要直接管理線程的創建和銷毀。

## 核心概念

### 1. Dispatch Queue (調度隊列)

Dispatch Queue 是 GCD 的核心，它負責管理任務的執行。所有提交到隊列的任務都會按照 FIFO (First In First Out) 的順序被取出，但執行的方式取決於隊列的類型。

### 2. 三種主要的 Dispatch Queue 類型

#### Serial Queue (串行隊列)
- **定義**：一次只執行一個任務
- **特點**：
  - 任務按照添加順序依次執行
  - 前一個任務完成後才會執行下一個任務
  - 保證任務的執行順序
  - 可以創建多個串行隊列
- **使用場景**：
  - 需要保證任務執行順序的情況
  - 避免資源競爭（Race Condition）
  - 保護共享資源的訪問

```swift
// 創建串行隊列
let serialQueue = DispatchQueue(label: "com.example.serialQueue")
```

#### Concurrent Queue (併發隊列)
- **定義**：可以同時執行多個任務
- **特點**：
  - 任務按照添加順序被取出
  - 但可以並行執行多個任務
  - 執行完成的順序不確定
  - 系統根據可用資源決定同時執行的任務數量
- **使用場景**：
  - 需要提高執行效率的獨立任務
  - 大量的網絡請求
  - 圖片處理等耗時操作

```swift
// 創建併發隊列
let concurrentQueue = DispatchQueue(label: "com.example.concurrentQueue", attributes: .concurrent)

// 或使用全局併發隊列
let globalQueue = DispatchQueue.global(qos: .default)
```

#### Main Dispatch Queue (主隊列)
- **定義**：在主線程上執行任務的串行隊列
- **特點**：
  - 是一個特殊的串行隊列
  - 所有任務都在主線程執行
  - 與主 RunLoop 關聯
  - 整個應用只有一個主隊列
- **使用場景**：
  - 更新 UI
  - 處理用戶交互
  - 所有與界面相關的操作

```swift
// 獲取主隊列
let mainQueue = DispatchQueue.main
```

## Quality of Service (QoS)

GCD 提供了不同的優先級別，稱為 Quality of Service (服務質量)：

1. **userInteractive**：最高優先級，用於用戶交互相關的任務
2. **userInitiated**：高優先級，用戶發起需要立即看到結果的任務
3. **default**：默認優先級
4. **utility**：較低優先級，適合耗時較長的任務
5. **background**：最低優先級，適合用戶不可見的後台任務
6. **unspecified**：未指定優先級

```swift
let queue = DispatchQueue.global(qos: .userInitiated)
```

## 同步 vs 異步執行

### 同步執行 (sync)
- 會阻塞當前線程
- 等待任務完成後才返回
- 不會開啟新線程

```swift
queue.sync {
    // 任務代碼
}
```

### 異步執行 (async)
- 不會阻塞當前線程
- 立即返回
- 可能會開啟新線程（取決於隊列類型）

```swift
queue.async {
    // 任務代碼
}
```

## 組合方式與特點

| 隊列類型 | 同步執行 | 異步執行 |
|---------|---------|---------|
| Serial Queue | 當前線程執行，阻塞 | 可能開啟新線程，不阻塞 |
| Concurrent Queue | 當前線程執行，阻塞 | 開啟多個線程，不阻塞 |
| Main Queue | 主線程執行，阻塞（容易死鎖）| 主線程執行，不阻塞 |

## 常見陷阱

### 1. 主隊列死鎖

```swift
// ❌ 錯誤：在主線程上同步調用主隊列會造成死鎖
DispatchQueue.main.sync {
    // 這會造成死鎖
}
```

### 2. 串行隊列死鎖

```swift
let serialQueue = DispatchQueue(label: "com.example.serial")

serialQueue.sync {
    // 外層任務
    serialQueue.sync {
        // ❌ 內層任務等待外層完成，外層等待內層完成 → 死鎖
    }
}
```

## 實用場景

### 1. 後台執行任務，完成後更新 UI

```swift
DispatchQueue.global(qos: .userInitiated).async {
    // 在後台執行耗時任務
    let result = performHeavyTask()
    
    // 回到主線程更新 UI
    DispatchQueue.main.async {
        updateUI(with: result)
    }
}
```

### 2. 使用 DispatchGroup 等待多個任務完成

```swift
let group = DispatchGroup()

group.enter()
task1 { group.leave() }

group.enter()
task2 { group.leave() }

group.notify(queue: .main) {
    // 所有任務完成後執行
}
```

### 3. 使用 Barrier 保證讀寫安全

```swift
let queue = DispatchQueue(label: "com.example.barrier", attributes: .concurrent)

// 讀取操作可以併發
queue.async {
    // 讀取
}

// 寫入操作使用 barrier 確保獨佔訪問
queue.async(flags: .barrier) {
    // 寫入（此時沒有其他任務在執行）
}
```

## 面試重點

1. **串行 vs 併發的區別**：串行一次執行一個，併發可以同時執行多個
2. **同步 vs 異步的區別**：同步會阻塞，異步不會阻塞
3. **主隊列的特殊性**：必須在主線程更新 UI
4. **死鎖的原因**：相互等待造成的循環依賴
5. **QoS 的選擇**：根據任務重要性和緊急程度選擇合適的優先級
6. **線程安全**：使用串行隊列或 barrier 來保護共享資源

## 優點

- 簡化多線程編程
- 自動管理線程池
- 高效的任務調度
- 良好的性能優化
- 易於使用的 API

## 總結

GCD 是 iOS 開發中處理併發的重要工具。理解串行隊列、併發隊列和主隊列的特性，以及同步/異步執行的區別，是編寫高效、安全的多線程代碼的基礎。在實際開發中，合理選擇隊列類型和執行方式，可以有效提升應用性能並避免常見的多線程問題。





