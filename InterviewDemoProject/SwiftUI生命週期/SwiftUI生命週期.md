# SwiftUI View 生命週期

## 概述

SwiftUI View 的生命週期與 UIKit 有根本性的不同。SwiftUI 採用聲明式編程範式，View 是值類型（struct），而不是引用類型（class）。這意味著 SwiftUI View 的「生命週期」概念與傳統的 UIKit ViewController 生命週期有很大差異。

## SwiftUI vs UIKit 的核心差異

### UIKit（命令式）

```swift
class MyViewController: UIViewController {
    // 引用類型，有明確的生命週期
    override func viewDidLoad() {
        // 手動配置 UI
    }
}
```

### SwiftUI（聲明式）

```swift
struct MyView: View {
    // 值類型，通過狀態變化驅動 UI 更新
    var body: some View {
        // 聲明 UI 的樣子
        Text("Hello")
    }
}
```

## SwiftUI View 的生命週期階段

### 1. 初始化階段 - `init()`

**時機**：View 結構體被創建時

**特點**：
- SwiftUI View 是值類型（struct），可能被創建多次
- 應該保持輕量級，避免耗時操作
- 不應該有副作用（side effects）

**用途**：
- 初始化 `@State` 屬性
- 設置初始值
- 不應該進行網絡請求或耗時操作

```swift
struct ContentView: View {
    @State private var count = 0
    let initialValue: Int
    
    init(initialValue: Int) {
        self.initialValue = initialValue
        // ❌ 不要在這裡做耗時操作
        // ✅ 只做簡單的初始化
        print("View init")
    }
    
    var body: some View {
        Text("Count: \(count)")
    }
}
```

### 2. 構建階段 - `body`

**時機**：
- 首次渲染時
- 任何依賴的狀態（@State, @Binding, @ObservedObject 等）改變時
- 父視圖重新渲染時

**特點**：
- `body` 是一個計算屬性，會被多次調用
- 必須是純函數（pure function），沒有副作用
- SwiftUI 會自動優化，只更新實際改變的部分

**用途**：
- 聲明 UI 結構
- 根據狀態返回不同的視圖

```swift
struct ContentView: View {
    @State private var isOn = false
    
    var body: some View {
        // ⚠️ body 會被多次調用
        // ❌ 不要在這裡做副作用操作
        print("Body 被調用") // 僅用於演示，實際不建議
        
        return VStack {
            Toggle("開關", isOn: $isOn)
            if isOn {
                Text("已開啟")
            }
        }
    }
}
```

### 3. 出現階段 - `onAppear(perform:)`

**時機**：View 即將出現在螢幕上時

**對應 UIKit**：類似 `viewWillAppear` 和 `viewDidAppear` 的結合

**用途**：
- 加載數據
- 開始動畫
- 註冊通知
- 啟動定時器

**注意**：
- 可能被多次調用（導航返回、Tab 切換等）
- 適合做需要每次顯示都更新的操作

```swift
struct ContentView: View {
    @State private var data: [String] = []
    
    var body: some View {
        List(data, id: \.self) { item in
            Text(item)
        }
        .onAppear {
            // ✅ 在這裡加載數據
            loadData()
            print("View appeared")
        }
    }
    
    func loadData() {
        // 加載數據的邏輯
    }
}
```

### 4. 消失階段 - `onDisappear(perform:)`

**時機**：View 即將從螢幕上消失時

**對應 UIKit**：類似 `viewWillDisappear` 和 `viewDidDisappear` 的結合

**用途**：
- 保存數據
- 停止動畫
- 取消網絡請求
- 移除通知
- 清理資源

```swift
struct ContentView: View {
    @State private var timer: Timer?
    
    var body: some View {
        Text("Hello")
            .onAppear {
                // 開始定時器
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    print("Timer fired")
                }
            }
            .onDisappear {
                // ✅ 清理資源
                timer?.invalidate()
                timer = nil
                print("View disappeared")
            }
    }
}
```

## 現代 SwiftUI 生命週期方法

### 5. 任務管理 - `task(priority:_:)`（iOS 15+）

**時機**：View 出現時開始，消失時自動取消

**特點**：
- 自動管理任務的生命週期
- 支援 async/await
- View 消失時自動取消任務

**用途**：
- 異步數據加載
- 替代 `onAppear` + `onDisappear` 的組合

```swift
struct ContentView: View {
    @State private var data: [String] = []
    
    var body: some View {
        List(data, id: \.self) { item in
            Text(item)
        }
        .task {
            // ✅ 自動管理的異步任務
            // View 消失時會自動取消
            do {
                data = try await fetchData()
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func fetchData() async throws -> [String] {
        // 異步數據獲取
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return ["Item 1", "Item 2", "Item 3"]
    }
}
```

