# Delegate 和 Protocol 的差異

## 核心概念

### Protocol（協議）

-   **定義**：Protocol 是 Swift/Objective-C 中的語言特性，用來定義方法、屬性和其他要求的藍圖
-   **本質**：是一種類型，定義了一組接口規範
-   **用途**：可以被 class、struct、enum 採納（conform），實現多態和抽象

### Delegate（委託）

-   **定義**：Delegate 是一種設計模式，允許一個對象將某些責任委託給另一個對象
-   **本質**：是一種架構設計模式，通常使用 Protocol 來實現
-   **用途**：實現對象間的通信和解耦

## 關鍵差異

### 1. 層級關係

```
Protocol（語言特性）
    ↓ 被用於實現
Delegate（設計模式）
```

**Protocol** 是基礎工具，**Delegate** 是使用這個工具實現的模式

### 2. 使用範圍

#### Protocol 的用途：

-   定義接口規範
-   實現多態
-   依賴注入
-   定義 Delegate 規範
-   擴展功能（Protocol Extension）

#### Delegate 的用途：

-   對象間通信
-   事件回調
-   自定義行為
-   解耦合

### 3. 實現方式

#### Protocol 範例：

```swift
// Protocol 定義了一組規範
protocol Flyable {
    var altitude: Double { get }
    func fly()
}

// 任何類型都可以採納這個 protocol
struct Bird: Flyable {
    var altitude: Double = 0
    func fly() { print("Bird flying") }
}

struct Airplane: Flyable {
    var altitude: Double = 0
    func fly() { print("Airplane flying") }
}
```

#### Delegate 範例：

```swift
// 使用 Protocol 定義 Delegate 的規範
protocol DataDownloaderDelegate: AnyObject {
    func didFinishDownloading(data: Data)
    func didFailWithError(error: Error)
}

// Delegate 模式：一個對象委託另一個對象處理特定任務
class DataDownloader {
    weak var delegate: DataDownloaderDelegate?

    func download() {
        // 下載完成後，委託 delegate 處理結果
        delegate?.didFinishDownloading(data: Data())
    }
}
```

### 4. 命名慣例

-   **Protocol**：通常使用形容詞或能力描述
    -   `Codable`, `Equatable`, `Hashable`, `CustomStringConvertible`
-   **Delegate Protocol**：通常使用 "Delegate" 後綴
    -   `UITableViewDelegate`, `UITextFieldDelegate`, `CustomViewDelegate`

### 5. 引用類型

#### Protocol：

-   可以是 value type (struct, enum) 或 reference type (class)
-   不涉及記憶體管理

#### Delegate：

-   通常使用 `weak` 修飾防止循環引用
-   通常是 class-only protocol (`AnyObject`)
-   涉及對象生命週期管理

```swift
// Delegate protocol 通常繼承 AnyObject
protocol MyDelegate: AnyObject {
    func didSomething()
}

class MyClass {
    // 使用 weak 防止循環引用
    weak var delegate: MyDelegate?
}
```

## 面試重點

### 問題：Delegate 和 Protocol 的差異？

**標準答案**：

1. **層級不同**：Protocol 是語言特性，Delegate 是設計模式
2. **關係**：Delegate 模式使用 Protocol 來實現，但 Protocol 的用途不僅限於 Delegate
3. **目的**：Protocol 定義接口規範，Delegate 實現對象間的通信和職責委託
4. **應用**：Protocol 可用於多態、擴展、依賴注入等多種場景；Delegate 專注於回調和事件處理

### 延伸問題

**Q: 為什麼 Delegate 要用 weak？**

-   防止循環引用（retain cycle）
-   委託者持有 delegate，delegate 通常也持有委託者，形成循環

**Q: Protocol 除了 Delegate 還有什麼用途？**

-   定義共同接口（多態）
-   Protocol Extension 擴展功能
-   依賴注入
-   泛型約束

**Q: 什麼時候用 Delegate，什麼時候用 Closure？**

-   Delegate：需要多個相關方法、建立明確的職責關係
-   Closure：簡單的一次性回調

## 總結

| 特性 | Protocol         | Delegate           |
| ---- | ---------------- | ------------------ |
| 類型 | 語言特性         | 設計模式           |
| 定義 | 接口規範         | 職責委託           |
| 實現 | Swift/ObjC 內建  | 使用 Protocol 實現 |
| 用途 | 多態、擴展、約束 | 對象通信、回調     |
| 範圍 | 廣泛             | 特定場景           |

**記憶口訣**：Protocol 是工具，Delegate 是模式；Protocol 可以不是 Delegate，但 Delegate 一定用 Protocol。
