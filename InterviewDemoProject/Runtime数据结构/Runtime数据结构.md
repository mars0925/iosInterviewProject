# Runtime 數據結構

## 概述

Objective-C Runtime 是一個運行時庫，為 Objective-C 語言提供動態特性支持。Runtime 的核心是一系列 C 語言的數據結構和函數，這些結構定義了 Objective-C 的類、對象、方法等的底層實現。

## 核心數據結構

### 1. objc_object (對象結構)

```c
struct objc_object {
    Class _Nonnull isa;
};
```

- **說明**：這是所有對象的基礎結構
- **isa 指針**：指向對象的類結構，通過 isa 可以找到對象所屬的類
- **在 64 位架構後**：isa 使用了優化技術（Tagged Pointer、Non-pointer isa），isa 不僅僅存儲類地址，還包含引用計數、是否有關聯對象等信息

### 2. objc_class (類結構)

```c
struct objc_class {
    Class _Nonnull isa;                      // 指向 metaclass
    Class _Nullable superclass;               // 指向父類
    cache_t cache;                            // 方法緩存
    class_data_bits_t bits;                   // 類的數據（方法、屬性、協議等）
};
```

- **isa**：指向該類的 metaclass（元類）
- **superclass**：指向父類
- **cache**：方法調用的緩存，提高方法查找效率
- **bits**：包含 class_rw_t 結構，存儲類的方法列表、屬性列表、協議列表等

### 3. class_rw_t (可讀寫的類數據)

```c
struct class_rw_t {
    uint32_t flags;
    uint16_t witness;
    const class_ro_t *ro;                    // 只讀數據
    method_array_t methods;                   // 方法列表
    property_array_t properties;              // 屬性列表
    protocol_array_t protocols;               // 協議列表
};
```

- 運行時可以修改的類信息
- 包含編譯時確定的數據（ro）和運行時添加的數據

### 4. class_ro_t (只讀的類數據)

```c
struct class_ro_t {
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
    const uint8_t * ivarLayout;
    const char * name;                        // 類名
    method_list_t * baseMethodList;           // 基礎方法列表
    protocol_list_t * baseProtocols;          // 基礎協議列表
    const ivar_list_t * ivars;                // 成員變量列表
    const uint8_t * weakIvarLayout;
    property_list_t *baseProperties;          // 基礎屬性列表
};
```

- 編譯時就確定的類信息
- 存儲在只讀段，不可修改

### 5. Method (方法結構)

```c
struct method_t {
    SEL name;                                 // 方法名
    const char *types;                        // 方法類型編碼
    IMP imp;                                  // 方法實現（函數指針）
};
```

- **SEL**：方法選擇器，本質是方法名的字符串
- **types**：方法的參數和返回值類型編碼
- **IMP**：函數指針，指向方法的實際實現

### 6. Ivar (成員變量結構)

```c
struct ivar_t {
    int32_t *offset;                          // 偏移量
    const char *name;                         // 變量名
    const char *type;                         // 變量類型編碼
    uint32_t alignment;                       // 對齊方式
    uint32_t size;                            // 大小
};
```

### 7. Property (屬性結構)

```c
struct property_t {
    const char *name;                         // 屬性名
    const char *attributes;                   // 屬性特性（如 atomic、nonatomic、strong 等）
};
```

### 8. Category (分類結構)

```c
struct category_t {
    const char *name;                         // 分類名
    classref_t cls;                           // 類
    struct method_list_t *instanceMethods;    // 實例方法
    struct method_list_t *classMethods;       // 類方法
    struct protocol_list_t *protocols;        // 協議
    struct property_list_t *instanceProperties; // 屬性
};
```

## 重要概念

### SEL、IMP 和 Method 的關係

- **SEL**：方法選擇器，相同名稱的方法有相同的 SEL
- **IMP**：函數指針，指向方法的具體實現
- **Method**：將 SEL 和 IMP 關聯起來的結構

```
[receiver message]
→ objc_msgSend(receiver, @selector(message))
→ 通過 receiver 的 isa 找到類
→ 在類的方法列表中查找 SEL
→ 獲取對應的 IMP
→ 執行 IMP 指向的函數
```

### isa 指針的關系鏈

```
實例對象的 isa → 類
類的 isa → 元類(metaclass)
元類的 isa → 根元類
根元類的 isa → 根元類自己
```

