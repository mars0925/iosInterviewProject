# UIViewController 生命週期

## 概述

UIViewController 的生命週期是指從 ViewController 創建、視圖加載、顯示、隱藏到最終銷毀的完整過程。理解 UIViewController 的生命週期對於正確管理視圖、優化性能和避免內存洩漏至關重要。

## UIViewController 生命週期方法

### 1. 初始化階段

#### `init(nibName:bundle:)` 或 `init(coder:)`

- **時機**：ViewController 對象創建時調用
- **用途**：初始化 ViewController 的基本屬性
- **注意**：此時 view 還未創建，不能訪問任何 UI 元素

```swift
// 程式碼創建
init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    // 初始化工作
}

// 從 Storyboard 創建
required init?(coder: NSCoder) {
    super.init(coder: coder)
    // 初始化工作
}
```

### 2. 視圖加載階段

#### `loadView()`

- **時機**：在第一次訪問 `view` 屬性時調用
- **用途**：創建或加載視圖層級
- **注意**：
  - 如果重寫此方法，必須創建並賦值給 `self.view`
  - 不要調用 `super.loadView()` 如果你完全自定義視圖
  - 系統會自動從 Storyboard/XIB 或創建空白 UIView

```swift
override func loadView() {
    // 自定義視圖創建
    let customView = UIView()
    customView.backgroundColor = .white
    self.view = customView
}
```

#### `viewDidLoad()`

- **時機**：視圖加載完成後調用（只調用一次）
- **用途**：
  - 配置視圖
  - 添加子視圖
  - 設置約束
  - 加載數據
  - 註冊通知
- **注意**：此時視圖已經創建，但尚未顯示在螢幕上

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // 一次性的視圖設置
    setupUI()
    loadData()
}
```

### 3. 視圖顯示階段

#### `viewWillAppear(_:)`

- **時機**：視圖即將添加到視圖層級並顯示在螢幕上之前
- **參數**：`animated` - 是否有動畫
- **用途**：
  - 更新 UI（可能因其他頁面操作而改變的數據）
  - 開始動畫
  - 註冊鍵盤通知
- **注意**：每次視圖即將顯示時都會調用

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // 視圖即將出現時的準備工作
    refreshData()
    navigationController?.setNavigationBarHidden(false, animated: animated)
}
```

#### `viewWillLayoutSubviews()`

- **時機**：視圖即將佈局其子視圖之前
- **用途**：在自動佈局之前進行額外的調整
- **注意**：可能被多次調用

```swift
override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    // 佈局前的準備
}
```

#### `viewDidLayoutSubviews()`

- **時機**：視圖完成子視圖佈局之後
- **用途**：
  - 獲取最終的視圖尺寸
  - 進行依賴於視圖尺寸的操作
- **注意**：可能被多次調用（旋轉、鍵盤彈出等）

```swift
override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // 根據最終的佈局調整 UI
    updateCircleRadius()
}
```

#### `viewDidAppear(_:)`

- **時機**：視圖已經添加到視圖層級並完全顯示在螢幕上
- **參數**：`animated` - 是否有動畫
- **用途**：
  - 開始動畫或視頻播放
  - 開始定時器
  - 開始監聽傳感器數據
