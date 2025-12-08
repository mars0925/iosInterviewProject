# UIView 事件傳遞與響應鏈機制詳解

## 📚 目錄

1. [核心概念](#核心概念)
2. [事件傳遞 (Hit-Testing)](#事件傳遞-hit-testing)
3. [事件響應 (Responder Chain)](#事件響應-responder-chain)
4. [方形按鈕指定區域響應](#方形按鈕指定區域響應)
5. [面試常見問題](#面試常見問題)
6. [代碼示例](#代碼示例)

---

## 核心概念

### 什麼是事件處理？

當用戶觸摸螢幕時，iOS 系統需要完成兩個主要任務：

1. **找到應該接收事件的視圖** （Hit-Testing）
2. **處理和傳遞事件** （Responder Chain）

### 兩個階段的關鍵區別

| 特性 | Hit-Testing（事件傳遞） | Responder Chain（事件響應） |
|------|------------------------|---------------------------|
| **方向** | 父視圖 → 子視圖（由外向內） | 子視圖 → 父視圖（由內向外） |
| **目的** | 找到第一響應者 | 處理事件 |
| **核心方法** | `hitTest(_:with:)`, `point(inside:with:)` | `touchesBegan(_:with:)` 等 |
| **時機** | 觸摸開始時 | 找到響應者後 |

---

## 事件傳遞 (Hit-Testing)

### 工作原理

當用戶觸摸螢幕時，iOS 系統會從最頂層的視圖（UIWindow）開始，逐層向下查找最合適的響應者。

### 流程圖

```
用戶觸摸螢幕
    ↓
UIApplication 接收事件
    ↓
UIWindow.hitTest()
    ↓
是否在範圍內？ (point(inside:))
    ├─ NO → 返回 nil
    └─ YES → 逆序遍歷子視圖
         ↓
    對每個子視圖調用 hitTest()
         ↓
    找到最深層級的視圖
         ↓
    返回該視圖作為第一響應者
```

### 核心方法

#### 1. hitTest(_:with:)

```swift
override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    // Step 1: 檢查視圖是否可以接收事件
    if !isUserInteractionEnabled || isHidden || alpha < 0.01 {
        return nil
    }
    
    // Step 2: 檢查觸摸點是否在視圖範圍內
    if !self.point(inside: point, with: event) {
        return nil
    }
    
    // Step 3: 逆序遍歷子視圖
    for subview in subviews.reversed() {
        let convertedPoint = convert(point, to: subview)
        if let hitView = subview.hitTest(convertedPoint, with: event) {
            return hitView
        }
    }
    
    // Step 4: 如果沒有子視圖處理，則返回自己
    return self
}
```

**重點說明：**
- 返回值是應該接收事件的視圖
- 返回 `nil` 表示不接收事件
- 子視圖是**逆序遍歷**（後添加的先遍歷）

#### 2. point(inside:with:)

```swift
override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    // 判斷觸摸點是否在視圖的 bounds 範圍內
    return bounds.contains(point)
}
```

**重點說明：**
- 返回 `true` 表示點在視圖範圍內
- 這是 `hitTest` 中用於判斷的關鍵方法
- 可以重寫此方法自定義響應區域

### 視圖不響應事件的條件

視圖在以下情況下不會接收觸摸事件：

1. `isUserInteractionEnabled = false`
2. `isHidden = true`
3. `alpha < 0.01`

### 為什麼要逆序遍歷子視圖？

因為後添加的子視圖通常在上層（z-index 更高），應該優先接收事件。

```swift
// 假設有以下視圖層級：
parentView.addSubview(redView)    // 先添加
parentView.addSubview(blueView)   // 後添加

// 當點擊重疊區域時：
// subviews = [redView, blueView]
// subviews.reversed() = [blueView, redView]
// 所以 blueView 會優先被檢測
```

---

## 事件響應 (Responder Chain)

### 工作原理

找到第一響應者後，事件會沿著響應鏈向上傳遞，直到有某個響應者處理它或到達鏈的末端。

### 響應鏈順序

```
觸摸的 View
    ↓
SuperView
    ↓
SuperView 的 SuperView
    ↓
...
    ↓
ViewController
    ↓
UIWindow
    ↓
UIApplication
    ↓
AppDelegate
```

### 核心方法

#### Touch 事件方法

```swift
// 觸摸開始
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("觸摸開始")
    super.touchesBegan(touches, with: event) // 繼續向上傳遞
}

// 觸摸移動
override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("觸摸移動")
    super.touchesMoved(touches, with: event)
}

// 觸摸結束
override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("觸摸結束")
    super.touchesEnded(touches, with: event)
}

// 觸摸取消（例如來電話）
override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("觸摸取消")
    super.touchesCancelled(touches, with: event)
}
```

#### 獲取下一個響應者

```swift
override var next: UIResponder? {
    return super.next
}
```

### 事件傳遞規則

1. **調用 super** → 事件繼續向上傳遞
2. **不調用 super** → 事件在當前響應者停止傳遞
3. **忽略事件** → 什麼都不做，事件自動向上傳遞

### 實際例子

```swift
// 場景：View1 → View2 → View3（層級關係）

// 如果 View3 處理了事件並調用 super：
View3.touchesBegan() → 調用 super
    ↓
View2.touchesBegan() → 調用 super
    ↓
View1.touchesBegan() → 調用 super
    ↓
ViewController.touchesBegan()
```

---

## 方形按鈕指定區域響應

### 問題描述

如何實現一個方形按鈕，但只有中間的圓形區域可以響應點擊？

<img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 200 200'%3E%3Crect width='200' height='200' fill='%23ff6b6b'/%3E%3Ccircle cx='100' cy='100' r='90' fill='white' opacity='0.3'/%3E%3Ctext x='100' y='110' text-anchor='middle' fill='white' font-size='20' font-weight='bold'%3E點我%3C/text%3E%3C/svg%3E" width="200" height="200">

### 解決方案

重寫 `point(inside:with:)` 方法，只有當觸摸點在圓形區域內時才返回 `true`。

### 核心代碼

```swift
class CircularHitButton: UIButton {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 1. 計算按鈕的中心點
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        // 2. 計算圓的半徑（使用較小的邊長）
        let radius = min(bounds.width, bounds.height) / 2
        
        // 3. 計算觸摸點到中心點的距離
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // 4. 判斷距離是否小於半徑
        return distance <= radius
    }
}
```

### 數學原理

#### 勾股定理

```
給定兩點：
- 中心點：(centerX, centerY)
- 觸摸點：(pointX, pointY)

距離計算：
dx = pointX - centerX
dy = pointY - centerY
distance = √(dx² + dy²)

判斷在圓內：
distance ≤ radius
```

#### 圖解

```
方形按鈕 (100 x 100)

┌─────────────┐
│ ╱         ╲ │ ← 角落區域（不響應）
│╱  圓形區   ╲│
││  域（響應） ││
││   center   ││ ← 中心點
│╲           ╱│
│ ╲_________╱ │
└─────────────┘

半徑 = min(100, 100) / 2 = 50
```

### 其他形狀示例

#### 三角形響應區域

```swift
override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    // 使用重心坐標法判斷點是否在三角形內
    let v0 = CGPoint(x: bounds.width / 2, y: 0)        // 頂點
    let v1 = CGPoint(x: 0, y: bounds.height)           // 左下
    let v2 = CGPoint(x: bounds.width, y: bounds.height) // 右下
    
    // 實現三角形內部判斷邏輯
    // ...
}
```

#### 橢圓響應區域

```swift
override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    let radiusX = bounds.width / 2
    let radiusY = bounds.height / 2
    
    let dx = point.x - center.x
    let dy = point.y - center.y
    
    // 橢圓方程：(x/a)² + (y/b)² ≤ 1
    return (dx * dx) / (radiusX * radiusX) + 
           (dy * dy) / (radiusY * radiusY) <= 1
}
```

#### 環形響應區域（圓環）

```swift
override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    let outerRadius = min(bounds.width, bounds.height) / 2
    let innerRadius = outerRadius * 0.6 // 內圈半徑為外圈的 60%
    
    let dx = point.x - center.x
    let dy = point.y - center.y
    let distance = sqrt(dx * dx + dy * dy)
    
    // 在外圈內且在內圈外
    return distance <= outerRadius && distance >= innerRadius
}
```

---

## 面試常見問題

### Q1: Hit-Testing 和 Responder Chain 有什麼區別？

**答案：**

- **Hit-Testing（事件傳遞）**
  - 目的：找到應該接收事件的視圖
  - 方向：從父視圖到子視圖（由外向內）
  - 時機：觸摸事件發生時
  - 方法：`hitTest(_:with:)`, `point(inside:with:)`

- **Responder Chain（事件響應）**
  - 目的：處理和傳遞事件
  - 方向：從子視圖到父視圖（由內向外）
  - 時機：找到第一響應者之後
  - 方法：`touchesBegan(_:with:)` 等

### Q2: 為什麼 hitTest 要逆序遍歷子視圖？

**答案：**

因為後添加的子視圖在視圖層級中位於上層（z-index 更高），當多個視圖重疊時，用戶看到的是最上層的視圖，因此應該優先檢測上層視圖是否接收事件。

```swift
// 例如：
parentView.addSubview(redView)   // 在下層
parentView.addSubview(blueView)  // 在上層

// 當點擊重疊區域時，應該讓 blueView 優先響應
// 所以要逆序遍歷：[blueView, redView]
```

### Q3: 如何擴大按鈕的響應區域？

**答案：**

重寫 `point(inside:with:)` 方法，擴大判斷範圍：

```swift
class ExpandedButton: UIButton {
    var expandedEdge: CGFloat = 20 // 擴大 20 點
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(dx: -expandedEdge, dy: -expandedEdge)
        return expandedBounds.contains(point)
    }
}
```

### Q4: 視圖在什麼情況下不會接收觸摸事件？

**答案：**

1. `isUserInteractionEnabled = false`
2. `isHidden = true`
3. `alpha < 0.01`

```swift
// 例如：
view.isUserInteractionEnabled = false // 不接收事件
view.isHidden = true                   // 不接收事件
view.alpha = 0.001                     // 不接收事件
```

### Q5: 如何阻止事件繼續向上傳遞？

**答案：**

在 touch 方法中不調用 `super`：

```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("事件在這裡處理")
    // 不調用 super.touchesBegan(touches, with: event)
    // 事件不會繼續向上傳遞
}
```

### Q6: UIControl（如 UIButton）為什麼不需要重寫 touch 方法？

**答案：**

UIControl 已經內部實現了完整的事件處理機制：

1. 使用 **Target-Action** 模式
2. 內部追蹤觸摸狀態（normal, highlighted, selected）
3. 提供了各種控制事件（touchUpInside, touchDown 等）

```swift
// UIButton 內部已經處理了觸摸事件
button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

// 不需要重寫 touchesBegan
```

### Q7: 手勢識別器（UIGestureRecognizer）和觸摸事件的關係？

**答案：**

手勢識別器比觸摸事件**優先級更高**：

1. 手勢識別器先接收觸摸事件
2. 如果手勢識別成功，觸摸事件會被取消（調用 `touchesCancelled`）
3. 如果手勢識別失敗，觸摸事件才會繼續傳遞

```swift
// 手勢和觸摸的優先級關係
let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
view.addGestureRecognizer(tapGesture)

// 如果 tapGesture 識別成功，touchesBegan 可能不會被調用
```

### Q8: 如何實現穿透點擊（點擊時穿透到下層視圖）？

**答案：**

方法 1：在 `hitTest` 中返回 `nil`

```swift
override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)
    // 如果點擊到的是自己，返回 nil，讓下層視圖接收
    return hitView == self ? nil : hitView
}
```

方法 2：讓特定區域穿透

```swift
override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)
    
    // 如果點擊的是指定區域，則穿透
    if transparentRect.contains(point) {
        return nil
    }
    
    return hitView
}
```

---

## 代碼示例

### 完整示例：自定義視圖追蹤事件流程

```swift
class EventTrackingView: UIView {
    var viewName: String = "View"
    
    // Hit-Testing 階段
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        print("[\(viewName)] hitTest 被調用")
        return super.hitTest(point, with: event)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let result = super.point(inside: point, with: event)
        print("[\(viewName)] point(inside:) = \(result)")
        return result
    }
    
    // 響應鏈階段
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("[\(viewName)] touchesBegan")
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("[\(viewName)] touchesEnded")
        super.touchesEnded(touches, with: event)
    }
}
```

### 輸出示例

```
// 當點擊最內層視圖時的輸出：

// Hit-Testing 階段（由外向內）
[Window] hitTest 被調用
[Window] point(inside:) = true
[ParentView] hitTest 被調用
[ParentView] point(inside:) = true
[ChildView] hitTest 被調用
[ChildView] point(inside:) = true

// Responder Chain 階段（由內向外）
[ChildView] touchesBegan
[ParentView] touchesBegan
[ViewController] touchesBegan
```

---

## 總結

### 記憶口訣

**Hit-Testing（找人）：從外往內找**
- Window → View → SubView → 最終響應者

**Responder Chain（傳話）：從內往外傳**
- 最終響應者 → SuperView → View → ViewController

### 關鍵要點

1. ✅ Hit-Testing 用於找到第一響應者
2. ✅ Responder Chain 用於處理和傳遞事件
3. ✅ 子視圖逆序遍歷（後添加的先檢測）
4. ✅ `point(inside:)` 可自定義響應區域
5. ✅ 調用 `super` 讓事件繼續傳遞
6. ✅ 不調用 `super` 阻止事件傳遞

### 實用場景

- 🎯 不規則形狀的按鈕（圓形、星形等）
- 🎯 擴大按鈕的點擊區域
- 🎯 實現穿透點擊
- 🎯 自定義手勢處理
- 🎯 遊戲中的碰撞檢測

---

## 參考資料

- [Apple Documentation: UIResponder](https://developer.apple.com/documentation/uikit/uiresponder)
- [Apple Documentation: UIView](https://developer.apple.com/documentation/uikit/uiview)
- [Event Handling Guide for iOS](https://developer.apple.com/library/archive/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/index.html)

---

**本文檔配合項目代碼使用效果最佳** 🎉

- `CustomView.swift` - 演示事件傳遞和響應鏈
- `CircularHitButton.swift` - 演示方形按鈕圓形響應
- `ViewController.swift` - 整合演示和日誌顯示



