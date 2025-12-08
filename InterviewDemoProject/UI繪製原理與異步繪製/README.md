# UI 繪製原理與異步繪製演示

## 文件結構

```
UI繪製原理與異步繪製/
├── UI繪製原理與異步繪製.md          # 理論說明文檔
├── SyncDrawingView.swift            # 同步繪製實現
├── AsyncDrawingView.swift           # 異步繪製實現
├── DrawingDemoViewController.swift  # 演示界面
└── README.md                        # 本文件
```

## 使用說明

### 1. 在主 ViewController 中添加導航

在 `ViewController.swift` 中添加按鈕來導航到演示頁面：

```swift
let drawingDemoButton = UIButton(type: .system)
drawingDemoButton.setTitle("UI 繪製演示", for: .normal)
drawingDemoButton.addTarget(self, action: #selector(showDrawingDemo), for: .touchUpInside)

@objc func showDrawingDemo() {
    let demoVC = DrawingDemoViewController()
    navigationController?.pushViewController(demoVC, animated: true)
    // 或者使用 present
    // present(demoVC, animated: true)
}
```

### 2. 運行演示

1. 啟動應用後，點擊"UI 繪製演示"按鈕
2. 查看兩個繪製區域：
   - 紅色邊框：同步繪製（在主線程執行）
   - 綠色邊框：異步繪製（在後台線程執行）

### 3. 測試步驟

#### 測試一：觀察繪製耗時
1. 點擊"🔄 觸發重繪"按鈕
2. 查看 Xcode 控制台輸出
3. 對比兩種方式的耗時差異

輸出示例：
```
==================================================
第 1 次重繪開始
==================================================
🔴 同步繪製耗時: 45.23ms
🟢 異步繪製耗時: 42.18ms
```

#### 測試二：檢測主線程卡頓
1. 開啟"繪製複雜圖形"開關
2. 拖動滑桿
3. 觀察滑桿是否流暢：
   - 同步繪製時，如果滑桿卡頓，說明主線程被阻塞
   - 異步繪製時，滑桿應該保持流暢

#### 測試三：性能對比
1. 連續點擊"觸發重繪"按鈕多次
2. 同時拖動滑桿
3. 感受兩種方式對主線程的影響

## 核心代碼解析

### 同步繪製 (SyncDrawingView)

```swift
override func draw(_ rect: CGRect) {
    // 在主線程同步執行
    // 繪製操作會阻塞主線程
    drawComplexGraphics(in: context, rect: rect)
    drawText(in: rect)
}
```

### 異步繪製 (AsyncDrawingView)

```swift
private func asyncRedraw() {
    drawingGeneration += 1  // 防止過期繪製
    let currentGeneration = drawingGeneration
    
    // 在主線程捕獲參數
    let context = DrawingContext(...)
    
    // 在後台線程繪製
    drawingQueue.async {
        guard currentGeneration == self.drawingGeneration else { return }
        let image = drawContent(with: context)
        
        // 回到主線程更新顯示
        DispatchQueue.main.async {
            self.layer.contents = image
        }
    }
}
```

## 性能優化要點

### 1. Generation Counter（代數計數器）
- 避免過期的繪製覆蓋新的繪製
- 在繪製前後都要檢查

### 2. 參數快照
- 在主線程捕獲所有繪製參數
- 避免後台線程訪問 UI 屬性

### 3. 位圖上下文創建
- 使用正確的 scale（UIScreen.main.scale）
- 選擇合適的 colorSpace 和 bitmapInfo

### 4. 線程安全
- 繪製在後台線程
- 更新 UI 必須回到主線程

## 適用場景

### 適合異步繪製：
✅ 複雜的富文本渲染  
✅ 大量圖形繪製  
✅ 自定義圖表  
✅ 靜態內容的複雜 UI  

### 不適合異步繪製：
❌ 簡單的 UI 控件  
❌ 頻繁變化的內容  
❌ 實時動畫  
❌ 內存受限的場景  

## 注意事項

1. **內存使用**：異步繪製需要額外的緩衝區
2. **延遲顯示**：繪製結果不會立即顯示
3. **複雜度增加**：需要處理線程同步和狀態管理
4. **調試困難**：多線程問題較難定位

## 擴展練習

1. 添加 FPS 監測，實時顯示幀率
2. 使用 Instruments 的 Core Animation 工具分析性能
3. 實現一個複雜的聊天氣泡，對比兩種繪製方式
4. 添加取消機制，支持快速滾動時取消繪製

## 相關資料

- Apple 官方文檔：[Drawing and Printing Guide](https://developer.apple.com/library/archive/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/Introduction/Introduction.html)
- WWDC 2012：iOS App Performance: Graphics and Animations
- YYText 框架：異步繪製的實際應用案例