- **注意**：每次視圖顯示完成後都會調用

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // 視圖已完全顯示
    startAnimation()
    beginRefresh()
}
```

### 4. 視圖消失階段

#### `viewWillDisappear(_:)`

- **時機**：視圖即將從視圖層級中移除之前
- **參數**：`animated` - 是否有動畫
- **用途**：
  - 保存數據
  - 移除鍵盤通知
  - 暫停動畫
- **注意**：每次視圖即將消失時都會調用

```swift
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // 視圖即將消失
    saveData()
    stopAnimation()
}
```

#### `viewDidDisappear(_:)`

- **時機**：視圖已經從視圖層級中移除
- **參數**：`animated` - 是否有動畫
- **用途**：
  - 停止佔用資源的操作
  - 停止定時器
  - 移除觀察者
- **注意**：每次視圖消失後都會調用

```swift
override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    // 視圖已消失
    stopTimer()
    pauseVideo()
}
```

### 5. 記憶體警告

#### `didReceiveMemoryWarning()`

- **時機**：系統記憶體不足時調用
- **用途**：
  - 釋放不必要的資源
  - 清理緩存
  - 釋放可重新創建的對象
- **注意**：不要釋放當前正在使用的資源

```swift
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // 清理緩存和不必要的資源
    imageCache.removeAll()
}
```

### 6. 銷毀階段

#### `deinit`

- **時機**：ViewController 對象即將被銷毀時調用
- **用途**：
  - 移除觀察者
  - 停止通知
  - 釋放資源
- **注意**：自動調用，不需要調用 super

```swift
deinit {
    // 清理工作
    NotificationCenter.default.removeObserver(self)
    print("ViewController 被銷毀")
}
```

## 完整生命週期流程

```
創建階段：
init(nibName:bundle:) / init(coder:)
    ↓

視圖加載：
loadView() [系統自動調用，創建 view]
    ↓
viewDidLoad() [一次性設置]
    ↓

首次顯示：
viewWillAppear(_:)
    ↓
viewWillLayoutSubviews()
    ↓
viewDidLayoutSubviews()
    ↓
viewDidAppear(_:)
    ↓

[視圖在螢幕上顯示]
    ↓

離開頁面：
viewWillDisappear(_:)
    ↓
viewDidDisappear(_:)
    ↓

[可能再次顯示]
viewWillAppear(_:) → ... → viewDidAppear(_:)
    ↓

[頁面被銷毀]
viewWillDisappear(_:)
    ↓
viewDidDisappear(_:)
    ↓
deinit
```

## 重要概念

### 1. viewDidLoad 只調用一次

- `viewDidLoad()` 在 ViewController 的生命週期中只調用一次
- 適合進行一次性的設置工作
- 即使 view 被移除再顯示，也不會再次調用

### 2. viewWillAppear 和 viewDidAppear 會多次調用

- 每次視圖即將/完成顯示時都會調用
- 適合進行需要每次更新的操作
- 從其他頁面返回時也會調用

### 3. 視圖加載的延遲性

- View 不是在 ViewController 創建時就加載的
- 只有在第一次訪問 `view` 屬性時才會觸發 `loadView()`
- 這是一種性能優化機制（Lazy Loading）

### 4. 佈局方法可能被多次調用

- `viewWillLayoutSubviews()` 和 `viewDidLayoutSubviews()` 可能被多次調用
- 設備旋轉、鍵盤顯示/隱藏、視圖尺寸改變時都會觸發
- 不要在這些方法中做過於耗時的操作

### 5. 避免記憶體洩漏

- 在 `deinit` 中移除所有觀察者和通知
- 使用 `weak` 或 `unowned` 打破循環引用
- 及時停止定時器和動畫

## 常見使用場景

### viewDidLoad - 一次性設置

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    // ✅ 配置導航欄
    title = "首頁"

    // ✅ 添加子視圖
    view.addSubview(tableView)

    // ✅ 設置約束
    setupConstraints()

    // ✅ 註冊通知（記得在 deinit 移除）
    NotificationCenter.default.addObserver(...)

    // ✅ 初始化數據
    loadInitialData()
}
```

### viewWillAppear - 每次顯示前的更新

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // ✅ 刷新數據（可能在其他頁面被修改）
    refreshUserInfo()

    // ✅ 顯示/隱藏導航欄
    navigationController?.setNavigationBarHidden(false, animated: animated)

    // ✅ 更新狀態欄
    UIApplication.shared.statusBarStyle = .lightContent

    // ✅ 註冊鍵盤通知
    registerKeyboardNotifications()
}
```

### viewDidAppear - 動畫和追蹤

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // ✅ 開始動畫
    startWelcomeAnimation()

    // ✅ 開始視頻播放
    videoPlayer.play()

    // ✅ 頁面追蹤（分析）
    Analytics.logPageView("HomePage")
}
```

