# UIView 生命週期

## 概述

UIView 的生命週期是指從創建到顯示在螢幕上，再到被移除的整個過程。理解 UIView 的生命週期對於優化性能和正確處理視圖邏輯至關重要。

## UIView 生命週期方法

### 1. 初始化階段

#### `init(frame:)` 或 `init(coder:)`

- **時機**：當通過程式碼創建 View 時調用 `init(frame:)`，從 Storyboard/XIB 加載時調用 `init(coder:)`
- **用途**：初始化 View 的基本屬性，設置初始狀態
- **注意**：此時 View 還未被添加到視圖層級中，subviews 可能還不完整

### 2. 佈局階段

#### `willMove(toSuperview:)`

- **時機**：在 View 即將被添加到父視圖之前調用
- **參數**：新的父視圖（如果是 nil，表示即將被移除）
- **用途**：可以在這裡做一些準備工作

#### `didMoveToSuperview()`

- **時機**：在 View 已經被添加到父視圖之後調用
- **用途**：可以訪問父視圖，進行一些需要父視圖的配置

#### `willMove(toWindow:)`

- **時機**：在 View 即將被添加到 window 之前調用
- **參數**：新的 window（如果是 nil，表示即將從 window 移除）
- **用途**：判斷 View 是否即將顯示在螢幕上

#### `didMoveToWindow()`

- **時機**：在 View 已經被添加到 window 之後調用
- **用途**：此時 View 已經在視圖層級中，可以進行需要完整視圖層級的操作

### 3. 佈局約束階段

#### `updateConstraints()`

- **時機**：在自動佈局需要更新約束時調用
- **用途**：自定義約束更新邏輯
- **注意**：必須調用 `super.updateConstraints()`

#### `layoutSubviews()`

- **時機**：在 View 的 bounds 改變或需要重新佈局時調用
- **用途**：精確控制子視圖的 frame
- **注意**：不要直接調用此方法，使用 `setNeedsLayout()` 或 `layoutIfNeeded()` 觸發

### 4. 繪製階段

#### `draw(_:)`

- **時機**：當 View 需要重繪時調用
- **用途**：自定義繪製內容
- **注意**：不要直接調用此方法，使用 `setNeedsDisplay()` 觸發
- **性能**：這是一個昂貴的操作，應該避免頻繁調用

### 5. 移除階段

#### `willMove(toSuperview: nil)`

- **時機**：View 即將從父視圖移除時調用
- **用途**：清理資源、移除觀察者等

#### `didMoveToSuperview()` （superview 為 nil）

- **時機**：View 已經從父視圖移除後調用
- **用途**：最終的清理工作

#### `willMove(toWindow: nil)`

- **時機**：View 即將從 window 移除時調用
- **用途**：停止動畫、清理定時器等

#### `didMoveToWindow()` （window 為 nil）

- **時機**：View 已經從 window 移除後調用

## 生命週期完整流程

```
創建 View
    ↓
init(frame:) / init(coder:)
    ↓
willMove(toSuperview:) [新的 superview]
    ↓
didMoveToSuperview()
    ↓
willMove(toWindow:) [新的 window]
    ↓
didMoveToWindow()
    ↓
updateConstraints()
    ↓
layoutSubviews()
    ↓
draw(_:)
    ↓
[View 顯示在螢幕上]
    ↓
[當需要更新時]
    ↓
layoutSubviews() / draw(_:)
    ↓
[當 View 被移除時]
    ↓
willMove(toWindow: nil)
    ↓
didMoveToWindow() [window 為 nil]
    ↓
willMove(toSuperview: nil)
    ↓
didMoveToSuperview() [superview 為 nil]
    ↓
deinit
```

## 重要概念

### 1. Lazy Loading（延遲加載）

- UIView 的許多操作都是延遲執行的，直到真正需要時才會觸發
- 這是為了優化性能

### 2. setNeedsLayout vs layoutIfNeeded

- `setNeedsLayout()`：標記需要重新佈局，在下一個更新週期執行
- `layoutIfNeeded()`：如果有待處理的佈局更新，立即執行

### 3. setNeedsDisplay

- `setNeedsDisplay()`：標記需要重繪，在下一個繪製週期執行
- 只有當 View 的內容發生變化時才需要調用

### 4. 性能優化建議

- 避免在 `layoutSubviews()` 中創建新的 View
- 避免頻繁調用 `setNeedsDisplay()`
- 使用 CALayer 的屬性動畫而不是重複繪製
- 在 `draw(_:)` 中只繪製必要的內容

## 常見問題

### Q1: 什麼時候使用 layoutSubviews()？

當需要精確控制子視圖的位置和大小，且無法通過 Auto Layout 實現時使用。

### Q2: 為什麼不應該直接調用 layoutSubviews() 或 draw(\_:)？

這些方法是系統回調方法，直接調用可能導致不必要的性能開銷或邏輯錯誤。應該使用 `setNeedsLayout()` 或 `setNeedsDisplay()` 來觸發。

### Q3: didMoveToWindow() 和 didMoveToSuperview() 有什麼區別？

- `didMoveToSuperview()`：View 被添加到任何父視圖時調用
- `didMoveToWindow()`：View 被添加到 window（即將顯示在螢幕上）時調用

### Q4: 如何判斷 View 是否在螢幕上顯示？

檢查 `view.window != nil`，如果不為 nil，表示 View 在視圖層級中且連接到 window。

## 面試重點

1. **理解生命週期順序**：從初始化到顯示再到移除的完整流程
2. **知道何時使用各個方法**：不同階段的方法有不同的用途
3. **性能優化**：了解哪些操作是昂貴的，如何避免不必要的調用
4. **與 UIViewController 的關係**：UIView 的生命週期與 UIViewController 的生命週期如何配合
