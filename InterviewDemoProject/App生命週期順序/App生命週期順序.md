# App 生命週期順序

## 概述

iOS App 的生命週期涉及多個層次的方法調用，包括 AppDelegate 層級和 UIViewController 層級。理解這些方法的調用順序對於正確管理資源、保存狀態和優化性能至關重要。

## 方法說明

### AppDelegate 方法

1. **didFinishLaunchingWithOptions**
   - 時機：App 完成啟動時調用
   - 用途：進行初始化設定、配置第三方庫

2. **applicationWillResignActive**
   - 時機：App 即將失去焦點（變為非活躍狀態）
   - 用途：暫停正在進行的任務、停止計時器

3. **applicationDidEnterBackground**
   - 時機：App 已進入背景
   - 用途：釋放資源、保存用戶數據

4. **applicationWillEnterForeground**
   - 時機：App 即將從背景返回前景
   - 用途：恢復被暫停的任務

5. **applicationDidBecomeActive**
   - 時機：App 已變為活躍狀態
   - 用途：重啟被暫停的任務、刷新 UI

6. **applicationWillTerminate**
   - 時機：App 即將終止
   - 用途：保存數據、清理資源
   - 注意：只在特定情況下調用（非常少見）

### UIViewController 方法

1. **viewDidLoad**
   - 時機：View 載入到記憶體後調用（只調用一次）
   - 用途：初始化 View、設定 UI 元素

2. **viewWillAppear**
   - 時機：View 即將顯示在屏幕上
   - 用途：更新 UI、開始動畫

3. **viewDidAppear**
   - 時機：View 已顯示在屏幕上
   - 用途：開始播放動畫、載入數據

4. **viewWillDisappear**
   - 時機：View 即將從屏幕上移除
   - 用途：保存數據、停止動畫

5. **viewDidDisappear**
   - 時機：View 已從屏幕上移除
   - 用途：清理資源

## 三種場景的生命週期順序

### 場景 1：App 首次啟動（重 build）

```
1. didFinishLaunchingWithOptions     // App 完成啟動
2. viewDidLoad                       // 根 ViewController 的 View 載入
3. viewWillAppear                    // View 即將出現
4. applicationDidBecomeActive        // App 變為活躍狀態
5. viewDidAppear                     // View 已出現
```

**說明：**
- 首次啟動時，AppDelegate 的 `didFinishLaunchingWithOptions` 最先被調用
- 接著根 ViewController 開始載入：`viewDidLoad` → `viewWillAppear`
- 在 View 顯示過程中，App 變為活躍狀態：`applicationDidBecomeActive`
- 最後 View 完全顯示：`viewDidAppear`

**注意：**
- 這些 ViewController 的生命週期方法只在首次顯示時被調用
- 之後 App 進入背景再返回時，**不會**再次調用這些方法

### 場景 2：App 縮下（進入背景）

```
1. applicationWillResignActive       // App 即將失去焦點
2. applicationDidEnterBackground     // App 已進入背景
```

**說明：**
- 使用者按下 Home 鍵或切換到其他 App
- 首先 App 失去焦點：`applicationWillResignActive`
- 最後 App 完全進入背景：`applicationDidEnterBackground`

**重要觀念：**
- ❌ **不會調用** `viewWillDisappear` 和 `viewDidDisappear`
- 原因：ViewController 的 View 並沒有從視圖層級中移除，只是 App 進入背景而已
- ViewController 仍然存在於記憶體中，View 層級結構沒有改變
- `viewWillDisappear`/`viewDidDisappear` 只在 View 真正從視圖層級移除時才會被調用（如 pop、dismiss）

### 場景 3：App 從背景打開（回到前景）

```
1. applicationWillEnterForeground    // App 即將進入前景
2. applicationDidBecomeActive        // App 變為活躍狀態
```