### viewWillDisappear - 保存和清理

```swift
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // ✅ 保存用戶輸入
    saveUserInput()

    // ✅ 停止動畫
    stopAnimation()

    // ✅ 移除鍵盤通知
    removeKeyboardNotifications()
}
```

### viewDidDisappear - 釋放資源

```swift
override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    // ✅ 停止定時器
    timer?.invalidate()

    // ✅ 暫停視頻
    videoPlayer.pause()

    // ✅ 停止位置更新
    locationManager.stopUpdatingLocation()
}
```

## 常見錯誤

### ❌ 錯誤 1：在 viewDidLoad 中使用視圖尺寸

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // ❌ 此時視圖尺寸可能不正確
    let center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
}
```

**✅ 正確做法**：在 `viewDidLayoutSubviews()` 中使用

```swift
override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // ✅ 此時視圖尺寸已確定
    circleView.center = view.center
}
```

### ❌ 錯誤 2：忘記調用 super

```swift
override func viewWillAppear(_ animated: Bool) {
    // ❌ 忘記調用 super
    refreshData()
}
```

**✅ 正確做法**：始終調用 super

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated) // ✅
    refreshData()
}
```

### ❌ 錯誤 3：在 viewDidLoad 中做耗時操作

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // ❌ 阻塞主線程
    let data = downloadLargeFile()
}
```

**✅ 正確做法**：在後台執行

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // ✅ 異步執行
    Task {
        let data = await downloadLargeFile()
        updateUI(with: data)
    }
}
```

### ❌ 錯誤 4：忘記移除觀察者

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(...)
    // ❌ 忘記在 deinit 移除
}
```

**✅ 正確做法**：在 deinit 中移除

```swift
deinit {
    NotificationCenter.default.removeObserver(self) // ✅
}
```

## 與 UIView 生命週期的關係

```
UIViewController               UIView
      |                           |
   viewDidLoad                    |
      |                           |
  viewWillAppear              willMove(toWindow:)
      |                           |
viewWillLayoutSubviews        layoutSubviews()
      |                           |
viewDidLayoutSubviews          draw(_:)
      |                           |
  viewDidAppear               didMoveToWindow()
      |                           |
      [視圖顯示在螢幕上]
      |                           |
 viewWillDisappear          willMove(toWindow: nil)
      |                           |
 viewDidDisappear           didMoveToWindow()
```

## 性能優化建議

1. **在正確的時機做正確的事**

   - 一次性設置 → `viewDidLoad()`
   - 需要更新的內容 → `viewWillAppear(_:)`
   - 依賴尺寸的操作 → `viewDidLayoutSubviews()`

2. **避免在生命週期方法中做耗時操作**

   - 使用異步操作
   - 顯示 loading 指示器
   - 優化數據加載策略

3. **合理管理資源**

   - 在 `viewDidDisappear(_:)` 中釋放不需要的資源
   - 在 `didReceiveMemoryWarning()` 中清理緩存
   - 在 `deinit` 中做最終清理

4. **避免記憶體洩漏**
   - 使用 `weak` 或 `unowned` 打破循環引用
   - 及時移除觀察者和通知
   - 停止定時器和動畫

## 面試重點

1. **生命週期順序**：能夠準確說出各個方法的調用順序
2. **調用時機**：理解每個方法在什麼情況下被調用
3. **使用場景**：知道在哪個方法中做什麼事情最合適
4. **常見問題**：
   - `viewDidLoad` 和 `viewWillAppear` 的區別
   - 為什麼不能在 `viewDidLoad` 中依賴視圖尺寸
   - 如何避免記憶體洩漏
   - `viewWillLayoutSubviews` 會被調用多少次
5. **與 UIView 生命週期的關係**：理解兩者如何配合工作
