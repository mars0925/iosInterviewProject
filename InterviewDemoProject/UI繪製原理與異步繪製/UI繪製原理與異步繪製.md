# UI 繪製原理與異步繪製

## 一、iOS UI 繪製原理

### 1.1 繪製流程概述

iOS 的 UI 繪製是一個複雜的過程，涉及多個層級和系統組件：

```
應用層 (UIKit)
    ↓
Core Animation
    ↓
OpenGL ES / Metal
    ↓
GPU
    ↓
顯示器
```

### 1.2 UIView 的繪製過程

#### 1.2.1 繪製時機

UIView 的繪製不是實時的，而是在特定時機觸發：

1. **首次顯示**：當 View 第一次加入到視圖層級時
2. **手動標記**：調用 `setNeedsDisplay()` 或 `setNeedsDisplay(_:)`
3. **佈局變化**：當 View 的幾何屬性改變且 `contentMode` 需要重繪時
4. **滾動內容**：某些情況下滾動會觸發重繪

#### 1.2.2 繪製三步驟

**第一步：標記階段 (Mark)**

```
View.setNeedsDisplay()
    ↓
標記 layer 為 dirty
    ↓
等待下一個 RunLoop 週期
```

**第二步：佈局階段 (Layout)**

```
RunLoop 進入更新階段
    ↓
layoutSubviews() 被調用
    ↓
updateConstraints() 處理約束
```

**第三步：繪製階段 (Display)**

```
draw(_:) 方法被調用
    ↓
在 CGContext 中繪製
    ↓
內容被渲染到 backing store
    ↓
提交給 Render Server
```

### 1.3 圖形渲染管線 (Graphics Rendering Pipeline)

#### 1.3.1 CPU 階段

1. **佈局計算**：計算 frame、bounds、center 等
2. **視圖創建**：創建視圖對象
3. **圖像解碼**：解碼壓縮的圖片
4. **繪製準備**：執行 `draw(_:)` 方法，生成渲染指令

#### 1.3.2 GPU 階段

1. **Tiling**：將渲染任務分成小塊
2. **Vertex Processing**：頂點處理
3. **Rasterization**：光柵化，轉換為像素
4. **Fragment Processing**：片段處理，計算每個像素的顏色
5. **Compositing**：圖層合成

### 1.4 Core Animation 與圖層樹

iOS 中每個 UIView 都有一個對應的 CALayer，實際的繪製和動畫都是在 Layer 層級完成的。

#### 三棵樹結構

1. **Model Layer Tree（模型樹）**

   - 我們直接操作的圖層
   - 包含了圖層的目標狀態

2. **Presentation Layer Tree（表現樹）**

   - 動畫執行過程中，顯示當前幀的狀態
   - 通過 `layer.presentation()` 訪問

3. **Render Tree（渲染樹）**
   - 在獨立的進程中（Render Server）
   - 執行實際的繪製工作

### 1.5 離屏渲染 (Offscreen Rendering)

當無法直接在當前屏幕緩衝區繪製時，需要先在離屏緩衝區完成繪製，再切換到屏幕緩衝區。

#### 觸發離屏渲染的情況：

1. **圓角 + 裁切**：`cornerRadius` + `masksToBounds = true`
2. **陰影**：`layer.shadowPath` 未設置時
3. **遮罩**：`layer.mask`
4. **透明度**：`layer.allowsGroupOpacity` + 不透明度 < 1
5. **抗鋸齒**：`layer.allowsEdgeAntialiasing`
6. **光柵化**：`layer.shouldRasterize`

## 二、異步繪製原理

### 2.1 為什麼需要異步繪製

同步繪製的問題：

- `draw(_:)` 在主線程執行
- 複雜繪製會阻塞主線程
- 造成界面卡頓，影響用戶體驗
- 無法充分利用多核 CPU

### 2.2 異步繪製原理

#### 2.2.1 核心思想

將耗時的繪製操作從主線程移到後台線程：

```
主線程                    後台線程
  ↓
標記需要繪製
  ↓                        ↓
獲取繪製參數  ────────→  創建繪製任務
  ↓                        ↓
繼續響應用戶              在 CGContext 中繪製
  ↓                        ↓
  ↓                    生成 CGImage
  ↓                        ↓
設置 layer.contents  ←──  回調主線程
  ↓
顯示結果
```

#### 2.2.2 實現步驟

**步驟 1：準備階段（主線程）**

```swift
// 1. 標記需要繪製
// 2. 獲取當前的繪製參數（大小、文字、顏色等）
// 3. 記錄一個繪製標識（用於判斷是否過期）
```

**步驟 2：繪製階段（後台線程）**

```swift
// 1. 創建位圖上下文
// 2. 在上下文中執行繪製操作
// 3. 從上下文生成 CGImage
```