### 方法緩存 (cache_t)

- 使用哈希表存儲最近調用的方法
- 提高方法查找效率，避免每次都遍歷方法列表
- 當緩存滿時會清空重新緩存

## Runtime 的應用場景

1. **方法交換 (Method Swizzling)**：交換兩個方法的實現
2. **動態添加方法**：運行時為類添加新方法
3. **動態添加屬性**：通過關聯對象為類添加屬性
4. **獲取類的詳細信息**：方法列表、屬性列表、成員變量列表等
5. **消息轉發**：處理未實現的方法調用
6. **KVO 的實現**：動態生成子類並重寫 setter 方法
7. **字典轉模型**：通過屬性列表自動映射

## 面試要點

1. **objc_class 和 objc_object 的區別**

   - objc_object 是對象的結構，只有一個 isa 指針
   - objc_class 是類的結構，繼承自 objc_object，包含更多信息

2. **isa 指針的作用**

   - 連接對象和類的紐帶
   - 實現了對象的動態類型和繼承機制

3. **方法查找流程**

   - 先查緩存 → 當前類方法列表 → 父類方法列表 → 消息轉發

4. **Category 的實現原理**

   - 編譯時生成 category_t 結構
   - 運行時將分類的方法、屬性等合併到類的 rw 中
   - 分類的方法會"覆蓋"原類的同名方法（實際是插入到方法列表前面）

5. **為什麼需要元類 (metaclass)**
   - 統一對象模型：類也是對象，需要一個"類"來描述它
   - 類方法存儲在元類中，實例方法存儲在類中

## Swift 語言中的 Runtime

### Swift 有 Runtime 嗎？

**答案：有！但與 Objective-C Runtime 不同。**

Swift 有自己的 Runtime 系統，稱為 **Swift Runtime**，但它的設計理念和實現方式與 Objective-C Runtime 有很大差異。

### Swift Runtime vs Objective-C Runtime

#### 1. 設計理念不同

| 特性     | Objective-C Runtime     | Swift Runtime                |
| -------- | ----------------------- | ---------------------------- |
| 類型系統 | 動態類型                | 靜態類型為主                 |
| 方法調用 | 動態派發 (objc_msgSend) | 靜態派發、虛表派發、消息派發 |
| 反射能力 | 強大的反射和動態性      | 有限的反射（Mirror API）     |
| 性能     | 運行時開銷較大          | 性能優化為主                 |
| 設計目標 | 最大靈活性              | 安全性和性能                 |

#### 2. Swift 的三種方法派發機制

```swift
// 1. 直接派發 (Direct Dispatch) - 最快
// 用於: 值類型的方法、final 方法、static 方法
struct MyStruct {
    func method() { }  // 直接派發
}

// 2. 虛表派發 (Table Dispatch) - 快
// 用於: 純 Swift 類的方法
class PureSwiftClass {
    func method() { }  // 虛表派發
}

// 3. 消息派發 (Message Dispatch) - 最慢但最靈活
// 用於: 繼承自 NSObject 的類、@objc dynamic 方法
class ObjCClass: NSObject {
    @objc dynamic func method() { }  // 消息派發，使用 Objective-C Runtime
}
```

### Swift 類與 Objective-C Runtime 的互操作性

#### 情況 1: 純 Swift 類（不支持 OC Runtime）

```swift
// 純 Swift 類，不繼承 NSObject
class PureSwiftClass {
    var name: String = "Swift"
    func sayHello() { }
}

// ❌ 無法使用 Objective-C Runtime API
// class_copyMethodList(PureSwiftClass.self, &count)  // 獲取不到方法
// class_copyPropertyList(PureSwiftClass.self, &count)  // 獲取不到屬性
```

**原因**：純 Swift 類使用自己的元數據結構，不是 objc_class 結構

#### 情況 2: 繼承自 NSObject 的 Swift 類（支持 OC Runtime）

```swift
// 繼承 NSObject，暴露給 Objective-C Runtime
@objcMembers class SwiftObjCClass: NSObject {
    var name: String = "Swift"
    func sayHello() { }
}

// ✅ 可以使用 Objective-C Runtime API
// class_copyMethodList(SwiftObjCClass.self, &count)  // 可以獲取方法
// class_copyPropertyList(SwiftObjCClass.self, &count)  // 可以獲取屬性
```

