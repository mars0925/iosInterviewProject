# Stack 和 Heap 的差異

## 一、什麼是 Stack（堆疊）？

Stack 是一種自動管理的記憶體區域，用於存儲**值型別（Value Types）**和**函數調用的上下文資訊**。

### Stack 的特性：

1. **記憶體分配方式**：
   - 採用 LIFO（Last In First Out，後進先出）的方式
   - 自動分配和釋放，速度非常快
   - 記憶體是連續的

2. **存儲內容**：
   - 值型別的實際數據（如 Int, Double, Bool, Struct, Enum 等）
   - 函數參數和局部變量
   - 函數調用的返回地址
   - 引用型別的指針（但指向的對象存在 Heap 中）

3. **大小限制**：
   - 空間相對較小（通常幾 MB）
   - 超出範圍會導致 Stack Overflow

4. **存取速度**：
   - 非常快，因為只需要移動 Stack Pointer
   - CPU 可以有效利用 Cache

5. **生命週期**：
   - 隨著作用域（scope）自動管理
   - 當函數返回時，該函數的 Stack Frame 會自動清理

## 二、什麼是 Heap（堆積）？

Heap 是一種動態管理的記憶體區域，用於存儲**引用型別（Reference Types）**的實際數據。

### Heap 的特性：

1. **記憶體分配方式**：
   - 動態分配，需要手動或通過 ARC（自動引用計數）管理
   - 分配和釋放相對較慢
   - 記憶體不一定連續，可能產生碎片

2. **存儲內容**：
   - 引用型別的實際對象（如 Class 實例、Closure、NSString 等）
   - 需要長期存在的數據
   - 大型數據結構

3. **大小限制**：
   - 相對較大，受系統可用記憶體限制
   - 但分配過多會導致記憶體不足

4. **存取速度**：
   - 相對較慢，因為需要：
     - 尋找合適大小的空閒記憶體塊
     - 維護記憶體分配的數據結構
     - 進行引用計數管理（在 iOS/Swift 中）
   - 需要通過指針間接訪問

5. **生命週期**：
   - 需要明確的生命週期管理
   - 在 Swift/Objective-C 中通過 ARC 自動管理
   - 引用計數為 0 時才會釋放

## 三、Stack vs Heap 對比表

| 特性 | Stack | Heap |
|------|-------|------|
| **分配速度** | 非常快（只需移動指針） | 較慢（需要搜尋合適空間） |
| **記憶體管理** | 自動（作用域結束自動釋放） | 需要管理（ARC/手動） |
| **記憶體大小** | 較小（幾 MB） | 較大（受系統限制） |
| **存取速度** | 快（連續記憶體，Cache 友好） | 較慢（需要指針間接訪問） |
| **數據結構** | 線性，連續 | 可能碎片化，不連續 |
| **存儲內容** | 值型別、函數調用資訊 | 引用型別的實際對象 |
| **線程安全** | 每個線程有自己的 Stack | 共享，需要同步機制 |
| **生命週期** | 作用域結束自動清理 | 引用計數為 0 時釋放 |
| **容易出錯** | Stack Overflow | Memory Leak、碎片化 |

## 四、Swift 中的應用

### 1. 值型別存儲在 Stack

```swift
// 這些都存儲在 Stack 上
struct Point {
    var x: Int  // 存在 Stack
    var y: Int  // 存在 Stack
}

func example() {
    let number = 42        // Stack
    let point = Point(x: 10, y: 20)  // Stack
    let tuple = (1, 2, 3)  // Stack
}  // 函數結束，所有變量自動從 Stack 釋放
```

### 2. 引用型別存儲在 Heap

```swift
// Class 實例存儲在 Heap
class Person {
    var name: String  // 實際對象在 Heap
    init(name: String) {
        self.name = name
    }
}

func example() {
    let person = Person(name: "John")
    // person 變量（指針）在 Stack
    // 但 Person 實例本身在 Heap
}  // 函數結束，person 變量從 Stack 移除
   // 但 Person 實例在 Heap 中，等待 ARC 釋放
```

### 3. 混合情況