**說明：**
- 使用者從背景切換回 App
- 首先收到將進入前景的通知：`applicationWillEnterForeground`
- App 變為活躍：`applicationDidBecomeActive`

**重要觀念：**
- ❌ **不會調用** `viewWillAppear` 和 `viewDidAppear`
- 原因：ViewController 的 View 一直都在視圖層級中，從未被移除
- View 只是隨著 App 從背景返回而重新可見，但 View 本身沒有重新加入視圖層級
- `viewWillAppear`/`viewDidAppear` 只在 View 真正加入視圖層級時才會被調用（如 push、present）
- ✅ **不會調用** `viewDidLoad`，因為 View 已經在記憶體中

## 重要觀念

### 1. ViewController 生命週期 vs App 生命週期

**ViewController 生命週期方法** (`viewDidLoad`, `viewWillAppear`, `viewDidAppear`, `viewWillDisappear`, `viewDidDisappear`)：
- 只在 View 真正**加入或移除**視圖層級時調用
- 場景：push/pop、present/dismiss、addSubview/removeFromSuperview
- ❌ **不會**在 App 進入背景或返回前景時調用

**App 生命週期方法** (`applicationWillResignActive`, `applicationDidEnterBackground`, `applicationWillEnterForeground`, `applicationDidBecomeActive`)：
- 在 App 狀態改變時調用
- 場景：按 Home 鍵、切換 App、鎖屏、來電等
- ✅ 無論 ViewController 是否改變都會調用

### 2. 常見誤解

❌ **錯誤觀念**：App 進入背景時會調用 `viewWillDisappear` 和 `viewDidDisappear`
✅ **正確觀念**：App 進入背景只會調用 App 層級的方法，不會調用 ViewController 的 View 生命週期方法

❌ **錯誤觀念**：App 從背景返回時會調用 `viewWillAppear` 和 `viewDidAppear`  
✅ **正確觀念**：App 從背景返回只會調用 App 層級的方法，ViewController 的 View 一直都在

### 3. viewDidLoad 只調用一次
- `viewDidLoad` 在 ViewController 的生命週期中只會被調用一次
- 當 App 從背景返回時，不會再次調用
- 只有在 View 被釋放後重新創建時才會再次調用

### 2. Active 與 Inactive 狀態
- **Active（活躍）**: App 在前景且正在接收事件
- **Inactive（非活躍）**: App 在前景但不接收事件（例如來電、控制中心下拉時）
- **Background（背景）**: App 在背景執行代碼或已被暫停

### 3. 狀態轉換
```
Not Running
    ↓ (啟動)
Inactive → Active (前景活躍)
    ↓ (縮下)
Inactive → Background (背景)
    ↓ (恢復)
Inactive → Active (前景活躍)
    ↓ (終止)
Not Running
```

### 4. applicationWillTerminate 的特殊性
- 此方法在現代 iOS 中很少被調用
- iOS 通常會直接終止背景中的 App，不會調用此方法
- 只在以下情況可能被調用：
  - App 在前景時被系統終止
  - 使用者從多工切換器強制關閉 App（但也不保證）

## Scene-Based 生命週期（iOS 13+）

在 iOS 13 及以後，如果使用 SceneDelegate，生命週期方法會略有不同：

### SceneDelegate 方法對應
- `scene(_:willConnectTo:options:)` → 類似 `didFinishLaunchingWithOptions`
- `sceneWillResignActive(_:)` → `applicationWillResignActive`
- `sceneDidEnterBackground(_:)` → `applicationDidEnterBackground`
- `sceneWillEnterForeground(_:)` → `applicationWillEnterForeground`
- `sceneDidBecomeActive(_:)` → `applicationDidBecomeActive`

## 實際應用場景

### 1. 保存數據的最佳時機
- `applicationDidEnterBackground`: ✅ 保存用戶數據和狀態（**最重要**）
- ~~`viewWillDisappear`: 保存 ViewController 特定的狀態~~ ❌ App 進入背景不會調用

