//
//  AsyncDrawingView.swift
//  InterviewDemoProject
//
//  異步繪製演示：在後台線程執行繪製，不會阻塞主線程

import UIKit

class AsyncDrawingView: UIView {
    
    // MARK: - Properties
    
    /// 要顯示的文字內容
    var text: String = "異步繪製測試\n這是一段較長的文字內容，用於測試異步繪製的性能。\n異步繪製在後台線程執行，不會阻塞主線程，界面保持流暢。" {
        didSet {
            asyncRedraw()
        }
    }
    
    /// 文字顏色
    var textColor: UIColor = .black {
        didSet {
            asyncRedraw()
        }
    }
    
    /// 文字字體
    var font: UIFont = .systemFont(ofSize: 16) {
        didSet {
            asyncRedraw()
        }
    }
    
    /// 是否繪製複雜圖形
    var drawComplexShapes: Bool = true {
        didSet {
            asyncRedraw()
        }
    }
    
    /// 繪製代數：用於標識繪製請求，避免過期的繪製覆蓋新的繪製
    private var drawingGeneration: Int = 0
    
    /// 繪製隊列：專門用於異步繪製的串行隊列
    private let drawingQueue = DispatchQueue(
        label: "com.interview.asyncdrawing",
        qos: .userInitiated
    )
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        isOpaque = true
        
        // 設置 layer 的屬性
        // 由於我們直接設置 layer.contents，所以不需要調用 draw(_:)
        layer.contentsScale = UIScreen.main.scale
    }
    
    // MARK: - Async Drawing
    
    /// 觸發異步重繪
    private func asyncRedraw() {
        // 增加繪製代數，使之前的繪製請求失效
        drawingGeneration += 1
        let currentGeneration = drawingGeneration
        
        // 在主線程捕獲繪製參數（快照）
        // 這樣即使屬性在繪製過程中改變，也不會影響當前的繪製
        let drawingContext = DrawingContext(
            size: bounds.size,
            text: text,
            font: font,
            textColor: textColor,
            backgroundColor: backgroundColor ?? .white,
            drawComplexShapes: drawComplexShapes,
            scale: layer.contentsScale
        )
        
        // 如果尺寸無效，不執行繪製
        guard drawingContext.size.width > 0 && drawingContext.size.height > 0 else {
            return
        }
        
        // 在後台線程執行繪製
        drawingQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 檢查繪製是否已過期
            guard currentGeneration == self.drawingGeneration else {
                print("⚠️ 繪製請求已過期，跳過")
                return
            }
            
            // 記錄繪製開始時間
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // 執行實際的繪製操作
            guard let image = self.drawContent(with: drawingContext) else {
                print("❌ 繪製失敗")
                return
            }
            
            // 計算繪製耗時
            let elapsedTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
            
            // 回到主線程更新顯示
            DispatchQueue.main.async {
                // 再次檢查繪製是否已過期
                guard currentGeneration == self.drawingGeneration else {
                    print("⚠️ 繪製完成時已過期，不更新顯示")
                    return
                }
                
                // 將繪製結果設置給 layer
                self.layer.contents = image
                
                print("🟢 異步繪製耗時: \(String(format: "%.2f", elapsedTime))ms")
            }
        }
    }
    
    /// 在後台線程執行實際的繪製操作
    /// - Parameter context: 繪製上下文，包含所有繪製需要的參數
    /// - Returns: 繪製結果的 CGImage
    private func drawContent(with context: DrawingContext) -> CGImage? {
        // 1. 創建位圖上下文
        let scale = context.scale
        let width = Int(context.size.width * scale)
        let height = Int(context.size.height * scale)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue |
                        CGImageAlphaInfo.premultipliedFirst.rawValue
        
        guard let cgContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }
        
        // 2. 設置坐標系統
        cgContext.scaleBy(x: scale, y: scale)
        
        // 3. 繪製背景
        cgContext.setFillColor(context.backgroundColor.cgColor)
        cgContext.fill(CGRect(origin: .zero, size: context.size))
        
        // 4. 繪製複雜圖形
        if context.drawComplexShapes {
            drawComplexGraphics(in: cgContext, size: context.size)
        }
        
        // 5. 繪製文字
        drawText(in: cgContext, context: context)
        
        // 6. 繪製邊框
        cgContext.setStrokeColor(UIColor.lightGray.cgColor)
        cgContext.setLineWidth(1.0)
        let rect = CGRect(origin: .zero, size: context.size)
        cgContext.stroke(rect.insetBy(dx: 0.5, dy: 0.5))
        
        // 7. 從位圖上下文生成圖片
        return cgContext.makeImage()
    }
    
    /// 繪製複雜圖形（與同步繪製版本相同的邏輯）
    private func drawComplexGraphics(in context: CGContext, size: CGSize) {
        context.saveGState()
        
        context.setLineWidth(0.5)
        context.setStrokeColor(UIColor.systemBlue.withAlphaComponent(0.3).cgColor)
        
        // 繪製大量圓形
        let circleCount = 50
        for i in 0..<circleCount {
            let x = CGFloat(arc4random_uniform(UInt32(size.width)))
            let y = CGFloat(arc4random_uniform(UInt32(size.height)))
            let radius = CGFloat(arc4random_uniform(20)) + 5
            
            // 設置隨機顏色
            let hue = CGFloat(i) / CGFloat(circleCount)
            let color = UIColor(hue: hue, saturation: 0.5, brightness: 0.9, alpha: 0.3)
            context.setFillColor(color.cgColor)
            
            // 繪製圓形
            context.addEllipse(in: CGRect(x: x - radius, y: y - radius,
                                         width: radius * 2, height: radius * 2))
            context.drawPath(using: .fillStroke)
        }
        
        // 繪製網格線
        context.setStrokeColor(UIColor.systemGray.withAlphaComponent(0.1).cgColor)
        let gridSpacing: CGFloat = 20
        
        var x: CGFloat = 0
        while x <= size.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: size.height))
            x += gridSpacing
        }
        
        var y: CGFloat = 0
        while y <= size.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: size.width, y: y))
            y += gridSpacing
        }
        
        context.strokePath()
        context.restoreGState()
    }
    
    /// 繪製文字（需要使用 Core Text 或 UIGraphics）
    private func drawText(in context: CGContext, context drawingContext: DrawingContext) {
        context.saveGState()
        
        // 由於我們在自定義的 CGContext 中，需要使用 UIGraphics 的方式來繪製文字
        // 設置當前上下文
        UIGraphicsPushContext(context)
        
        // 設置文字屬性
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: drawingContext.font,
            .foregroundColor: drawingContext.textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        // 計算文字區域
        let textRect = CGRect(origin: .zero, size: drawingContext.size).insetBy(dx: 20, dy: 20)
        
        // 繪製文字
        let attributedString = NSAttributedString(string: drawingContext.text, attributes: attributes)
        attributedString.draw(in: textRect)
        
        UIGraphicsPopContext()
        context.restoreGState()
    }
    
    // MARK: - Public Methods
    
    /// 更新顯示內容（會觸發異步重繪）
    func updateContent(text: String? = nil, color: UIColor? = nil) {
        if let newText = text {
            self.text = newText
        }
        if let newColor = color {
            self.textColor = newColor
        }
    }
}

// MARK: - Drawing Context

/// 繪製上下文：封裝所有繪製需要的參數
/// 在主線程創建快照，傳遞給後台線程使用
private struct DrawingContext {
    let size: CGSize
    let text: String
    let font: UIFont
    let textColor: UIColor
    let backgroundColor: UIColor
    let drawComplexShapes: Bool
    let scale: CGFloat
}