### 6. 狀態變化監聽 - `onChange(of:perform:)`

**時機**：特定狀態值改變時

**用途**：
- 響應狀態變化
- 執行副作用操作
- 數據同步

```swift
struct ContentView: View {
    @State private var searchText = ""
    @State private var results: [String] = []
    
    var body: some View {
        VStack {
            TextField("搜尋", text: $searchText)
            List(results, id: \.self) { result in
                Text(result)
            }
        }
        .onChange(of: searchText) { newValue in
            // ✅ 響應搜尋文字變化
            performSearch(query: newValue)
        }
    }
    
    func performSearch(query: String) {
        // 執行搜尋
    }
}
```

### 7. 數據接收 - `onReceive(_:perform:)`

**時機**：接收到 Publisher 發送的值時

**用途**：
- 監聽 Combine Publisher
- 響應通知
- 處理定時器事件

```swift
struct ContentView: View {
    @State private var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("Current time: \(currentDate.formatted(date: .omitted, time: .standard))")
            .onReceive(timer) { date in
                // ✅ 每秒更新一次
                currentDate = date
            }
    }
}
```

## 完整生命週期流程

```
創建階段：
init() [可能被多次調用]
    ↓
構建階段：
body [首次渲染]
    ↓
出現階段：
onAppear() [View 出現]
task {} [開始異步任務]
    ↓
運行階段：
[狀態變化]
    ↓
body [重新渲染受影響的部分]
onChange(of:) [監聽特定狀態]
onReceive() [接收 Publisher 事件]
    ↓
消失階段：
onDisappear() [View 消失]
task {} [自動取消]
    ↓
[可能再次出現]
onAppear() → ...
    ↓
[View 不再使用]
deinit [僅限包含的引用類型]
```

## 狀態管理與生命週期

### @State - 本地狀態

```swift
struct CounterView: View {
    @State private var count = 0
    
    // @State 的生命週期與 View 實例綁定
    // View 重新創建時，SwiftUI 會保持 @State 的值
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("增加") {
                count += 1
            }
        }
    }
}
```

### @StateObject - 引用類型管理

```swift
class ViewModel: ObservableObject {
    @Published var data: [String] = []
    
    init() {
        print("ViewModel init")
    }
    
    deinit {
        print("ViewModel deinit")
    }
    
    func loadData() {
        // 加載數據
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    // @StateObject 確保 ViewModel 在 View 生命週期內只創建一次
    // 即使 View 被重新創建，ViewModel 實例也會保持
    
    var body: some View {
        List(viewModel.data, id: \.self) { item in
            Text(item)
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}
```

### @ObservedObject - 外部管理的對象

```swift
struct DetailView: View {
    @ObservedObject var viewModel: ViewModel
    
    // @ObservedObject 不擁有對象
    // 對象的生命週期由外部管理
    
    var body: some View {
        Text("Data count: \(viewModel.data.count)")
    }
}
```

## 與 UIKit 生命週期對比

| UIKit | SwiftUI | 說明 |
|-------|---------|------|
| `init` | `init` | 初始化 |
| `loadView()` | - | SwiftUI 自動管理 |
| `viewDidLoad()` | `onAppear()` (首次) + `task {}` | 一次性設置 |
| `viewWillAppear(_:)` | `onAppear()` | 每次出現 |
| `viewDidAppear(_:)` | `onAppear()` | 已經出現 |
| `viewWillLayoutSubviews()` | `GeometryReader` | 獲取尺寸 |
| `viewDidLayoutSubviews()` | - | SwiftUI 自動處理 |
| `viewWillDisappear(_:)` | `onDisappear()` | 即將消失 |
| `viewDidDisappear(_:)` | `onDisappear()` | 已經消失 |
| 手動更新 UI | 狀態變化自動更新 | 聲明式 |

## 常見模式與最佳實踐

### 1. 數據加載

**❌ 錯誤做法：在 init 中加載**

```swift
struct ContentView: View {
    @State private var data: [String] = []
    
    init() {
        // ❌ 不要在 init 中做異步操作
        loadData() // 這不會按預期工作
    }
    
    var body: some View {
        List(data, id: \.self) { Text($0) }
    }
}
```

**✅ 正確做法：使用 task**

```swift
struct ContentView: View {
    @State private var data: [String] = []
    
    var body: some View {
        List(data, id: \.self) { Text($0) }
            .task {
                // ✅ 在這裡加載數據
                data = await loadData()
            }
    }
    
    func loadData() async -> [String] {
        // 異步加載
        return ["Item 1", "Item 2"]
    }
}
```

