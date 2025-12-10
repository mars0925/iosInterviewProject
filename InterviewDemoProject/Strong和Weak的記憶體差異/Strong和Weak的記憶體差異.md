# Strong 和 Weak 對 Memory 的差異

## 一、基本概念

在 iOS 開發中，`strong` 和 `weak` 是 ARC（Automatic Reference Counting）記憶體管理中的兩種引用修飾符，它們對物件的記憶體管理方式有著根本性的差異。

### 1.1 Strong（強引用）

**定義：** 預設的引用類型，會增加物件的引用計數（retain count）。

**特性：**

-   當一個物件被 strong 引用時，引用計數 +1
-   只要有至少一個 strong 引用存在，物件就不會被釋放
-   是屬性的預設修飾符（在 Swift 中）
-   會持有物件的所有權

**語法：**

```swift
// Swift
var person: Person?  // 預設是 strong
strong var person: Person?  // 明確宣告（較少使用）

// Objective-C
@property (nonatomic, strong) Person *person;
```

### 1.2 Weak（弱引用）

**定義：** 不會增加物件的引用計數，不持有物件所有權的引用。

**特性：**

-   當一個物件被 weak 引用時，引用計數不變
-   weak 引用不會阻止物件被釋放
-   當被引用的物件釋放時，weak 引用會自動設為 nil（避免野指標）
-   必須宣告為 optional 類型（可選類型）
-   只能用於 class 類型（引用類型）

**語法：**

```swift
// Swift
weak var delegate: MyDelegate?

// Objective-C
@property (nonatomic, weak) id<MyDelegate> delegate;
```

## 二、記憶體管理差異對比

| 特性           | Strong         | Weak                   |
| -------------- | -------------- | ---------------------- |
| **引用計數**   | +1             | 不變（0）              |
| **所有權**     | 持有所有權     | 不持有所有權           |
| **物件釋放**   | 阻止物件釋放   | 不阻止物件釋放         |
| **自動置 nil** | 不會           | 會（當物件被釋放時）   |
| **使用類型**   | 任何類型       | 僅 class（引用類型）   |
| **是否可選**   | 可選或非可選   | 必須是可選（optional） |
| **預設值**     | 是（Swift 中） | 否                     |

## 三、記憶體循環引用（Retain Cycle）

### 3.1 什麼是循環引用？

當兩個或多個物件相互持有 strong 引用時，會形成循環引用，導致記憶體洩漏。

**典型情況：**

```
物件 A (strong) → 物件 B
       ↑              ↓
       └──── (strong) ┘
```

兩個物件互相持有對方，引用計數永遠不會變成 0，無法被釋放。

### 3.2 常見的循環引用場景

1. **Delegate 模式**

    - View 持有 strong 引用指向 Delegate
    - Delegate（通常是 ViewController）也持有 strong 引用指向 View
    - 解決方法：Delegate 使用 weak 引用

2. **Closure（閉包）**

    - 物件持有閉包的 strong 引用
    - 閉包內部捕獲了物件的 strong 引用（self）
    - 解決方法：使用 `[weak self]` 或 `[unowned self]`

3. **Parent-Child 關係**
    - Parent 持有 Child 的 strong 引用
    - Child 持有 Parent 的 strong 引用
    - 解決方法：Child 對 Parent 使用 weak 引用

## 四、使用場景與最佳實踐

### 4.1 使用 Strong 的場景

1. **一般屬性**：當你需要持有物件並確保它存在時

    ```swift
    class Person {
        var name: String  // Strong reference
        var address: Address  // Strong reference
    }
    ```

2. **陣列、字典等集合**：集合對元素的引用預設是 strong

    ```swift
    var students: [Student] = []  // Array holds strong references
    ```

3. **子視圖**：父視圖對子視圖的引用
    ```swift
    view.addSubview(myButton)  // view holds strong reference to myButton
    ```

### 4.2 使用 Weak 的場景

1. **Delegate 模式**：避免循環引用

    ```swift
    protocol MyDelegate: AnyObject {
        func didComplete()
    }

    class MyView {
        weak var delegate: MyDelegate?
    }
    ```

2. **Closure 捕獲 self**：

    ```swift
    class MyViewController {
        var completion: (() -> Void)?

        func setupCompletion() {
            completion = { [weak self] in
                self?.doSomething()
            }
        }
    }
    ```

3. **觀察者模式**：被觀察者持有觀察者時

    ```swift
    class Observable {
        weak var observer: Observer?
    }
    ```

4. **Parent-Child 關係中的反向引用**：
    ```swift
    class Child {
        weak var parent: Parent?  // Avoid retain cycle
    }
    ```

## 五、Weak vs Unowned