```swift
struct Container {
    var value: Int        // Stack
    var object: Person    // 指針在 Stack，對象在 Heap
}

class ComplexObject {
    var id: Int           // 這個 Int 存在 Heap（作為對象的一部分）
    var point: Point      // 這個 Struct 也存在 Heap（作為對象的一部分）
    
    init(id: Int, point: Point) {
        self.id = id
        self.point = point
    }
}
```

## 五、性能影響

### Stack 的優勢：
1. **分配和釋放極快**：只需要移動一個指針
2. **Cache 友好**：數據連續存儲，CPU Cache 命中率高
3. **無需記憶體管理開銷**：自動清理，無需引用計數

### Heap 的劣勢：
1. **分配慢**：需要找到合適大小的空閒塊
2. **釋放慢**：需要更新記憶體管理結構
3. **引用計數開銷**：每次賦值、傳遞都需要更新引用計數
4. **線程同步開銷**：多線程訪問需要加鎖
5. **記憶體碎片**：長時間運行可能產生碎片

## 六、Stack Overflow 示例

```swift
// 遞迴過深會導致 Stack Overflow
func infiniteRecursion() {
    infiniteRecursion()  // 每次調用都在 Stack 上分配空間
}  // 最終導致 Stack Overflow

// 大型局部數組可能導致 Stack Overflow
func largeLocalArray() {
    var hugeArray = [Int](repeating: 0, count: 10_000_000)
    // 如果這個數組是 struct，可能會超出 Stack 大小
}
```

## 七、選擇 Stack 還是 Heap？

### 優先使用 Stack（值型別）的情況：

1. **小型數據結構**（幾個屬性）
2. **不需要繼承**
3. **需要值語義**（複製而非共享）
4. **性能關鍵的代碼**
5. **多線程環境**（避免共享狀態）

### 必須使用 Heap（引用型別）的情況：

1. **需要繼承**
2. **需要引用語義**（共享同一個實例）
3. **大型對象**（避免複製開銷）
4. **需要 deinit**（清理資源）
5. **Objective-C 互操作**

## 八、記憶體佈局示例

```
Stack (向下增長)：
+------------------+  <- 高地址
| main() 的變量     |
+------------------+
| functionA() 參數  |
+------------------+
| functionA() 變量  |
+------------------+
| functionB() 參數  |
+------------------+
| functionB() 變量  |
+------------------+  <- Stack Pointer（當前位置）
| 未使用空間        |
|                  |
+------------------+  <- 低地址

Heap (動態分配)：
+------------------+
| 已分配對象 1      |
+------------------+
| 空閒空間         |
+------------------+
| 已分配對象 2      |
+------------------+
| 已分配對象 3      |
+------------------+
| 空閒空間         |
+------------------+
```

## 九、面試重點

1. **Stack 是自動管理的，快速但有限；Heap 是動態管理的，靈活但慢**
2. **值型別通常存在 Stack，引用型別存在 Heap**
3. **理解為什麼 Struct 比 Class 性能更好**
4. **知道 Stack Overflow 和 Memory Leak 的原因**
5. **能解釋為什麼多線程使用值型別更安全**
6. **理解 ARC 只管理 Heap 上的對象**

## 十、實際影響

```swift
// 性能差異示例
struct ValueType {
    var x: Int
    var y: Int
}

class ReferenceType {
    var x: Int
    var y: Int
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

// Struct（Stack）：
// - 創建：極快（只需在 Stack 上分配空間）
// - 複製：快（直接複製值）
// - 傳遞：可能有複製開銷，但編譯器會優化
let v1 = ValueType(x: 1, y: 2)  // Stack 分配
let v2 = v1  // 複製（但通常很快）

// Class（Heap）：
// - 創建：慢（Heap 分配 + 引用計數初始化）
// - 複製：只複製指針，共享實例
// - 傳遞：快（只傳遞指針），但有引用計數開銷
let r1 = ReferenceType(x: 1, y: 2)  // Heap 分配
let r2 = r1  // 只複製指針，引用計數 +1
```

## 總結

Stack 和 Heap 是兩種不同的記憶體管理機制：

- **Stack**：快速、自動管理、適合小型短生命週期數據
- **Heap**：靈活、需要管理、適合大型長生命週期對象

在 Swift 中，合理選擇 Struct（Stack）和 Class（Heap）可以顯著影響程式的性能和安全性。理解這兩者的差異是成為優秀 iOS 開發者的基礎。