**步驟 3：顯示階段（主線程）**

```swift
// 1. 檢查繪製是否已過期
// 2. 將生成的 image 設置給 layer.contents
// 3. 觸發顯示更新
```

### 2.3 異步繪製的關鍵技術點

#### 2.3.1 繪製標識（Generation）

使用遞增的計數器標識每次繪製請求：

```swift
var drawingGeneration: Int = 0

func asyncRedraw() {
    drawingGeneration += 1
    let currentGeneration = drawingGeneration

    DispatchQueue.global().async {
        // 繪製前檢查是否過期
        guard currentGeneration == self.drawingGeneration else { return }

        // 執行繪製...

        // 繪製後再次檢查
        DispatchQueue.main.async {
            guard currentGeneration == self.drawingGeneration else { return }
            // 更新顯示
        }
    }
}
```

#### 2.3.2 參數快照（Snapshot）

在主線程捕獲所有繪製需要的參數：

```swift
struct DrawingContext {
    let size: CGSize
    let text: String
    let font: UIFont
    let textColor: UIColor
    let backgroundColor: UIColor
    let scale: CGFloat
    // ... 其他需要的參數
}
```

#### 2.3.3 位圖上下文創建

```swift
// 使用屏幕的 scale 確保清晰度
let scale = UIScreen.main.scale
let colorSpace = CGColorSpaceCreateDeviceRGB()
let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue |
                 CGImageAlphaInfo.premultipliedFirst.rawValue

guard let context = CGContext(
    data: nil,
    width: Int(size.width * scale),
    height: Int(size.height * scale),
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: bitmapInfo
) else { return }

context.scaleBy(x: scale, y: scale)
```

### 2.4 異步繪製的優缺點

#### 優點：

1. **不阻塞主線程**：提高界面流暢度
2. **充分利用多核**：後台線程並行繪製
3. **提升複雜界面性能**：適合大量文字、圖形繪製

#### 缺點：

1. **增加內存使用**：需要額外的緩衝區
2. **增加複雜度**：需要處理線程同步、狀態管理
3. **延遲顯示**：內容不會立即顯示
4. **不適合動畫**：快速變化的內容不適合

### 2.5 適用場景

#### 適合異步繪製：

- 富文本渲染（如微博、Twitter feed）
- 複雜的自定義圖表
- 大量圖形繪製的遊戲界面
- 自定義的複雜控件

#### 不適合異步繪製：

- 簡單的 UI 控件
- 頻繁變化的內容
- 實時動畫
- 內存受限的場景

## 三、性能優化建議

### 3.1 繪製優化

1. **避免不必要的重繪**

   - 只在需要時調用 `setNeedsDisplay()`
   - 使用 `setNeedsDisplay(_:)` 只重繪部分區域

2. **使用 opaque 屬性**

   - 對不透明的 View 設置 `isOpaque = true`
   - 減少圖層混合計算

3. **避免離屏渲染**

   - 使用 `shadowPath` 明確陰影路徑
   - 預先渲染圓角：使用圖片或 mask

4. **光柵化緩存**
   ```swift
   layer.shouldRasterize = true
   layer.rasterizationScale = UIScreen.main.scale
   ```
   - 適用於靜態複雜內容
   - 注意：動態內容會降低性能

### 3.2 圖層優化

1. **減少視圖層級**：扁平化視圖結構
2. **使用 CALayer 替代 UIView**：更輕量
3. **批量更新**：使用 `CATransaction` 包裹多個修改

### 3.3 圖片優化

1. **圖片大小匹配**：圖片尺寸應與顯示尺寸一致
2. **圖片格式選擇**：PNG vs JPEG 權衡透明度和大小
3. **預解碼圖片**：在後台線程提前解碼
4. **使用圖片緩存**：避免重複加載和解碼

## 四、工具和調試

### 4.1 Instruments 工具

- **Core Animation**：檢測離屏渲染、圖層混合
- **Time Profiler**：分析 CPU 使用
- **Allocations**：檢查內存使用

### 4.2 Debug 選項

在 Simulator 中：Debug → Color Blended Layers / Color Offscreen-Rendered Yellow

### 4.3 性能指標

- 保持 60 FPS（每幀 16.67ms）
- 主線程繁忙時間 < 16ms
- GPU 利用率合理（不過高或過低）

## 總結

iOS 的 UI 繪製是一個多層級、多階段的過程，涉及 CPU 和 GPU 的協同工作。理解繪製原理有助於：

1. 優化應用性能，減少卡頓
2. 合理使用異步繪製技術
3. 避免常見的性能陷阱
4. 創建流暢的用戶體驗

異步繪製是一種高級優化技術，應該在確認性能瓶頸後有針對性地使用，而不是盲目應用到所有場景。
