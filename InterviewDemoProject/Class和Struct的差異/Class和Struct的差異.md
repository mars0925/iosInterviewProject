# Class 和 Struct 的差異

## 核心差異

### 1. 類型本質

- **Struct (結構體)**: 值類型 (Value Type)
- **Class (類別)**: 引用類型 (Reference Type)

### 2. 記憶體分配

- **Struct**: 分配在堆疊 (Stack) 上，效能較好
- **Class**: 分配在堆積 (Heap) 上，需要 ARC 管理

### 3. 複製行為

- **Struct**: 賦值時進行深拷貝 (Deep Copy)，創建完全獨立的副本
- **Class**: 賦值時只複製引用 (Reference)，多個變數指向同一個實例

## 詳細比較

### Struct (結構體)

**特點:**

- 值類型，賦值時會複製整個資料
- 不支援繼承，但可以遵循協議 (Protocol)
- 沒有反初始化器 (deinitializer)
- 自動生成成員初始化器
- 線程安全 (因為是值複製)
- 適合表示簡單的資料結構

**優勢:**

- 更安全，避免意外修改
- 效能較好（在堆疊上分配）
- 自動記憶體管理，無需 ARC
- 不會產生循環引用問題

**使用場景:**

- 簡單的資料模型
- 幾何圖形 (如 Point, Size, Rect)
- 不需要繼承的情況
- 需要值語義的場景

### Class (類別)

**特點:**

- 引用類型，賦值時只複製引用
- 支援繼承和方法覆寫
- 有反初始化器 (deinit)
- 需要手動定義初始化器
- 需要 ARC 管理記憶體
- 可能產生循環引用

**優勢:**

- 支援 OOP 特性（繼承、多態）
- 適合表示複雜對象
- 可以使用類型轉換和類型檢查
- 適合需要共享狀態的場景

**使用場景:**

- 需要繼承的類層次結構
- 複雜的業務邏輯對象
- 需要引用語義（多個地方引用同一實例）
- UIKit 組件（必須繼承自 UIView、UIViewController 等）

## 共同點

1. 都可以定義屬性 (Properties)
2. 都可以定義方法 (Methods)
3. 都可以定義下標 (Subscripts)
4. 都可以定義初始化器 (Initializers)
5. 都可以遵循協議 (Protocols)
6. 都可以使用 extension 擴展功能

## Class 獨有特性

1. **繼承 (Inheritance)**: 可以從父類繼承特性
2. **類型轉換 (Type Casting)**: 可以在運行時檢查和解釋類實例的類型
3. **反初始化器 (Deinitializers)**: 可以定義 deinit 來釋放資源
4. **引用計數 (Reference Counting)**: 允許多個引用指向同一實例

## Struct 獨有特性

1. **自動成員初始化器**: 自動生成包含所有屬性的初始化器
2. **Copy-on-Write (COW)**: Swift 標準庫的集合類型（Array、Dictionary）使用 COW 優化

## 實際範例對比

### 值類型 vs 引用類型

```swift
// Struct - 值類型
struct PointStruct {
    var x: Int
    var y: Int
}

var point1 = PointStruct(x: 10, y: 20)
var point2 = point1  // 複製整個值
point2.x = 30
// point1.x = 10, point2.x = 30 (各自獨立)

// Class - 引用類型
class PointClass {
    var x: Int
    var y: Int
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

var point3 = PointClass(x: 10, y: 20)
var point4 = point3  // 只複製引用
point4.x = 30
// point3.x = 30, point4.x = 30 (指向同一對象)
```

## Mutability (可變性)

### Struct

- 使用 `var` 聲明的 struct 實例可以修改屬性
- 使用 `let` 聲明的 struct 實例，所有屬性都不可修改
- 修改屬性的方法需要標記為 `mutating`

### Class

- 實例的引用用 `let` 聲明時，引用不可變，但屬性仍可修改
- 實例的引用用 `var` 聲明時，可以指向不同的實例

## 性能考量

### Struct 的優勢

- 堆疊分配，速度快
- 無需引用計數
- 適合小型、頻繁創建的資料

### Class 的優勢

- 大型對象避免複製開銷
- 共享狀態時效率高

## 選擇建議

### 優先使用 Struct 的情況：

1. 資料結構簡單，主要用於封裝少量相關數據
2. 需要值語義，複製時希望得到獨立的實例
3. 不需要繼承
4. 需要線程安全

### 必須使用 Class 的情況：

1. 需要繼承現有的 Objective-C 類
2. 需要使用 deinitializer
3. 需要引用同一個實例
4. 需要繼承和多態特性

## 總結

Swift 推薦優先使用 Struct，除非你需要 Class 特有的功能（如繼承）。這種設計哲學鼓勵使用值類型來減少錯誤和提高代碼的可預測性。

**記憶口訣:**

- **Struct**: 值類型、獨立複製、堆疊分配、無繼承
- **Class**: 引用類型、共享實例、堆積分配、支援繼承





