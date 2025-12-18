# ARC機制與引用計數 (Automatic Reference Counting)

## 什麼是 Reference Count（引用計數）

**引用計數**是一種記憶體管理技術，用來追蹤某個物件被多少個變數或屬性「引用」。每當有新的引用指向該物件時，引用計數就會 +1；當引用被移除時，引用計數就會 -1。當引用計數降到 0 時，表示沒有任何變數在使用這個物件，系統就會自動釋放該物件所佔用的記憶體。

### 核心概念

```
物件被創建 → Reference Count = 1
新增一個引用 → Reference Count + 1
移除一個引用 → Reference Count - 1
Reference Count = 0 → 物件被釋放（deinit 被調用）
```

## 什麼是 ARC（Automatic Reference Counting）

**ARC**是 Apple 在 iOS 5 和 macOS 10.7 引入的自動記憶體管理機制。在 ARC 之前，開發者需要手動管理記憶體（MRC - Manual Reference Counting），需要手動調用 `retain`、`release`、`autorelease` 等方法。

### ARC 的工作原理

ARC 會在**編譯期間**自動在適當的位置插入記憶體管理代碼（retain、release），而不需要開發者手動編寫。這大大降低了記憶體管理的複雜度和出錯機率。

#### ARC 的三個核心操作

1. **Strong Reference（強引用）**：預設的引用類型，會增加引用計數
2. **Weak Reference（弱引用）**：不會增加引用計數，當物件被釋放時自動設為 nil
3. **Unowned Reference（無主引用）**：不會增加引用計數，但不會自動設為 nil

## Reference Count 的運作機制

### 1. Strong Reference（強引用）

```swift
var person1: Person? = Person(name: "張三")  // RC = 1
var person2 = person1                        // RC = 2（person2 強引用）
var person3 = person1                        // RC = 3（person3 強引用）

person1 = nil  // RC = 2
person2 = nil  // RC = 1
person3 = nil  // RC = 0，物件被釋放，deinit 被調用
```

### 2. Weak Reference（弱引用）

```swift
class Person {
    var name: String
    weak var friend: Person?  // 使用 weak 避免循環引用
    
    init(name: String) {
        self.name = name
    }
}

var person1: Person? = Person(name: "張三")  // person1 RC = 1
var person2: Person? = Person(name: "李四")  // person2 RC = 1

person1?.friend = person2  // person2 RC 依然是 1（weak 不增加計數）
person2?.friend = person1  // person1 RC 依然是 1（weak 不增加計數）
```

### 3. Unowned Reference（無主引用）

```swift
class Customer {
    var card: CreditCard?
}

class CreditCard {
    unowned let customer: Customer  // 使用 unowned
    
    init(customer: Customer) {
        self.customer = customer
    }
}
```

## ARC 的常見問題

### 1. 循環引用（Retain Cycle）

當兩個物件互相強引用時，會造成循環引用，導致記憶體洩漏。

```swift
class Person {
    var dog: Dog?
}

class Dog {
    var owner: Person?  // 強引用，造成循環引用
}

var person: Person? = Person()
var dog: Dog? = Dog()

person?.dog = dog      // person 強引用 dog
dog?.owner = person    // dog 強引用 person

// 即使設為 nil，兩個物件的 RC 都不會變成 0
person = nil  // person 的 RC 從 2 變成 1（dog.owner 還在引用）
dog = nil     // dog 的 RC 從 2 變成 1（person.dog 還在引用）
// 結果：記憶體洩漏！
```

**解決方案：使用 weak 或 unowned**

```swift
class Dog {
    weak var owner: Person?  // 使用 weak 打破循環引用
}
```

### 2. Closure 中的循環引用

Closure 會捕獲它使用的外部變數，如果 closure 捕獲了 `self`，可能造成循環引用。

```swift
class ViewController {
    var name = "主頁"
    
    func setupClosure() {
        someAsyncFunction {
            print(self.name)  // closure 強引用 self
        }
    }
}
```

**解決方案：使用 capture list**

