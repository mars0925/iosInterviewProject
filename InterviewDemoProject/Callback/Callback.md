# Callback (回調)

## 什麼是 Callback？

Callback（回調）是一種編程模式，指的是將一個函數作為參數傳遞給另一個函數，並在特定事件發生或任務完成時調用該函數。在 iOS 開發中，Callback 是實現異步操作、事件處理和代碼解耦的重要機制。

## Callback 的核心概念

### 1. 基本定義
- **回調函數**：作為參數傳遞的函數
- **調用者**：接收並在適當時機執行回調函數的函數
- **異步執行**：回調通常用於處理異步操作的結果

### 2. 為什麼需要 Callback？

```
傳統同步執行：
任務A → 等待完成 → 任務B → 等待完成 → 任務C
（阻塞主線程）

使用 Callback 的異步執行：
任務A（開始） → 任務B（開始） → 任務C（開始）
   ↓              ↓              ↓
 完成回調       完成回調       完成回調
（不阻塞主線程）
```

## iOS 中的 Callback 實現方式

### 1. Closure/Block 回調

**Swift Closure 方式：**
```swift
func fetchData(completion: (Result<String, Error>) -> Void) {
    // 異步操作
    DispatchQueue.global().async {
        // 模擬網絡請求
        sleep(2)
        completion(.success("Data loaded"))
    }
}

// 使用
fetchData { result in
    switch result {
    case .success(let data):
        print(data)
    case .failure(let error):
        print(error)
    }
}
```

**Objective-C Block 方式：**
```objective-c
- (void)fetchDataWithCompletion:(void (^)(NSString *data, NSError *error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 異步操作
        if (completion) {
            completion(@"Data loaded", nil);
        }
    });
}
```

### 2. Delegate 模式

```swift
protocol DataFetcherDelegate: AnyObject {
    func dataFetcher(_ fetcher: DataFetcher, didFinishWith data: String)
    func dataFetcher(_ fetcher: DataFetcher, didFailWith error: Error)
}

class DataFetcher {
    weak var delegate: DataFetcherDelegate?
    
    func fetch() {
        // 異步操作完成後回調
        delegate?.dataFetcher(self, didFinishWith: "Data")
    }
}
```

### 3. Notification 通知

```swift
// 發送通知（回調觸發）
NotificationCenter.default.post(name: NSNotification.Name("DataLoaded"), 
                                object: nil, 
                                userInfo: ["data": "some data"])

// 接收通知（回調處理）
NotificationCenter.default.addObserver(self, 
                                       selector: #selector(handleDataLoaded(_:)), 
                                       name: NSNotification.Name("DataLoaded"), 
                                       object: nil)
```

### 4. Target-Action 模式

```swift
button.addTarget(self, 
                 action: #selector(buttonTapped), 
                 for: .touchUpInside)

@objc func buttonTapped() {
    // 按鈕點擊的回調處理
}
```

## Callback 的優缺點

### 優點

1. **異步處理**：不阻塞主線程，提升用戶體驗
2. **代碼解耦**：調用者和執行者分離
3. **靈活性**：可以傳遞不同的處理邏輯
4. **事件驅動**：適合處理用戶交互和系統事件

### 缺點

1. **回調地獄（Callback Hell）**
```swift
fetchUser { user in
    fetchPosts(for: user) { posts in
        fetchComments(for: posts) { comments in
            fetchLikes(for: comments) { likes in
                // 嵌套太深，難以維護
            }
        }
    }
}
```

2. **錯誤處理複雜**：每層都需要處理錯誤
3. **內存管理**：需要注意循環引用問題
4. **調試困難**：異步調用棧不連續

## 現代替代方案

### 1. async/await（Swift 5.5+）

```swift
func fetchData() async throws -> String {
    // 異步操作
    return "Data loaded"
}

// 使用
Task {
    do {
        let data = try await fetchData()
        print(data)
    } catch {
        print(error)
    }
}
```

### 2. Combine Framework

```swift
let publisher = URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: User.self, decoder: JSONDecoder())
    .sink(receiveCompletion: { completion in
        // 處理完成
    }, receiveValue: { user in
        // 處理數據
    })
```

### 3. RxSwift (第三方)

```swift
fetchDataObservable()
    .subscribe(onNext: { data in
        print(data)
    }, onError: { error in
        print(error)
    })
```

## Callback 使用最佳實踐

### 1. 避免循環引用

```swift
// ❌ 錯誤：強引用 self
networkManager.fetchData { data in
    self.updateUI(with: data)
}

// ✅ 正確：使用 weak self
networkManager.fetchData { [weak self] data in
    self?.updateUI(with: data)
}

// ✅ 或使用 unowned（確定 self 不會被釋放）
networkManager.fetchData { [unowned self] data in
    self.updateUI(with: data)
}
```

### 2. 指定執行隊列

```swift
func fetchData(completion: @escaping (String) -> Void) {
    DispatchQueue.global().async {
        let data = "Loaded data"
        // 確保回調在主線程執行
        DispatchQueue.main.async {
            completion(data)
        }
    }
}
```

### 3. 使用 @escaping

```swift
// 如果 closure 在函數返回後才執行，必須標記為 @escaping
func performAsync(completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        completion()
    }
}
```

### 4. 提供有意義的參數

```swift
// ❌ 不好的設計
func fetch(callback: (Any?) -> Void)

// ✅ 好的設計
func fetch(completion: (Result<User, NetworkError>) -> Void)
```

## 常見使用場景

### 1. 網絡請求

```swift
URLSession.shared.dataTask(with: url) { data, response, error in
    // 處理響應
}.resume()
```

### 2. 動畫完成

```swift
UIView.animate(withDuration: 0.3, animations: {
    view.alpha = 0
}) { finished in
    // 動畫完成後的回調
    view.removeFromSuperview()
}
```

### 3. 用戶交互

```swift
let alert = UIAlertController(title: "提示", message: "確認刪除？", preferredStyle: .alert)
alert.addAction(UIAlertAction(title: "確認", style: .destructive) { _ in
    // 用戶確認的回調
    self.deleteItem()
})
```

### 4. 數據庫操作

```swift
database.save(user) { result in
    switch result {
    case .success:
        print("保存成功")
    case .failure(let error):
        print("保存失敗: \(error)")
    }
}
```

## 面試重點

### 常見問題

1. **什麼是 Callback？為什麼需要它？**
   - Callback 是將函數作為參數傳遞，用於異步操作完成時通知調用者

2. **Callback 和 Delegate 的區別？**
   - Callback：一次性調用，適合簡單場景
   - Delegate：可以有多個方法，適合複雜交互

3. **如何避免 Callback Hell？**
   - 使用 Promise/Future 模式
   - 使用 async/await
   - 將回調拆分成獨立函數
   - 使用 Combine 或 RxSwift

4. **Callback 中的內存管理注意事項？**
   - 使用 `[weak self]` 或 `[unowned self]` 避免循環引用
   - 注意 escaping closure 的生命週期

5. **什麼是 @escaping？**
   - 標記 closure 在函數返回後才執行
   - 默認 closure 是 non-escaping 的

## 總結

Callback 是 iOS 開發中處理異步操作的基礎機制，理解它的原理和最佳實踐對於編寫高質量的 iOS 應用至關重要。雖然現代 Swift 提供了 async/await 等更優雅的方案，但 Callback 仍然是理解異步編程的基礎。