### 2. 刷新 UI 的最佳時機
- `viewWillAppear`: 更新即將顯示的內容（僅在 View 真正出現時）
- `applicationWillEnterForeground`: ✅ 從背景返回時刷新數據
- `applicationDidBecomeActive`: ✅ 恢復暫停的動畫或更新

### 3. 資源管理
- `applicationDidEnterBackground`: ✅ 釋放不必要的資源
- `applicationWillEnterForeground`: ✅ 重新載入資源

### 4. 網絡請求
- `viewDidLoad` 或 `viewDidAppear`: 初始化數據載入
- `applicationWillEnterForeground`: ✅ 從背景返回時刷新可能過期的數據

## 常見面試問題

### Q1: App 從背景恢復時會調用 viewDidLoad 嗎？
**答：** 不會。`viewDidLoad` 只在 View 首次載入到記憶體時調用一次。從背景恢復時，只會調用 `applicationWillEnterForeground` 和 `applicationDidBecomeActive`。

**重要補充：** 也不會調用 `viewWillAppear` 和 `viewDidAppear`，因為 View 一直都在視圖層級中。

### Q2: applicationWillResignActive 和 applicationDidEnterBackground 的區別？
**答：** 
- `applicationWillResignActive`: App 失去焦點但仍在屏幕上（可能是 Inactive 狀態，如通知下拉）
- `applicationDidEnterBackground`: App 完全進入背景，不在屏幕上顯示

### Q3: 應該在哪裡保存數據？
**答：** 
- 優先在 `applicationDidEnterBackground` 中保存
- ~~也可以在 `viewWillDisappear` 中保存 ViewController 特定的狀態~~ (❌ 錯誤：App 進入背景不會調用此方法)
- 正確做法：使用 `applicationDidEnterBackground` 保存所有重要數據
- **不要** 依賴 `applicationWillTerminate`，因為它不保證會被調用

### Q4: viewWillAppear 和 viewDidAppear 的選擇？
**答：**
- `viewWillAppear`: 適合更新 UI、準備顯示的內容（此時 View 還未完全顯示）
- `viewDidAppear`: 適合開始動畫、記錄分析事件（此時 View 已完全顯示）

**重要提醒：** 這些方法只在 View 真正進入或離開視圖層級時調用，不會在 App 進入背景或返回前景時調用。

### Q5: App 進入背景時，ViewController 的生命週期方法會被調用嗎？
**答：** ❌ **不會**。App 進入背景或返回前景時，只會調用 App 層級的生命週期方法（`applicationWillResignActive`、`applicationDidEnterBackground`、`applicationWillEnterForeground`、`applicationDidBecomeActive`），不會調用 ViewController 的 View 生命週期方法（`viewWillDisappear`、`viewDidDisappear`、`viewWillAppear`、`viewDidAppear`）。

因為 ViewController 的 View 並沒有從視圖層級中移除，只是隨著 App 一起進入背景而已。

## 總結

理解 App 生命週期的關鍵點：
1. **層次性**：App 級別（AppDelegate）和 View 級別（UIViewController）的方法是分離的
2. **順序性**：方法調用有嚴格的順序，理解這個順序有助於正確處理狀態
3. **用途明確**：每個方法都有其特定的用途和最佳實踐
4. **viewDidLoad 的特殊性**：只調用一次，是初始化的最佳時機
5. **重要區別**：App 進入背景/返回前景 ≠ View 消失/出現
   - App 進入背景時，**不會**調用 `viewWillDisappear`/`viewDidDisappear`
   - App 返回前景時，**不會**調用 `viewWillAppear`/`viewDidAppear`
   - 這些方法只在 View 真正加入或移除視圖層級時調用
6. **背景處理**：正確處理背景和前景切換對用戶體驗至關重要
   - 使用 `applicationDidEnterBackground` 保存數據
   - 使用 `applicationWillEnterForeground` 刷新數據