**關鍵修飾符**：

- `@objc`：將單個方法/屬性暴露給 Objective-C Runtime
- `@objcMembers`：將類的所有成員暴露給 Objective-C Runtime
- `dynamic`：強制使用消息派發，支持 Method Swizzling

### Swift 的反射機制 - Mirror API

Swift 提供了自己的反射 API，適用於所有 Swift 類型（包括純 Swift 類）：

```swift
class Person {
    var name: String = "張三"
    var age: Int = 25
}

let person = Person()
let mirror = Mirror(reflecting: person)

// 獲取屬性
for child in mirror.children {
    print("\(child.label ?? "unknown"): \(child.value)")
}
// 輸出:
// name: 張三
// age: 25
```

**Mirror API 的限制**：

- 只能讀取，不能修改
- 不能獲取方法列表
- 不能動態添加方法或屬性
- 性能較低

### Swift Runtime 的元數據結構

Swift 有自己的元數據結構（不是 objc_class）：

```c
// Swift 類的元數據結構（簡化版）
struct swift_class_metadata {
    void *isa;                          // 元類型
    void *superclass;                   // 父類
    void *cache[2];                     // 緩存
    void *data;                         // 類數據
    uint32_t flags;                     // 標誌位
    uint32_t instanceAddressPoint;      // 實例地址
    uint32_t instanceSize;              // 實例大小
    uint16_t instanceAlignMask;         // 對齊掩碼
    uint16_t reserved;
    uint32_t classSize;                 // 類大小
    uint32_t classAddressPoint;         // 類地址
    void *description;                  // 類型描述
    // ... 更多字段
};
```

### 實際應用中的建議

#### 何時使用 Objective-C Runtime？

✅ **適合的場景**：

1. 需要 Method Swizzling（如 AOP、埋點）
2. 需要動態添加方法或屬性
3. 需要完整的類信息反射
4. 與 Objective-C 代碼互操作

❌ **不適合的場景**：

1. 純 Swift 項目，追求性能
2. 值類型（struct、enum）
3. 使用 Swift 特性（泛型、協議擴展等）

#### 性能對比

```
直接派發 (Direct Dispatch):        1.0x   最快
虛表派發 (Table Dispatch):          1.1x   略慢
消息派發 (Message Dispatch):        4.4x   最慢
```

### Swift 中使用 Runtime 的示例

```swift
// 1. 必須繼承 NSObject
// 2. 使用 @objc 或 @objcMembers
// 3. 使用 dynamic 支持動態派發

@objcMembers class RuntimeEnabledClass: NSObject {
    var name: String = "Swift"

    // 支持 Method Swizzling
    @objc dynamic func originalMethod() {
        print("Original")
    }
}

// 可以使用 Objective-C Runtime API
var count: UInt32 = 0
if let methods = class_copyMethodList(RuntimeEnabledClass.self, &count) {
    for i in 0..<Int(count) {
        let method = methods[i]
        let selector = method_getName(method)
        print(NSStringFromSelector(selector))
    }
    free(methods)
}
```

### 面試重點

1. **Swift 有 Runtime 嗎？**

   - 有，但與 OC Runtime 是兩個不同的系統
   - Swift 優先使用靜態派發和虛表派發

2. **純 Swift 類可以使用 OC Runtime 嗎？**

   - 不可以，必須繼承 NSObject
   - 需要使用 @objc 或 @objcMembers 暴露給 OC

3. **Swift 的方法派發方式有哪些？**

   - 直接派發、虛表派發、消息派發
   - 不同方式性能差異很大

4. **如何在 Swift 中啟用 Method Swizzling？**

   - 繼承 NSObject + @objc dynamic

5. **Mirror API 和 OC Runtime 的區別？**
   - Mirror: 純 Swift 反射，只讀，適用所有類型
   - OC Runtime: 強大的動態性，可修改，僅適用 NSObject 子類

### 總結

- **Objective-C Runtime**：動態、靈活、強大的反射能力
- **Swift Runtime**：靜態、安全、性能優先
- **互操作**：通過繼承 NSObject 橋接兩個 Runtime 系統
- **選擇建議**：純 Swift 項目優先使用 Swift 特性，需要動態性時才使用 OC Runtime
