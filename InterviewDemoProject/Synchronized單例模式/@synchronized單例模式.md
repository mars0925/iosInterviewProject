# @synchronized 在單例模式中保證對象唯一性

## 什麼是 @synchronized？

`@synchronized` 是 Objective-C 中的一個語法糖，用於創建互斥鎖（Mutex Lock）。它可以確保同一時間只有一個線程能夠執行被保護的代碼塊。

## 為什麼單例需要 @synchronized？

在多線程環境下，如果沒有同步機制，多個線程可能同時進入創建實例的代碼，導致創建多個實例：

```
時間線：
Thread 1: if (instance == nil) → true  → 創建實例 A
Thread 2: if (instance == nil) → true  → 創建實例 B  ← 問題！
```

## Objective-C 中的 @synchronized 單例

```objc
@implementation MySingleton

+ (instancetype)sharedInstance {
    static MySingleton *instance = nil;
    
    // @synchronized 確保同一時間只有一個線程執行這段代碼
    @synchronized (self) {
        if (instance == nil) {
            instance = [[MySingleton alloc] init];
        }
    }
    
    return instance;
}

@end
```

## Swift 中的等效實現

Swift 沒有 `@synchronized` 關鍵字，但可以使用以下方式：

### 方式一：objc_sync_enter/exit（@synchronized 的底層實現）

```swift
func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try closure()
}

class MySingleton {
    private static var _instance: MySingleton?
    
    static func sharedInstance() -> MySingleton {
        synchronized(self) {
            if _instance == nil {
                _instance = MySingleton()
            }
            return _instance!
        }
    }
}
```

### 方式二：Swift 推薦寫法（dispatch_once 語義）

```swift
class MySingleton {
    static let shared = MySingleton()
    private init() {}
}
```

這是 Swift 中**最推薦**的單例寫法，因為：
- `static let` 自動具有 `dispatch_once` 語義
- 系統保證線程安全
- 懶加載（首次訪問時才創建）
- 代碼簡潔

## @synchronized 工作原理

```
┌─────────────────────────────────────────────────────────┐
│  Thread 1        Thread 2         Thread 3              │
│     │               │                │                  │
│     ▼               ▼                ▼                  │
│  [進入同步區]    [等待鎖...]       [等待鎖...]           │
│     │                                                   │
│     ▼                                                   │
│  [instance == nil? YES]                                 │
│     │                                                   │
│     ▼                                                   │
│  [創建實例]                                              │
│     │                                                   │
│     ▼                                                   │
│  [退出同步區，釋放鎖]                                    │
│                 │                │                      │
│                 ▼                │                      │
│           [進入同步區]         [等待鎖...]              │
│                 │                                       │
│                 ▼                                       │
│           [instance == nil? NO]                        │
│                 │                                       │
│                 ▼                                       │
│           [返回已有實例]                                │
│                 │                                       │
│                 ▼                                       │
│           [退出同步區]                                  │
│                             │                           │
│                             ▼                           │
│                       [Thread 3 同理]                   │
└─────────────────────────────────────────────────────────┘
```

## 各種實現方式比較

| 方式 | 線程安全 | 性能 | 適用場景 |
|------|----------|------|----------|
| @synchronized (ObjC) | ✅ | 中等 | Objective-C 項目 |
| objc_sync_enter/exit | ✅ | 中等 | ObjC/Swift 混編 |
| NSLock | ✅ | 較好 | 需要精確控制鎖 |
| DispatchQueue (serial) | ✅ | 較好 | GCD 風格代碼 |
| static let (Swift) | ✅ | 最佳 | **Swift 推薦** |

## 面試要點

1. **@synchronized 的本質**：
   - 底層調用 `objc_sync_enter()` 和 `objc_sync_exit()`
   - 以傳入的對象作為鎖的標識符

2. **為什麼傳入 self（類對象）**：
   - 確保同一個類的所有調用共用一把鎖
   - 不同類可以有不同的鎖，互不影響

3. **Swift 為什麼沒有 @synchronized**：
   - Swift 設計更傾向於值類型和不可變性
   - `static let` 已經提供了安全的單例語義
   - 如需要，可以使用底層函數實現

4. **雙重檢查鎖定（Double-Checked Locking）**：
   ```swift
   static func sharedInstance() -> MySingleton {
       if _instance == nil {  // 第一次檢查（無鎖）
           synchronized(self) {
               if _instance == nil {  // 第二次檢查（有鎖）
                   _instance = MySingleton()
               }
           }
       }
       return _instance!
   }
   ```
   - 優化性能：大部分情況不需要獲取鎖

## 總結

- **Objective-C**：使用 `@synchronized(self)` 包裹單例創建代碼
- **Swift**：直接使用 `static let shared = MyClass()` 即可
- **關鍵原理**：確保同一時間只有一個線程能執行實例化代碼