除了 weak，還有另一個不增加引用計數的修飾符：`unowned`

### 差異對比

| 特性           | Weak                        | Unowned              |
| -------------- | --------------------------- | -------------------- |
| **引用計數**   | 不增加                      | 不增加               |
| **物件釋放後** | 自動置 nil                  | 不會置 nil（危險！） |
| **類型要求**   | 必須 optional               | 可以非 optional      |
| **安全性**     | 安全（自動處理）            | 不安全（可能崩潰）   |
| **效能**       | 略低（需要自動置 nil 機制） | 略高                 |

### 使用建議

-   **使用 weak**：當引用的物件可能會比當前物件先釋放時
-   **使用 unowned**：當你確定引用的物件生命週期至少與當前物件一樣長時

**範例：**

```swift
// Weak - 安全但需要處理 optional
class Person {
    weak var apartment: Apartment?
}

// Unowned - 假設 customer 生命週期不短於 card
class CreditCard {
    unowned let customer: Customer  // Customer 必定存在

    init(customer: Customer) {
        self.customer = customer
    }
}
```

## 六、記憶體檢測工具

### 6.1 Xcode Memory Graph Debugger

-   在 App 運行時點擊 Debug Navigator 中的 Memory Graph 圖標
-   可視化檢查物件之間的引用關係
-   自動檢測循環引用（會標記為紫色感嘆號）

### 6.2 Instruments - Leaks

-   使用 Instruments 的 Leaks 模板
-   可以追蹤記憶體洩漏
-   顯示洩漏的物件和分配堆疊

### 6.3 手動除錯

在 deinit 中加入 print：

```swift
class MyClass {
    deinit {
        print("MyClass is being deinitialized")
    }
}
```

如果物件應該被釋放但 deinit 沒有被調用，可能存在循環引用。

## 七、實際範例總結

### 7.1 正確的 Delegate 模式

```swift
// ❌ 錯誤：會造成循環引用
class MyView {
    var delegate: MyDelegate?  // Strong reference!
}

// ✅ 正確：使用 weak
class MyView {
    weak var delegate: MyDelegate?  // Weak reference
}
```

### 7.2 正確的 Closure 使用

```swift
// ❌ 錯誤：會造成循環引用
class ViewController {
    var handler: (() -> Void)?

    func setup() {
        handler = {
            self.updateUI()  // Strong capture of self!
        }
    }
}

// ✅ 正確：使用 weak self
class ViewController {
    var handler: (() -> Void)?

    func setup() {
        handler = { [weak self] in
            self?.updateUI()  // Weak capture, safe
        }
    }
}
```

### 7.3 IBOutlet 的引用類型

```swift
// UIKit 中的 IBOutlet 通常使用 weak
// 因為視圖已經被 view hierarchy 持有（strong reference）
class MyViewController: UIViewController {
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var myLabel: UILabel!
}
```

## 八、常見錯誤與注意事項

### 8.1 過度使用 Weak

❌ **錯誤示範：**

```swift
class Person {
    weak var name: String?  // 錯誤！String 是值類型
    weak var age: Int?      // 錯誤！Int 是值類型
}
```

✅ **正確做法：**

```swift
class Person {
    var name: String    // 值類型使用 strong（預設）
    var age: Int        // 值類型使用 strong（預設）
}
```

### 8.2 Weak 引用被過早釋放

```swift
// ❌ 問題代碼
class MyClass {
    weak var temporaryObject: MyObject?

    func test() {
        temporaryObject = MyObject()  // 立即被釋放！
        print(temporaryObject)        // nil
    }
}

// ✅ 解決方案
class MyClass {
    var temporaryObject: MyObject?  // 使用 strong

    func test() {
        temporaryObject = MyObject()  // 正常持有
        print(temporaryObject)        // 有值
    }
}
```

## 九、面試重點

1. **Strong 會增加引用計數，Weak 不會**
2. **Weak 引用在物件釋放時自動置為 nil**
3. **循環引用的成因和解決方法**
4. **Delegate 模式中為什麼要用 weak**
5. **Closure 如何使用 weak self 避免循環引用**
6. **Weak vs Unowned 的差異和使用時機**
7. **如何檢測和除錯記憶體問題**

## 十、效能考量

### Strong 引用的效能影響

-   需要維護引用計數
-   對效能影響極小（優化過的操作）

### Weak 引用的效能影響

-   需要額外的 side table 來追蹤 weak 引用
-   物件釋放時需要遍歷並更新所有 weak 引用
-   相對 strong 稍慢，但差異通常可以忽略

**結論：** 不要為了效能而避免使用 weak，應該優先考慮正確性和記憶體安全。
