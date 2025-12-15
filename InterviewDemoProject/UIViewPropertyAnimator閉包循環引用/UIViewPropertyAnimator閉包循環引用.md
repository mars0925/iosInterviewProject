# UIViewPropertyAnimator 閉包循環引用問題

## 問題分析

### testLeakOne() - 明顯的循環引用

```swift
func testLeakOne() {
    let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { 
        self.view.backgroundColor = .red
    }
    anim.addCompletion { _ in     
        self.view.backgroundColor = .white 
    }
    self.closureStorage = anim
}
```

**循環引用鏈：**
1. `self`（ViewController）持有 `closureStorage`（strong reference）
2. `closureStorage` 持有 `anim`（UIViewPropertyAnimator）
3. `anim` 的 animations closure 和 completion closure 都捕獲了 `self`（strong reference）
4. 形成循環：**self → closureStorage → anim → closures → self**

**結果：** ViewController 無法被釋放，造成記憶體洩漏。

### testLeakTwo() - 隱藏的循環引用

```swift
func testLeakTwo() {
    let view = self.view
    let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { 
        view?.backgroundColor = .red 
    }
    anim.addCompletion { _ in 
        view?.backgroundColor = .white 
    }
    self.closureStorage = anim
}
```

**為什麼仍然洩漏？**

雖然看起來沒有直接使用 `self`，但這種做法仍有問題：

1. **`let view = self.view` 這行代碼本身就捕獲了 `self`**
   - 在某些情況下，編譯器可能會將這個操作編譯成捕獲 `self` 的形式
   
2. **View 的所有權鏈問題**
   - `self.view` 是 ViewController 的主視圖
   - Closure 持有 `view` 的 strong reference
   - `view` 雖然不直接持有 ViewController，但它們之間有隱式的關聯
   
3. **UIViewPropertyAnimator 的特殊性**
   - 當 animator 儲存在 `self.closureStorage` 中時
   - animator 持有的 closure 會一直存在
   - 直到 animator 被釋放或動畫完成並被清理

4. **主要問題依然是：** `self` → `closureStorage` → `anim` → `self`
   - 即使透過 view 變數間接引用，循環引用鏈依然存在

## 正確的解決方案

### 方案一：使用 [weak self]

```swift
func testNoLeak() {
    let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { [weak self] in
        self?.view.backgroundColor = .red
    }
    anim.addCompletion { [weak self] _ in     
        self?.view.backgroundColor = .white 
    }
    self.closureStorage = anim
}
```

### 方案二：使用 [unowned self]

```swift
func testNoLeakUnowned() {
    let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { [unowned self] in
        self.view.backgroundColor = .red
    }
    anim.addCompletion { [unowned self] _ in     
        self.view.backgroundColor = .white 
    }
    self.closureStorage = anim
}
```

**注意：** 只有在確定 `self` 的生命週期一定比 closure 長時才使用 `unowned`，否則使用 `weak` 更安全。

### 方案三：動畫完成後清理

```swift
func testNoLeakWithCleanup() {
    let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { [weak self] in
        self?.view.backgroundColor = .red
    }
    anim.addCompletion { [weak self] _ in     
        self?.view.backgroundColor = .white
        self?.closureStorage = nil  // 清理引用
    }
    self.closureStorage = anim
    anim.startAnimation()
}
```

## 為什麼 testLeakTwo 的方法不可靠？

### 常見誤解

很多開發者認為將 `self.view` 賦值給局部變數就能避免循環引用，但這是錯誤的：

```swift
let view = self.view  // ❌ 這不能解決問題
```

### 原因：

1. **仍然捕獲了 self**
   - Swift 的 closure 捕獲機制是基於值捕獲
   - 當你在 closure 外部訪問 `self.view` 時，實際上已經建立了與 `self` 的關聯
   
2. **對象圖（Object Graph）的問題**
   - 即使 closure 只持有 `view`，而不直接持有 `self`
   - 但 `self` → `closureStorage` → `anim` 的強引用鏈依然存在
   - 只要 animator 不被釋放，`self` 就不會被釋放

3. **View 和 ViewController 的關聯**
   - UIViewController 的 `view` 屬性是 strong reference
   - View hierarchy 中可能存在回調或 delegate 指向 ViewController
   - 這些隱式關聯可能導致意外的循環引用

## 檢測記憶體洩漏的方法

### 1. Instruments - Leaks 工具
- 使用 Xcode 的 Instruments → Leaks
- 可以實時檢測記憶體洩漏

### 2. Memory Graph Debugger
- 在 Xcode 中運行 app
- 點擊 Debug Memory Graph 按鈕
- 查看對象之間的引用關係

### 3. deinit 方法
```swift
deinit {
    print("ViewController is being deallocated")
}
```
如果 ViewController 沒有被釋放，deinit 就不會被調用。

## 最佳實踐

### 1. 預設使用 [weak self]

在 closure 中訪問 `self` 時，除非有特殊原因，否則應該使用 `[weak self]`：

```swift
{ [weak self] in
    guard let self = self else { return }
    // 使用 self
}
```

### 2. 動畫完成後清理引用

如果 animator 只是臨時使用，動畫結束後應該清理：

```swift
anim.addCompletion { [weak self] _ in
    // 動畫邏輯
    self?.animatorStorage = nil  // 清理
}
```

### 3. 理解 UIViewPropertyAnimator 的生命週期

- `UIViewPropertyAnimator` 本身會持有 animations 和 completion closures
- 如果將 animator 儲存為屬性，它會一直存在
- 如果不儲存，animator 在動畫結束後會自動被釋放

### 4. 不要依賴"局部變數技巧"

```swift
// ❌ 錯誤做法 - 不可靠
let view = self.view
closure { view?.doSomething() }

// ✅ 正確做法 - 明確使用 weak self
closure { [weak self] in 
    self?.view.doSomething() 
}
```

## 總結

### testLeakOne 的問題：
- **明顯的循環引用**：closures 直接捕獲 `self`

### testLeakTwo 的問題：
- **隱藏的循環引用**：雖然使用局部變數，但無法真正打破引用鏈
- **不是可靠的解決方案**：依然可能導致記憶體洩漏

### 正確做法：
1. **使用 `[weak self]` 或 `[unowned self]`** 明確打破循環引用
2. **動畫結束後清理引用** 避免長期持有 animator
3. **使用 Memory Graph Debugger** 檢測和確認沒有洩漏
4. **添加 deinit 方法** 確認對象正確釋放

### 面試要點：
- 理解 Swift closure 的捕獲機制
- 識別循環引用的模式
- 知道何時使用 weak vs unowned
- 理解 UIViewPropertyAnimator 的生命週期
- 掌握記憶體洩漏的檢測方法

