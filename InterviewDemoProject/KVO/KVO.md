# KVO (Key-Value Observing) 詳解

## 什麼是 KVO？

KVO 是 Key-Value Observing 的縮寫，是蘋果提供的一種觀察者模式實現機制。它允許對象監聽其他對象特定屬性的變化，當屬性值發生改變時，觀察者會收到通知。

## 核心概念

### 1. 觀察者模式

- KVO 是觀察者設計模式的實現
- 一個對象（觀察者）可以監聽另一個對象（被觀察者）的屬性變化
- 當屬性值改變時，觀察者會自動收到通知

### 2. KVO 的三個要素

1. **被觀察者（Subject）**：屬性發生變化的對象
2. **觀察者（Observer）**：監聽屬性變化的對象
3. **Key Path**：要觀察的屬性路徑

## 實現原理

### 底層機制：Runtime 動態子類化

KVO 的實現依賴於 Objective-C 的 Runtime 機制，核心原理如下：

1. **動態生成子類**

   - 當對一個對象的屬性添加觀察者時，Runtime 會動態創建該對象類的子類
   - 子類名稱格式：`NSKVONotifying_原類名`
   - 將被觀察對象的 isa 指針指向這個新的子類

2. **重寫 Setter 方法**

   - 在動態子類中重寫被觀察屬性的 setter 方法
   - 重寫的 setter 方法會在調用原始 setter 前後發送通知
   - 執行順序：
     ```
     willChangeValueForKey:
     -> 調用原始setter
     -> didChangeValueForKey:
     -> 通知觀察者
     ```

3. **重寫 class 方法**

   - 為了隱藏內部實現，重寫 class 方法返回原始類
   - 這樣外部看起來類型沒有變化

4. **重寫 dealloc 方法**
   - 用於清理 KVO 相關的資源

### 觸發機制

```
設置屬性值
    ↓
調用 willChangeValueForKey:
    ↓
調用原始 setter 方法
    ↓
調用 didChangeValueForKey:
    ↓
觸發 observeValueForKeyPath:ofObject:change:context:
```

## KVO 的使用步驟

### 1. 添加觀察者

```swift
// Objective-C風格（Swift中可用）
object.addObserver(self,
                   forKeyPath: "propertyName",
                   options: [.new, .old],
                   context: nil)
```

### 2. 實現回調方法

```swift
override func observeValue(forKeyPath keyPath: String?,
                          of object: Any?,
                          change: [NSKeyValueChangeKey : Any]?,
                          context: UnsafeMutableRawPointer?) {
    // 處理屬性變化
}
```

### 3. 移除觀察者

```swift
object.removeObserver(self, forKeyPath: "propertyName")
```

## Swift 中的現代 KVO

### 使用 NSKeyValueObservation（iOS 11+）

Swift 提供了更安全的 KVO API：

```swift
var observation: NSKeyValueObservation?

observation = object.observe(\.propertyName, options: [.new, .old]) { object, change in
    // 處理變化
}

// 不需要手動移除，observation釋放時自動移除
```

### 優點

- 類型安全（使用 KeyPath）
- 自動管理觀察者生命週期
- 避免了手動移除觀察者的陷阱

## KVO 的 Options

- **.new**：change 字典包含新值（NSKeyValueChangeNewKey）
- **.old**：change 字典包含舊值（NSKeyValueChangeOldKey）
- **.initial**：註冊後立即發送一次通知
- **.prior**：值改變前後各發送一次通知

## 注意事項與最佳實踐

### 1. 必須移除觀察者

- 在觀察者 dealloc 之前必須移除觀察
- 否則會導致崩潰（向已釋放的對象發送消息）
- 使用 NSKeyValueObservation 可以避免這個問題

### 2. 線程安全

- KVO 通知在屬性改變的線程上發送
- 如果在子線程改變屬性，通知也在子線程
- UI 更新需要切換到主線程

### 3. Context 的使用

- 使用 context 可以區分不同的觀察
- 建議使用靜態變量地址作為 context

```swift
private var myContext = 0
// 使用 &myContext 作為context
```

### 4. 手動觸發 KVO

```swift
willChangeValue(forKey: "propertyName")
// 改變內部狀態
didChangeValue(forKey: "propertyName")
```

### 5. 禁用自動 KVO

```swift
class MyClass: NSObject {
    @objc dynamic var property: String = ""

    override class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        if key == "property" {
            return false
        }
        return super.automaticallyNotifiesObservers(forKey: key)
    }
}
```

## KVO vs 通知中心 (NotificationCenter)

| 特性       | KVO                        | NotificationCenter         |
| ---------- | -------------------------- | -------------------------- |
| 使用場景   | 監聽屬性變化               | 任意事件通知               |
| 耦合度     | 較高（需要知道對象和屬性） | 較低（只需要知道通知名稱） |
| 傳遞信息   | 舊值和新值                 | 任意 userInfo              |
| 性能       | 較好                       | 較差                       |
| 一對多     | 支持                       | 支持                       |
| 實現複雜度 | 較簡單                     | 較簡單                     |

## KVO vs 屬性觀察器 (didSet/willSet)

| 特性              | KVO               | didSet/willSet     |
| ----------------- | ----------------- | ------------------ |
| 使用場景          | 外部觀察對象屬性  | 屬性自身的變化處理 |
| 觀察者數量        | 多個              | 單一（屬性本身）   |
| 需要繼承 NSObject | 是                | 否                 |
| 語言支持          | Objective-C/Swift | Swift              |
| 獲取舊值          | 支持              | willSet 中支持     |

## 適用場景

### 適合使用 KVO

- 需要監聽第三方庫對象的屬性變化
- 多個對象需要監聽同一屬性
- 需要同時獲取新舊值
- 需要監聽嵌套屬性（keyPath）

### 不適合使用 KVO

- 純 Swift 對象（不繼承 NSObject）
- 簡單的屬性監聽（用 didSet 更簡單）
- 需要傳遞複雜的事件信息（用 NotificationCenter 或 delegate）
- 性能要求極高的場景

## 常見問題

### 1. 為什麼需要@objc dynamic？

在 Swift 中，要使屬性支持 KVO，需要：

- 類繼承自 NSObject
- 屬性標記為@objc dynamic

這讓屬性暴露給 Objective-C runtime，使動態派發和 KVO 成為可能。

### 2. 崩潰常見原因

- 重複添加觀察者
- 忘記移除觀察者
- 移除未添加的觀察者
- 觀察者已釋放但未移除

### 3. 如何 Debug KVO？

```swift
// 查看對象的觀察信息
po object.observationInfo
```

## 總結

KVO 是 iOS 開發中重要的設計模式實現：

- **原理**：基於 Runtime 的 isa-swizzling 和方法重寫
- **優點**：自動通知、支持嵌套路徑、無需修改被觀察類
- **缺點**：需要手動管理生命週期、容易崩潰、調試困難
- **現代做法**：在 Swift 中優先使用 NSKeyValueObservation 或 Combine 框架

理解 KVO 的實現原理和使用場景，能幫助你在面試和實際開發中做出更好的設計決策。