```swift
func setupClosure() {
    someAsyncFunction { [weak self] in
        guard let self = self else { return }
        print(self.name)
    }
}

// 或者使用 unowned（確定 self 不會被釋放）
func setupClosure() {
    someAsyncFunction { [unowned self] in
        print(self.name)
    }
}
```

## Weak vs Unowned 的選擇

### 使用 Weak 的時機

- 引用可能在生命週期內變成 nil
- 適合用於可選類型（Optional）
- 引用的物件可能先被釋放

```swift
weak var delegate: SomeDelegate?
```

### 使用 Unowned 的時機

- 引用在生命週期內永遠不會是 nil
- 適合用於非可選類型
- 確定引用的物件生命週期比當前物件長

```swift
unowned let owner: Person
```

**注意**：如果 unowned 引用的物件被釋放，訪問該引用會導致崩潰，因此使用時需要特別小心。

## ARC 不適用的場景

ARC 只適用於**類別（Class）**的實例，不適用於：

- **結構體（Struct）**：值類型，使用複製機制
- **列舉（Enum）**：值類型
- **基本類型**：Int、String、Double 等

這些類型使用**值語義**，而不是引用計數。

## 記憶體管理最佳實踐

### 1. 預設使用 Strong

大多數情況下使用預設的強引用即可。

### 2. 打破循環引用

- Delegate 使用 `weak`
- Parent-Child 關係中，child 對 parent 使用 `weak` 或 `unowned`
- Closure 捕獲 self 時使用 capture list

### 3. 使用工具檢測記憶體洩漏

- **Instruments**：使用 Leaks 和 Allocations 工具
- **Memory Graph Debugger**：Xcode 內建工具，可視化物件關係
- **deinit 方法**：在類別中實作 deinit，確認物件是否被正確釋放

```swift
class MyClass {
    deinit {
        print("MyClass 被釋放")
    }
}
```

## 面試重點總結

### 1. Reference Count 是什麼？

引用計數是追蹤物件被引用次數的機制，當計數為 0 時物件被釋放。

### 2. ARC 的作用

自動在編譯期間插入記憶體管理代碼，無需手動管理 retain/release。

### 3. Strong、Weak、Unowned 的區別

| 類型 | 增加 RC | 可為 nil | 使用場景 |
|------|---------|----------|----------|
| Strong | ✓ | ✓ | 預設引用 |
| Weak | ✗ | ✓ | Delegate、可能為 nil 的引用 |
| Unowned | ✗ | ✗ | 確定不為 nil 的引用 |

### 4. 循環引用的原因和解決方法

**原因**：兩個物件互相強引用，導致 RC 無法降到 0

**解決**：使用 weak 或 unowned 打破循環

### 5. Closure 為什麼會造成循環引用？

Closure 會捕獲並強引用它使用的外部變數（包括 self），如果物件也持有這個 closure，就形成循環引用。

**解決**：使用 capture list `[weak self]` 或 `[unowned self]`

### 6. 如何檢測記憶體洩漏？

- 實作 `deinit` 方法打印日誌
- 使用 Xcode Memory Graph Debugger
- 使用 Instruments 的 Leaks 工具

## 底層實現

### SideTable 結構

在 Objective-C runtime 中，引用計數存儲在 SideTable 結構中：

```
SideTable {
    spinlock_t slock;           // 自旋鎖
    RefcountMap refcnts;        // 引用計數表
    weak_table_t weak_table;    // 弱引用表
}
```

### 引用計數存儲優化

- **小對象**：引用計數可能存儲在物件的 isa 指標中（isa 優化）
- **大對象**：引用計數存儲在 SideTable 的 RefcountMap 中

### Weak 表的實現

當使用 weak 引用時，系統會在 weak_table 中記錄：
- 哪些 weak 指標指向這個物件
- 當物件被釋放時，遍歷 weak_table，將所有 weak 指標設為 nil

## 延伸閱讀

- MRC（Manual Reference Counting）與 ARC 的差異
- Tagged Pointer 優化技術
- Copy-On-Write（COW）機制
- Swift 的值類型與引用類型