### 2. 定時器管理

**❌ 錯誤做法：不清理定時器**

```swift
struct ContentView: View {
    @State private var count = 0
    
    var body: some View {
        Text("Count: \(count)")
            .onAppear {
                // ❌ 沒有清理機制
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    count += 1
                }
            }
    }
}
```

**✅ 正確做法：使用 onReceive 或 task**

```swift
struct ContentView: View {
    @State private var count = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("Count: \(count)")
            .onReceive(timer) { _ in
                count += 1
            }
    }
}

// 或使用 task（iOS 15+）
struct ContentView2: View {
    @State private var count = 0
    
    var body: some View {
        Text("Count: \(count)")
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    count += 1
                }
            }
    }
}
```

### 3. 避免在 body 中產生副作用

**❌ 錯誤做法：在 body 中修改狀態**

```swift
struct ContentView: View {
    @State private var count = 0
    
    var body: some View {
        // ❌ 永遠不要這樣做！會導致無限循環
        // count += 1
        
        // ❌ 不要在 body 中做網絡請求
        // fetchData()
        
        return Text("Count: \(count)")
    }
}
```

**✅ 正確做法：使用生命週期方法**

```swift
struct ContentView: View {
    @State private var count = 0
    
    var body: some View {
        Text("Count: \(count)")
            .onAppear {
                // ✅ 在生命週期方法中修改狀態
                count += 1
            }
            .task {
                // ✅ 在 task 中做異步操作
                await fetchData()
            }
    }
}
```

### 4. ViewModel 管理

**✅ 使用 @StateObject 創建**

```swift
struct ParentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ChildView(viewModel: viewModel)
    }
}

struct ChildView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Text(viewModel.title)
    }
}
```

## 性能優化建議

### 1. 避免不必要的重新渲染

```swift
struct ContentView: View {
    @State private var counter = 0
    
    var body: some View {
        VStack {
            // ✅ 使用 equatable 避免不必要的更新
            ExpensiveView(data: someData)
                .equatable()
            
            Button("Increment") {
                counter += 1
            }
        }
    }
}
```

### 2. 使用 @StateObject vs @ObservedObject

```swift
// ✅ 在創建者處使用 @StateObject
struct ParentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ChildView(viewModel: viewModel)
    }
}

// ✅ 在接收者處使用 @ObservedObject
struct ChildView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Text(viewModel.data)
    }
}
```

### 3. 減少 body 的計算複雜度

```swift
struct ContentView: View {
    @State private var items: [Item] = []
    
    // ✅ 將複雜計算提取為計算屬性
    private var sortedItems: [Item] {
        items.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        List(sortedItems) { item in
            ItemRow(item: item)
        }
    }
}
```

## 常見陷阱

### 1. init 被多次調用

```swift
struct ContentView: View {
    init() {
        print("Init called") // 可能被調用多次！
    }
    
    var body: some View {
        Text("Hello")
    }
}
```

**解決方案**：不要依賴 init 的調用次數，使用 @StateObject 或 onAppear

### 2. body 不是生命週期方法

```swift
struct ContentView: View {
    var body: some View {
        print("Body called") // 會被頻繁調用！
        return Text("Hello")
    }
}
```

**解決方案**：不要在 body 中執行副作用操作

### 3. @State 不會在 init 時更新 UI

```swift
struct ContentView: View {
    @State private var text = ""
    
    init() {
        text = "Updated" // ❌ 這樣不會更新 UI
        _text = State(initialValue: "Updated") // ✅ 正確方式
    }
    
    var body: some View {
        Text(text)
    }
}
```

## 面試重點

1. **聲明式 vs 命令式**：理解 SwiftUI 的聲明式編程範式
2. **View 是值類型**：SwiftUI View 是 struct，不是 class
3. **body 不是生命週期方法**：body 是計算屬性，會被多次調用
4. **狀態驅動 UI**：UI 更新由狀態變化自動觸發
5. **生命週期方法**：
   - `onAppear()` - 視圖出現時
   - `onDisappear()` - 視圖消失時
   - `task {}` - 自動管理的異步任務
   - `onChange(of:)` - 監聽狀態變化
6. **狀態管理**：
   - `@State` - 本地狀態
   - `@StateObject` - 創建並擁有引用類型
   - `@ObservedObject` - 不擁有的引用類型
7. **與 UIKit 的對應關係**：能夠對比說明差異
8. **常見陷阱**：避免在 body 中產生副作用，理解 init 的調用時機



